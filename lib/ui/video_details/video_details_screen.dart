import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'bloc/video_details_bloc.dart';
import 'bloc/video_details_event.dart';
import 'bloc/video_details_state.dart';
import 'widgets/head_section.dart';
import 'widgets/info_image.dart';
import 'widgets/info_details.dart';
import 'widgets/details_text.dart';

class VideoDetailsScreen extends StatelessWidget {
  final String? videoId;
  final VideoModel? video;

  const VideoDetailsScreen({
    super.key,
    this.videoId,
    this.video,
  }) : assert(videoId != null || video != null,
            'Either videoId or video must be provided');

  @override
  Widget build(BuildContext context) {
    final effectiveVideoId = videoId ?? video!.id;
    final apiService = context.read<VideoApiService>();

    return BlocProvider(
      create: (_) => VideoDetailsBloc(apiService: apiService)
        ..add(LoadVideoDetails(effectiveVideoId, initialVideo: video)),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 233, 221),
        body: BlocBuilder<VideoDetailsBloc, VideoDetailsState>(
          builder: (context, state) {
            if (state is VideoDetailsLoading) {
              return Scaffold(
                backgroundColor: const Color.fromARGB(255, 245, 233, 221),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: Icon(Icons.arrow_back,
                          color: Colors.white, size: 22),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFC85A17),
                  ),
                ),
              );
            } else if (state is VideoDetailsLoaded) {
              final currentVideo = state.video;

              return SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadSection(
                        video: currentVideo,
                        bannerHeight: 380,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
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
                                  InfoImage(video: currentVideo),
                                  const SizedBox(width: 16),
                                  Expanded(
                                      child: InfoDetails(video: currentVideo)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            DetailsText(video: currentVideo),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is VideoDetailsError) {
              return Scaffold(
                backgroundColor: const Color.fromARGB(255, 245, 233, 221),
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: Icon(Icons.arrow_back,
                          color: Colors.white, size: 22),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC85A17),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            context.read<VideoDetailsBloc>().add(
                                  LoadVideoDetails(effectiveVideoId,
                                      initialVideo: video),
                                );
                          },
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
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