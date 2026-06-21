import '../models/app_data.dart';

/// Persistence boundary for the app's data.
///
/// The rest of the app only talks to the repository, which in turn only talks
/// to this interface. Swapping JSON for SQLite later is a single new
/// implementation + one constructor change — no UI or repository logic moves.
abstract class Storage {
  /// Loads the full dataset. Returns empty [AppData] if nothing is stored yet.
  Future<AppData> load();

  /// Overwrites the full dataset.
  Future<void> save(AppData data);
}
