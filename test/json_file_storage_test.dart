import 'dart:io';

import 'package:fintr/data/json_file_storage.dart';
import 'package:fintr/models/app_data.dart';
import 'package:fintr/models/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fintr_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('missing file yields empty AppData', () async {
    final storage = JsonFileStorage(directory: tempDir);
    final data = await storage.load();
    expect(data.isEmpty, isTrue);
  });

  test('save then load round-trips data', () async {
    final storage = JsonFileStorage(directory: tempDir);
    final data = AppData(
      categories: const [
        Category(
          id: 'c1',
          name: 'Food',
          monthlyLimit: 500,
          colorValue: 0xFF00FF00,
          iconCodePoint: 0xe000,
        ),
      ],
    );
    await storage.save(data);

    final reloaded = await JsonFileStorage(directory: tempDir).load();
    expect(reloaded.categories.single.name, 'Food');
    expect(reloaded.categories.single.monthlyLimit, 500);
  });

  test('corrupt file falls back to empty AppData', () async {
    final file = File('${tempDir.path}/fintr_data.json');
    await file.writeAsString('{ this is not valid json');
    final data = await JsonFileStorage(directory: tempDir).load();
    expect(data.isEmpty, isTrue);
  });
}
