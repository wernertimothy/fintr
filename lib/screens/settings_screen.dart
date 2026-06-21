import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/finance_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Bumped after export/import to refresh the "last backup" subtitle.
  int _refreshTick = 0;

  /// Last-modified time of the local backup file, or null if none exists.
  Future<DateTime?> _lastBackupTime() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = FinanceRepository.backupFile(dir);
    if (!await file.exists()) return null;
    return file.lastModified();
  }

  Future<void> _export() async {
    final repo = context.read<FinanceRepository>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dir = await getApplicationDocumentsDirectory();
      await repo.exportToFile(dir);
      if (mounted) setState(() => _refreshTick++);
      messenger.showSnackBar(
        const SnackBar(content: Text('Backup saved.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _import() async {
    final repo = context.read<FinanceRepository>();
    final messenger = ScaffoldMessenger.of(context);

    final dir = await getApplicationDocumentsDirectory();
    final file = FinanceRepository.backupFile(dir);
    if (!await file.exists()) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No backup found.')),
      );
      return;
    }

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text(
          'Importing overwrites your current categories and expenses with '
          'the contents of the local backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await repo.importFromFile(file);
      messenger.showSnackBar(
        const SnackBar(content: Text('Backup restored.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Restore failed: not a valid backup ($e)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const _ThemeModeSelector(),
          const Divider(height: 24),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Backup (stored in the app folder)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: const Text('Export data'),
            subtitle: const Text('Save a backup to the app folder'),
            onTap: _export,
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('Import data'),
            subtitle: FutureBuilder<DateTime?>(
              key: ValueKey(_refreshTick),
              future: _lastBackupTime(),
              builder: (context, snapshot) {
                final time = snapshot.data;
                if (time == null) return const Text('No backup yet');
                final formatted =
                    DateFormat.yMMMd().add_Hm().format(time);
                return Text('Restore backup from $formatted');
              },
            ),
            onTap: _import,
          ),
        ],
      ),
    );
  }
}

/// System / Light / Dark theme picker wired to the repository.
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FinanceRepository>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            label: Text('System'),
            icon: Icon(Icons.brightness_auto_outlined),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode_outlined),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode_outlined),
          ),
        ],
        selected: {repo.themeMode},
        showSelectedIcon: false,
        onSelectionChanged: (selection) =>
            repo.setThemeMode(selection.first),
      ),
    );
  }
}
