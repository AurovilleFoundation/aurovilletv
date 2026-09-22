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
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Watchlist",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkColor,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: const Color(0xFFE2D6CA),
                height: 1.0,
              ),
            ),
          ),
          const SliverFillRemaining(
            child: WatchListWidget(),
          ),
        ],
      ),
    );
  }
}