import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constant/app_colors.dart';
import '../../constant/font_helper.dart';


class MyTextField extends StatefulWidget {
  final TextStyle? textStyle;
  final TextEditingController? controller;
  final bool isPass, isReadOnly, autoFocus;
  final String hintText;
  final TextStyle? hindStyle;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextInputType textInputType;
  final VoidCallback? onTap;
  final bool isValidate;
  final String? Function(String?)? validator;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showLabel;
  final Function(String)? onChanged;
  final bool showCounter;
  final String? helperText;
  final TextStyle? helperStyle;
  final Widget? helperIcon;
  final FloatingLabelBehavior floatingLabelBehavior;
  final int? maxLines;
  const MyTextField({
    super.key,
    this.textStyle,
    this.controller,
    this.isPass = false,
    this.isReadOnly = false,
    this.autoFocus = false,
    required this.hintText,
    this.hindStyle,
    this.labelText,
    this.labelStyle,
    this.textInputType = TextInputType.text,
    this.onTap,
    this.isValidate = true,
    this.validator,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.showLabel = true,
    this.onChanged,
    this.showCounter = false,
    this.helperText,
    this.helperStyle,
    this.helperIcon,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.maxLines,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool isObserver = false;
  int textCount = 0;

  final inputBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.kcSecondaryAccentColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(8)));

  final focusedBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.kcPrimaryColor, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(8)));

  final errorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.errorColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(8)));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: AppColors.kcPrimaryAccentColor.withOpacity(0.1),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.kcPrimaryColor,
              secondary: AppColors.kcPrimaryAccentColor,
            ),
          ),
      child: TextFormField(
        controller: widget.controller,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
          textCount = value.length;
          setState(() {});
        },
        validator: widget.isValidate ? widget.validator : null,
        style: widget.textStyle ?? FontHelper.ts12w400(color: AppColors.kcDefaultText),
        readOnly: widget.isReadOnly,
        autofocus: widget.autoFocus,
        onTap: widget.onTap,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        cursorColor: AppColors.kcPrimaryColor,
        maxLines: widget.maxLines ?? 1,
        keyboardType: widget.maxLines != null
            ? TextInputType.multiline
            : widget.textInputType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counter: const Offstage(),
          isDense: true,
          prefixIcon: widget.prefixIcon != null 
              ? Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme: IconThemeData(color: AppColors.kcPrimaryColor),
                  ),
                  child: widget.prefixIcon!,
                )
              : null,
          hintText: widget.hintText,
          floatingLabelBehavior: widget.floatingLabelBehavior,
          hintStyle: widget.hindStyle ?? FontHelper.ts14w400(color: AppColors.kcCaptionLightGray),
          labelText: widget.showLabel ? (widget.labelText ?? "") : null,
          labelStyle: widget.labelStyle ?? FontHelper.ts14w400(color: AppColors.kcCaptionDarkGray),
          helperText: widget.helperText,
          helperStyle: widget.helperStyle ?? FontHelper.ts12w400(color: AppColors.kcCaptionLightGray),
          border: inputBorder,
          focusedBorder: focusedBorder,
          enabledBorder: inputBorder,
          errorBorder: errorBorder,
          focusedErrorBorder: errorBorder,
          errorStyle: FontHelper.ts12w400(color: AppColors.errorColor),
          suffixIcon: widget.isPass
              ? IconButton(
                  icon: isObserver
                      ? Icon(Icons.visibility_outlined, size: 25, color: AppColors.kcPrimaryColor)
                      : Icon(Icons.visibility_off_outlined, size: 25, color: AppColors.kcCaptionLightGray),
                  onPressed: () => setState(
                    () => isObserver = !isObserver,
                  ),
                )
              : widget.suffixIcon,
          filled: true,
          fillColor: AppColors.kcSecondaryColor,
        ),
        obscureText: widget.isPass && !isObserver,
      ),
        ),
        // Counter display
        if (widget.showCounter && widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, right: 12.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$textCount/${widget.maxLength}',
                style: FontHelper.ts12w400(
                  color: textCount > (widget.maxLength! * 0.9) 
                      ? AppColors.errorColor 
                      : AppColors.kcCaptionLightGray,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
