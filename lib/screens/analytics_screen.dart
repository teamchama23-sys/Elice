import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../db/database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, double> _totals = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getTotalsByCategory();
    setState(() => _totals = data);
  }

  @override
  Widget build(BuildContext context) {
    final total = _totals.values.fold(0.0, (a, b) => a + b);
    final colors = [
      Colors.blue, Colors.orange, Colors.green, Colors.purple,
      Colors.red, Colors.teal, Colors.brown,
    ];

    return Scaffold(
      body: _totals.isEmpty
          ? const Center(child: Text('Add expenses to see analytics.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Total: ${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: _totals.entries.toList().asMap().entries.map((entry) {
                          final i = entry.key;
                          final e = entry.value;
                          return PieChartSectionData(
                            value: e.value,
                            title: e.key,
                            color: colors[i % colors.length],
                            radius: 80,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
