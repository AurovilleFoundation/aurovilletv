import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkColor),
          tooltip: "Back to Home",
          onPressed: () {
            context.read<NavigationBloc>().add(const TabChanged(0));
          },
        ),
        title: const Text("Watch list"),
        centerTitle: true,
        elevation: 0,
      ),
      body: const WatchListWidget(),
    );
  }
}
