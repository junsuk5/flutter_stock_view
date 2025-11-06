import '../data/repositories/fake_stock_repository.dart';
import '../domain/repositories/stock_repository.dart';

class AppDependencies {
  AppDependencies({required this.stockRepository});

  final StockRepository stockRepository;

  factory AppDependencies.fake() {
    return AppDependencies(stockRepository: FakeStockRepository());
  }
}
