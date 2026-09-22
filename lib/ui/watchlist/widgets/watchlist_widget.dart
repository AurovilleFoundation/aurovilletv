import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/explore/widgets/detail_view_btn.dart';
import '../bloc/watchlist_bloc.dart';

class WatchListWidget extends StatelessWidget {
  const WatchListWidget({super.key});

  static const String _defaultAssetThumb = 'assets/images/thumb.png';

  Widget _buildThumbnail(String thumbnail) {
    String imageUrl = thumbnail.trim();

    if (imageUrl.isEmpty || imageUrl.startsWith('assets/')) {
      return _buildLocalThumb();
    }

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchListBloc, WatchListState>(
      builder: (context, state) {
        if (state is WatchListLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFC85A17),
            ),
          );
        }

        if (state is WatchListError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is WatchListLoaded) {
          if (state.videos.isEmpty) {
            return const _EmptyWatchList();
          }

          return RefreshIndicator(
            color: const Color(0xFFC85A17),
            onRefresh: () async {
              context.read<WatchListBloc>().add(const RefreshWatchList());
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: state.videos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final video = state.videos[index];

                return Dismissible(
                  key: ValueKey(video.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 28),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (_) {
                    context.read<WatchListBloc>().add(RemoveVideo(video.id));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${video.title}" removed from Watchlist',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Video Thumbnail Container
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

                      const SizedBox(width: 16),

                      // Video Info & Details Button
                      Expanded(
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
                            const SizedBox(height: 8),
                            // Details Screen Navigate Button
                            DetailViewBtn(videoId: video.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
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
    final category = (video.category != null && video.category!.isNotEmpty)
        ? video.category!
        : "Documentary";

    final duration = _getDuration();
    final subtitle = duration.isNotEmpty ? "$category  •  $duration" : category;

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

class _EmptyWatchList extends StatelessWidget {
  const _EmptyWatchList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFC85A17).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 54,
                color: Color(0xFFC85A17),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Your Watchlist is Empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              "Videos you save for later will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}