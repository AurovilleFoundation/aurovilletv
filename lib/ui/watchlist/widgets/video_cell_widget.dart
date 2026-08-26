import 'package:flutter/material.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/utils/theme/colors.dart';

class VideoCellWidget extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onTap;

  const VideoCellWidget({super.key, required this.video, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Thumbnail on left
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: video.thumbnail.isNotEmpty &&
                            video.thumbnail.startsWith('http')
                        ? Image.network(video.thumbnail, fit: BoxFit.cover)
                        : Image.asset(video.thumbnail, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.themeColor,
                      child: const Icon(Icons.play_arrow_rounded,
                          color: AppColors.lightColor, size: 20),
                    ),
                  ),
                  if (video.isLive) _liveBadge(),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ✅ Only title text on right
            Expanded(
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _liveBadge() {
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          "LIVE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
