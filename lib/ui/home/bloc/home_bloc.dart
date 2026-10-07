import 'package:aurovilletv/data/models/home_data_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final VideoApiService apiService;
  final DBManager? dbManager;

  HomeBloc({required this.apiService, this.dbManager})
    : super(const HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<RefreshHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(HomeEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    try {
      final homeData = await apiService.getHomeData();

      if (dbManager != null && homeData.categories.isNotEmpty) {
        try {
          await dbManager!.replaceCategories(homeData.categories);
        } catch (dbError) {
          debugPrint('Failed to cache categories in DB: $dbError');
        }
      }

      emit(HomeLoaded(homeData: homeData));
    } catch (error) {
      emit(HomeError(message: error.toString().replaceAll('Exception: ', '')));
    }
  }
}
