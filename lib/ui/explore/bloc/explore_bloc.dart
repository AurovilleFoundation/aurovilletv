import 'package:aurovilletv/data/models/category_model.dart';
import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final DBManager dbManager;
  final VideoApiService apiService;

  ExploreBloc({required this.dbManager, required this.apiService})
    : super(const ExploreState()) {
    on<LoadExplore>(_onLoadExplore);
    on<CategoryChanged>(_onCategoryChanged);
    on<RefreshExplore>(_onRefreshExplore);
  }

  //----------------------------------------------------------------------------
  // Load Explore Screen
  //----------------------------------------------------------------------------

  Future<void> _onLoadExplore(
    LoadExplore event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final categories = await dbManager.getCategories();

      if (categories.isEmpty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'No categories found.',
          ),
        );
        return;
      }

      final firstCategory = categories.first;

      final videos = firstCategory.id == 0
          ? await apiService.getAllVideos()
          : await apiService.getVideos(categoryId: firstCategory.id);

      emit(
        state.copyWith(
          isLoading: false,
          categories: categories,
          selectedCategoryId: firstCategory.id,
          videos: videos,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  // Category Changed
  //----------------------------------------------------------------------------

  Future<void> _onCategoryChanged(
    CategoryChanged event,
    Emitter<ExploreState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        selectedCategoryId: event.categoryId,
        clearError: true,
      ),
    );

    try {
      final videos = event.categoryId == 0
          ? await apiService.getAllVideos()
          : await apiService.getVideos(categoryId: event.categoryId);

      emit(state.copyWith(isLoading: false, videos: videos));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  //----------------------------------------------------------------------------
  // Pull To Refresh
  //----------------------------------------------------------------------------

  Future<void> _onRefreshExplore(
    RefreshExplore event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      final videos = state.selectedCategoryId == 0
          ? await apiService.getAllVideos()
          : await apiService.getVideos(categoryId: state.selectedCategoryId);

      emit(state.copyWith(videos: videos, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
