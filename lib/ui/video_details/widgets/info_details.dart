import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aurovilletv/data/models/video_model.dart';

class InfoDetails extends StatelessWidget {
  final VideoModel video;

  const InfoDetails({super.key, required this.video});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Date & Time not available";
    return DateFormat("EEEE, dd MMMM yyyy 'at' hh:mm a 'IST'").format(dateTime);
  }

  String _formatEndTime(DateTime? dateTime, int? durationMinutes) {
    if (dateTime == null) return "Unknown";
    final end = dateTime.add(Duration(minutes: durationMinutes ?? 60));
    return DateFormat("EEEE, dd MMMM yyyy 'at' hh:mm a 'IST'").format(end);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = _formatDateTime(video.publishDate ?? video.uploadDate);
    final String programmeTag = (video.category?.isNotEmpty == true)
        ? video.category!.toUpperCase()
        : "PROGRAMME";

    final bool isEnded = !video.isLive &&
        (video.publishDate != null && video.publishDate!.isBefore(DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          programmeTag,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFC85A17),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          video.title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),

        // Notice Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Color.fromRGBO(248, 240, 230, 1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color.fromARGB(255, 236, 221, 208),
              width: 1,
            ),
          ),
          child: Text(
            video.isLive
                ? "Streaming now on Auroville TV network."
                : (isEnded
                    ? "The programme ended at ${_formatEndTime(video.publishDate, video.durationMinutes)}."
                    : "The programme will start at $formattedDate."),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5A3B28),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}