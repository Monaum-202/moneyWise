import 'package:flutter/material.dart';
import 'package:moneywise/core/constants/app_strings.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loans)),
      body: const Center(
        child: Text('Loans Content - // TODO Part 7: implement loans module'),
      ),
    );
  }
}
