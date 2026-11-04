/// Whether [username] is 3 to 30 letters, digits, dots or underscores. A format check only; the server
/// decides whether it is free.
bool isValidUsername(String username) => _pattern.hasMatch(username);

final _pattern = RegExp(r'^[A-Za-z0-9._]{3,30}$');
