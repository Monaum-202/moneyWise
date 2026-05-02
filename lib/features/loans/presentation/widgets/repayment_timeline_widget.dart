import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/widgets/empty_state_widget.dart';

class RepaymentTimelineWidget extends ConsumerWidget {

  const RepaymentTimelineWidget({
    required this.repayments, required this.totalLoan, super.key,
  });
  final List<RepaymentEntity> repayments;
  final double totalLoan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    if (repayments.isEmpty) {
      return const EmptyStateWidget(
        title: 'No repayments yet',
        subtitle: 'Add the first repayment below',
        icon: Icons.payments_outlined,
      );
    }

    final totalRepaid = repayments.fold(0.0, (sum, r) => sum + r.amount);
    final percentage = totalLoan > 0 ? (totalRepaid / totalLoan).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryBar(currencySymbol, totalRepaid, totalLoan, percentage, theme),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: repayments.length,
          itemBuilder: (context, index) {
            final repayment = repayments[index];
            final isLatest = index == 0;
            return _buildTimelineEntry(repayment, isLatest, theme, currencySymbol);
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBar(String currency, double repaid, double total, double percentage, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repaid: $currency${repaid.toStringAsFixed(0)} of $currency${total.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              color: const Color(0xFF1D9E75),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEntry(RepaymentEntity r, bool isLatest, ThemeData theme, String currency) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: isLatest ? 12 : 8,
              height: isLatest ? 12 : 8,
              decoration: const BoxDecoration(
                color: Color(0xFF1D9E75),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 50,
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$currency${r.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D9E75), fontSize: 15),
                  ),
                  if (isLatest) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9E75).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Latest', style: TextStyle(color: Color(0xFF1D9E75), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              Text(
                DateFormatter.format(r.date),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
              if (r.note != null && r.note!.isNotEmpty)
                Text(
                  r.note!,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
