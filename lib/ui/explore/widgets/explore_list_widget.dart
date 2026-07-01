import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../watchlist/widgets/video_cell_widget.dart';
import '../bloc/explore_bloc.dart';

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
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.videos.isEmpty) {
          return _ErrorWidget(message: state.errorMessage!);
        }

        if (state.videos.isEmpty) {
          return const _EmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ExploreBloc>().add(const RefreshExplore());
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: state.videos.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final video = state.videos[index];

              return VideoCellWidget(video: video, onTap: () {});
            },
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No Videos Found",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "There are no videos available in this category.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 70, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Something went wrong",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                context.read<ExploreBloc>().add(const RefreshExplore());
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
