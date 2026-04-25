import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/transactions/data/transaction_repository_impl.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';

class MockIsar extends Mock implements Isar {}
class MockTransactionCollection extends Mock implements IsarCollection<TransactionModel> {}
class MockLoanCollection extends Mock implements IsarCollection<LoanModel> {}
class MockCategoryCollection extends Mock implements IsarCollection<CategoryModel> {}

void main() {
  late TransactionRepositoryImpl transactionRepository;
  late MockIsar mockIsar;
  late MockTransactionCollection mockTransactionCollection;
  late MockLoanCollection mockLoanCollection;
  late MockCategoryCollection mockCategoryCollection;

  setUpAll(() {
    registerFallbackValue(TransactionModel());
    registerFallbackValue(LoanModel());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockTransactionCollection = MockTransactionCollection();
    mockLoanCollection = MockLoanCollection();
    mockCategoryCollection = MockCategoryCollection();

    transactionRepository = TransactionRepositoryImpl(mockIsar);

    when(() => mockIsar.collection<TransactionModel>()).thenReturn(mockTransactionCollection);
    when(() => mockIsar.collection<LoanModel>()).thenReturn(mockLoanCollection);
    when(() => mockIsar.collection<CategoryModel>()).thenReturn(mockCategoryCollection);
  });

  group('TransactionRepository', () {
    final testEntity = TransactionEntity(
      uuid: 'test-uuid',
      title: 'Lunch',
      amount: 15.0,
      type: TransactionType.expense,
      categoryId: 'cat-1',
      date: DateTime(2024),
      isRecurring: false,
      recurringType: RecurringType.none,
      createdAt: DateTime(2024),
    );

    test('add calls put on collection inside txn', () async {
      when(() => mockIsar.writeTxn<int>(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as Future<int> Function();
        return await callback();
      });
      when(() => mockTransactionCollection.put(any())).thenAnswer((_) async => 1);

      await transactionRepository.add(testEntity);

      verify(() => mockTransactionCollection.put(any())).called(1);
    });
  });
}
