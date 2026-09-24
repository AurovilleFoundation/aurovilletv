import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/cubit/search_cubit.dart';
import 'widgets/detail_view_btn.dart';

class SearchScreen extends StatelessWidget {
  final VideoApiService apiService;

  const SearchScreen({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 232, 223),
      body: SafeArea(
        child: Column(
          children: [
            // Top Spacing & Search Bar Area
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 16, top: 20, bottom: 12),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1E1E1E),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),

                  // Search Bar Input Container
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 249, 246, 241),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFC85A17).withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                        cursorColor: const Color(0xFFC85A17),
                        decoration: InputDecoration(
                          hintText: 'Search title, category, talks...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.search_rounded,
                              color: Color(0xFFC85A17),
                              size: 22,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 44),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller,
                            builder: (_, value, _) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                onPressed: () {
                                  controller.clear();
                                  cubit.clear();
                                },
                              );
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: cubit.search,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Content / Results List
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) {
                        return const _EmptySearchWidget();
                      }

                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC85A17),
                          ),
                        );
                      }

                      if (state.errorMessage != null) {
                        return _ErrorWidget(message: state.errorMessage!);
                      }

                      if (state.videos.isEmpty) {
                        return const _NoResultWidget();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: state.videos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final video = state.videos[index];

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Thumbnail Box
                              SizedBox(
                                width: 175,
                                height: 118,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: video.thumbnail.isNotEmpty &&
                                                video.thumbnail.startsWith('http')
                                            ? Image.network(
                                                video.thumbnail,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Container(
                                                  color: Colors.grey.shade300,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            : Image.asset(
                                                video.thumbnail,
                                                fit: BoxFit.cover,
                                              ),
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

                              // Details Info
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
                                    _SearchVideoSubtitle(video: video),
                                    if (!video.isLive) ...[
                                      const SizedBox(height: 8),
                                      DetailViewBtn(videoId: video.id, video: video),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchVideoSubtitle extends StatelessWidget {
  final VideoModel video;

  const _SearchVideoSubtitle({required this.video});

  String _getDuration() {
    if (video.isLive) return "Live";
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

class _EmptySearchWidget extends StatelessWidget {
  const _EmptySearchWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFC85A17).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 48,
              color: Color(0xFFC85A17),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Search Auroville TV",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultWidget extends StatelessWidget {
  const _NoResultWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No videos found",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      ),
    );
  }
}