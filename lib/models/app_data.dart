import 'category.dart';
import 'expense_item.dart';

/// The full dataset persisted as a single JSON document.
///
/// The top-level [version] is a cheap migration hook for future schema
/// changes or a move to SQLite.
class AppData {
  AppData({
    this.version = currentVersion,
    List<Category>? categories,
    List<ExpenseItem>? items,
    this.themeMode = 'system',
  })  : categories = categories ?? [],
        items = items ?? [];

  static const int currentVersion = 1;

  final int version;
  final List<Category> categories;
  final List<ExpenseItem> items;

  /// User's theme preference: `system`, `light`, or `dark`.
  final String themeMode;

  bool get isEmpty => categories.isEmpty && items.isEmpty;

  Map<String, dynamic> toJson() => {
        'version': version,
        'categories': categories.map((c) => c.toJson()).toList(),
        'items': items.map((i) => i.toJson()).toList(),
        'themeMode': themeMode,
      };

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
        version: (json['version'] as num?)?.toInt() ?? currentVersion,
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        themeMode: json['themeMode'] as String? ?? 'system',
      );
}
