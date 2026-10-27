-- Checks for supabase/migrations/20261027173905_update_post_settings.sql (update_post also saves the comments
-- switch and the audience in the same transaction).
-- Run it on a LOCAL database that has the migration (supabase/tests/update_post_settings_rpc.sh does it and
-- also checks the same RPC through PostgREST). Do not run it on the project: it writes users, posts and
-- storage rows (it always ends by raising VALIDATION_RESULT, so nothing is kept, but a project database is
-- not the place for a test that inserts into auth.users).
-- Expected:
--   t1  the old 8-parameter call (no settings) still works: caption 'new caption', location 'new place', mood
--       'happy' saved; comments switch and audience stay as they were (t1_comments false, t1_visibility
--       close_friends)
--   t2  settings given: both change together with the caption; only the comments switch; only the audience
--   t3  null settings (explicit nulls) change nothing
--   t4  an invalid audience ('secret', '') is 22023 and nothing changes (caption included); someone else's
--       post, no session and the anon role are refused (42501); a post that is not a 'post' kind is refused
--   t5  rollback: a call that fails AFTER its updates (21 tags) leaves caption, comments, audience, media rows,
--       media_count and tags exactly as they were
--   t6  media and tags behave as before: media replaced in order with media_count; a file that was not
--       uploaded is 22023; a path outside the user's folder is 42501; 11 media is check_violation; tags
--       stored, replaced and cleared; a person who does not allow tags and the author are dropped silently;
--       a tag on a photo that is gone is check_violation
--   t7  exactly one update_post signature (10 parameters), the old 8-parameter one is gone, anon and public
--       cannot run it, authenticated can
create or replace function pg_temp.as_user(p_user uuid) returns void language plpgsql as $f$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  execute 'reset role';
  execute 'set local role authenticated';
end;
$f$;

-- One saved post of [a]: followers-only look is not wanted, so the odd values are comments off + close friends.
create or replace function pg_temp.fresh_post(p uuid, a uuid, b uuid) returns void language plpgsql as $f$
begin
  execute 'reset role';
  delete from public.posts where id = p;
  insert into public.posts (id, author_id, caption, location, media_count, comments_enabled, visibility)
    values (p, a, 'old caption', 'old place', 2, false, 'close_friends');
  insert into public.post_media (post_id, position, type, path, width, height) values
    (p, 0, 'image', a::text || '/' || p::text || '/0.jpg', 10, 10),
    (p, 1, 'image', a::text || '/' || p::text || '/1.jpg', 10, 10);
  insert into public.post_tags (post_id, user_id, media_position, x, y) values (p, b, 1, 0.5, 0.5);
end;
$f$;

-- What a post looks like, for before/after comparisons.
create or replace function pg_temp.snap(p uuid) returns jsonb language sql as $f$
  select jsonb_build_object(
    'caption', po.caption, 'location', po.location, 'comments', po.comments_enabled,
    'visibility', po.visibility, 'media_count', po.media_count,
    'media', (select coalesce(jsonb_agg(m.path order by m.position), '[]'::jsonb) from public.post_media m where m.post_id = p),
    'tags', (select coalesce(jsonb_agg(t.user_id order by t.user_id), '[]'::jsonb) from public.post_tags t where t.post_id = p))
  from public.posts po where po.id = p;
$f$;

do $t$
declare
  a uuid := gen_random_uuid(); b uuid := gen_random_uuid(); c uuid := gen_random_uuid(); d uuid := gen_random_uuid();
  p uuid := gen_random_uuid(); ps uuid := gen_random_uuid();
  r jsonb := '{}'::jsonb; before_ jsonb; after_ jsonb; s jsonb; i integer; many jsonb;
  pre text;
begin
  insert into auth.users (id, aud, role, email) values
    (a,'authenticated','authenticated','ua@t.test'),(b,'authenticated','authenticated','ub@t.test'),
    (c,'authenticated','authenticated','uc@t.test'),(d,'authenticated','authenticated','ud@t.test');
  insert into public.profiles (id, username, full_name, birthday, signup_step) values
    (a,'zz_ua','Test A','1990-01-01',0),(b,'zz_ub','Test B','1990-01-01',0),
    (c,'zz_uc','Test C','1990-01-01',0),(d,'zz_ud','Test D','1990-01-01',0)
    on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
      birthday = excluded.birthday, signup_step = 0;
  update public.profiles set allow_tags = 'none' where id = d;
  pre := a::text || '/' || p::text || '/';
  -- Files the edits may use.
  insert into storage.objects (bucket_id, name, owner_id, metadata) values
    ('post-media', pre || 'n0.jpg', a::text, '{"size":1000,"mimetype":"image/jpeg"}'),
    ('post-media', pre || 'n1.jpg', a::text, '{"size":1000,"mimetype":"image/jpeg"}'),
    ('post-media', pre || '0.jpg',  a::text, '{"size":1000,"mimetype":"image/jpeg"}'),
    ('post-media', pre || '1.jpg',  a::text, '{"size":1000,"mimetype":"image/jpeg"}');

  -- t1: the old 8-parameter call, by name, exactly as the app sent it before the migration.
  perform pg_temp.fresh_post(p, a, b);
  perform pg_temp.as_user(a);
  perform public.update_post(
    p_id => p, p_caption => 'new caption', p_location => 'new place',
    p_media => jsonb_build_array(
      jsonb_build_object('type','image','path',pre||'0.jpg','width',10,'height',10),
      jsonb_build_object('type','image','path',pre||'1.jpg','width',10,'height',10)),
    p_mood_kind => 'feeling', p_mood_key => 'happy', p_mood_text => null, p_tags => '[]'::jsonb);
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t1_caption', s->>'caption', 't1_location', s->>'location',
    't1_comments', (s->>'comments')::boolean, 't1_visibility', s->>'visibility',
    't1_mood', (select mood_key from public.posts where id = p));

  -- t2: settings given.
  perform pg_temp.fresh_post(p, a, b);
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'both', p_media => (select to_jsonb(array_agg(jsonb_build_object('type','image','path',pre||x||'.jpg','width',10,'height',10) order by x)) from unnest(array['0','1']) x),
    p_comments_enabled => true, p_visibility => 'only_me');
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t2_both_caption', s->>'caption', 't2_both_comments', (s->>'comments')::boolean, 't2_both_visibility', s->>'visibility');
  perform pg_temp.fresh_post(p, a, b);
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'comments only', p_media => (select to_jsonb(array_agg(jsonb_build_object('type','image','path',pre||x||'.jpg','width',10,'height',10) order by x)) from unnest(array['0','1']) x),
    p_comments_enabled => true);
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t2_comments_only', (s->>'comments')::boolean, 't2_comments_only_visibility', s->>'visibility');
  perform pg_temp.fresh_post(p, a, b);
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'audience only', p_media => (select to_jsonb(array_agg(jsonb_build_object('type','image','path',pre||x||'.jpg','width',10,'height',10) order by x)) from unnest(array['0','1']) x),
    p_visibility => 'public');
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t2_audience_only', s->>'visibility', 't2_audience_only_comments', (s->>'comments')::boolean);
  -- and back to false: false is a value, not "unchanged"
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'back', p_media => (select to_jsonb(array_agg(jsonb_build_object('type','image','path',pre||x||'.jpg','width',10,'height',10) order by x)) from unnest(array['0','1']) x),
    p_comments_enabled => false, p_visibility => 'close_friends');
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t2_false_is_a_value', not (s->>'comments')::boolean, 't2_close_friends', s->>'visibility');

  -- t3: explicit nulls change nothing.
  perform pg_temp.fresh_post(p, a, b);
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'nulls', p_media => (select to_jsonb(array_agg(jsonb_build_object('type','image','path',pre||x||'.jpg','width',10,'height',10) order by x)) from unnest(array['0','1']) x),
    p_comments_enabled => null, p_visibility => null);
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t3_comments', (s->>'comments')::boolean, 't3_visibility', s->>'visibility', 't3_caption', s->>'caption');

  -- t4: invalid audience, someone else, no session, anon, wrong kind.
  perform pg_temp.fresh_post(p, a, b);
  before_ := pg_temp.snap(p);
  perform pg_temp.as_user(a);
  begin
    perform public.update_post(p_id => p, p_caption => 'x', p_media => '[]'::jsonb, p_visibility => 'secret');
    r := r || jsonb_build_object('t4_secret', 'allowed');
  exception when others then r := r || jsonb_build_object('t4_secret', sqlstate); end;
  begin
    perform public.update_post(p_id => p, p_caption => 'x', p_media => '[]'::jsonb, p_visibility => '');
    r := r || jsonb_build_object('t4_empty', 'allowed');
  exception when others then r := r || jsonb_build_object('t4_empty', sqlstate); end;
  execute 'reset role';
  r := r || jsonb_build_object('t4_invalid_changes_nothing', pg_temp.snap(p) = before_);
  perform pg_temp.as_user(b);
  begin
    perform public.update_post(p_id => p, p_caption => 'hijack', p_media => '[]'::jsonb, p_comments_enabled => true, p_visibility => 'public');
    r := r || jsonb_build_object('t4_stranger', 'allowed');
  exception when others then r := r || jsonb_build_object('t4_stranger', sqlstate); end;
  execute 'reset role';
  r := r || jsonb_build_object('t4_stranger_changes_nothing', pg_temp.snap(p) = before_);
  perform set_config('request.jwt.claims', '{}', true);
  execute 'set local role authenticated';
  begin
    perform public.update_post(p_id => p, p_caption => 'x', p_media => '[]'::jsonb);
    r := r || jsonb_build_object('t4_no_session', 'allowed');
  exception when others then r := r || jsonb_build_object('t4_no_session', sqlstate); end;
  execute 'reset role';
  execute 'set local role anon';
  begin
    perform public.update_post(p_id => p, p_caption => 'x', p_media => '[]'::jsonb);
    r := r || jsonb_build_object('t4_anon', 'allowed');
  exception when others then r := r || jsonb_build_object('t4_anon', sqlstate); end;
  execute 'reset role';
  -- a short is not a 'post': refused even for its author (if shorts can exist without media here)
  begin
    insert into public.posts (id, author_id, caption, kind) values (ps, a, 'a short', 'short');
    perform pg_temp.as_user(a);
    begin
      perform public.update_post(p_id => ps, p_caption => 'x', p_media => '[]'::jsonb, p_visibility => 'public');
      r := r || jsonb_build_object('t4_not_a_post', 'allowed');
    exception when others then r := r || jsonb_build_object('t4_not_a_post', sqlstate); end;
    execute 'reset role';
  exception when others then
    execute 'reset role';
    r := r || jsonb_build_object('t4_not_a_post', 'skipped: ' || sqlstate);
  end;

  -- t5: a failure after the updates rolls everything back (21 tags raises after caption, settings and media
  -- were already written inside the function).
  perform pg_temp.fresh_post(p, a, b);
  before_ := pg_temp.snap(p);
  select jsonb_agg(jsonb_build_object('user_id', gen_random_uuid())) into many from generate_series(1, 21);
  perform pg_temp.as_user(a);
  begin
    perform public.update_post(p_id => p, p_caption => 'half done', p_location => 'half place',
      p_media => jsonb_build_array(jsonb_build_object('type','image','path',pre||'n0.jpg','width',10,'height',10)),
      p_tags => many, p_comments_enabled => true, p_visibility => 'only_me');
    r := r || jsonb_build_object('t5_error', 'allowed');
  exception when others then r := r || jsonb_build_object('t5_error', sqlstate); end;
  execute 'reset role';
  after_ := pg_temp.snap(p);
  r := r || jsonb_build_object('t5_nothing_changed', after_ = before_, 't5_caption', after_->>'caption',
    't5_comments', (after_->>'comments')::boolean, 't5_visibility', after_->>'visibility',
    't5_media', after_->'media', 't5_tags_kept', after_->'tags' = before_->'tags');

  -- t6: media and tags.
  perform pg_temp.fresh_post(p, a, b);
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'media',
    p_media => jsonb_build_array(
      jsonb_build_object('type','image','path',pre||'n1.jpg','width',20,'height',20),
      jsonb_build_object('type','image','path',pre||'n0.jpg','width',20,'height',20)),
    p_tags => jsonb_build_array(
      jsonb_build_object('user_id', c, 'media_position', 0, 'x', 0.25, 'y', 0.75),
      jsonb_build_object('user_id', d),
      jsonb_build_object('user_id', a)));
  execute 'reset role';
  s := pg_temp.snap(p);
  r := r || jsonb_build_object('t6_media_order', s->'media', 't6_media_count', (s->>'media_count')::int,
    't6_tags_replaced', s->'tags' = jsonb_build_array(c),
    't6_tag_spot', (select (media_position = 0 and x = 0.25 and y = 0.75) from public.post_tags where post_id = p and user_id = c),
    't6_untaggable_and_author_dropped', not exists (select 1 from public.post_tags where post_id = p and user_id in (d, a)),
    't6_old_tag_removed', not exists (select 1 from public.post_tags where post_id = p and user_id = b));
  -- tags cleared
  perform pg_temp.as_user(a);
  perform public.update_post(p_id => p, p_caption => 'media',
    p_media => jsonb_build_array(jsonb_build_object('type','image','path',pre||'n1.jpg','width',20,'height',20)),
    p_tags => '[]'::jsonb);
  execute 'reset role';
  r := r || jsonb_build_object('t6_tags_cleared', (select count(*) from public.post_tags where post_id = p),
    't6_one_media', (select media_count from public.posts where id = p));
  -- a file that was not uploaded, a path outside the folder, too many media, a tag on a photo that is gone
  perform pg_temp.fresh_post(p, a, b);
  before_ := pg_temp.snap(p);
  perform pg_temp.as_user(a);
  begin
    perform public.update_post(p_id => p, p_caption => 'x', p_media => jsonb_build_array(jsonb_build_object('type','image','path',pre||'missing.jpg','width',10,'height',10)), p_visibility => 'only_me');
    r := r || jsonb_build_object('t6_not_uploaded', 'allowed');
  exception when others then r := r || jsonb_build_object('t6_not_uploaded', sqlstate); end;
  begin
    perform public.update_post(p_id => p, p_caption => 'x', p_media => jsonb_build_array(jsonb_build_object('type','image','path',b::text||'/'||p::text||'/0.jpg','width',10,'height',10)));
    r := r || jsonb_build_object('t6_other_folder', 'allowed');
  exception when others then r := r || jsonb_build_object('t6_other_folder', sqlstate); end;
  begin
    perform public.update_post(p_id => p, p_caption => 'x',
      p_media => (select jsonb_agg(jsonb_build_object('type','image','path',pre||'0.jpg','width',10,'height',10)) from generate_series(1, 11)));
    r := r || jsonb_build_object('t6_eleven_media', 'allowed');
  exception when others then r := r || jsonb_build_object('t6_eleven_media', sqlstate); end;
  begin
    perform public.update_post(p_id => p, p_caption => 'x',
      p_media => jsonb_build_array(jsonb_build_object('type','image','path',pre||'0.jpg','width',10,'height',10)),
      p_tags => jsonb_build_array(jsonb_build_object('user_id', c, 'media_position', 3, 'x', 0.5, 'y', 0.5)));
    r := r || jsonb_build_object('t6_tag_on_missing_photo', 'allowed');
  exception when others then r := r || jsonb_build_object('t6_tag_on_missing_photo', sqlstate); end;
  execute 'reset role';
  r := r || jsonb_build_object('t6_refusals_change_nothing', pg_temp.snap(p) = before_);

  -- t7: one signature, no 8-parameter one, who can run it.
  r := r || jsonb_build_object(
    't7_signatures', (select count(*) from pg_proc pr join pg_namespace n on n.oid = pr.pronamespace
                      where n.nspname = 'public' and pr.proname = 'update_post'),
    't7_params', (select pr.pronargs from pg_proc pr join pg_namespace n on n.oid = pr.pronamespace
                  where n.nspname = 'public' and pr.proname = 'update_post' limit 1),
    't7_old_signature_gone', to_regprocedure('public.update_post(uuid,text,text,jsonb,text,text,text,jsonb)') is null,
    't7_anon_can_run', has_function_privilege('anon', 'public.update_post(uuid,text,text,jsonb,text,text,text,jsonb,boolean,text)', 'execute'),
    't7_authenticated_can_run', has_function_privilege('authenticated', 'public.update_post(uuid,text,text,jsonb,text,text,text,jsonb,boolean,text)', 'execute'),
    't7_security_definer', (select pr.prosecdef from pg_proc pr join pg_namespace n on n.oid = pr.pronamespace
                            where n.nspname = 'public' and pr.proname = 'update_post' limit 1));

  execute 'reset role';
  raise exception 'VALIDATION_RESULT %', r::text;
end;
$t$;
