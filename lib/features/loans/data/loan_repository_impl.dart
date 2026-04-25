import 'package:isar/isar.dart';
import 'package:moneywise/features/loans/domain/i_loan_repository.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/loan_summary.dart';

class LoanRepositoryImpl implements ILoanRepository {

  LoanRepositoryImpl(this.isar);
  final Isar isar;

  @override
  Stream<List<LoanEntity>> watchAll({LoanType? type, bool? isPaid}) {
    return isar.loanModels
        .where()
        .filter()
        .optional(type != null, (q) => q.typeEqualTo(type!))
        .and()
        .optional(isPaid != null, (q) => q.isPaidEqualTo(isPaid!))
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<LoanEntity?> getById(String uuid) async {
    final model = await isar.loanModels.where().uuidEqualTo(uuid).findFirst();
    return model != null ? _toEntity(model) : null;
  }

  @override
  Future<void> add(LoanEntity entity) async {
    final model = _toModel(entity);
    await isar.writeTxn(() => isar.loanModels.put(model));
  }

  @override
  Future<void> update(LoanEntity entity) async {
    await isar.writeTxn(() async {
      final model = await isar.loanModels.where().uuidEqualTo(entity.uuid).findFirst();
      if (model != null) {
        final updatedModel = _toModel(entity)..id = model.id;
        await isar.loanModels.put(updatedModel);
      }
    });
  }

  @override
  Future<void> delete(String uuid) async {
    await isar.writeTxn(() async {
      final model = await isar.loanModels.where().uuidEqualTo(uuid).findFirst();
      if (model != null) {
        await isar.loanModels.delete(model.id);
      }
    });
  }

  @override
  Future<void> addRepayment(String loanUuid, RepaymentEntity repayment) async {
    await isar.writeTxn(() async {
      final loan = await isar.loanModels.where().uuidEqualTo(loanUuid).findFirst();
      if (loan != null) {
        final rModel = RepaymentModel()
          ..id = repayment.id
          ..amount = repayment.amount
          ..date = repayment.date
          ..note = repayment.note;
        
        loan.repayments = [...loan.repayments, rModel];
        await isar.loanModels.put(loan);
      }
    });
  }

  @override
  Future<void> markSettled(String loanUuid) async {
    await isar.writeTxn(() async {
      final loan = await isar.loanModels.where().uuidEqualTo(loanUuid).findFirst();
      if (loan != null) {
        loan
          ..isPaid = true
          ..paidAt = DateTime.now();
        await isar.loanModels.put(loan);
      }
    });
  }

  @override
  Future<List<LoanEntity>> getOverdue() async {
    final now = DateTime.now();
    final models = await isar.loanModels
        .where()
        .filter()
        .isPaidEqualTo(false)
        .and()
        .dueDateLessThan(now)
        .findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<LoanSummary> getSummary() async {
    final loans = await isar.loanModels.where().findAll();
    final now = DateTime.now();

    double totalGave = 0;
    double totalTook = 0;
    double totalOverdue = 0;
    var overdueCount = 0;

    for (final loan in loans) {
      final repaid = loan.repayments.fold(0.0, (sum, r) => sum + r.amount);
      final remaining = loan.amount - repaid;

      if (loan.type == LoanType.gave) {
        totalGave += remaining;
      } else {
        totalTook += remaining;
      }

      if (!loan.isPaid && loan.dueDate != null && loan.dueDate!.isBefore(now)) {
        totalOverdue += remaining;
        overdueCount++;
      }
    }

    return LoanSummary(
      totalGave: totalGave,
      totalTook: totalTook,
      totalOverdue: totalOverdue,
      overdueCount: overdueCount,
    );
  }

  LoanEntity _toEntity(LoanModel model) {
    return LoanEntity(
      uuid: model.uuid,
      personName: model.personName,
      amount: model.amount,
      type: model.type,
      date: model.date,
      dueDate: model.dueDate,
      purpose: model.purpose,
      isPaid: model.isPaid,
      paidAt: model.paidAt,
      createdAt: model.createdAt,
      repayments: model.repayments.map((r) => RepaymentEntity(
        id: r.id,
        amount: r.amount,
        date: r.date,
        note: r.note,
      )).toList(),
    );
  }

  LoanModel _toModel(LoanEntity entity) {
    return LoanModel()
      ..uuid = entity.uuid
      ..personName = entity.personName
      ..amount = entity.amount
      ..type = entity.type
      ..date = entity.date
      ..dueDate = entity.dueDate
      ..purpose = entity.purpose
      ..isPaid = entity.isPaid
      ..paidAt = entity.paidAt
      ..createdAt = entity.createdAt
      ..repayments = entity.repayments.map((r) => RepaymentModel()
        ..id = r.id
        ..amount = r.amount
        ..date = r.date
        ..note = r.note
      ).toList();
  }
}
