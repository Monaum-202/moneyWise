import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/app.dart';
import 'package:moneywise/core/utils/logger.dart';
import 'package:moneywise/shared/models/budget_model.dart';
import 'package:moneywise/shared/models/category_model.dart';
import 'package:moneywise/shared/models/loan_model.dart';
import 'package:moneywise/shared/models/transaction_model.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('Initializing Database...');
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      TransactionSchema,
      LoanSchema,
      CategorySchema,
      BudgetSchema,
    ],
    directory: dir.path,
  );

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
