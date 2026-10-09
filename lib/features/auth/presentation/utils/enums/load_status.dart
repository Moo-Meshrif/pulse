/// Where a list that is fetched for a step is.
enum LoadStatus {
  idle,
  loading,
  loaded,
  failed;

  bool get isLoading => this == loading;
  bool get isFailed => this == failed;
}
