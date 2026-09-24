import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/enums.dart';
import 'package:aurovilletv/main_common.dart';
import 'package:aurovilletv/ui/app/my_app.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/data/network/repository/video_api_service_impl.dart';
import 'package:aurovilletv/data/network/dio_client.dart';
import 'package:aurovilletv/utils/dbmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory only for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await mainCommon();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  await setupServiceLocator(appType: AppType.prod);

  // Force DB init before UI starts
  await DBManager.instance.database;

  // Run root widget with Provider
  runApp(
    MultiProvider(
      providers: [
        Provider<VideoApiService>(
          create: (_) => VideoApiServiceImpl(
            dioClient: DioClient(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
