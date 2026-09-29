part of 'explore_bloc.dart';

class ExploreState extends Equatable {
  final bool isLoading;
  final List<CategoryModel> categories;
  final String selectedCategoryId;
  final List<VideoModel> videos;
  final String selectedCategory; // 👉 new field for All/Live/Upcoming/Ended
  final String? errorMessage;

  const ExploreState({
    this.isLoading = false,
    this.categories = const [],
    this.selectedCategoryId = "",
    this.videos = const [],
    this.selectedCategory = "All", // ✅ default tab
    this.errorMessage,
  });

  ExploreState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
    String? selectedCategoryId,
    List<VideoModel>? videos,
    String? selectedCategory,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      videos: videos ?? this.videos,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        categories,
        selectedCategoryId,
        videos,
        selectedCategory,
        errorMessage,
      ];
}
