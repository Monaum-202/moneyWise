import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:moneywise/features/dashboard/presentation/widgets/balance_summary_card.dart';
import 'package:moneywise/features/dashboard/presentation/widgets/recent_transactions_widget.dart';
import 'package:moneywise/features/dashboard/presentation/widgets/top_categories_widget.dart';
import 'package:moneywise/features/dashboard/presentation/widgets/upcoming_loans_widget.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:moneywise/features/sms/presentation/widgets/sms_confirmation_card.dart';
import 'package:moneywise/features/sms/providers/sms_providers.dart';
import 'package:moneywise/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:moneywise/features/transactions/presentation/screens/add_transaction_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _insightController;
  Timer? _insightTimer;

  @override
  void initState() {
    super.initState();
    _insightController = PageController();
    _insightTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_insightController.hasClients) {
        final insights = ref.read(insightsProvider);
        if (insights.isNotEmpty) {
          var nextPage = _insightController.page!.toInt() + 1;
          if (nextPage >= insights.length) nextPage = 0;
          _insightController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _insightTimer?.cancel();
    _insightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(insightsProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currencySymbol = CurrencyFormatter.getSymbol(settings?.currency ?? 'BDT');
    final theme = Theme.of(context);

    final hour = DateTime.now().hour;
    final greeting = hour < 12 
        ? 'Good morning' 
        : hour < 17 
            ? 'Good afternoon' 
            : 'Good evening';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16, end: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moneywise',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      totalBalanceAsync.when(
                        data: (balance) => Text(
                          'Balance: $currencySymbol${balance.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/categories'),
                icon: const Icon(Icons.category_rounded),
                tooltip: 'Categories',
              ),
              IconButton(
                onPressed: () => context.push('/budget'),
                icon: const Icon(Icons.account_balance_wallet_rounded),
                tooltip: 'Budget',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          Consumer(builder: (context, ref, _) {
            final pending = ref.watch(pendingSmsProvider);
            if (pending.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverToBoxAdapter(
              child: Column(
                children: pending.map((parsed) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SmsConfirmationCard(
                    parsed: parsed,
                    onDismiss: () => ref
                      .read(smsTrackingNotifierProvider.notifier)
                      .dismissTransaction(parsed),
                    onConfirm: (catId) => ref
                      .read(smsTrackingNotifierProvider.notifier)
                      .confirmTransaction(parsed, catId),
                  ),
                )).toList(),
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const BalanceSummaryCard(),
                  if (insights.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 80,
                      child: PageView.builder(
                        controller: _insightController,
                        itemCount: insights.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, 
                                     color: theme.colorScheme.secondary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    insights[index],
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const TopCategoriesWidget(),
                  const UpcomingLoansWidget(),
                  const RecentTransactionsWidget(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => const AddTransactionSheet(),
          );
        },
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add_rounded),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
