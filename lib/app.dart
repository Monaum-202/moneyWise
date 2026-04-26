import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/constants/app_strings.dart';
import 'package:moneywise/core/theme/app_theme.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/routing/app_router.dart';

class MoneywiseApp extends ConsumerStatefulWidget {
  const MoneywiseApp({super.key});

  @override
  ConsumerState<MoneywiseApp> createState() => _MoneywiseAppState();
}

class _MoneywiseAppState extends ConsumerState<MoneywiseApp> {
  late final AppLifecycleListener _listener;
  DateTime? _backgroundTimestamp;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onHide: () => _backgroundTimestamp = DateTime.now(),
      onResume: _handleResume,
    );
  }

  void _handleResume() {
    if (_backgroundTimestamp == null) return;
    
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.biometricEnabled == true) {
      final diff = DateTime.now().difference(_backgroundTimestamp!).inMinutes;
      if (diff >= 5) {
        ref.read(appRouterProvider).push('/lock');
      }
    }
    _backgroundTimestamp = null;
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    
    // Trigger category seeding on app startup
    ref.watch(categorySeederProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
