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
    final selectedJobs = widget.repository.jobs
        .where((job) => _sameDate(job.scheduledAt, _selectedDate))
        .toList();
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
            const Spacer(),
            IconButton(
              tooltip: 'Filter',
              onPressed: () {},
              icon: const Icon(Icons.tune),
            ),
            IconButton(
              tooltip: 'Search',
              onPressed: () {},
              icon: const Icon(Icons.search),
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
          child: _ScheduleBoard(jobs: selectedJobs),
        ),
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
  const _WeekStrip({
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
                    const SizedBox(height: 2),
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

class _ScheduleBoard extends StatelessWidget {
  const _ScheduleBoard({required this.jobs});

  final List<OperationsJob> jobs;

  @override
  Widget build(BuildContext context) {
    final rows = List.generate(14, (index) => index + 6);
    return Column(
      children: [
        for (final hour in rows)
          SizedBox(
            height: 74,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.50),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        top: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.black.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (final job in jobs.where(
                        (item) => item.scheduledAt.hour == hour,
                      ))
                        _JobBlock(job: job),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _JobBlock extends StatelessWidget {
  const _JobBlock({required this.job});

  final OperationsJob job;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: FractionallySizedBox(
        widthFactor: 0.72,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          child: Text(
            '${formatTime(job.scheduledAt)}\n${job.farmerName}\n${job.serviceType.label}',
            style: const TextStyle(fontWeight: FontWeight.w800, height: 1.2),
          ),
        ),
      ),
    );
  }
}
