import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/home_data_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/ui/explore/bloc/explore_bloc.dart';
import 'package:aurovilletv/ui/home/cubit/home_cubit.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/ui/video_player/video_player_screen.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            _buildLatestVideosSection(context),
          ],
        ),
      ),
    );
  }

  // Header App Bar
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 44,
            height: 44,
            fit: BoxFit.contain,
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

  // Hero Banner Slider
  Widget _buildHeroBanner(BuildContext context) {
    final heroVideo = homeData.liveVideo;
    final String heroTitle = heroVideo?.title ?? "The world from Auroville";
    final String heroDesc = heroVideo?.description ??
        "Stories, voices and perspectives from the living experiment in human unity.";
    
    final String? thumbnail = heroVideo?.thumbnail;
    final bool useNetworkImage = thumbnail != null && thumbnail.isNotEmpty && thumbnail.startsWith('http');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 230,
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
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: useNetworkImage
                  ? CachedNetworkImage(
                      imageUrl: thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.themeColor),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/home_banner.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/home_banner.jpg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            // Black overlay gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  Text(
                    heroTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    heroDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Page Indicators mockup
                  Row(
                    children: [
                      Container(width: 14, height: 4, decoration: BoxDecoration(color: AppColors.themeColor, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 4),
                      Container(width: 6, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
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

  // Explore Categories List
  Widget _buildExploreSection(BuildContext context) {
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Discover content that inspires",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: homeData.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Stories from the community",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: homeData.featuredVideos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
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
    final String image = video.thumbnail.isNotEmpty ? video.thumbnail : "https://live.auroville.org.in/thumbnail.jpg";
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    height: 120,
                    width: 250,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.video_library_rounded, size: 38, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
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
                    "${video.categoryId.isNotEmpty ? video.categoryId : 'General'} • 24 min",
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
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    final String image = video.thumbnail.isNotEmpty ? video.thumbnail : "https://live.auroville.org.in/thumbnail.jpg";
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: image,
                width: 95,
                height: 60,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 95,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.video_library_rounded, size: 24, color: Colors.grey),
                  ),
                ),
              ),
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
}
