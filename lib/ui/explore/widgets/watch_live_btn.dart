import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/live/live_detail_screen.dart';

class WatchLiveBtn extends StatelessWidget {
  final VideoModel video;

  const WatchLiveBtn({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveDetailScreen(
              liveStream: video.toLiveStreamModel(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 3.5,
              backgroundColor: Color(0xFFE53935),
            ),
            SizedBox(width: 6),
            Text(
              "Watch Live",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE53935),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.play_arrow_rounded,
              size: 14,
              color: Color(0xFFE53935),
            ),
          ],
        ),
      ),
    );
  }
}
