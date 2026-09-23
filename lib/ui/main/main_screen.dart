import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/explore_screen.dart';
import 'package:aurovilletv/ui/home/home_screen.dart';
import 'package:aurovilletv/ui/live/live_screen.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/ui/main/widgets/bottom_navbar_widget.dart';
import 'package:aurovilletv/ui/watchlist/watchlist_screen.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime? _lastBackPressTime;

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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            // If user is on any tab other than Home, navigate back to Home
            if (state.currentIndex != 0) {
              context.read<NavigationBloc>().add(const TabChanged(0));
              return;
            }

            // If already on Home tab, require double-press to exit to avoid accidental exits
            final now = DateTime.now();
            if (_lastBackPressTime == null ||
                now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
              _lastBackPressTime = now;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Press back again to exit"),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            // User pressed back twice within 2 seconds while on Home -> exit cleanly
            SystemNavigator.pop();
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: IndexedStack(index: state.currentIndex, children: pages),
            bottomNavigationBar: BottomNavBarWidget(
              currentIndex: state.currentIndex,
              onTap: (index) {
                context.read<NavigationBloc>().add(TabChanged(index));
              },
            ),
          ),
        );
      },
    );
  }
}
