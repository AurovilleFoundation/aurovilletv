import 'package:aurovilletv/ui/main/main_screen.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../utils/values/strings.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeColor),
        scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
        useMaterial3: true,
        textTheme: GoogleFonts.cormorantGaramondTextTheme(
          ThemeData.light().textTheme.copyWith(),
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
