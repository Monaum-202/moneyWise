import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moneywise/app.dart';
import 'package:moneywise/core/services/isar_service.dart';
import 'package:moneywise/core/services/notification_service.dart';
import 'package:moneywise/core/utils/logger.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('Initializing Database...');
  final isar = await IsarService.open();

  // Load settings from SecureStorage to get initial currency for notifications
  const storage = FlutterSecureStorage();
  final rawSettings = await storage.read(key: 'app_settings');
  String initialCurrency = 'BDT';
  
  if (rawSettings != null) {
    try {
      final Map<String, dynamic> settingsMap = jsonDecode(rawSettings);
      initialCurrency = settingsMap['currency'] ?? 'BDT';
    } catch (e) {
      logger.e('Failed to parse settings: $e');
    }
  }

  logger.i('Initializing Notifications with $initialCurrency...');
  await NotificationService.init(initialCurrency);

  logger.i('Starting Moneywise App...');
  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MoneywiseApp(),
    ),
  );
}
