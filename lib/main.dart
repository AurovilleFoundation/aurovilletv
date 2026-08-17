import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/enums.dart';
import 'package:aurovilletv/main_common.dart';
import 'package:aurovilletv/ui/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await mainCommon();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }
  await setupServiceLocator(appType: AppType.prod);
  runApp(const MyApp());
}
