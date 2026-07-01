import 'package:aurovilletv/data/models/video_model.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchListBloc extends Bloc<WatchListEvent, WatchListState> {
  final DBManager dbManager;

  WatchListBloc({required this.dbManager}) : super(const WatchListInitial()) {
    on<LoadWatchList>(_onLoadWatchList);
    on<RefreshWatchList>(_onRefreshWatchList);
    on<AddVideo>(_onAddVideo);
    on<RemoveVideo>(_onRemoveVideo);
  }

  Future<void> _onLoadWatchList(
    LoadWatchList event,
    Emitter<WatchListState> emit,
  ) async {
    emit(const WatchListLoading());

    try {
      final videos = await dbManager.getWatchList();
      emit(WatchListLoaded(videos));
    } catch (e) {
      emit(WatchListError(e.toString()));
    }
  }

  Future<void> _onRefreshWatchList(
    RefreshWatchList event,
    Emitter<WatchListState> emit,
  ) async {
    try {
      final videos = await dbManager.getWatchList();

      emit(WatchListLoaded(videos));
    } catch (e) {
      emit(WatchListError(e.toString()));
    }
  }

  Future<void> _onAddVideo(AddVideo event, Emitter<WatchListState> emit) async {
    try {
      await dbManager.addVideo(event.video);
      final videos = await dbManager.getWatchList();
      emit(WatchListLoaded(videos));
    } catch (e) {
      emit(WatchListError(e.toString()));
    }
  }

  Future<void> _onRemoveVideo(
    RemoveVideo event,
    Emitter<WatchListState> emit,
  ) async {
    try {
      await dbManager.removeVideo(event.videoId);
      final videos = await dbManager.getWatchList();
      emit(WatchListLoaded(videos));
    } catch (e) {
      emit(WatchListError(e.toString()));
    }
  }
}
