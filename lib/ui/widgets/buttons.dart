import 'package:flutter/material.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/styles.dart';

class MyElevatedButton extends StatelessWidget {
  //final double _buttonHeight = 48.h;
  final String text;
  final bool isFullWidth;
  final Function onPressed;
  final Color? backgroundColor;
  final Color textColor;

  const MyElevatedButton({
    super.key,
    this.text = "",
    this.isFullWidth = true,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (isFullWidth) ? double.infinity : null,
      //height: _buttonHeight,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            letterSpacing: .5,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class MyTextButton extends StatelessWidget {
  //final double _buttonHeight = 48.0.h;
  final String text;
  final bool isFullWidth;
  final Function onPressed;
  final Color? backgroundColor;
  final Color textColor;

  const MyTextButton({
    super.key,
    this.text = "",
    this.isFullWidth = true,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = AppColors.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (isFullWidth) ? double.infinity : null,
      //height: _buttonHeight,
      child: TextButton(
          onPressed: () => onPressed(),
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: .5,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          )),
    );
  }
}

class MyRoundIconButton extends StatelessWidget {
  const MyRoundIconButton({
    super.key,
    required this.title,
    required this.icon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.iconColor,
    required this.onPressed,
  });
  final String title;
  final IconData icon;
  final Function onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => onPressed(),
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
            backgroundColor: backgroundColor,
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          style: AppStyle.textStyleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class MoreItemButton extends StatelessWidget {
  const MoreItemButton({
    super.key,
    required this.title,
    required this.icon,
    this.backgroundColor,
    this.textColor = AppColors.themeColor,
    this.iconColor = AppColors.themeColor,
    this.isComingSoon = false,
    required this.onPressed,
  });
  final String title;
  final IconData icon;
  final Function onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final Color? iconColor;
  final bool isComingSoon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => onPressed(),
          label: Text(
            title,
            style: AppStyle.textStyleRegular.copyWith(
                color: (isComingSoon) ? AppColors.textColorDisabled : null),
            textAlign: TextAlign.center,
          ),
          icon: Icon(
            icon,
            color: (isComingSoon) ? AppColors.themeColor.shade100 : iconColor,
          ),
        ),
      ],
    );
  }
}

class MyOutlinedButton extends StatelessWidget {
  final String text;
  final bool isFullWidth;
  final Function onPressed;
  final Color textColor;
  final IconData? suffixIcon;
  final double buttonHeight;
  final double fontSize;
  final double? width;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const MyOutlinedButton({
    super.key,
    this.text = "",
    this.isFullWidth = true,
    this.textColor = AppColors.themeColor,
    this.suffixIcon,
    this.buttonHeight = 36,
    this.width,
    this.iconColor,
    this.fontSize = 14,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (isFullWidth) ? double.infinity : null,
      height: buttonHeight,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: 1, color: borderColor ?? textColor),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => onPressed(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
              ),
            ),
            if (suffixIcon != null) const SizedBox(width: 4),
            if (suffixIcon != null)
              Icon(
                suffixIcon,
                size: fontSize,
                color: textColor,
                // opticalSize: fontSize,
              ),
          ],
        ),
      ),
    );
  }
}

class MyElevatedIconButton extends StatelessWidget {
  //final double _buttonHeight = 48.h;
  final String text;
  final Function onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  const MyElevatedIconButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = AppColors.themeColor,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(
          icon,
          color: iconColor,
        ),
        label: Text(
          text,
          style: AppStyle.textStyleMedium.copyWith(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MoreIconButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final IconData icon;

  const MoreIconButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ElevatedButton.icon(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.themeColor.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        iconAlignment: IconAlignment.end,
        icon: Icon(
          icon,
          color: AppColors.themeColor,
          size: 12,
        ),
        label: Text(
          text,
          style: AppStyle.textStyleMedium.copyWith(
              fontSize: 10,
              color: AppColors.themeColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class MySquareIconButton extends StatelessWidget {
  //final double _buttonHeight = 48.h;
  final Function onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  const MySquareIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = AppColors.themeColor,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: _buttonHeight,
      child: ElevatedButton(
          onPressed: () => onPressed(),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
          )),
    );
  }
}

class LocalAuthButton extends StatelessWidget {
  final String text;
  final bool isFullWidth;
  final Function onPressed;
  final Color textColor;
  final Widget? icon;
  final double buttonHeight;
  final double fontSize;
  final double? width;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const LocalAuthButton({
    super.key,
    this.text = "",
    this.isFullWidth = true,
    this.textColor = AppColors.textColorDark,
    this.icon,
    this.buttonHeight = 36,
    this.width,
    this.iconColor,
    this.fontSize = 16,
    required this.onPressed,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (isFullWidth) ? double.infinity : null,
      height: buttonHeight,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: 1, color: borderColor ?? textColor),
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(5),
        ),
        onPressed: () => onPressed(),
        child: Stack(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: icon!,
              ),
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  //fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
