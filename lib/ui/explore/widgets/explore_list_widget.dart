import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/video_details/video_details_screen.dart';
import '../bloc/explore_bloc.dart';

class ExploreListWidget extends StatelessWidget {
  const ExploreListWidget({super.key});

  static const String _defaultAssetThumb = 'assets/images/thumb.png';

  Widget _buildThumbnail(String thumbnail) {
    final String imageUrl = thumbnail.trim();

    if (imageUrl.isEmpty || imageUrl.startsWith('assets/')) {
      return _buildLocalThumb();
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildLocalThumb(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLocalThumb();
        },
      );
    }

    return _buildLocalThumb();
  }

  Widget _buildLocalThumb() {
    return Image.asset(
      _defaultAssetThumb,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
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

  void _navigateToDetails(BuildContext context, String videoId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoDetailsScreen(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.videos != current.videos ||
          previous.selectedCategory != current.selectedCategory ||
          previous.errorMessage != current.errorMessage,
      builder: (context, state) {
        // Slow Network அல்லது Refresh ஆகும் போது தோன்றும் Circular Progress + Grey Shimmer UI
        if (state.isLoading) {
          return const _ExploreLoadingSkeleton();
        }

        if (state.errorMessage != null && state.videos.isEmpty) {
          return _ErrorWidget(message: state.errorMessage!);
        }

        if (state.videos.isEmpty) {
          return _EmptyWidget(category: state.selectedCategory);
        }

        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: state.videos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final video = state.videos[index];

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _navigateToDetails(context, video.id),
                child: SizedBox(
                  height: 125,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Thumbnail Box
                      SizedBox(
                        width: 200,
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

                      // Navigation Arrow (Vertically Centered & 8px Inset from Edge)
                      const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------- Grey Skeleton Loader with Top Circle ----------------
class _ExploreLoadingSkeleton extends StatelessWidget {
  const _ExploreLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Center Progress Indicator
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              color: Color(0xFFC85A17),
            ),
          ),
        ),

        // Grey Video Cards Skeleton
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 125,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grey Thumbnail Box Skeleton
                      Container(
                        width: 200,
                        height: 125,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Grey Texts Skeleton
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 16,
                                width: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                height: 12,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Grey Arrow Skeleton
                      const Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
  final String category;

  const _EmptyWidget({this.category = "All"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No $category Videos Found",
        style: const TextStyle(
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