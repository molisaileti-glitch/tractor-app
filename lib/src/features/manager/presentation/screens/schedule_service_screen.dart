import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../../../core/theme/app_theme.dart';
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
  String? _selectedImplement;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  int _duration = 4;
  bool _checkingAvailability = false;
  bool _submitting = false;
  RequestAvailabilityResult? _availability;

  @override
  void initState() {
    super.initState();
    final preferred =
        widget.repository.maybeRequestById(widget.requestId)?.preferredDate ??
        DateTime.now();
    final today = DateTime.now();
    _date = preferred.isBefore(DateTime(today.year, today.month, today.day))
        ? today
        : preferred;
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.repository.maybeRequestById(widget.requestId);
    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request unavailable')),
        body: const Center(child: Text('This request is no longer available.')),
      );
    }
    final availableTractors = widget.repository.tractors
        .where((tractor) => tractor.status.canSchedule)
        .toList();
    final availableOperators = widget.repository.operators
        .where((operator) => operator.status.canSchedule)
        .toList();
    final selectedTractor = availableTractors
        .where((tractor) => tractor.id == _tractorId)
        .firstOrNull;
    final implementNames = selectedTractor?.implementNames ?? const <String>[];
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined),
            SizedBox(width: 10),
            Text('Schedule service'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RequestOverview(request: request),
                    const SizedBox(height: 22),
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
                          title: const Text('Tractor'),
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
                                    _selectedImplement = null;
                                    _availability = null;
                                  }),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                        Step(
                          title: const Text('Operator'),
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
                          subtitle: const Text(
                            'Choose the service date and time',
                          ),
                          isActive: _currentStep >= 2,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ScheduleDetailsPanel(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _ScheduleTile(
                                      label: 'Date',
                                      value: formatDate(_date),
                                      icon: Icons.calendar_month_outlined,
                                      onTap: _pickDate,
                                    ),
                                    const Divider(height: 1),
                                    _ScheduleTile(
                                      label: 'Start time',
                                      value: _time.format(context),
                                      icon: Icons.schedule,
                                      onTap: _pickTime,
                                    ),
                                    const Divider(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        18,
                                      ),
                                      child: _DurationSelector(
                                        value: _duration,
                                        onChanged: (value) => setState(() {
                                          _duration = value;
                                          _availability = null;
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (implementNames.isEmpty)
                                const AppMessage(
                                  message:
                                      'No implement is configured for this tractor. The server will validate the service requirements.',
                                  type: AppMessageType.warning,
                                )
                              else
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedImplement,
                                  decoration: const InputDecoration(
                                    labelText: 'Implement',
                                    prefixIcon: Icon(Icons.handyman_outlined),
                                  ),
                                  hint: const Text('Select an implement'),
                                  items: [
                                    for (final implement in implementNames)
                                      DropdownMenuItem(
                                        value: implement,
                                        child: Text(implement),
                                      ),
                                  ],
                                  onChanged: (value) => setState(() {
                                    _selectedImplement = value;
                                    _availability = null;
                                  }),
                                ),
                              const SizedBox(height: 14),
                              if (_availability == null)
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
                                      : const Icon(
                                          Icons.event_available_outlined,
                                        ),
                                  label: Text(
                                    _checkingAvailability
                                        ? 'Checking availability...'
                                        : 'Check availability',
                                  ),
                                )
                              else
                                _AvailabilityBanner(result: _availability!),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed:
                                    _submitting ||
                                        _availability?.isAvailable != true
                                    ? null
                                    : _confirmSchedule,
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
                                      : 'Confirm schedule',
                                ),
                              ),
                              if (_availability != null) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _checkingAvailability
                                      ? null
                                      : _checkAvailability,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Check availability again'),
                                ),
                              ],
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
      windowStart: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
      duration: Duration(hours: _duration),
      tractorId: _tractorId!,
      operatorId: _operatorId!,
    );
    if (!mounted) return result;
    setState(() {
      _availability = result;
      _checkingAvailability = false;
    });
    if (result == null && widget.repository.mechanizationActionError != null) {
      showAppSnackBar(
        context,
        message: widget.repository.mechanizationActionError!,
        type: AppSnackType.error,
      );
    }
    return result;
  }

  Future<void> _confirmSchedule() async {
    final availability = await _checkAvailability();
    if (!mounted) return;
    if (availability == null) return;
    if (!availability.isAvailable) {
      showAppSnackBar(
        context,
        message: availability.summary,
        type: AppSnackType.warning,
      );
      return;
    }
    final implement = _selectedImplement;
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
    await widget.repository.scheduleRequest(
      requestId: widget.requestId,
      tractorId: _tractorId!,
      operatorId: _operatorId!,
      scheduledAt: scheduledAt,
      estimatedHours: _duration,
      implement: implement,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (widget.repository.mechanizationActionError != null) {
      showAppSnackBar(
        context,
        message: widget.repository.mechanizationActionError!,
        type: AppSnackType.error,
      );
      return;
    }
    final scheduledJob = widget.repository.jobForRequest(widget.requestId);
    if (scheduledJob?.status == JobStatus.dispatched) {
      await showAppSuccessDialog(
        context,
        title: 'Service scheduled and dispatched',
        message:
            'The backend dispatched this assignment while scheduling it. The operator can now receive it under active jobs.',
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    final dispatchNow = await showAppConfirmationDialog(
      context,
      title: 'Service scheduled',
      message:
          'The schedule has been saved. Would you like to dispatch this job to the operator now?',
      confirmLabel: 'Dispatch now',
      cancelLabel: 'Later',
    );
    if (!mounted) return;
    if (dispatchNow) {
      if (scheduledJob == null) {
        await showAppErrorDialog(
          context,
          title: 'Dispatch unavailable',
          message:
              'The schedule was saved, but the created job could not be loaded. Refresh the Jobs section and dispatch it from the job actions menu.',
        );
        if (!mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }
      await widget.repository.dispatchJob(scheduledJob.id);
      if (!mounted) return;
      final error = widget.repository.mechanizationActionError;
      if (error != null) {
        await showAppErrorDialog(
          context,
          title: 'Dispatch failed',
          message: error,
        );
        if (!mounted) return;
      } else {
        await showAppSuccessDialog(
          context,
          title: 'Job dispatched',
          message:
              'The assignment has been sent to the operator. You can continue tracking it under Jobs or Schedule.',
        );
        if (!mounted) return;
      }
    } else {
      await showAppFeedbackDialog(
        context,
        title: 'Dispatch later',
        message:
            'You can dispatch this assignment later from the Jobs section using the job actions menu.',
        icon: Icons.schedule_send_outlined,
        color: Theme.of(context).colorScheme.primary,
        buttonLabel: 'Got it',
      );
      if (!mounted) return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _RequestOverview extends StatelessWidget {
  const _RequestOverview({required this.request});

  final OperationsServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preferredWindow = request.preferredWindow?.trim();
    final work = request.requestedAcres == null
        ? '${request.plot.areaHectares.toStringAsFixed(1)} ha plot'
        : '${request.requestedAcres!.toStringAsFixed(1)} acres requested';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.agriculture_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceType.label,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${request.farmerName} - ${request.plot.name}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OperationsStatusChip.request(requestStatus: request.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 5,
          children: [
            Text(
              work,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '- Preferred ${formatDate(request.preferredDate)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (preferredWindow != null && preferredWindow.isNotEmpty)
              Text(
                '- $preferredWindow',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ScheduleDetailsPanel extends StatelessWidget {
  const _ScheduleDetailsPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _DurationSelector extends StatelessWidget {
  const _DurationSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated duration', style: theme.textTheme.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final hours in const [2, 4, 6, 8])
              ChoiceChip(
                label: Text('$hours h'),
                selected: value == hours,
                onSelected: (_) => onChanged(hours),
                showCheckmark: false,
              ),
          ],
        ),
      ],
    );
  }
}

class _AvailabilityBanner extends StatelessWidget {
  const _AvailabilityBanner({required this.result});

  final RequestAvailabilityResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = result.isAvailable
        ? AppColors.adaptiveSuccess(context)
        : theme.colorScheme.error;
    return AnimatedContainer(
      duration: AppMotion.standard,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result.isAvailable
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.summary,
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
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
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
