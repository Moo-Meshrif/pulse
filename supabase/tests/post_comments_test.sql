-- Checks for supabase/migrations/20261025180433_post_comments.sql (Phase 26 of docs/plans/post-plan.md).
-- Run it on a database that has the migration (local, branch, or the project after approval; to check the
-- migration BEFORE applying, paste the migration SQL above this block in the same run).
-- It makes four test users and always ends by raising VALIDATION_RESULT, so nothing is kept: the error text
-- holds the answers.
-- Expected:
--   t1  reply_to_reply_parent = the top-level comment id (true); reply parent is the top-level comment
--   t2  empty and 1001-char bodies refused (22023), 1000 chars accepted
--   t3  retry with the same client id: same id, one row
--   t4  like twice = 1, unlike = 0, liked_by_me true after the like
--   t5  edit by the writer sets edited_at; edit by someone else = 42501; same words = no edited_at
--   t6  relevant: the thread the author answered is first even though it is older; newest: newest first;
--       paging with the row's rank, created_at and id gives the next row, then an empty page
--   t7  4 replies: top-level row shows 3, reply_count 4; comment_replies after the 3rd returns 1
--   t8  hide: count drops, stranger does not see it, the writer still does; non-owner 42501; own comment 42501;
--       Undo restores; hiding a thread hides its replies and Undo brings back the same ones
--   t9  delete by the writer removes the replies and fixes the count; by someone else 42501
--   t10 comments off: add refused 22023, reading still works
--   t11 a followers-only post is P0002 for a stranger (read and write)
--   t12 focus on a reply: thread first with the reply inside, is_focus true, never listed twice
--   t13 mention candidates: the post author and thread people first, a prefix filter, at most the limit
--   t14 report: other's comment ok twice (one row), own comment 22023, hidden comment 22023
--   t15 notifications: comment, reply and mention rows exist
--   t16 direct table access is denied (42501)
create or replace function pg_temp.as_user(p_user uuid) returns void language plpgsql as $f$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  execute 'reset role';
  execute 'set local role authenticated';
end;
$f$;

do $t$
declare
  a uuid := gen_random_uuid(); b uuid := gen_random_uuid(); c uuid := gen_random_uuid(); d uuid := gen_random_uuid();
  p uuid := gen_random_uuid(); pf uuid := gen_random_uuid();
  r jsonb := '{}'::jsonb; x jsonb; y jsonb; z jsonb;
  c1 uuid; c2 uuid; r1 uuid; rr uuid; k uuid := gen_random_uuid();
  n integer; code bigint;
begin
  insert into auth.users (id, aud, role, email) values
    (a,'authenticated','authenticated','a@t.test'),(b,'authenticated','authenticated','b@t.test'),
    (c,'authenticated','authenticated','c@t.test'),(d,'authenticated','authenticated','d@t.test');
  insert into public.profiles (id, username, full_name, birthday, signup_step) values
    (a,'zz_a','Test A','1990-01-01',0),(b,'zz_b','Test B','1990-01-01',0),
    (c,'zz_c','Test C','1990-01-01',0),(d,'zz_d','Test D','1990-01-01',0)
    on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
      birthday = excluded.birthday, signup_step = 0;
  insert into public.follows (follower_id, following_id, status) values (b, a, 'accepted'), (d, a, 'accepted');
  update public.follows set status='accepted' where following_id = a;
  insert into public.posts (id, author_id, caption) values (p, a, 'public post');
  insert into public.posts (id, author_id, caption, visibility) values (pf, a, 'followers post', 'followers');

  -- t1 t2 t3: b writes
  perform pg_temp.as_user(b);
  x := public.add_comment(p, 'first comment', null, null);
  c1 := (x->>'id')::uuid;
  perform pg_temp.as_user(a);
  y := public.add_comment(p, 'author reply', c1, null);
  r1 := (y->>'id')::uuid;
  perform pg_temp.as_user(b);
  z := public.add_comment(p, 'reply to the reply', r1, null);
  rr := (z->>'id')::uuid;
  r := r || jsonb_build_object('t1_reply_parent', (y->>'parent_id')::uuid = c1,
                               't1_reply_to_reply_parent', (z->>'parent_id')::uuid = c1,
                               't1_author_flag', (y->>'is_post_author')::boolean);

  begin perform public.add_comment(p, '   ', null, null); r := r || jsonb_build_object('t2_empty', 'allowed');
  exception when others then r := r || jsonb_build_object('t2_empty', sqlstate); end;
  begin perform public.add_comment(p, repeat('x', 1001), null, null); r := r || jsonb_build_object('t2_long', 'allowed');
  exception when others then r := r || jsonb_build_object('t2_long', sqlstate); end;
  x := public.add_comment(p, repeat('y', 1000), null, null);
  r := r || jsonb_build_object('t2_1000_ok', x->>'id' is not null);
  perform public.delete_comment((x->>'id')::uuid);

  x := public.add_comment(p, 'safe retry', null, k);
  y := public.add_comment(p, 'safe retry', null, k);
  execute 'reset role';
  select count(*) into n from public.comments where client_id = k;
  r := r || jsonb_build_object('t3_same_id', x->>'id' = y->>'id', 't3_rows', n);
  perform pg_temp.as_user(b);
  perform public.delete_comment((x->>'id')::uuid);

  -- t4 likes
  perform pg_temp.as_user(c);
  perform public.set_comment_like(c1, true);
  n := public.set_comment_like(c1, true);
  r := r || jsonb_build_object('t4_like_twice', n);
  r := r || jsonb_build_object('t4_liked_by_me', (select (e->>'liked_by_me')::boolean
                                                    from jsonb_array_elements(public.post_comments(p, 'newest')) e
                                                   where e->>'id' = c1::text));
  n := public.set_comment_like(c1, false);
  r := r || jsonb_build_object('t4_unlike', n);

  -- t5 edit
  perform pg_temp.as_user(b);
  x := public.edit_comment(c1, 'first comment (edited)');
  r := r || jsonb_build_object('t5_edited_at_set', x->>'edited_at' is not null);
  perform pg_temp.as_user(c);
  begin perform public.edit_comment(c1, 'hacked'); r := r || jsonb_build_object('t5_other', 'allowed');
  exception when others then r := r || jsonb_build_object('t5_other', sqlstate); end;
  perform pg_temp.as_user(b);
  x := public.edit_comment(rr, 'reply to the reply');
  r := r || jsonb_build_object('t5_same_words_no_edit', x->>'edited_at' is null);

  -- t6 order: c2 is newer, but c1 was answered by the author
  perform pg_temp.as_user(c);
  x := public.add_comment(p, 'second comment', null, null);
  c2 := (x->>'id')::uuid;
  -- every row of one run shares the transaction time: make c2 clearly the newest
  execute 'reset role';
  update public.comments set created_at = now() + interval '1 minute' where id = c2;
  perform pg_temp.as_user(c);
  y := public.post_comments(p, 'relevant');
  -- keyset: one row per page, in the same order, then nothing
  x := public.post_comments(p, 'relevant', 1, (y->0->>'rank')::int, (y->0->>'created_at')::timestamptz, (y->0->>'id')::uuid);
  z := public.post_comments(p, 'relevant', 1, (x->0->>'rank')::int, (x->0->>'created_at')::timestamptz, (x->0->>'id')::uuid);
  r := r || jsonb_build_object('t6_page2_is_second_row', x->0->>'id' = y->1->>'id', 't6_page3_empty', jsonb_array_length(z),
                               't6_rank_present', y->0->>'rank');
  z := public.post_comments(p, 'newest');
  r := r || jsonb_build_object('t6_relevant_first', (y->0->>'id')::uuid = c1,
                               't6_newest_first', (z->0->>'id')::uuid = c2);

  -- t7 replies paging
  perform pg_temp.as_user(a);
  perform public.add_comment(p, 'reply 3', c1, null);
  perform public.add_comment(p, 'reply 4', c1, null);
  y := (public.post_comments(p, 'relevant'))->0;
  r := r || jsonb_build_object('t7_shown', jsonb_array_length(y->'replies'), 't7_reply_count', y->>'reply_count');
  x := public.comment_replies(c1, 20, (y->'replies'->2->>'created_at')::timestamptz, (y->'replies'->2->>'id')::uuid);
  r := r || jsonb_build_object('t7_rest', jsonb_array_length(x));

  -- t8 hide
  select comment_count into n from public.posts where id = p;
  r := r || jsonb_build_object('t8_count_before', n);
  perform public.hide_comment(c2, true);
  select comment_count into n from public.posts where id = p;
  r := r || jsonb_build_object('t8_count_after_hide', n);
  perform pg_temp.as_user(d);
  r := r || jsonb_build_object('t8_stranger_sees', (select count(*) from jsonb_array_elements(public.post_comments(p)) e where e->>'id' = c2::text));
  perform pg_temp.as_user(c);
  r := r || jsonb_build_object('t8_writer_sees', (select count(*) from jsonb_array_elements(public.post_comments(p)) e where e->>'id' = c2::text));
  begin perform public.hide_comment(c1, true); r := r || jsonb_build_object('t8_non_owner', 'allowed');
  exception when others then r := r || jsonb_build_object('t8_non_owner', sqlstate); end;
  perform pg_temp.as_user(a);
  x := public.add_comment(p, 'my own', null, null);
  begin perform public.hide_comment((x->>'id')::uuid, true); r := r || jsonb_build_object('t8_own', 'allowed');
  exception when others then r := r || jsonb_build_object('t8_own', sqlstate); end;
  perform public.delete_comment((x->>'id')::uuid);
  perform public.hide_comment(c2, false);
  select comment_count into n from public.posts where id = p;
  r := r || jsonb_build_object('t8_count_after_undo', n);
  -- hide a thread (c1 has 4 replies: r1, rr, 2 more) and bring it back
  perform public.hide_comment(c1, true);
  select comment_count into n from public.posts where id = p;
  r := r || jsonb_build_object('t8_count_thread_hidden', n);
  perform public.hide_comment(c1, false);
  select comment_count into n from public.posts where id = p;
  r := r || jsonb_build_object('t8_count_thread_back', n);

  -- t14 report (before the delete tests): c reports b's comment
  perform pg_temp.as_user(c);
  perform public.report_content('comment', c1, 'spam', null);
  perform public.report_content('comment', c1, 'spam', null);
  begin perform public.report_content('comment', c2, 'spam', null); r := r || jsonb_build_object('t14_own', 'allowed');
  exception when others then r := r || jsonb_build_object('t14_own', sqlstate); end;
  perform pg_temp.as_user(a);
  perform public.hide_comment(c1, true);
  perform pg_temp.as_user(d);
  begin perform public.report_content('comment', c1, 'spam', null); r := r || jsonb_build_object('t14_hidden', 'allowed');
  exception when others then r := r || jsonb_build_object('t14_hidden', sqlstate); end;
  perform pg_temp.as_user(a);
  perform public.hide_comment(c1, false);
  execute 'reset role';
  select count(*) into n from public.reports where comment_id = c1;
  r := r || jsonb_build_object('t14_rows', n);

  -- t12 focus on a reply
  perform pg_temp.as_user(d);
  y := public.post_comments(p, 'newest', 20, null, null, null, rr);
  r := r || jsonb_build_object('t12_first_is_thread', (y->0->>'id')::uuid = c1,
                               't12_focus_flag', (y->0->>'is_focus')::boolean,
                               't12_reply_included', exists (select 1 from jsonb_array_elements(y->0->'replies') e where e->>'id' = rr::text),
                               't12_listed_once', (select count(*) from jsonb_array_elements(y) e where e->>'id' = c1::text));
  y := public.post_comments(p, 'newest', 20, null, null, null, c2);
  r := r || jsonb_build_object('t12_top_focus_first', (y->0->>'id')::uuid = c2);

  -- t13 mention candidates
  perform pg_temp.as_user(b);
  r := r || jsonb_build_object('t13_all', (select jsonb_agg(username) from public.comment_mention_candidates(p, null, 3)),
                               't13_prefix', (select jsonb_agg(username) from public.comment_mention_candidates(p, 'zz_d', 3)),
                               't13_none', (select count(*) from public.comment_mention_candidates(p, 'nomatch', 3)));

  -- t15 notifications, with a mention of d
  perform pg_temp.as_user(b);
  perform public.add_comment(p, 'hello @zz_d', null, null);
  execute 'reset role';
  r := r || jsonb_build_object('t15_comment', (select count(*) from public.notifications where recipient_id = a and type = 'comment'),
                               't15_reply', (select count(*) from public.notifications where recipient_id = b and type = 'reply'),
                               't15_mention', (select count(*) from public.notifications where recipient_id = d and type = 'mention'));

  -- t9 delete
  perform pg_temp.as_user(c);
  begin perform public.delete_comment(c1); r := r || jsonb_build_object('t9_other', 'allowed');
  exception when others then r := r || jsonb_build_object('t9_other', sqlstate); end;
  perform pg_temp.as_user(b);
  perform public.delete_comment(c1);
  execute 'reset role';
  select count(*) into n from public.comments where id = c1 or parent_id = c1;
  r := r || jsonb_build_object('t9_rows_left', n);
  select comment_count into n from public.posts where id = p;
  select count(*) into code from public.comments where post_id = p and hidden_at is null;
  r := r || jsonb_build_object('t9_count', n, 't9_visible_rows', code);

  -- t10 comments off
  update public.posts set comments_enabled = false where id = p;
  perform pg_temp.as_user(c);
  begin perform public.add_comment(p, 'late', null, null); r := r || jsonb_build_object('t10_add', 'allowed');
  exception when others then r := r || jsonb_build_object('t10_add', sqlstate); end;
  r := r || jsonb_build_object('t10_read', jsonb_array_length(public.post_comments(p)));

  -- t11 followers-only post
  begin perform public.post_comments(pf); r := r || jsonb_build_object('t11_read', 'allowed');
  exception when others then r := r || jsonb_build_object('t11_read', sqlstate); end;
  begin perform public.add_comment(pf, 'hi', null, null); r := r || jsonb_build_object('t11_write', 'allowed');
  exception when others then r := r || jsonb_build_object('t11_write', sqlstate); end;

  -- t16 direct access
  begin perform 1 from public.comments limit 1; r := r || jsonb_build_object('t16_select', 'allowed');
  exception when others then r := r || jsonb_build_object('t16_select', sqlstate); end;
  begin insert into public.comments (post_id, body) values (p, 'x'); r := r || jsonb_build_object('t16_insert', 'allowed');
  exception when others then r := r || jsonb_build_object('t16_insert', sqlstate); end;

  execute 'reset role';
  raise exception 'VALIDATION_RESULT %', r::text;
end;
$t$;
