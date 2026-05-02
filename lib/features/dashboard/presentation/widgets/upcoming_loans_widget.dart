import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class UpcomingLoansWidget extends ConsumerWidget {
  const UpcomingLoansWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanListAsync = ref.watch(loanListProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    return loanListAsync.when(
      data: (loans) {
        final upcoming = loans.where((l) => !l.isPaid && l.dueDate != null).toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
        
        if (upcoming.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Due Soon',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: upcoming.length > 3 ? 3 : upcoming.length,
                itemBuilder: (context, index) {
                  final loan = upcoming[index];
                  final isOverdue = loan.dueDate!.isBefore(DateTime.now());
                  
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOverdue ? theme.colorScheme.error.withValues(alpha: 0.3) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(loan.personName[0].toUpperCase()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loan.personName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormatter.formatDayMonth(loan.dueDate!),
                                style: TextStyle(
                                  color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                '$currencySymbol${loan.amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
