insert into public.legal_documents (type, locale, title, html) values
  ('terms', 'en', 'Terms', '<p>Coming soon.</p>'),
  ('privacy', 'en', 'Privacy Policy', '<p>Coming soon.</p>'),
  ('community', 'en', 'Community Guidelines', '<p>Coming soon.</p>'),
  ('cookies', 'en', 'Cookie Policy', '<p>Coming soon.</p>'),
  ('licenses', 'en', 'Open-source Licenses', '<p>Coming soon.</p>'),
  ('terms', 'ar', 'الشروط', '<p>قريباً.</p>'),
  ('privacy', 'ar', 'سياسة الخصوصية', '<p>قريباً.</p>'),
  ('community', 'ar', 'إرشادات المجتمع', '<p>قريباً.</p>'),
  ('cookies', 'ar', 'سياسة ملفات تعريف الارتباط', '<p>قريباً.</p>'),
  ('licenses', 'ar', 'تراخيص المصادر المفتوحة', '<p>قريباً.</p>')
on conflict (type, locale) do nothing;
