import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/cubit/search_cubit.dart';
import 'package:aurovilletv/ui/watchlist/widgets/video_cell_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoSearchDelegate extends SearchDelegate<VideoModel?> {
  final VideoApiService apiService;

  VideoSearchDelegate({required this.apiService});

  @override
  String get searchFieldLabel => 'Search videos';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            context.read<SearchCubit>().clear();
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchBody(keyword: query);
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchBody(keyword: query);
  }

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    return null;
  }

  @override
  Widget? buildFlexibleSpace(BuildContext context) {
    return null;
  }
}

class _SearchBody extends StatelessWidget {
  final String keyword;

  const _SearchBody({required this.keyword});

  @override
  Widget build(BuildContext context) {
    if (keyword.trim().isEmpty) {
      context.read<SearchCubit>().clear();

      return const Center(
        child: Text("Search Auroville TV", style: TextStyle(fontSize: 16)),
      );
    }

    context.read<SearchCubit>().search(keyword);

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(state.errorMessage!, textAlign: TextAlign.center),
            ),
          );
        }

        if (state.videos.isEmpty) {
          return const Center(child: Text("No videos found"));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 8),
          itemCount: state.videos.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final video = state.videos[index];

            return VideoCellWidget(video: video, onTap: () {});
          },
        );
      },
    );
  }
}
