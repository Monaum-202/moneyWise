import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/loans/domain/i_loan_repository.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/models/loan_summary.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

enum LoanFilter { all, gave, took, overdue, settled }

final loanFilterProvider = StateProvider<LoanFilter>((ref) => LoanFilter.all);

final loanListProvider = StreamProvider<List<LoanEntity>>((ref) {
  final filter = ref.watch(loanFilterProvider);
  final repo = ref.watch(loanRepositoryProvider);
  return switch (filter) {
    LoanFilter.gave => repo.watchAll(type: LoanType.gave),
    LoanFilter.took => repo.watchAll(type: LoanType.took),
    LoanFilter.settled => repo.watchAll(isPaid: true),
    LoanFilter.overdue => repo.watchAll(isPaid: false).map((list) => list
        .where((l) => l.dueDate != null && l.dueDate!.isBefore(DateTime.now()))
        .toList()),
    LoanFilter.all => repo.watchAll(),
  };
});

final loanSummaryProvider = StreamProvider<LoanSummary>((ref) {
  return ref.watch(loanRepositoryProvider).watchSummary();
});

// Loan form notifier
class LoanFormNotifier extends StateNotifier<LoanEntity?> {
  LoanFormNotifier(this._repo, this.ref) : super(null);
  final ILoanRepository _repo;
  final Ref ref;

  void initNew() => state = LoanEntity(
        uuid: const Uuid().v4(),
        personName: '',
        amount: 0,
        type: LoanType.gave,
        date: DateTime.now(),
        isPaid: false,
        repayments: [],
        createdAt: DateTime.now(),
      );
  void initEdit(LoanEntity l) => state = l;
  void updateName(String v) => state = state?.copyWith(personName: v);
  void updateAmount(double v) => state = state?.copyWith(amount: v);
  void updateType(LoanType v) => state = state?.copyWith(type: v);
  void updateDate(DateTime d) => state = state?.copyWith(date: d);
  void updateDueDate(DateTime? d) => state = state?.copyWith(dueDate: d);
  void updatePurpose(String v) => state = state?.copyWith(purpose: v);

  Future<bool> save() async {
    if (state == null) return false;
    try {
      final existing = await _repo.getById(state!.uuid);
      if (existing != null) {
        await _repo.update(state!);
      } else {
        await _repo.add(state!);
      }
      
      if (!state!.isPaid && state!.dueDate != null) {
        await ref.read(notificationServiceProvider).scheduleLoanDueReminder(state!);
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addRepayment(RepaymentEntity r) async {
    if (state == null) return false;
    try {
      await _repo.addRepayment(state!.uuid, r);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markSettled() async {
    if (state == null) return false;
    try {
      await _repo.markSettled(state!.uuid);
      await ref.read(notificationServiceProvider).cancelLoanReminder(state!.uuid);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final loanFormProvider = StateNotifierProvider.autoDispose<LoanFormNotifier, LoanEntity?>(
  (ref) => LoanFormNotifier(ref.watch(loanRepositoryProvider), ref),
);
