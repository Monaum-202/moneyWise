import 'package:flutter/material.dart';
import 'package:moneywise/core/constants/app_strings.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dashboard)),
      body: const Center(
        child: Text('Dashboard Content - // TODO Part 6: implement dashboard widgets'),
      ),
    );
  }
}
