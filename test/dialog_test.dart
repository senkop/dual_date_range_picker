import 'package:dual_date_range_picker/dual_date_range_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _today = DateTime(2026, 11, 19);

Future<Future<DateTimeRange?> Function()> _open(
  WidgetTester tester, {
  DualPickerLabels labels = DualPickerLabels.english,
}) async {
  DateTimeRange? result;
  Future<void>? done;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () {
            done = showDualDateRangePicker(
              context: context,
              currentDate: _today,
              labels: labels,
            ).then((r) => result = r);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () async {
    await done;
    return result;
  };
}

void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(500, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('picks a range by tapping two days', (tester) async {
    _phoneSize(tester);
    final result = await _open(tester);

    expect(find.text('November 2026'), findsOneWidget);
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final range = await result();
    expect(range, isNotNull);
    expect(range!.start, DateTime(2026, 11, 3));
    expect(range.end, DateTime(2026, 11, 5, 23, 59));
  });

  testWidgets('a preset fills the range', (tester) async {
    _phoneSize(tester);
    final result = await _open(tester);

    await tester.tap(find.text('Last 7 Days'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final range = await result();
    expect(range!.start, DateTime(2026, 11, 13));
    expect(range.end, DateTime(2026, 11, 19, 23, 59));
  });

  testWidgets('switches to the Hijri calendar', (tester) async {
    _phoneSize(tester);
    await _open(tester);

    await tester.tap(find.text('Hijri'));
    await tester.pumpAndSettle();
    expect(find.text('Jumada Al-Thani 1448'), findsOneWidget);
  });

  testWidgets('Apply is disabled until a day is picked', (tester) async {
    _phoneSize(tester);
    await _open(tester);

    final apply = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(apply.onPressed, isNull);
  });

  testWidgets('shows two months on wide screens', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _open(tester);

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
  });

  testWidgets('uses Arabic labels', (tester) async {
    _phoneSize(tester);
    await _open(tester, labels: DualPickerLabels.arabic);

    expect(find.text('اختر الفترة'), findsOneWidget);
    expect(find.text('نوفمبر 2026'), findsOneWidget);
  });
}
