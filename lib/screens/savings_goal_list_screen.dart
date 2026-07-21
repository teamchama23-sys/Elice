import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../db/database_helper.dart';
import 'add_savings_goal_screen.dart';

class SavingsGoalListScreen extends StatefulWidget {
  const SavingsGoalListScreen({super.key});

  @override
  State<SavingsGoalListScreen> createState() => _SavingsGoalListScreenState();
}

class _SavingsGoalListScreenState extends State<SavingsGoalListScreen> {
  List<SavingsGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllSavingsGoals();
    setState(() => _goals = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _goals.isEmpty
          ? const Center(child: Text('No savings goals yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, i) {
                final goal = _goals[i];
                return Dismissible(
                  key: Key(goal.id.toString()),
                  onDismissed: (_) async {
                    await DatabaseHelper.instance.deleteSavingsGoal(goal.id!);
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
                            Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)} ${goal.currency}'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: goal.progressPercent / 100),
                            const SizedBox(height: 4),
                            Text('${goal.progressPercent.toStringAsFixed(1)}% complete'),
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
            MaterialPageRoute(builder: (_) => const AddSavingsGoalScreen()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
