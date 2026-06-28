import 'package:flutter/material.dart';

import 'colors.dart';

class ThemeManager {}

class AppTheme {
  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.themeColor,
    ),
    brightness: Brightness.dark,
    useMaterial3: false,
    //textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
  );

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.themeColor,
    ),
    useMaterial3: true,
    //textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
  );
}
