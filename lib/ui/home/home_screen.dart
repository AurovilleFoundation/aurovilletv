import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/home_data_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/explore/bloc/explore_bloc.dart';
import 'package:aurovilletv/ui/home/cubit/home_cubit.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/ui/video_player/video_player_screen.dart';
import 'package:aurovilletv/ui/widgets/video_placeholder_widget.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const _HomeLoadingWidget();
            } else if (state is HomeError) {
              return _HomeErrorWidget(message: state.message);
            } else if (state is HomeLoaded) {
              return _HomeLoadedWidget(homeData: state.homeData);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// Loading Skeleton (Shimmer)
//------------------------------------------------------------------------------
class _HomeLoadingWidget extends StatelessWidget {
  const _HomeLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              children: [
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Container(width: 150, height: 24, color: Colors.white),
                const Spacer(),
                Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 24),
            // Banner shimmer
            Container(width: double.infinity, height: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 24),
            // Section title shimmer
            Container(width: 100, height: 18, color: Colors.white),
            const SizedBox(height: 12),
            // Categories shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => Column(
                  children: [
                    Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(height: 8),
                    Container(width: 50, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Featured shimmer
            Container(width: 120, height: 18, color: Colors.white),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 250, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 12),
                Container(width: 100, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// Error Screen Widget
//------------------------------------------------------------------------------
class _HomeErrorWidget extends StatelessWidget {
  final String message;

  const _HomeErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 72, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Oops, could not load Home Screen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.earthColor),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeCubit>().loadHomeData(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry Connection"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.themeColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
// Home Screen Content (Loaded State)
//------------------------------------------------------------------------------
class _HomeLoadedWidget extends StatelessWidget {
  final HomeDataModel homeData;

  const _HomeLoadedWidget({required this.homeData});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().loadHomeData(),
      color: AppColors.themeColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildHeroBanner(context),
            _buildExploreSection(context),
            _buildFeaturedSection(context),
            _buildPopularSection(context),
            _buildLatestVideosSection(context),
          ],
        ),
      ),
    );
  }

  // Header App Bar
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 4.0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.themeColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tv_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Text(
            "Auroville TV",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.earthColor,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.earthColor,
              size: 26,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notifications coming soon!")),
              );
            },
          ),
        ],
      ),
    );
  }

  // Explore Categories List
  Widget _buildExploreSection(BuildContext context) {
    if (homeData.categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "EXPLORE",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.earthColor, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 105,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: homeData.categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = homeData.categories[index];
              return _buildCategoryItem(context, category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return GestureDetector(
      onTap: () {
        // Dispatch to Explore Bloc and select this category tab
        context.read<ExploreBloc>().add(CategoryChanged(category.id));
        context.read<NavigationBloc>().add(const TabChanged(2)); // index 2 is Explore tab
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(category.id),
              color: AppColors.themeColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 75,
            child: Text(
              category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.darkColor,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'spiritual':
        return Icons.spa_outlined;
      case 'educational':
        return Icons.school_outlined;
      case 'workshop':
        return Icons.handyman_outlined;
      case 'inauguration':
        return Icons.celebration_outlined;
      case 'events':
        return Icons.event_note_outlined;
      default:
        return Icons.video_library_outlined;
    }
  }

  // Featured Videos Slider
  Widget _buildFeaturedSection(BuildContext context) {
    if (homeData.featuredVideos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "FEATURED",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.earthColor, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: homeData.featuredVideos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final video = homeData.featuredVideos[index];
              return _buildFeaturedVideoCard(context, video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedVideoCard(BuildContext context, VideoModel video) {
    final String image = _getVideoThumbnail(video.thumbnail);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(video: video),
          ),
        );
      },
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Play button overlay
            VideoPlaceholderWidget(
              width: 250,
              height: 120,
              imageUrl: image,
              borderRadius: 12,
              iconSize: 24,
            ),
            // Video Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${video.categoryId.isNotEmpty ? video.categoryId : 'General'} • ${video.viewCount} views",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popular Videos Section
  Widget _buildPopularSection(BuildContext context) {
    if (homeData.popularVideos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "POPULAR VIDEOS",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.earthColor, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: homeData.popularVideos.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final video = homeData.popularVideos[index];
              return _buildPopularVideoCard(context, video);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularVideoCard(BuildContext context, VideoModel video) {
    final String image = _getVideoThumbnail(video.thumbnail);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(video: video),
          ),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoPlaceholderWidget(
              width: 220,
              height: 115,
              imageUrl: image,
              borderRadius: 12,
              iconSize: 22,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkColor),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${video.categoryId.isNotEmpty ? video.categoryId : 'General'} • ${video.viewCount} views",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getVideoThumbnail(String thumbnail) {
    if (thumbnail.isEmpty) {
      return "";
    }
    if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) {
      return thumbnail;
    }
    if (thumbnail.startsWith('/')) {
      return "https://aiis.auroville.org$thumbnail";
    }
    return "https://aiis.auroville.org/$thumbnail";
  }

  // Latest Videos Section
  Widget _buildLatestVideosSection(BuildContext context) {
    if (homeData.latestVideos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "LATEST VIDEOS",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.earthColor, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: homeData.latestVideos.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final video = homeData.latestVideos[index];
            return _buildLatestVideoRow(context, video);
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLatestVideoRow(BuildContext context, VideoModel video) {
    final String image = _getVideoThumbnail(video.thumbnail);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(video: video),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Image card
            VideoPlaceholderWidget(
              width: 95,
              height: 60,
              imageUrl: image,
              borderRadius: 8,
              iconSize: 14,
            ),
            const SizedBox(width: 12),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.darkColor, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.categoryId.isNotEmpty ? video.categoryId : 'General',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.themeColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${video.viewCount} views",
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hero Live / Featured Banner (From API live data)
  Widget _buildHeroBanner(BuildContext context) {
    final liveVideo = homeData.liveVideo;
    if (liveVideo == null || liveVideo.title.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final String title = liveVideo.title.trim();
    final String description = liveVideo.description.trim();
    final String thumbnail = _getVideoThumbnail(liveVideo.thumbnail);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 16.0),
      child: GestureDetector(
        onTap: () {
          // Switch to Live Broadcast tab (index 1)
          context.read<NavigationBloc>().add(const TabChanged(1));
        },
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Dynamic thumbnail or asset fallback
                if (thumbnail.isNotEmpty)
                  VideoPlaceholderWidget(
                    imageUrl: thumbnail,
                    borderRadius: 0,
                    showPlayIcon: false,
                  )
                else
                  Image.asset(
                    'assets/images/home_banner.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) =>
                        const VideoPlaceholderWidget(
                      imageUrl: '',
                      borderRadius: 0,
                      showPlayIcon: false,
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Content Overlay
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (liveVideo.categoryId.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.themeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            liveVideo.categoryId.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
