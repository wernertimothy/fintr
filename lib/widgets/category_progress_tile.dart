import 'package:flutter/material.dart';

import '../data/finance_repository.dart';
import '../utils/formatting.dart';

/// One row of the dashboard: icon + name, spent / limit, and an animated bar
/// that shifts to amber near the limit and red when over budget.
class CategoryProgressTile extends StatelessWidget {
  const CategoryProgressTile({
    super.key,
    required this.progress,
    this.onTap,
  });

  final CategoryProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = progress.category;
    final ratio = progress.ratio;
    final over = progress.isOverBudget;

    final Color barColor;
    if (over) {
      barColor = theme.colorScheme.error;
    } else if (ratio >= 0.9) {
      barColor = Colors.amber.shade700;
    } else {
      barColor = category.color;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${formatMoney(progress.spent)} / ${formatMoney(progress.limit)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: over ? theme.colorScheme.error : null,
                    fontWeight: over ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
