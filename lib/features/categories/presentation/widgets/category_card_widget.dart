import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/icon_helper.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class CategoryCardWidget extends ConsumerWidget {

  const CategoryCardWidget({
    required this.category, required this.spentThisMonth, super.key,
    this.onLongPress,
    this.onTap,
  });
  final CategoryEntity category;
  final double spentThisMonth;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.currency ?? '৳';
    
    final budget = category.monthlyBudget;
    final progress = budget > 0 ? (spentThisMonth / budget).clamp(0.0, 1.0) : 0.0;
    
    Color progressColor = Colors.green;
    if (progress >= 0.9) {
      progressColor = Colors.red;
    } else if (progress >= 0.7) {
      progressColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (budget > 0)
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        color: progressColor,
                      ),
                    ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(category.colorValue),
                    child: Icon(
                      IconHelper.getIcon(category.iconCodePoint),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 4),
              Text(
                '$currency${spentThisMonth.toStringAsFixed(0)}',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
