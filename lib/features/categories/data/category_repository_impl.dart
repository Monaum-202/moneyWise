import 'package:isar/isar.dart';
import 'package:moneywise/features/categories/domain/i_category_repository.dart';
import 'package:moneywise/shared/models/category_model.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final Isar isar;

  CategoryRepositoryImpl(this.isar);

  @override
  Stream<List<Category>> watchAll() {
    return isar.categorys.where().watch(fireImmediately: true);
  }

  @override
  Future<List<Category>> getAll() {
    return isar.categorys.where().findAll();
  }

  @override
  Future<void> add(Category category) {
    return isar.writeTxn(() => isar.categorys.put(category));
  }

  @override
  Future<void> update(Category category) {
    return isar.writeTxn(() => isar.categorys.put(category));
  }

  @override
  Future<void> delete(int id) {
    return isar.writeTxn(() => isar.categorys.delete(id));
  }
}
