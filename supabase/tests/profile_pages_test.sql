-- Checks for supabase/migrations/20261027223146_profile_pages.sql (profile page, grids, people lists).
-- Run it on a LOCAL database that has the migration (profile_pages_rpc.sh does it and also checks the RPCs
-- through PostgREST). Do not run it on the project: it writes users and posts (it always ends by raising
-- VALIDATION_RESULT, so nothing is kept).
-- Cast: a (the caller), b (public), c (private), d (private, a follows d), e (public, a pending request to c).
-- Expected:
--   t1  profile_by_id: public b -> counts, i_follow 'none'; after a follows b 'accepted'; pending request to c
--       'pending' and not counted in c's followers; follows_me; unknown id and unfinished sign-up -> no row;
--       never exposes phone/birthday (no such column); is_verified false, blocked_by_me false
--   (d also follows c, accepted)
--   t2  user_posts 'posts': public b -> its Public post; private c -> nothing for a non-follower, its post for
--       an accepted follower; Only me / Followers posts hidden from strangers; paging with the last row's key;
--       unknown kind is 22023
--   t3  user_posts 'tagged': a post b is tagged in shows on b; hidden when b is private and the caller does not follow b
--   t4  saved_posts: only the caller's saves, never someone else's
--   t5  followers_of / following_of / mutual_followers: accepted only; private not followed -> no rows;
--       search by name; mutual = people a follows who follow p_user; follow_status per row
--   t6  profile_id_by_username: found with and without '@', unknown is null
--   t7  mutual_followers_preview: names, avatars, total; none for yourself
--   t8  anon cannot run the functions; is_verified cannot be updated by a client, cover_url can
create or replace function pg_temp.as_user(p_user uuid) returns void language plpgsql as $f$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  execute 'reset role';
  execute 'set local role authenticated';
end;
$f$;

do $t$
declare
  a uuid := gen_random_uuid(); b uuid := gen_random_uuid(); c uuid := gen_random_uuid();
  d uuid := gen_random_uuid(); e uuid := gen_random_uuid(); u uuid := gen_random_uuid();
  pb uuid := gen_random_uuid(); pb2 uuid := gen_random_uuid(); pb3 uuid := gen_random_uuid();
  pc uuid := gen_random_uuid(); pt uuid := gen_random_uuid(); pa uuid := gen_random_uuid();
  r jsonb := '{}'::jsonb; row_ record; n integer; last_ record;
begin
  insert into auth.users (id, aud, role, email) values
    (a,'authenticated','authenticated','pa@t.test'),(b,'authenticated','authenticated','pb@t.test'),
    (c,'authenticated','authenticated','pc@t.test'),(d,'authenticated','authenticated','pd@t.test'),
    (e,'authenticated','authenticated','pe@t.test'),(u,'authenticated','authenticated','pu@t.test');
  insert into public.profiles (id, username, full_name, birthday, signup_step) values
    (a,'zz_pa','Anna A','1990-01-01',0),(b,'zz_pb','Bob B','1990-01-01',0),(c,'zz_pc','Cara C','1990-01-01',0),
    (d,'zz_pd','Dina D','1990-01-01',0),(e,'zz_pe','Eli E','1990-01-01',0)
    on conflict (id) do update set username = excluded.username, full_name = excluded.full_name,
      birthday = excluded.birthday, signup_step = 0;
  -- u has not finished signing up
  update public.profiles set phone = '+1234567890' where id = b;

  -- follows: a -> b, a -> d (accepted: d is still public), b -> a, d -> b, e -> b; then c and d go private and
  -- e asks to follow c (the trigger makes it pending)
  insert into public.follows (follower_id, following_id) values (a, b), (a, d), (b, a), (d, b), (e, b);
  update public.profiles set is_private = true where id in (c, d);
  insert into public.follows (follower_id, following_id) values (e, c), (d, c);
  update public.follows set status = 'accepted' where follower_id = d and following_id = c;

  -- posts
  insert into public.posts (id, author_id, caption, media_count, visibility, created_at) values
    (pb,  b, 'b public 1', 1, 'public',    now() - interval '3 minutes'),
    (pb2, b, 'b public 2', 1, 'public',    now() - interval '2 minutes'),
    (pb3, b, 'b only me',  1, 'only_me',   now() - interval '1 minute'),
    (pc,  c, 'c public',   1, 'public',    now()),
    (pt,  e, 'e tags b',   1, 'public',    now()),
    (pa,  a, 'a post',     1, 'public',    now());
  insert into public.post_media (post_id, position, type, path, width, height, blurhash)
    select p, 0, 'image', 'x/' || p::text || '.jpg', 10, 10, 'LEHV6nWB2yk8pyo0adR*.7kCMdnj' from unnest(array[pb,pb2,pb3,pc,pt,pa]) p;
  insert into public.post_tags (post_id, user_id) values (pt, b);
  insert into public.post_saves (user_id, post_id) values (a, pb), (b, pa);

  -- t1 profile_by_id
  perform pg_temp.as_user(a);
  select * into row_ from public.profile_by_id(b);
  r := r || jsonb_build_object('t1_b_username', row_.username, 't1_b_posts', row_.posts_count,
    't1_b_followers', row_.followers_count, 't1_b_following', row_.following_count,
    't1_b_i_follow', row_.i_follow, 't1_b_follows_me', row_.follows_me, 't1_b_verified', row_.is_verified,
    't1_b_blocked', row_.blocked_by_me, 't1_b_can_message', row_.can_message);
  select * into row_ from public.profile_by_id(a);
  r := r || jsonb_build_object('t1_self_posts', row_.posts_count, 't1_self_i_follow', row_.i_follow, 't1_self_can_message', row_.can_message);
  select * into row_ from public.profile_by_id(c);
  r := r || jsonb_build_object('t1_c_private', row_.is_private, 't1_c_followers_ignores_pending', row_.followers_count);
  perform pg_temp.as_user(e);
  select * into row_ from public.profile_by_id(c);
  r := r || jsonb_build_object('t1_e_to_c_pending', row_.i_follow);
  perform pg_temp.as_user(a);
  r := r || jsonb_build_object('t1_unknown_rows', (select count(*) from public.profile_by_id(gen_random_uuid())),
    't1_unfinished_rows', (select count(*) from public.profile_by_id(u)));

  -- t2 user_posts 'posts'
  r := r || jsonb_build_object('t2_b_stranger_view', (select count(*) from public.user_posts(b, 'posts')));
  perform pg_temp.as_user(e);
  r := r || jsonb_build_object('t2_c_pending_sees', (select count(*) from public.user_posts(c, 'posts')));
  perform pg_temp.as_user(d);
  r := r || jsonb_build_object('t2_c_follower_sees', (select count(*) from public.user_posts(c, 'posts')));
  perform pg_temp.as_user(a);
  r := r || jsonb_build_object('t2_c_stranger_sees', (select count(*) from public.user_posts(c, 'posts')));
  perform pg_temp.as_user(b);
  r := r || jsonb_build_object('t2_own_includes_only_me', (select count(*) from public.user_posts(b, 'posts')));
  perform pg_temp.as_user(a);
  select * into last_ from public.user_posts(b, 'posts', 1);
  r := r || jsonb_build_object('t2_page1_caption_post', last_.id = pb2, 't2_page1_media_count', last_.media_count,
    't2_page1_type', last_.first_type, 't2_page1_blurhash', last_.first_blurhash is not null);
  select count(*) into n from public.user_posts(b, 'posts', 5, last_.sort_at, last_.id);
  r := r || jsonb_build_object('t2_page2_rows', n);
  begin
    perform public.user_posts(b, 'shorts');
    r := r || jsonb_build_object('t2_shorts', 'allowed');
  exception when others then r := r || jsonb_build_object('t2_shorts', sqlstate); end;

  -- t3 tagged
  r := r || jsonb_build_object('t3_b_tagged_for_following_caller', (select count(*) from public.user_posts(b, 'tagged')));
  execute 'reset role';
  update public.profiles set is_private = true where id = b;
  perform pg_temp.as_user(c);
  r := r || jsonb_build_object('t3_b_private_stranger_tagged', (select count(*) from public.user_posts(b, 'tagged')));
  perform pg_temp.as_user(a);
  r := r || jsonb_build_object('t3_b_private_follower_tagged', (select count(*) from public.user_posts(b, 'tagged')));
  execute 'reset role';
  update public.profiles set is_private = false where id = b;

  -- t4 saved
  perform pg_temp.as_user(a);
  r := r || jsonb_build_object('t4_a_saved', (select count(*) from public.saved_posts()),
    't4_a_saved_is_pb', (select bool_and(id = pb) from public.saved_posts()));
  perform pg_temp.as_user(b);
  r := r || jsonb_build_object('t4_b_saved_is_pa', (select bool_and(id = pa) from public.saved_posts()));

  -- t5 lists
  perform pg_temp.as_user(a);
  r := r || jsonb_build_object('t5_b_followers', (select count(*) from public.followers_of(b)),
    't5_b_following', (select count(*) from public.following_of(b)),
    't5_b_followers_search_hit', (select count(*) from public.followers_of(b, 'dina')),
    't5_b_followers_search_miss', (select count(*) from public.followers_of(b, 'zzzz')),
    't5_row_follow_status_d', (select follow_status from public.followers_of(b) where id = d),
    't5_row_follow_status_e', (select follow_status from public.followers_of(b) where id = e),
    't5_row_follows_me_d', (select follows_me from public.followers_of(b) where id = d),
    't5_c_stranger_followers', (select count(*) from public.followers_of(c)),
    't5_d_follower_followers', (select count(*) from public.followers_of(d)),
    't5_mutual_b', (select array_agg(id::text order by id) = array[d::text] from public.mutual_followers(b)),
    't5_mutual_self', (select count(*) from public.mutual_followers(a)));
  select * into last_ from public.followers_of(b, null, 1);
  r := r || jsonb_build_object('t5_page2', (select count(*) from public.followers_of(b, null, 5, last_.sort_at, last_.id)));
  perform pg_temp.as_user(e);
  r := r || jsonb_build_object('t5_c_pending_followers_visible', (select count(*) from public.followers_of(c)));

  -- t6 username
  perform pg_temp.as_user(a);
  r := r || jsonb_build_object('t6_plain', public.profile_id_by_username('zz_pb') = b,
    't6_at_upper', public.profile_id_by_username('@ZZ_PB ') = b,
    't6_unknown', public.profile_id_by_username('nobody_here') is null,
    't6_null', public.profile_id_by_username(null) is null);

  -- t7 mutual preview
  select * into row_ from public.mutual_followers_preview(b);
  r := r || jsonb_build_object('t7_total', row_.total, 't7_first', row_.first_username, 't7_second_null', row_.second_username is null,
    't7_avatars', jsonb_array_length(row_.avatars));
  r := r || jsonb_build_object('t7_self_rows', (select count(*) from public.mutual_followers_preview(a)));

  -- t8 grants
  execute 'reset role';
  r := r || jsonb_build_object(
    't8_anon_profile_by_id', has_function_privilege('anon', 'public.profile_by_id(uuid)', 'execute'),
    't8_anon_user_posts', has_function_privilege('anon', 'public.user_posts(uuid,text,integer,timestamptz,uuid)', 'execute'),
    't8_auth_followers_of', has_function_privilege('authenticated', 'public.followers_of(uuid,text,integer,timestamptz,uuid)', 'execute'),
    't8_auth_update_verified', has_column_privilege('authenticated', 'public.profiles', 'is_verified', 'update'),
    't8_auth_update_cover', has_column_privilege('authenticated', 'public.profiles', 'cover_url', 'update'));

  execute 'reset role';
  raise exception 'VALIDATION_RESULT %', r::text;
end;
$t$;
