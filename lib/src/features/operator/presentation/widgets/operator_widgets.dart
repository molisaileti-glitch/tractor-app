import 'package:flutter/material.dart';

import '../../domain/entities/operator_job.dart';

class OperatorCard extends StatelessWidget {
  const OperatorCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: card,
    );
  }
}

class OperatorStatusPill extends StatelessWidget {
  const OperatorStatusPill({super.key, required this.status});

  final OperatorJobStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OperatorJobStatus.scheduled => Theme.of(context).colorScheme.tertiary,
      OperatorJobStatus.dispatched => const Color(0xFF7B4BD2),
      OperatorJobStatus.enRoute => const Color(0xFF7B4BD2),
      OperatorJobStatus.inProgress => Theme.of(context).colorScheme.primary,
      OperatorJobStatus.completedPendingConfirmation => Theme.of(
        context,
      ).colorScheme.secondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class OperatorMapCard extends StatelessWidget {
  const OperatorMapCard({
    super.key,
    this.showTractor = true,
    this.showTrack = false,
    this.label = 'ASSIGNED FARM',
  });

  final bool showTractor;
  final bool showTrack;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.45,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6EFE8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OperatorMapPainter(
                  color: Theme.of(context).colorScheme.primary,
                  showTrack: showTrack,
                ),
              ),
            ),
            if (showTractor)
              Positioned(
                top: showTrack ? 78 : 48,
                left: showTrack ? 132 : 110,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.agriculture, size: 28),
                  ),
                ),
              ),
            Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF284437),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OperatorMapPainter extends CustomPainter {
  _OperatorMapPainter({required this.color, required this.showTrack});

  final Color color;
  final bool showTrack;

  @override
  void paint(Canvas canvas, Size size) {
    final farm = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.20,
        size.width * 0.56,
        size.height * 0.58,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(farm, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawRRect(
      farm,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (!showTrack) return;

    final track = Path()
      ..moveTo(size.width * 0.30, size.height * 0.68)
      ..lineTo(size.width * 0.30, size.height * 0.34)
      ..lineTo(size.width * 0.62, size.height * 0.34)
      ..lineTo(size.width * 0.62, size.height * 0.66)
      ..lineTo(size.width * 0.38, size.height * 0.66);
    canvas.drawPath(
      track,
      Paint()
        ..color = const Color(0xFF7B4BD2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _OperatorMapPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.showTrack != showTrack;
  }
}
