import 'package:flutter_test/flutter_test.dart';

import 'package:stock_view/data/repositories/fake_stock_repository.dart';
import 'package:stock_view/domain/models/stock_interval.dart';

void main() {
  group('FakeStockRepository', () {
    late FakeStockRepository repository;

    setUp(() {
      repository = FakeStockRepository();
    });

    test('fetchWatchlist returns default watchlist', () async {
      final result = await repository.fetchWatchlist();
      expect(result, isNotEmpty);
      expect(
        result.map((ticker) => ticker.symbol),
        containsAll(['AAPL', 'TSLA', 'MSFT']),
      );
    });

    test('searchTickers returns matching symbol or company name', () async {
      final result = await repository.searchTickers('apple');
      expect(result, isNotEmpty);
      expect(result.first.symbol, 'AAPL');
    });

    test('fetchTimeSeries provides data for each interval', () async {
      for (final interval in StockInterval.values) {
        final series = await repository.fetchTimeSeries('AAPL', interval);
        expect(series, isNotEmpty);
      }
    });
  });
}
