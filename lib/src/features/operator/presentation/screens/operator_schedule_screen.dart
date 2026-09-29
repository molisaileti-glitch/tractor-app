import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';
import 'operator_job_detail_screen.dart';

class OperatorScheduleScreen extends StatelessWidget {
  const OperatorScheduleScreen({super.key, required this.repository});

  final OperatorLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'September',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
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
                const _OperatorWeekStrip(),
                const SizedBox(height: 12),
                OperatorCard(
                  child: Column(
                    children: [
                      for (final hour in [8, 9, 10, 11, 12, 13, 14])
                        _ScheduleHour(
                          hour: hour,
                          jobs: repository.jobs
                              .where((job) => job.scheduledAt.hour == hour)
                              .toList(),
                          onOpen: (job) => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OperatorJobDetailScreen(
                                repository: repository,
                                jobId: job.id,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OperatorWeekStrip extends StatelessWidget {
  const _OperatorWeekStrip();

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
                color: day.$2 == 28
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    day.$1,
                    style: TextStyle(
                      color: day.$2 == 28 ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${day.$2}',
                    style: TextStyle(
                      color: day.$2 == 28 ? Colors.white : Colors.black87,
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

class _ScheduleHour extends StatelessWidget {
  const _ScheduleHour({
    required this.hour,
    required this.jobs,
    required this.onOpen,
  });

  final int hour;
  final List<OperatorJob> jobs;
  final ValueChanged<OperatorJob> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(color: Colors.black.withValues(alpha: 0.50)),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  top: 8,
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
                for (final job in jobs)
                  Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      onTap: () => onOpen(job),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Text(
                          '${formatTime(job.scheduledAt)}\n${job.plot.name} · ${job.serviceType.label}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
