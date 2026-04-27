import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class AmountInputWidget extends ConsumerStatefulWidget {

  const AmountInputWidget({
    required this.initialValue, required this.onChanged, super.key,
  });
  final double initialValue;
  final ValueChanged<double> onChanged;

  @override
  ConsumerState<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends ConsumerState<AmountInputWidget> {
  late String _amountString;

  @override
  void initState() {
    super.initState();
    _amountString = widget.initialValue == 0 ? '' : widget.initialValue.toStringAsFixed(0);
  }

  @override
  void didUpdateWidget(covariant AmountInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue == 0) {
      setState(() {
        _amountString = '';
      });
    }
  }

  void _onKeyPress(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (value == 'back') {
        if (_amountString.isNotEmpty) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        }
      } else if (value == '.') {
        if (!_amountString.contains('.')) {
          _amountString += _amountString.isEmpty ? '0.' : '.';
        }
      } else {
        _amountString += value;
      }
      widget.onChanged(double.tryParse(_amountString) ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencyCode = settings?.currency ?? 'BDT';
    final currencySymbol = CurrencyFormatter.getSymbol(currencyCode);
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              currencySymbol,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _amountString.isEmpty ? '0' : _amountString,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          children: [
            ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'].map((key) {
              return InkWell(
                onTap: () => _onKeyPress(key),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: key == 'back'
                      ? const Icon(Icons.backspace_outlined)
                      : Text(
                          key,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
