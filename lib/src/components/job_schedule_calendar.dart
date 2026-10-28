import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_empty_state.dart';
import 'schedule_assignment.dart';

export 'schedule_assignment.dart';

/// A collision group uses two readable lanes; further jobs open in a sheet.
class CalendarCollisionGroup {
  CalendarCollisionGroup(this.entries, this.start, this.displayEnd);
  final List<ScheduleAssignment> entries;
  final DateTime start;
  final DateTime displayEnd;
}

List<CalendarCollisionGroup> calendarCollisionGroups(
  List<ScheduleAssignment> entries,
  DateTime day, {
  required int minimumMinutes,
}) {
  final midnight = DateUtils.dateOnly(day);
  final nextDay = DateTime(day.year, day.month, day.day + 1);
  DateTime start(ScheduleAssignment a) =>
      a.start.isBefore(midnight) ? midnight : a.start;
  DateTime end(ScheduleAssignment a) {
    final actualEnd = a.effectiveEnd.isAfter(nextDay)
        ? nextDay
        : a.effectiveEnd;
    final minimumEnd = start(a).add(Duration(minutes: minimumMinutes));
    return actualEnd.isAfter(minimumEnd) ? actualEnd : minimumEnd;
  }

  final ordered = entries.where((a) => a.occursOn(day)).toList()
    ..sort((a, b) {
      final order = start(a).compareTo(start(b));
      return order == 0 ? a.reference.compareTo(b.reference) : order;
    });
  final groups = <CalendarCollisionGroup>[];
  var index = 0;
  while (index < ordered.length) {
    final members = <ScheduleAssignment>[ordered[index]];
    final groupStart = start(ordered[index]);
    var groupEnd = end(ordered[index]);
    index++;
    while (index < ordered.length && start(ordered[index]).isBefore(groupEnd)) {
      final entry = ordered[index++];
      members.add(entry);
      if (end(entry).isAfter(groupEnd)) groupEnd = end(entry);
    }
    groups.add(CalendarCollisionGroup(members, groupStart, groupEnd));
  }
  return groups;
}

class JobScheduleCalendar extends StatefulWidget {
  const JobScheduleCalendar({
    super.key,
    required this.assignments,
    this.initialDate,
  });
  final List<ScheduleAssignment> assignments;
  final DateTime? initialDate;

  @override
  State<JobScheduleCalendar> createState() => _JobScheduleCalendarState();
}

class _JobScheduleCalendarState extends State<JobScheduleCalendar> {
  final _boardScroll = ScrollController();
  final _weekScroll = ScrollController();
  late DateTime _selected = DateUtils.dateOnly(
    widget.initialDate ?? DateTime.now(),
  );
  double _columnWidth = 320;
  static const _timeWidth = 62.0;
  static const _hourHeight = 64.0;

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  void _select(DateTime day) {
    setState(() => _selected = DateUtils.dateOnly(day));
    _revealSelected();
  }

  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_boardScroll.hasClients) {
        final viewport = _boardScroll.position.viewportDimension;
        _boardScroll.jumpTo(
          (viewport >= _columnWidth * 2 ? 0.0 : _timeWidth + _columnWidth)
              .clamp(0.0, _boardScroll.position.maxScrollExtent),
        );
      }
      if (_weekScroll.hasClients) {
        final viewport = _weekScroll.position.viewportDimension;
        final width = math.max(76.0, viewport / 7);
        _weekScroll.jumpTo(
          ((_selected.weekday - 1) * width - (viewport - width) / 2).clamp(
            0.0,
            _weekScroll.position.maxScrollExtent,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _boardScroll.dispose();
    _weekScroll.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final years = [
      DateTime.now().year,
      _selected.year,
      ...widget.assignments.map((a) => a.start.year),
    ]..sort();
    final date = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(years.first - 1),
      lastDate: DateTime(years.last + 2),
    );
    if (mounted && date != null) _select(date);
  }

  String _time(BuildContext context, DateTime date) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(date),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  String _statusLabel(BuildContext context, ScheduleAssignment entry) =>
      entry.statusKey == null
      ? entry.status
      : scheduleStatusLabel(entry.statusKey!, AppLocalizations.of(context)!);

  Future<void> _expand(DateTime day, List<ScheduleAssignment> entries) async {
    final ordered = entries.toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final chosen = await showModalBottomSheet<ScheduleAssignment>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        final strings = AppLocalizations.of(context)!;
        final date = MaterialLocalizations.of(context).formatMediumDate(day);
        if (ordered.isEmpty) {
          return SizedBox(
            key: const ValueKey('empty-calendar-day'),
            height: math.min(
              420,
              math.max(280, MediaQuery.sizeOf(context).height * .46),
            ),
            child: AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: strings.noAssignmentsOn(date),
            ),
          );
        }
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * .78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  strings.assignmentsOn(ordered.length, date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  key: const ValueKey('expanded-calendar-jobs'),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: ordered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final a = ordered[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        key: ValueKey('expanded-assignment-${a.id}'),
                        onTap: () => Navigator.of(context).pop(a),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: a.color, width: 4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    a.reference,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  _CalendarStatusBadge(
                                    label: _statusLabel(context, a),
                                    color: a.color,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_time(context, a.start)} - ${_time(context, a.effectiveEnd)}',
                              ),
                              const SizedBox(height: 8),
                              Text(a.title),
                              for (final detail in a.details) Text(detail),
                              const SizedBox(height: 8),
                              Text(AppLocalizations.of(context)!.openJob),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    if (mounted && chosen != null) chosen.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    final local = MaterialLocalizations.of(context);
    final strings = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    final minimumHeight = math.max(52.0, 48 * scale);
    final minimumMinutes = ((minimumHeight + 8) / _hourHeight * 60).ceil();
    final days = List.generate(
      3,
      (i) => DateTime(_selected.year, _selected.month, _selected.day + i - 1),
    );
    final groups = [
      for (final day in days)
        calendarCollisionGroups(
          widget.assignments,
          day,
          minimumMinutes: minimumMinutes,
        ),
    ];
    var minHour = 6;
    var maxHour = 19;
    for (var index = 0; index < days.length; index++) {
      for (final group in groups[index]) {
        minHour = math.min(minHour, group.start.hour);
        final relativeEnd = group.displayEnd.difference(days[index]).inMinutes;
        maxHour = math.max(maxHour, (relativeEnd / 60).ceil().clamp(0, 24));
      }
    }
    final boardHeight = (maxHour - minHour) * _hourHeight + minimumHeight + 16;
    final selectedEntries = widget.assignments
        .where((a) => a.occursOn(_selected))
        .toList();
    final monday = DateTime(
      _selected.year,
      _selected.month,
      _selected.day - _selected.weekday + 1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(
                  local.formatMediumDate(_selected),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Previous day',
              onPressed: () => _select(days.first),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Next day',
              onPressed: () => _select(days.last),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            controller: _weekScroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Builder(
                    builder: (context) {
                      final day = DateTime(
                        monday.year,
                        monday.month,
                        monday.day + i,
                      );
                      final selected = DateUtils.isSameDay(day, _selected);
                      return SizedBox(
                        width: math.max(76, constraints.maxWidth / 7),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Material(
                            color: selected
                                ? scheme.primary
                                : scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _select(day),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'en'
                                          ? const [
                                              'Mon',
                                              'Tue',
                                              'Wed',
                                              'Thu',
                                              'Fri',
                                              'Sat',
                                              'Sun',
                                            ][day.weekday - 1]
                                          : local.narrowWeekdays[day.weekday %
                                                7],
                                      style: TextStyle(
                                        color: selected
                                            ? scheme.onPrimary
                                            : scheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: selected
                                            ? scheme.onPrimary
                                            : scheme.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.event_note_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.assignmentsOn(
                      selectedEntries.length,
                      local.formatMediumDate(_selected),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Swipe sideways for adjacent days. Tap +more to expand overlapping jobs.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            _columnWidth = math.max(
              320.0 * math.min(scale, 1.5),
              (constraints.maxWidth - _timeWidth) / 3,
            );
            final width = _timeWidth + _columnWidth * 3;
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Scrollbar(
                  controller: _boardScroll,
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    key: const ValueKey('calendar-horizontal-scroll'),
                    controller: _boardScroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: _timeWidth,
                                child: Center(
                                  child: Text(
                                    'TIME',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall,
                                  ),
                                ),
                              ),
                              for (final day in days)
                                SizedBox(
                                  width: _columnWidth,
                                  child: Material(
                                    color: DateUtils.isSameDay(day, _selected)
                                        ? scheme.primary
                                        : scheme.surfaceContainerLow,
                                    child: InkWell(
                                      key: ValueKey(
                                        'calendar-day-${day.year}-${day.month}-${day.day}',
                                      ),
                                      onTap: () => _expand(
                                        day,
                                        widget.assignments
                                            .where((a) => a.occursOn(day))
                                            .toList(),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          children: [
                                            Text(
                                              local.formatMediumDate(day),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    DateUtils.isSameDay(
                                                      day,
                                                      _selected,
                                                    )
                                                    ? scheme.onPrimary
                                                    : scheme.onSurface,
                                              ),
                                            ),
                                            Text(
                                              '${widget.assignments.where((a) => a.occursOn(day)).length} jobs',
                                              style: TextStyle(
                                                color:
                                                    DateUtils.isSameDay(
                                                      day,
                                                      _selected,
                                                    )
                                                    ? scheme.onPrimary
                                                    : scheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: boardHeight,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                for (var h = minHour; h <= maxHour; h++)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: (h - minHour) * _hourHeight,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: _timeWidth,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              '${h.toString().padLeft(2, '0')}:00',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            height: 1,
                                            color: scheme.outlineVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                for (var i = 0; i <= 3; i++)
                                  Positioned(
                                    left: _timeWidth + i * _columnWidth,
                                    top: 0,
                                    bottom: 0,
                                    child: VerticalDivider(
                                      width: 1,
                                      color: scheme.outlineVariant,
                                    ),
                                  ),
                                for (var i = 0; i < days.length; i++)
                                  for (final group in groups[i])
                                    ..._groupBlocks(
                                      context,
                                      group,
                                      days[i],
                                      i,
                                      minHour,
                                      minimumHeight,
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _groupBlocks(
    BuildContext context,
    CalendarCollisionGroup group,
    DateTime day,
    int dayIndex,
    int minHour,
    double minimumHeight,
  ) {
    final entries = group.entries;
    final visible = entries.take(2).toList();
    final hidden = entries.length - visible.length;
    final moreWidth = hidden > 0 ? 88.0 : 0.0;
    final laneWidth = (_columnWidth - 16 - moreWidth) / visible.length;
    final nextDay = DateTime(day.year, day.month, day.day + 1);
    final widgets = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      final a = visible[i];
      final start = a.start.isBefore(day) ? day : a.start;
      final end = a.effectiveEnd.isAfter(nextDay) ? nextDay : a.effectiveEnd;
      final top =
          (start.difference(day).inMinutes / 60 - minHour) * _hourHeight;
      final height = math.max(
        minimumHeight,
        end.difference(start).inMinutes / 60 * _hourHeight - 8,
      );
      widgets.add(
        Positioned(
          top: top + 4,
          left: _timeWidth + dayIndex * _columnWidth + 8 + i * laneWidth,
          width: laneWidth - 6,
          height: height,
          child: Semantics(
            label:
                '${a.reference}, ${_statusLabel(context, a)}, ${a.status}, ${a.title}, ${_time(context, a.start)}',
            button: true,
            child: Material(
              color: Color.alphaBlend(
                a.color.withValues(alpha: .14),
                Theme.of(context).colorScheme.surface,
              ),
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: ValueKey('schedule-assignment-${a.id}'),
                onTap: a.onOpen,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: a.color, width: 4)),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fontSize = MediaQuery.textScalerOf(
                        context,
                      ).scale(12);
                      final badgeHeight =
                          MediaQuery.textScalerOf(context).scale(11) * 1.2 + 4;
                      final lines = math.max(
                        0,
                        ((constraints.maxHeight - badgeHeight - 3) /
                                (fontSize * 1.25))
                            .floor(),
                      );
                      final content = [
                        a.reference,
                        '${_time(context, a.start)} - ${_time(context, a.effectiveEnd)}',
                        a.title,
                        ...a.details,
                      ];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: badgeHeight,
                            child: _CalendarStatusBadge(
                              key: ValueKey('calendar-job-status-${a.id}'),
                              label: _statusLabel(context, a),
                              color: a.color,
                            ),
                          ),
                          if (lines > 0) ...[
                            const SizedBox(height: 3),
                            Flexible(
                              child: Text(
                                content.take(lines).join('\n'),
                                maxLines: lines,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (hidden > 0) {
      final top =
          (group.start.difference(day).inMinutes / 60 - minHour) * _hourHeight +
          4;
      widgets.add(
        Positioned(
          top: top,
          left: _timeWidth + dayIndex * _columnWidth + _columnWidth - moreWidth,
          width: moreWidth - 8,
          height: minimumHeight,
          child: Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: ValueKey(
                'calendar-more-${day.toIso8601String()}-${group.entries.first.id}',
              ),
              onTap: () => _expand(day, entries),
              borderRadius: BorderRadius.circular(10),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '+$hidden\nmore',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _CalendarStatusBadge extends StatelessWidget {
  const _CalendarStatusBadge({
    super.key,
    required this.label,
    required this.color,
  });
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}
