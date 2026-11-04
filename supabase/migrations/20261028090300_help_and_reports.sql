-- =====================================================================
-- Migration: supabase/migrations/20261028090300_help_and_reports.sql
-- Plan: docs/plans/profile-plan.md (Phase 2), specs s9-help-center.md, s10-report-problem.md, s12-other-profile.md
-- Adds: help_topics, help_articles (read-only for the app, seeded with the four topics and four questions of S9)
--       problem_reports + the private `problem-reports` bucket + submit_problem_report(...)
--       reports.reported_user_id + report_user(...)  (a profile can be reported)
-- The Arabic seed text is a draft until the user approves it.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Help content
-- ---------------------------------------------------------------------
create table public.help_topics (
  id       smallint generated always as identity primary key,
  slug     text not null unique,
  icon     text not null,
  title_en text not null,
  title_ar text not null,
  position smallint not null
);
create table public.help_articles (
  id          smallint generated always as identity primary key,
  topic_id    smallint not null references public.help_topics (id) on delete cascade,
  question_en text not null,
  question_ar text not null,
  answer_en   text not null,
  answer_ar   text not null,
  position    smallint not null,
  is_common   boolean not null default false
);
create index help_articles_topic_idx on public.help_articles (topic_id, position);

revoke all on public.help_topics, public.help_articles from anon, authenticated;
grant select on public.help_topics, public.help_articles to authenticated;
alter table public.help_topics   enable row level security;
alter table public.help_articles enable row level security;
create policy "help_topics: read" on public.help_topics for select to authenticated using (true);
create policy "help_articles: read" on public.help_articles for select to authenticated using (true);

insert into public.help_topics (slug, icon, title_en, title_ar, position) values
  ('account',  'ic_user',        'Account & profile', 'الحساب والملف الشخصي', 1),
  ('privacy',  'ic_lock',        'Privacy & safety',  'الخصوصية والأمان',      2),
  ('posts',    'ic_play',        'Posts & shorts',    'المنشورات والشورتس',    3),
  ('messages', 'ic_chat_bubble', 'Messages',          'الرسائل',               4);

insert into public.help_articles (topic_id, question_en, question_ar, answer_en, answer_ar, position, is_common)
select t.id, a.question_en, a.question_ar, a.answer_en, a.answer_ar, a.position, true
  from (values
    ('account', 'How do I change my username?', 'كيف أغير اسم المستخدم؟',
     'Go to Settings, then Personal info, and edit the Username field. A green check means the name is free.',
     'اذهب إلى الإعدادات، ثم المعلومات الشخصية، وعدّل حقل اسم المستخدم. العلامة الخضراء تعني أن الاسم متاح.', 1),
    ('privacy', 'How do I make my account private?', 'كيف أجعل حسابي خاصًا؟',
     'Go to Settings, then Privacy, and turn on Private account. New followers then need your approval, and people who do not follow you cannot see your posts, shorts or stories.',
     'اذهب إلى الإعدادات، ثم الخصوصية، وفعّل الحساب الخاص. سيحتاج المتابعون الجدد إلى موافقتك، ولن يتمكن من لا يتابعك من رؤية منشوراتك أو شورتسك أو قصصك.', 2),
    ('posts', 'Why can''t I upload a short?', 'لماذا لا يمكنني رفع شورت؟',
     'Shorts are not available yet. You will be able to post one as soon as they launch.',
     'الشورتس غير متاح بعد. ستتمكن من نشر شورت فور إطلاقه.', 3),
    ('account', 'How do I recover a hacked account?', 'كيف أستعيد حسابًا تم اختراقه؟',
     'On the Sign in page tap Forgot password and reset it by email. Then open Settings, Password & security, and choose Log out of all other devices. If you cannot get back in, use Report a problem in the Help center.',
     'في صفحة تسجيل الدخول اضغط على نسيت كلمة المرور وأعد تعيينها عبر البريد الإلكتروني. ثم افتح الإعدادات، كلمة المرور والأمان، واختر تسجيل الخروج من جميع الأجهزة الأخرى. إذا لم تستطع الدخول، استخدم الإبلاغ عن مشكلة في مركز المساعدة.', 4)
  ) as a(slug, question_en, question_ar, answer_en, answer_ar, position)
  join public.help_topics t on t.slug = a.slug;

-- ---------------------------------------------------------------------
-- 2. Problem reports: written only through submit_problem_report, read only by the team
-- ---------------------------------------------------------------------
create table public.problem_reports (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references public.profiles (id) on delete cascade,
  category          text not null,
  message           text not null,
  screenshot_paths  text[] not null default '{}',
  device_info       jsonb,
  logs              text,
  created_at        timestamptz not null default now(),
  constraint problem_reports_category check (category in ('feed', 'shorts', 'chat', 'profile', 'signing_in', 'other')),
  constraint problem_reports_message_len check (char_length(message) between 1 and 500),
  constraint problem_reports_screenshots check (cardinality(screenshot_paths) <= 3),
  constraint problem_reports_logs_len check (logs is null or char_length(logs) <= 20000)
);
create index problem_reports_user_idx on public.problem_reports (user_id, created_at desc);

revoke all on public.problem_reports from anon, authenticated;
alter table public.problem_reports enable row level security;

-- Screenshots: private bucket. The owner can add and remove files in their own folder; nobody reads them in the app.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('problem-reports', 'problem-reports', false, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

drop policy if exists "problem-reports: owner insert" on storage.objects;
create policy "problem-reports: owner insert"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'problem-reports' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "problem-reports: owner delete" on storage.objects;
create policy "problem-reports: owner delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'problem-reports' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- Errors (22023): invalid category, message length, too many screenshots, a screenshot outside the caller's folder.
create or replace function public.submit_problem_report(
  p_category         text,
  p_message          text,
  p_screenshot_paths text[] default '{}',
  p_device_info      jsonb default null,
  p_logs             text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid     uuid := auth.uid();
  v_message text := btrim(coalesce(p_message, ''));
  v_paths   text[] := coalesce(p_screenshot_paths, '{}');
  v_path    text;
  v_id      uuid;
begin
  if v_uid is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if p_category is null or p_category not in ('feed', 'shorts', 'chat', 'profile', 'signing_in', 'other') then
    raise exception 'invalid category' using errcode = '22023';
  end if;
  if char_length(v_message) not between 1 and 500 then
    raise exception 'invalid message' using errcode = '22023';
  end if;
  if cardinality(v_paths) > 3 then
    raise exception 'too many screenshots' using errcode = '22023';
  end if;
  foreach v_path in array v_paths loop
    if v_path is null or left(v_path, char_length(v_uid::text) + 1) <> v_uid::text || '/' then
      raise exception 'invalid screenshot path' using errcode = '22023';
    end if;
  end loop;
  if p_device_info is not null and jsonb_typeof(p_device_info) <> 'object' then
    raise exception 'invalid device info' using errcode = '22023';
  end if;

  insert into public.problem_reports (user_id, category, message, screenshot_paths, device_info, logs)
  values (v_uid, p_category, v_message, v_paths, p_device_info, left(p_logs, 20000))
  returning id into v_id;
  return v_id;
end;
$$;
revoke all on function public.submit_problem_report(text, text, text[], jsonb, text) from public, anon;
grant execute on function public.submit_problem_report(text, text, text[], jsonb, text) to authenticated;

-- ---------------------------------------------------------------------
-- 3. Reporting a profile: a row of `reports` about a person
-- ---------------------------------------------------------------------
alter table public.reports
  add column reported_user_id uuid references public.profiles (id) on delete cascade;
alter table public.reports drop constraint reports_one_target;
alter table public.reports
  add constraint reports_one_target check (num_nonnulls(post_id, story_id, comment_id, reported_user_id) = 1);
alter table public.reports
  add constraint reports_one_per_user_profile unique (reporter_id, reported_user_id);

-- Errors: 22023 (reason, yourself), P0002 (no such person, or they blocked the caller). Reporting twice is a no-op.
create or replace function public.report_user(p_user uuid, p_reason text, p_note text default null)
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
  if p_user is null or p_user = v_uid then
    raise exception 'cannot report yourself' using errcode = '22023';
  end if;
  if p_reason is null or p_reason not in ('spam', 'nudity', 'hate', 'bullying', 'violence', 'false_info', 'other') then
    raise exception 'invalid reason' using errcode = '22023';
  end if;
  if not exists (select 1 from public.profiles pr where pr.id = p_user and pr.signup_step = 0) then
    raise exception 'user_unavailable' using errcode = 'P0002';
  end if;
  insert into public.reports (reporter_id, reported_user_id, reason, note)
  values (v_uid, p_user, p_reason, v_note)
  on conflict (reporter_id, reported_user_id) do nothing;
end;
$$;
revoke all on function public.report_user(uuid, text, text) from public, anon;
grant execute on function public.report_user(uuid, text, text) to authenticated;
