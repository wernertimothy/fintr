import 'package:fintr/models/app_data.dart';
import 'package:fintr/models/category.dart';
import 'package:fintr/models/expense_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Category JSON round-trip', () {
    const category = Category(
      id: 'c1',
      name: 'Food',
      monthlyLimit: 1000,
      colorValue: 0xFF00FF00,
    );
    final restored = Category.fromJson(category.toJson());
    expect(restored, category);
  });

  test('ExpenseItem JSON round-trip', () {
    final item = ExpenseItem(
      id: 'i1',
      name: 'Groceries',
      amount: 42.5,
      categoryId: 'c1',
      month: '2026-06',
      createdAt: DateTime.parse('2026-06-21T10:00:00.000'),
    );
    final restored = ExpenseItem.fromJson(item.toJson());
    expect(restored, item);
  });

  test('AppData round-trip preserves version, categories and items', () {
    final data = AppData(
      categories: const [
        Category(
          id: 'c1',
          name: 'Food',
          monthlyLimit: 1000,
          colorValue: 0xFF00FF00,
        ),
      ],
      items: [
        ExpenseItem(
          id: 'i1',
          name: 'Groceries',
          amount: 42.5,
          categoryId: 'c1',
          month: '2026-06',
          createdAt: DateTime.parse('2026-06-21T10:00:00.000'),
        ),
      ],
    );
    final restored = AppData.fromJson(data.toJson());
    expect(restored.version, AppData.currentVersion);
    expect(restored.categories.single, data.categories.single);
    expect(restored.items.single, data.items.single);
  });
}
