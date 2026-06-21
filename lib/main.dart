import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/finance_repository.dart';
import 'data/json_file_storage.dart';
import 'screens/dashboard_screen.dart';

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
      child: MaterialApp(
        title: 'Fintr',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
