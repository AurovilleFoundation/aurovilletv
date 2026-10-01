import 'package:flutter/material.dart';
import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/live/live_detail_screen.dart';
import 'package:aurovilletv/ui/video_details/video_details_screen.dart';
import 'package:aurovilletv/utils/theme/colors.dart';

class CategoryVideosScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryVideosScreen({super.key, required this.category});

  @override
  State<CategoryVideosScreen> createState() => _CategoryVideosScreenState();
}

class _CategoryVideosScreenState extends State<CategoryVideosScreen> {
  late Future<List<VideoModel>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  void _fetchVideos() {
    final apiService = getIt<VideoApiService>();
    _videosFuture = (widget.category.id.isEmpty || widget.category.id == "0")
        ? apiService.getAllVideos()
        : apiService.getVideos(categoryId: widget.category.id);
  }

  void _navigateToVideo(BuildContext context, VideoModel video) {
    if (video.isLive) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              LiveDetailScreen(liveStream: video.toLiveStreamModel()),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoDetailsScreen(videoId: video.id, video: video),
        ),
      );
    }
  }

  Widget _buildThumbnail(String thumbnail) {
    if (thumbnail.isEmpty) {
      return Image.asset(
        'assets/images/video_placeholder.jpg',
        fit: BoxFit.cover,
      );
    }
    if (thumbnail.startsWith('http')) {
      return Image.network(
        thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/video_placeholder.jpg',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      thumbnail,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset('assets/images/video_placeholder.jpg', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: AppColors.darkColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.themeColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Something went wrong",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.themeColor,
                        side: const BorderSide(color: AppColors.themeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _fetchVideos();
                        });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final videos = snapshot.data ?? [];
          if (videos.isEmpty) {
            return const Center(
              child: Text(
                "No Videos Found",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.themeColor,
            onRefresh: () async {
              setState(() {
                _fetchVideos();
              });
              await _videosFuture;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: videos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final video = videos[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _navigateToVideo(context, video),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Thumbnail Box
                        SizedBox(
                          width: 175,
                          height: 125,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: _buildThumbnail(video.thumbnail),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.25),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Play Icon (Bottom Left)
                              const Positioned(
                                left: 10,
                                bottom: 10,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              // Live Tag (Top Right)
                              if (video.isLive)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "LIVE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Title & Subtitle Area (Starting at top of video)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E1E1E),
                                    height: 1.25,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _VideoMetaSubtitle(video: video),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Navigation Arrow (Middle-Aligned, Size 16)
                        const SizedBox(
                          height: 125,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Color(0xFFBDBDBD),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VideoMetaSubtitle extends StatelessWidget {
  final VideoModel video;

  const _VideoMetaSubtitle({required this.video});

  String _getDuration() {
    if (video.formattedDuration != null &&
        video.formattedDuration!.isNotEmpty) {
      return video.formattedDuration!;
    }
    if (video.durationMinutes != null && video.durationMinutes! > 0) {
      final m = video.durationMinutes!;
      return m >= 60 ? "${m ~/ 60} hr ${m % 60} min" : "$m min";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final String category =
        (video.category != null && video.category!.isNotEmpty)
        ? video.category!
        : "Documentary";

    final String duration = _getDuration();
    final String subtitle = duration.isNotEmpty
        ? "$category  •  $duration"
        : category;

    return Text(
      subtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }
}
