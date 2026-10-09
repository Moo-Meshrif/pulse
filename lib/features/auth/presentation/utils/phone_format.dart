/// Whether [phone] holds 7 to 15 digits (spaces and a leading "+" allowed). Empty is not valid; callers
/// treat an empty phone as "not given".
bool isValidPhone(String phone) {
  if (!_pattern.hasMatch(phone)) return false;
  final digits = phone.replaceAll(RegExp(r'\D'), '').length;
  return digits >= minDigits && digits <= maxDigits;
}

const minDigits = 7;
const maxDigits = 15;

final _pattern = RegExp(r'^\+?[\d\s]+$');
