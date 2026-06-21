import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';
import '../models/category.dart';
import '../utils/formatting.dart';
import '../widgets/swipe_backgrounds.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FinanceRepository>();
    final categories = repo.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categories.isEmpty
          ? const Center(child: Text('No categories yet. Add one below.'))
          : ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = categories[index];
                return Dismissible(
                  key: ValueKey(c.id),
                  background: editSwipeBackground(context),
                  secondaryBackground: deleteSwipeBackground(context),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editCategory(context, c);
                      return false;
                    }
                    return _confirmDelete(context, c);
                  },
                  onDismissed: (_) => repo.deleteCategory(c.id),
                  child: ListTile(
                    leading: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: c.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(c.name),
                    subtitle:
                        Text('Limit ${formatMoney(c.monthlyLimit)} / month'),
                    onTap: () => _editCategory(context, c),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditCategoryScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New category'),
      ),
    );
  }

  void _editCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(existing: category),
      ),
    );
  }

  /// Shows the destructive-delete confirmation. Returns true if confirmed.
  Future<bool> _confirmDelete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${category.name}"?'),
        content: const Text(
          'This also deletes all expenses in this category, across every '
          'month. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
