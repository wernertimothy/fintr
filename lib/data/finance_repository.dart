import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/app_data.dart';
import '../models/category.dart';
import '../models/expense_item.dart';
import 'storage.dart';

/// View-model row for the dashboard: a category paired with its spend for the
/// active month and the resulting progress ratio.
@immutable
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.spent,
  });

  final Category category;
  final double spent;

  double get limit => category.monthlyLimit;

  /// Spent / limit, clamped at 0 lower bound (unbounded above so callers can
  /// detect over-budget). Returns 0 when there is no limit.
  double get ratio => limit <= 0 ? 0 : spent / limit;

  bool get isOverBudget => limit > 0 && spent > limit;

  double get remaining => limit - spent;
}

/// In-memory source of truth + business logic. The UI watches this and calls
/// its methods; every mutation persists through [Storage] and notifies.
class FinanceRepository extends ChangeNotifier {
  FinanceRepository(this._storage);

  final Storage _storage;
  final _uuid = const Uuid();

  List<Category> _categories = [];
  List<ExpenseItem> _items = [];
  late String _activeMonth = monthKey(DateTime.now());
  ThemeMode _themeMode = ThemeMode.system;

  List<Category> get categories => List.unmodifiable(_categories);
  List<ExpenseItem> get items => List.unmodifiable(_items);
  String get activeMonth => _activeMonth;
  ThemeMode get themeMode => _themeMode;

  static ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _themeModeToString(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  /// `YYYY-MM` key for a date.
  static String monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  static DateTime monthDate(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  // --- lifecycle -----------------------------------------------------------

  Future<void> init() async {
    final data = await _storage.load();
    _categories = data.categories;
    _items = data.items;
    _themeMode = _themeModeFromString(data.themeMode);
    if (data.isEmpty) {
      _categories = _seedCategories();
      await _persist();
    }
    notifyListeners();
  }

  Future<void> _persist() => _storage.save(
        AppData(
          categories: _categories,
          items: _items,
          themeMode: _themeModeToString(_themeMode),
        ),
      );

  // --- appearance ----------------------------------------------------------

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    await _persist();
    notifyListeners();
  }

  // --- month navigation ----------------------------------------------------

  void setActiveMonth(String month) {
    if (month == _activeMonth) return;
    _activeMonth = month;
    notifyListeners();
  }

  void previousMonth() {
    final d = monthDate(_activeMonth);
    setActiveMonth(monthKey(DateTime(d.year, d.month - 1)));
  }

  void nextMonth() {
    final d = monthDate(_activeMonth);
    setActiveMonth(monthKey(DateTime(d.year, d.month + 1)));
  }

  // --- category ops --------------------------------------------------------

  Future<Category> addCategory({
    required String name,
    required double monthlyLimit,
    required int colorValue,
  }) async {
    final category = Category(
      id: _uuid.v4(),
      name: name,
      monthlyLimit: monthlyLimit,
      colorValue: colorValue,
    );
    _categories = [..._categories, category];
    await _persist();
    notifyListeners();
    return category;
  }

  Future<void> updateCategory(Category updated) async {
    _categories = [
      for (final c in _categories) c.id == updated.id ? updated : c,
    ];
    await _persist();
    notifyListeners();
  }

  /// Deletes a category and all of its items.
  Future<void> deleteCategory(String categoryId) async {
    _categories = _categories.where((c) => c.id != categoryId).toList();
    _items = _items.where((i) => i.categoryId != categoryId).toList();
    await _persist();
    notifyListeners();
  }

  Category? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  // --- item ops ------------------------------------------------------------

  Future<ExpenseItem> addItem({
    required String name,
    required double amount,
    required String categoryId,
    String? month,
  }) async {
    final item = ExpenseItem(
      id: _uuid.v4(),
      name: name,
      amount: amount,
      categoryId: categoryId,
      month: month ?? _activeMonth,
      createdAt: DateTime.now(),
    );
    _items = [..._items, item];
    await _persist();
    notifyListeners();
    return item;
  }

  Future<void> updateItem(ExpenseItem updated) async {
    _items = [
      for (final i in _items) i.id == updated.id ? updated : i,
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> deleteItem(String itemId) async {
    _items = _items.where((i) => i.id != itemId).toList();
    await _persist();
    notifyListeners();
  }

  /// Re-adds a previously deleted item exactly as it was (used for undo).
  Future<void> restoreItem(ExpenseItem item) async {
    if (_items.any((i) => i.id == item.id)) return;
    _items = [..._items, item];
    await _persist();
    notifyListeners();
  }

  /// Items for a given month, newest first.
  List<ExpenseItem> itemsForMonth(String month) {
    final result = _items.where((i) => i.month == month).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  List<ExpenseItem> itemsForCategory(String categoryId, String month) =>
      _items
          .where((i) => i.categoryId == categoryId && i.month == month)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // --- computed views ------------------------------------------------------

  double spentFor(String categoryId, String month) {
    var total = 0.0;
    for (final i in _items) {
      if (i.categoryId == categoryId && i.month == month) total += i.amount;
    }
    return total;
  }

  double totalSpent(String month) {
    var total = 0.0;
    for (final i in _items) {
      if (i.month == month) total += i.amount;
    }
    return total;
  }

  double get totalLimit =>
      _categories.fold(0.0, (sum, c) => sum + c.monthlyLimit);

  /// Per-category progress for the active month, in category order.
  List<CategoryProgress> progressForActiveMonth() => [
        for (final c in _categories)
          CategoryProgress(category: c, spent: spentFor(c.id, _activeMonth)),
      ];

  // --- backup: export / import --------------------------------------------

  /// Fixed-name backup file inside [dir] (the app's local documents folder).
  static const String backupFileName = 'fintr-backup.json';

  static File backupFile(Directory dir) =>
      File('${dir.path}/$backupFileName');

  /// Overwrites the single local backup file in [dir] with the current
  /// dataset (atomic write — tmp + rename) and returns it. Stays entirely
  /// within the app's local folder; no OS share sheet.
  Future<File> exportToFile(Directory dir) async {
    final data = AppData(
      categories: _categories,
      items: _items,
      themeMode: _themeModeToString(_themeMode),
    );
    final file = backupFile(dir);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data.toJson()), flush: true);
    return tmp.rename(file.path);
  }

  /// Replaces the entire dataset from a backup file. Throws [FormatException]
  /// if the file is not a valid backup.
  Future<void> importFromFile(File file) async {
    final contents = await file.readAsString();
    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Not a valid fintr backup file.');
    }
    final data = AppData.fromJson(decoded);
    _categories = data.categories;
    _items = data.items;
    _themeMode = _themeModeFromString(data.themeMode);
    await _persist();
    notifyListeners();
  }

  // --- seed ----------------------------------------------------------------

  List<Category> _seedCategories() => [
        Category(
          id: _uuid.v4(),
          name: 'Food',
          monthlyLimit: 1000,
          colorValue: Colors.green.toARGB32(),
        ),
        Category(
          id: _uuid.v4(),
          name: 'Transport',
          monthlyLimit: 400,
          colorValue: Colors.blue.toARGB32(),
        ),
        Category(
          id: _uuid.v4(),
          name: 'Leisure',
          monthlyLimit: 300,
          colorValue: Colors.purple.toARGB32(),
        ),
      ];
}
