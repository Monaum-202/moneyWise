import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/core/services/sms_parser.dart';
import 'package:moneywise/features/categories/presentation/providers/category_providers.dart';
import 'package:moneywise/features/sms/providers/sms_providers.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/widgets/empty_state_widget.dart';

class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({super.key});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  bool _isLoading = true;
  List<ParsedSmsTransaction> _allTransactions = [];
  final Map<String, String> _groupCategories = {}; // bankName -> categoryId
  final Set<ParsedSmsTransaction> _selectedTransactions = {};

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() => _isLoading = true);
    final history = await ref.read(smsTrackingNotifierProvider.notifier).scanHistory();
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    final defaultCatId = categories.isNotEmpty ? categories.first.uuid : '';

    setState(() {
      _allTransactions = history;
      _selectedTransactions.addAll(history);
      _isLoading = false;
      
      final groups = groupBy(history, (t) => t.bankName);
      for (final bank in groups.keys) {
        _groupCategories[bank] = defaultCatId;
      }
    });
  }

  Future<void> _importSelected() async {
    final selected = _allTransactions.where((t) => _selectedTransactions.contains(t)).toList();
    if (selected.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportProgressDialog(
        total: selected.length,
        onImport: (progress) async {
          final item = selected[progress];
          final catId = _groupCategories[item.bankName] ?? '';
          await ref.read(smsTrackingNotifierProvider.notifier).confirmTransaction(item, catId);
        },
      ),
    ).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ ${selected.length} transactions imported')),
        );
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Import SMS History')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Scanning your SMS inbox...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_allTransactions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Import SMS History')),
        body: EmptyStateWidget(
          icon: Icons.sms_failed_outlined,
          title: "No bank SMS found",
          subtitle: "No transactions from bKash, Nagad, Rocket, DBBL or IBBL in last 90 days",
          onAction: () => Navigator.of(context).pop(),
          actionLabel: "Go Back",
        ),
      );
    }

    final groups = groupBy(_allTransactions, (t) => t.bankName);
    final income = _allTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final expense = _allTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Import SMS History')),
      body: Column(
        children: [
          _buildSummaryCard(income, expense),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: groups.entries.map((entry) => _buildBankGroup(entry.key, entry.value)).toList(),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildSummaryCard(double income, double expense) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(label: 'Found', value: _allTransactions.length.toString(), color: theme.colorScheme.primary),
            _SummaryItem(label: 'Income', value: '৳${income.toStringAsFixed(0)}', color: Colors.green),
            _SummaryItem(label: 'Expense', value: '৳${expense.toStringAsFixed(0)}', color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildBankGroup(String bankName, List<ParsedSmsTransaction> transactions) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$bankName (${transactions.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _groupCategories[bankName],
                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), border: OutlineInputBorder()),
                  items: categories.map((c) => DropdownMenuItem(value: c.uuid, child: Text(c.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _groupCategories[bankName] = val);
                  },
                ),
              ),
            ],
          ),
        ),
        ...transactions.map((t) => CheckboxListTile(
          value: _selectedTransactions.contains(t),
          onChanged: (val) {
            setState(() {
              if (val == true) _selectedTransactions.add(t);
              else _selectedTransactions.remove(t);
            });
          },
          title: Text('৳${t.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: t.type == TransactionType.income ? Colors.green : Colors.red)),
          subtitle: Text(DateFormat('MMM dd, hh:mm a').format(t.receivedAt)),
          secondary: Icon(t.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward, color: t.type == TransactionType.income ? Colors.green : Colors.red),
        )),
        const Divider(),
      ],
    );
  }

  Widget _buildBottomBar() {
    final selectedCount = _selectedTransactions.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: selectedCount > 0 ? _importSelected : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Import $selectedCount selected'),
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _ImportProgressDialog extends StatefulWidget {
  final int total;
  final Future<void> Function(int index) onImport;
  const _ImportProgressDialog({required this.total, required this.onImport});

  @override
  State<_ImportProgressDialog> createState() => _ImportProgressDialogState();
}

class _ImportProgressDialogState extends State<_ImportProgressDialog> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _startImport();
  }

  Future<void> _startImport() async {
    for (int i = 0; i < widget.total; i++) {
      if (!mounted) return;
      setState(() => _current = i + 1);
      await widget.onImport(i);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importing Transactions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _current / widget.total),
          const SizedBox(height: 16),
          Text('Importing $_current of ${widget.total}...'),
        ],
      ),
    );
  }
}
