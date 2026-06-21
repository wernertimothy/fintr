import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../utils/formatting.dart';
import 'add_edit_item_screen.dart';

/// Expenses for one category in the active month, with swipe-to-delete and
/// tap-to-edit.
class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FinanceRepository>();
    final category = repo.categoryById(categoryId);
    if (category == null) {
      // Category was deleted while this screen was open.
      return const Scaffold(body: Center(child: Text('Category not found')));
    }
    final items = repo.itemsForCategory(categoryId, repo.activeMonth);
    final spent = repo.spentFor(categoryId, repo.activeMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${formatMonth(repo.activeMonth)}  ·  '
              '${formatMoney(spent)} / ${formatMoney(category.monthlyLimit)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? const Center(child: Text('No expenses this month.'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) => repo.deleteItem(item.id),
                  child: ListTile(
                    title: Text(item.name),
                    trailing: Text(
                      formatMoney(item.amount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditItemScreen(existing: item),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
