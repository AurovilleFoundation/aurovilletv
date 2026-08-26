import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/search_screen.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor, 
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.scaffoldBackgroundColor, 
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Back to Home',
              color: AppColors.themeColor, 
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Explore",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkColor, 
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                color: AppColors.themeColor, 
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(apiService: apiService),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: const [
                CategoryTabWidget(),
                Divider(height: 1),
              ],
            ),
          ),
          const SliverFillRemaining(
            child: ExploreListWidget(),
          ),
        ],
      ),
    );
  }
}
