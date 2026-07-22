import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../db/database_helper.dart';
import 'add_ledger_entry_screen.dart';

class LedgerListScreen extends StatefulWidget {
  const LedgerListScreen({super.key});

  @override
  State<LedgerListScreen> createState() => _LedgerListScreenState();
}

class _LedgerListScreenState extends State<LedgerListScreen> {
  List<LedgerEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllLedgerEntries();
    setState(() => _entries = data);
  }

  @override
  Widget build(BuildContext context) {
    final income = _entries.where((e) => e.type == 'Income').fold(0.0, (s, e) => s + e.amount);
    final expense = _entries.where((e) => e.type == 'Expense').fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      body: Column(
        children: [
          if (_entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Text('Income'),
                    Text(income.toStringAsFixed(2), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ]),
                  Column(children: [
                    const Text('Expense'),
                    Text(expense.toStringAsFixed(2), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ]),
                  Column(children: [
                    const Text('Net'),
                    Text((income - expense).toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
          Expanded(
            child: _entries.isEmpty
                ? const Center(child: Text('No ledger entries yet. Tap + to add one.'))
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (context, i) {
                      final e = _entries[i];
                      return Dismissible(
                        key: Key(e.id.toString()),
                        onDismissed: (_) async {
                          await DatabaseHelper.instance.deleteLedgerEntry(e.id!);
                          _load();
                        },
                        background: Container(color: Colors.red),
                        child: ListTile(
                          title: Text(e.description),
                          subtitle: Text('${e.category} • ${e.date.toLocal()}'.split(' ')[0]),
                          trailing: Text(
                            '${e.type == 'Income' ? '+' : '-'}${e.amount.toStringAsFixed(2)} ${e.currency}',
                            style: TextStyle(
                              color: e.type == 'Income' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
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
            MaterialPageRoute(builder: (_) => const AddLedgerEntryScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
