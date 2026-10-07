part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadHome extends HomeEvent {
  const LoadHome();
}

final class RefreshHome extends HomeEvent {
  const RefreshHome();
}
