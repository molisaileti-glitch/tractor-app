import 'package:flutter/material.dart';

import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

class ScheduleServiceScreen extends StatefulWidget {
  const ScheduleServiceScreen({
    super.key,
    required this.repository,
    required this.requestId,
  });

  final UnionOperationsRepository repository;
  final String requestId;

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  String? _tractorId;
  String? _operatorId;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  int _duration = 4;
  bool _checkingAvailability = false;
  bool _submitting = false;
  RequestAvailabilityResult? _availability;

  @override
  void initState() {
    super.initState();
    _tractorId = widget.repository.tractors
        .where((tractor) => tractor.status.canSchedule)
        .firstOrNull
        ?.id;
    _operatorId = widget.repository.operators
        .where((operator) => operator.status.canSchedule)
        .firstOrNull
        ?.id;
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.repository.requestById(widget.requestId);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OperationsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.serviceType.label} for ${request.farmerName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${request.serviceType.label} - ${request.plot.name} - ${request.plot.areaHectares.toStringAsFixed(1)} ha',
                      ),
                    ],
                  ),
                ),
                const OperationsSectionTitle('1. SELECT TRACTOR'),
                for (final tractor in widget.repository.tractors) ...[
                  _TractorOption(
                    tractor: tractor,
                    selected: _tractorId == tractor.id,
                    onTap: tractor.status.canSchedule
                        ? () => setState(() {
                            _tractorId = tractor.id;
                            _availability = null;
                          })
                        : null,
                  ),
                  const SizedBox(height: 10),
                ],
                const OperationsSectionTitle('2. SELECT OPERATOR'),
                for (final operator in widget.repository.operators) ...[
                  _OperatorOption(
                    operator: operator,
                    selected: _operatorId == operator.id,
                    onTap: operator.status.canSchedule
                        ? () => setState(() {
                            _operatorId = operator.id;
                            _availability = null;
                          })
                        : null,
                  ),
                  const SizedBox(height: 10),
                ],
                const OperationsSectionTitle('3. SCHEDULE'),
                OperationsCard(
                  child: Column(
                    children: [
                      _ScheduleTile(
                        label: 'Date',
                        value: formatDate(_date),
                        icon: Icons.calendar_month_outlined,
                        onTap: _pickDate,
                      ),
                      const Divider(height: 24),
                      _ScheduleTile(
                        label: 'Time',
                        value: _time.format(context),
                        icon: Icons.schedule,
                        onTap: _pickTime,
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Expanded(child: Text('Estimated duration')),
                          DropdownButton<int>(
                            value: _duration,
                            items: [2, 3, 4, 5, 6]
                                .map(
                                  (hours) => DropdownMenuItem(
                                    value: hours,
                                    child: Text('$hours hours'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _duration = value ?? _duration),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _tractorId == null ||
                          _operatorId == null ||
                          _checkingAvailability
                      ? null
                      : _checkAvailability,
                  icon: _checkingAvailability
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.event_available_outlined),
                  label: Text(
                    _checkingAvailability
                        ? 'Checking availability...'
                        : 'Check Availability',
                  ),
                ),
                if (_availability != null) ...[
                  const SizedBox(height: 10),
                  OperationsCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _availability!.isAvailable
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          color: _availability!.isAvailable
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _availability!.summary,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _tractorId == null ||
                          _operatorId == null ||
                          _submitting
                      ? null
                      : _confirmSchedule,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(_submitting ? 'Scheduling...' : 'Confirm Schedule'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027, 12, 31),
    );
    if (selected == null) return;
    setState(() {
      _date = selected;
      _availability = null;
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected == null) return;
    setState(() {
      _time = selected;
      _availability = null;
    });
  }

  Future<RequestAvailabilityResult?> _checkAvailability() async {
    if (_tractorId == null || _operatorId == null) return null;
    setState(() => _checkingAvailability = true);
    final result = await widget.repository.checkRequestAvailability(
      date: _date,
      tractorId: _tractorId!,
      operatorId: _operatorId!,
    );
    if (!mounted) return result;
    setState(() {
      _availability = result;
      _checkingAvailability = false;
    });
    if (result == null && widget.repository.mechanizationActionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.repository.mechanizationActionError!)),
      );
    }
    return result;
  }

  Future<void> _confirmSchedule() async {
    final availability = _availability ?? await _checkAvailability();
    if (!mounted) return;
    if (availability != null && !availability.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(availability.summary)),
      );
      return;
    }
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    setState(() => _submitting = true);
    final jobId = await widget.repository.scheduleRequest(
      requestId: widget.requestId,
      tractorId: _tractorId!,
      operatorId: _operatorId!,
      scheduledAt: scheduledAt,
      estimatedHours: _duration,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (widget.repository.mechanizationActionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.repository.mechanizationActionError!)),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Service Scheduled'),
        content: Text('Job $jobId is ready for dispatch on service day.'),
        actions: [
          FilledButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _TractorOption extends StatelessWidget {
  const _TractorOption({
    required this.tractor,
    required this.selected,
    required this.onTap,
  });

  final TractorAsset tractor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.58 : 1,
      child: OperationsCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black45,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tractor.assetNo ?? tractor.label ?? tractor.model,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(tractor.model),
                  if (tractor.note != null) Text(tractor.note!),
                ],
              ),
            ),
            OperationsStatusChip.tractor(tractorStatus: tractor.status),
          ],
        ),
      ),
    );
  }
}

class _OperatorOption extends StatelessWidget {
  const _OperatorOption({
    required this.operator,
    required this.selected,
    required this.onTap,
  });

  final OperatorProfile operator;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.58 : 1,
      child: OperationsCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black45,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operator.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (operator.note != null) Text(operator.note!),
                ],
              ),
            ),
            OperationsStatusChip.operator(operatorStatus: operator.status),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
