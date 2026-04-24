import 'package:flutter/material.dart';
import 'package:moneywise/core/constants/app_strings.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analytics)),
      body: const Center(
        child: Text('Analytics Content - // TODO Part 8: implement analytics charts'),
      ),
    );
  }
}
