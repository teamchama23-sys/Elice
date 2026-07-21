import 'package:flutter/material.dart';
import 'screens/expense_list_screen.dart';
import 'screens/analytics_screen.dart';
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
  int _dataTab = 0; // 0 = Expenses, 1 = Analytics

  @override
  Widget build(BuildContext context) {
    final dataBody = _dataTab == 0
        ? const ExpenseListScreen()
        : const AnalyticsScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text(_section == 0 ? 'My Finances' : 'AI Assistant'),
        bottom: _section == 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => setState(() => _dataTab = 0),
                        style: TextButton.styleFrom(
                          foregroundColor: _dataTab == 0 ? Colors.white : Colors.white70,
                        ),
                        child: const Text('Expenses'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => setState(() => _dataTab = 1),
                        style: TextButton.styleFrom(
                          foregroundColor: _dataTab == 1 ? Colors.white : Colors.white70,
                        ),
                        child: const Text('Analytics'),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: _section == 0 ? dataBody : const AiChatPlaceholderScreen(),
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
