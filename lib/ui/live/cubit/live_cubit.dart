import 'package:aurovilletv/data/models/live_stream_model.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/utils/secure_storage_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'live_state.dart';

class LiveCubit extends Cubit<LiveState> {
  final VideoApiService apiService;
  final SecureStorageManager secureStorage;

  static const String apiKeyStoreKey = "atv_live_api_key";
  static const String apiSecretStoreKey = "atv_live_api_secret";

  LiveCubit({required this.apiService, required this.secureStorage})
      : super(const LiveInitial()) {
    _init();
  }

  Future<void> _init() async {
    await loadLiveStatus();
  }

  Future<void> loadLiveStatus() async {
    emit(const LiveLoading());

    try {
      var apiKey = await secureStorage.getValue(apiKeyStoreKey);
      var apiSecret = await secureStorage.getValue(apiSecretStoreKey);

      if (apiKey == null || apiSecret == null || apiKey.trim().isEmpty || apiSecret.trim().isEmpty) {
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
    } catch (e) {
      emit(LiveError(message: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> saveCredentials(String apiKey, String apiSecret) async {
    emit(const LiveLoading());
    await secureStorage.updateValue(apiKeyStoreKey, apiKey);
    await secureStorage.updateValue(apiSecretStoreKey, apiSecret);
    await loadLiveStatus();
  }

  Future<void> clearCredentials() async {
    emit(const LiveLoading());
    await secureStorage.deleteValue(apiKeyStoreKey);
    await secureStorage.deleteValue(apiSecretStoreKey);
    emit(const LiveNoCredentials());
  }
}
