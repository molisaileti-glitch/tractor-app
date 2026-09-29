import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class TractorsView extends StatelessWidget {
  const TractorsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return _DirectoryPage(
      title: 'Tractors',
      children: [
        _PrettyGrid(
          children: [
            for (final tractor in repository.tractors)
              OperationsCard(
                child: Row(
                  children: [
                    const Icon(Icons.agriculture),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tractor.id,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(tractor.model),
                          Text('${tractor.operatingHours} operating hours'),
                          if (tractor.note != null) Text(tractor.note!),
                        ],
                      ),
                    ),
                    OperationsStatusChip.tractor(tractorStatus: tractor.status),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class OperatorsView extends StatelessWidget {
  const OperatorsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return _DirectoryPage(
      title: 'Operators',
      children: [
        _PrettyGrid(
          children: [
            for (final operator in repository.operators)
              OperationsCard(
                child: Row(
                  children: [
                    const Icon(Icons.engineering_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            operator.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(operator.note ?? 'Ready for dispatch'),
                        ],
                      ),
                    ),
                    OperationsStatusChip.operator(
                      operatorStatus: operator.status,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class FarmersView extends StatelessWidget {
  const FarmersView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final farmers = repository.requests
        .map((request) => '${request.farmerName}|${request.plot.location}')
        .toSet()
        .map((item) => item.split('|'))
        .toList();

    return _DirectoryPage(
      title: 'Farmers',
      children: [
        _PrettyGrid(
          children: [
            for (final farmer in farmers)
              OperationsCard(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer[0],
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(farmer[1]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final blocked = repository.tractors
        .where((tractor) => !tractor.status.canSchedule)
        .toList();

    return _DirectoryPage(
      title: 'Maintenance',
      children: [
        _MaintenanceSummary(repository: repository),
        const SizedBox(height: 16),
        _PrettyGrid(
          children: [
            for (final tractor in blocked)
              _MaintenanceCard(
                tractorId: tractor.id,
                model: tractor.model,
                note: tractor.note ?? tractor.status.label,
                status: tractor.status,
                hours: tractor.operatingHours,
              ),
          ],
        ),
      ],
    );
  }
}

class ReportsView extends StatelessWidget {
  const ReportsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return _DirectoryPage(
      title: 'Reports',
      children: [
        _PrettyGrid(
          children: [
            MetricCard(
              value: '${repository.requests.length}',
              label: 'Total Requests',
              icon: Icons.fact_check_outlined,
            ),
            MetricCard(
              value: '${repository.jobs.length}',
              label: 'Total Jobs',
              icon: Icons.route_outlined,
            ),
            MetricCard(
              value: '${repository.tractors.length}',
              label: 'Fleet Assets',
              icon: Icons.agriculture_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ResponsivePanelRow(
          children: [
            _ReportPanel(
              title: 'Request Pipeline',
              icon: Icons.stacked_line_chart,
              rows: [
                _ReportRow(
                  'Pending review',
                  '${repository.pendingRequestCount}',
                ),
                _ReportRow(
                  'Approved',
                  '${_requestCount(OperationsRequestStatus.approved)}',
                ),
                _ReportRow(
                  'Rejected',
                  '${_requestCount(OperationsRequestStatus.rejected)}',
                ),
              ],
            ),
            _ReportPanel(
              title: 'Field Performance',
              icon: Icons.insights_outlined,
              rows: [
                _ReportRow('Active jobs', '${repository.activeJobs.length}'),
                _ReportRow('Closed jobs', '${_jobCount(JobStatus.closed)}'),
                _ReportRow(
                  'Awaiting verification',
                  '${_jobCount(JobStatus.completedPendingConfirmation)}',
                ),
              ],
            ),
            _ReportPanel(
              title: 'Fleet Readiness',
              icon: Icons.speed_outlined,
              rows: [
                _ReportRow(
                  'Available tractors',
                  '${_tractorCount(TractorStatus.available)}',
                ),
                _ReportRow(
                  'Blocked tractors',
                  '${repository.maintenanceCount}',
                ),
                _ReportRow(
                  'Available operators',
                  '${_operatorCount(OperatorStatus.available)}',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        OperationsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.14),
                    child: const Icon(Icons.map_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Service Coverage',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _CoverageBar(label: 'Kibaha', value: 0.82),
              const _CoverageBar(label: 'Mlandizi', value: 0.64),
              const _CoverageBar(label: 'Bagamoyo', value: 0.48),
              const _CoverageBar(label: 'Kisarawe', value: 0.36),
            ],
          ),
        ),
      ],
    );
  }

  int _requestCount(OperationsRequestStatus status) {
    return repository.requests
        .where((request) => request.status == status)
        .length;
  }

  int _jobCount(JobStatus status) {
    return repository.jobs.where((job) => job.status == status).length;
  }

  int _tractorCount(TractorStatus status) {
    return repository.tractors
        .where((tractor) => tractor.status == status)
        .length;
  }

  int _operatorCount(OperatorStatus status) {
    return repository.operators
        .where((operator) => operator.status == status)
        .length;
  }
}

class _MaintenanceSummary extends StatelessWidget {
  const _MaintenanceSummary({required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final available = repository.tractors
        .where((tractor) => tractor.status == TractorStatus.available)
        .length;
    final blocked = repository.tractors
        .where((tractor) => !tractor.status.canSchedule)
        .length;

    return _PrettyGrid(
      children: [
        MetricCard(
          value: '$available',
          label: 'Ready to dispatch',
          icon: Icons.check_circle_outline,
        ),
        MetricCard(
          value: '${repository.maintenanceCount}',
          label: 'Under maintenance',
          icon: Icons.build_outlined,
        ),
        MetricCard(
          value: '$blocked',
          label: 'Blocked resources',
          icon: Icons.block,
        ),
      ],
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({
    required this.tractorId,
    required this.model,
    required this.note,
    required this.status,
    required this.hours,
  });

  final String tractorId;
  final String model;
  final String note;
  final TractorStatus status;
  final int hours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.14,
                ),
                child: const Icon(Icons.agriculture),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tractorId,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(model),
                  ],
                ),
              ),
              OperationsStatusChip.tractor(tractorStatus: status),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.report_problem_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallStat(
                  label: 'Hours',
                  value: '$hours',
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallStat(
                  label: 'Last service',
                  value: formatShortDate(DateTime(2026, 8, 10)),
                  icon: Icons.history,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_note_outlined),
            label: const Text('Log Maintenance'),
          ),
        ],
      ),
    );
  }
}

class _ReportPanel extends StatelessWidget {
  const _ReportPanel({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_ReportRow> rows;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final row in rows) ...[
            Row(
              children: [
                Expanded(child: Text(row.label)),
                Text(
                  row.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            if (row != rows.last) const Divider(height: 22),
          ],
        ],
      ),
    );
  }
}

class _ReportRow {
  const _ReportRow(this.label, this.value);

  final String label;
  final String value;
}

class _CoverageBar extends StatelessWidget {
  const _CoverageBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 86, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 42,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsivePanelRow extends StatelessWidget {
  const _ResponsivePanelRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 820) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final child in children) ...[
              Expanded(child: child),
              if (child != children.last) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _PrettyGrid extends StatelessWidget {
  const _PrettyGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 960
            ? 3
            : constraints.maxWidth >= 640
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _DirectoryPage extends StatelessWidget {
  const _DirectoryPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}
