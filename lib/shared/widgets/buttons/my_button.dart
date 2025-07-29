import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../constant/app_colors.dart';
import '../../constant/font_helper.dart';

class MyButton extends StatefulWidget {
  final String text;
  final Color? textColor;
  final double? width, height;
  final AsyncCallback onPressed;
  final Color? color;
  final BorderRadius borderRadius;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;
  final bool disabled;
  final TextStyle? textStyle;
  final Widget? leadingIcon;
  final Widget? prefixIcon;

  const MyButton({
    super.key,
    required this.text,
    this.textColor = AppColors.kcWhite,
    this.width,
    this.height = 40,
    required this.onPressed,
    this.color = AppColors.kcPrimaryColor,
    this.borderColor = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.boxShadow,
    this.disabled = false,
    this.textStyle,
    this.leadingIcon,
    this.prefixIcon,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.disabled,
      child: GestureDetector(
        onTap: isPressed
            ? null
            : () async {
                setState(() {
                  isPressed = !isPressed;
                });
                await widget.onPressed().catchError((e) {
                  // CommonWidget.toastError(e.toString());
                });
                setState(() {
                  isPressed = !isPressed;
                });
              },
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: (widget.disabled && widget.color != Colors.transparent)
                ? AppColors.kcButtonDisabledColor
                : widget.color,
            borderRadius: widget.borderRadius,
            border: Border.all(
                color: (widget.disabled &&
                        widget.borderColor != Colors.transparent)
                    ? widget.borderColor.withOpacity(0.5)
                    : widget.borderColor),
            boxShadow: widget.boxShadow,
          ),
          child: Center(
            child: isPressed
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Add prefix icon if provided
                      if (widget.prefixIcon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: widget.prefixIcon,
                        ),
                      Text(
                        widget.text,
                        style: (widget.textStyle ??
                                FontHelper.ts16w700(color: AppColors.kcWhite))
                            .copyWith(color: widget.textColor),
                      ),
                      // Add leading icon if provided
                      if (widget.leadingIcon != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: widget.leadingIcon,
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
