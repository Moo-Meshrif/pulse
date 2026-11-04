-- Include profile ids in comment responses so mention taps need no lookup.
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
    'mention_ids', coalesce((
      select jsonb_object_agg(m.username, target.id)
      from (
        select distinct lower(matches.parts[2]) as username
        from regexp_matches(
          c.body,
          '(^|[^[:alnum:]_@])@([A-Za-z0-9_]+([A-Za-z0-9_.]*[A-Za-z0-9_])?)',
          'g'
        ) as matches(parts)
      ) m
      join public.profiles target on target.username = m.username::extensions.citext
      where target.signup_step = 0
        and not exists (
          select 1 from public.blocks b
          where b.blocker_id = target.id and b.blocked_id = auth.uid()
        )
    ), '{}'::jsonb),
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
