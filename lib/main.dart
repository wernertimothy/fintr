import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/finance_repository.dart';
import 'data/json_file_storage.dart';
import 'screens/dashboard_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository(JsonFileStorage());
  await repository.init();
  runApp(FintrApp(repository: repository));
}

class FintrApp extends StatelessWidget {
  const FintrApp({super.key, required this.repository});

  final FinanceRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: repository,
      child: Consumer<FinanceRepository>(
        builder: (context, repo, _) => MaterialApp(
          title: 'Fintr',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: repo.themeMode,
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
