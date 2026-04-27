import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/features/analytics/presentation/providers/analytics_providers.dart';

class PeriodSelectorWidget extends ConsumerWidget {
  const PeriodSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<AnalyticsPeriod>(
        segments: const [
          ButtonSegment(value: AnalyticsPeriod.week, label: Text('Week')),
          ButtonSegment(value: AnalyticsPeriod.month, label: Text('Month')),
          ButtonSegment(value: AnalyticsPeriod.year, label: Text('Year')),
          ButtonSegment(value: AnalyticsPeriod.custom, label: Text('Custom')),
        ],
        selected: {period},
        onSelectionChanged: (set) async {
          final selected = set.first;
          if (selected == AnalyticsPeriod.custom) {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (range != null) {
              ref.read(analyticsCustomRangeProvider.notifier).state = range;
              ref.read(analyticsPeriodProvider.notifier).state = AnalyticsPeriod.custom;
            }
          } else {
            ref.read(analyticsPeriodProvider.notifier).state = selected;
          }
        },
      ),
    );
  }
}
