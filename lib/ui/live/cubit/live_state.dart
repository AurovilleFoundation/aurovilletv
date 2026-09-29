part of 'live_cubit.dart';

abstract class LiveState extends Equatable {
  const LiveState();

  @override
  List<Object?> get props => [];
}

class LiveInitial extends LiveState {
  const LiveInitial();
}

class LiveLoading extends LiveState {
  const LiveLoading();
}

class LiveLoaded extends LiveState {
  final LiveStreamModel liveStream;

  const LiveLoaded({required this.liveStream});

  @override
  List<Object?> get props => [liveStream];
}

class LiveNoCredentials extends LiveState {
  const LiveNoCredentials();
}

class LiveError extends LiveState {
  final String message;

  const LiveError({required this.message});

  @override
  List<Object?> get props => [message];
}
