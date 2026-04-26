import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/loans/presentation/widgets/overdue_badge_widget.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/enums/loan_type.dart';

class LoanCardWidget extends ConsumerWidget {

  const LoanCardWidget({
    required this.loan, required this.onTap, super.key,
  });
  final LoanEntity loan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currency = settings?.currency ?? '৳';
    final theme = Theme.of(context);

    final totalRepaid = loan.repayments.fold(0.0, (sum, r) => sum + r.amount);
    final progress = loan.amount > 0 ? (totalRepaid / loan.amount).clamp(0.0, 1.0) : 0.0;
    
    final initials = loan.personName.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    final avatarColor = Color(loan.personName.hashCode | 0xFF000000);

    return Hero(
      tag: 'loan_hero_${loan.uuid}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: avatarColor.withValues(alpha: 0.2),
                      child: Text(
                        initials,
                        style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.personName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (loan.purpose != null && loan.purpose!.isNotEmpty)
                            Text(
                              loan.purpose!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          const SizedBox(height: 4),
                          _buildStatusRow(theme),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currency${loan.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        _buildTypeBadge(),
                      ],
                    ),
                  ],
                ),
                if (loan.repayments.isNotEmpty && !loan.isPaid) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: const Color(0xFF1D9E75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(ThemeData theme) {
    if (loan.isPaid) {
      return const OverdueBadgeWidget(
        label: 'Settled ✓',
        bg: Color(0xFFE8F5E9),
        text: Color(0xFF1D9E75),
      );
    }

    if (loan.dueDate == null) {
      return Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            DateFormatter.format(loan.date),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final difference = loan.dueDate!.difference(now).inDays;

    if (difference < 0) {
      return const OverdueBadgeWidget(
        label: 'Overdue',
        bg: Color(0xFFFFEBEE),
        text: Color(0xFFE05C5C),
      );
    } else if (difference <= 3) {
      return const OverdueBadgeWidget(
        label: 'Due soon',
        bg: Color(0xFFFFF3E0),
        text: Colors.orange,
      );
    }

    return Row(
      children: [
        const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          DateFormatter.format(loan.dueDate!),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTypeBadge() {
    final isGave = loan.type == LoanType.gave;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isGave ? const Color(0xFF1D9E75).withValues(alpha: 0.1) : const Color(0xFFE05C5C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isGave ? 'I Gave' : 'I Took',
        style: TextStyle(
          color: isGave ? const Color(0xFF1D9E75) : const Color(0xFFE05C5C),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
