import 'package:flutter/foundation.dart';

import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';

enum WatchlistStatus { idle, loading, ready, error }

@immutable
class WatchlistState {
  const WatchlistState({
    required this.status,
    required this.watchlist,
    required this.interval,
    required this.searchResults,
    required this.isSearching,
    required this.searchQuery,
    this.errorMessage,
  });

  factory WatchlistState.initial() {
    return WatchlistState(
      status: WatchlistStatus.idle,
      watchlist: const <StockTicker>[],
      interval: StockInterval.day,
      searchResults: const <StockTicker>[],
      isSearching: false,
      searchQuery: '',
    );
  }

  final WatchlistStatus status;
  final List<StockTicker> watchlist;
  final StockInterval interval;
  final List<StockTicker> searchResults;
  final bool isSearching;
  final String searchQuery;
  final String? errorMessage;

  bool get hasError => errorMessage != null;

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<StockTicker>? watchlist,
    StockInterval? interval,
    List<StockTicker>? searchResults,
    bool? isSearching,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      watchlist: watchlist ?? this.watchlist,
      interval: interval ?? this.interval,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
