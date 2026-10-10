/// The tabs of the Follow step that the backend serves (the "From contacts" tab is not served yet).
enum SuggestionTab {
  suggested(value: 'suggested'),
  popular(value: 'popular');

  const SuggestionTab({required this.value});

  /// The `p_tab` argument of the `suggested_profiles` function.
  final String value;
}
