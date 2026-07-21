import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../db/database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'General';
  String _currency = 'USD';
  DateTime _date = DateTime.now();

  final List<String> _categories = [
    'General', 'Food', 'Transport', 'Rent', 'Utilities', 'Entertainment', 'Other'
  ];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'PKR', 'AED'];

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
    final expense = Expense(
      title: _titleController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      category: _category,
      currency: _currency,
      date: _date,
    );
    await DatabaseHelper.instance.insertExpense(expense);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _currency,
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v!),
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
