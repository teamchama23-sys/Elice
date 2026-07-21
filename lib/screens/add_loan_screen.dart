import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../db/database_helper.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final _nameController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _emiController = TextEditingController();
  final _totalMonthsController = TextEditingController();
  final _monthsPaidController = TextEditingController(text: '0');
  String _currency = 'USD';
  DateTime _date = DateTime.now();

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
    final principal = double.tryParse(_principalController.text);
    final rate = double.tryParse(_rateController.text);
    final emi = double.tryParse(_emiController.text);
    final totalMonths = int.tryParse(_totalMonthsController.text);
    final monthsPaid = int.tryParse(_monthsPaidController.text) ?? 0;

    if (_nameController.text.isEmpty || principal == null || rate == null || emi == null || totalMonths == null) {
      return;
    }

    final loan = Loan(
      name: _nameController.text,
      principal: principal,
      interestRate: rate,
      emiAmount: emi,
      totalMonths: totalMonths,
      monthsPaid: monthsPaid,
      currency: _currency,
      startDate: _date,
    );
    await DatabaseHelper.instance.insertLoan(loan);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Loan Name (e.g. Car Loan)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _principalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Principal Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Annual Interest Rate (%)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly EMI Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalMonthsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Months (loan term)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthsPaidController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Months Already Paid'),
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
              title: Text('Start Date: ${_date.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save Loan')),
          ],
        ),
      ),
    );
  }
}
