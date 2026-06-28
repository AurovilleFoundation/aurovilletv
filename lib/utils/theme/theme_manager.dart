import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class ThemeManager {}

class AppTheme {
  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeColor),
    brightness: Brightness.dark,
    useMaterial3: false,
    textTheme: GoogleFonts.cormorantGaramondTextTheme(
      ThemeData.light().textTheme,
    ),
  );

  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeColor),
    useMaterial3: true,
    textTheme: GoogleFonts.cormorantGaramondTextTheme(
      ThemeData.light().textTheme,
    ),
  );
}
