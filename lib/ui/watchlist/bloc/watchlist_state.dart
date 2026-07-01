part of 'watchlist_bloc.dart';

sealed class WatchListState extends Equatable {
  const WatchListState();
  @override
  List<Object?> get props => [];
}

final class WatchListInitial extends WatchListState {
  const WatchListInitial();
}

final class WatchListLoading extends WatchListState {
  const WatchListLoading();
}

final class WatchListLoaded extends WatchListState {
  final List<VideoModel> videos;
  const WatchListLoaded(this.videos);
  @override
  List<Object?> get props => [videos];
}

final class WatchListError extends WatchListState {
  final String message;
  const WatchListError(this.message);
  @override
  List<Object?> get props => [message];
}
