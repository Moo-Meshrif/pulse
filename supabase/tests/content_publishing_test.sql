-- Phase 1 of docs/plans/content-publishing-plan.md: drafts, sharing, publishing, cleanup and storage
-- rules. Run with `supabase test db` on the local stack. Concurrency: content_publishing_race.sh.
begin;
create extension if not exists pgtap with schema extensions;
select plan(77);

-- People: A posts, B follows A (accepted), C has not finished sign-up.
insert into auth.users (id, email) values
  ('a0000000-0000-4000-8000-000000000000', 'a@test.local'),
  ('b0000000-0000-4000-8000-000000000000', 'b@test.local'),
  ('c0000000-0000-4000-8000-000000000000', 'c@test.local');
update public.profiles set username = 'alice', full_name = 'Alice', birthday = '1990-01-01', signup_step = 0
where id = 'a0000000-0000-4000-8000-000000000000';
update public.profiles set username = 'bob', full_name = 'Bob', birthday = '1990-01-01', signup_step = 0
where id = 'b0000000-0000-4000-8000-000000000000';
insert into public.follows (follower_id, following_id, status)
values ('b0000000-0000-4000-8000-000000000000', 'a0000000-0000-4000-8000-000000000000', 'accepted');

-- Runs p_sql as the signed-in user p_uid (role authenticated); returns its first value, or 'ERR <sqlstate>'.
create function pg_temp.as_user(p_uid uuid, p_sql text) returns text language plpgsql as $$
declare v text;
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    execute p_sql into v;
    v := coalesce(v, 'null');
  exception when others then
    v := 'ERR ' || sqlstate;
  end;
  perform set_config('role', 'postgres', true);
  perform set_config('request.jwt.claims', '', true);
  return v;
end $$;

-- A stored file, as the storage server writes it after the bytes arrived.
create function pg_temp.put(p_owner uuid, p_name text, p_size int default 1000, p_mime text default 'image/jpeg')
returns void language sql as $$
  insert into storage.objects (bucket_id, name, owner_id, metadata)
  values ('post-media', p_name, p_owner::text, jsonb_build_object('size', p_size, 'mimetype', p_mime));
$$;

-- A post request with p_n photos {author}/{id}/{i}.jpg of 1000 bytes.
create function pg_temp.post_req(p_author uuid, p_id uuid, p_n int, p_extra jsonb default '{}')
returns jsonb language sql as $$
  select jsonb_build_object('caption', 'hello', 'media', coalesce((
           select jsonb_agg(jsonb_build_object(
                    'type', 'image', 'path', p_author || '/' || p_id || '/' || i || '.jpg',
                    'width', 1080, 'height', 1350, 'size', 1000, 'mime', 'image/jpeg') order by i)
           from generate_series(0, p_n - 1) i), '[]'::jsonb)) || p_extra;
$$;

create function pg_temp.upload_all(p_author uuid, p_id uuid, p_n int) returns void language sql as $$
  select pg_temp.put(p_author, p_author || '/' || p_id || '/' || i || '.jpg') from generate_series(0, p_n - 1) i;
$$;

create function pg_temp.share(p_id uuid, p_n int, p_extra jsonb default '{}') returns text language sql as $$
  select pg_temp.as_user('a0000000-0000-4000-8000-000000000000',
    format('select public.share_content(%L, ''post'', %L::jsonb)', p_id,
           pg_temp.post_req('a0000000-0000-4000-8000-000000000000', p_id, p_n, p_extra)));
$$;

create function pg_temp.a(p_sql text) returns text language sql as $$
  select pg_temp.as_user('a0000000-0000-4000-8000-000000000000', p_sql);
$$;
create function pg_temp.b(p_sql text) returns text language sql as $$
  select pg_temp.as_user('b0000000-0000-4000-8000-000000000000', p_sql);
$$;

-- ---------------------------------------------------------------- drafts
select is(pg_temp.a($$select public.open_draft('00000000-0000-4000-8000-000000000001', 'post')$$),
          'draft', 'open_draft makes a draft');
select is(pg_temp.a($$select public.open_draft('00000000-0000-4000-8000-000000000001', 'post')$$),
          'draft', 'open_draft again returns the same draft');
select is(pg_temp.b($$select public.open_draft('00000000-0000-4000-8000-000000000001', 'post')$$),
          'ERR 42501', 'another user cannot open my draft');
select is(pg_temp.a($$select public.open_draft('00000000-0000-4000-8000-000000000001', 'short')$$),
          'ERR 22023', 'the kind cannot change');
select is(pg_temp.as_user('c0000000-0000-4000-8000-000000000000',
          $$select public.open_draft('00000000-0000-4000-8000-000000000030', 'post')$$),
          'ERR 42501', 'sign-up must be finished');
select is(pg_temp.a($$select count(*) from public.pending_content$$),
          'ERR 42501', 'the table is not readable directly');

-- ---------------------------------------------------------------- draft files
select is(pg_temp.a($$insert into storage.objects (bucket_id, name, owner_id, metadata)
                      values ('post-media', 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/0.jpg',
                              'a0000000-0000-4000-8000-000000000000', '{"size": 1000, "mimetype": "image/jpeg"}')
                      returning name$$),
          'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/0.jpg',
          'I can upload into my draft');
select is(pg_temp.b($$select count(*) from storage.objects
                      where name like 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/%'$$),
          '0', 'a follower cannot see draft files');
select is(pg_temp.a($$select count(*) from storage.objects
                      where name like 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/%'$$),
          '1', 'I can see my draft files');

-- ---------------------------------------------------------------- share + publish once
select is(pg_temp.share('00000000-0000-4000-8000-000000000001', 1), 'waiting', 'share saves the request');
select is(pg_temp.share('00000000-0000-4000-8000-000000000001', 1), 'waiting', 'the same share again is fine');
select is(pg_temp.share('00000000-0000-4000-8000-000000000001', 1, '{"caption": "other"}'),
          'ERR 22023', 'a different request for the same id is refused');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000001')$$),
          'published', 'publish posts it');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000001')$$),
          'published', 'publish again changes nothing');
select is(pg_temp.share('00000000-0000-4000-8000-000000000001', 1), 'published', 'share after posting returns published');
select is((select count(*)::int from public.posts where id = '00000000-0000-4000-8000-000000000001'),
          1, 'posting twice makes one post');
select is((select caption from public.posts where id = '00000000-0000-4000-8000-000000000001'),
          'hello', 'the post has the shared caption');
select is(pg_temp.b($$select public.publish_content('00000000-0000-4000-8000-000000000001')$$),
          'ERR 42501', 'another user cannot publish my item');
select is(pg_temp.a($$select public.discard_content('00000000-0000-4000-8000-000000000001', 'post')$$),
          'published', 'discarding a posted item says it already went out');

-- a file of the folder that is not part of the post stays private
select pg_temp.put('a0000000-0000-4000-8000-000000000000',
                   'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/late.jpg');
select is(pg_temp.b($$select string_agg(name, ',') from storage.objects
                      where name like 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/%'$$),
          'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000001/0.jpg',
          'a follower sees only the files that are part of the post');

-- ---------------------------------------------------------------- missing and wrong files
select is(pg_temp.share('00000000-0000-4000-8000-000000000002', 2), 'waiting', 'share without a draft');
select pg_temp.put('a0000000-0000-4000-8000-000000000000',
                   'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/0.jpg');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000002')$$),
          'waiting', 'publish waits while a file is missing');
select is(pg_temp.a($$select missing::text from public.content_status(array['00000000-0000-4000-8000-000000000002'::uuid])$$),
          '{a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/1.jpg}',
          'content_status lists the missing file');
select pg_temp.put('a0000000-0000-4000-8000-000000000000',
                   'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/1.jpg', 999);
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000002')$$),
          'waiting', 'a file of the wrong size does not count');
select pg_temp.put('b0000000-0000-4000-8000-000000000000',
                   'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000020/0.jpg');
select is(pg_temp.share('00000000-0000-4000-8000-000000000020', 1), 'waiting', 'share an item whose file someone else owns');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000020')$$),
          'waiting', 'a file owned by someone else does not count');
select is(pg_temp.a($$select public.discard_content('00000000-0000-4000-8000-000000000020', 'post')$$),
          'discarded', 'discard it again');

-- ---------------------------------------------------------------- discard is final
select is(pg_temp.a($$select public.discard_content('00000000-0000-4000-8000-000000000002', 'post')$$),
          'discarded', 'discard a waiting post');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000002')$$),
          'discarded', 'a discarded item is never published');
select is(pg_temp.share('00000000-0000-4000-8000-000000000002', 2), 'ERR 55000', 'share after discard is refused');
select is(pg_temp.a($$select public.create_post('00000000-0000-4000-8000-000000000002')$$),
          'ERR 55000', 'create_post refuses a discarded id');
select is(pg_temp.a($$select public.discard_content('00000000-0000-4000-8000-000000000003', 'post')$$),
          'discarded', 'discard an id the server never saw');
select is(pg_temp.a($$select public.create_post('00000000-0000-4000-8000-000000000003', p_caption => 'x')$$),
          'ERR 55000', 'create_post refuses that id too');
select is(pg_temp.a($$select public.open_draft('00000000-0000-4000-8000-000000000003', 'post')$$),
          'discarded', 'reopening a discarded draft says so');
select is(pg_temp.a($$insert into storage.objects (bucket_id, name, owner_id)
                      values ('post-media', 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/9.jpg',
                              'a0000000-0000-4000-8000-000000000000') returning name$$),
          'ERR 42501', 'no upload into a discarded folder');
select is(pg_temp.a($$insert into storage.objects (bucket_id, name, owner_id)
                      values ('post-media', 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000099/0.jpg',
                              'a0000000-0000-4000-8000-000000000000') returning 'ok'$$),
          'ok', 'a folder with no record keeps the old rule');
select is(pg_temp.a($$select public.create_post('00000000-0000-4000-8000-000000000098', p_caption => 'old app')$$),
          '00000000-0000-4000-8000-000000000098', 'create_post still works for an id with no record');

-- ---------------------------------------------------------------- cleanup
select pg_temp.put('b0000000-0000-4000-8000-000000000000',
                   'b0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000004/0.jpg');
select is(pg_temp.b($$select public.discard_content('00000000-0000-4000-8000-000000000004', 'post')$$),
          'discarded', 'B discards their own draft');
select is(pg_temp.a($$select string_agg(id || '=' || paths::text, ' ' order by id) from public.content_cleanup_list()$$),
          '00000000-0000-4000-8000-000000000002={a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/0.jpg,a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/1.jpg} '
          || '00000000-0000-4000-8000-000000000003={} '
          || '00000000-0000-4000-8000-000000000020={}',
          'cleanup lists only my discarded files, never posted files or another user''s');
select is(pg_temp.a($$select public.confirm_content_cleanup('00000000-0000-4000-8000-000000000002')$$),
          '2', 'confirm reports files still there');
set local storage.allow_delete_query = 'true';
delete from storage.objects where name like 'a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000002/%';
select is(pg_temp.a($$select public.confirm_content_cleanup('00000000-0000-4000-8000-000000000002')$$),
          '0', 'confirm after the files are gone');
select is((select cleanup_due_at::date - current_date from public.pending_content
           where id = '00000000-0000-4000-8000-000000000002'),
          1, 'it is checked again a day later');
update public.pending_content set cleanup_due_at = now() where id = '00000000-0000-4000-8000-000000000002';
select is(pg_temp.a($$select public.confirm_content_cleanup('00000000-0000-4000-8000-000000000002')$$),
          '0', 'second check');
select ok((select cleanup_due_at is null from public.pending_content where id = '00000000-0000-4000-8000-000000000002'),
          'then it is done');

-- ---------------------------------------------------------------- the minute job
select is(pg_temp.share('00000000-0000-4000-8000-000000000005', 1,
                        '{"caption": "hi @bob", "tags": [{"user_id": "b0000000-0000-4000-8000-000000000000"}]}'),
          'waiting', 'share a post with a tag and a mention');
select pg_temp.upload_all('a0000000-0000-4000-8000-000000000000', '00000000-0000-4000-8000-000000000005', 1);
select set_config('request.jwt.claims', '', true);
select is(public.publish_due(), 1, 'the job posts it with no signed-in user');
select is(current_setting('request.jwt.claims', true), '', 'the job leaves no claims behind');
select is((select string_agg(user_id::text, ',') from public.post_tags where post_id = '00000000-0000-4000-8000-000000000005'),
          'b0000000-0000-4000-8000-000000000000', 'the job keeps the tag (auth.uid() is the author)');
select is((select string_agg(type, ',' order by type) from public.notifications
           where recipient_id = 'b0000000-0000-4000-8000-000000000000'
             and post_id = '00000000-0000-4000-8000-000000000005'),
          'mention,tag', 'the job sends the tag and mention notifications');
select pg_temp.upload_all('a0000000-0000-4000-8000-000000000000', '00000000-0000-4000-8000-000000000006', 1);
select is(pg_temp.a($$select public.create_post('00000000-0000-4000-8000-000000000006', p_caption => 'hi @bob',
                        p_media => '[{"type": "image", "path": "a0000000-0000-4000-8000-000000000000/00000000-0000-4000-8000-000000000006/0.jpg", "width": 1080, "height": 1350}]',
                        p_tags => '[{"user_id": "b0000000-0000-4000-8000-000000000000"}]')$$),
          '00000000-0000-4000-8000-000000000006', 'the app path for comparison');
select is((select string_agg(type, ',' order by type) from public.notifications
           where recipient_id = 'b0000000-0000-4000-8000-000000000000'
             and post_id = '00000000-0000-4000-8000-000000000006'),
          'mention,tag', 'same notifications as the app path');

-- one bad item never blocks the others
select is(pg_temp.share('00000000-0000-4000-8000-000000000007', 1,
                        '{"tags": [{"user_id": "b0000000-0000-4000-8000-000000000000", "media_position": 5, "x": 0.5, "y": 0.5}]}'),
          'waiting', 'share a post with a tag on a photo that does not exist');
select is(pg_temp.share('00000000-0000-4000-8000-000000000008', 1), 'waiting', 'share a good post after it');
select pg_temp.upload_all('a0000000-0000-4000-8000-000000000000', '00000000-0000-4000-8000-000000000007', 1);
select pg_temp.upload_all('a0000000-0000-4000-8000-000000000000', '00000000-0000-4000-8000-000000000008', 1);
select is(public.publish_due(), 1, 'the job posts the good one');
select is((select state || ' ' || error_code from public.pending_content where id = '00000000-0000-4000-8000-000000000007'),
          'rejected 23514', 'the bad one is rejected with its SQLSTATE');
select is((select state from public.pending_content where id = '00000000-0000-4000-8000-000000000008'),
          'published', 'the good one is posted');

-- ---------------------------------------------------------------- order and limit
select is(pg_temp.share('00000000-0000-4000-8000-000000000009', 1), 'waiting', 'first post, file not there yet');
select is(pg_temp.share('00000000-0000-4000-8000-000000000010', 1), 'waiting', 'second post');
select pg_temp.upload_all('a0000000-0000-4000-8000-000000000000', '00000000-0000-4000-8000-000000000010', 1);
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000010')$$),
          'waiting', 'the second waits for the first');
select is(pg_temp.share('00000000-0000-4000-8000-000000000011', 1), 'waiting', 'third waiting');
select is(pg_temp.share('00000000-0000-4000-8000-000000000012', 1), 'ERR 53400', 'a 4th waiting is refused');
select is(pg_temp.a($$select public.discard_content('00000000-0000-4000-8000-000000000009', 'post')$$),
          'discarded', 'discard the first');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000010')$$),
          'published', 'then the second goes out');
select is(pg_temp.a($$select public.discard_content('00000000-0000-4000-8000-000000000011', 'post')$$),
          'discarded', 'discard the third');

-- ---------------------------------------------------------------- stories
select is(pg_temp.a($$select public.share_content('00000000-0000-4000-8000-000000000015', 'story',
                      '{"type": "image", "path": "a0000000-0000-4000-8000-000000000000/stories/other.jpg", "width": 1080, "height": 1920, "size": 1000, "mime": "image/jpeg"}')$$),
          'ERR 22023', 'a story file must be named after the story id');
select is(pg_temp.a($$select public.share_content('00000000-0000-4000-8000-000000000015', 'story',
                      '{"type": "image", "path": "a0000000-0000-4000-8000-000000000000/stories/00000000-0000-4000-8000-000000000015.jpg", "width": 1080, "height": 1920, "size": 1000, "mime": "image/jpeg"}')$$),
          'waiting', 'share a story');
select pg_temp.put('a0000000-0000-4000-8000-000000000000',
                   'a0000000-0000-4000-8000-000000000000/stories/00000000-0000-4000-8000-000000000015.jpg');
select is(pg_temp.b($$select count(*) from storage.objects
                      where name = 'a0000000-0000-4000-8000-000000000000/stories/00000000-0000-4000-8000-000000000015.jpg'$$),
          '0', 'a follower cannot see a story file before it is posted');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000015')$$),
          'published', 'the story is posted');
select is(pg_temp.b($$select count(*) from storage.objects
                      where name = 'a0000000-0000-4000-8000-000000000000/stories/00000000-0000-4000-8000-000000000015.jpg'$$),
          '1', 'then the follower sees it');
select ok((select expires_at = now() + interval '24 hours' from public.stories
           where id = '00000000-0000-4000-8000-000000000015'), 'its 24 hours start at publish');

-- ---------------------------------------------------------------- limits of the request
select is(pg_temp.a(format('select public.share_content(%L, ''post'', %L::jsonb)', '00000000-0000-4000-8000-000000000016',
                           jsonb_build_object('caption', repeat('x', 70000)))),
          'ERR 22023', 'a request over 64 KB is refused');

-- ---------------------------------------------------------------- hourly and daily jobs
select is(pg_temp.a($$select public.open_draft('00000000-0000-4000-8000-000000000017', 'post')$$), 'draft', 'a draft');
update public.pending_content set updated_at = now() - interval '31 days' where id = '00000000-0000-4000-8000-000000000017';
select is(pg_temp.share('00000000-0000-4000-8000-000000000018', 1), 'waiting', 'a shared item');
update public.pending_content set shared_at = now() - interval '4 days' where id = '00000000-0000-4000-8000-000000000018';
select is(public.expire_pending_content(), 2, 'an old draft and an old shared item are given up');
select is((select string_agg(state, ',' order by id) from public.pending_content
           where id in ('00000000-0000-4000-8000-000000000017', '00000000-0000-4000-8000-000000000018')),
          'abandoned,abandoned', 'both are abandoned');
select is(pg_temp.a($$select public.publish_content('00000000-0000-4000-8000-000000000018')$$),
          'abandoned', 'an abandoned item is never published');
update public.pending_content set finished_at = now() - interval '31 days'
where id = '00000000-0000-4000-8000-000000000001';
select is(public.purge_pending_content(), 1, 'an old finished record is removed');

select * from finish();
rollback;
