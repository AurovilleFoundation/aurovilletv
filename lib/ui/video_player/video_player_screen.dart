import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/video_details/video_details_screen.dart';

/// Unified wrapper that delegates directly to VideoDetailsScreen.
class VideoPlayerScreen extends StatelessWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return VideoDetailsScreen(video: video);
  }
}
