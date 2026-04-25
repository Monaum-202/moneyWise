import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {

  const EmptyStateWidget({
    required this.message, super.key,
    this.icon = Icons.inbox_outlined,
  });
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
