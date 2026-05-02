import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/budget/presentation/providers/budget_providers.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/transactions/domain/i_transaction_repository.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_filter.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/models/category_total.dart';
import 'package:moneywise/shared/models/transaction_summary.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

// Active filter state
final transactionFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter.thisMonth();
});

// Filtered transaction stream
final transactionListProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchAll(
    from: filter.from,
    to: filter.to,
    categoryId: filter.categoryId,
    type: filter.type,
  );
});

// Monthly summary for dashboard
final monthlySummaryProvider = StreamProvider<TransactionSummary>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month);
  final to = DateTime(now.year, now.month + 1, 0);
  return repo.watchSummary(from, to);
});

// Total balance across all time
final totalBalanceProvider = StreamProvider<double>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchSummary(DateTime(2000), DateTime(2100)).map((s) => s.netBalance);
});

// Category totals for charts
final categoryTotalsProvider = StreamProvider<List<CategoryTotal>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final now = DateTime.now();
  final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  return repo.watchCategoryTotals(monthYear);
});

// Transaction form notifier
class TransactionFormNotifier extends StateNotifier<TransactionEntity?> {
  TransactionFormNotifier(this._repo, this.ref) : super(null);
  final ITransactionRepository _repo;
  final Ref ref;

  void initNew() => state = TransactionEntity(
        uuid: const Uuid().v4(),
        title: '',
        amount: 0,
        type: TransactionType.expense,
        categoryId: '',
        date: DateTime.now(),
        isRecurring: false,
        recurringType: RecurringType.none,
        createdAt: DateTime.now(),
      );

  void initEdit(TransactionEntity t) {
    if (t.isRecurring && t.recurringType == RecurringType.none) {
      state = t.copyWith(recurringType: RecurringType.daily);
    } else {
      state = t;
    }
  }
  void updateTitle(String v) => state = state?.copyWith(title: v);
  void updateAmount(double v) => state = state?.copyWith(amount: v);
  void updateType(TransactionType v) => state = state?.copyWith(type: v);
  void updateCategory(String id) => state = state?.copyWith(categoryId: id);
  void updateDate(DateTime d) => state = state?.copyWith(date: d);
  void updateNote(String v) => state = state?.copyWith(note: v);
  void updateRecurring(bool v) {
    if (state == null) return;
    state = state!.copyWith(
      isRecurring: v,
      recurringType: v 
          ? (state!.recurringType == RecurringType.none ? RecurringType.daily : state!.recurringType)
          : RecurringType.none,
    );
  }

  void updateRecurringType(RecurringType v) => state = state?.copyWith(recurringType: v);

  Future<bool> save() async {
    if (state == null) return false;
    try {
      final existing = await _repo.getById(state!.uuid);
      if (existing != null) {
        await _repo.update(state!);
      } else {
        await _repo.add(state!);
      }
      
      if (state!.type == TransactionType.expense) {
        await _checkBudgetAlerts();
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkBudgetAlerts() async {
    final monthYear = ref.read(currentMonthYearProvider);
    final categoryMap = ref.read(categoryMapProvider);
    final category = categoryMap[state!.categoryId];
    
    if (category != null) {
      final totals = await ref.read(categoryTotalsProvider.future);
      final spent = totals.firstWhere(
        (t) => t.categoryId == category.uuid, 
        orElse: () => const CategoryTotal(categoryId: '', categoryName: '', total: 0, colorValue: 0, iconCodePoint: 0)
      ).total;
      
      await ref.read(budgetAlertServiceProvider).checkAndTriggerAlert(
        category: category,
        monthYear: monthYear,
        spent: spent,
      );
    }
  }

  Future<bool> delete(String uuid) async {
    try {
      await _repo.delete(uuid);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final transactionFormProvider = StateNotifierProvider.autoDispose<TransactionFormNotifier, TransactionEntity?>(
  (ref) => TransactionFormNotifier(ref.watch(transactionRepositoryProvider), ref),
);
