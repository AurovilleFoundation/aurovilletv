import 'package:flutter/material.dart';
  import 'package:aurovilletv/data/models/video_model.dart';

class DetailsText extends StatelessWidget {
  final VideoModel video;
  const DetailsText({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        video.description,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
