import 'package:dual_date_range_picker/dual_date_range_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarMonth', () {
    test('adds months across year boundaries', () {
      expect(const CalendarMonth(2026, 12) + 1, const CalendarMonth(2027, 1));
      expect(const CalendarMonth(2026, 1) + -1, const CalendarMonth(2025, 12));
      expect(const CalendarMonth(2026, 5) + 14, const CalendarMonth(2027, 7));
    });

    test('compares months', () {
      expect(
        const CalendarMonth(2026, 3).compareTo(const CalendarMonth(2026, 4)),
        isNegative,
      );
      expect(
        const CalendarMonth(2027, 1).compareTo(const CalendarMonth(2026, 12)),
        isPositive,
      );
    });
  });

  group('Gregorian', () {
    const g = CalendarSystem.gregorian;

    test('knows month lengths, including leap years', () {
      expect(g.daysIn(const CalendarMonth(2024, 2)), 29);
      expect(g.daysIn(const CalendarMonth(2026, 2)), 28);
      expect(g.daysIn(const CalendarMonth(2026, 11)), 30);
    });

    test('finds the month and day of a date', () {
      final d = DateTime(2026, 11, 19, 15, 30);
      expect(g.monthOf(d), const CalendarMonth(2026, 11));
      expect(g.dayOf(d), 19);
      expect(g.firstDayOf(const CalendarMonth(2026, 11)), DateTime(2026, 11));
    });
  });

  group('Hijri', () {
    const h = CalendarSystem.hijri;

    test('converts a known date', () {
      // 19 November 2026 is 9 Jumada Al-Thani 1448 (Umm al-Qura).
      final d = DateTime(2026, 11, 19);
      expect(h.monthOf(d), const CalendarMonth(1448, 6));
      expect(h.dayOf(d), 9);
    });

    test('first day of each month round-trips', () {
      var month = const CalendarMonth(1447, 1);
      for (var i = 0; i < 24; i++) {
        final first = h.firstDayOf(month);
        expect(h.monthOf(first), month);
        expect(h.dayOf(first), 1);
        expect(h.daysIn(month), anyOf(29, 30));
        month = month + 1;
      }
    });
  });

  group('DateRangePreset', () {
    final now = DateTime(2026, 11, 19, 10);

    test('last 7 days covers today and the 6 days before it', () {
      final r = DateRangePreset.days(now, 6, 0);
      expect(r.start, DateTime(2026, 11, 13));
      expect(r.end, DateTime(2026, 11, 19, 23, 59));
    });

    test('defaults use the given labels', () {
      final presets = DateRangePreset.defaults(DualPickerLabels.arabic);
      expect(presets.map((p) => p.label), contains('أمس'));
      expect(presets[1].resolve(now).start, DateTime(2026, 11, 18));
    });
  });
}
