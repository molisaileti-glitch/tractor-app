import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

void disposeAppDialogController(TextEditingController controller) {
  Future<void>.delayed(const Duration(milliseconds: 350), controller.dispose);
}

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
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
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

Future<String?> showAppTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? hintText,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Submit',
  int maxLines = 3,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _AppTextInputDialog(
      title: title,
      label: label,
      hintText: hintText,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      maxLines: maxLines,
    ),
  );
}

class _AppTextInputDialog extends StatefulWidget {
  const _AppTextInputDialog({
    required this.title,
    required this.label,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.maxLines,
    this.hintText,
  });

  final String title;
  final String label;
  final String? hintText;
  final String cancelLabel;
  final String confirmLabel;
  final int maxLines;

  @override
  State<_AppTextInputDialog> createState() => _AppTextInputDialogState();
}

class _AppTextInputDialogState extends State<_AppTextInputDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        AppDialogActions(
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(_controller.text.trim()),
          cancelLabel: widget.cancelLabel,
          confirmLabel: widget.confirmLabel,
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

Future<bool> showAppAsyncConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required Future<void> Function() onConfirm,
  String confirmLabel = 'Continue',
  String workingLabel = 'Please wait...',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _AsyncConfirmationDialog(
      title: title,
      message: message,
      onConfirm: onConfirm,
      confirmLabel: confirmLabel,
      workingLabel: workingLabel,
      cancelLabel: cancelLabel,
      danger: danger,
    ),
  );
  return result ?? false;
}

class _AsyncConfirmationDialog extends StatefulWidget {
  const _AsyncConfirmationDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.confirmLabel,
    required this.workingLabel,
    required this.cancelLabel,
    required this.danger,
  });

  final String title;
  final String message;
  final Future<void> Function() onConfirm;
  final String confirmLabel;
  final String workingLabel;
  final String cancelLabel;
  final bool danger;

  @override
  State<_AsyncConfirmationDialog> createState() =>
      _AsyncConfirmationDialogState();
}

class _AsyncConfirmationDialogState extends State<_AsyncConfirmationDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'The action could not be completed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      child: AlertDialog(
        title: Text(widget.title),
        content: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          AppDialogActions(
            onCancel: () => Navigator.of(context).pop(false),
            onConfirm: _submit,
            cancelLabel: widget.cancelLabel,
            confirmLabel: _loading ? widget.workingLabel : widget.confirmLabel,
            danger: widget.danger,
            loading: _loading,
          ),
        ],
      ),
    );
  }
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
              color: AppColors.adaptiveMutedText(context),
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
