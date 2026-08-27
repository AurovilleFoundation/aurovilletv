import 'package:flutter/material.dart';
import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/models/enums.dart';
import 'package:aurovilletv/main_common.dart';
import 'package:aurovilletv/ui/app/my_app.dart';
import 'package:provider/provider.dart';

// ✅ Import your VideoApiService interface + implementation
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/data/network/repository/video_api_service_impl.dart';
import 'package:aurovilletv/data/network/dio_client.dart';

// ✅ Import FFI only for desktop
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:aurovilletv/utils/dbmanager.dart'; // ✅ ensure DB init

Future<void> main() async {
  // ✅ Ensure Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize database factory only for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ Common setup
  mainCommon();

  // ✅ Service locator
  await setupServiceLocator(appType: AppType.prod);

  // ✅ Force DB init before UI starts
  await DBManager.instance.database;

  // ✅ Run root widget with Provider
  runApp(
    MultiProvider(
      providers: [
        Provider<VideoApiService>(
          create: (_) => VideoApiServiceImpl(
            dioClient: DioClient(), // ✅ pass required argument
          ),
        ),
        // add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}
