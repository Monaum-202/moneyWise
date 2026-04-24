import 'package:moneywise/shared/models/category_model.dart';

abstract interface class ICategoryRepository {
  Stream<List<Category>> watchAll();
  Future<List<Category>> getAll();
  Future<void> add(Category category);
  Future<void> update(Category category);
  Future<void> delete(int id);
}
