import 'dart:io';

import 'package:fintr/data/finance_repository.dart';
import 'package:fintr/data/storage.dart';
import 'package:fintr/models/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [Storage] so tests avoid path_provider / the filesystem.
class FakeStorage implements Storage {
  FakeStorage([AppData? initial]) : _data = initial ?? AppData();
  AppData _data;
  int saveCount = 0;

  @override
  Future<AppData> load() async => _data;

  @override
  Future<void> save(AppData data) async {
    _data = data;
    saveCount++;
  }
}

void main() {
  test('init seeds starter categories when storage is empty', () async {
    final repo = FinanceRepository(FakeStorage());
    await repo.init();
    expect(repo.categories, isNotEmpty);
  });

  test('spentFor and totalSpent sum only matching category/month', () async {
    final repo = FinanceRepository(FakeStorage());
    await repo.init();
    final food = repo.categories.first;
    final other = repo.categories[1];

    await repo.addItem(name: 'Lunch', amount: 10, categoryId: food.id);
    await repo.addItem(name: 'Dinner', amount: 15, categoryId: food.id);
    await repo.addItem(name: 'Bus', amount: 5, categoryId: other.id);
    // A different month must not be counted.
    await repo.addItem(
        name: 'Old', amount: 99, categoryId: food.id, month: '2000-01');

    expect(repo.spentFor(food.id, repo.activeMonth), 25);
    expect(repo.spentFor(other.id, repo.activeMonth), 5);
    expect(repo.totalSpent(repo.activeMonth), 30);
  });

  test('deleting a category removes its items', () async {
    final repo = FinanceRepository(FakeStorage());
    await repo.init();
    final food = repo.categories.first;
    await repo.addItem(name: 'Lunch', amount: 10, categoryId: food.id);

    await repo.deleteCategory(food.id);

    expect(repo.categories.any((c) => c.id == food.id), isFalse);
    expect(repo.items.any((i) => i.categoryId == food.id), isFalse);
  });

  test('month navigation wraps across year boundaries', () async {
    final repo = FinanceRepository(FakeStorage());
    await repo.init();
    repo.setActiveMonth('2026-01');
    repo.previousMonth();
    expect(repo.activeMonth, '2025-12');
    repo.nextMonth();
    repo.nextMonth();
    expect(repo.activeMonth, '2026-02');
  });

  test('mutations persist through storage', () async {
    final storage = FakeStorage();
    final repo = FinanceRepository(storage);
    await repo.init();
    final before = storage.saveCount;
    await repo.addItem(
        name: 'X', amount: 1, categoryId: repo.categories.first.id);
    expect(storage.saveCount, before + 1);
  });

  test('deleteItem then restoreItem brings the entry back unchanged',
      () async {
    final repo = FinanceRepository(FakeStorage());
    await repo.init();
    final food = repo.categories.first;
    final item =
        await repo.addItem(name: 'Lunch', amount: 12, categoryId: food.id);

    await repo.deleteItem(item.id);
    expect(repo.items, isEmpty);

    await repo.restoreItem(item);
    expect(repo.items.single, item);

    // Restoring again is a no-op (no duplicates).
    await repo.restoreItem(item);
    expect(repo.items.length, 1);
  });

  test('theme mode defaults to system and persists across reload', () async {
    final storage = FakeStorage();
    final repo = FinanceRepository(storage);
    await repo.init();
    expect(repo.themeMode, ThemeMode.system);

    await repo.setThemeMode(ThemeMode.dark);
    expect(repo.themeMode, ThemeMode.dark);

    // A fresh repo over the same storage should load the saved preference.
    final reloaded = FinanceRepository(storage);
    await reloaded.init();
    expect(reloaded.themeMode, ThemeMode.dark);
  });

  test('export then import restores data from the local backup file',
      () async {
    final dir = await Directory.systemTemp.createTemp('fintr_backup');
    addTearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    final repo = FinanceRepository(FakeStorage());
    await repo.init();
    final food = repo.categories.first;
    await repo.addItem(name: 'Lunch', amount: 12, categoryId: food.id);

    final backup = await repo.exportToFile(dir);
    // Backup lives in the app folder under the fixed name, not a share/temp name.
    expect(backup.path.endsWith(FinanceRepository.backupFileName), isTrue);

    // Mutate, then restore from the backup.
    await repo.deleteItem(repo.items.first.id);
    expect(repo.items, isEmpty);

    await repo.importFromFile(FinanceRepository.backupFile(dir));
    expect(repo.items.length, 1);
    expect(repo.items.first.name, 'Lunch');
  });
}
