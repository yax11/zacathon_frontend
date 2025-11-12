import 'package:flutter/material.dart';
import '../../app/core/theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Color bgColor = backgroundColor ?? _getBackgroundColor();
    Color txtColor = textColor ?? _getTextColor();
    double btnHeight = height ?? _getHeight();
    EdgeInsets btnPadding = padding ?? _getPadding();
    BorderRadius btnRadius = borderRadius ?? BorderRadius.circular(8);

    Widget child = _buildChild(txtColor);

    if (type == ButtonType.outline) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: btnHeight,
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: btnPadding,
            shape: RoundedRectangleBorder(borderRadius: btnRadius),
            side: BorderSide(
              color: isDisabled ? AppColors.border : (backgroundColor ?? AppColors.primary),
              width: 2,
            ),
          ),
          child: child,
        ),
      );
    }

    if (type == ButtonType.text) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: btnHeight,
        child: TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            padding: btnPadding,
            shape: RoundedRectangleBorder(borderRadius: btnRadius),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: btnHeight,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? AppColors.border : bgColor,
          foregroundColor: txtColor,
          padding: btnPadding,
          elevation: type == ButtonType.secondary ? 0 : 2,
          shape: RoundedRectangleBorder(borderRadius: btnRadius),
        ),
        child: child,
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize(), color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.background;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.textWhite;
      case ButtonType.secondary:
        return AppColors.primary;
      case ButtonType.outline:
        return backgroundColor ?? AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

