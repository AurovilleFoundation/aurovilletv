import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/watchlist/bloc/watchlist_bloc.dart';
import 'package:aurovilletv/ui/widgets/video_placeholder_widget.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late VideoModel _currentVideo;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _currentVideo = widget.video;
    _initializeVideo();
    _checkIfSaved();
  }

  void _checkIfSaved() async {
    final isSaved = await getIt<DBManager>().isInWatchList(_currentVideo.id);
    if (mounted) {
      setState(() {
        _isSaved = isSaved;
      });
    }
  }

  void _toggleWatchlist() {
    final nextState = !_isSaved;
    setState(() {
      _isSaved = nextState;
    });

    if (nextState) {
      context.read<WatchListBloc>().add(AddVideo(_currentVideo));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_currentVideo.title}" added to Watchlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      context.read<WatchListBloc>().add(RemoveVideo(_currentVideo.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_currentVideo.title}" removed from Watchlist'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _initializeVideo() async {
    String url = _currentVideo.videoUrl?.trim() ?? '';

    // Fetch single video API details (Endpoint #10 in API docs)
    try {
      final fetchedVideo = await getIt<VideoApiService>().getVideoById(_currentVideo.id);
      if (mounted) {
        setState(() {
          _currentVideo = fetchedVideo;
        });
      }
      if (fetchedVideo.videoUrl?.trim().isNotEmpty ?? false) {
        url = fetchedVideo.videoUrl!.trim();
      }
    } catch (_) {}

    // Increment view count API (Endpoint #12 in API docs)
    getIt<VideoApiService>().incrementViewCount(_currentVideo.id);

    if (url.isEmpty) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        url = "https://aiis.auroville.org$url";
      } else {
        url = "https://$url";
      }
    }

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      } else {
        _controller?.dispose();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  String _formatFullDateTime(DateTime dt) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final weekday = weekdays[dt.weekday - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;

    final hour12 = (dt.hour % 12 == 0) ? 12 : (dt.hour % 12);
    final hourStr = hour12.toString().padLeft(2, '0');
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return '$weekday, $day $month $year at $hourStr:$minuteStr $amPm IST';
  }

  String _formatEndDateTime(DateTime dt) {
    final endDt = dt.add(const Duration(hours: 1));
    return _formatFullDateTime(endDt);
  }

  String _getVideoThumbnail(String thumbnail) {
    if (thumbnail.isEmpty) return "";
    if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) return thumbnail;
    if (thumbnail.startsWith('/')) return "https://aiis.auroville.org$thumbnail";
    return "https://aiis.auroville.org/$thumbnail";
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatFullDateTime(_currentVideo.dateTime);
    final formattedEndDate = _formatEndDateTime(_currentVideo.dateTime);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _controller?.pause();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBanner(context, formattedDate),
              _buildInfoCard(context, formattedDate, formattedEndDate),
              _buildDescriptionSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context, String formattedDate) {
    final thumbnail = _getVideoThumbnail(_currentVideo.thumbnail);

    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image or placeholder
          if (thumbnail.isNotEmpty)
            VideoPlaceholderWidget(
              imageUrl: thumbnail,
              borderRadius: 0,
              showPlayIcon: false,
            )
          else
            Image.asset(
              'assets/images/video_placeholder.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8C3A27), Color(0xFFB85C37)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Video Player when active
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),

          // Content Overlay (when stream is not active/playing)
          if (!_isInitialized)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Pill badge: 🔴 PROGRAMME ENDED
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "PROGRAMME ENDED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Big Title
                  Text(
                    _currentVideo.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Date & Time
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Subtitle
                  const Text(
                    "This scheduled broadcast has ended.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Video Controls Overlay (when active)
          if (_isInitialized && _controller != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: Colors.black54,
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _controller!,
                      builder: (context, VideoPlayerValue value, child) {
                        return IconButton(
                          icon: Icon(
                            value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            value.isPlaying ? _controller!.pause() : _controller!.play();
                          },
                        );
                      },
                    ),
                    Expanded(
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.themeColor,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top Navigation & Action Row (Back button and Bookmark)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 20,
                  child: IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: _isSaved ? "Remove from Watchlist" : "Save to Watchlist",
                    onPressed: _toggleWatchlist,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String formattedDate, String formattedEndDate) {
    final category = _currentVideo.categoryId.isNotEmpty ? _currentVideo.categoryId : 'General';
    final thumbnail = _getVideoThumbnail(_currentVideo.thumbnail);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: VideoPlaceholderWidget(
              width: 110,
              height: 95,
              imageUrl: thumbnail,
              borderRadius: 10,
              iconSize: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFB85C37),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentVideo.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkColor,
                    fontFamily: 'serif',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "The programme ended at\n$formattedEndDate.",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B4B3E),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final description = _currentVideo.description.isNotEmpty
        ? _currentVideo.description
        : "No description available for this broadcast.";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About this broadcast",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
              color: AppColors.darkColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
