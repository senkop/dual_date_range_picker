import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

/// A month in a specific calendar system (Gregorian or Hijri).
@immutable
class CalendarMonth {
  /// Creates a month. [month] is 1-based.
  const CalendarMonth(this.year, this.month)
      : assert(month >= 1 && month <= 12);

  /// The year in this calendar.
  final int year;

  /// The month in this calendar, from 1 to 12.
  final int month;

  /// Returns the month [months] months after this one (negative goes back).
  CalendarMonth operator +(int months) {
    final index = year * 12 + (month - 1) + months;
    return CalendarMonth(index ~/ 12, index % 12 + 1);
  }

  /// Negative if this month is before [other], zero if equal, positive after.
  int compareTo(CalendarMonth other) =>
      (year * 12 + month) - (other.year * 12 + other.month);

  @override
  bool operator ==(Object other) =>
      other is CalendarMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'CalendarMonth($year, $month)';
}

/// The calendars the picker can show.
enum CalendarKind {
  /// The Gregorian calendar.
  gregorian,

  /// The Hijri (Umm al-Qura) calendar.
  hijri,
}

/// Converts between real dates and the months/days of a calendar.
abstract class CalendarSystem {
  /// Base constructor for subclasses.
  const CalendarSystem();

  /// The Gregorian calendar.
  static const CalendarSystem gregorian = GregorianCalendarSystem();

  /// The Hijri (Umm al-Qura) calendar.
  static const CalendarSystem hijri = HijriCalendarSystem();

  /// Returns the system for [kind].
  static CalendarSystem of(CalendarKind kind) =>
      kind == CalendarKind.hijri ? hijri : gregorian;

  /// The month that contains [date].
  CalendarMonth monthOf(DateTime date);

  /// The day of the month of [date] in this calendar (1-based).
  int dayOf(DateTime date);

  /// The Gregorian date (at midnight) of the first day of [month].
  DateTime firstDayOf(CalendarMonth month);

  /// The number of days in [month].
  int daysIn(CalendarMonth month);
}

/// The Gregorian calendar.
class GregorianCalendarSystem extends CalendarSystem {
  /// Creates the Gregorian calendar.
  const GregorianCalendarSystem();

  @override
  CalendarMonth monthOf(DateTime date) => CalendarMonth(date.year, date.month);

  @override
  int dayOf(DateTime date) => date.day;

  @override
  DateTime firstDayOf(CalendarMonth month) => DateTime(month.year, month.month);

  @override
  int daysIn(CalendarMonth month) =>
      DateTime(month.year, month.month + 1, 0).day;
}

/// The Hijri calendar, using the Umm al-Qura tables from the `hijri` package.
///
/// Supported range is roughly 1356–1500 AH (1937–2077).
class HijriCalendarSystem extends CalendarSystem {
  /// Creates the Hijri calendar.
  const HijriCalendarSystem();

  @override
  CalendarMonth monthOf(DateTime date) {
    final h = HijriCalendar.fromDate(date);
    return CalendarMonth(h.hYear, h.hMonth);
  }

  @override
  int dayOf(DateTime date) => HijriCalendar.fromDate(date).hDay;

  @override
  DateTime firstDayOf(CalendarMonth month) {
    final g = HijriCalendar().hijriToGregorian(month.year, month.month, 1);
    return DateTime(g.year, g.month, g.day);
  }

  @override
  int daysIn(CalendarMonth month) =>
      HijriCalendar().getDaysInMonth(month.year, month.month);
}
