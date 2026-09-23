import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/search_screen.dart';
import 'package:aurovilletv/ui/explore/widgets/category_tab_widget.dart';
import 'package:aurovilletv/ui/explore/widgets/explore_list_widget.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: const Text(
          "Explore",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.earthColor),
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
      body: const Column(
        children: [
          CategoryTabWidget(),
          Expanded(child: ExploreListWidget()),
        ],
      ),
    );
  }
}
