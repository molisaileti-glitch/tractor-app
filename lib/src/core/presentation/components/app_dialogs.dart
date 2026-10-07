import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppDialogActions extends StatelessWidget {
  const AppDialogActions({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Submit',
    this.danger = false,
    this.loading = false,
  });

  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final String cancelLabel;
  final String confirmLabel;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: loading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              side: BorderSide(color: Colors.black.withValues(alpha: 0.14)),
            ),
            child: Text(cancelLabel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: loading ? null : onConfirm,
            style: danger
                ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                : null,
            child: loading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(confirmLabel),
          ),
        ),
      ],
    );
  }
}

Future<bool> showAppConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Continue',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        AppDialogActions(
          onCancel: () => Navigator.of(dialogContext).pop(false),
          onConfirm: () => Navigator.of(dialogContext).pop(true),
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          danger: danger,
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showAppSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Done',
}) => showAppFeedbackDialog(
  context,
  title: title,
  message: message,
  icon: Icons.check_rounded,
  color: AppColors.successGreen,
  buttonLabel: buttonLabel,
);

Future<void> showAppErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Close',
}) => showAppFeedbackDialog(
  context,
  title: title,
  message: message,
  icon: Icons.error_outline,
  color: AppColors.danger,
  buttonLabel: buttonLabel,
);

Future<void> showAppFeedbackDialog(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  required Color color,
  String buttonLabel = 'OK',
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(icon, color: color, size: 40),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedText,
              height: 1.4,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(buttonLabel),
          ),
        ),
      ],
    ),
  );
}
