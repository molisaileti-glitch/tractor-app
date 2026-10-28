import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Consistent button feedback for actions that wait on the API.
///
/// Keeping the working label visible tells the user which action is running,
/// while the spinner and disabled parent button prevent accidental repeats.
class AppButtonContent extends StatelessWidget {
  const AppButtonContent({
    super.key,
    required this.label,
    this.loading = false,
    this.loadingLabel,
    this.icon,
    this.progressColor,
  });

  final String label;
  final bool loading;
  final String? loadingLabel;
  final IconData? icon;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Row(
        key: ValueKey(loading),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: progressColor,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 20),
          if (loading || icon != null) const SizedBox(width: 9),
          Flexible(child: Text(loading ? loadingLabel ?? label : label)),
        ],
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.trailing,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? AppButtonContent(
              label: label,
              loading: true,
              loadingLabel: label,
              progressColor: Colors.white,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label),
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  Icon(trailing, size: 22),
                ],
              ],
            ),
    );
  }
}

class AppGlowButton extends StatelessWidget {
  const AppGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailing,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailing;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.fieldGreen.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.fieldGreen,
          foregroundColor: Colors.white,
        ),
        child: loading
            ? AppButtonContent(
                label: label,
                loading: true,
                loadingLabel: label,
                progressColor: Colors.white,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(label),
                  if (trailing != null) ...[
                    const SizedBox(width: 10),
                    Icon(trailing, size: 22),
                  ],
                ],
              ),
      ),
    );
  }
}
