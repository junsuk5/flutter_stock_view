import 'package:flutter/foundation.dart';

import '../../domain/models/price_point.dart';
import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';
import '../../domain/repositories/stock_repository.dart';
import 'watchlist_state.dart';

class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel({required StockRepository repository})
    : _repository = repository,
      _state = WatchlistState.initial();

  final StockRepository _repository;

  WatchlistState _state;
  final Set<String> _watchlistSymbols = <String>{};

  WatchlistState get state => _state;

  List<StockTicker> get watchlist => _state.watchlist;
  StockInterval get selectedInterval => _state.interval;

  Future<void> load() async {
    _setState(
      _state.copyWith(status: WatchlistStatus.loading, clearError: true),
    );

    try {
      final tickers = await _repository.fetchWatchlist();
      _watchlistSymbols
        ..clear()
        ..addAll(tickers.map((ticker) => ticker.symbol.toUpperCase()));
      _setState(
        _state.copyWith(
          status: WatchlistStatus.ready,
          watchlist: List<StockTicker>.unmodifiable(tickers),
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void changeInterval(StockInterval interval) {
    if (interval == _state.interval) {
      return;
    }
    _setState(_state.copyWith(interval: interval));
  }

  bool isInWatchlist(String symbol) {
    return _watchlistSymbols.contains(symbol.toUpperCase());
  }

  Future<void> addToWatchlist(String symbol) async {
    final normalized = symbol.toUpperCase();
    if (_watchlistSymbols.contains(normalized)) {
      return;
    }

    try {
      await _repository.addToWatchlist(normalized);
      await load();
    } catch (error) {
      _setState(
        _state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final normalized = symbol.toUpperCase();
    if (!_watchlistSymbols.contains(normalized)) {
      return;
    }

    try {
      await _repository.removeFromWatchlist(normalized);
      await load();
    } catch (error) {
      _setState(
        _state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> search(String query) async {
    _setState(_state.copyWith(isSearching: true, searchQuery: query));

    try {
      final results = await _repository.searchTickers(query);
      _setState(
        _state.copyWith(
          isSearching: false,
          searchResults: List<StockTicker>.unmodifiable(results),
          clearError: true,
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          isSearching: false,
          status: WatchlistStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void clearSearch() {
    if (_state.searchQuery.isEmpty && _state.searchResults.isEmpty) {
      return;
    }

    _setState(
      _state.copyWith(
        searchQuery: '',
        searchResults: const <StockTicker>[],
        isSearching: false,
      ),
    );
  }

  Future<List<PricePoint>> loadSeriesForTicker(
    String symbol,
    StockInterval interval,
  ) async {
    try {
      return await _repository.fetchTimeSeries(symbol, interval);
    } catch (_) {
      return const [];
    }
  }

  void _setState(WatchlistState newState) {
    _state = newState;
    notifyListeners();
  }
}
