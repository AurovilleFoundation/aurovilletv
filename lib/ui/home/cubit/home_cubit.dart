import 'package:aurovilletv/data/models/home_data_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeDataModel homeData;

  const HomeLoaded({required this.homeData});

  @override
  List<Object?> get props => [homeData];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

class HomeCubit extends Cubit<HomeState> {
  final VideoApiService apiService;

  HomeCubit({required this.apiService}) : super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final homeData = await apiService.getHomeData();
      emit(HomeLoaded(homeData: homeData));
    } catch (e) {
      emit(HomeError(message: e.toString().replaceAll("Exception: ", "")));
    }
  }
}
