import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/localized_copy.dart';

String timeAwareGreeting(
  BuildContext context, {
  required String name,
  required DateTime now,
}) {
  if (now.hour < 12) {
    return AppLocalizations.of(context)!.goodMorning(name);
  }
  final template = now.hour < 17
      ? context.appText('Good afternoon, {name}')
      : context.appText('Good evening, {name}');
  return template.replaceAll('{name}', name);
}

class TimeAwareGreeting extends StatefulWidget {
  const TimeAwareGreeting({
    super.key,
    required this.name,
    this.style,
    this.clock,
  });

  final String name;
  final TextStyle? style;
  final DateTime Function()? clock;

  @override
  State<TimeAwareGreeting> createState() => _TimeAwareGreetingState();
}

class _TimeAwareGreetingState extends State<TimeAwareGreeting>
    with WidgetsBindingObserver {
  Timer? _boundaryTimer;

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextBoundary();
  }

  @override
  void didUpdateWidget(covariant TimeAwareGreeting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clock != widget.clock) _scheduleNextBoundary();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (mounted) setState(() {});
    _scheduleNextBoundary();
  }

  void _scheduleNextBoundary() {
    _boundaryTimer?.cancel();
    final now = _now;
    final next = switch (now.hour) {
      < 12 => DateTime(now.year, now.month, now.day, 12),
      < 17 => DateTime(now.year, now.month, now.day, 17),
      _ => DateTime(now.year, now.month, now.day + 1),
    };
    final delay = next.difference(now) + const Duration(seconds: 1);
    _boundaryTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {});
      _scheduleNextBoundary();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _boundaryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      timeAwareGreeting(context, name: widget.name, now: _now),
      style: widget.style,
    );
  }
}
