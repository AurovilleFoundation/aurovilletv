import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';

import 'widgets/watchlist_widget.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WatchlistView();
  }
}

class _WatchlistView extends StatelessWidget {
  const _WatchlistView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Watch list"),
        centerTitle: true,
        elevation: 16,
      ),
      body: const WatchListWidget(),
    );
  }
}
