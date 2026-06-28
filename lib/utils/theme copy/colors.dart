import 'package:flutter/material.dart';

class AppColors {
  /// Light Theme Colors
  static const themePrimaryLightColor = Color(0xFF9B543E);
  static const themeSecondaryLightColor = "";
  static const themeAscentLightColor = "";

  /// Dark Theme Colors
  static const themePrimaryDarkColor = "";
  static const themeSecondaryDarkColor = "";
  static const themeAscentDarkColor = "";

  //static const themeColor = Color(0xFF9B543E);
  static const MaterialColor themeColor = Colors.teal;
  static const themeColorSecondary = themeColor;

  static primaryColor(BuildContext context) => themeColor;

  // Background Color
  static const scaffoldBackgroundColor = Colors.white;
  static const backgroundLight = Colors.white;
  static const backgroundDark = Color(0xFF48D5C7);

  static const webBgColorPrimary = Color(0xFF212332);
  static const webBgColorSecondary = Color(0xFF2A2D3E);

  static const toolbarForegroundColor = Colors.white;
  static const inputBackgroundColor = Colors.white;

  // Text Color
  //static textPrimaryColor() => textColorDark;
  static const textPrimaryColor = textColorDark;
  static const textColorDark = Colors.black;
  static const textColorLightDark = Color(0xFF494949);
  static const textColorLight = Colors.white;
  static const textColorDisabled = Colors.grey;
  static const textHintColor = Color(0xFFACACAC);
}
