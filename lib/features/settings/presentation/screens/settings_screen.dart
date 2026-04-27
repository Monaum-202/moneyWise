import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:local_auth/local_auth.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/core/utils/export_service.dart';
import 'package:moneywise/core/utils/pdf_report_generator.dart';
import 'package:moneywise/features/budget/presentation/providers/budget_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/providers/isar_provider.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull ?? const AppSettings();
    final isar = ref.watch(isarProvider);

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
                title: const Text('Categories'),
                leading: const Icon(Icons.category_rounded),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/categories'),
              ),
              ListTile(
                title: const Text('Monthly Budget'),
                leading: const Icon(Icons.account_balance_wallet_rounded),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/budget'),
              ),
              ListTile(
                title: const Text('Currency'),
                trailing: DropdownButton<String>(
                  value: settings.currency,
                  items: ['BDT', 'USD', 'EUR', 'GBP', 'INR']
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('$c (${CurrencyFormatter.getSymbol(c)})'),
                          ))
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
                onTap: () => ExportService.exportJson(isar),
              ),
              ListTile(
                title: const Text('Import JSON'),
                leading: const Icon(Icons.upload_rounded),
                onTap: () => ExportService.importJson(isar, context),
              ),
              ListTile(
                title: const Text('Export PDF Report'),
                leading: const Icon(Icons.picture_as_pdf_rounded),
                onTap: () => _exportPdf(ref),
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

  Future<void> _exportPdf(WidgetRef ref) async {
    final transRepo = ref.read(transactionRepositoryProvider);
    final loanRepo = ref.read(loanRepositoryProvider);
    final monthYear = ref.read(currentMonthYearProvider);
    final settings = ref.read(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final transactions = await transRepo.watchAll(from: startOfMonth, to: endOfMonth).first;
    final summary = await transRepo.watchSummary(startOfMonth, endOfMonth).first;
    final categoryTotals = await transRepo.watchCategoryTotals(monthYear).first;
    final loanSummary = await loanRepo.watchSummary().first;
    final loans = await loanRepo.watchAll(isPaid: false).first;

    final sortedTransactions = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    await PdfReportGenerator.generate(
      summary: summary,
      categoryTotals: categoryTotals,
      topTransactions: sortedTransactions.take(10).toList(),
      loanSummary: loanSummary,
      unsettledLoans: loans,
      monthYear: monthYear,
      currency: currencySymbol,
    );
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
                final isar = ref.read(isarProvider);
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
