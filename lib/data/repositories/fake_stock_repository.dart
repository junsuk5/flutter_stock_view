import '../../domain/models/price_point.dart';
import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/fake_stock_data.dart';

class FakeStockRepository implements StockRepository {
  FakeStockRepository({FakeStockDataSource? dataSource})
    : _dataSource = dataSource ?? FakeStockDataSource();

  final FakeStockDataSource _dataSource;

  @override
  Future<List<StockTicker>> fetchWatchlist() async {
    return _dataSource.watchlistTickers;
  }

  @override
  Future<StockTicker> fetchTicker(String symbol) async {
    return _dataSource.requireTicker(symbol);
  }

  @override
  Future<List<StockTicker>> searchTickers(String query) async {
    return _dataSource.search(query);
  }

  @override
  Future<List<PricePoint>> fetchTimeSeries(
    String symbol,
    StockInterval interval,
  ) async {
    final ticker = _dataSource.requireTicker(symbol);
    return ticker.seriesFor(interval);
  }
}
