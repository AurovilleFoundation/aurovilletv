import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class AppStyle {
  get systemUiOverlayStyle => const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark, //iOS top bar color
        statusBarColor: Colors.transparent, //Android top bar color
        statusBarIconBrightness: Brightness.dark, //Android top bar icons
        systemNavigationBarColor: Colors.black, //Android bottom bar color
        systemNavigationBarIconBrightness:
            Brightness.light, //Android bottom bar icons
      );

  static const textStyleToolbarTitle = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: .5,
  );

  static const textStyleTitle = TextStyle(
    color: AppColors.textPrimaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: .5,
  );

  static const textStyleRegular = TextStyle(
    color: AppColors.textPrimaryColor,
    fontWeight: FontWeight.normal,
    fontSize: 14,
    letterSpacing: .5,
  );

  static const textStyleMedium = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 12,
    letterSpacing: .5,
  );

  static const textStyleSmall = TextStyle(
    color: AppColors.textPrimaryColor,
    fontSize: 8,
    letterSpacing: .5,
  );

  static const textStyleInputType = TextStyle(
    letterSpacing: .5,
  );

  static const textStyleHint = TextStyle(
    color: AppColors.textHintColor,
    letterSpacing: .5,
  );

  static const chatboxMeBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      topRight: Radius.zero,
      bottomRight: Radius.zero);

  static const chatboxMe = BoxDecoration(
    //color: AppColors.greenColorLight,
    color: Colors.white,
    borderRadius: chatboxMeBorderRadius,
  );

  static const chatboxOtherBorderRadius = BorderRadius.only(
      topLeft: Radius.zero,
      bottomLeft: Radius.zero,
      topRight: Radius.circular(16),
      bottomRight: Radius.circular(16));

  static const borderradiusOnlyLeft = BoxDecoration(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        topRight: Radius.zero,
        bottomRight: Radius.zero),
  );

  static const circularRadiusAll = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const chatboxOther = BoxDecoration(
    //color: AppColors.greenColorLight,
    color: Colors.white,
    borderRadius: chatboxOtherBorderRadius,
  );

  static const bgRoundCorner = BoxDecoration(
    color: AppColors.webBgColorSecondary,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
}
