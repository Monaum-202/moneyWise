import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportJson(Isar isar) async {
    final transactions = await isar.transactionModels.where().findAll();
    final loans = await isar.loanModels.where().findAll();
    final categories = await isar.categoryModels.where().findAll();

    final data = {
      'transactions': transactions.map((t) => _transToEntity(t).toJson()).toList(),
      'loans': loans.map((l) => _loanToEntity(l).toJson()).toList(),
      'categories': categories.map((c) => _catToEntity(c).toJson()).toList(),
    };

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/moneywise_export.json');
    await file.writeAsString(jsonEncode(data));

    await Share.shareXFiles([XFile(file.path)], text: 'Moneywise Data Export');
  }

  static Future<void> importJson(Isar isar, BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      final transJson = data['transactions'] as List?;
      final loansJson = data['loans'] as List?;
      final catsJson = data['categories'] as List?;

      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data?'),
          content: Text(
            'Found ${transJson?.length ?? 0} transactions, '
            '${loansJson?.length ?? 0} loans, and '
            '${catsJson?.length ?? 0} categories. '
            'Import them now?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Import')),
          ],
        ),
      );

      if (confirmed != true) return;

      await isar.writeTxn(() async {
        if (catsJson != null) {
          for (final json in catsJson) {
            final entity = CategoryEntity.fromJson(Map<String, dynamic>.from(json));
            final existing = await isar.categoryModels.where().uuidEqualTo(entity.uuid).findFirst();
            final model = _catToModel(entity);
            if (existing != null) model.id = existing.id;
            await isar.categoryModels.put(model);
          }
        }
        if (loansJson != null) {
          for (final json in loansJson) {
            final entity = LoanEntity.fromJson(Map<String, dynamic>.from(json));
            final existing = await isar.loanModels.where().uuidEqualTo(entity.uuid).findFirst();
            final model = _loanToModel(entity);
            if (existing != null) model.id = existing.id;
            await isar.loanModels.put(model);
          }
        }
        if (transJson != null) {
          for (final json in transJson) {
            final entity = TransactionEntity.fromJson(Map<String, dynamic>.from(json));
            final existing = await isar.transactionModels.where().uuidEqualTo(entity.uuid).findFirst();
            final model = _transToModel(entity);
            if (existing != null) model.id = existing.id;
            await isar.transactionModels.put(model);
          }
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import complete ✓')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  // Mapper helpers (Reuse logic from repository implementations)
  static TransactionEntity _transToEntity(TransactionModel m) => TransactionEntity(
        uuid: m.uuid,
        title: m.title,
        amount: m.amount,
        type: m.type,
        categoryId: m.categoryId,
        date: m.date,
        note: m.note,
        isRecurring: m.isRecurring,
        recurringType: m.recurringType,
        receiptImagePath: m.receiptImagePath,
        createdAt: m.createdAt,
      );

  static TransactionModel _transToModel(TransactionEntity e) => TransactionModel()
    ..uuid = e.uuid
    ..title = e.title
    ..amount = e.amount
    ..type = e.type
    ..categoryId = e.categoryId
    ..date = e.date
    ..note = e.note
    ..isRecurring = e.isRecurring
    ..recurringType = e.recurringType
    ..receiptImagePath = e.receiptImagePath
    ..createdAt = e.createdAt;

  static LoanEntity _loanToEntity(LoanModel m) => LoanEntity(
        uuid: m.uuid,
        personName: m.personName,
        amount: m.amount,
        type: m.type,
        date: m.date,
        dueDate: m.dueDate,
        purpose: m.purpose,
        isPaid: m.isPaid,
        paidAt: m.paidAt,
        createdAt: m.createdAt,
        repayments: m.repayments
            .map((r) => RepaymentEntity(
                  id: r.id,
                  amount: r.amount,
                  date: r.date,
                  note: r.note,
                ))
            .toList(),
      );

  static LoanModel _loanToModel(LoanEntity e) => LoanModel()
    ..uuid = e.uuid
    ..personName = e.personName
    ..amount = e.amount
    ..type = e.type
    ..date = e.date
    ..dueDate = e.dueDate
    ..purpose = e.purpose
    ..isPaid = e.isPaid
    ..paidAt = e.paidAt
    ..createdAt = e.createdAt
    ..repayments = e.repayments
        .map((r) => RepaymentModel()
          ..id = r.id
          ..amount = r.amount
          ..date = r.date
          ..note = r.note)
        .toList();

  static CategoryEntity _catToEntity(CategoryModel m) => CategoryEntity(
        uuid: m.uuid,
        name: m.name,
        iconCodePoint: m.iconCodePoint,
        colorValue: m.colorValue,
        isCustom: m.isCustom,
        isArchived: m.isArchived,
        monthlyBudget: m.monthlyBudget,
        createdAt: m.createdAt,
      );

  static CategoryModel _catToModel(CategoryEntity e) => CategoryModel()
    ..uuid = e.uuid
    ..name = e.name
    ..iconCodePoint = e.iconCodePoint
    ..colorValue = e.colorValue
    ..isCustom = e.isCustom
    ..isArchived = e.isArchived
    ..monthlyBudget = e.monthlyBudget
    ..createdAt = e.createdAt;
}
