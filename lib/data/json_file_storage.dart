import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/app_data.dart';
import 'storage.dart';

/// Stores all data in a single JSON file in the app's private documents
/// directory. Writes are atomic (tmp file + rename) to survive a crash
/// mid-write.
class JsonFileStorage implements Storage {
  JsonFileStorage({this.fileName = 'fintr_data.json', Directory? directory})
      : _directoryOverride = directory;

  final String fileName;

  /// Used by tests to point at a temp directory instead of the documents dir.
  final Directory? _directoryOverride;

  File? _cachedFile;

  Future<File> _file() async {
    if (_cachedFile != null) return _cachedFile!;
    final dir = _directoryOverride ?? await getApplicationDocumentsDirectory();
    return _cachedFile = File('${dir.path}/$fileName');
  }

  @override
  Future<AppData> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return AppData();
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return AppData();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return AppData.fromJson(json);
    } catch (_) {
      // Corrupt or unreadable file: fall back to empty rather than crashing.
      return AppData();
    }
  }

  @override
  Future<void> save(AppData data) async {
    final file = await _file();
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data.toJson()), flush: true);
    await tmp.rename(file.path);
  }
}
