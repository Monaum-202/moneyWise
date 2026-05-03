import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/categories/presentation/screens/add_category_sheet.dart';
import 'package:moneywise/features/categories/presentation/widgets/category_card_widget.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:moneywise/shared/widgets/empty_state_widget.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final categoryListAsync = ref.watch(categoryListProvider);
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
            onPressed: () => setState(() => _showArchived = !_showArchived),
            tooltip: _showArchived ? 'Hide Archived' : 'Show Archived',
          ),
        ],
      ),
      body: categoryListAsync.when(
        data: (categories) {
          final filtered = categories.where((c) => _showArchived || !c.isArchived).toList();
          
          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              title: 'No categories',
              subtitle: 'Create a category to start organizing your finances.',
              icon: Icons.category_rounded,
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final category = filtered[index];

              return CategoryCardWidget(
                category: category,
                spentThisMonth: categoryTotalsAsync.maybeWhen(
                  data: (totals) {
                    return totals.where((t) => t.categoryId == category.uuid).firstOrNull?.total ?? 0.0;
                  },
                  orElse: () => 0.0,
                ),
                onTap: () {
                  ref.read(transactionFilterProvider.notifier).state = 
                    ref.read(transactionFilterProvider).copyWith(categoryId: category.uuid);
                  context.push('/transactions');
                },
                onLongPress: () => _showCategoryOptions(context, category),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddCategorySheet(),
          );
        },
        label: const Text('Add Category'),
        icon: const Icon(Icons.add_rounded),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, CategoryEntity category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AddCategorySheet(category: category),
              );
            },
          ),
          ListTile(
            leading: Icon(category.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
            title: Text(category.isArchived ? 'Unarchive' : 'Archive'),
            onTap: () async {
              final repo = ref.read(categoryRepositoryProvider);
              if (category.isArchived) {
                await repo.update(category.copyWith(isArchived: false));
              } else {
                await repo.archive(category.uuid);
              }
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
