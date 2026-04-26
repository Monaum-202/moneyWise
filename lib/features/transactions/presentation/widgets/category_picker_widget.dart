import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/icon_helper.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';

class CategoryPickerWidget extends ConsumerWidget {

  const CategoryPickerWidget({
    required this.selectedCategoryId, required this.onSelected, super.key,
  });
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return categoriesAsync.when(
      data: (categories) => SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.uuid == selectedCategoryId;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(category.name),
                avatar: Icon(
                  IconHelper.getIcon(category.iconCodePoint),
                  size: 16,
                  color: isSelected ? Colors.white : Color(category.colorValue),
                ),
                selected: isSelected,
                onSelected: (_) => onSelected(category.uuid),
                selectedColor: Color(category.colorValue),
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 50),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
