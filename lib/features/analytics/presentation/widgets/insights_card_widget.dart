import 'package:flutter/material.dart';

class InsightCardWidget extends StatelessWidget {

  const InsightCardWidget({
    required this.insight, super.key,
  });
  final String insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Auto-choose color and icon based on content
    Color color = Colors.amber;
    var icon = Icons.lightbulb_outline_rounded;

    if (insight.contains('Great job') || insight.contains('saved')) {
      color = const Color(0xFF1D9E75);
      icon = Icons.savings_rounded;
    } else if (insight.contains('spent more') || insight.contains('Review')) {
      color = const Color(0xFFE05C5C);
      icon = Icons.trending_up_rounded;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.08), Colors.transparent],
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(icon, color: color),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 16, bottom: 16),
                  child: Text(
                    insight,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
