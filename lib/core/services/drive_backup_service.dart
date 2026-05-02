import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:isar/isar.dart';
import 'package:moneywise/core/services/drive_backup_result.dart';
import 'package:moneywise/core/services/google_auth_service.dart';
import 'package:moneywise/features/budget/domain/budget_model.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';

class DriveBackupService {
  static const _backupFileName = 'moneywise_backup.json';
  static const _appDataFolder = 'appDataFolder';

  // ─── BACKUP ──────────────────────────────────────────
  static Future<DriveBackupResult> backup(Isar isar) async {
    try {
      final client = await GoogleAuthService.getAuthClient();
      if (client == null) return const DriveBackupResult.notSignedIn();

      final driveApi = drive.DriveApi(client);

      // 1. Generate JSON from all Isar data
      final jsonData = await _generateBackupJson(isar);
      final bytes = utf8.encode(jsonData);
      final stream = Stream.fromIterable([bytes]);

      // 2. Check if backup file already exists in appDataFolder
      final existingId = await _findExistingBackupId(driveApi);

      final driveFile = drive.File()
        ..name = _backupFileName
        ..parents = existingId == null ? [_appDataFolder] : null;

      final media = drive.Media(stream, bytes.length,
          contentType: 'application/json');

      // 3. Update existing OR create new
      if (existingId != null) {
        await driveApi.files.update(driveFile, existingId,
            uploadMedia: media);
      } else {
        await driveApi.files.create(driveFile, uploadMedia: media);
      }

      client.close();
      return DriveBackupResult.success(
        timestamp: DateTime.now(),
        sizeBytes: bytes.length,
      );
    } catch (e) {
      return DriveBackupResult.failure(e.toString());
    }
  }

  // ─── RESTORE ─────────────────────────────────────────
  static Future<DriveRestoreResult> restore(Isar isar) async {
    try {
      final client = await GoogleAuthService.getAuthClient();
      if (client == null) return const DriveRestoreResult.notSignedIn();

      final driveApi = drive.DriveApi(client);
      final fileId = await _findExistingBackupId(driveApi);

      if (fileId == null) return const DriveRestoreResult.noBackupFound();

      // Download file content
      final response = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> chunks = [];
      await for (final chunk in response.stream) {
        chunks.addAll(chunk);
      }
      final jsonString = utf8.decode(chunks);

      // Parse backup info before importing
      final Map<String, dynamic> backupMap = jsonDecode(jsonString);
      final meta = BackupMetadata.fromJson(backupMap['metadata']);

      client.close();
      return DriveRestoreResult.ready(
        jsonString: jsonString,
        metadata: meta,
      );
    } catch (e) {
      return DriveRestoreResult.failure(e.toString());
    }
  }

  // ─── IMPORT to Isar after user confirms ──────────────
  static Future<void> importToIsar(Isar isar, String jsonString) async {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    await isar.writeTxn(() async {
      // Clear existing data
      await isar.transactionModels.clear();
      await isar.loanModels.clear();
      await isar.categoryModels.clear();
      await isar.budgetModels.clear();

      // Import categories
      final catList = (map['categories'] as List)
          .map((e) => _catToModel(CategoryEntity.fromJson(Map<String, dynamic>.from(e))))
          .toList();
      await isar.categoryModels.putAll(catList);

      // Import budgets
      final budgetList = (map['budgets'] as List? ?? [])
          .map((e) => _budgetToModel(BudgetEntity.fromJson(Map<String, dynamic>.from(e))))
          .toList();
      await isar.budgetModels.putAll(budgetList);

      // Import loans
      final loanList = (map['loans'] as List)
          .map((e) => _loanToModel(LoanEntity.fromJson(Map<String, dynamic>.from(e))))
          .toList();
      await isar.loanModels.putAll(loanList);

      // Import transactions
      final txList = (map['transactions'] as List)
          .map((e) => _transToModel(TransactionEntity.fromJson(Map<String, dynamic>.from(e))))
          .toList();
      await isar.transactionModels.putAll(txList);
    });
  }

  // ─── CHECK last backup info ───────────────────────────
  static Future<BackupMetadata?> getLastBackupInfo() async {
    try {
      final client = await GoogleAuthService.getAuthClient();
      if (client == null) return null;
      final driveApi = drive.DriveApi(client);
      final fileId = await _findExistingBackupId(driveApi);
      if (fileId == null) {
        client.close();
        return null;
      }

      final file = await driveApi.files.get(fileId,
          $fields: 'modifiedTime,size') as drive.File;
      
      // We also want the counts if possible, but that requires downloading the file.
      // For the quick "Last backup" info, size and time are enough.
      // If we want counts, we'd need to fetch them from the metadata inside the file.
      // Let's just return what we have from the file object for now.
      
      client.close();
      return BackupMetadata(
        lastBackupTime: file.modifiedTime?.toLocal() ?? DateTime.now(),
        sizeBytes: int.tryParse(file.size ?? '0') ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  // ─── PRIVATE helpers ──────────────────────────────────
  static Future<String?> _findExistingBackupId(drive.DriveApi api) async {
    final list = await api.files.list(
      spaces: _appDataFolder,
      q: "name='$_backupFileName'",
      $fields: 'files(id)',
    );
    return list.files?.firstOrNull?.id;
  }

  static Future<String> _generateBackupJson(Isar isar) async {
    final transactions = await isar.transactionModels.where().findAll();
    final loans = await isar.loanModels.where().findAll();
    final categories = await isar.categoryModels.where().findAll();
    final budgets = await isar.budgetModels.where().findAll();

    return jsonEncode({
      'metadata': {
        'version': '1.0',
        'appName': 'Moneywise',
        'exportedAt': DateTime.now().toIso8601String(),
        'transactionCount': transactions.length,
        'loanCount': loans.length,
        'categoryCount': categories.length,
        'budgetCount': budgets.length,
      },
      'transactions': transactions.map((t) => _transToEntity(t).toJson()).toList(),
      'loans': loans.map((l) => _loanToEntity(l).toJson()).toList(),
      'categories': categories.map((c) => _catToEntity(c).toJson()).toList(),
      'budgets': budgets.map((b) => _budgetToEntity(b).toJson()).toList(),
    });
  }

  // Mapper helpers (Copied/Adapted from ExportService)
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

  static BudgetEntity _budgetToEntity(BudgetModel m) => BudgetEntity(
        uuid: m.uuid,
        categoryId: m.categoryId,
        monthYear: m.monthYear,
        limitAmount: m.limitAmount,
        spentAmount: m.spentAmount,
      );

  static BudgetModel _budgetToModel(BudgetEntity e) => BudgetModel()
    ..uuid = e.uuid
    ..categoryId = e.categoryId
    ..monthYear = e.monthYear
    ..limitAmount = e.limitAmount
    ..spentAmount = e.spentAmount;
}
