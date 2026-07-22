import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../db/database_helper.dart';

class TaxEstimateScreen extends StatefulWidget {
  const TaxEstimateScreen({super.key});

  @override
  State<TaxEstimateScreen> createState() => _TaxEstimateScreenState();
}

class _TaxEstimateScreenState extends State<TaxEstimateScreen> {
  List<LedgerEntry> _entries = [];
  double _taxRate = 20.0;
  final _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await DatabaseHelper.instance.getAllLedgerEntries();
    final savedRate = await DatabaseHelper.instance.getSetting('tax_rate');
    setState(() {
      _entries = entries;
      _taxRate = savedRate != null ? double.tryParse(savedRate) ?? 20.0 : 20.0;
      _rateController.text = _taxRate.toString();
    });
  }

  Future<void> _saveRate() async {
    final rate = double.tryParse(_rateController.text);
    if (rate == null) return;
    await DatabaseHelper.instance.setSetting('tax_rate', rate.toString());
    setState(() => _taxRate = rate);
  }

  Map<String, double> _netIncomeByCurrency() {
    final Map<String, double> net = {};
    for (final e in _entries) {
      final delta = e.type == 'Income' ? e.amount : -e.amount;
      net[e.currency] = (net[e.currency] ?? 0) + delta;
    }
    return net;
  }

  @override
  Widget build(BuildContext context) {
    final netByCurrency = _netIncomeByCurrency();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Flat Tax Rate (%)'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _saveRate, child: const Text('Save Rate')),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'This is a simplified flat-rate estimate based on your business ledger '
                'net income per currency. It does not account for tax brackets, deductions, '
                'or region-specific rules. Consult a tax professional for actual filing.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: netByCurrency.isEmpty
                  ? const Center(child: Text('Add ledger entries to see tax estimates.'))
                  : ListView(
                      children: netByCurrency.entries.map((entry) {
                        final currency = entry.key;
                        final net = entry.value;
                        final estimatedTax = net > 0 ? net * (_taxRate / 100) : 0.0;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currency, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Net Income: ${net.toStringAsFixed(2)} $currency'),
                                Text(
                                  'Estimated Tax (${_taxRate.toStringAsFixed(1)}%): ${estimatedTax.toStringAsFixed(2)} $currency',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
