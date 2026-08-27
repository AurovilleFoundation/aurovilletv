import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aurovilletv/ui/video_details/bloc/video_details_bloc.dart';
import 'package:aurovilletv/ui/video_details/bloc/video_details_event.dart';
import 'package:aurovilletv/ui/video_details/bloc/video_details_state.dart';
import 'package:aurovilletv/ui/video_details/widgets/head_section.dart';
import 'package:aurovilletv/ui/video_details/widgets/info_details.dart';
import 'package:aurovilletv/ui/video_details/widgets/details_text.dart';
import 'package:aurovilletv/ui/video_details/widgets/info_image.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:provider/provider.dart';

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
        backgroundColor: Colors.transparent, // ✅ no background outside
        body: Center(
          child: BlocBuilder<VideoDetailsBloc, VideoDetailsState>(
            builder: (context, state) {
              if (state is VideoDetailsLoading) {
                return const CircularProgressIndicator();
              } else if (state is VideoDetailsLoaded) {
                final video = state.video;
                return Container(
                  width: MediaQuery.of(context).size.width * 101, // ✅ bigger box
                  height: MediaQuery.of(context).size.height * .85,
                  decoration: BoxDecoration(
                    color: Colors.white, // ✅ solid box background
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.orangeAccent,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back icon inside box
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          HeadSection(video: video),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            indent: 20,
                            endIndent: 20,
                          ),
                          InfoImage(video: video),
                          const SizedBox(height: 12),
                          InfoDetails(video: video),
                          const Divider(
                            thickness: 1.5,
                            color: Colors.grey,
                            indent: 20,
                            endIndent: 20,
                          ),
                          DetailsText(video: video),
                        ],
                      ),
                    ),
                  ),
                );      
              } else if (state is VideoDetailsError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
