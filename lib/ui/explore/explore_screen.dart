import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/search_screen.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
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
      body: Column(
        children: const [
          CategoryTabWidget(),
          Divider(height: 1),
          Expanded(child: ExploreListWidget()),
        ],
      ),
    );
  }
}
