import 'package:dual_date_range_picker/dual_date_range_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dual_date_range_picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1C1C28),
          primary: const Color(0xFF1C1C28),
        ),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  DateTimeRange? _range;
  bool _arabic = false;

  Future<void> _pick() async {
    final labels = _arabic ? DualPickerLabels.arabic : DualPickerLabels.english;
    final range = await showDualDateRangePicker(
      context: context,
      initialRange: _range,
      lastDate: DateTime.now(),
      labels: labels,
    );
    if (range != null) setState(() => _range = range);
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    return Directionality(
      textDirection: _arabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: const Text('dual_date_range_picker')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _pick,
                icon: const Icon(Icons.date_range),
                label: const Text('Pick a date range'),
              ),
              const SizedBox(height: 16),
              Text(
                range == null
                    ? 'No range selected'
                    : '${range.start}  →  ${range.end}',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 260,
                child: SwitchListTile(
                  title: const Text('Arabic labels (RTL)'),
                  value: _arabic,
                  onChanged: (v) => setState(() => _arabic = v),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
