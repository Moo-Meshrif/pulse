/// The youngest age sign-up accepts.
const minAge = 18;

/// "DD / MM / YYYY", as the Birthday field shows a picked date.
String formatBirthday(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} / '
    '${date.month.toString().padLeft(2, '0')} / '
    '${date.year.toString().padLeft(4, '0')}';

/// Whether someone born on [birthday] is at least [minAge] on [today].
bool isOldEnough(DateTime birthday, DateTime today) {
  var age = today.year - birthday.year;
  final hadBirthday =
      today.month > birthday.month ||
      (today.month == birthday.month && today.day >= birthday.day);
  if (!hadBirthday) age--;
  return age >= minAge;
}
