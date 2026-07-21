import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../db/database_helper.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController(text: '0');
  String _currency = 'USD';
  DateTime? _targetDate;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'INR', 'PKR', 'AED'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    final target = double.tryParse(_targetController.text);
    final current = double.tryParse(_currentController.text) ?? 0;

    if (_nameController.text.isEmpty || target == null) return;

    final goal = SavingsGoal(
      name: _nameController.text,
      targetAmount: target,
      currentAmount: current,
      currency: _currency,
      targetDate: _targetDate,
    );
    await DatabaseHelper.instance.insertSavingsGoal(goal);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Savings Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name (e.g. Emergency Fund)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current Amount Saved'),
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
              title: Text(_targetDate == null
                  ? 'Target Date (optional)'
                  : 'Target: ${_targetDate!.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save Goal')),
          ],
        ),
      ),
    );
  }
}
