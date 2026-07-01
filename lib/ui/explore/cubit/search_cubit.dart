import 'dart:async';

import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final VideoApiService apiService;

  Timer? _debounce;

  SearchCubit({required this.apiService}) : super(const SearchState());

  void search(String keyword) {
    _debounce?.cancel();

    if (keyword.trim().isEmpty) {
      emit(const SearchState());
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _performSearch(keyword),
    );
  }

  Future<void> _performSearch(String keyword) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final videos = await apiService.searchVideos(keyword: keyword);

      emit(state.copyWith(isLoading: false, videos: videos));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void clear() {
    _debounce?.cancel();
    emit(const SearchState());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
