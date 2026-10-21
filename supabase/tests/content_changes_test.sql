-- Checks for supabase/migrations/20261021190119_content_changes.sql (Phase 1 of docs/plans/content-changes-plan.md).
-- Run it on a database that has the migration (local, branch, or the project after approval; to check the
-- migration BEFORE applying, paste the migration SQL above this block in the same run).
-- It makes three test users and always ends by raising VALIDATION_RESULT, so nothing is kept: the error text
-- holds the answers.
-- Expected:
--   t1  one upsert (the followed author's post), the stranger's post absent
--   t2  updated_at stays 2020-01-01 after a like and a comment; moved = true after caption, media and tag edits
--   t3  one delete op for the deleted post, log kind 'post'
--   t4  one remove op after the post goes Only me
--   t5  reset true for no point and for a point 4 days old
--   t6  story upsert, then a delete op after it is removed
--   t7  posts_by_ids returns 2 rows (a public post is readable by anyone, as the read policy allows), post_counts returns its counts
--   t8  page 1: has_more true, 2 ops; page 2: 2 ops, has_more false (3 new posts + 1 delete = 4 ops)
do $t$
declare
  a uuid := gen_random_uuid(); b uuid := gen_random_uuid(); c uuid := gen_random_uuid();
  p1 uuid := gen_random_uuid(); p2 uuid := gen_random_uuid(); p3 uuid := gen_random_uuid(); pc uuid := gen_random_uuid();
  s1 uuid := gen_random_uuid();
  cur timestamptz := now() - interval '1 hour';
  r jsonb := '{}'::jsonb; x jsonb; ts timestamptz;
begin
  insert into auth.users (id, aud, role, email) values
    (a,'authenticated','authenticated','a@t.test'),(b,'authenticated','authenticated','b@t.test'),(c,'authenticated','authenticated','c@t.test');
  insert into public.profiles (id, username, full_name, birthday, signup_step) values
    (a,'zz_a','Test A','1990-01-01',0),(b,'zz_b','Test B','1990-01-01',0),(c,'zz_c','Test C','1990-01-01',0)
    on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
      birthday = excluded.birthday, signup_step = 0;
  insert into public.follows (follower_id, following_id, status) values (b, a, 'accepted');
  update public.follows set status='accepted' where follower_id=b and following_id=a;
  insert into public.posts (id, author_id, caption) values (p1, a, 'one'), (pc, c, 'stranger');

  -- caller B
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  x := public.changes_since('post', cur);
  r := r || jsonb_build_object('t1_followed_post_upserts_stranger_absent', x);
  r := r || jsonb_build_object('t5_null_cursor', public.changes_since('post', null)->'reset',
                               't5_old_cursor', public.changes_since('post', now() - interval '4 days')->'reset');
  execute 'reset role';

  -- like and comment must not move updated_at
  set local session_replication_role = replica;
  update public.posts set updated_at = '2020-01-01' where id = p1;
  set local session_replication_role = origin;
  insert into public.post_likes (post_id, user_id) values (p1, b);
  insert into public.comments (post_id, author_id, body) values (p1, b, 'hi');
  select updated_at into ts from public.posts where id = p1;
  r := r || jsonb_build_object('t2_after_like_comment_updated_at', ts, 't2_counts', (select jsonb_build_array(like_count, comment_count) from public.posts where id = p1));
  update public.posts set caption = 'edited' where id = p1;
  select updated_at into ts from public.posts where id = p1;
  r := r || jsonb_build_object('t2_after_caption_edit_moved', ts > '2020-01-01');
  set local session_replication_role = replica;
  update public.posts set updated_at = '2020-01-01' where id = p1;
  set local session_replication_role = origin;
  insert into public.post_media (post_id, position, type, path, width, height) values (p1, 0, 'image', 'x/y.jpg', 10, 10);
  select updated_at into ts from public.posts where id = p1;
  r := r || jsonb_build_object('t2_after_media_insert_moved', ts > '2020-01-01');
  set local session_replication_role = replica;
  update public.posts set updated_at = '2020-01-01' where id = p1;
  set local session_replication_role = origin;
  insert into public.post_tags (post_id, user_id) values (p1, c);
  select updated_at into ts from public.posts where id = p1;
  r := r || jsonb_build_object('t2_after_tag_insert_moved', ts > '2020-01-01');

  -- narrowing the audience: B gets remove
  update public.posts set visibility = 'only_me' where id = p1;
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  r := r || jsonb_build_object('t4_only_me_ops', public.changes_since('post', cur)->'ops');
  execute 'reset role';
  update public.posts set visibility = 'public' where id = p1;

  -- upsert read + counts as B
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  r := r || jsonb_build_object('t7_by_ids_rows', (select count(*) from public.posts_by_ids(array[p1, pc])),
                               't7_counts', (select jsonb_agg(to_jsonb(k)) from public.post_counts(array[p1]) k));
  execute 'reset role';

  -- delete: logged, B sees delete
  delete from public.posts where id = p1;
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  r := r || jsonb_build_object('t3_delete_ops', public.changes_since('post', cur)->'ops');
  execute 'reset role';
  r := r || jsonb_build_object('t3_log_kind', (select kind from public.content_deletions where id = p1));

  -- paging
  insert into public.posts (id, author_id, caption) values (p2, a, 'two'), (p3, a, 'three'), (gen_random_uuid(), a, 'four');
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  x := public.changes_since('post', cur, null, 2);
  r := r || jsonb_build_object('t8_page1_has_more', x->'has_more', 't8_page1_n', jsonb_array_length(x->'ops'));
  x := public.changes_since('post', (x->>'next_at')::timestamptz, (x->>'next_id')::uuid, 2);
  r := r || jsonb_build_object('t8_page2_has_more', x->'has_more', 't8_page2_n', jsonb_array_length(x->'ops'));
  execute 'reset role';

  -- stories
  insert into public.stories (id, author_id, type, path, width, height) values (s1, a, 'image', 'a/stories/s.jpg', 10, 10);
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  r := r || jsonb_build_object('t6_story_new', public.changes_since('story', cur)->'ops');
  execute 'reset role';
  delete from public.stories where id = s1;
  perform set_config('request.jwt.claims', json_build_object('sub', b, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';
  r := r || jsonb_build_object('t6_story_ops_after_delete', public.changes_since('story', cur)->'ops');
  execute 'reset role';

  raise exception 'VALIDATION_RESULT %', jsonb_pretty(r);
end
$t$;
