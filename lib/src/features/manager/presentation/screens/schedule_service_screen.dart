import 'package:flutter/material.dart';

import '../../../../components/components.dart';
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
  int _currentStep = 0;
  String? _tractorId;
  String? _operatorId;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  int _duration = 4;
  bool _checkingAvailability = false;
  bool _submitting = false;
  RequestAvailabilityResult? _availability;

  @override
  Widget build(BuildContext context) {
    final request = widget.repository.requestById(widget.requestId);
    final availableTractors = widget.repository.tractors
        .where((tractor) => tractor.status.canSchedule)
        .toList();
    final availableOperators = widget.repository.operators
        .where((operator) => operator.status.canSchedule)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OperationsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.agriculture_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${request.serviceType.label} service',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Review the request before assigning resources',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 14),
                      _RequestSummaryRow(
                        icon: Icons.person_outline,
                        label: 'Farmer',
                        value: request.farmerName,
                      ),
                      const SizedBox(height: 12),
                      _RequestSummaryRow(
                        icon: Icons.landscape_outlined,
                        label: 'Plot',
                        value: request.plot.name,
                      ),
                      const SizedBox(height: 12),
                      _RequestSummaryRow(
                        icon: Icons.straighten_outlined,
                        label: 'Plot area',
                        value:
                            '${request.plot.areaHectares.toStringAsFixed(1)} ha',
                      ),
                      const SizedBox(height: 12),
                      _RequestSummaryRow(
                        icon: Icons.event_outlined,
                        label: 'Preferred date',
                        value: formatDate(request.preferredDate),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppHorizontalStepper(
                  currentStep: _currentStep,
                  canContinue: _currentStep == 0
                      ? _tractorId != null
                      : _operatorId != null,
                  onStepTapped: (step) {
                    final canOpen =
                        step == 0 ||
                        (step == 1 && _tractorId != null) ||
                        (step == 2 &&
                            _tractorId != null &&
                            _operatorId != null);
                    if (canOpen) setState(() => _currentStep = step);
                  },
                  onStepContinue: () {
                    if (_currentStep == 0 && _tractorId != null) {
                      setState(() => _currentStep = 1);
                    } else if (_currentStep == 1 && _operatorId != null) {
                      setState(() => _currentStep = 2);
                    }
                  },
                  onStepBack: _currentStep == 0
                      ? null
                      : () => setState(() => _currentStep--),
                  steps: [
                    Step(
                      title: const Text('Select tractor'),
                      subtitle: Text(
                        _tractorId == null
                            ? 'Choose an available tractor'
                            : 'Tractor selected',
                      ),
                      isActive: _currentStep >= 0,
                      state: _tractorId == null
                          ? StepState.indexed
                          : StepState.complete,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (availableTractors.isEmpty)
                            const AppEmptyState(
                              icon: Icons.agriculture_outlined,
                              title: 'No tractors available',
                              message:
                                  'Available tractors will appear here when they are ready for scheduling.',
                            ),
                          for (final tractor in availableTractors) ...[
                            _SelectableResourceCard(
                              selected: _tractorId == tractor.id,
                              title:
                                  tractor.assetNo ??
                                  tractor.label ??
                                  tractor.model,
                              subtitle: tractor.model,
                              supportingText: tractor.note,
                              trailing: OperationsStatusChip.tractor(
                                tractorStatus: tractor.status,
                              ),
                              onTap: () => setState(() {
                                _tractorId = _tractorId == tractor.id
                                    ? null
                                    : tractor.id;
                                _availability = null;
                              }),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Select operator'),
                      subtitle: Text(
                        _operatorId == null
                            ? 'Choose an available operator'
                            : 'Operator selected',
                      ),
                      isActive: _currentStep >= 1,
                      state: _operatorId == null
                          ? StepState.indexed
                          : StepState.complete,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (availableOperators.isEmpty)
                            const AppEmptyState(
                              icon: Icons.engineering_outlined,
                              title: 'No operators available',
                              message:
                                  'Registered operators will appear here when they are available for scheduling.',
                            ),
                          for (final operator in availableOperators) ...[
                            _SelectableResourceCard(
                              selected: _operatorId == operator.id,
                              title: operator.name,
                              supportingText: operator.note,
                              trailing: OperationsStatusChip.operator(
                                operatorStatus: operator.status,
                              ),
                              onTap: () => setState(() {
                                _operatorId = _operatorId == operator.id
                                    ? null
                                    : operator.id;
                                _availability = null;
                              }),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    Step(
                      title: const Text('Schedule'),
                      subtitle: const Text('Choose the service date and time'),
                      isActive: _currentStep >= 2,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                    const Expanded(
                                      child: Text('Estimated duration'),
                                    ),
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
                                      onChanged: (value) => setState(() {
                                        _duration = value ?? _duration;
                                        _availability = null;
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: _checkingAvailability
                                ? null
                                : _checkAvailability,
                            icon: _checkingAvailability
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                                    child: Text(_availability!.summary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _submitting ? null : _confirmSchedule,
                            icon: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              _submitting
                                  ? 'Scheduling...'
                                  : 'Confirm Schedule',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    if (availability == null) return;
    if (!availability.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(availability.summary)));
      return;
    }
    final scheduledAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Schedule service?',
      message:
          'This will assign the selected tractor and operator on ${formatDate(scheduledAt)} at ${formatTime(scheduledAt)}.',
      confirmLabel: 'Schedule',
    );
    if (!confirmed || !mounted) return;
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

class _RequestSummaryRow extends StatelessWidget {
  const _RequestSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        SizedBox(
          width: 112,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectableResourceCard extends StatelessWidget {
  const _SelectableResourceCard({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.supportingText,
    this.trailing,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final String? supportingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                    if (supportingText?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        supportingText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],
            ],
          ),
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
