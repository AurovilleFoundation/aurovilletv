import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityManager {
  Future<bool> hasInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return true;
    }
  }
}
