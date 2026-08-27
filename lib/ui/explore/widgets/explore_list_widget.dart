import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import '../bloc/explore_bloc.dart';
import '../../video_details/video_details_screen.dart';

class ExploreListWidget extends StatelessWidget {
  const ExploreListWidget({super.key});

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
              color: AppColors.themeColor,
              strokeWidth: 3,
            ),
          );
        }

        if (state.errorMessage != null && state.videos.isEmpty) {
          return _ErrorWidget(message: state.errorMessage!);
        }

        if (state.videos.isEmpty) {
          return const _EmptyWidget();
        }

        return Container(
          color: AppColors.scaffoldBackgroundColor,
          child: RefreshIndicator(
            color: AppColors.themeColor,
            onRefresh: () async {
              context.read<ExploreBloc>().add(const RefreshExplore());
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.videos.length,
              itemBuilder: (context, index) {
                final video = state.videos[index];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.lightColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.backgroundDark.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Thumbnail with play button & LIVE badge
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 175,
                              height: 150,
                              child: video.thumbnail.isNotEmpty &&
                                      video.thumbnail.startsWith('http')
                                  ? Image.network(video.thumbnail, fit: BoxFit.cover)
                                  : Image.asset(video.thumbnail, fit: BoxFit.cover),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            if (video.isLive)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "LIVE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // Title & Details Button
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkColor,
                                    height: 1.2,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.themeColor,
                                      foregroundColor: AppColors.lightColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 1.5,
                                    ),
                                    onPressed: () {
                                      // ✅ Show VideoDetailsScreen in bottom sheet (not full screen)
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (_) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.85, // covers 85% height
                                            child: VideoDetailsScreen(videoId: video.id),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      "Details",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackgroundColor,
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 80,
                color: AppColors.themeColor,
              ),
              SizedBox(height: 16),
              Text(
                "No Videos Found",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "There are no videos available in this category.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHintColor),
              ),
            ],
          ),
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
    return Container(
      color: AppColors.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 70,
                color: AppColors.themeColor,
              ),
              const SizedBox(height: 20),
              const Text(
                "Something went wrong",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textHintColor),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.themeColor,
                  foregroundColor: AppColors.lightColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: AppColors.backgroundDark.withValues(alpha: 0.35),
                  elevation: 4,
                ),
                onPressed: () {
                  context.read<ExploreBloc>().add(const RefreshExplore());
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}