import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../utils/formatting.dart';

/// `‹ June 2026 ›` selector wired to the repository's active month.
class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FinanceRepository>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: repo.previousMonth,
          tooltip: 'Previous month',
        ),
        Text(
          formatMonth(repo.activeMonth),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: repo.nextMonth,
          tooltip: 'Next month',
        ),
      ],
    );
  }
}
