import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/widgets/video_placeholder_widget.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';

class VideoCellWidget extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onTap;

  const VideoCellWidget({super.key, required this.video, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _thumbnail(),
            const SizedBox(width: 12),
            Expanded(child: _details(context)),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    return VideoPlaceholderWidget(
      width: 150,
      height: 96,
      imageUrl: video.thumbnail,
      borderRadius: 12,
      iconSize: 24,
    );
  }

  Widget _details(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkColor,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.earthColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                "Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
