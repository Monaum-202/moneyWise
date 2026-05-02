import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/core/services/backup_providers.dart';
import 'package:moneywise/core/services/drive_backup_result.dart';

Future<void> showRestoreDialog(BuildContext context, WidgetRef ref) async {
  // Step 1: Fetch backup preview
  final result = await showDialog<DriveRestoreResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _LoadingBackupDialog(),
  );

  if (result == null) return;

  if (result is RestoreNoBackup) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No backup found'),
        content: const Text("We couldn't find a Moneywise backup in your Google Drive."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  if (result is RestoreFailure) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restore failed: ${result.error}'), backgroundColor: Colors.red),
    );
    return;
  }

  if (result is RestoreReady) {
    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _RestoreConfirmDialog(metadata: result.metadata),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 16),
              Text('Restoring...'),
            ],
          ),
          duration: Duration(days: 1), // Persistent until manually hidden
        ),
      );

      await ref.read(backupProvider.notifier).confirmRestore(result.jsonString);
      
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('✓ Data restored successfully')),
      );

      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    }
  }
}

class _LoadingBackupDialog extends ConsumerStatefulWidget {
  const _LoadingBackupDialog();

  @override
  ConsumerState<_LoadingBackupDialog> createState() => _LoadingBackupDialogState();
}

class _LoadingBackupDialogState extends ConsumerState<_LoadingBackupDialog> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final result = await ref.read(backupProvider.notifier).fetchRestorePreview();
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Checking Google Drive...'),
        ],
      ),
    );
  }
}

class _RestoreConfirmDialog extends StatelessWidget {
  const _RestoreConfirmDialog({required this.metadata});
  final BackupMetadata metadata;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Restore from backup?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _MetadataRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Backup date',
                    value: dateFormat.format(metadata.lastBackupTime),
                  ),
                  _MetadataRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transactions',
                    value: metadata.transactionCount.toString(),
                  ),
                  _MetadataRow(
                    icon: Icons.handshake_outlined,
                    label: 'Loans',
                    value: metadata.loanCount.toString(),
                  ),
                  _MetadataRow(
                    icon: Icons.category_outlined,
                    label: 'Categories',
                    value: metadata.categoryCount.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This will REPLACE all your current data. This action cannot be undone.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Yes, Restore'),
        ),
      ],
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
