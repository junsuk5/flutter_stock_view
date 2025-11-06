import 'dart:math' as math;

import '../../domain/models/price_point.dart';
import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';

class FakeStockDataSource {
  FakeStockDataSource() : _tickers = _buildTickers();

  final Map<String, StockTicker> _tickers;

  static const List<String> defaultWatchlist = ['AAPL', 'TSLA', 'MSFT'];

  List<StockTicker> get watchlistTickers =>
      defaultWatchlist.map(requireTicker).toList();

  StockTicker requireTicker(String symbol) {
    final ticker = _tickers[symbol.toUpperCase()];
    if (ticker == null) {
      throw StateError('Unknown ticker symbol: $symbol');
    }
    return ticker;
  }

  List<StockTicker> search(String query) {
    if (query.isEmpty) {
      return _tickers.values.toList(growable: false);
    }

    final lowerQuery = query.toLowerCase();
    return _tickers.values
        .where(
          (ticker) =>
              ticker.symbol.toLowerCase().contains(lowerQuery) ||
              ticker.companyName.toLowerCase().contains(lowerQuery),
        )
        .toList(growable: false);
  }

  static Map<String, StockTicker> _buildTickers() {
    final now = DateTime.now();
    return {
      'AAPL': _buildTicker(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        currentPrice: 195.48,
        changePercent: 1.24,
        basePrice: 192,
        now: now,
      ),
      'TSLA': _buildTicker(
        symbol: 'TSLA',
        companyName: 'Tesla Inc.',
        currentPrice: 256.12,
        changePercent: -0.84,
        basePrice: 260,
        now: now,
      ),
      'MSFT': _buildTicker(
        symbol: 'MSFT',
        companyName: 'Microsoft Corp.',
        currentPrice: 345.76,
        changePercent: 0.92,
        basePrice: 340,
        now: now,
      ),
      'GOOGL': _buildTicker(
        symbol: 'GOOGL',
        companyName: 'Alphabet Inc.',
        currentPrice: 132.45,
        changePercent: 1.67,
        basePrice: 128,
        now: now,
      ),
      'AMZN': _buildTicker(
        symbol: 'AMZN',
        companyName: 'Amazon.com Inc.',
        currentPrice: 142.21,
        changePercent: 0.58,
        basePrice: 140,
        now: now,
      ),
      'NVDA': _buildTicker(
        symbol: 'NVDA',
        companyName: 'NVIDIA Corp.',
        currentPrice: 452.39,
        changePercent: 2.12,
        basePrice: 430,
        now: now,
      ),
    };
  }

  static StockTicker _buildTicker({
    required String symbol,
    required String companyName,
    required double currentPrice,
    required double changePercent,
    required double basePrice,
    required DateTime now,
  }) {
    Map<StockInterval, List<double>> rawSeries = {
      StockInterval.day: _sineWave(basePrice, 6, 3.2),
      StockInterval.week: _sineWave(basePrice, 7, 5.5),
      StockInterval.month: _sineWave(basePrice, 8, 8.3),
      StockInterval.year: _sineWave(basePrice, 12, 15.6),
    };

    final Map<StockInterval, List<PricePoint>> series = {
      for (final entry in rawSeries.entries)
        entry.key: _mapToPoints(entry.value, now, _stepOf(entry.key)),
    };

    return StockTicker(
      symbol: symbol,
      companyName: companyName,
      currentPrice: currentPrice,
      changePercent: changePercent,
      series: series,
    );
  }

  static List<double> _sineWave(double base, int count, double amplitude) {
    return List<double>.generate(count, (index) {
      final angle = index / (count - 1) * math.pi;
      final delta = math.sin(angle) * amplitude;
      final value = base + delta;
      return double.parse(value.toStringAsFixed(2));
    });
  }

  static List<PricePoint> _mapToPoints(
    List<double> values,
    DateTime now,
    Duration step,
  ) {
    final points = <PricePoint>[];
    for (int index = 0; index < values.length; index++) {
      final offset = values.length - 1 - index;
      final diff = Duration(seconds: step.inSeconds * offset);
      points.add(PricePoint(time: now.subtract(diff), close: values[index]));
    }
    return points;
  }

  static Duration _stepOf(StockInterval interval) {
    switch (interval) {
      case StockInterval.day:
        return const Duration(hours: 4);
      case StockInterval.week:
        return const Duration(days: 1);
      case StockInterval.month:
        return const Duration(days: 7);
      case StockInterval.year:
        return const Duration(days: 30);
    }
  }
}
