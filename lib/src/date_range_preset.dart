import 'package:flutter/material.dart';

import 'picker_labels.dart';

/// A quick-pick range shown on the side of the picker, like "Last 7 Days".
@immutable
class DateRangePreset {
  /// Creates a preset with a [label] and a function that builds the range
  /// from the current time.
  const DateRangePreset({required this.label, required this.resolve});

  /// Text shown for this preset.
  final String label;

  /// Builds the range for this preset from `now`.
  final DateTimeRange Function(DateTime now) resolve;

  /// Today, Yesterday, Last 7 Days and Last 30 Days. Each range runs from
  /// 00:00 on its first day to 23:59 on its last day.
  static List<DateRangePreset> defaults([
    DualPickerLabels labels = DualPickerLabels.english,
  ]) =>
      [
        DateRangePreset(label: labels.today, resolve: (n) => days(n, 0, 0)),
        DateRangePreset(label: labels.yesterday, resolve: (n) => days(n, 1, 1)),
        DateRangePreset(label: labels.last7Days, resolve: (n) => days(n, 6, 0)),
        DateRangePreset(
          label: labels.last30Days,
          resolve: (n) => days(n, 29, 0),
        ),
      ];

  /// A range from 00:00 [fromDaysAgo] days before [now] to 23:59
  /// [toDaysAgo] days before [now].
  static DateTimeRange days(DateTime now, int fromDaysAgo, int toDaysAgo) {
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day - fromDaysAgo),
      end: DateTime(now.year, now.month, now.day - toDaysAgo, 23, 59),
    );
  }
}
