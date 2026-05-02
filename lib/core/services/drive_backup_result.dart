import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_backup_result.freezed.dart';
part 'drive_backup_result.g.dart';

@freezed
sealed class DriveBackupResult with _$DriveBackupResult {
  const factory DriveBackupResult.success({
    required DateTime timestamp,
    required int sizeBytes,
  }) = BackupSuccess;
  const factory DriveBackupResult.failure(String error) = BackupFailure;
  const factory DriveBackupResult.notSignedIn() = BackupNotSignedIn;
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
    required int sizeBytes,
    @Default('1.0') String version,
    @Default(0) int transactionCount,
    @Default(0) int loanCount,
    @Default(0) int categoryCount,
  }) = _BackupMetadata;

  factory BackupMetadata.fromJson(Map<String, dynamic> json) =>
      _$BackupMetadataFromJson(json);
}
