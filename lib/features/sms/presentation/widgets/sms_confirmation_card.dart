import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/services/sms_parser.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';

class SmsConfirmationCard extends ConsumerStatefulWidget {
  final ParsedSmsTransaction parsed;
  final VoidCallback onDismiss;
  final void Function(String categoryId) onConfirm;

  const SmsConfirmationCard({
    super.key,
    required this.parsed,
    required this.onDismiss,
    required this.onConfirm,
  });

  @override
  ConsumerState<SmsConfirmationCard> createState() => _SmsConfirmationCardState();
}

class _SmsConfirmationCardState extends ConsumerState<SmsConfirmationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  String? _selectedCategoryId;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );

    _progressController.forward().then((_) {
      if (mounted && !_isDismissed) {
        _handleDismiss();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    setState(() => _isDismissed = true);
    widget.onDismiss();
  }

  Color _getBankColor(String bankName) {
    final name = bankName.toLowerCase();
    if (name.contains('bkash')) return Colors.pink;
    if (name.contains('nagad')) return Colors.orange;
    if (name.contains('rocket')) return Colors.purple;
    if (name.contains('dbbl')) return Colors.blue;
    if (name.contains('islami') || name.contains('ibbl')) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.uuid;
    }

    final theme = Theme.of(context);
    final isIncome = widget.parsed.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;

    return Animate(
      effects: _isDismissed
          ? [const SlideEffect(begin: Offset(0, 0), end: Offset(0, -1.5)), const FadeEffect(begin: 1, end: 0)]
          : [const SlideEffect(begin: Offset(0, -1.5), end: Offset(0, 0)), const FadeEffect(begin: 0, end: 1)],
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getBankColor(widget.parsed.bankName),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.parsed.bankName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        'Detected from SMS',
                        style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: amountColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '৳${widget.parsed.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                  if (widget.parsed.balance != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Balance after: ৳${widget.parsed.balance}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),
                  if (widget.parsed.counterParty != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        '${isIncome ? "From" : "To"}: ${widget.parsed.counterParty}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = _selectedCategoryId == cat.uuid;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategoryId = cat.uuid);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedCategoryId == null
                              ? null
                              : () => widget.onConfirm(_selectedCategoryId!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('✓ Add Transaction'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _handleDismiss,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: 1.0 - _progressController.value,
                  minHeight: 4,
                  backgroundColor: theme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary.withValues(alpha: 0.5)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
