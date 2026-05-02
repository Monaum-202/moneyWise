import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_backup_result.freezed.dart';

@freezed
sealed class DriveBackupResult with _$DriveBackupResult {
  const factory DriveBackupResult.success({
    required DateTime timestamp,
    required int sizeBytes,
  }) = BackupSuccess;
  const factory DriveBackupResult.failure(String error) = BackupFailure;
  const factory DriveBackupResult.notSignedIn() = BackupNotSignedIn;
  const factory DriveBackupResult.overwriteWarning({
    required BackupMetadata remoteMetadata,
  }) = BackupOverwriteWarning;
}

@freezed
sealed class DriveRestoreResult with _$DriveRestoreResult {
  const factory DriveRestoreResult.ready({
    required String jsonString,
    required BackupMetadata metadata,
  }) = RestoreReady;
  const factory DriveRestoreResult.noBackupFound() = RestoreNoBackup;
  const factory DriveRestoreResult.failure(String error) = RestoreFailure;
  const factory DriveRestoreResult.notSignedIn() = RestoreNotSignedIn;
}

@freezed
class BackupMetadata with _$BackupMetadata {
  const factory BackupMetadata({
    required DateTime lastBackupTime,
    @Default(0) int sizeBytes,
    @Default('1.0') String version,
    @Default(0) int transactionCount,
    @Default(0) int loanCount,
    @Default(0) int categoryCount,
    @Default(0) int budgetCount,
  }) = _BackupMetadata;

  factory BackupMetadata.fromJson(Map<String, dynamic>? json) {
    final map = json ?? <String, dynamic>{};
    return BackupMetadata(
      lastBackupTime: DateTime.tryParse(
              (map['lastBackupTime'] ?? map['exportedAt'])?.toString() ?? '') ??
          DateTime.now(),
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      version: map['version']?.toString() ?? '1.0',
      transactionCount: (map['transactionCount'] as num?)?.toInt() ?? 0,
      loanCount: (map['loanCount'] as num?)?.toInt() ?? 0,
      categoryCount: (map['categoryCount'] as num?)?.toInt() ?? 0,
      budgetCount: (map['budgetCount'] as num?)?.toInt() ?? 0,
    );
  }
}
