import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moneywise/core/utils/pdf_report_generator.dart';
import 'package:moneywise/features/budget/presentation/providers/budget_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull ?? const AppSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'APPEARANCE',
            children: [
              ListTile(
                title: const Text('Theme Mode'),
                subtitle: Text(settings.themeMode.name.toUpperCase()),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined)),
                    ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined)),
                    ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest_outlined)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (set) => ref.read(settingsProvider.notifier).setTheme(set.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'PREFERENCES',
            children: [
              ListTile(
                title: const Text('Currency'),
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  items: ['BDT', 'USD', 'EUR', 'GBP', 'INR']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => ref.read(settingsProvider.notifier).setCurrency(v ?? 'BDT'),
                ),
              ),
              SwitchListTile(
                title: const Text('Date Format'),
                subtitle: Text(settings.dateFormat),
                value: settings.dateFormat == 'DD/MM/YYYY',
                onChanged: (v) => ref.read(settingsProvider.notifier).setDateFormat(v ? 'DD/MM/YYYY' : 'MM/DD/YYYY'),
              ),
              SwitchListTile(
                title: const Text('First day of week'),
                subtitle: Text(settings.firstDayOfWeek == 1 ? 'Monday' : 'Sunday'),
                value: settings.firstDayOfWeek == 1,
                onChanged: (v) => ref.read(settingsProvider.notifier).setFirstDayOfWeek(v ? 1 : 7),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'SECURITY',
            children: [
              SwitchListTile(
                title: const Text('Biometric Lock'),
                value: settings.biometricEnabled,
                onChanged: (v) async {
                  if (v) {
                    final auth = LocalAuthentication();
                    final canAuth = await auth.canCheckBiometrics;
                    if (!canAuth) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biometrics not available on this device')),
                        );
                      }
                      return;
                    }
                    final didAuth = await auth.authenticate(
                      localizedReason: 'Confirm to enable biometric lock',
                    );
                    if (!didAuth) return;
                  }
                  ref.read(settingsProvider.notifier).setBiometric(v);
                },
              ),
              ListTile(
                title: const Text('Change PIN'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/pin-setup'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'DATA',
            children: [
              ListTile(
                title: const Text('Export JSON'),
                leading: const Icon(Icons.download_rounded),
                onTap: () async => await _exportData(ref),
              ),
              ListTile(
                title: const Text('Import JSON'),
                leading: const Icon(Icons.upload_rounded),
                onTap: () async => await _importData(ref, context),
              ),
              ListTile(
                title: const Text('Export PDF Report'),
                leading: const Icon(Icons.picture_as_pdf_rounded),
                onTap: () async => await _exportPdf(ref, context),
              ),
              ListTile(
                title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                onTap: () => _showClearDataDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'NOTIFICATIONS',
            children: [
              SwitchListTile(
                title: const Text('Budget Alerts'),
                value: settings.budgetAlertsEnabled,
                onChanged: (v) => ref.read(settingsProvider.notifier).setBudgetAlerts(v),
              ),
              SwitchListTile(
                title: const Text('Loan Reminders'),
                value: settings.loanRemindersEnabled,
                onChanged: (v) => ref.read(settingsProvider.notifier).setLoanReminders(v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'ABOUT',
            children: [
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  return ListTile(
                    title: const Text('App Version'),
                    trailing: Text(snapshot.data?.version ?? '1.0.0'),
                  );
                },
              ),
              ListTile(
                title: const Text('Licenses'),
                onTap: () => showLicensePage(context: context),
              ),
              ListTile(
                title: const Text('Rate App'),
                onTap: () async {
                  final inAppReview = InAppReview.instance;
                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _exportPdf(WidgetRef ref, BuildContext context) async {
    final repo = ref.read(transactionRepositoryProvider);
    final monthYear = ref.read(currentMonthYearProvider);
    
    final transactions = await repo.watchAll().first;
    final summary = await repo.watchSummary(DateTime(2000), DateTime(2100)).first;

    final file = await PdfReportGenerator.generate(
      monthYear: monthYear,
      transactions: transactions,
      totalIncome: summary.totalIncome,
      totalExpense: summary.totalExpense,
    );

    await Share.shareXFiles([XFile(file.path)], text: 'Moneywise Report $monthYear');
  }

  Future<void> _exportData(WidgetRef ref) async {
    final repo = ref.read(transactionRepositoryProvider);
    final loanRepo = ref.read(loanRepositoryProvider);
    
    final transactions = await repo.watchAll().first;
    final loans = await loanRepo.watchAll().first;

    final data = {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'loans': loans.map((l) => l.toJson()).toList(),
    };

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/moneywise_backup.json');
    await file.writeAsString(jsonEncode(data));

    await Share.shareXFiles([XFile(file.path)], text: 'Moneywise Backup');
  }

  Future<void> _importData(WidgetRef ref, BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null) return;

    try {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      jsonDecode(content);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import successful ✓ (Logic pending)')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import failed!')));
      }
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action cannot be undone. Type "DELETE" to confirm.'),
            TextField(controller: controller, decoration: const InputDecoration(hintText: 'DELETE')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text == 'DELETE') {
                final isar = ref.read(isarProvider).requireValue;
                await isar.writeTxn(() => isar.clear());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
          child: Column(children: children),
        ),
      ],
    );
  }
}
