import 'package:flutter/material.dart';

import '../../../domain/models/stock_ticker.dart';
import '../watchlist_view_model.dart';

class WatchlistSearchSheet extends StatefulWidget {
  const WatchlistSearchSheet({super.key, required this.viewModel});

  final WatchlistViewModel viewModel;

  @override
  State<WatchlistSearchSheet> createState() => _WatchlistSearchSheetState();
}

class _WatchlistSearchSheetState extends State<WatchlistSearchSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.clearSearch();
      widget.viewModel.search('');
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.viewModel.clearSearch();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '티커 검색',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '티커 또는 회사명을 입력하세요',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            widget.viewModel.search('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
                onChanged: widget.viewModel.search,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, _) {
                    final state = widget.viewModel.state;

                    if (state.isSearching) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.searchResults.isEmpty) {
                      return const Center(child: Text('검색 결과가 없습니다.'));
                    }

                    return ListView.separated(
                      itemCount: state.searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final ticker = state.searchResults[index];
                        final isAdded = widget.viewModel.isInWatchlist(
                          ticker.symbol,
                        );
                        return ListTile(
                          title: Text(
                            '${ticker.symbol} • ${ticker.companyName}',
                          ),
                          subtitle: Text(
                            '현재가: ${ticker.currentPrice.toStringAsFixed(2)}',
                          ),
                          trailing: isAdded
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      _selectTicker(context, ticker),
                                ),
                          onTap: isAdded
                              ? null
                              : () => _selectTicker(context, ticker),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTicker(BuildContext context, StockTicker ticker) {
    Navigator.pop(context, ticker);
  }
}
