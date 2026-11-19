import 'package:flutter/material.dart';

/// A small segmented toggle, used for Gregorian/Hijri and AM/PM.
class PillToggle extends StatelessWidget {
  /// Creates a toggle with [options], highlighting [selectedIndex].
  const PillToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.fontSize = 13,
  });

  /// The option labels.
  final List<String> options;

  /// The highlighted option.
  final int selectedIndex;

  /// Called with the index of a tapped option.
  final ValueChanged<int> onSelected;

  /// Font size of the labels.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            Semantics(
              button: true,
              selected: i == selectedIndex,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: i == selectedIndex
                          ? scheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      options[i],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: i == selectedIndex
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: i == selectedIndex
                            ? scheme.onPrimary
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
