import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_categories_seeder.g.dart';

@riverpod
Future<void> categorySeeder(CategorySeederRef ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  await repository.seedDefaults();
}
