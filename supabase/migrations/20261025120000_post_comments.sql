-- Comments, replies, comment likes, edit / delete / hide, mentions and reports of a comment.
-- Phase 26 of docs/plans/post-plan.md (specs: docs/specs/post/screens/s14-comments-sheet.md).
-- Depends on: 20261013155541_home_feed (comments, comments_check_parent, post_counters),
--             20261014135126_post_visibility (can_view_post), 20261014135142_shared_content_actions
--             (report_content), 20261014213146_notifications (notify_on_comment, notify_mentions).
-- Spec copy: docs/specs/post/schema-post-comments.sql (keep both in sync).
--
-- Clients no longer touch `comments` directly: every read and write goes through the functions below
-- (hidden comments must stay invisible to everyone but their writer).
--
-- Refusals (the app maps them):
--   P0002 post_unavailable   the post is gone or the caller cannot see it
--   P0002 comment_unavailable the comment is gone, hidden from the caller, or on another post
--   22023 comments_off       the post turned comments off (reading stays allowed)
--   42501                    not signed in, or not allowed (only the writer edits / deletes, only the
--                            post owner hides, never your own comment)

-- ---------------------------------------------------------------------
-- 1. Columns and tables
-- ---------------------------------------------------------------------
alter table public.comments
  add column like_count integer not null default 0,
  add column edited_at  timestamptz,
  add column hidden_at  timestamptz,
  add column client_id  uuid;

-- A retry with the same client id writes once.
create unique index comments_client_idx on public.comments (author_id, client_id)
  where client_id is not null;
-- The replies of a thread, in the order they are read.
create index comments_thread_idx on public.comments (parent_id, created_at, id)
  where parent_id is not null;
-- Top-level comments of a post, newest first (the "Newest" sort and the keyset).
create index comments_top_idx on public.comments (post_id, created_at desc, id desc)
  where parent_id is null;

create table public.comment_likes (
  comment_id uuid not null references public.comments (id) on delete cascade,
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (comment_id, user_id)
);
create index comment_likes_user_idx on public.comment_likes (user_id);

alter table public.comment_likes enable row level security;
revoke all on public.comment_likes from anon, authenticated;
revoke all on public.comments from anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. Counters
-- ---------------------------------------------------------------------
-- posts.comment_count counts the comments people can see: a hidden comment (and the replies hidden
-- with it) does not count, and Undo counts it again.
create or replace function public.post_counters()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_table_name = 'post_likes' then
    if tg_op = 'INSERT' then
      update public.posts set like_count = like_count + 1 where id = new.post_id;
    else
      update public.posts set like_count = greatest(like_count - 1, 0) where id = old.post_id;
    end if;
  elsif tg_table_name = 'comments' then
    if tg_op = 'INSERT' then
      if new.hidden_at is null then
        update public.posts set comment_count = comment_count + 1 where id = new.post_id;
      end if;
    elsif old.hidden_at is null then
      update public.posts set comment_count = greatest(comment_count - 1, 0) where id = old.post_id;
    end if;
  end if;
  return null;
end;
$$;

create or replace function public.comment_hidden_counter()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.hidden_at is null and new.hidden_at is not null then
    update public.posts set comment_count = greatest(comment_count - 1, 0) where id = new.post_id;
  elsif old.hidden_at is not null and new.hidden_at is null then
    update public.posts set comment_count = comment_count + 1 where id = new.post_id;
  end if;
  return null;
end;
$$;
revoke all on function public.comment_hidden_counter() from public, anon, authenticated;

create trigger comments_hidden_count
  after update of hidden_at on public.comments
  for each row execute function public.comment_hidden_counter();

create or replace function public.comment_like_counter()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    update public.comments set like_count = like_count + 1 where id = new.comment_id;
  else
    update public.comments set like_count = greatest(like_count - 1, 0) where id = old.comment_id;
  end if;
  return null;
end;
$$;
revoke all on function public.comment_like_counter() from public, anon, authenticated;

create trigger comment_likes_count
  after insert or delete on public.comment_likes
  for each row execute function public.comment_like_counter();

-- ---------------------------------------------------------------------
-- 3. Helpers (not callable by the app)
-- ---------------------------------------------------------------------
-- The post's author when [p_post] exists and the caller may see it, otherwise raises post_unavailable.
create or replace function public.comments_post_author(p_post uuid)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_author uuid;
begin
  if auth.uid() is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select p.author_id into v_author
    from public.posts p
   where p.id = p_post and public.can_view_post(p.author_id, p.visibility);
  if v_author is null then
    raise exception 'post_unavailable' using errcode = 'P0002';
  end if;
  return v_author;
end;
$$;
revoke all on function public.comments_post_author(uuid) from public, anon, authenticated;

-- One comment as the app reads it. [p_replies] are the replies to send with it; [p_focus] marks the row the
-- app opened from a link.
create or replace function public.comment_json(
  c           public.comments,
  p_post_author uuid,
  p_replies   jsonb default '[]'::jsonb,
  p_is_focus  boolean default false
) returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', c.id,
    'post_id', c.post_id,
    'parent_id', c.parent_id,
    'author_id', c.author_id,
    'username', pr.username,
    'full_name', pr.full_name,
    'avatar_url', pr.avatar_url,
    'body', c.body,
    'created_at', c.created_at,
    'edited_at', c.edited_at,
    'like_count', c.like_count,
    'liked_by_me', exists (select 1 from public.comment_likes l
                            where l.comment_id = c.id and l.user_id = auth.uid()),
    'is_post_author', c.author_id = p_post_author,
    'reply_count', case when c.parent_id is null then
        (select count(*) from public.comments r
          where r.parent_id = c.id and (r.hidden_at is null or r.author_id = auth.uid()))
      else 0 end,
    'replies', p_replies,
    'is_focus', p_is_focus
  )
  from public.profiles pr
  where pr.id = c.author_id;
$$;
revoke all on function public.comment_json(public.comments, uuid, jsonb, boolean) from public, anon, authenticated;

-- The first replies of a thread (oldest first), plus [p_also] when it is a reply further down.
create or replace function public.comment_first_replies(
  p_parent uuid, p_post_author uuid, p_limit integer default 3, p_also uuid default null
) returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(public.comment_json(r, p_post_author) order by r.created_at, r.id), '[]'::jsonb)
    from public.comments r
   where r.parent_id = p_parent
     and (r.hidden_at is null or r.author_id = auth.uid())
     and (r.id = p_also or r.id in (
           select f.id from public.comments f
            where f.parent_id = p_parent and (f.hidden_at is null or f.author_id = auth.uid())
            order by f.created_at, f.id limit p_limit));
$$;
revoke all on function public.comment_first_replies(uuid, uuid, integer, uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 4. Read: post_comments, comment_replies
-- ---------------------------------------------------------------------
-- A page of top-level comments, each with its first 3 replies. p_sort: 'relevant' (default) or 'newest'.
-- Relevant: threads the post's author wrote or answered, and the ones you liked, first; then newest.
-- Keyset: pass the rank, created_at and id of the last row of the page you have (each row carries its
-- `rank`; the focus row is not part of the keyset). p_focus (a comment or a
-- reply of the post) puts that comment, or its thread with the reply, first on the first page and leaves
-- it out of the normal rows; pass it on every page so the thread is never listed twice.
create or replace function public.post_comments(
  p_post          uuid,
  p_sort          text default 'relevant',
  p_limit         integer default 20,
  p_before_rank   integer default null,
  p_before_time   timestamptz default null,
  p_before_id     uuid default null,
  p_focus         uuid default null
) returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_author  uuid := public.comments_post_author(p_post);
  v_limit   integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_top     uuid;
  v_focus   jsonb := null;
  v_rows    jsonb;
  f         public.comments;
  t         public.comments;
begin
  if p_focus is not null then
    select * into f from public.comments c
     where c.id = p_focus and c.post_id = p_post
       and (c.hidden_at is null or c.author_id = v_uid);
    if found then
      select * into t from public.comments c
       where c.id = coalesce(f.parent_id, f.id)
         and (c.hidden_at is null or c.author_id = v_uid);
      if found then
        v_top := t.id;
        if p_before_time is null then
          v_focus := public.comment_json(
            t, v_author,
            public.comment_first_replies(t.id, v_author, 3, case when f.parent_id is null then null else f.id end),
            true);
        end if;
      end if;
    end if;
  end if;

  select coalesce(jsonb_agg(
           public.comment_json(c, v_author, public.comment_first_replies(c.id, v_author))
             || jsonb_build_object('rank', ranked.rank)
           order by ranked.rank desc, c.created_at desc, c.id desc), '[]'::jsonb)
    into v_rows
    from (
      select x.id, x.created_at, x.rank
        from (
          select c.id, c.created_at,
                 case when p_sort = 'newest' then 0 else
                   (case when c.author_id = v_author or exists (
                            select 1 from public.comments r
                             where r.parent_id = c.id and r.author_id = v_author
                               and (r.hidden_at is null or r.author_id = v_uid))
                         then 2 else 0 end)
                   + (case when exists (select 1 from public.comment_likes l
                                         where l.comment_id = c.id and l.user_id = v_uid)
                           then 1 else 0 end)
                 end as rank
            from public.comments c
           where c.post_id = p_post and c.parent_id is null
             and (c.hidden_at is null or c.author_id = v_uid)
             and c.id is distinct from v_top
        ) x
       where p_before_time is null
          or (x.rank, x.created_at, x.id) < (coalesce(p_before_rank, 0), p_before_time, p_before_id)
       order by x.rank desc, x.created_at desc, x.id desc
       limit v_limit
    ) ranked
    join public.comments c on c.id = ranked.id;

  return case when v_focus is null then v_rows else jsonb_build_array(v_focus) || v_rows end;
end;
$$;

-- The replies of one top-level comment after a cursor, oldest first. Pass the created_at and id of the last
-- reply you have.
create or replace function public.comment_replies(
  p_comment     uuid,
  p_limit       integer default 20,
  p_before_time timestamptz default null,
  p_before_id   uuid default null
) returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_limit  integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_post   uuid;
  v_author uuid;
begin
  select c.post_id into v_post from public.comments c
   where c.id = p_comment and c.parent_id is null and (c.hidden_at is null or c.author_id = v_uid);
  if v_post is null then
    raise exception 'comment_unavailable' using errcode = 'P0002';
  end if;
  v_author := public.comments_post_author(v_post);

  return coalesce((
    select jsonb_agg(public.comment_json(r, v_author) order by r.created_at, r.id)
      from public.comments r
     where r.id in (
       select x.id from public.comments x
        where x.parent_id = p_comment
          and (x.hidden_at is null or x.author_id = v_uid)
          and (p_before_time is null or (x.created_at, x.id) > (p_before_time, p_before_id))
        order by x.created_at, x.id
        limit v_limit)
  ), '[]'::jsonb);
end;
$$;

-- ---------------------------------------------------------------------
-- 5. Write: add, edit, delete, hide, like
-- ---------------------------------------------------------------------
-- Adds a comment (or a reply). A reply to a reply goes to the top-level comment. p_client_id makes a retry
-- safe: the same id writes once and answers with the comment already written. Returns the comment.
create or replace function public.add_comment(
  p_post      uuid,
  p_body      text,
  p_parent    uuid default null,
  p_client_id uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_author  uuid := public.comments_post_author(p_post);
  v_body    text := btrim(coalesce(p_body, ''));
  v_parent  uuid := null;
  v_id      uuid;
  c         public.comments;
begin
  if not (select p.comments_enabled from public.posts p where p.id = p_post) then
    raise exception 'comments_off' using errcode = '22023';
  end if;
  if char_length(v_body) not between 1 and 1000 then
    raise exception 'invalid body' using errcode = '22023';
  end if;

  if p_parent is not null then
    select coalesce(pc.parent_id, pc.id) into v_parent
      from public.comments pc
     where pc.id = p_parent and pc.post_id = p_post
       and (pc.hidden_at is null or pc.author_id = v_uid);
    if v_parent is null then
      raise exception 'comment_unavailable' using errcode = 'P0002';
    end if;
  end if;

  insert into public.comments (post_id, author_id, parent_id, body, client_id)
  values (p_post, v_uid, v_parent, v_body, p_client_id)
  on conflict (author_id, client_id) where client_id is not null do nothing
  returning id into v_id;

  if v_id is null then
    select id into v_id from public.comments where author_id = v_uid and client_id = p_client_id;
  end if;

  select * into c from public.comments where id = v_id;
  return public.comment_json(c, v_author);
end;
$$;

-- Changes the words of your own comment and marks it edited (the same words change nothing).
create or replace function public.edit_comment(p_comment uuid, p_body text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_body   text := btrim(coalesce(p_body, ''));
  v_author uuid;
  c        public.comments;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select * into c from public.comments where id = p_comment;
  if not found then
    raise exception 'comment_unavailable' using errcode = 'P0002';
  end if;
  if c.author_id <> v_uid then
    raise exception 'only the writer edits' using errcode = '42501';
  end if;
  v_author := public.comments_post_author(c.post_id);
  if char_length(v_body) not between 1 and 1000 then
    raise exception 'invalid body' using errcode = '22023';
  end if;
  if v_body <> c.body then
    update public.comments set body = v_body, edited_at = now() where id = p_comment returning * into c;
  end if;
  return public.comment_json(c, v_author);
end;
$$;

-- Deletes your own comment; its replies go with it.
create or replace function public.delete_comment(p_comment uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  delete from public.comments where id = p_comment and author_id = v_uid;
  if not found then
    if exists (select 1 from public.comments where id = p_comment) then
      raise exception 'only the writer deletes' using errcode = '42501';
    end if;
  end if;
end;
$$;

-- The post owner hides (or brings back) someone else's comment. A hidden comment is gone for everyone
-- except its writer; hiding a top-level comment hides its replies with it, and Undo brings back exactly
-- those.
create or replace function public.hide_comment(p_comment uuid, p_hidden boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_stamp timestamptz;
  c       public.comments;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select * into c from public.comments where id = p_comment;
  if not found then
    raise exception 'comment_unavailable' using errcode = 'P0002';
  end if;
  if not exists (select 1 from public.posts p where p.id = c.post_id and p.author_id = v_uid) then
    raise exception 'only the post owner hides' using errcode = '42501';
  end if;
  if c.author_id = v_uid then
    raise exception 'cannot hide your own comment' using errcode = '42501';
  end if;

  if p_hidden then
    update public.comments set hidden_at = now()
     where (id = p_comment or parent_id = p_comment) and hidden_at is null;
  else
    v_stamp := c.hidden_at;
    if v_stamp is not null then
      update public.comments set hidden_at = null
       where (id = p_comment or parent_id = p_comment) and hidden_at = v_stamp;
    end if;
  end if;
end;
$$;

-- Likes or unlikes a comment (twice does nothing). Returns the like count afterwards.
create or replace function public.set_comment_like(p_comment uuid, p_liked boolean)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_count integer;
  c       public.comments;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select * into c from public.comments
   where id = p_comment and (hidden_at is null or author_id = v_uid);
  if not found then
    raise exception 'comment_unavailable' using errcode = 'P0002';
  end if;
  perform public.comments_post_author(c.post_id);

  if p_liked then
    insert into public.comment_likes (comment_id, user_id) values (p_comment, v_uid)
    on conflict do nothing;
  else
    delete from public.comment_likes where comment_id = p_comment and user_id = v_uid;
  end if;
  select like_count into v_count from public.comments where id = p_comment;
  return v_count;
end;
$$;

-- ---------------------------------------------------------------------
-- 6. Mentions: up to p_limit people to suggest while typing @name
-- ---------------------------------------------------------------------
-- People already in this thread first, then your accepted followers, whose username starts with p_query
-- (blank = anyone). Only people who can see the post's author, like the mention notification.
create or replace function public.comment_mention_candidates(
  p_post uuid, p_query text default null, p_limit integer default 3
) returns table (id uuid, username text, full_name text, avatar_url text)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid    uuid := auth.uid();
  v_author uuid := public.comments_post_author(p_post);
  v_q      text := lower(coalesce(btrim(p_query), ''));
  v_limit  integer := least(greatest(coalesce(p_limit, 3), 1), 10);
begin
  return query
    select pr.id, pr.username::text, pr.full_name, pr.avatar_url
      from (
        select u.id, min(u.source) as source
          from (
            select v_author, 0
            union all
            select c.author_id, 0 from public.comments c
             where c.post_id = p_post and (c.hidden_at is null or c.author_id = v_uid)
            union all
            select f.follower_id, 1 from public.follows f
             where f.following_id = v_uid and f.status = 'accepted'
          ) u
         group by u.id
      ) cand
      join public.profiles pr on pr.id = cand.id
     where pr.id <> v_uid
       and pr.username is not null
       and starts_with(lower(pr.username::text), v_q)
       and public.can_user_view_author(pr.id, v_author)
     order by cand.source, pr.username
     limit v_limit;
end;
$$;

-- ---------------------------------------------------------------------
-- 7. Reports: a comment can be reported like a post
-- ---------------------------------------------------------------------
alter table public.reports
  add column comment_id uuid references public.comments (id) on delete cascade;
alter table public.reports drop constraint reports_one_target;
alter table public.reports
  add constraint reports_one_target check (num_nonnulls(post_id, story_id, comment_id) = 1);
alter table public.reports
  add constraint reports_one_per_user_comment unique (reporter_id, comment_id);

create or replace function public.report_content(
  p_kind   text,
  p_id     uuid,
  p_reason text,
  p_note   text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := auth.uid();
  v_note text := nullif(btrim(p_note), '');
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_kind not in ('post', 'short', 'story', 'comment') then
    raise exception 'invalid kind' using errcode = '22023';
  end if;

  if p_kind = 'story' then
    if not exists (select 1 from public.stories s
                   where s.id = p_id and s.expires_at > now()
                     and public.can_view_story(s.author_id, s.audience)) then
      raise exception 'story not found' using errcode = '22023';
    end if;
    insert into public.reports (reporter_id, story_id, reason, note)
    values (v_uid, p_id, p_reason, v_note)
    on conflict (reporter_id, story_id) do nothing;
  elsif p_kind = 'comment' then
    if not exists (select 1 from public.comments c
                    join public.posts p on p.id = c.post_id
                   where c.id = p_id and c.author_id <> v_uid
                     and c.hidden_at is null
                     and public.can_view_post(p.author_id, p.visibility)) then
      raise exception 'comment not found' using errcode = '22023';
    end if;
    insert into public.reports (reporter_id, comment_id, reason, note)
    values (v_uid, p_id, p_reason, v_note)
    on conflict (reporter_id, comment_id) do nothing;
  else
    if not exists (select 1 from public.posts p
                   where p.id = p_id and p.kind = p_kind
                     and public.can_view_post(p.author_id, p.visibility)) then
      raise exception 'post not found' using errcode = '22023';
    end if;
    insert into public.reports (reporter_id, post_id, reason, note)
    values (v_uid, p_id, p_reason, v_note)
    on conflict (reporter_id, post_id) do nothing;
    insert into public.post_hides (user_id, post_id) values (v_uid, p_id)
    on conflict do nothing;
  end if;
end;
$$;

-- ---------------------------------------------------------------------
-- 8. Grants
-- ---------------------------------------------------------------------
revoke all on function public.post_comments(uuid, text, integer, integer, timestamptz, uuid, uuid) from public, anon;
revoke all on function public.comment_replies(uuid, integer, timestamptz, uuid) from public, anon;
revoke all on function public.add_comment(uuid, text, uuid, uuid) from public, anon;
revoke all on function public.edit_comment(uuid, text) from public, anon;
revoke all on function public.delete_comment(uuid) from public, anon;
revoke all on function public.hide_comment(uuid, boolean) from public, anon;
revoke all on function public.set_comment_like(uuid, boolean) from public, anon;
revoke all on function public.comment_mention_candidates(uuid, text, integer) from public, anon;
grant execute on function public.post_comments(uuid, text, integer, integer, timestamptz, uuid, uuid) to authenticated;
grant execute on function public.comment_replies(uuid, integer, timestamptz, uuid) to authenticated;
grant execute on function public.add_comment(uuid, text, uuid, uuid) to authenticated;
grant execute on function public.edit_comment(uuid, text) to authenticated;
grant execute on function public.delete_comment(uuid) to authenticated;
grant execute on function public.hide_comment(uuid, boolean) to authenticated;
grant execute on function public.set_comment_like(uuid, boolean) to authenticated;
grant execute on function public.comment_mention_candidates(uuid, text, integer) to authenticated;
