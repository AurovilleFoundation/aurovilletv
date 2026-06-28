import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/models/enums.dart';

class AppConstants {
  String? _version;
  String? _buildNumber;
  String? _versionInfo;
  String? _brand;
  String? _model;
  String? _systemVersion;
  String? _deviceInfo;
  bool? isLoggedIn;

  AppType _appType;

  AppConstants(this._appType) {
    _appType = _appType;
    PackageInfo.fromPlatform().then((value) {
      _version = value.version;
      _buildNumber = value.buildNumber;
      _versionInfo = "version - $_version ($_buildNumber)";
    });

    if (kIsWeb) {
      DeviceInfoPlugin().webBrowserInfo.then((value) {
        _brand = value.platform;
        _model = value.browserName.name;
        _systemVersion = value.userAgent;
        _deviceInfo = "$_brand / $_model / $_systemVersion";
      });
    } else if (Platform.isIOS) {
      DeviceInfoPlugin().iosInfo.then((value) {
        _brand = value.name;
        _model = value.model;
        _systemVersion = value.systemVersion;
        _deviceInfo = "$_brand / $_model / $_systemVersion";
      });
    } else if (Platform.isAndroid) {
      DeviceInfoPlugin().androidInfo.then((value) {
        _brand = value.brand;
        _model = value.model;
        _systemVersion = value.version.release;
        _deviceInfo = "$_brand / $_model / $_systemVersion";
      });
    } else {}
  }

  void clear() {}

  AppType get appType => _appType;
  String? get versionName => _version;
  String? get versionNumber => _buildNumber;
  String? get versionInfo => _versionInfo;

  String? get deviceBrand => _brand;
  String? get deviceModel => _model;
  String? get osVersion => _systemVersion;
  String? get deviceInfo => _deviceInfo;
}
