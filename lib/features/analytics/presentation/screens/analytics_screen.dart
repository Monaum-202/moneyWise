import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:moneywise/features/analytics/presentation/widgets/cashflow_bar_chart.dart';
import 'package:moneywise/features/analytics/presentation/widgets/cashflow_summary_row.dart';
import 'package:moneywise/features/analytics/presentation/widgets/category_donut_chart.dart';
import 'package:moneywise/features/analytics/presentation/widgets/insights_card_widget.dart';
import 'package:moneywise/features/analytics/presentation/widgets/period_selector_widget.dart';
import 'package:moneywise/features/analytics/presentation/widgets/trend_line_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'Analytics',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
            floating: true,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PeriodSelectorWidget(),
                const CashFlowSummaryRow(),
                
                const _SectionCard(
                  title: 'Cash Flow',
                  child: CashflowBarChart(),
                ),
                
                const _SectionCard(
                  title: 'By Category',
                  child: CategoryDonutChart(),
                ),
                
                const _SectionCard(
                  title: 'Spending Trend',
                  child: TrendLineChart(),
                ),

                if (insights.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      'Smart Insights',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: insights.map((insight) => InsightCardWidget(insight: insight)).toList(),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {

  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
