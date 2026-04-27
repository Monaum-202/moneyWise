import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/icon_helper.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/models/category_total.dart';

class TopCategoriesWidget extends ConsumerWidget {
  const TopCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(categoryTotalsProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    return totalsAsync.when(
      data: (totals) {
        if (totals.isEmpty) return const SizedBox.shrink();
        
        final sortedTotals = List<CategoryTotal>.from(totals)
          ..sort((a, b) => b.total.compareTo(a.total));
        final top3 = sortedTotals.take(3).toList();
        final maxTotal = top3.first.total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Top Spending',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ...top3.map((t) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(t.colorValue).withValues(alpha: 0.2),
                    child: Icon(
                      IconHelper.getIcon(t.iconCodePoint),
                      color: Color(t.colorValue),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t.categoryName, style: const TextStyle(fontWeight: FontWeight.w500)),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(text: '$currencySymbol ', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                  TextSpan(text: t.total.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: t.total / maxTotal,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: Color(t.colorValue),
                            minHeight: 8,
                          ).animate().scaleX(begin: 0, duration: 800.ms, curve: Curves.easeOut),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
