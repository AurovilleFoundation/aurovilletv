import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/watchlist/bloc/watchlist_bloc.dart';

class HeadSection extends StatelessWidget {
  final VideoModel video;
  final double bannerHeight;

  const HeadSection({
    super.key,
    required this.video,
    this.bannerHeight = 480,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Date & Time not available";
    return DateFormat("EEEE, dd MMMM yyyy 'at' hh:mm a 'IST'").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        _formatDateTime(video.publishDate ?? video.uploadDate);
    final bool isEnded = !video.isLive &&
        (video.publishDate != null &&
            video.publishDate!.isBefore(DateTime.now()));

    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Hero Image
          video.thumbnail.isNotEmpty && video.thumbnail.startsWith('http')
              ? Image.network(
                  video.thumbnail,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) => Image.asset(
                    'assets/images/thumb.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/thumb.png',
                  fit: BoxFit.cover,
                ),

          // Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Bookmark Button (Placed aligned with standard Top Back Button)
          Positioned(
            top: 8,
            right: 16,
            child: SafeArea(
              child: BlocBuilder<WatchListBloc, WatchListState>(
                builder: (context, state) {
                  // Checks whether this specific video exists in SQLite watchlist
                  final bool isBookmarked = state is WatchListLoaded &&
                      state.videos.any((item) => item.id == video.id);

                  return IconButton(
                    splashRadius: 24,
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded          // Solid White Fill (image 2)
                          : Icons.bookmark_border_rounded,  // Outline White (image 1)
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
  final bloc = context.read<WatchListBloc>();
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  if (isBookmarked) {
    bloc.add(RemoveVideo(video.id));
    // ---------------- Style 4 Layout: Solid Background (#1E1E1E) ----------------
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 1),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Solid Dark Color
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Removed from Watchlist",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } else {
    bloc.add(AddVideo(video));
    // ---------------- Style 3 Layout: Solid Background (#C85A17) ----------------
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 1),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFC85A17), // Solid Orange/Brown Theme Color
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Added to Watchlist",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}                 
                  );
                },
              ),
            ),
          ),

          // Header Text & Badge Box
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 4.5,
                          backgroundColor: video.isLive
                              ? const Color(0xFFE53935)
                              : (isEnded
                                  ? const Color(0xFFEF5350)
                                  : const Color(0xFFFB8C00)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          video.isLive
                              ? "LIVE NOW"
                              : (isEnded
                                  ? "PROGRAMME ENDED"
                                  : "UPCOMING PROGRAMME"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title Text
                  Text(
                    video.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scheduled Date
                  Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    video.isLive
                        ? "This broadcast is currently streaming live."
                        : (isEnded
                            ? "This scheduled broadcast has ended."
                            : "This broadcast is scheduled to stream."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}