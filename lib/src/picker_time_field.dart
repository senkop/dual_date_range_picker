import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'picker_labels.dart';
import 'pill_toggle.dart';

/// A compact 12-hour time input with hour and minute boxes and an AM/PM
/// toggle.
class PickerTimeField extends StatefulWidget {
  /// Creates a time field showing [value].
  const PickerTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.labels = DualPickerLabels.english,
  });

  /// The current time.
  final TimeOfDay value;

  /// Called when the user changes the time.
  final ValueChanged<TimeOfDay> onChanged;

  /// Text for the AM/PM toggle.
  final DualPickerLabels labels;

  @override
  State<PickerTimeField> createState() => _PickerTimeFieldState();
}

class _PickerTimeFieldState extends State<PickerTimeField> {
  late final TextEditingController _hour =
      TextEditingController(text: _hourText(widget.value));
  late final TextEditingController _minute =
      TextEditingController(text: _two(widget.value.minute));

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _hourText(TimeOfDay t) =>
      _two(t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod);

  bool get _isPm => widget.value.period == DayPeriod.pm;

  @override
  void didUpdateWidget(covariant PickerTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    final hour = _hourText(widget.value);
    if (int.tryParse(_hour.text) != int.parse(hour)) _hour.text = hour;
    if (int.tryParse(_minute.text) != widget.value.minute) {
      _minute.text = _two(widget.value.minute);
    }
  }

  @override
  void dispose() {
    _hour.dispose();
    _minute.dispose();
    super.dispose();
  }

  void _onHour(String text) {
    final h = int.tryParse(text);
    if (h == null || h < 1 || h > 12) return;
    widget.onChanged(TimeOfDay(
      hour: h % 12 + (_isPm ? 12 : 0),
      minute: widget.value.minute,
    ));
  }

  void _onMinute(String text) {
    final m = int.tryParse(text);
    if (m == null || m > 59) return;
    widget.onChanged(TimeOfDay(hour: widget.value.hour, minute: m));
  }

  void _setPm(bool pm) {
    if (pm == _isPm) return;
    widget.onChanged(TimeOfDay(
      hour: widget.value.hour % 12 + (pm ? 12 : 0),
      minute: widget.value.minute,
    ));
  }

  Widget _box(TextEditingController controller, ValueChanged<String> onChanged,
      String semanticLabel) {
    return SizedBox(
      width: 30,
      child: Semantics(
        label: semanticLabel,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: const InputDecoration.collapsed(hintText: '00'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          _box(_hour, _onHour, 'Hour'),
          const Text(':', style: TextStyle(fontSize: 20)),
          _box(_minute, _onMinute, 'Minute'),
          const Spacer(),
          PillToggle(
            options: [widget.labels.am, widget.labels.pm],
            selectedIndex: _isPm ? 1 : 0,
            onSelected: (i) => _setPm(i == 1),
            fontSize: 12,
          ),
        ],
      ),
    );
  }
}
