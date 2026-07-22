import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../db/database_helper.dart';
import 'add_invoice_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<Invoice> _invoices = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllInvoices();
    setState(() => _invoices = data);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      case 'Sent':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _invoices.isEmpty
          ? const Center(child: Text('No invoices yet. Tap + to create one.'))
          : ListView.builder(
              itemCount: _invoices.length,
              itemBuilder: (context, i) {
                final inv = _invoices[i];
                return Dismissible(
                  key: Key(inv.id.toString()),
                  onDismissed: (_) async {
                    await DatabaseHelper.instance.deleteInvoice(inv.id!);
                    _load();
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    title: Text(inv.clientName),
                    subtitle: Text('${inv.description} • Due ${inv.dueDate.toLocal()}'.split(' ')[0]),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${inv.amount.toStringAsFixed(2)} ${inv.currency}'),
                        Text(inv.status, style: TextStyle(color: _statusColor(inv.status), fontSize: 12)),
                      ],
                    ),
                    onTap: () async {
                      final newStatus = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: ['Draft', 'Sent', 'Paid', 'Overdue']
                              .map((s) => ListTile(title: Text(s), onTap: () => Navigator.pop(context, s)))
                              .toList(),
                        ),
                      );
                      if (newStatus != null) {
                        await DatabaseHelper.instance.updateInvoiceStatus(inv.id!, newStatus);
                        _load();
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddInvoiceScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
