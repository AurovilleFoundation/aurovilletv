import 'package:flutter/material.dart';

import '../../utils/theme/colors.dart';
import '../../utils/theme/styles.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String hintText;
  final String labelText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextAlign textAlign;
  final int? maxLength;
  final bool readOnly;
  final bool obscureText;
  final double borderRadius;
  final Function? onTap;
  final Function? onChanged;

  const MyTextField({
    super.key,
    this.textEditingController,
    this.hintText = "",
    this.labelText = "",
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.justify,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLength,
    this.obscureText = false,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: AppStyle.textStyleInputType,
      controller: textEditingController,
      keyboardType: keyboardType,
      enabled: enabled,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      readOnly: readOnly,
      maxLength: maxLength,
      obscureText: obscureText,
      onTap: () => onTap?.call(),
      onChanged: (value) => (onChanged != null) ? onChanged!(value) : null,
      decoration: InputDecoration(
        prefixIcon: (prefixIcon != null)
            ? Icon(
                prefixIcon,
                color: AppColors.textHintColor,
              )
            : null,
        suffixIcon: (suffixIcon != null)
            ? Icon(
                suffixIcon,
                color: AppColors.textHintColor,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: AppColors.themeColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: AppColors.themeColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: AppColors.themeColor,
            width: 2,
          ),
        ),
        filled: true,
        hintText: hintText,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        labelText: (labelText.isNotEmpty) ? labelText : null,
        hintStyle: AppStyle.textStyleHint,
        counterText: "",
        counterStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class MyMultiLineTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String hintText;
  final String labelText;
  final IconData? prefixIcon;
  final TextInputAction textInputAction;
  final int maxLength;
  final int? maxLines;
  final int minLines;
  final bool autofocus;

  const MyMultiLineTextField({
    super.key,
    this.textEditingController,
    this.hintText = "",
    this.labelText = "",
    this.prefixIcon,
    this.textInputAction = TextInputAction.unspecified,
    this.maxLength = 120,
    this.maxLines,
    this.minLines = 3,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.inputBackgroundColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: TextField(
        controller: textEditingController,
        style: AppStyle.textStyleInputType,
        keyboardType: TextInputType.multiline,
        textAlign: TextAlign.justify,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: textInputAction,
        maxLength: maxLength,
        maxLines: maxLines,
        minLines: minLines,
        autofocus: autofocus,
        buildCounter: (context,
                {required currentLength,
                required isFocused,
                required maxLength}) =>
            Container(),
        decoration: InputDecoration(
            prefixIcon: (prefixIcon != null)
                ? Icon(
                    prefixIcon,
                    color: Colors.grey,
                  )
                : null,
            border: InputBorder.none,
            filled: true,
            hintText: hintText,
            labelText: (labelText.isNotEmpty) ? labelText : null,
            hintStyle: AppStyle.textStyleHint,
            //fillColor: Theme.of(context).scaffoldBackgroundColor,
            fillColor: Colors.white,
            counterStyle: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
