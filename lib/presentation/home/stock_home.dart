import 'package:flutter/material.dart';

import '../../app/app_dependencies.dart';
import '../watchlist/watchlist_page.dart';
import '../watchlist/watchlist_view_model.dart';

class StockHome extends StatefulWidget {
  const StockHome({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<StockHome> createState() => _StockHomeState();
}

class _StockHomeState extends State<StockHome> {
  late final WatchlistViewModel _watchlistViewModel;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _watchlistViewModel = WatchlistViewModel(
      repository: widget.dependencies.stockRepository,
    )..load();
  }

  @override
  void dispose() {
    _watchlistViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StockView')),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WatchlistPage(viewModel: _watchlistViewModel),
          const _PlaceholderTab(label: 'Insights'),
          const _PlaceholderTab(label: 'Portfolio'),
          const _PlaceholderTab(label: 'Settings'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label 화면은 준비 중입니다.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
