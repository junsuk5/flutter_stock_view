import 'package:flutter/material.dart';

import '../../domain/models/stock_interval.dart';
import '../../domain/models/stock_ticker.dart';
import 'watchlist_state.dart';
import 'watchlist_view_model.dart';
import 'widgets/watchlist_card.dart';
import 'widgets/watchlist_search_sheet.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key, required this.viewModel});

  final WatchlistViewModel viewModel;

  static const Map<StockInterval, String> _intervalLabels = {
    StockInterval.day: '1D',
    StockInterval.week: '1W',
    StockInterval.month: '1M',
    StockInterval.year: '1Y',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        return RefreshIndicator(
          onRefresh: viewModel.load,
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WatchlistState state) {
    if (state.status == WatchlistStatus.loading && state.watchlist.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (state.status == WatchlistStatus.error && state.watchlist.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 160),
          _buildError(context, state.errorMessage ?? '데이터를 불러오지 못했습니다.'),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        FilledButton.icon(
          onPressed: () => _openSearch(context),
          icon: const Icon(Icons.add),
          label: const Text('Search & Add'),
        ),
        const SizedBox(height: 16),
        _buildIntervalSelector(context, state),
        const SizedBox(height: 24),
        if (state.status == WatchlistStatus.error)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildInlineError(context, state.errorMessage!),
          ),
        if (state.watchlist.isEmpty)
          _buildEmptyState(context)
        else
          ...state.watchlist.map(
            (ticker) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WatchlistCard(ticker: ticker, interval: state.interval),
            ),
          ),
      ],
    );
  }

  Widget _buildIntervalSelector(BuildContext context, WatchlistState state) {
    return Wrap(
      spacing: 12,
      children: StockInterval.values.map((interval) {
        final selected = interval == state.interval;
        return ChoiceChip(
          label: Text(_intervalLabels[interval]!),
          selected: selected,
          onSelected: (_) => viewModel.changeInterval(interval),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.playlist_add,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('관심 종목을 추가해 보세요.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Search & Add 버튼을 눌러 티커를 검색할 수 있습니다.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => viewModel.load(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(BuildContext context, String message) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    final selected = await showModalBottomSheet<StockTicker?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return WatchlistSearchSheet(viewModel: viewModel);
      },
    );

    if (selected != null) {
      await viewModel.addToWatchlist(selected.symbol);
    }
  }
}
