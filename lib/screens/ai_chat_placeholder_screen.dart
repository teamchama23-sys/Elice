import 'package:flutter/material.dart';

class AiChatPlaceholderScreen extends StatelessWidget {
  const AiChatPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Offline AI Assistant\nComing in Phase 4',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
