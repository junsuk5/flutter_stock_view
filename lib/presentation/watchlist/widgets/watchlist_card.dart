import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/price_point.dart';
import '../../../domain/models/stock_interval.dart';
import '../../../domain/models/stock_ticker.dart';

class WatchlistCard extends StatelessWidget {
  WatchlistCard({super.key, required this.ticker, required this.interval});

  final StockTicker ticker;
  final StockInterval interval;

  final NumberFormat _priceFormat = NumberFormat.simpleCurrency(name: 'USD');

  @override
  Widget build(BuildContext context) {
    final chartColor = ticker.isGain
        ? Colors.greenAccent.shade400
        : Colors.redAccent.shade200;
    final points = ticker.seriesFor(interval);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticker.symbol,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticker.companyName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _priceFormat.format(ticker.currentPrice),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    _buildChangeBadge(context),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (points.isNotEmpty)
              SizedBox(
                height: 120,
                child: LineChart(_buildChartData(points, chartColor)),
              )
            else
              const Text('차트 데이터를 불러오지 못했습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGain = ticker.isGain;
    final background = isGain
        ? colorScheme.secondaryContainer
        : colorScheme.errorContainer;
    final textColor = isGain
        ? colorScheme.onSecondaryContainer
        : colorScheme.onErrorContainer;

    final sign = isGain ? '+' : '';
    final changeText = '$sign${ticker.changePercent.toStringAsFixed(2)}%';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          changeText,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  LineChartData _buildChartData(List<PricePoint> points, Color chartColor) {
    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int index = 0; index < points.length; index++) {
      final value = points[index].close;
      spots.add(FlSpot(index.toDouble(), value));
      minY = value < minY ? value : minY;
      maxY = value > maxY ? value : maxY;
    }

    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(enabled: false),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          gradient: LinearGradient(
            colors: [chartColor, chartColor.withOpacity(0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                chartColor.withOpacity(0.3),
                chartColor.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
