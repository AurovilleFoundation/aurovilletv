import 'package:flutter/material.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/utils/dbmanager.dart';

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
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Explore Screen",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "Teammate code will be pushed here.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
