import 'package:flutter/material.dart';

import 'calendar_system.dart';
import 'picker_labels.dart';

/// Returns [d] with the time removed.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whether [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// One month of the range picker: a header with navigation, weekday labels
/// and a grid of days with the selected range highlighted.
class MonthView extends StatelessWidget {
  /// Creates a month view.
  const MonthView({
    super.key,
    required this.month,
    required this.system,
    required this.labels,
    required this.today,
    required this.firstDate,
    required this.lastDate,
    required this.onDayTap,
    required this.onMonthSelected,
    this.start,
    this.end,
    this.firstDayOfWeek = DateTime.sunday,
    this.showPrevious = false,
    this.showNext = false,
    this.onPrevious,
    this.onNext,
  });

  /// The month to show, in [system].
  final CalendarMonth month;

  /// The calendar the month belongs to.
  final CalendarSystem system;

  /// Text for month and weekday names.
  final DualPickerLabels labels;

  /// Today's date, outlined in the grid.
  final DateTime today;

  /// Earliest selectable day.
  final DateTime firstDate;

  /// Latest selectable day.
  final DateTime lastDate;

  /// Start of the selected range.
  final DateTime? start;

  /// End of the selected range.
  final DateTime? end;

  /// First column of the grid, e.g. [DateTime.sunday] or [DateTime.monday].
  final int firstDayOfWeek;

  /// Whether to reserve and show the "previous month" button.
  final bool showPrevious;

  /// Whether to reserve and show the "next month" button.
  final bool showNext;

  /// Called by the previous button. `null` disables it.
  final VoidCallback? onPrevious;

  /// Called by the next button. `null` disables it.
  final VoidCallback? onNext;

  /// Called when a day is tapped.
  final ValueChanged<DateTime> onDayTap;

  /// Called when a month is chosen from the header menu.
  final ValueChanged<CalendarMonth> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final names = system is HijriCalendarSystem
        ? labels.hijriMonths
        : labels.gregorianMonths;

    final first = system.firstDayOf(month);
    final count = system.daysIn(month);
    final leading = (first.weekday - firstDayOfWeek) % 7;
    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const SizedBox.shrink(),
      for (var d = 0; d < count; d++)
        _DayCell(
          date: DateTime(first.year, first.month, first.day + d),
          label: '${d + 1}',
          start: start,
          end: end,
          today: today,
          firstDate: firstDate,
          lastDate: lastDate,
          onTap: onDayTap,
        ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: showPrevious
                    ? IconButton(
                        onPressed: onPrevious,
                        icon: const Icon(Icons.chevron_left),
                        iconSize: 20,
                      )
                    : null,
              ),
              Expanded(
                child: Center(
                  child: PopupMenuButton<int>(
                    onSelected: (m) =>
                        onMonthSelected(CalendarMonth(month.year, m)),
                    itemBuilder: (context) => [
                      for (var m = 1; m <= 12; m++)
                        PopupMenuItem(value: m, child: Text(names[m - 1])),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${names[month.month - 1]} ${month.year}',
                          style: theme.textTheme.titleSmall,
                        ),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: showNext
                    ? IconButton(
                        onPressed: onNext,
                        icon: const Icon(Icons.chevron_right),
                        iconSize: 20,
                      )
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 32,
          child: Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Center(
                    child: Text(
                      labels.weekdaysShort[(firstDayOfWeek % 7 + c) % 7],
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (var r = 0; r < cells.length; r += 7)
          SizedBox(
            height: 40,
            child: Row(
              children: [
                for (final cell in cells.sublist(r, r + 7))
                  Expanded(child: cell),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.label,
    required this.start,
    required this.end,
    required this.today,
    required this.firstDate,
    required this.lastDate,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final DateTime? start;
  final DateTime? end;
  final DateTime today;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = start;
    final e = end;
    final isStart = s != null && isSameDay(date, s);
    final isEnd = e != null && isSameDay(date, e);
    final hasSpan = s != null && e != null && e.isAfter(s);
    final inside =
        s != null && e != null && date.isAfter(s) && date.isBefore(e) && !isEnd;
    final selected = isStart || isEnd;
    final enabled = !date.isBefore(firstDate) && !date.isAfter(lastDate);
    final band = scheme.surfaceContainerHighest;

    final textColor = !enabled
        ? scheme.outline
        : selected
            ? scheme.onPrimary
            : scheme.onSurface;

    final child = Stack(
      children: [
        if (hasSpan && (inside || isStart || isEnd))
          Positioned.fill(
            top: 2,
            bottom: 2,
            child: Row(
              children: [
                Expanded(
                  child: ColoredBox(
                    color: inside || isEnd ? band : Colors.transparent,
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: inside || isStart ? band : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        Center(
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? scheme.primary : null,
              border: !selected && isSameDay(date, today)
                  ? Border.all(color: scheme.primary)
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );

    if (!enabled) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(date),
        child: child,
      ),
    );
  }
}
