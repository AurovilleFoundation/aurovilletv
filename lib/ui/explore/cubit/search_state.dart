part of 'search_cubit.dart';

class SearchState extends Equatable {
  final bool isLoading;
  final List<VideoModel> videos;
  final String? errorMessage;

  const SearchState({
    this.isLoading = false,
    this.videos = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    bool? isLoading,
    List<VideoModel>? videos,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      videos: videos ?? this.videos,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, videos, errorMessage];
}
