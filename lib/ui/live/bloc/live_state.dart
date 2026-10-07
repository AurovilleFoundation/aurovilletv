part of 'live_bloc.dart';

abstract class LiveState extends Equatable {
  const LiveState();

  @override
  List<Object?> get props => [];
}

final class LiveInitial extends LiveState {
  const LiveInitial();
}

final class LiveLoading extends LiveState {
  const LiveLoading();
}

final class LiveLoaded extends LiveState {
  final LiveStreamModel liveStream;

  const LiveLoaded({required this.liveStream});

  @override
  List<Object?> get props => [liveStream];
}

final class LiveNoCredentials extends LiveState {
  const LiveNoCredentials();
}

final class LiveError extends LiveState {
  final String message;

  const LiveError({required this.message});

  @override
  List<Object?> get props => [message];
}
