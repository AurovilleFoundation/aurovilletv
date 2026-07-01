import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/cubit/search_cubit.dart';
import 'package:aurovilletv/ui/watchlist/widgets/video_cell_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
  final VideoApiService apiService;

  const SearchScreen({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return const _SearchView();
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search videos',
            border: InputBorder.none,
          ),
          onChanged: cubit.search,
        ),
        actions: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, _) {
              if (value.text.isEmpty) {
                return const SizedBox();
              }

              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  cubit.clear();
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (_controller.text.isEmpty) {
            return const _EmptySearchWidget();
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return _ErrorWidget(message: state.errorMessage!);
          }

          if (state.videos.isEmpty) {
            return const _NoResultWidget();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.videos.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final video = state.videos[index];

              return VideoCellWidget(
                video: video,
                onTap: () {
                  /// TODO
                  /// Open Player Screen
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptySearchWidget extends StatelessWidget {
  const _EmptySearchWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Search Auroville TV",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

class _NoResultWidget extends StatelessWidget {
  const _NoResultWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("No videos found", style: TextStyle(fontSize: 18)),
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
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
