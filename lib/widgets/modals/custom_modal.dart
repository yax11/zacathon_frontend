import 'package:flutter/material.dart';
import '../../app/core/theme/app_colors.dart';
import '../buttons/custom_button.dart';

class CustomModal extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancelButton;
  final bool isDismissible;
  final double? height;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<Widget>? actions;

  const CustomModal({
    super.key,
    this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = true,
    this.isDismissible = true,
    this.height,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCancelButton = true,
    bool isDismissible = true,
    double? height,
    EdgeInsets? padding,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    List<Widget>? actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomModal(
        title: title,
        message: message,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancelButton: showCancelButton,
        isDismissible: isDismissible,
        height: height,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.background,
        borderRadius: borderRadius ??
            const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  if (title != null) ...[
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Message
                  if (message != null) ...[
                    Text(
                      message!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Custom Content
                  if (content != null) ...[
                    content!,
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  if (actions != null)
                    ...actions!
                  else if (onConfirm != null || onCancel != null) ...[
                    Row(
                      children: [
                        if (showCancelButton && onCancel != null) ...[
                          Expanded(
                            child: CustomButton(
                              text: cancelText ?? 'Cancel',
                              type: ButtonType.outline,
                              onPressed: () {
                                Navigator.pop(context);
                                onCancel?.call();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (onConfirm != null)
                          Expanded(
                            child: CustomButton(
                              text: confirmText ?? 'Confirm',
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm?.call();
                        },
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog variant
class CustomDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancelButton;

  const CustomDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    Widget? content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCancelButton = true,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancelButton: showCancelButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (message != null) ...[
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (content != null) ...[
              content!,
              const SizedBox(height: 24),
            ],
            if (onConfirm != null || onCancel != null)
              Row(
                children: [
                  if (showCancelButton && onCancel != null) ...[
                    Expanded(
                      child: CustomButton(
                        text: cancelText ?? 'Cancel',
                        type: ButtonType.outline,
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (onConfirm != null)
                    Expanded(
                      child: CustomButton(
                        text: confirmText ?? 'Confirm',
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm?.call();
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

