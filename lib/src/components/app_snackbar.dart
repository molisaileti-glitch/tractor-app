import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

enum AppSnackType { info, success, warning, error }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackType type = AppSnackType.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final (color, icon) = switch (type) {
    AppSnackType.info => (AppColors.info, Icons.info_outline),
    AppSnackType.success => (
      AppColors.successGreen,
      Icons.check_circle_outline,
    ),
    AppSnackType.warning => (AppColors.warning, Icons.warning_amber_rounded),
    AppSnackType.error => (AppColors.danger, Icons.error_outline),
  };
  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.24)),
        ),
        content: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: scheme.onSurface)),
            ),
          ],
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: color,
                onPressed: onAction,
              ),
      ),
    );
}
