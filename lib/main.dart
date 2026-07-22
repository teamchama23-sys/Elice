import 'package:flutter/material.dart';
import 'screens/expense_list_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/investment_list_screen.dart';
import 'screens/loan_list_screen.dart';
import 'screens/savings_goal_list_screen.dart';
import 'screens/invoice_list_screen.dart';
import 'screens/ledger_list_screen.dart';
import 'screens/tax_estimate_screen.dart';
import 'screens/ai_chat_placeholder_screen.dart';

void main() {
  runApp(const EliceApp());
}

class EliceApp extends StatelessWidget {
  const EliceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1B2430),
        useMaterial3: true,
      ),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _section = 0; // 0 = Data/Analytics, 1 = AI Chat
  int _dataTab = 0;

  final List<String> _tabLabels = [
    'Expenses', 'Analytics', 'Investments', 'Loans', 'Savings',
    'Invoices', 'Ledger', 'Tax'
  ];

  Widget _dataBody() {
    switch (_dataTab) {
      case 0:
        return const ExpenseListScreen();
      case 1:
        return const AnalyticsScreen();
      case 2:
        return const InvestmentListScreen();
      case 3:
        return const LoanListScreen();
      case 4:
        return const SavingsGoalListScreen();
      case 5:
        return const InvoiceListScreen();
      case 6:
        return const LedgerListScreen();
      case 7:
        return const TaxEstimateScreen();
      default:
        return const ExpenseListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_section == 0 ? _tabLabels[_dataTab] : 'AI Assistant'),
        bottom: _section == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(_tabLabels.length, (i) {
                      final selected = _dataTab == i;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextButton(
                          onPressed: () => setState(() => _dataTab = i),
                          style: TextButton.styleFrom(
                            foregroundColor: selected ? Colors.white : Colors.white70,
                          ),
                          child: Text(_tabLabels[i]),
                        ),
                      );
                    }),
                  ),
                ),
              )
            : null,
      ),
      body: _section == 0 ? _dataBody() : const AiChatPlaceholderScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _section,
        onDestinationSelected: (i) => setState(() => _section = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Finances'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
        ],
      ),
    );
  }
}
