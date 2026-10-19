import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 220);
  static const standard = Duration(milliseconds: 360);
  static const emphasized = Duration(milliseconds: 560);

  static const standardCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;

  static bool animationsEnabled(BuildContext context) =>
      !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);

  static Duration duration(
    BuildContext context, [
    Duration preferred = standard,
  ]) => animationsEnabled(context) ? preferred : Duration.zero;
}

class AppFadeThroughSwitcher extends StatelessWidget {
  const AppFadeThroughSwitcher({
    super.key,
    required this.child,
    this.duration = AppMotion.standard,
    this.layoutBuilder,
  });

  final Widget child;
  final Duration duration;
  final AnimatedSwitcherLayoutBuilder? layoutBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, duration),
      reverseDuration: AppMotion.duration(context, AppMotion.fast),
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.exitCurve,
      layoutBuilder: layoutBuilder ?? AnimatedSwitcher.defaultLayoutBuilder,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.18, 1, curve: AppMotion.standardCurve),
        );
        final scale = Tween<double>(begin: 0.985, end: 1).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      child: child,
    );
  }
}

PageRoute<T> appPageRoute<T>({required WidgetBuilder builder}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionDuration: AppMotion.standard,
    reverseTransitionDuration: AppMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (!AppMotion.animationsEnabled(context)) return child;
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.standardCurve,
        reverseCurve: AppMotion.exitCurve,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.035, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
