import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moneywise/features/transactions/data/transaction_repository_impl.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';

class MockIsar extends Mock implements Isar {}
class MockIsarCollection extends Mock implements IsarCollection<Transaction> {}

void main() {
  late TransactionRepositoryImpl repository;
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = TransactionRepositoryImpl(mockIsar);

    // Mocking Isar collection access
    when(() => mockIsar.transactions).thenReturn(mockCollection);
  });

  group('TransactionRepository Tests', () {
    test('add transaction calls put on collection', () async {
      final transaction = Transaction()
        ..uuid = 'test-uuid'
        ..title = 'Lunch'
        ..amount = 15.0
        ..type = TransactionType.expense
        ..categoryId = 'cat-1'
        ..date = DateTime.now()
        ..isRecurring = false
        ..recurringType = RecurringType.none
        ..createdAt = DateTime.now();

      when(() => mockIsar.writeTxn(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as Future<dynamic> Function();
        return callback();
      });
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.add(transaction);

      verify(() => mockCollection.put(transaction)).called(1);
    });
  });
}
