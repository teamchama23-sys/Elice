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
  final _customCategoryController = TextEditingController();
  String _category = 'General';
  bool _isCustomCategory = false;
  String _currency = 'USD';
  DateTime _date = DateTime.now();

  final List<String> _categories = [
    'General', 'Food', 'Transport', 'Rent', 'Utilities', 'Entertainment', 'Other', 'Custom'
  ];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'PKR', 'AED'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    final finalCategory = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _category;

    if (finalCategory.isEmpty) return;

    final expense = Expense(
      title: _titleController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      category: finalCategory,
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
      body: SingleChildScrollView(
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
              onChanged: (v) {
                setState(() {
                  _category = v!;
                  _isCustomCategory = v == 'Custom';
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            if (_isCustomCategory) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customCategoryController,
                decoration: const InputDecoration(labelText: 'Enter custom category'),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _currency,
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v!),
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date: ${_date.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
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
