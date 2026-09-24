import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/bloc/explore_bloc.dart';
import 'package:aurovilletv/ui/explore/search_screen.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:aurovilletv/utils/theme/colors.dart';

import 'widgets/category_tab_widget.dart';
import 'widgets/explore_list_widget.dart';

class ExploreScreen extends StatelessWidget {
  final VideoApiService apiService;
  final DBManager dbManager;

  const ExploreScreen({
    super.key,
    required this.apiService,
    required this.dbManager,
  });

  @override
  Widget build(BuildContext context) {
    return _ExploreView(apiService: apiService);
  }
}

class _ExploreView extends StatelessWidget {
  final VideoApiService apiService;

  const _ExploreView({required this.apiService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final List<ConnectivityResult> results = snapshot.data ?? [];
        final bool isConnected = !snapshot.hasData ||
            results.any((result) => result != ConnectivityResult.none);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundColor,
          body: RefreshIndicator(
            color: AppColors.themeColor,
            backgroundColor: Colors.white,
            onRefresh: () async {
              if (isConnected) {
                context.read<ExploreBloc>().add(const RefreshExplore());

                await Future.delayed(const Duration(seconds: 5));
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColors.scaffoldBackgroundColor,
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Explore",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                  actions: [
                    if (isConnected)
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
                        color: AppColors.themeColor,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SearchScreen(apiService: apiService),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                if (!isConnected)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoInternetWidget(
                      onRetry: () {
                        context.read<ExploreBloc>().add(const RefreshExplore());
                      },
                    ),
                  )
                else ...[
                  const SliverToBoxAdapter(
                    child: Column(
                      children: [
                        CategoryTabWidget(),
                        Divider(height: 1),
                      ],
                    ),
                  ),
                  const SliverFillRemaining(
                    child: ExploreListWidget(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoInternetWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppColors.themeColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Internet Connection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please check your network settings and try again to view videos.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text(
                "Try Again",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}