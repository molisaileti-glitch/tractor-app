import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class OperationsScheduleView extends StatefulWidget {
  const OperationsScheduleView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  State<OperationsScheduleView> createState() => _OperationsScheduleViewState();
}

class _OperationsScheduleViewState extends State<OperationsScheduleView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = widget.repository.jobs.toList()
      ..sort(
        (first, second) => first.scheduledAt.compareTo(second.scheduledAt),
      );
    final selectedCount = jobs
        .where((job) => _sameDate(job.scheduledAt, _selectedDate))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              formatDate(_selectedDate),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            IconButton(
              tooltip: 'Choose date',
              onPressed: _pickDate,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _WeekStrip(
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        const SizedBox(height: 12),
        OperationsCard(
          child: Row(
            children: [
              const Icon(Icons.event_note_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  selectedCount == 0
                      ? 'No jobs on ${formatShortDate(_selectedDate)}.'
                      : '$selectedCount job${selectedCount == 1 ? '' : 's'} on ${formatShortDate(_selectedDate)}.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Refresh schedule',
                onPressed: widget.repository.refreshMechanizationData,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _OperationsCalendarBoard(selectedDate: _selectedDate, jobs: jobs),
      ],
    );
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selectedDate, required this.onDateSelected});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - DateTime.monday),
    );
    final days = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onDateSelected(day),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _sameDate(day, selectedDate)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      _weekday(day.weekday),
                      style: TextStyle(
                        color: _sameDate(day, selectedDate)
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: _sameDate(day, selectedDate)
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _weekday(int weekday) {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }
}

class _OperationsCalendarBoard extends StatelessWidget {
  const _OperationsCalendarBoard({
    required this.selectedDate,
    required this.jobs,
  });

  static const double _timeColumnWidth = 54;
  static const double _rowHeight = 74;

  final DateTime selectedDate;
  final List<OperationsJob> jobs;

  @override
  Widget build(BuildContext context) {
    final days = [
      selectedDate.subtract(const Duration(days: 1)),
      selectedDate,
      selectedDate.add(const Duration(days: 1)),
    ];
    final visibleJobs = jobs
        .where((job) => days.any((day) => _sameDate(job.scheduledAt, day)))
        .toList();
    final minHour = _minHour(visibleJobs);
    final maxHour = _maxHour(visibleJobs);
    final hours = List.generate(maxHour - minHour, (index) => minHour + index);
    final boardHeight = hours.length * _rowHeight;

    return OperationsCard(
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: _timeColumnWidth),
              for (final day in days)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _sameDate(day, selectedDate)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _weekday(day.weekday).toUpperCase(),
                          style: TextStyle(
                            color: _sameDate(day, selectedDate)
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: _sameDate(day, selectedDate)
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: boardHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columnWidth =
                    (constraints.maxWidth - _timeColumnWidth) / days.length;
                final placements = _placeOverlappingJobs(visibleJobs);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < hours.length; i++)
                      Positioned(
                        top: i * _rowHeight,
                        left: 0,
                        right: 0,
                        height: _rowHeight,
                        child: _OperationsCalendarHourLine(hour: hours[i]),
                      ),
                    for (var i = 0; i <= days.length; i++)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: _timeColumnWidth + i * columnWidth,
                        child: Container(
                          width: 1,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    for (final placement in placements)
                      _PositionedOperationsJobBlock(
                        job: placement.job,
                        days: days,
                        minHour: minHour,
                        columnWidth: columnWidth,
                        lane: placement.lane,
                        laneCount: placement.laneCount,
                      ),
                    _OperationsCurrentTimeLine(
                      days: days,
                      minHour: minHour,
                      maxHour: maxHour,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _minHour(List<OperationsJob> visibleJobs) {
    if (visibleJobs.isEmpty) return 6;
    final earliest = visibleJobs
        .map((job) => job.scheduledAt.hour)
        .reduce((first, second) => first < second ? first : second);
    return earliest < 6 ? earliest : 6;
  }

  int _maxHour(List<OperationsJob> visibleJobs) {
    if (visibleJobs.isEmpty) return 19;
    final latest = visibleJobs
        .map((job) {
          final end = job.scheduledAt.add(Duration(hours: job.estimatedHours));
          return end.minute == 0 ? end.hour : end.hour + 1;
        })
        .reduce((first, second) => first > second ? first : second);
    return latest > 19 ? latest : 19;
  }

  List<_CalendarJobPlacement> _placeOverlappingJobs(List<OperationsJob> jobs) {
    final placements = <_CalendarJobPlacement>[];
    final jobsByDay = <DateTime, List<OperationsJob>>{};
    for (final job in jobs) {
      final day = DateTime(
        job.scheduledAt.year,
        job.scheduledAt.month,
        job.scheduledAt.day,
      );
      jobsByDay.putIfAbsent(day, () => []).add(job);
    }

    for (final dayJobs in jobsByDay.values) {
      dayJobs.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      var index = 0;
      while (index < dayJobs.length) {
        final group = <OperationsJob>[dayJobs[index]];
        var groupEnd = _jobEnd(dayJobs[index]);
        var cursor = index + 1;
        while (cursor < dayJobs.length &&
            dayJobs[cursor].scheduledAt.isBefore(groupEnd)) {
          final job = dayJobs[cursor];
          group.add(job);
          final end = _jobEnd(job);
          if (end.isAfter(groupEnd)) groupEnd = end;
          cursor++;
        }

        final laneEnds = <DateTime>[];
        final assignedLanes = <OperationsJob, int>{};
        for (final job in group) {
          var lane = laneEnds.indexWhere(
            (end) => !end.isAfter(job.scheduledAt),
          );
          if (lane == -1) {
            lane = laneEnds.length;
            laneEnds.add(_jobEnd(job));
          } else {
            laneEnds[lane] = _jobEnd(job);
          }
          assignedLanes[job] = lane;
        }

        final laneCount = laneEnds.length;
        for (final job in group) {
          placements.add(
            _CalendarJobPlacement(
              job: job,
              lane: assignedLanes[job]!,
              laneCount: laneCount,
            ),
          );
        }
        index = cursor;
      }
    }
    return placements;
  }

  DateTime _jobEnd(OperationsJob job) =>
      job.scheduledAt.add(Duration(hours: job.estimatedHours.clamp(1, 24)));

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _weekday(int weekday) {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }
}

class _OperationsCalendarHourLine extends StatelessWidget {
  const _OperationsCalendarHourLine({required this.hour});

  final int hour;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _OperationsCalendarBoard._timeColumnWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }
}

class _PositionedOperationsJobBlock extends StatelessWidget {
  const _PositionedOperationsJobBlock({
    required this.job,
    required this.days,
    required this.minHour,
    required this.columnWidth,
    required this.lane,
    required this.laneCount,
  });

  final OperationsJob job;
  final List<DateTime> days;
  final int minHour;
  final double columnWidth;
  final int lane;
  final int laneCount;

  @override
  Widget build(BuildContext context) {
    final dayIndex = days.indexWhere((day) => _sameDate(day, job.scheduledAt));
    if (dayIndex == -1) return const SizedBox.shrink();
    final end = job.scheduledAt.add(Duration(hours: job.estimatedHours));
    final startMinutes =
        (job.scheduledAt.hour - minHour) * 60 + job.scheduledAt.minute;
    final durationMinutes = end.difference(job.scheduledAt).inMinutes;
    final top = startMinutes / 60 * _OperationsCalendarBoard._rowHeight;
    final height =
        (durationMinutes <= 0 ? 60 : durationMinutes) /
        60 *
        _OperationsCalendarBoard._rowHeight;
    const horizontalGap = 3.0;
    final availableWidth = columnWidth - 8;
    final laneWidth =
        (availableWidth - horizontalGap * (laneCount - 1)) / laneCount;
    final left =
        _OperationsCalendarBoard._timeColumnWidth +
        dayIndex * columnWidth +
        4 +
        lane * (laneWidth + horizontalGap);
    final color = _statusColor(context, job.status);

    return Positioned(
      top: top + 4,
      left: left,
      width: laneWidth,
      height: height.clamp(54, 280).toDouble(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            height: 1.18,
            fontWeight: FontWeight.w800,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatTime(job.scheduledAt)}-${formatTime(end)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${job.serviceType.label} - ${job.farmerName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${job.tractor.assetNo ?? job.tractor.label ?? job.tractor.model} - ${job.operator.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${job.plot.name} - ${job.serviceType.label}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                job.status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, JobStatus status) {
    return switch (status) {
      JobStatus.scheduled || JobStatus.dispatched => const Color(0xFFF59E0B),
      JobStatus.enRoute => const Color(0xFFF97316),
      JobStatus.arrived => const Color(0xFF0EA5E9),
      JobStatus.inProgress => Theme.of(context).colorScheme.primary,
      JobStatus.completedPendingConfirmation => const Color(0xFF16A34A),
      JobStatus.flagged => Theme.of(context).colorScheme.error,
      JobStatus.closed => const Color(0xFF475569),
      JobStatus.cancelled => const Color(0xFF94A3B8),
    };
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _CalendarJobPlacement {
  const _CalendarJobPlacement({
    required this.job,
    required this.lane,
    required this.laneCount,
  });

  final OperationsJob job;
  final int lane;
  final int laneCount;
}

class _OperationsCurrentTimeLine extends StatelessWidget {
  const _OperationsCurrentTimeLine({
    required this.days,
    required this.minHour,
    required this.maxHour,
  });

  final List<DateTime> days;
  final int minHour;
  final int maxHour;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final visibleToday = days.any((day) => _sameDate(day, now));
    if (!visibleToday || now.hour < minHour || now.hour >= maxHour) {
      return const SizedBox.shrink();
    }
    final top =
        ((now.hour - minHour) * 60 + now.minute) /
        60 *
        _OperationsCalendarBoard._rowHeight;
    return Positioned(
      top: top,
      left: _OperationsCalendarBoard._timeColumnWidth,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFE11D48),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1.5, color: const Color(0xFFE11D48)),
          ),
        ],
      ),
    );
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
