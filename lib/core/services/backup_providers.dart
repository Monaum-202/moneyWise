import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isar/isar.dart';
import 'package:moneywise/core/services/drive_backup_result.dart';
import 'package:moneywise/core/services/drive_backup_service.dart';
import 'package:moneywise/core/services/google_auth_service.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/loans/presentation/providers/loan_providers.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';

// Google account state
final googleAccountProvider = StateProvider<GoogleSignInAccount?>((ref) => null);

// Backup operation state
enum BackupStatus { idle, loading, success, failure }

class BackupNotifier extends StateNotifier<BackupStatus> {
  BackupNotifier(this._isar, this._ref) : super(BackupStatus.idle);
  final Isar _isar;
  final Ref _ref;

  Future<String?> signIn() async {
    state = BackupStatus.loading;
    try {
      final account = await GoogleAuthService.signIn();
      _ref.read(googleAccountProvider.notifier).state = account;
      state = BackupStatus.idle;
      return account?.email;
    } catch (e) {
      state = BackupStatus.failure;
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleAuthService.signOut();
    _ref.read(googleAccountProvider.notifier).state = null;
  }

  Future<DriveBackupResult> backup() async {
    state = BackupStatus.loading;
    final result = await DriveBackupService.backup(_isar);
    state = result is BackupSuccess
        ? BackupStatus.success : BackupStatus.failure;
    
    if (result is BackupSuccess) {
      _ref.invalidate(lastBackupInfoProvider);
    }
    
    await Future.delayed(const Duration(seconds: 2));
    state = BackupStatus.idle;
    return result;
  }

  Future<DriveRestoreResult> fetchRestorePreview() async {
    state = BackupStatus.loading;
    final result = await DriveBackupService.restore(_isar);
    state = BackupStatus.idle;
    return result;
  }

  Future<void> confirmRestore(String jsonString) async {
    state = BackupStatus.loading;
    await DriveBackupService.importToIsar(_isar, jsonString);
    state = BackupStatus.success;
    
    // Invalidate all data providers so UI refreshes
    _ref.invalidate(transactionListProvider);
    _ref.invalidate(loanListProvider);
    _ref.invalidate(categoryListProvider);
    
    await Future.delayed(const Duration(seconds: 2));
    state = BackupStatus.idle;
  }
}

final backupProvider = StateNotifierProvider<BackupNotifier, BackupStatus>((ref) {
  final isar = ref.watch(isarProvider);
  return BackupNotifier(isar, ref);
});

final lastBackupInfoProvider = FutureProvider<BackupMetadata?>((ref) async {
  final isSignedIn = await GoogleAuthService.isSignedIn;
  if (!isSignedIn) return null;
  return DriveBackupService.getLastBackupInfo();
});
