import 'package:flutter/material.dart';

import '../presentation/home/stock_home.dart';
import 'app_dependencies.dart';

class StockViewApp extends StatelessWidget {
  const StockViewApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockView',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: StockHome(dependencies: dependencies),
    );
  }
}
