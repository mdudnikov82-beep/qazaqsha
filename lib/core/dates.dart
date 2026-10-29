/// Russian dates without pulling in intl.
library;

const _monthsShort = [
  'янв', 'фев', 'мар', 'апр', 'май', 'июн', //
  'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
];

const _monthsOf = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', //
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// «окт» — for calendar column labels.
String monthShort(DateTime d) => _monthsShort[d.month - 1];

/// «28 октября 2026».
String dateLong(DateTime d) => '${d.day} ${_monthsOf[d.month - 1]} ${d.year}';

/// «28 октября».
String dayMonth(DateTime d) => '${d.day} ${_monthsOf[d.month - 1]}';

/// «19:05».
String clock(int minutes) =>
    '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';

/// 1 занятие, 2 занятия, 5 занятий.
String plural(int n, String one, String few, String many) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return one;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
  return many;
}
