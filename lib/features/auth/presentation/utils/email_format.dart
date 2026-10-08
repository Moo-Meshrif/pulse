/// Whether [email] looks like an address: something before the "@", a dot-separated domain after it, no
/// spaces. A format check only; the server decides whether the address exists.
bool isValidEmail(String email) => _pattern.hasMatch(email.trim());

final _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@.]+$');
