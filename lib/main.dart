import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/inventory_provider.dart';
import 'screens/hub_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PaperPlanApp());
}

class PaperPlanApp extends StatelessWidget {
  const PaperPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider(),
      child: MaterialApp(
        title: 'PaperPlan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.notebookTheme,
        home: const HubScreen(),
      ),
    );
  }
}
