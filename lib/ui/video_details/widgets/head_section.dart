import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';

class HeadSection extends StatelessWidget {
  final VideoModel video;
  const HeadSection({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            video.thumbnail ?? "",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          video.title,
          style: Theme.of(context).textTheme.titleLarge, // ✅ fixed
        ),
      ],
    );
  }
}
