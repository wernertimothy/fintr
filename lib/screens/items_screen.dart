import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../models/expense_item.dart';
import '../utils/formatting.dart';
import '../widgets/swipe_backgrounds.dart';
import 'add_edit_item_screen.dart';

/// Expenses for one category in the active month. Swipe right to edit, swipe
/// left to delete (with undo).
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
                  background: editSwipeBackground(context),
                  secondaryBackground: deleteSwipeBackground(context),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editItem(context, item);
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (_) => _deleteItem(context, repo, item),
                  child: ListTile(
                    title: Text(item.name),
                    trailing: Text(
                      formatMoney(item.amount),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    onTap: () => _editItem(context, item),
                  ),
                );
              },
            ),
    );
  }

  void _editItem(BuildContext context, ExpenseItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditItemScreen(existing: item)),
    );
  }

  void _deleteItem(
      BuildContext context, FinanceRepository repo, ExpenseItem item) {
    repo.deleteItem(item.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${item.name}"'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => repo.restoreItem(item),
          ),
        ),
      );
  }
}
