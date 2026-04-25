import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/app.dart';
import 'package:moneywise/core/utils/logger.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:path_provider/path_provider.dart';

class PreloadedIsar extends IsarNotifier {
  PreloadedIsar(this.isar);
  final Isar isar;
  @override
  Future<Isar> build() async => isar;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  logger.i('Initializing Database...');
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      TransactionModelSchema,
      LoanModelSchema,
      CategoryModelSchema,
      BudgetModelSchema,
    ],
    directory: dir.path,
  );

  logger.i('Starting Moneywise App...');

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWith(() => PreloadedIsar(isar)),
      ],
      child: const MoneywiseApp(),
    ),
  );
}
