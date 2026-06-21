import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../utils/formatting.dart';
import '../widgets/category_progress_tile.dart';
import '../widgets/month_selector.dart';
import 'add_edit_item_screen.dart';
import 'categories_screen.dart';
import 'items_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FinanceRepository>();
    final progress = repo.progressForActiveMonth();
    final hasCategories = progress.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fintr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categories',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: MonthSelector()),
          ),
          _TotalSummaryCard(
            spent: repo.totalSpent(repo.activeMonth),
            limit: repo.totalLimit,
          ),
          const Divider(height: 1),
          Expanded(
            child: hasCategories
                ? ListView.separated(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: progress.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = progress[index];
                      return CategoryProgressTile(
                        progress: p,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ItemsScreen(categoryId: p.category.id),
                          ),
                        ),
                      );
                    },
                  )
                : const _EmptyState(),
          ),
        ],
      ),
      floatingActionButton: hasCategories
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
            )
          : null,
    );
  }
}

class _TotalSummaryCard extends StatelessWidget {
  const _TotalSummaryCard({required this.spent, required this.limit});

  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = limit <= 0 ? 0.0 : (spent / limit);
    final over = limit > 0 && spent > limit;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This month', style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatMoney(spent),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: over ? theme.colorScheme.error : null,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ ${formatMoney(limit)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  over ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline,
                size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No categories yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add a category with a monthly limit to start tracking.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Manage categories'),
            ),
          ],
        ),
      ),
    );
  }
}
