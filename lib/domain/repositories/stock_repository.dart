import '../models/price_point.dart';
import '../models/stock_interval.dart';
import '../models/stock_ticker.dart';

abstract class StockRepository {
  Future<List<StockTicker>> fetchWatchlist();
  Future<StockTicker> fetchTicker(String symbol);
  Future<List<StockTicker>> searchTickers(String query);
  Future<List<PricePoint>> fetchTimeSeries(
    String symbol,
    StockInterval interval,
  );
}
