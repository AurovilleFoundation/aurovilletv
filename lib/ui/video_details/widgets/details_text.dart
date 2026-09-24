import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';

class DetailsText extends StatelessWidget {
  final VideoModel video;

  const DetailsText({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "About this broadcast",
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          video.description.isNotEmpty
              ? video.description
              : "The title card remains visible below the player throughout the visit, helping viewers identify and understand the programme being broadcast.",
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}