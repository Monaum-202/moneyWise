import 'package:isar/isar.dart';

enum TransactionType {
  income,
  expense;

  @Index()
  int get indexValue => index;
}
