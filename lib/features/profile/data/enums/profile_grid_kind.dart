/// Which posts a person's grid lists; the wire value is `user_posts`' `p_kind`.
enum ProfileGridKind {
  posts('posts'),
  tagged('tagged');

  const ProfileGridKind(this.value);

  final String value;
}
