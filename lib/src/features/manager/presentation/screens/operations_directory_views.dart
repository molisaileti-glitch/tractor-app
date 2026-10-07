import 'package:flutter/material.dart';

import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class TractorsView extends StatelessWidget {
  const TractorsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final tractors = repository.tractors;
    return _DirectoryPage(
      title: 'Tractors',
      children: [
        if (tractors.isEmpty)
          const OperationsCard(child: Text('No tractors loaded yet.'))
        else
          _PrettyGrid(
            children: [
              for (final tractor in tractors)
                _TractorDirectoryCard(tractor: tractor),
            ],
          ),
      ],
    );
  }
}

class _TractorDirectoryCard extends StatelessWidget {
  const _TractorDirectoryCard({required this.tractor});

  final TractorAsset tractor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = tractor.assetNo ?? tractor.label ?? tractor.model;
    final model = [tractor.make, tractor.model]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .join(' ');

    return OperationsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.10,
                  ),
                  child: Icon(
                    Icons.agriculture_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (model.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(model, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                OperationsStatusChip.tractor(tractorStatus: tractor.status),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              color: theme.dividerColor.withValues(alpha: 0.55),
              height: 1,
            ),
            const SizedBox(height: 14),
            _DirectoryFact(
              icon: Icons.speed_outlined,
              text: '${tractor.operatingHours} operating hours',
            ),
            if (tractor.registrationNo?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 9),
              _DirectoryFact(
                icon: Icons.pin_outlined,
                text: tractor.registrationNo!,
              ),
            ],
            if (tractor.station?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 9),
              _DirectoryFact(
                icon: Icons.location_on_outlined,
                text: tractor.station!,
              ),
            ],
            if (tractor.implementNames.isNotEmpty) ...[
              const SizedBox(height: 9),
              _DirectoryFact(
                icon: Icons.handyman_outlined,
                text: tractor.implementNames.join(', '),
              ),
            ],
            if (tractor.online != null) ...[
              const SizedBox(height: 9),
              _DirectoryFact(
                icon: tractor.online!
                    ? Icons.sensors_outlined
                    : Icons.sensors_off_outlined,
                text: tractor.online! ? 'Tracker online' : 'Tracker offline',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OperatorsView extends StatelessWidget {
  const OperatorsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final operators = repository.operators;
    return _DirectoryPage(
      title: 'Operators',
      children: [
        if (operators.isEmpty)
          const OperationsCard(child: Text('No operators loaded yet.'))
        else
          _PrettyGrid(
            children: [
              for (final operator in operators)
                _OperatorDirectoryCard(
                  operator: operator,
                  jobs: repository.jobs
                      .where((job) => job.operator.id == operator.id)
                      .toList(),
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
    final farmers = <String, List<OperationsServiceRequest>>{};
    for (final request in repository.requests) {
      farmers.putIfAbsent(request.farmerName, () => []).add(request);
    }

    return _DirectoryPage(
      title: 'Farmers',
      children: [
        if (farmers.isEmpty)
          const OperationsCard(child: Text('No farmers loaded yet.'))
        else
          _PrettyGrid(
            children: [
              for (final entry in farmers.entries)
                _FarmerDirectoryCard(
                  name: entry.key,
                  requests: entry.value,
                ),
            ],
          ),
      ],
    );
  }
}

class _OperatorDirectoryCard extends StatelessWidget {
  const _OperatorDirectoryCard({required this.operator, required this.jobs});

  final OperatorProfile operator;
  final List<OperationsJob> jobs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeJobs = jobs.where((job) =>
        job.status != JobStatus.closed && job.status != JobStatus.cancelled).toList();
    final currentJob = activeJobs.isEmpty ? null : activeJobs.first;
    return OperationsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
                  child: Icon(Icons.engineering_outlined, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(operator.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (operator.note?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(operator.note!, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                OperationsStatusChip.operator(operatorStatus: operator.status),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.55), height: 1),
            const SizedBox(height: 14),
            _DirectoryFact(
              icon: Icons.assignment_outlined,
              text: '${activeJobs.length} active assignment${activeJobs.length == 1 ? '' : 's'}',
            ),
            if (currentJob != null) ...[
              const SizedBox(height: 9),
              _DirectoryFact(
                icon: Icons.agriculture_outlined,
                text: currentJob.tractor.assetNo ?? currentJob.tractor.label ?? currentJob.tractor.model,
              ),
              const SizedBox(height: 9),
              _DirectoryFact(
                icon: Icons.location_on_outlined,
                text: '${currentJob.plot.name} - ${currentJob.serviceType.label}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FarmerDirectoryCard extends StatelessWidget {
  const _FarmerDirectoryCard({required this.name, required this.requests});

  final String name;
  final List<OperationsServiceRequest> requests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latest = requests.first;
    final phone = requests.map((item) => item.farmerPhone).whereType<String>().firstOrNull;
    final plots = requests.map((item) => item.plot.name).toSet();
    final location = requests
        .map((item) => item.plot.location.trim())
        .where((item) => item.isNotEmpty)
        .firstOrNull;
    return OperationsCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
                  child: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (phone != null) ...[
                        const SizedBox(height: 4),
                        Text(phone, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                OperationsStatusChip.request(requestStatus: latest.status),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor.withValues(alpha: 0.55), height: 1),
            const SizedBox(height: 14),
            _DirectoryFact(icon: Icons.landscape_outlined, text: '${plots.length} registered plot${plots.length == 1 ? '' : 's'}'),
            const SizedBox(height: 9),
            _DirectoryFact(icon: Icons.fact_check_outlined, text: '${requests.length} service request${requests.length == 1 ? '' : 's'}'),
            const SizedBox(height: 9),
            _DirectoryFact(icon: Icons.location_on_outlined, text: location ?? latest.plot.name),
          ],
        ),
      ),
    );
  }
}

class _DirectoryFact extends StatelessWidget {
  const _DirectoryFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 9),
        Expanded(child: Text(text)),
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
        if (blocked.isEmpty)
          const OperationsCard(child: Text('No blocked tractors loaded yet.'))
        else
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
                _ReportRow(
                  'Returned',
                  '${_requestCount(OperationsRequestStatus.returned)}',
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
                  value: 'Not recorded',
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
