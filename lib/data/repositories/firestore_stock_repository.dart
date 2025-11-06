
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/price_point.dart';
import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';
import '../../domain/repositories/stock_repository.dart';
import 'fake_stock_repository.dart';

class FirestoreStockRepository implements StockRepository {
  FirestoreStockRepository({
    required this.firestore,
  }) : _fakeRepository = FakeStockRepository();

  final FirebaseFirestore firestore;
  final StockRepository _fakeRepository;

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
  Future<StockTicker> fetchTicker(String symbol) {
    return _fakeRepository.fetchTicker(symbol);
  }

  @override
  Future<List<PricePoint>> fetchTimeSeries(String symbol, StockInterval interval) {
    return _fakeRepository.fetchTimeSeries(symbol, interval);
  }

  @override
  Future<List<StockTicker>> searchTickers(String query) {
    return _fakeRepository.searchTickers(query);
  }
}
