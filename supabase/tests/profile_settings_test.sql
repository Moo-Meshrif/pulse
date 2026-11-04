-- Checks for the Phase 2 migrations 20261028090000..090400 (privacy, post subscriptions, blocks, help and reports,
-- delete account).
-- Run it on a LOCAL database that has the migrations (profile_settings_rpc.sh does it). Do not run it on the project:
-- it writes users, posts and storage rows (it always ends by raising VALIDATION_RESULT, so nothing is kept).
-- It checks itself: the result is "all passed" or the list of failed checks.
-- Cast: a, b (public), c (private), d (public, spare), x (deleted at the end).
-- Checks:
--   t1  who_can_comment: followers-only refuses a stranger and lets a follower and the author in; none refuses
--       everyone but the author; invalid values and is_verified are refused by the table
--   t2  Private off keeps a pending request pending
--   t3  blocks: both follows removed, close friends / mutes / post subscriptions gone; a blocked pair cannot see
--       each other's posts or profile; the target gets no profile row, the blocker gets blocked_by_me; no new
--       follow; leaves lists, search and username lookup; notify() skips the pair; unblock keeps follows removed;
--       blocked_users pages; self and unknown ids are refused
--   t4  appear_in_search off hides a person from suggestions
--   t5  post notifications: a subscriber hears about a public post, not an only-me post nor a followers post when
--       not following; subscribing to a blocked author is refused
--   t6  help content is readable and not writable
--   t7  problem reports: stored; bad category, message, screenshots and foreign paths are 22023; no direct access
--   t8  report_user: stored once; yourself, bad reason, unknown person are refused
--   t9  delete_my_account: the person, profile, posts and storage files are gone, others stay; anon cannot run it
create or replace function pg_temp.as_user(p_user uuid) returns void language plpgsql as $f$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  execute 'reset role';
  execute 'set local role authenticated';
end;
$f$;

-- Runs one statement, returns 'ok' or 'SQLSTATE message'.
create or replace function pg_temp.try(p_sql text) returns text language plpgsql as $f$
begin
  execute p_sql;
  return 'ok';
exception when others then
  return sqlstate || ' ' || sqlerrm;
end;
$f$;

create or replace function pg_temp.chk(p_name text, p_have anyelement, p_want anyelement) returns jsonb language sql as $f$
  select case when p_have is not distinct from p_want then '[]'::jsonb
              else jsonb_build_array(p_name || ' (have: ' || coalesce(p_have::text, 'null') || ', want: ' || coalesce(p_want::text, 'null') || ')') end;
$f$;

do $t$
declare
  a uuid := gen_random_uuid(); b uuid := gen_random_uuid(); c uuid := gen_random_uuid();
  d uuid := gen_random_uuid(); x uuid := gen_random_uuid();
  pa uuid := gen_random_uuid(); pb uuid := gen_random_uuid(); pb_only uuid := gen_random_uuid();
  pb_fol uuid := gen_random_uuid(); px uuid := gen_random_uuid(); pd uuid := gen_random_uuid();
  bad jsonb := '[]'::jsonb; report uuid; row_ record; n integer; last_ record;
begin
  insert into auth.users (id, aud, role, email) values
    (a,'authenticated','authenticated','sa@t.test'),(b,'authenticated','authenticated','sb@t.test'),
    (c,'authenticated','authenticated','sc@t.test'),(d,'authenticated','authenticated','sd@t.test'),
    (x,'authenticated','authenticated','sx@t.test');
  insert into public.profiles (id, username, full_name, birthday, signup_step) values
    (a,'zz_sa','Anna A','1990-01-01',0),(b,'zz_sb','Bob B','1990-01-01',0),(c,'zz_sc','Cara C','1990-01-01',0),
    (d,'zz_sd','Dina D','1990-01-01',0),(x,'zz_sx','Xavi X','1990-01-01',0)
    on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
      birthday = excluded.birthday, signup_step = 0;
  insert into public.posts (id, author_id, caption, media_count, visibility) values
    (pa, a, 'a post', 0, 'public'), (pb, b, 'b post', 0, 'public');

  -- t1 who_can_comment
  perform pg_temp.as_user(b);
  update public.profiles set who_can_comment = 'followers' where id = b;
  perform pg_temp.as_user(a);
  bad := bad || pg_temp.chk('t1 followers-only refuses a stranger',
    pg_temp.try(format('select public.add_comment(%L, ''hi'')', pb)), '22023 comments_followers_only');
  insert into public.follows (follower_id, following_id) values (a, b);
  bad := bad || pg_temp.chk('t1 followers-only lets a follower in', pg_temp.try(format('select public.add_comment(%L, ''hi'')', pb)), 'ok');
  perform pg_temp.as_user(b);
  bad := bad || pg_temp.chk('t1 the author always comments', pg_temp.try(format('select public.add_comment(%L, ''mine'')', pb)), 'ok');
  update public.profiles set who_can_comment = 'none' where id = b;
  perform pg_temp.as_user(a);
  bad := bad || pg_temp.chk('t1 none refuses even a follower', pg_temp.try(format('select public.add_comment(%L, ''hi'')', pb)), '22023 comments_off');
  perform pg_temp.as_user(b);
  bad := bad || pg_temp.chk('t1 none still lets the author in', pg_temp.try(format('select public.add_comment(%L, ''mine'')', pb)), 'ok');
  bad := bad || pg_temp.chk('t1 invalid who_can_comment',
    pg_temp.try('update public.profiles set who_can_comment = ''bogus'' where id = ''' || b || ''''), '23514 new row for relation "profiles" violates check constraint "profiles_who_can_comment_valid"');
  bad := bad || pg_temp.chk('t1 invalid who_can_message',
    left(pg_temp.try('update public.profiles set who_can_message = ''bogus'' where id = ''' || b || ''''), 5), '23514');
  bad := bad || pg_temp.chk('t1 is_verified cannot be set by the client',
    left(pg_temp.try('update public.profiles set is_verified = true where id = ''' || b || ''''), 5), '42501');
  update public.profiles set who_can_comment = 'everyone', who_can_message = 'following', show_activity = false where id = b;
  perform pg_temp.as_user(a);
  select * into row_ from public.profile_by_id(b);
  bad := bad || pg_temp.chk('t1 can_message follows who_can_message (a is not followed by b)', row_.can_message, false);
  perform pg_temp.as_user(b);
  update public.profiles set who_can_message = 'everyone', show_activity = true where id = b;

  -- t2 private off keeps requests
  perform pg_temp.as_user(c);
  update public.profiles set is_private = true where id = c;
  perform pg_temp.as_user(a);
  insert into public.follows (follower_id, following_id) values (a, c);
  perform pg_temp.as_user(c);
  update public.profiles set is_private = false where id = c;
  execute 'reset role';
  bad := bad || pg_temp.chk('t2 request still pending after Private off',
    (select status from public.follows where follower_id = a and following_id = c), 'pending');
  delete from public.follows where follower_id = a and following_id = c;

  -- t3 blocks: a follows b (above), b follows a, close friend, mute, subscription, a notification
  insert into public.follows (follower_id, following_id) values (b, a);
  insert into public.close_friends (user_id, friend_id) values (a, b), (b, a);
  insert into public.mutes (user_id, muted_id) values (a, b);
  insert into public.post_subscriptions (user_id, author_id) values (b, a);
  insert into public.follows (follower_id, following_id) values (d, a), (d, b);
  perform public.notify(a, 'like', b, 'g-before', pa);
  bad := bad || pg_temp.chk('t3 a sees b before the block', (select count(*) from (select 1 from public.posts) s) >= 2, true);
  perform pg_temp.as_user(a);
  bad := bad || pg_temp.chk('t3 block yourself', pg_temp.try(format('select public.block_user(%L)', a)), '22023 cannot block yourself');
  bad := bad || pg_temp.chk('t3 block an unknown person', pg_temp.try(format('select public.block_user(%L)', gen_random_uuid())), 'P0002 user_unavailable');
  perform public.block_user(b);
  perform public.block_user(b);
  execute 'reset role';
  bad := bad || pg_temp.chk('t3 follows removed both ways',
    (select count(*) from public.follows where (follower_id = a and following_id = b) or (follower_id = b and following_id = a)), 0::bigint);
  bad := bad || pg_temp.chk('t3 other follows stay', (select count(*) from public.follows where follower_id = d), 2::bigint);
  bad := bad || pg_temp.chk('t3 close friends, mutes, subscriptions removed',
    (select count(*) from public.close_friends where user_id in (a, b)) + (select count(*) from public.mutes where user_id = a)
      + (select count(*) from public.post_subscriptions where user_id = b), 0::bigint);
  bad := bad || pg_temp.chk('t3 their notifications removed', (select count(*) from public.notifications where recipient_id = a and actor_id = b), 0::bigint);
  bad := bad || pg_temp.chk('t3 one block row', (select count(*) from public.blocks where blocker_id = a and blocked_id = b), 1::bigint);

  perform pg_temp.as_user(a);
  select * into row_ from public.profile_by_id(b);
  bad := bad || pg_temp.chk('t3 blocker sees blocked_by_me', row_.blocked_by_me, true);
  bad := bad || pg_temp.chk('t3 blocker cannot message', row_.can_message, false);
  bad := bad || pg_temp.chk('t3 blocker cannot see b posts', (select count(*) from public.posts where id = pb), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocker user_posts of b', (select count(*) from public.user_posts(b, 'posts')), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocker username lookup still finds b', public.profile_id_by_username('zz_sb'), b);
  bad := bad || pg_temp.chk('t3 blocker cannot follow b', left(pg_temp.try(format('insert into public.follows (follower_id, following_id) values (%L, %L)', a, b)), 5), 'P0002');
  bad := bad || pg_temp.chk('t3 blocker cannot comment on b post', pg_temp.try(format('select public.add_comment(%L, ''hi'')', pb)), 'P0002 post_unavailable');
  bad := bad || pg_temp.chk('t3 b absent from suggestions', (select count(*) from public.suggested_profiles('popular', 50) where id = b), 0::bigint);
  bad := bad || pg_temp.chk('t3 d is in suggestions? (d is not followed)', (select count(*) from public.suggested_profiles('popular', 50) where id = d), 1::bigint);

  perform pg_temp.as_user(b);
  bad := bad || pg_temp.chk('t3 blocked gets no profile row', (select count(*) from public.profile_by_id(a)), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocked cannot see a posts', (select count(*) from public.posts where id = pa), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocked user_posts of a', (select count(*) from public.user_posts(a, 'posts')), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocked username lookup finds nobody', public.profile_id_by_username('zz_sa') is null, true);
  bad := bad || pg_temp.chk('t3 blocked cannot follow a', left(pg_temp.try(format('insert into public.follows (follower_id, following_id) values (%L, %L)', b, a)), 5), 'P0002');
  bad := bad || pg_temp.chk('t3 blocked cannot comment on a post', pg_temp.try(format('select public.add_comment(%L, ''hi'')', pa)), 'P0002 post_unavailable');
  bad := bad || pg_temp.chk('t3 a absent from b suggestions', (select count(*) from public.suggested_profiles('popular', 50) where id = a), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocked list of b is empty', (select count(*) from public.blocked_users()), 0::bigint);
  bad := bad || pg_temp.chk('t3 b cannot read the blocks table', (select count(*) from public.blocks), 0::bigint);

  perform pg_temp.as_user(d);
  bad := bad || pg_temp.chk('t3 d followers of a omit nobody wrongly', (select count(*) from public.followers_of(a)), 1::bigint);
  bad := bad || pg_temp.chk('t3 d sees both profiles', (select count(*) from public.profile_by_id(a)) + (select count(*) from public.profile_by_id(b)), 2::bigint);
  execute 'reset role';
  insert into public.follows (follower_id, following_id) values (c, a);
  perform public.notify(a, 'like', b, 'g-after', pa);
  bad := bad || pg_temp.chk('t3 notify skips a blocked pair', (select count(*) from public.notifications where recipient_id = a and actor_id = b), 0::bigint);

  perform pg_temp.as_user(a);
  select * into last_ from public.blocked_users(1);
  bad := bad || pg_temp.chk('t3 blocked_users lists b', last_.id, b);
  bad := bad || pg_temp.chk('t3 blocked_users page 2 empty', (select count(*) from public.blocked_users(5, last_.sort_at, last_.id)), 0::bigint);
  bad := bad || pg_temp.chk('t3 blocks count for the settings row', (select count(*) from public.blocks), 1::bigint);

  perform public.unblock_user(b);
  perform public.unblock_user(b);
  bad := bad || pg_temp.chk('t3 unblock empties the list', (select count(*) from public.blocked_users()), 0::bigint);
  bad := bad || pg_temp.chk('t3 unblock keeps follows removed', (select count(*) from public.follows where follower_id = a and following_id = b), 0::bigint);
  bad := bad || pg_temp.chk('t3 a sees b post again', (select count(*) from public.posts where id = pb), 1::bigint);
  perform pg_temp.as_user(b);
  bad := bad || pg_temp.chk('t3 b gets a profile again', (select count(*) from public.profile_by_id(a)), 1::bigint);

  -- t4 appear_in_search
  perform pg_temp.as_user(d);
  update public.profiles set appear_in_search = false where id = d;
  perform pg_temp.as_user(a);
  bad := bad || pg_temp.chk('t4 hidden from suggestions', (select count(*) from public.suggested_profiles('popular', 50) where id = d), 0::bigint);
  perform pg_temp.as_user(d);
  update public.profiles set appear_in_search = true where id = d;

  -- t5 post notifications
  execute 'reset role';
  delete from public.notifications;
  perform pg_temp.as_user(a);
  insert into public.post_subscriptions (user_id, author_id) values (a, b);
  execute 'reset role';
  insert into public.posts (id, author_id, caption, media_count, visibility) values
    (pb_only, b, 'only me', 0, 'only_me'), (pb_fol, b, 'followers', 0, 'followers');
  bad := bad || pg_temp.chk('t5 no notice for only-me or a followers post a does not follow',
    (select count(*) from public.notifications where recipient_id = a and type = 'new_post'), 0::bigint);
  insert into public.posts (id, author_id, caption, media_count, visibility) values (gen_random_uuid(), b, 'public again', 0, 'public');
  bad := bad || pg_temp.chk('t5 notice for a public post', (select count(*) from public.notifications where recipient_id = a and type = 'new_post'), 1::bigint);
  insert into public.follows (follower_id, following_id) values (a, b);
  insert into public.posts (id, author_id, caption, media_count, visibility) values (gen_random_uuid(), b, 'for followers', 0, 'followers');
  bad := bad || pg_temp.chk('t5 notice for a followers post once following', (select count(*) from public.notifications where recipient_id = a and type = 'new_post'), 2::bigint);
  perform pg_temp.as_user(d);
  perform public.block_user(a);
  bad := bad || pg_temp.chk('t5 subscribing to a blocked author is refused',
    left(pg_temp.try(format('insert into public.post_subscriptions (user_id, author_id) values (%L, %L)', d, a)), 5), '42501');
  perform public.unblock_user(a);

  -- t6 help
  perform pg_temp.as_user(a);
  bad := bad || pg_temp.chk('t6 four topics', (select count(*) from public.help_topics), 4::bigint);
  bad := bad || pg_temp.chk('t6 four common questions', (select count(*) from public.help_articles where is_common), 4::bigint);
  bad := bad || pg_temp.chk('t6 help is read-only', left(pg_temp.try('delete from public.help_topics'), 5), '42501');

  -- t7 problem reports
  bad := bad || pg_temp.chk('t7 valid report', pg_temp.try(format('select public.submit_problem_report(''feed'', ''it broke'', %L::text[], ''{"os":"x"}''::jsonb, ''log'')', array[a || '/1.jpg'])), 'ok');
  bad := bad || pg_temp.chk('t7 bad category', pg_temp.try('select public.submit_problem_report(''nope'', ''it broke'')'), '22023 invalid category');
  bad := bad || pg_temp.chk('t7 blank message', pg_temp.try('select public.submit_problem_report(''feed'', ''   '')'), '22023 invalid message');
  bad := bad || pg_temp.chk('t7 long message', pg_temp.try(format('select public.submit_problem_report(''feed'', %L)', repeat('x', 501))), '22023 invalid message');
  bad := bad || pg_temp.chk('t7 four screenshots', pg_temp.try(format('select public.submit_problem_report(''feed'', ''m'', %L::text[])', array[a||'/1', a||'/2', a||'/3', a||'/4'])), '22023 too many screenshots');
  bad := bad || pg_temp.chk('t7 foreign screenshot', pg_temp.try(format('select public.submit_problem_report(''feed'', ''m'', %L::text[])', array[b||'/1.jpg'])), '22023 invalid screenshot path');
  bad := bad || pg_temp.chk('t7 no direct read', left(pg_temp.try('select * from public.problem_reports'), 5), '42501');
  bad := bad || pg_temp.chk('t7 no direct insert', left(pg_temp.try(format('insert into public.problem_reports (user_id, category, message) values (%L, ''feed'', ''m'')', a)), 5), '42501');
  execute 'reset role';
  bad := bad || pg_temp.chk('t7 one stored report', (select count(*) from public.problem_reports where user_id = a), 1::bigint);

  -- t8 report_user
  perform pg_temp.as_user(a);
  bad := bad || pg_temp.chk('t8 report', pg_temp.try(format('select public.report_user(%L, ''spam'', ''bad'')', b)), 'ok');
  bad := bad || pg_temp.chk('t8 report again', pg_temp.try(format('select public.report_user(%L, ''hate'')', b)), 'ok');
  bad := bad || pg_temp.chk('t8 yourself', pg_temp.try(format('select public.report_user(%L, ''spam'')', a)), '22023 cannot report yourself');
  bad := bad || pg_temp.chk('t8 bad reason', pg_temp.try(format('select public.report_user(%L, ''because'')', b)), '22023 invalid reason');
  bad := bad || pg_temp.chk('t8 unknown person', pg_temp.try(format('select public.report_user(%L, ''spam'')', gen_random_uuid())), 'P0002 user_unavailable');
  execute 'reset role';
  bad := bad || pg_temp.chk('t8 stored once', (select count(*) from public.reports where reporter_id = a and reported_user_id = b), 1::bigint);

  -- t9 delete_my_account
  insert into public.posts (id, author_id, caption, media_count) values (px, x, 'x post', 0);
  insert into public.follows (follower_id, following_id) values (x, d), (d, x);
  insert into storage.objects (bucket_id, name) values ('avatars', x || '/avatar.jpg'), ('avatars', d || '/avatar.jpg');
  perform pg_temp.as_user(x);
  bad := bad || pg_temp.chk('t9 delete', pg_temp.try('select public.delete_my_account()'), 'ok');
  execute 'reset role';
  bad := bad || pg_temp.chk('t9 auth user gone', (select count(*) from auth.users where id = x), 0::bigint);
  bad := bad || pg_temp.chk('t9 profile, posts, follows gone',
    (select count(*) from public.profiles where id = x) + (select count(*) from public.posts where author_id = x)
      + (select count(*) from public.follows where follower_id = x or following_id = x), 0::bigint);
  bad := bad || pg_temp.chk('t9 files gone, others kept',
    (select count(*) from storage.objects where bucket_id = 'avatars' and name like x || '/%') || '|' ||
    (select count(*) from storage.objects where bucket_id = 'avatars' and name like d || '/%'), '0|1');
  bad := bad || pg_temp.chk('t9 other people stay', (select count(*) from public.profiles where id in (a, b, c, d)), 4::bigint);
  bad := bad || pg_temp.chk('t9 anon cannot run it', has_function_privilege('anon', 'public.delete_my_account()', 'execute'), false);
  perform set_config('request.jwt.claims', '{}', true);
  execute 'set local role authenticated';
  bad := bad || pg_temp.chk('t9 no session is refused', left(pg_temp.try('select public.delete_my_account()'), 5), '42501');
  execute 'reset role';

  -- grants
  bad := bad || pg_temp.chk('grants: anon cannot block', has_function_privilege('anon', 'public.block_user(uuid)', 'execute'), false);
  bad := bad || pg_temp.chk('grants: client cannot run is_blocked_pair', has_function_privilege('authenticated', 'public.is_blocked_pair(uuid,uuid)', 'execute'), false);
  bad := bad || pg_temp.chk('grants: client cannot write blocks', has_table_privilege('authenticated', 'public.blocks', 'insert'), false);

  raise exception 'VALIDATION_RESULT %', case when bad = '[]'::jsonb then 'all passed' else bad::text end;
end;
$t$;
