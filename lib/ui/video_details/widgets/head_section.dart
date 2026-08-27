import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';

class HeadSection extends StatelessWidget {
  final VideoModel video;
  const HeadSection({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(video.title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          if (video.category != null)
            Text(video.category!,
                style: const TextStyle(
                    fontSize: 14, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
