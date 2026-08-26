  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:aurovilletv/data/models/video_model.dart';
  import 'package:aurovilletv/ui/video_details/bloc/video_details_bloc.dart';
  import 'package:aurovilletv/ui/video_details/bloc/video_details_event.dart';
  import 'package:aurovilletv/ui/video_details/bloc/video_details_state.dart';
  import 'package:aurovilletv/ui/video_details/widgets/head_section.dart';
  import 'package:aurovilletv/ui/video_details/widgets/info_details.dart';
  import 'package:aurovilletv/ui/video_details/widgets/details_text.dart';


class VideoDetailsScreen extends StatelessWidget {
  final String videoId;
  const VideoDetailsScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoDetailsBloc(context.read())..add(LoadVideoDetails(videoId)),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Details")),
        body: BlocBuilder<VideoDetailsBloc, VideoDetailsState>(
          builder: (context, state) {
            if (state is VideoDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VideoDetailsLoaded) {
              final video = state.video;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadSection(video: video),
                    const SizedBox(height: 16),
                    InfoDetails(video: video),
                  ],
                ),
              );
            } else if (state is VideoDetailsError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
