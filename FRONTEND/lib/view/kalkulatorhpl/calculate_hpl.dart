DateTime calculateHPL(DateTime hpht) {
  final hpl = DateTime(hpht.year, hpht.month, hpht.day + 7);
  final adjustedMonth = hpl.month - 3;
  final adjustedYear = adjustedMonth <= 0 ? hpl.year + 1 : hpl.year;
  final month = adjustedMonth <= 0 ? adjustedMonth + 12 : adjustedMonth;
  return DateTime(adjustedYear, month, hpl.day);
}
