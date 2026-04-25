import 'package:moneywise/features/categories/domain/category_model.dart';

abstract interface class ICategoryRepository {
  Stream<List<CategoryEntity>> watchAll({bool includeArchived = false});
  Future<void> add(CategoryEntity category);
  Future<void> update(CategoryEntity category);
  Future<void> archive(String uuid);
  Future<void> seedDefaults();
}
