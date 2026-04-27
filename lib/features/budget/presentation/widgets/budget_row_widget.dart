import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/icon_helper.dart';
import 'package:moneywise/features/budget/presentation/providers/budget_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';

class BudgetRowWidget extends ConsumerStatefulWidget {
  const BudgetRowWidget({
    required this.data,
    super.key,
  });
  final CategoryBudget data;

  @override
  ConsumerState<BudgetRowWidget> createState() => _BudgetRowWidgetState();
}

class _BudgetRowWidgetState extends ConsumerState<BudgetRowWidget> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.data.limitAmount > 0 ? widget.data.limitAmount.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveLimit() async {
    final limit = double.tryParse(_controller.text) ?? 0.0;
    final monthYear = ref.read(currentMonthYearProvider);
    await ref.read(budgetRepositoryProvider).setLimit(
          widget.data.category.uuid,
          monthYear,
          limit,
        );
    if (mounted) setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');

    final category = widget.data.category;
    final progress = widget.data.percentage;

    Color progressColor = Colors.green;
    if (progress >= 0.9) {
      progressColor = Colors.red;
    } else if (progress >= 0.7) {
      progressColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(category.colorValue).withValues(alpha: 0.1),
                  child: Icon(
                    IconHelper.getIcon(category.iconCodePoint),
                    color: Color(category.colorValue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall,
                          children: [
                            TextSpan(text: currencySymbol, style: const TextStyle(fontSize: 10)),
                            TextSpan(text: widget.data.spentAmount.toStringAsFixed(0)),
                            const TextSpan(text: ' spent of '),
                            if (widget.data.limitAmount > 0) ...[
                              TextSpan(text: currencySymbol, style: const TextStyle(fontSize: 10)),
                              TextSpan(text: widget.data.limitAmount.toStringAsFixed(0)),
                            ] else
                              const TextSpan(text: 'no limit'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isEditing)
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check, size: 20),
                          onPressed: _saveLimit,
                        ),
                      ),
                      onSubmitted: (_) => _saveLimit(),
                    ),
                  )
                else if (widget.data.limitAmount > 0)
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(color: progressColor, fontWeight: FontWeight.bold),
                  )
                else
                  OutlinedButton(
                    onPressed: () => setState(() => _isEditing = true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Set limit', style: TextStyle(fontSize: 12)),
                  ),
                if (!_isEditing && widget.data.limitAmount > 0)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
              ],
            ),
            if (widget.data.limitAmount > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: progressColor,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
