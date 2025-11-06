
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../domain/models/price_point.dart';
import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';
import '../../domain/repositories/stock_repository.dart';
import '../datasources/alpha_vantage_data_source.dart';

class FirestoreStockRepository implements StockRepository {
  FirestoreStockRepository({
    required this.firestore,
    required this.alphaVantageDataSource,
  });

  final FirebaseFirestore firestore;
  final AlphaVantageDataSource alphaVantageDataSource;
  final Map<String, StockTicker> _tickerCache = {};

  static const String _watchlistCollection = 'watchlist';

  @override
  Future<List<StockTicker>> fetchWatchlist() async {
    final snapshot = await firestore.collection(_watchlistCollection).get();
    final symbols = snapshot.docs.map((doc) => doc.id).toList();
    
    final tickers = <StockTicker>[];
    for (final symbol in symbols) {
      try {
        final ticker = await fetchTicker(symbol);
        tickers.add(ticker);
      } catch (e) {
        // Ignore if a ticker fails to load
      }
    }
    return tickers;
  }

  @override
  Future<void> addToWatchlist(String symbol) async {
    await firestore
        .collection(_watchlistCollection)
        .doc(symbol.toUpperCase())
        .set({'added_at': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> removeFromWatchlist(String symbol) async {
    await firestore
        .collection(_watchlistCollection)
        .doc(symbol.toUpperCase())
        .delete();
  }

  @override
  Future<StockTicker> fetchTicker(String symbol) async {
    final upperSymbol = symbol.toUpperCase();

    // 캐시 확인
    if (_tickerCache.containsKey(upperSymbol)) {
      return _tickerCache[upperSymbol]!;
    }

    try {
      final ticker = await alphaVantageDataSource.fetchTicker(upperSymbol);
      _tickerCache[upperSymbol] = ticker;
      return ticker;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PricePoint>> fetchTimeSeries(String symbol, StockInterval interval) async {
    try {
      return await alphaVantageDataSource.fetchTimeSeries(symbol, interval);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<StockTicker>> searchTickers(String query) async {
    try {
      return await alphaVantageDataSource.searchTickers(query);
    } catch (e) {
      rethrow;
    }
  }

  void clearCache() {
    _tickerCache.clear();
  }
}
