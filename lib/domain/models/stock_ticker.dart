import 'price_point.dart';
import 'stock_interval.dart';

class StockTicker {
  const StockTicker({
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.changePercent,
    required this.series,
  });

  final String symbol;
  final String companyName;
  final double currentPrice;
  final double changePercent;
  final Map<StockInterval, List<PricePoint>> series;

  bool get isGain => changePercent >= 0;

  List<PricePoint> seriesFor(StockInterval interval) {
    return series[interval] ?? const [];
  }

  StockTicker copyWith({
    String? symbol,
    String? companyName,
    double? currentPrice,
    double? changePercent,
    Map<StockInterval, List<PricePoint>>? series,
  }) {
    return StockTicker(
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      currentPrice: currentPrice ?? this.currentPrice,
      changePercent: changePercent ?? this.changePercent,
      series: series ?? this.series,
    );
  }
}
