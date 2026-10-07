import 'package:aurovilletv/data/models/live_stream_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/utils/secure_storage_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'live_event.dart';
part 'live_state.dart';

class LiveBloc extends Bloc<LiveEvent, LiveState> {
  final VideoApiService apiService;
  final SecureStorageManager secureStorage;

  static const String apiKeyStoreKey = 'atv_live_api_key';
  static const String apiSecretStoreKey = 'atv_live_api_secret';

  LiveBloc({required this.apiService, required this.secureStorage})
    : super(const LiveInitial()) {
    on<LoadLiveStatus>(_onLoadLiveStatus);
    on<RefreshLiveStatus>(_onLoadLiveStatus);
    on<SaveCredentials>(_onSaveCredentials);
    on<ClearCredentials>(_onClearCredentials);
  }

  Future<void> _onLoadLiveStatus(
    LiveEvent event,
    Emitter<LiveState> emit,
  ) async {
    emit(const LiveLoading());

    try {
      var apiKey = await secureStorage.getValue(apiKeyStoreKey);
      var apiSecret = await secureStorage.getValue(apiSecretStoreKey);

      if (apiKey == null ||
          apiSecret == null ||
          apiKey.trim().isEmpty ||
          apiSecret.trim().isEmpty) {
        final envKey = dotenv.env['LIVE_API_KEY'] ?? 'ecadacc37f4fd48';
        final envSecret = dotenv.env['LIVE_API_SECRET'] ?? '278a8eda422a329';
        apiKey = envKey.trim();
        apiSecret = envSecret.trim();
        await secureStorage.updateValue(apiKeyStoreKey, apiKey);
        await secureStorage.updateValue(apiSecretStoreKey, apiSecret);
      }

      final liveStream = await apiService.getLiveStream(
        apiKey: apiKey.trim(),
        apiSecret: apiSecret.trim(),
      );

      emit(LiveLoaded(liveStream: liveStream));
    } catch (error) {
      emit(LiveError(message: error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSaveCredentials(
    SaveCredentials event,
    Emitter<LiveState> emit,
  ) async {
    emit(const LiveLoading());

    try {
      await secureStorage.updateValue(apiKeyStoreKey, event.apiKey);
      await secureStorage.updateValue(apiSecretStoreKey, event.apiSecret);
      await _onLoadLiveStatus(const LoadLiveStatus(), emit);
    } catch (error) {
      emit(LiveError(message: error.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onClearCredentials(
    ClearCredentials event,
    Emitter<LiveState> emit,
  ) async {
    emit(const LiveLoading());

    try {
      await secureStorage.deleteValue(apiKeyStoreKey);
      await secureStorage.deleteValue(apiSecretStoreKey);
      emit(const LiveNoCredentials());
    } catch (error) {
      emit(LiveError(message: error.toString().replaceAll('Exception: ', '')));
    }
  }
}
