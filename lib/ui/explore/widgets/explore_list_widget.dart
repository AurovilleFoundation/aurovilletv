import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import '../bloc/explore_bloc.dart';
import '../../live/live_detail_screen.dart';
import '../../video_details/video_details_screen.dart';

class ExploreListWidget extends StatelessWidget {
  const ExploreListWidget({super.key});

  static const String _defaultAssetThumb = 'assets/images/thumb.png';

  Widget _buildThumbnail(String thumbnail) {
    final String imageUrl = thumbnail.trim();

    // 1. If empty or points to an asset, load local thumb.png
    if (imageUrl.isEmpty || imageUrl.startsWith('assets/')) {
      return _buildLocalThumb();
    }

    // 2. If valid full HTTP/HTTPS URL, load network image with fallback
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildLocalThumb(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLocalThumb();
        },
      );
    }

    // 3. Fallback for all other cases
    return _buildLocalThumb();
  }

  Widget _buildLocalThumb() {
    return Image.asset(
      _defaultAssetThumb,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFEADBCE),
        child: const Center(
          child: Icon(
            Icons.movie_creation_outlined,
            color: Color(0xFFC85A17),
            size: 36,
          ),
        ),
      ),
    );
  }

  void _navigateToVideo(BuildContext context, VideoModel video) {
    if (video.isLive) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveDetailScreen(
            liveStream: video.toLiveStreamModel(),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoDetailsScreen(
            videoId: video.id,
            video: video,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.videos != current.videos ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        if (state.isLoading && state.videos.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFC85A17),
            ),
          );
        }

        if (state.errorMessage != null && state.videos.isEmpty) {
          return _ErrorWidget(message: state.errorMessage!);
        }

        if (state.videos.isEmpty) {
          return const _EmptyWidget();
        }

        return RefreshIndicator(
          color: const Color(0xFFC85A17),
          onRefresh: () async {
            context.read<ExploreBloc>().add(const RefreshExplore());
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: state.videos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final video = state.videos[index];

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
                                        color: Colors.black.withValues(alpha: 0.2),
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

                      // Title & Subtitle Area
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

                      // Navigation Arrow (Truly Vertically Centered & Visible)
                      const SizedBox(
                        height: 125,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Color(0xFF757575),
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
    );
  }
}

class _VideoMetaSubtitle extends StatelessWidget {
  final VideoModel video;

  const _VideoMetaSubtitle({required this.video});

  String _getDuration() {
    if (video.formattedDuration != null && video.formattedDuration!.isNotEmpty) {
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
    final String category = (video.category != null && video.category!.isNotEmpty)
        ? video.category!
        : "Documentary";

    final String duration = _getDuration();
    final String subtitle = duration.isNotEmpty ? "$category  •  $duration" : category;

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

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
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
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 50, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              "Something went wrong",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC85A17),
                side: const BorderSide(color: Color(0xFFC85A17)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                context.read<ExploreBloc>().add(const RefreshExplore());
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}