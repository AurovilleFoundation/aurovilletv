import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/enums.dart';
import 'package:aurovilletv/main_common.dart';
import 'package:aurovilletv/ui/app/my_app.dart';
import 'package:flutter/material.dart';

void main() async {
  mainCommon();
  await setupServiceLocator(appType: AppType.prod);
  runApp(const MyApp());
}
