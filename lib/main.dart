import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/app.dart';
import 'package:moneywise/core/services/isar_service.dart';
import 'package:moneywise/core/services/notification_service.dart';
import 'package:moneywise/core/utils/logger.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('Initializing Notifications...');
  await NotificationService.init();

  logger.i('Initializing Database...');
  final isar = await IsarService.open();

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
