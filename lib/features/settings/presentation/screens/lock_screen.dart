import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  int _failedAttempts = 0;
  bool _showPinFallback = false;
  final List<int> _pin = [];

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock Moneywise',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      if (didAuthenticate) {
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _failedAttempts++;
          if (_failedAttempts >= 3) _showPinFallback = true;
        });
      }
    } catch (e) {
      setState(() => _showPinFallback = true);
    }
  }

  void _onPinKeyTap(int digit) {
    if (_pin.length < 4) {
      setState(() => _pin.add(digit));
      if (_pin.length == 4) _verifyPin();
    }
  }

  Future<void> _verifyPin() async {
    final storage = ref.read(secureStorageProvider);
    final storedHash = await storage.read(key: 'user_pin_hash');
    
    // Default PIN is 1234 for first-time if not set (simple fallback for this module)
    final pinString = _pin.join();
    final bytes = utf8.encode(pinString);
    final hash = sha256.convert(bytes).toString();

    // Default PIN is 1234 if not set
    const defaultPin = '1234';
    final defaultHash = sha256.convert(utf8.encode(defaultPin)).toString();

    if ((storedHash ?? defaultHash) == hash) {
       if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN')));
      }
      setState(() => _pin.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Icon(Icons.lock_outline_rounded, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Moneywise Locked',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            Text(
              _showPinFallback ? 'Enter your 4-digit PIN' : 'Touch the sensor to unlock',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Spacer(),
            if (!_showPinFallback)
              IconButton(
                iconSize: 80,
                onPressed: _authenticate,
                icon: Icon(Icons.fingerprint_rounded, color: theme.colorScheme.primary),
              )
            else
              _buildPinPad(theme),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinPad(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: i < _pin.length ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
          )),
        ),
        const SizedBox(height: 48),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          childAspectRatio: 1.5,
          children: [
            for (var i = 1; i <= 9; i++) _buildKey(i, theme),
            const SizedBox.shrink(),
            _buildKey(0, theme),
            IconButton(onPressed: () => setState(() => _pin.clear()), icon: const Icon(Icons.backspace_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(int digit, ThemeData theme) {
    return InkWell(
      onTap: () => _onPinKeyTap(digit),
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
