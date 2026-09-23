import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watchlist_bloc.dart';
import '../../video_player/video_player_screen.dart';
import 'video_cell_widget.dart';

class WatchListWidget extends StatelessWidget {
  const WatchListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchListBloc, WatchListState>(
      builder: (context, state) {
        if (state is WatchListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WatchListError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is WatchListLoaded) {
          if (state.videos.isEmpty) {
            return const _EmptyWatchListWidget();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<WatchListBloc>().add(const RefreshWatchList());
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.videos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final video = state.videos[index];

                return Dismissible(
                  key: ValueKey(video.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(color: Colors.red.shade400),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 32),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  onDismissed: (_) {
                    context.read<WatchListBloc>().add(RemoveVideo(video.id));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${video.title}" removed from Watchlist',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },

                  child: VideoCellWidget(
                    video: video,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(video: video),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyWatchListWidget extends StatelessWidget {
  const _EmptyWatchListWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "Your Watchlist is Empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.earthColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Save videos by tapping the bookmark icon in the top right corner of any video to watch them later.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
