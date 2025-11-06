import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/datasources/alpha_vantage_data_source.dart';
import '../data/repositories/fake_stock_repository.dart';
import '../data/repositories/firestore_stock_repository.dart';
import '../domain/repositories/stock_repository.dart';

class AppDependencies {
  AppDependencies({required this.stockRepository});

  final StockRepository stockRepository;

  factory AppDependencies.fake() {
    return AppDependencies(stockRepository: FakeStockRepository());
  }

  factory AppDependencies.production() {
    final apiKey = dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? '';

    if (apiKey.isEmpty) {
      throw Exception(
        'ALPHA_VANTAGE_API_KEY not found in .env file. '
        'Please add your API key to the .env file.',
      );
    }

    final alphaVantageDataSource = AlphaVantageDataSource(apiKey: apiKey);

    return AppDependencies(
      stockRepository: FirestoreStockRepository(
        firestore: FirebaseFirestore.instance,
        alphaVantageDataSource: alphaVantageDataSource,
      ),
    );
  }
}
