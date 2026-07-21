import 'package:flutter/material.dart';
import '../models/investment.dart';
import '../db/database_helper.dart';

class AddInvestmentScreen extends StatefulWidget {
  const AddInvestmentScreen({super.key});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  String _type = 'Stock';
  String _currency = 'USD';
  DateTime _date = DateTime.now();

  final List<String> _types = ['Stock', 'Crypto', 'Bond', 'Fund', 'Other'];
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
    final quantity = double.tryParse(_quantityController.text);
    final purchasePrice = double.tryParse(_purchasePriceController.text);
    final currentPrice = double.tryParse(_currentPriceController.text);

    if (_nameController.text.isEmpty || quantity == null || purchasePrice == null || currentPrice == null) {
      return;
    }

    final investment = Investment(
      name: _nameController.text,
      type: _type,
      quantity: quantity,
      purchasePrice: purchasePrice,
      currentPrice: currentPrice,
      currency: _currency,
      purchaseDate: _date,
    );
    await DatabaseHelper.instance.insertInvestment(investment);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Investment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name (e.g. AAPL, Bitcoin)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity / Units'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _purchasePriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Purchase Price (per unit)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currentPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current Price (per unit)'),
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
              title: Text('Purchase Date: ${_date.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save Investment')),
          ],
        ),
      ),
    );
  }
}
