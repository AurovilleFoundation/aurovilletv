import 'package:flutter/material.dart';

class AppColors {
  /// Light Theme Colors
  static const themePrimaryLightColor = themeColor;
  static const themeSecondaryLightColor = earthColor;
  static const themeAscentLightColor = goldenColor;

  /// Dark Theme Colors
  static const themePrimaryDarkColor = themeColor;
  static const themeSecondaryDarkColor = earthColor;
  static const themeAscentDarkColor = goldenColor;

  static const themeColor = Color(0xFFC96A3A);
  static const beigeColor = Color(0xFFF5EFE8);
  static const earthColor = Color(0xFF6B4A32);
  static const goldenColor = Color(0xFFD6A84A);
  static const darkColor = Color(0xFF2E2E2E);
  static const lightColor = Color(0xFFFFFFFF);

  static primaryColor(BuildContext context) => themeColor;

  // Background Color
  static const scaffoldBackgroundColor = beigeColor;
  static const backgroundLight = beigeColor;
  static const backgroundDark = darkColor;

  // Text Color
  static const textPrimaryColor = darkColor;
  static const textColorDark = darkColor;
  static const textColorLightDark = beigeColor;
  static const textColorLight = beigeColor;
  static const textColorDisabled = Colors.grey;
  static const textHintColor = earthColor;
}
