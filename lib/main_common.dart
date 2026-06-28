import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> mainCommon() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //SystemChrome.setSystemUIOverlayStyle(AppStyle().systemUiOverlayStyle);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
