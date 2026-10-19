import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_motion.dart';

Future<void> showAppThemeReveal(
  BuildContext originContext, {
  required Color color,
  required Future<void> Function() onCovered,
}) async {
  if (!AppMotion.animationsEnabled(originContext)) {
    await onCovered();
    return;
  }

  final overlay = Overlay.of(originContext, rootOverlay: true);
  final renderObject = originContext.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) {
    await onCovered();
    return;
  }

  final origin = renderObject.localToGlobal(
    renderObject.size.center(Offset.zero),
  );
  final screenSize = MediaQuery.sizeOf(originContext);
  final completer = Completer<void>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ThemeRevealOverlay(
      origin: origin,
      screenSize: screenSize,
      color: color,
      onCovered: onCovered,
      onFinished: () {
        entry.remove();
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );
  overlay.insert(entry);
  await completer.future;
}

class _ThemeRevealOverlay extends StatefulWidget {
  const _ThemeRevealOverlay({
    required this.origin,
    required this.screenSize,
    required this.color,
    required this.onCovered,
    required this.onFinished,
  });

  final Offset origin;
  final Size screenSize;
  final Color color;
  final Future<void> Function() onCovered;
  final VoidCallback onFinished;

  @override
  State<_ThemeRevealOverlay> createState() => _ThemeRevealOverlayState();
}

class _ThemeRevealOverlayState extends State<_ThemeRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    widget.onCovered();
    _controller.forward().whenComplete(widget.onFinished);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farthestX = math.max(
      widget.origin.dx,
      widget.screenSize.width - widget.origin.dx,
    );
    final farthestY = math.max(
      widget.origin.dy,
      widget.screenSize.height - widget.origin.dy,
    );
    final maxRadius = math.sqrt(farthestX * farthestX + farthestY * farthestY);

    return Positioned.fill(
      child: AbsorbPointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final expansion = Curves.easeInOutCubicEmphasized.transform(
              (progress / 0.86).clamp(0.0, 1.0),
            );
            final opacity = progress < 0.86
                ? 1.0
                : 1 - Curves.easeOutCubic.transform((progress - 0.86) / 0.14);
            return CustomPaint(
              size: widget.screenSize,
              painter: _ThemeRevealPainter(
                origin: widget.origin,
                radius: maxRadius * expansion,
                color: widget.color.withValues(
                  alpha: 0.38 * opacity.clamp(0.0, 1.0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ThemeRevealPainter extends CustomPainter {
  const _ThemeRevealPainter({
    required this.origin,
    required this.radius,
    required this.color,
  });

  final Offset origin;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final shader = RadialGradient(
      colors: [
        color.withValues(alpha: color.a * 0.82),
        color,
      ],
      stops: const [0.82, 1],
    ).createShader(Rect.fromCircle(center: origin, radius: radius));
    canvas.drawCircle(origin, radius, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _ThemeRevealPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}
