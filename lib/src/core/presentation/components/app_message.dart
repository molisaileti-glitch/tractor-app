import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppMessageType { info, success, warning, error }

class AppMessage extends StatelessWidget {
  const AppMessage({
    super.key,
    required this.message,
    this.title,
    this.type = AppMessageType.info,
  });

  final String? title;
  final String message;
  final AppMessageType type;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      AppMessageType.info => (AppColors.info, Icons.info_outline),
      AppMessageType.success => (
        AppColors.successGreen,
        Icons.check_circle_outline,
      ),
      AppMessageType.warning => (AppColors.warning, Icons.warning_amber_rounded),
      AppMessageType.error => (AppColors.danger, Icons.error_outline),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(title!, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 3),
                  ],
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
