import 'package:flutter/material.dart';
import '../models/investment.dart';
import '../db/database_helper.dart';
import 'add_investment_screen.dart';

class InvestmentListScreen extends StatefulWidget {
  const InvestmentListScreen({super.key});

  @override
  State<InvestmentListScreen> createState() => _InvestmentListScreenState();
}

class _InvestmentListScreenState extends State<InvestmentListScreen> {
  List<Investment> _investments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllInvestments();
    setState(() => _investments = data);
  }

  @override
  Widget build(BuildContext context) {
    final totalValue = _investments.fold(0.0, (sum, i) => sum + i.currentValue);
    final totalGainLoss = _investments.fold(0.0, (sum, i) => sum + i.gainLoss);

    return Scaffold(
      body: Column(
        children: [
          if (_investments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Text('Total Value'),
                    Text(totalValue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                  Column(children: [
                    const Text('Gain/Loss'),
                    Text(
                      totalGainLoss.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalGainLoss >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          Expanded(
            child: _investments.isEmpty
                ? const Center(child: Text('No investments yet. Tap + to add one.'))
                : ListView.builder(
                    itemCount: _investments.length,
                    itemBuilder: (context, i) {
                      final inv = _investments[i];
                      return Dismissible(
                        key: Key(inv.id.toString()),
                        onDismissed: (_) async {
                          await DatabaseHelper.instance.deleteInvestment(inv.id!);
                          _load();
                        },
                        background: Container(color: Colors.red),
                        child: ListTile(
                          title: Text(inv.name),
                          subtitle: Text('${inv.type} • ${inv.quantity} units'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${inv.currentValue.toStringAsFixed(2)} ${inv.currency}'),
                              Text(
                                '${inv.gainLoss >= 0 ? '+' : ''}${inv.gainLoss.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: inv.gainLoss >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddInvestmentScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
