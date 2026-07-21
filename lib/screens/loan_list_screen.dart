import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../db/database_helper.dart';
import 'add_loan_screen.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({super.key});

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  List<Loan> _loans = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllLoans();
    setState(() => _loans = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loans.isEmpty
          ? const Center(child: Text('No loans yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _loans.length,
              itemBuilder: (context, i) {
                final loan = _loans[i];
                return Dismissible(
                  key: Key(loan.id.toString()),
                  onDismissed: (_) async {
                    await DatabaseHelper.instance.deleteLoan(loan.id!);
                    _load();
                  },
                  background: Container(color: Colors.red),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Remaining: ${loan.remainingBalance.toStringAsFixed(2)} ${loan.currency}'),
                            Text('EMI: ${loan.emiAmount.toStringAsFixed(2)} ${loan.currency}/mo • ${loan.interestRate}% APR'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: loan.progressPercent / 100),
                            const SizedBox(height: 4),
                            Text('${loan.monthsPaid}/${loan.totalMonths} months paid'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLoanScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
