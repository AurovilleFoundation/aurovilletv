part of 'live_bloc.dart';

sealed class LiveEvent extends Equatable {
  const LiveEvent();

  @override
  List<Object?> get props => [];
}

final class LoadLiveStatus extends LiveEvent {
  const LoadLiveStatus();
}

final class RefreshLiveStatus extends LiveEvent {
  const RefreshLiveStatus();
}

final class SaveCredentials extends LiveEvent {
  final String apiKey;
  final String apiSecret;

  const SaveCredentials({required this.apiKey, required this.apiSecret});

  @override
  List<Object?> get props => [apiKey, apiSecret];
}

final class ClearCredentials extends LiveEvent {
  const ClearCredentials();
}
