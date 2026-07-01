import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/watchlist_bloc.dart';
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
            return const _EmptyWatchList();
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
                      // TODO:
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

class _EmptyWatchList extends StatelessWidget {
  const _EmptyWatchList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bookmark_border_rounded, size: 90, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Your Watchlist is Empty",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "Videos you save for later will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
