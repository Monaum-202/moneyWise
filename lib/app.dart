import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/constants/app_strings.dart';
import 'package:moneywise/core/services/notification_service.dart';
import 'package:moneywise/core/services/drive_backup_service.dart';
import 'package:moneywise/core/services/google_auth_service.dart';
import 'package:moneywise/core/theme/app_theme.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/routing/app_router.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';

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
      onHide: () {
        _backgroundTimestamp = DateTime.now();
        _handleBackgroundBackup();
      },
      onResume: _handleResume,
    );
  }

  Future<void> _handleBackgroundBackup() async {
    final isSignedIn = await GoogleAuthService.isSignedIn;
    final settings = ref.read(settingsProvider).valueOrNull;
    final autoBackup = settings?.autoBackupEnabled ?? false;

    if (isSignedIn && autoBackup) {
      final isar = ref.read(isarProvider);
      // Fire and forget backup in background
      DriveBackupService.backup(isar);
    }
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
    final settingsAsync = ref.watch(settingsProvider);
    
    // Seed default categories
    ref.watch(categorySeederProvider);

    // Schedule/Sync loan reminders on startup
    ref.listen(loanListProvider, (previous, next) {
      next.whenData((loans) {
        for (final loan in loans) {
          if (!loan.isPaid && loan.dueDate != null) {
            NotificationService.scheduleLoanDueReminder(loan);
          }
        }
      });
    });

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settingsAsync.valueOrNull?.themeMode ?? ThemeMode.system,
      routerConfig: router,
    );
  }
}
