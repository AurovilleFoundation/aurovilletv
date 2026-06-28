import 'dart:developer';

import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/ui/widgets/dialogs.dart';
import 'package:aurovilletv/utils/extensions.dart';
import 'package:aurovilletv/utils/secure_storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

import '../data/models/enums.dart';
import 'app_constants.dart';
import 'theme/colors.dart';
import 'theme/styles.dart';
import 'values/strings.dart';

class AppUtils {
  static final AppUtils _instance = AppUtils._internal();

  factory AppUtils() => _instance;

  final bool _isDubugMode = kDebugMode;

  AppUtils._internal();

  void popScreen(BuildContext context, {dynamic value}) {
    Navigator.of(context).pop(value);
  }

  void pageRoute(BuildContext context, dynamic page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => page));
  }

  void pageRouteDialog(BuildContext context, dynamic page) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return page;
        },
      ),
    );
  }

  void pageRouteReplacement(BuildContext context, dynamic page) {
    Navigator.of(
      context,
    ).pushReplacement(CupertinoPageRoute(builder: (context) => page));
  }

  void pageRouteUntilClearStack(
    BuildContext context,
    dynamic page, {
    bool canClearStack = true,
  }) {
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (context) => page),
      (route) => !canClearStack,
    );
  }

  bool isValidPhoneNumber(String? phone) {
    if (phone.isNullOrEmpty()) {
      return false;
    } else if (phone!.length < 10) {
      return false;
    } else {
      return true;
    }
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<void> openUrl(String url) async {
    if (url.contains("http:")) {
      url = url.replaceAll("http:", "https:");
    }
    var browserUrl = Uri.parse(url);

    if (await canLaunchUrl(browserUrl)) {
      await launchUrl(browserUrl);
      // getIt<AnalyticsManager>()
      //     .logEvent(name: AppStrings().faEventPrivacyClicked);
    }
  }

  Future<void> openPhoneCall(String number) async {
    var telephoneUrl = Uri.parse("tel:$number");
    if (await canLaunchUrl(telephoneUrl)) {
      await launchUrl(telephoneUrl);
      // getIt<AnalyticsManager>()
      //     .logEvent(name: AppStrings().faEventEmergenyCall);
    }
  }

  Future<void> openEmail(String email, String sub, String msg) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject= $sub &body= $msg',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      // getIt<AnalyticsManager>()
      //     .logEvent(name: AppStrings().faEventEmergenyCall);
    }
  }

  void _handleError(String msg) {}

  String getDateString(DateTime date) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    return dateFormat.format(date);
  }

  String getDateStringFullMonth(DateTime date) {
    final DateFormat dateFormat = DateFormat('dd MMMM, yyyy');
    return dateFormat.format(date);
  }

  String getTimeString(DateTime? time) {
    if (time == null) return "";
    final DateFormat dateFormat = DateFormat('hh:mm a');
    return dateFormat.format(time);
  }

  String getDateStringForFeedDetail(DateTime date) {
    final DateFormat dateFormat = DateFormat('hh:mm a | dd MMM, yyyy');
    return dateFormat.format(date);
  }

  String getFullDateTimeString(DateTime date) {
    final DateFormat dateFormat = DateFormat('dd MMM, yyyy. hh:mm a');
    return dateFormat.format(date);
  }

  String getDateTimeForEvent(DateTime date) {
    final DateFormat dateFormat = DateFormat('EEEE, MMM dd, yyyy. hh:mm a');
    return dateFormat.format(date);
  }

  String getWeekdayString(int day, {bool isFull = false}) {
    String value;
    switch (day) {
      case 1:
        value = (isFull) ? "Monday: " : "MON";
        break;
      case 2:
        value = (isFull) ? "Tuesday: " : "TUE";
        break;
      case 3:
        value = (isFull) ? "Wednesday: " : "WED";
        break;
      case 4:
        value = (isFull) ? "Thursday: " : "THU";
        break;
      case 5:
        value = (isFull) ? "Friday: " : "FRI";
        break;
      case 6:
        value = (isFull) ? "Saturday: " : "SAT";
        break;
      case 7:
        value = (isFull) ? "Sunday: " : "SUN";
        break;
      default:
        value = "";
    }
    return value;
  }

  void logData(String? data) {
    if (_isDubugMode) {
      log("$data");
    }
  }

  void showLogoutDialog(BuildContext context) {
    AppUtils().showAlertDialog(
      context,
      content: AppStrings.logoutMsg,
      okayBtn: AppStrings.logout,
      cancelBtn: AppStrings.cancel,
      onOkayPressed: () {
        logout(context);
      },
    );
  }

  void logout(BuildContext context) {
    clearData();
    // AppUtils().pageRouteUntilClearStack(context, const LoginScreen());
  }

  void clearData() {
    getIt<AppConstants>().clear();
    getIt<SecureStorageManager>().deleteAll();
  }

  void showAboutInfo(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationIcon: Container(
        alignment: Alignment.center,
        width: 72,
        height: 72,
        child: const FlutterLogo(size: 56),
      ),
      applicationName: AppStrings.appName,
      applicationVersion: getIt<AppConstants>().versionInfo,
      applicationLegalese: AppStrings().appLegalese,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(AppStrings().aboutApp, textAlign: TextAlign.justify),
        ),
      ],
    );
  }

  void showSnackBar(BuildContext context, String msg) {
    var snackdemo = SnackBar(
      content: Text(
        msg,
        style: AppStyle.textStyleMedium.copyWith(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      backgroundColor: AppColors.themeColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackdemo);
  }

  void showMaterialBanner(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(msg),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leadingPadding: const EdgeInsets.only(right: 30),
        leading: (icon != null) ? const Icon(Icons.info, size: 32) : null,
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void showAlertDialog(
    BuildContext context, {
    String? title,
    String? content,
    String? okayBtn,
    String? cancelBtn,
    Function? onOkayPressed,
    Function? onCancelPressed,
    bool isCancellable = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: isCancellable,
      builder: (BuildContext context) {
        return MyAlertDialog(
          title: title,
          content: content,
          okayBtn: okayBtn,
          cancelBtn: cancelBtn,
          isCancellable: isCancellable,
          onOkayPressed: onOkayPressed,
          onCancelPressed: onCancelPressed,
        );
      },
    );
  }
}
