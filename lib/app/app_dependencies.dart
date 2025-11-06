import 'package:cloud_firestore/cloud_firestore.dart';

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
    return AppDependencies(
      stockRepository: FirestoreStockRepository(
        firestore: FirebaseFirestore.instance,
      ),
    );
  }
}
