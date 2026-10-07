import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_job_detail_screen.dart';

class OperatorScheduleScreen extends StatefulWidget {
  const OperatorScheduleScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  State<OperatorScheduleScreen> createState() => _OperatorScheduleScreenState();
}

class _OperatorScheduleScreenState extends State<OperatorScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = widget.repository.jobs.toList()
      ..sort((first, second) => first.scheduledAt.compareTo(second.scheduledAt));
    final selectedCount = jobs
        .where((job) => _sameDate(job.scheduledAt, _selectedDate))
        .length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  children: [
                    Text(
                      formatDate(_selectedDate),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      tooltip: 'Choose date',
                      onPressed: _pickDate,
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _OperatorWeekStrip(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) =>
                      setState(() => _selectedDate = date),
                ),
                const SizedBox(height: 12),
                OperatorCard(
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedCount == 0
                              ? 'No assignments on ${formatShortDate(_selectedDate)}.'
                              : '$selectedCount assignment${selectedCount == 1 ? '' : 's'} on ${formatShortDate(_selectedDate)}.',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _OperatorCalendarBoard(
                  selectedDate: _selectedDate,
                  jobs: jobs,
                  onOpen: (job) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OperatorJobDetailScreen(
                        repository: widget.repository,
                        jobId: job.id,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _OperatorWeekStrip extends StatelessWidget {
  const _OperatorWeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

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
                            : Colors.black54,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: _sameDate(day, selectedDate)
                            ? Colors.white
                            : Colors.black87,
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

class _OperatorCalendarBoard extends StatelessWidget {
  const _OperatorCalendarBoard({
    required this.selectedDate,
    required this.jobs,
    required this.onOpen,
  });

  static const double _timeColumnWidth = 54;
  static const double _rowHeight = 74;

  final DateTime selectedDate;
  final List<OperatorJob> jobs;
  final ValueChanged<OperatorJob> onOpen;

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

    return OperatorCard(
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
                                  : Colors.black54,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: _sameDate(day, selectedDate)
                                  ? Colors.white
                                  : Colors.black87,
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
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var i = 0; i < hours.length; i++)
                      Positioned(
                        top: i * _rowHeight,
                        left: 0,
                        right: 0,
                        height: _rowHeight,
                        child: _CalendarHourLine(hour: hours[i]),
                      ),
                    for (var i = 0; i <= days.length; i++)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: _timeColumnWidth + i * columnWidth,
                        child: Container(
                          width: 1,
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                    for (final job in visibleJobs)
                      _PositionedJobBlock(
                        job: job,
                        days: days,
                        minHour: minHour,
                        columnWidth: columnWidth,
                        onOpen: onOpen,
                      ),
                    _CurrentTimeLine(
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

  int _minHour(List<OperatorJob> visibleJobs) {
    if (visibleJobs.isEmpty) return 6;
    final earliest = visibleJobs
        .map((job) => job.scheduledAt.hour)
        .reduce((first, second) => first < second ? first : second);
    return earliest < 6 ? earliest : 6;
  }

  int _maxHour(List<OperatorJob> visibleJobs) {
    if (visibleJobs.isEmpty) return 19;
    final latest = visibleJobs.map((job) {
      final end = job.scheduledEndAt ?? job.scheduledAt.add(const Duration(hours: 1));
      return end.minute == 0 ? end.hour : end.hour + 1;
    }).reduce((first, second) => first > second ? first : second);
    return latest > 19 ? latest : 19;
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

class _CalendarHourLine extends StatelessWidget {
  const _CalendarHourLine({required this.hour});

  final int hour;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _OperatorCalendarBoard._timeColumnWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.50),
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
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }
}

class _PositionedJobBlock extends StatelessWidget {
  const _PositionedJobBlock({
    required this.job,
    required this.days,
    required this.minHour,
    required this.columnWidth,
    required this.onOpen,
  });

  final OperatorJob job;
  final List<DateTime> days;
  final int minHour;
  final double columnWidth;
  final ValueChanged<OperatorJob> onOpen;

  @override
  Widget build(BuildContext context) {
    final dayIndex = days.indexWhere((day) => _sameDate(day, job.scheduledAt));
    if (dayIndex == -1) return const SizedBox.shrink();

    final end = job.scheduledEndAt ?? job.scheduledAt.add(const Duration(hours: 1));
    final startMinutes =
        (job.scheduledAt.hour - minHour) * 60 + job.scheduledAt.minute;
    final durationMinutes = end.difference(job.scheduledAt).inMinutes;
    final top = startMinutes / 60 * _OperatorCalendarBoard._rowHeight;
    final height = (durationMinutes <= 0 ? 60 : durationMinutes) /
        60 *
        _OperatorCalendarBoard._rowHeight;
    final left =
        _OperatorCalendarBoard._timeColumnWidth + dayIndex * columnWidth + 4;
    final color = _statusColor(context, job.status);

    return Positioned(
      top: top + 4,
      left: left,
      width: columnWidth - 8,
      height: height.clamp(54, 280).toDouble(),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onOpen(job),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.black87,
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
                if (job.tractorLabel != null)
                  Text(
                    job.tractorLabel!,
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
      ),
    );
  }

  Color _statusColor(BuildContext context, OperatorJobStatus status) {
    return switch (status) {
      OperatorJobStatus.dispatched || OperatorJobStatus.assigned =>
        const Color(0xFFF59E0B),
      OperatorJobStatus.enRoute => const Color(0xFFF97316),
      OperatorJobStatus.arrived => const Color(0xFF0EA5E9),
      OperatorJobStatus.inProgress => Theme.of(context).colorScheme.primary,
      OperatorJobStatus.completedPendingConfirmation => const Color(0xFF16A34A),
      OperatorJobStatus.scheduled => const Color(0xFF8B5CF6),
    };
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _CurrentTimeLine extends StatelessWidget {
  const _CurrentTimeLine({
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
        _OperatorCalendarBoard._rowHeight;
    return Positioned(
      top: top,
      left: _OperatorCalendarBoard._timeColumnWidth,
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
            child: Container(
              height: 1.5,
              color: const Color(0xFFE11D48),
            ),
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
