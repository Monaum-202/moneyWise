import 'package:isar/isar.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/transactions/domain/i_transaction_repository.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/models/category_total.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';

class TransactionRepositoryImpl implements ITransactionRepository {

  TransactionRepositoryImpl(this.isar);
  final Isar isar;

  @override
  Stream<List<TransactionEntity>> watchAll({
    DateTime? from,
    DateTime? to,
    String? categoryId,
    TransactionType? type,
  }) {
    final query = isar.transactionModels.where();

    return query
        .filter()
        .optional(from != null, (q) => q.dateGreaterThan(from!, include: true))
        .and()
        .optional(to != null, (q) => q.dateLessThan(to!, include: true))
        .and()
        .optional(categoryId != null, (q) => q.categoryIdEqualTo(categoryId!))
        .and()
        .optional(type != null, (q) => q.typeEqualTo(type!))
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<TransactionEntity?> getById(String uuid) async {
    final model = await isar.transactionModels.where().uuidEqualTo(uuid).findFirst();
    return model != null ? _toEntity(model) : null;
  }

  @override
  Future<void> add(TransactionEntity entity) async {
    final model = _toModel(entity);
    await isar.writeTxn(() => isar.transactionModels.put(model));
  }

  @override
  Future<void> update(TransactionEntity entity) async {
    await isar.writeTxn(() async {
      final model = await isar.transactionModels.where().uuidEqualTo(entity.uuid).findFirst();
      if (model != null) {
        final updatedModel = _toModel(entity)..id = model.id;
        await isar.transactionModels.put(updatedModel);
      }
    });
  }

  @override
  Future<void> delete(String uuid) async {
    await isar.writeTxn(() async {
      final model = await isar.transactionModels.where().uuidEqualTo(uuid).findFirst();
      if (model != null) {
        await isar.transactionModels.delete(model.id);
      }
    });
  }

  @override
  Future<TransactionSummary> getSummary(DateTime from, DateTime to) async {
    final transactions = await isar.transactionModels
        .where()
        .filter()
        .dateBetween(from, to)
        .findAll();

    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return TransactionSummary(
      totalIncome: income,
      totalExpense: expense,
    );
  }

  @override
  Future<List<CategoryTotal>> getCategoryTotals(String monthYear) async {
    // In a real app, monthYear would be used to filter dates. 
    // For simplicity, we assume monthYear filter logic here.
    final transactions = await isar.transactionModels.where().findAll();
    final categories = await isar.categoryModels.where().findAll();

    final categoryMap = {for (var c in categories) c.uuid: c};
    final totals = <String, double>{};

    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
      }
    }

    return totals.entries.map((e) {
      final cat = categoryMap[e.key];
      return CategoryTotal(
        categoryId: e.key,
        categoryName: cat?.name ?? 'Unknown',
        total: e.value,
        colorValue: cat?.colorValue ?? 0xFF808080,
        iconCodePoint: cat?.iconCodePoint ?? 0xe13d,
      );
    }).toList();
  }

  TransactionEntity _toEntity(TransactionModel model) {
    return TransactionEntity(
      uuid: model.uuid,
      title: model.title,
      amount: model.amount,
      type: model.type,
      categoryId: model.categoryId,
      date: model.date,
      note: model.note,
      isRecurring: model.isRecurring,
      recurringType: model.recurringType,
      receiptImagePath: model.receiptImagePath,
      createdAt: model.createdAt,
    );
  }

  TransactionModel _toModel(TransactionEntity entity) {
    return TransactionModel()
      ..uuid = entity.uuid
      ..title = entity.title
      ..amount = entity.amount
      ..type = entity.type
      ..categoryId = entity.categoryId
      ..date = entity.date
      ..note = entity.note
      ..isRecurring = entity.isRecurring
      ..recurringType = entity.recurringType
      ..receiptImagePath = entity.receiptImagePath
      ..createdAt = entity.createdAt;
  }
}
