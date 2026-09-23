import 'package:aurovilletv/data/models/live_stream_model.dart';
import 'package:aurovilletv/ui/live/cubit/live_cubit.dart';
import 'package:aurovilletv/ui/live/live_detail_screen.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<LiveCubit>();
      if (cubit.state is LiveInitial) {
        cubit.loadLiveStatus();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToDetail(LiveStreamModel liveStream) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveDetailScreen(liveStream: liveStream),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkColor),
          tooltip: "Back to Home",
          onPressed: () {
            context.read<NavigationBloc>().add(const TabChanged(0));
          },
        ),
        title: const Text(
          "Live Broadcast",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.darkColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.darkColor),
            tooltip: "Refresh Status",
            onPressed: () => context.read<LiveCubit>().loadLiveStatus(),
          ),
        ],
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.themeColor,
        onRefresh: () async {
          await context.read<LiveCubit>().loadLiveStatus();
        },
        child: BlocBuilder<LiveCubit, LiveState>(
          builder: (context, state) {
            if (state is LiveLoading || state is LiveInitial) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.themeColor),
                ),
              );
            } else if (state is LiveNoCredentials) {
              return _buildNoCredentialsState(context);
            } else if (state is LiveError) {
              return _buildErrorState(context, state.message);
            } else if (state is LiveLoaded) {
              return _buildLiveContent(context, state.liveStream);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNoCredentialsState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.live_tv_rounded,
                size: 64,
                color: AppColors.themeColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Live Broadcast Offline",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.earthColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "The live stream broadcast is currently offline. Please check back later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<LiveCubit>().loadLiveStatus(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Refresh Status"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            const Text(
              "Failed to Connect",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<LiveCubit>().loadLiveStatus(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry Connection"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveContent(BuildContext context, LiveStreamModel liveStream) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "BROADCAST ACTIVE",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                "Auroville TV 24/7",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Interactive Live Broadcast Card (Click to open Live Detail Screen)
          GestureDetector(
            onTap: () => _navigateToDetail(liveStream),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Placeholder Image
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

                      // Dark tint scrim
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.65),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Top-right pulsing "WATCH LIVE" pill
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2E6DB),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  FadeTransition(
                                    opacity: _pulseController,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.themeColor
                                            .withValues(alpha: 0.32),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: AppColors.themeColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "WATCH LIVE",
                                style: TextStyle(
                                  color: AppColors.earthColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center Play Icon Button
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.themeColor.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),

                      // Bottom label overlay on the card
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Row(
                          children: const [
                            Icon(Icons.touch_app_rounded,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 6),
                            Text(
                              "Tap to watch live stream",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Live Metadata from API response
          if (liveStream.category.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                liveStream.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.themeColor,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Title
          Text(
            liveStream.title.isNotEmpty
                ? liveStream.title
                : "Auroville TV Live Broadcast",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.earthColor,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // View count and Publish date
          if (liveStream.viewerCount > 0 || liveStream.publishDate.isNotEmpty) ...[
            Row(
              children: [
                if (liveStream.viewerCount > 0) ...[
                  const Icon(Icons.visibility_outlined,
                      size: 15, color: AppColors.darkColor),
                  const SizedBox(width: 5),
                  Text(
                    "${liveStream.viewerCount} ${liveStream.viewerCount == 1 ? 'view' : 'views'}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
                if (liveStream.viewerCount > 0 &&
                    liveStream.publishDate.isNotEmpty)
                  const Text("  •  ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkColor)),
                if (liveStream.publishDate.isNotEmpty) ...[
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.darkColor),
                  const SizedBox(width: 5),
                  Text(
                    liveStream.publishDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkColor,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Primary Call To Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToDetail(liveStream),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
              label: const Text(
                "Watch Live Stream",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
          if (liveStream.description.trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              "About Broadcast",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.earthColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              liveStream.description.trim(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkColor,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
