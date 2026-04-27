import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<int> _pin = [];
  final List<int> _confirmPin = [];
  bool _isConfirming = false;

  void _onKeyTap(int digit) {
    if (!_isConfirming) {
      if (_pin.length < 4) {
        setState(() => _pin.add(digit));
        if (_pin.length == 4) setState(() => _isConfirming = true);
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin.add(digit));
        if (_confirmPin.length == 4) _verifyAndSave();
      }
    }
  }

  Future<void> _verifyAndSave() async {
    if (_pin.join() == _confirmPin.join()) {
      final pinString = _pin.join();
      final bytes = utf8.encode(pinString);
      final hash = sha256.convert(bytes).toString();
      
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: 'user_pin_hash', value: hash);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN saved successfully ✓')));
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PINs do not match. Try again.')));
      setState(() {
        _pin.clear();
        _confirmPin.clear();
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      appBar: AppBar(title: const Text('Setup PIN')),
      body: Column(
        children: [
          const Spacer(),
          Text(
            _isConfirming ? 'Confirm your 4-digit PIN' : 'Enter a 4-digit PIN',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: i < displayPin.length ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            )),
          ),
          const Spacer(),
          _buildKeypad(theme),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      children: [
        for (var i = 1; i <= 9; i++) _buildKey(i, theme),
        const SizedBox.shrink(),
        _buildKey(0, theme),
        IconButton(
          onPressed: () => setState(() {
            if (_isConfirming) {
              if (_confirmPin.isNotEmpty) {
                _confirmPin.removeLast();
              } else {
                _isConfirming = false;
              }
            } else {
              if (_pin.isNotEmpty) _pin.removeLast();
            }
          }),
          icon: const Icon(Icons.backspace_outlined),
        ),
      ],
    );
  }

  Widget _buildKey(int digit, ThemeData theme) {
    return InkWell(
      onTap: () => _onKeyTap(digit),
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: Text(
          digit.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
