import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';

class InfoImage extends StatelessWidget {
  final VideoModel video;
  const InfoImage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: video.thumbnail.startsWith('http')
            ? Image.network(video.thumbnail, fit: BoxFit.cover)
            : Image.asset(video.thumbnail, fit: BoxFit.cover),
      ),
    );
  }
}
