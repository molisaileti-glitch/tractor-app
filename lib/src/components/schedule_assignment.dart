import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

String scheduleStatusLabel(String status, AppLocalizations strings) =>
    switch (status) {
      'scheduled' => strings.scheduled,
      'assigned' => strings.assigned,
      'dispatched' => strings.dispatched,
      'enRoute' => strings.enRoute,
      'arrived' => strings.arrived,
      'inProgress' => strings.calendarStatusInProgress,
      'paused' => strings.calendarStatusPaused,
      'completedPendingConfirmation' => strings.calendarStatusCompleted,
      'verified' => strings.calendarStatusVerified,
      'closed' => strings.calendarStatusClosed,
      'cancelled' => strings.calendarStatusCancelled,
      'flagged' => strings.calendarStatusFlagged,
      _ => status,
    };

Color scheduleStatusColor(String status, ColorScheme scheme) =>
    switch (status) {
      'scheduled' || 'assigned' => const Color(0xFF64748B),
      'dispatched' => const Color(0xFFF59E0B),
      'enRoute' => const Color(0xFFF97316),
      'arrived' => const Color(0xFF0EA5E9),
      'inProgress' => const Color(0xFF2563EB),
      'paused' => const Color(0xFF7C3AED),
      'completedPendingConfirmation' => const Color(0xFF10B981),
      'verified' => const Color(0xFF059669),
      'closed' => const Color(0xFF334155),
      'cancelled' => const Color(0xFF94A3B8),
      'flagged' => scheme.error,
      _ => scheme.primary,
    };

class ScheduleAssignment {
  const ScheduleAssignment({
    required this.id,
    required this.reference,
    required this.start,
    required this.end,
    required this.title,
    required this.details,
    required this.status,
    this.statusKey,
    required this.color,
    required this.onOpen,
  });

  final String id;
  final String reference;
  final DateTime start;
  final DateTime end;
  final String title;
  final List<String> details;
  final String status;
  final String? statusKey;
  final Color color;
  final VoidCallback onOpen;

  DateTime get effectiveEnd =>
      end.isAfter(start) ? end : start.add(const Duration(hours: 1));

  bool occursOn(DateTime date) {
    final day = DateUtils.dateOnly(date);
    final nextDay = DateTime(day.year, day.month, day.day + 1);
    return start.isBefore(nextDay) && effectiveEnd.isAfter(day);
  }
}
