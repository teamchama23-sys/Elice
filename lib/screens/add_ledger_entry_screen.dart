import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../db/database_helper.dart';

class AddLedgerEntryScreen extends StatefulWidget {
  const AddLedgerEntryScreen({super.key});

  @override
  State<AddLedgerEntryScreen> createState() => _AddLedgerEntryScreenState();
}

class _AddLedgerEntryScreenState extends State<AddLedgerEntryScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Income';
  String _category = 'Sales';
  String _currency = 'USD';
  DateTime _date = DateTime.now();

  final List<String> _incomeCategories = ['Sales', 'Services', 'Interest', 'Other Income'];
  final List<String> _expenseCategories = ['Supplies', 'Rent', 'Salaries', 'Utilities', 'Marketing', 'Other Expense'];
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
    final amount = double.tryParse(_amountController.text);
    if (_descController.text.isEmpty || amount == null) return;

    final entry = LedgerEntry(
      description: _descController.text,
      amount: amount,
      type: _type,
      category: _category,
      currency: _currency,
      date: _date,
    );
    await DatabaseHelper.instance.insertLedgerEntry(entry);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'Income' ? _incomeCategories : _expenseCategories;
    if (!categories.contains(_category)) _category = categories.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Ledger Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Income', label: Text('Income')),
                ButtonSegment(value: 'Expense', label: Text('Expense')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
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
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _currency,
              items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
            ElevatedButton(onPressed: _save, child: const Text('Save Entry')),
          ],
        ),
      ),
    );
  }
}
