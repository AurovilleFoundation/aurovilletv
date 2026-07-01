import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aurovilletv/ui/explore/explore_screen.dart';
import 'package:aurovilletv/ui/home/home_screen.dart';
import 'package:aurovilletv/ui/live/live_screen.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/ui/main/widgets/bottom_navbar_widget.dart';
import 'package:aurovilletv/ui/watchlist/watchlist_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<Widget> pages = [
    const HomeScreen(),
    const LiveScreen(),
    ExploreScreen(
      dbManager: getIt<DBManager>(),
      apiService: getIt<VideoApiService>(),
    ),
    const WatchlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(index: state.currentIndex, children: pages),
          bottomNavigationBar: BottomNavBarWidget(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(TabChanged(index));
            },
          ),
        );
      },
    );
  }
}
