import 'package:flutter/material.dart';
import '../../video_details/video_details_screen.dart';

class DetailViewBtn extends StatelessWidget {
  final String videoId;

  const DetailViewBtn({
    super.key,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoDetailsScreen(videoId: videoId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFC85A17).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFC85A17).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Details",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC85A17),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 11,
              color: Color(0xFFC85A17),
            ),
          ],
        ),
      ),
    );
  }
}