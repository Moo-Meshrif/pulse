-- =====================================================================
-- Migration: supabase/migrations/20261028090100_post_subscriptions.sql
-- Plan: docs/plans/profile-plan.md (Phase 2), spec docs/specs/profile/screens/s12-other-profile.md (Following sheet)
-- Adds: post_subscriptions (the "Post notifications" switch on someone's profile)
--       notifications.type 'new_post', and a trigger that tells subscribers when the author posts
-- The Activity screen shows 'new_post' rows later; nothing in the app reads this type yet.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. post_subscriptions: owner-only, written straight by the client
-- ---------------------------------------------------------------------
create table public.post_subscriptions (
  user_id    uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  author_id  uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, author_id),
  constraint post_subscriptions_not_self check (user_id <> author_id)
);
create index post_subscriptions_author_idx on public.post_subscriptions (author_id);

revoke all on public.post_subscriptions from anon, authenticated;
grant select, insert, delete on public.post_subscriptions to authenticated;
alter table public.post_subscriptions enable row level security;

create policy "post_subscriptions: read own" on public.post_subscriptions
  for select to authenticated using (user_id = (select auth.uid()));
create policy "post_subscriptions: insert own" on public.post_subscriptions
  for insert to authenticated
  with check (user_id = (select auth.uid()) and public.can_view_author(author_id));
create policy "post_subscriptions: delete own" on public.post_subscriptions
  for delete to authenticated using (user_id = (select auth.uid()));

-- ---------------------------------------------------------------------
-- 2. The notification: one row per post and subscriber, only for people who may see that post
-- ---------------------------------------------------------------------
alter table public.notifications drop constraint notifications_type;
alter table public.notifications add constraint notifications_type check (type in (
  'follow', 'follow_request', 'follow_accepted',
  'like', 'comment', 'reply', 'mention', 'tag', 'share', 'new_post'
));

create or replace function public.notify_subscribers_on_post()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  s  record;
  ok boolean;
begin
  if new.visibility = 'only_me' then
    return null;
  end if;
  for s in
    select ps.user_id
      from public.post_subscriptions ps
     where ps.author_id = new.author_id
  loop
    ok := case new.visibility
         when 'public' then public.can_user_view_author(s.user_id, new.author_id)
         when 'followers' then exists (select 1 from public.follows f
                                        where f.follower_id = s.user_id and f.following_id = new.author_id
                                          and f.status = 'accepted')
         when 'close_friends' then exists (select 1 from public.follows f
                                            where f.follower_id = s.user_id and f.following_id = new.author_id
                                              and f.status = 'accepted')
                                   and exists (select 1 from public.close_friends c
                                                where c.user_id = new.author_id and c.friend_id = s.user_id)
         else false
       end;
    if ok then
      perform public.notify(s.user_id, 'new_post', new.author_id, 'new_post:' || new.id, new.id);
    end if;
  end loop;
  return null;
end;
$$;
revoke all on function public.notify_subscribers_on_post() from public, anon, authenticated;

create trigger posts_notify_subscribers
  after insert on public.posts
  for each row execute function public.notify_subscribers_on_post();
