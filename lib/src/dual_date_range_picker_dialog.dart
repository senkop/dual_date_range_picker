import 'package:flutter/material.dart';

import 'calendar_system.dart';
import 'date_range_preset.dart';
import 'month_view.dart';
import 'picker_labels.dart';
import 'picker_time_field.dart';
import 'pill_toggle.dart';

/// Shows the dual Gregorian/Hijri date range picker and returns the chosen
/// range, or `null` if the user cancels.
///
/// ```dart
/// final range = await showDualDateRangePicker(context: context);
/// ```
Future<DateTimeRange?> showDualDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
  DateTime? currentDate,
  CalendarKind initialCalendar = CalendarKind.gregorian,
  List<DateRangePreset>? presets,
  bool showTime = true,
  bool showCalendarToggle = true,
  int firstDayOfWeek = DateTime.sunday,
  DualPickerLabels labels = DualPickerLabels.english,
  bool barrierDismissible = true,
}) {
  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => DualDateRangePickerDialog(
      initialRange: initialRange,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialCalendar: initialCalendar,
      presets: presets,
      showTime: showTime,
      showCalendarToggle: showCalendarToggle,
      firstDayOfWeek: firstDayOfWeek,
      labels: labels,
    ),
  );
}

/// A dialog for picking a date (and optionally time) range on either the
/// Gregorian or the Hijri calendar.
///
/// It pops with a [DateTimeRange] when the user taps Apply. Usually shown
/// with [showDualDateRangePicker].
class DualDateRangePickerDialog extends StatefulWidget {
  /// Creates the picker dialog.
  const DualDateRangePickerDialog({
    super.key,
    this.initialRange,
    this.firstDate,
    this.lastDate,
    this.currentDate,
    this.initialCalendar = CalendarKind.gregorian,
    this.presets,
    this.showTime = true,
    this.showCalendarToggle = true,
    this.firstDayOfWeek = DateTime.sunday,
    this.labels = DualPickerLabels.english,
  });

  /// The range selected when the dialog opens.
  final DateTimeRange? initialRange;

  /// Earliest selectable day. Defaults to 1 January 2000.
  final DateTime? firstDate;

  /// Latest selectable day. Defaults to 31 December 2075.
  final DateTime? lastDate;

  /// "Today" for highlighting and presets. Defaults to [DateTime.now].
  final DateTime? currentDate;

  /// The calendar shown first.
  final CalendarKind initialCalendar;

  /// Quick-pick ranges. Defaults to [DateRangePreset.defaults]. Pass an
  /// empty list to hide them.
  final List<DateRangePreset>? presets;

  /// Whether to show the start and end time fields.
  final bool showTime;

  /// Whether to show the Gregorian/Hijri toggle.
  final bool showCalendarToggle;

  /// First column of the calendar, e.g. [DateTime.sunday].
  final int firstDayOfWeek;

  /// All text in the dialog.
  final DualPickerLabels labels;

  @override
  State<DualDateRangePickerDialog> createState() =>
      _DualDateRangePickerDialogState();
}

class _DualDateRangePickerDialogState extends State<DualDateRangePickerDialog> {
  late CalendarKind _kind = widget.initialCalendar;
  late final DateTime _now = widget.currentDate ?? DateTime.now();
  late final DateTime _today = dateOnly(_now);
  late final DateTime _first = dateOnly(widget.firstDate ?? DateTime(2000));
  late final DateTime _last =
      dateOnly(widget.lastDate ?? DateTime(2075, 12, 31));
  late final List<DateRangePreset> _presets =
      widget.presets ?? DateRangePreset.defaults(widget.labels);

  DateTime? _start;
  DateTime? _end;
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);

  /// The month shown in the last (rightmost) panel.
  late CalendarMonth _anchor;

  CalendarSystem get _system => CalendarSystem.of(_kind);

  @override
  void initState() {
    super.initState();
    final range = widget.initialRange;
    if (range != null) {
      _start = dateOnly(range.start);
      _end = dateOnly(range.end);
      _startTime = TimeOfDay.fromDateTime(range.start);
      _endTime = TimeOfDay.fromDateTime(range.end);
    }
    _anchor = _system.monthOf(_end ?? _start ?? _today);
  }

  void _setKind(CalendarKind kind) {
    if (kind == _kind) return;
    setState(() {
      _kind = kind;
      _anchor = _system.monthOf(_end ?? _start ?? _today);
    });
  }

  void _onDayTap(DateTime day) {
    setState(() {
      final s = _start;
      if (s == null || _end != null || day.isBefore(s)) {
        _start = day;
        _end = null;
      } else {
        _end = day;
      }
    });
  }

  void _applyPreset(DateRangePreset preset) {
    final range = preset.resolve(_now);
    setState(() {
      _start = dateOnly(range.start);
      _end = dateOnly(range.end);
      _startTime = TimeOfDay.fromDateTime(range.start);
      _endTime = TimeOfDay.fromDateTime(range.end);
      _anchor = _system.monthOf(_end!);
    });
  }

  DateTimeRange? get _result {
    final s = _start;
    if (s == null) return null;
    final e = _end ?? s;
    final start =
        DateTime(s.year, s.month, s.day, _startTime.hour, _startTime.minute);
    final end =
        DateTime(e.year, e.month, e.day, _endTime.hour, _endTime.minute);
    if (end.isBefore(start)) return null;
    return DateTimeRange(start: start, end: end);
  }

  String _gregorianText(DateTime d) {
    final l = widget.labels;
    return '${l.weekdaysAbbr[d.weekday % 7]}, ${d.day} '
        '${l.gregorianMonths[d.month - 1]} ${d.year}';
  }

  String _hijriText(DateTime d) {
    const hijri = CalendarSystem.hijri;
    final m = hijri.monthOf(d);
    return '${hijri.dayOf(d)} ${widget.labels.hijriMonths[m.month - 1]} '
        '${m.year}';
  }

  String _span(String Function(DateTime) format) {
    final s = _start;
    if (s == null) return '';
    final e = _end;
    if (e == null || isSameDay(s, e)) return format(s);
    return '${format(s)} – ${format(e)}';
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context),
                  const Divider(height: 1),
                  if (wide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_presets.isNotEmpty) ...[
                            SizedBox(width: 160, child: _presetList()),
                            const VerticalDivider(width: 1),
                          ],
                          Expanded(child: _calendars(2)),
                        ],
                      ),
                    )
                  else ...[
                    if (_presets.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: _presetChips(),
                      ),
                    _calendars(1),
                  ],
                  const Divider(height: 1),
                  if (widget.showTime)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _timeFields(wide),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _footer(context, labels),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final labels = widget.labels;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              labels.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (widget.showCalendarToggle)
            PillToggle(
              options: [labels.gregorian, labels.hijri],
              selectedIndex: _kind == CalendarKind.hijri ? 1 : 0,
              onSelected: (i) => _setKind(
                  i == 1 ? CalendarKind.hijri : CalendarKind.gregorian),
            ),
        ],
      ),
    );
  }

  Widget _presetList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final preset in _presets)
            InkWell(
              onTap: () => _applyPreset(preset),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(preset.label),
              ),
            ),
        ],
      ),
    );
  }

  Widget _presetChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final preset in _presets)
          ActionChip(
            label: Text(preset.label),
            onPressed: () => _applyPreset(preset),
          ),
      ],
    );
  }

  Widget _calendars(int count) {
    final months = [for (var i = count - 1; i >= 0; i--) _anchor + -i];
    final firstMonth = _system.monthOf(_first);
    final lastMonth = _system.monthOf(_last);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < months.length; i++) ...[
            if (i > 0) const SizedBox(width: 24),
            Expanded(
              child: MonthView(
                month: months[i],
                system: _system,
                labels: widget.labels,
                today: _today,
                firstDate: _first,
                lastDate: _last,
                start: _start,
                end: _end,
                firstDayOfWeek: widget.firstDayOfWeek,
                onDayTap: _onDayTap,
                showPrevious: i == 0,
                showNext: i == months.length - 1,
                onPrevious: months.first.compareTo(firstMonth) > 0
                    ? () => setState(() => _anchor = _anchor + -1)
                    : null,
                onNext: _anchor.compareTo(lastMonth) < 0
                    ? () => setState(() => _anchor = _anchor + 1)
                    : null,
                onMonthSelected: (m) => setState(
                  () => _anchor = m + (months.length - 1 - i),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeFields(bool wide) {
    final labels = widget.labels;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    Widget labeled(String label, Widget child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: textStyle),
            const SizedBox(height: 6),
            child,
          ],
        );
    final startField = labeled(
      labels.startTime,
      PickerTimeField(
        value: _startTime,
        labels: labels,
        onChanged: (t) => setState(() => _startTime = t),
      ),
    );
    final endField = labeled(
      labels.endTime,
      PickerTimeField(
        value: _endTime,
        labels: labels,
        onChanged: (t) => setState(() => _endTime = t),
      ),
    );
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [startField, const SizedBox(height: 12), endField],
      );
    }
    return Row(
      children: [
        Expanded(child: startField),
        const SizedBox(width: 16),
        Expanded(child: endField),
      ],
    );
  }

  Widget _footer(BuildContext context, DualPickerLabels labels) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final result = _result;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_start != null) ...[
                Text(_span(_gregorianText), style: small),
                Text(_span(_hijriText), style: small),
              ],
              if (_start != null && result == null)
                Text(
                  labels.invalidRange,
                  style: small?.copyWith(color: theme.colorScheme.error),
                ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(labels.cancel),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed:
              result == null ? null : () => Navigator.of(context).pop(result),
          child: Text(labels.apply),
        ),
      ],
    );
  }
}
