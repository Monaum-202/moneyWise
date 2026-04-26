import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/categories/presentation/widgets/category_card_widget.dart';
import 'package:moneywise/features/categories/presentation/widgets/color_picker_widget.dart';
import 'package:moneywise/features/categories/presentation/widgets/icon_picker_widget.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

class AddCategorySheet extends ConsumerStatefulWidget {
  const AddCategorySheet({super.key, this.category});
  final CategoryEntity? category;

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  late String _name;
  late int _iconCode;
  late int _colorValue;
  late double _budget;
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.category?.name ?? '';
    _iconCode = widget.category?.iconCodePoint ?? Icons.category.codePoint;
    _colorValue = widget.category?.colorValue ?? Colors.blue.toARGB32();
    _budget = widget.category?.monthlyBudget ?? 0.0;
    _nameController.text = _name;
    if (_budget > 0) _budgetController.text = _budget.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            const SizedBox(height: 12),
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 140,
                child: CategoryCardWidget(
                  category: CategoryEntity(
                    uuid: '',
                    name: _name.isEmpty ? 'Category Name' : _name,
                    iconCodePoint: _iconCode,
                    colorValue: _colorValue,
                    isCustom: true,
                    isArchived: false,
                    monthlyBudget: _budget,
                    createdAt: DateTime.now(),
                  ),
                  spentThisMonth: 0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category Name', prefixIcon: Icon(Icons.edit_rounded)),
              onChanged: (v) => setState(() => _name = v),
            ),
            const SizedBox(height: 24),
            const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            IconPickerWidget(
              selectedIconCode: _iconCode,
              onSelected: (code) => setState(() => _iconCode = code),
            ),
            const SizedBox(height: 24),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ColorPickerWidget(
              selectedColorValue: _colorValue,
              onSelected: (val) => setState(() => _colorValue = val),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _budgetController,
              decoration: const InputDecoration(labelText: 'Monthly Budget Limit (optional)', prefixIcon: Icon(Icons.account_balance_wallet_rounded)),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _budget = double.tryParse(v) ?? 0.0),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _name.isEmpty ? null : () async {
                final entity = CategoryEntity(
                  uuid: widget.category?.uuid ?? const Uuid().v4(),
                  name: _name,
                  iconCodePoint: _iconCode,
                  colorValue: _colorValue,
                  isCustom: true,
                  isArchived: false,
                  monthlyBudget: _budget,
                  createdAt: widget.category?.createdAt ?? DateTime.now(),
                );
                
                if (widget.category == null) {
                  await ref.read(categoryRepositoryProvider).add(entity);
                } else {
                  await ref.read(categoryRepositoryProvider).update(entity);
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.category == null ? 'Category added ✓' : 'Category updated ✓')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
