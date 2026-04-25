import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';

final categoryListProvider = StreamProvider<List<CategoryEntity>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

// Map of categoryId → CategoryEntity for quick lookup in UI
final categoryMapProvider = Provider<Map<String, CategoryEntity>>((ref) {
  final cats = ref.watch(categoryListProvider).valueOrNull ?? [];
  return {for (final c in cats) c.uuid: c};
});

// Called once at app startup from main.dart
final categorySeederProvider = FutureProvider<void>((ref) async {
  await ref.watch(categoryRepositoryProvider).seedDefaults();
});
