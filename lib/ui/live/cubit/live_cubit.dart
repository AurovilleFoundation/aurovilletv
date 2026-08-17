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
  static const String mockModeStoreKey = "atv_live_mock_mode";

  bool _isMockMode = false;

  LiveCubit({required this.apiService, required this.secureStorage})
      : super(const LiveInitial()) {
    _init();
  }

  Future<void> _init() async {
    _isMockMode = await secureStorage.getBool(mockModeStoreKey);
    await loadLiveStatus();
  }

  bool get isMockMode => _isMockMode;

  Future<void> loadLiveStatus() async {
    emit(const LiveLoading());

    if (_isMockMode) {
      // Return simulated live data
      await Future.delayed(const Duration(seconds: 1));
      emit(LiveLoaded(
        liveStream: const LiveStreamModel(
          status: "Live",
          title: "Auroville Charter Day & Matrimandir Meditations",
          description: "Live broadcasting of the annual meditations at the Matrimandir amphitheatre. Connecting Aurovillians around the globe.",
          streamUrl: "https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8", // public HLS stream URL for testing
          viewerCount: 342,
          thumbnail: "assets/images/live_banner.jpg",
        ),
        isMocked: true,
      ));
      return;
    }

    try {
      var apiKey = await secureStorage.getValue(apiKeyStoreKey);
      var apiSecret = await secureStorage.getValue(apiSecretStoreKey);

      if (apiKey == null || apiSecret == null || apiKey.trim().isEmpty || apiSecret.trim().isEmpty) {
        final envKey = dotenv.env['LIVE_API_KEY'];
        final envSecret = dotenv.env['LIVE_API_SECRET'];
        if (envKey != null && envSecret != null && envKey.trim().isNotEmpty && envSecret.trim().isNotEmpty) {
          apiKey = envKey.trim();
          apiSecret = envSecret.trim();
          await secureStorage.updateValue(apiKeyStoreKey, apiKey);
          await secureStorage.updateValue(apiSecretStoreKey, apiSecret);
        } else {
          emit(const LiveNoCredentials());
          return;
        }
      }

      final liveStream = await apiService.getLiveStream(
        apiKey: apiKey.trim(),
        apiSecret: apiSecret.trim(),
      );

      emit(LiveLoaded(liveStream: liveStream, isMocked: false));
    } catch (e) {
      emit(LiveError(message: e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> saveCredentials(String apiKey, String apiSecret) async {
    emit(const LiveLoading());
    await secureStorage.updateValue(apiKeyStoreKey, apiKey);
    await secureStorage.updateValue(apiSecretStoreKey, apiSecret);
    // Automatically turn off mock mode if credentials are saved
    _isMockMode = false;
    await secureStorage.updateBool(mockModeStoreKey, false);
    await loadLiveStatus();
  }

  Future<void> clearCredentials() async {
    emit(const LiveLoading());
    await secureStorage.deleteValue(apiKeyStoreKey);
    await secureStorage.deleteValue(apiSecretStoreKey);
    emit(const LiveNoCredentials());
  }

  Future<void> toggleMockMode(bool enabled) async {
    _isMockMode = enabled;
    await secureStorage.updateBool(mockModeStoreKey, enabled);
    await loadLiveStatus();
  }
}
