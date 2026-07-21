import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../db/database_helper.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllExpenses();
    setState(() => _expenses = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _expenses.isEmpty
          ? const Center(child: Text('No expenses yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, i) {
                final e = _expenses[i];
                return Dismissible(
                  key: Key(e.id.toString()),
                  onDismissed: (_) async {
                    await DatabaseHelper.instance.deleteExpense(e.id!);
                    _load();
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(e.title),
                    subtitle: Text('${e.category} • ${e.date.toLocal()}'.split(' ')[0]),
                    trailing: Text('${e.amount.toStringAsFixed(2)} ${e.currency}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
