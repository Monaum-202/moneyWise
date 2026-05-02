import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/core/services/backup_providers.dart';
import 'package:moneywise/core/services/drive_backup_result.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/settings/presentation/widgets/restore_dialog.dart';

class GoogleBackupTile extends ConsumerWidget {
  const GoogleBackupTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(googleAccountProvider);
    final lastBackup = ref.watch(lastBackupInfoProvider);
    final backupStatus = ref.watch(backupProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final theme = Theme.of(context);

    if (account == null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: const Text('Google Drive Backup'),
        subtitle: Text(
          'Sign in to back up your data',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: backupStatus == BackupStatus.loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : OutlinedButton(
                onPressed: () async {
                  final email = await ref.read(backupProvider.notifier).signIn();
                  if (email != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Signed in as $email ✓')),
                    );
                  }
                },
                child: const Text('Sign In'),
              ),
      );
    }

    return Column(
      children: [
        ListTile(
          leading: account.photoUrl != null
              ? CircleAvatar(backgroundImage: NetworkImage(account.photoUrl!))
              : const CircleAvatar(child: Icon(Icons.person)),
          title: const Text('Backup to Google Drive'),
          subtitle: Text(
            'Signed in as ${account.email}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          trailing: TextButton(
            onPressed: () => ref.read(backupProvider.notifier).signOut(),
            child: Text(
              'Sign out',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        ),
        const Divider(height: 1),
        _BackupActionRow(
          icon: Icons.cloud_upload_outlined,
          iconColor: theme.colorScheme.primary,
          title: 'Back up now',
          subtitle: lastBackup.when(
            data: (info) {
              if (info == null) return 'Never backed up';
              final date = DateFormat('dd MMM yyyy, HH:mm').format(info.lastBackupTime);
              final size = (info.sizeBytes / 1024).toStringAsFixed(1);
              return 'Last backup: $date · $size KB';
            },
            loading: () => 'Checking...',
            error: (_, __) => 'Error fetching backup info',
          ),
          trailing: backupStatus == BackupStatus.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton(
                  onPressed: () async {
                    final result = await ref.read(backupProvider.notifier).backup();
                    if (!context.mounted) return;
                    if (result is BackupSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✓ Backed up to Google Drive')),
                      );
                    } else if (result is BackupFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Backup failed: ${result.error}'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Backup'),
                ),
        ),
        _BackupActionRow(
          icon: Icons.cloud_download_outlined,
          iconColor: theme.colorScheme.tertiary,
          title: 'Restore from Drive',
          subtitle: 'Replace all local data with backup',
          trailing: OutlinedButton(
            onPressed: () => showRestoreDialog(context, ref),
            child: const Text('Restore'),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.sync_rounded, size: 20),
          title: const Text('Auto-backup', style: TextStyle(fontSize: 14)),
          subtitle: const Text('Back up when leaving the app', style: TextStyle(fontSize: 12)),
          value: settings?.autoBackupEnabled ?? false,
          onChanged: (v) => ref.read(settingsProvider.notifier).setAutoBackup(v),
        ),
      ],
    );
  }
}

class _BackupActionRow extends StatelessWidget {
  const _BackupActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
