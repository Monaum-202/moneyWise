import 'package:flutter/material.dart';
import 'package:moneywise/core/constants/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: const Center(
        child: Text('Settings Content - // TODO Part 8: implement settings'),
      ),
    );
  }
}
