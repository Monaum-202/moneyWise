import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/date_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/loans/presentation/screens/add_loan_sheet.dart';
import 'package:moneywise/features/loans/presentation/screens/add_repayment_sheet.dart';
import 'package:moneywise/features/loans/presentation/widgets/overdue_badge_widget.dart';
import 'package:moneywise/features/loans/presentation/widgets/repayment_timeline_widget.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/enums/loan_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:share_plus/share_plus.dart';

class LoanDetailScreen extends ConsumerStatefulWidget {
  const LoanDetailScreen({required this.uuid, super.key});
  final String uuid;

  @override
  ConsumerState<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends ConsumerState<LoanDetailScreen> {
  bool _showConfetti = false;

  void _triggerConfetti() {
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loanListAsync = ref.watch(loanListProvider);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).valueOrNull;

    return loanListAsync.when(
      data: (loans) {
        final loan = loans.cast<LoanEntity?>().firstWhere(
              (l) => l?.uuid == widget.uuid,
              orElse: () => null,
            );

        if (loan == null) return const Scaffold(body: Center(child: Text('Loan not found')));

        final totalRepaid = loan.repayments.fold(0.0, (sum, r) => sum + r.amount);
        final remaining = loan.amount - totalRepaid;
        final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        loan.personName,
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                      ),
                      background: Hero(
                        tag: 'loan_hero_${loan.uuid}',
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => AddLoanSheet(initialLoan: loan),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {
                          final text = "Loan to ${loan.personName}: $currencySymbol${loan.amount.toStringAsFixed(0)} | "
                              "Due: ${loan.dueDate != null ? DateFormatter.format(loan.dueDate!) : 'N/A'} | "
                              "Repaid: $currencySymbol${totalRepaid.toStringAsFixed(0)} ($currencySymbol${remaining.toStringAsFixed(0)} remaining)";
                          Share.share(text);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => _showDeleteDialog(context, loan.uuid),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(loan, remaining, currencySymbol, theme),
                          const SizedBox(height: 32),
                          const Text(
                            'Repayment History',
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          RepaymentTimelineWidget(repayments: loan.repayments, totalLoan: loan.amount),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!loan.isPaid)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showSettleDialog(context, loan),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Mark Settled', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(loanFormProvider.notifier).initEdit(loan);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => AddRepaymentSheet(
                                  loanUuid: loan.uuid,
                                  totalLoan: loan.amount,
                                  alreadyRepaid: totalRepaid,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Add Repayment', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_showConfetti) _buildConfettiOverlay(),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildSummaryCard(LoanEntity loan, double remaining, String symbol, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance Remaining', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$symbol ',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: remaining.toStringAsFixed(0),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              fontFamily: 'Poppins',
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(loan),
              ],
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Total Amount', '$symbol${loan.amount.toStringAsFixed(0)}'),
                _buildInfoItem('Loan Type', loan.type == LoanType.gave ? 'I Gave' : 'I Took'),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Date', DateFormatter.format(loan.date)),
                _buildInfoItem('Due Date', loan.dueDate != null ? DateFormatter.format(loan.dueDate!) : 'None'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusBadge(LoanEntity loan) {
    if (loan.isPaid) {
      return const OverdueBadgeWidget(label: 'Settled ✓', bg: Color(0xFFE8F5E9), text: Color(0xFF1D9E75));
    }
    if (loan.dueDate == null) return const SizedBox.shrink();
    
    final difference = loan.dueDate!.difference(DateTime.now()).inDays;
    if (difference < 0) {
      return const OverdueBadgeWidget(label: 'Overdue', bg: Color(0xFFFFEBEE), text: Color(0xFFE05C5C));
    }
    return const SizedBox.shrink();
  }

  Widget _buildConfettiOverlay() {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: List.generate(20, (i) => AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: Colors.primaries[i % Colors.primaries.length],
            shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
          ),
        )),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String uuid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan?'),
        content: const Text('This will permanently remove this loan and all its repayments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(loanRepositoryProvider).delete(uuid);
              if (context.mounted) {
                Navigator.pop(context);
                context.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSettleDialog(BuildContext context, LoanEntity loan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settle Loan?'),
        content: const Text('Mark this loan as fully settled? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              ref.read(loanFormProvider.notifier).initEdit(loan);
              await ref.read(loanFormProvider.notifier).markSettled();
              if (context.mounted) {
                Navigator.pop(context);
                _triggerConfetti();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
