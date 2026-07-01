import 'package:aurovilletv/data/models/video_model.dart';
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
    Widget image;

    if (video.thumbnail.startsWith('http')) {
      image = Image.network(
        video.thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const Icon(Icons.video_library, size: 40, color: Colors.grey);
        },
      );
    } else {
      image = Image.asset(
        video.thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const Icon(Icons.video_library, size: 40, color: Colors.grey);
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 168,
        height: 96,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Container(color: Colors.black.withOpacity(.15)),
            _videoIconWidget(),
          ],
        ),
      ),
    );
  }

  Widget _details(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),

          Text(
            _subtitle(),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    return "Documentary • 32 mins";
  }

  Widget _videoIconWidget() {
    return const Positioned(
      left: 8,
      bottom: 8,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.scaffoldBackgroundColor,
        child: Icon(
          Icons.play_arrow_rounded,
          color: AppColors.darkColor,
          size: 18,
        ),
      ),
    );
  }
}
