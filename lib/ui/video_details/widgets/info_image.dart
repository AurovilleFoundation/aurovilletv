import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';

class InfoImage extends StatelessWidget {
  final VideoModel video;

  const InfoImage({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 150,
        height: 120,
        child: video.thumbnail.isNotEmpty && video.thumbnail.startsWith('http')
            ? Image.network(
                video.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            : Image.asset(
                video.thumbnail,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}