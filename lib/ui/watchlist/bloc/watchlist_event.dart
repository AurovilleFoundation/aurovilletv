part of 'watchlist_bloc.dart';

sealed class WatchListEvent extends Equatable {
  const WatchListEvent();

  @override
  List<Object?> get props => [];
}

/// Load all videos from SQLite
final class LoadWatchList extends WatchListEvent {
  const LoadWatchList();
}

/// Add a video to SQLite
final class AddVideo extends WatchListEvent {
  final VideoModel video;
  const AddVideo(this.video);

  @override
  List<Object?> get props => [video];
}

/// Remove a video from SQLite
final class RemoveVideo extends WatchListEvent {
  final String videoId;
  const RemoveVideo(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

/// Reload the list
final class RefreshWatchList extends WatchListEvent {
  const RefreshWatchList();
}
