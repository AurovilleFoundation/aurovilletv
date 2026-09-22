import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'bloc/video_details_bloc.dart';
import 'bloc/video_details_event.dart';
import 'bloc/video_details_state.dart';
import 'widgets/head_section.dart';
import 'widgets/info_image.dart';
import 'widgets/info_details.dart';
import 'widgets/details_text.dart';

class VideoDetailsScreen extends StatelessWidget {
  final String videoId;

  const VideoDetailsScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final apiService = context.read<VideoApiService>();

    return BlocProvider(
      create: (_) => VideoDetailsBloc(apiService: apiService)
        ..add(LoadVideoDetails(videoId)),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 233, 221),
        body: BlocBuilder<VideoDetailsBloc, VideoDetailsState>(
          builder: (context, state) {
            if (state is VideoDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC85A17),
                ),
              );
            } else if (state is VideoDetailsLoaded) {
              final video = state.video;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350, // Set to match HeadSection
                    pinned: true,
                    elevation: 0,
                    backgroundColor: const Color(0xFF14100E),
                    leading: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.black45,
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: HeadSection(
                        video: video,
                        bannerHeight: 480,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InfoImage(video: video),
                                const SizedBox(width: 16),
                                Expanded(child: InfoDetails(video: video)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          DetailsText(video: video),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is VideoDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}