import 'package:flutter/material.dart';
import 'package:moneywise/core/constants/app_strings.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.transactions)),
      body: const Center(
        child: Text('Transactions Content - // TODO Part 6: implement transactions list'),
      ),
    );
  }
}
