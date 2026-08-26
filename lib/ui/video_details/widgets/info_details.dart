import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
  import 'package:aurovilletv/data/models/video_model.dart';

class InfoDetails extends StatelessWidget {
  final VideoModel video;
  const InfoDetails({super.key, required this.video});

  String formatDuration(int minutes) {
    final duration = Duration(minutes: minutes);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
           "${twoDigits(duration.inMinutes.remainder(60))}:"
           "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = (video.publishDate ?? video.uploadDate) != null
        ? DateFormat('EEE, dd MMM yyyy, hh:mm:ss a')
            .format((video.publishDate ?? video.uploadDate)!)
        : "Unknown time";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (video.durationMinutes != null)
            Text("Duration: ${formatDuration(video.durationMinutes!)}",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 12),
          Text(formattedDateTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
