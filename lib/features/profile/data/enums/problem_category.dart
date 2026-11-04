enum ProblemCategory {
  feed,
  shorts,
  chat,
  profile,
  signingIn,
  other;

  String get wire => this == signingIn ? 'signing_in' : name;
}
