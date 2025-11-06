import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/price_point.dart';
import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';

class AlphaVantageDataSource {
  AlphaVantageDataSource({
    required this.apiKey,
    this.httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiKey;
  final http.Client? httpClient;
  late final http.Client _httpClient;

  static const String _baseUrl = 'https://www.alphavantage.co/query';

  Future<StockTicker> fetchTicker(String symbol) async {
    // GLOBAL_QUOTE로 현재 가격 정보 조회
    final quoteResponse = await _fetchGlobalQuote(symbol);

    // 일일 데이터로 기본 시계열 정보 조회
    final timeSeriesResponse = await _fetchTimeSeries(
      symbol,
      StockInterval.day,
    );

    final companyName = quoteResponse['01. symbol'] ?? symbol;
    final currentPrice = double.tryParse(
      quoteResponse['05. price'] ?? '0',
    ) ?? 0.0;
    final changePercent = double.tryParse(
      quoteResponse['10. change percent'] ?? '0',
    ) ?? 0.0;

    final series = <StockInterval, List<PricePoint>>{};

    // DAILY 데이터 파싱
    if (timeSeriesResponse['Time Series (Daily)'] != null) {
      series[StockInterval.day] = _parseDailyData(
        timeSeriesResponse['Time Series (Daily)'],
      );
    }

    return StockTicker(
      symbol: symbol.toUpperCase(),
      companyName: companyName,
      currentPrice: currentPrice,
      changePercent: changePercent,
      series: series,
    );
  }

  Future<List<PricePoint>> fetchTimeSeries(
    String symbol,
    StockInterval interval,
  ) async {
    final response = await _fetchTimeSeries(symbol, interval);

    switch (interval) {
      case StockInterval.day:
        return _parseDailyData(response['Time Series (Daily)'] ?? {});
      case StockInterval.week:
        return _parseWeeklyData(response['Time Series (Weekly)'] ?? {});
      case StockInterval.month:
        return _parseMonthlyData(response['Time Series (Monthly)'] ?? {});
      case StockInterval.year:
        return _parseDailyData(response['Time Series (Daily)'] ?? {});
    }
  }

  Future<List<StockTicker>> searchTickers(String query) async {
    final params = {
      'function': 'SYMBOL_SEARCH',
      'keywords': query,
      'apikey': apiKey,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to search tickers: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (json['bestMatches'] as List<dynamic>?) ?? [];

    final tickers = <StockTicker>[];
    for (final result in results) {
      final symbol = result['1. symbol'] as String?;
      if (symbol != null && symbol.isNotEmpty) {
        try {
          final ticker = await fetchTicker(symbol);
          tickers.add(ticker);
        } catch (e) {
          // Skip if ticker fetch fails
        }
      }
    }

    return tickers;
  }

  Future<Map<String, dynamic>> _fetchGlobalQuote(String symbol) async {
    final params = {
      'function': 'GLOBAL_QUOTE',
      'symbol': symbol,
      'apikey': apiKey,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch global quote: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final quote = (json['Global Quote'] as Map<String, dynamic>?) ?? {};

    if (quote.isEmpty) {
      throw Exception('Symbol not found: $symbol');
    }

    return quote;
  }

  Future<Map<String, dynamic>> _fetchTimeSeries(
    String symbol,
    StockInterval interval,
  ) async {
    final function = _getFunction(interval);

    final params = {
      'function': function,
      'symbol': symbol,
      'apikey': apiKey,
    };

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch time series: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json.containsKey('Error Message')) {
      throw Exception(json['Error Message']);
    }

    if (json.containsKey('Note')) {
      throw Exception('API rate limit reached. Please try again later.');
    }

    return json;
  }

  String _getFunction(StockInterval interval) {
    switch (interval) {
      case StockInterval.day:
        return 'TIME_SERIES_DAILY';
      case StockInterval.week:
        return 'TIME_SERIES_WEEKLY';
      case StockInterval.month:
        return 'TIME_SERIES_MONTHLY';
      case StockInterval.year:
        return 'TIME_SERIES_DAILY';
    }
  }

  List<PricePoint> _parseDailyData(Map<String, dynamic> data) {
    final points = <PricePoint>[];

    data.forEach((dateStr, priceData) {
      try {
        final date = DateTime.parse(dateStr);
        final closePrice = double.tryParse(
          (priceData as Map<String, dynamic>)['4. close'] ?? '0',
        ) ?? 0.0;

        points.add(PricePoint(time: date, close: closePrice));
      } catch (e) {
        // Skip invalid entries
      }
    });

    // 최신순으로 정렬
    points.sort((a, b) => b.time.compareTo(a.time));
    return points;
  }

  List<PricePoint> _parseWeeklyData(Map<String, dynamic> data) {
    return _parseDailyData(data); // Weekly 데이터도 동일한 형식
  }

  List<PricePoint> _parseMonthlyData(Map<String, dynamic> data) {
    return _parseDailyData(data); // Monthly 데이터도 동일한 형식
  }
}
