import 'package:aurovilletv/data/models/enums.dart';
import 'package:aurovilletv/data/network/api_constants.dart';
import 'package:aurovilletv/utils/app_constants.dart';
import 'package:aurovilletv/utils/connectivity_manager.dart';
import 'package:aurovilletv/utils/secure_storage_manager.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator({required AppType appType}) async {
  getIt.registerSingleton(AppConstants(appType));
  getIt.registerSingleton(SecureStorageManager());
  getIt.registerSingleton(ConnectivityManager());
  getIt.registerSingleton(APIConstants());
}
