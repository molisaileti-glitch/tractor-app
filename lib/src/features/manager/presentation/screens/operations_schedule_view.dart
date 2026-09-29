import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class OperationsScheduleView extends StatelessWidget {
  const OperationsScheduleView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'September',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Icon(Icons.keyboard_arrow_down),
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
        _WeekStrip(selectedDay: 28),
        const SizedBox(height: 12),
        OperationsCard(
          child: _ScheduleBoard(jobs: repository.jobs),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selectedDay});

  final int selectedDay;

  @override
  Widget build(BuildContext context) {
    const days = [
      ('Mon', 22),
      ('Tue', 23),
      ('Wed', 24),
      ('Thu', 25),
      ('Fri', 26),
      ('Sat', 27),
      ('Sun', 28),
    ];
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: day.$2 == selectedDay
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    day.$1,
                    style: TextStyle(
                      color: day.$2 == selectedDay
                          ? Colors.white
                          : Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.$2}',
                    style: TextStyle(
                      color: day.$2 == selectedDay
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
    );
  }
}

class _ScheduleBoard extends StatelessWidget {
  const _ScheduleBoard({required this.jobs});

  final List<OperationsJob> jobs;

  @override
  Widget build(BuildContext context) {
    final rows = [8, 9, 10, 11, 12, 13, 14];
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
