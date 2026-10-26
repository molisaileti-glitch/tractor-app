import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../components/components.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_widgets.dart';

class OperatorFarmerConfirmationScreen extends StatefulWidget {
  const OperatorFarmerConfirmationScreen({
    super.key,
    required this.repository,
    required this.jobId,
  });
  final OperatorLocalRepository repository;
  final String jobId;

  @override
  State<OperatorFarmerConfirmationScreen> createState() =>
      _OperatorFarmerConfirmationScreenState();
}

class _OperatorFarmerConfirmationScreenState
    extends State<OperatorFarmerConfirmationScreen> {
  final _credential = TextEditingController();
  final _note = TextEditingController();
  String _method = 'pin';
  int? _rating;
  bool _dispute = false;
  bool _busy = false;
  bool _refreshing = false;
  String? _message;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh(announce: false);
    });
  }

  @override
  void dispose() {
    _credential.clear();
    _credential.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool announce = true}) async {
    if (_refreshing || _busy) return;
    final hadPin =
        widget.repository.maybeJobById(widget.jobId)?.farmerHasPin == true;
    setState(() => _refreshing = true);
    final loaded = await widget.repository.refreshJobDetail(widget.jobId);
    if (!mounted) return;
    final hasPin =
        widget.repository.maybeJobById(widget.jobId)?.farmerHasPin == true;
    setState(() {
      _refreshing = false;
      if (!loaded) {
        if (announce) {
          _error = true;
          _message =
              widget.repository.lastActionError ??
              'Could not refresh the farmer confirmation details.';
        }
        return;
      }
      if (hasPin && !hadPin) {
        _method = 'pin';
        _credential.clear();
        _error = false;
        _message = 'Farmer PIN is now available.';
      } else if (announce) {
        _error = false;
        _message = hasPin
            ? 'Farmer PIN details are up to date.'
            : 'Details refreshed. You can enter the PIN configured in the portal or use an SMS code.';
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await widget.repository.sendFarmerOtp(widget.jobId);
    if (mounted) {
      setState(() {
        _busy = false;
        _error = !ok;
        _message = ok
            ? 'Code sent to the farmer. It expires in 10 minutes; five wrong attempts invalidate it.'
            : widget.repository.lastActionError;
      });
    }
  }

  Future<void> _submit() async {
    final code = _credential.text.trim();
    if (!RegExp(_method == 'pin' ? r'^\d{4}$' : r'^\d{6}$').hasMatch(code) ||
        (_dispute && _note.text.trim().isEmpty)) {
      setState(() {
        _error = true;
        _message =
            'Enter the ${_method == 'pin' ? 'four-digit PIN' : 'six-digit code'}${_dispute ? ' and describe the problem' : ''}.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await widget.repository.confirmFarmerService(
      jobId: widget.jobId,
      method: _method,
      credential: code,
      rating: _rating,
      dispute: _dispute,
      note: _note.text.trim(),
    );
    if (!mounted) return;
    _credential.clear();
    setState(() {
      _busy = false;
      _error = !ok;
      _message = ok
          ? (_dispute
                ? 'The problem was sent to the union for review.'
                : 'Farmer confirmation recorded. The union can now review and verify the work.')
          : widget.repository.lastActionError ??
                'Confirmation failed. Please try again.';
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Farmer confirmation'),
        actions: [
          IconButton(
            key: const ValueKey('farmer-confirmation-refresh'),
            onPressed: _busy || _refreshing ? null : _refresh,
            tooltip: 'Refresh farmer details',
            icon: _refreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.repository,
        builder: (context, _) {
          final job = widget.repository.maybeJobById(widget.jobId);
          if (job == null) {
            return const Center(
              child: Text('This job is no longer available.'),
            );
          }
          final pending =
              job.status == OperatorJobStatus.completedPendingConfirmation &&
              job.farmerConfirmedAt == null;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => ListView(
                key: const ValueKey('farmer-confirmation-list'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  constraints.maxWidth >= 700 ? 28 : 16,
                  16,
                  constraints.maxWidth >= 700 ? 28 : 16,
                  32,
                ),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _JobSummary(job: job),
                          if (_message != null) ...[
                            const SizedBox(height: 14),
                            AppMessage(
                              title: _error ? 'Action needed' : 'Updated',
                              message: _message!,
                              type: _error
                                  ? AppMessageType.error
                                  : AppMessageType.success,
                            ),
                          ],
                          const SizedBox(height: 14),
                          if (!pending)
                            AppMessage(
                              type: job.farmerConfirmedAt != null
                                  ? AppMessageType.success
                                  : AppMessageType.info,
                              title: job.farmerConfirmedAt != null
                                  ? 'Confirmation complete'
                                  : 'Confirmation unavailable',
                              message: job.farmerConfirmedAt != null
                                  ? 'The farmer has already confirmed this service.'
                                  : 'This job is ${job.status.label.toLowerCase()}. Farmer confirmation becomes available after the work is completed.',
                            )
                          else ...[
                            const AppMessage(
                              title: 'Give the phone to the farmer',
                              message:
                                  'The farmer should review the service and enter their own PIN or SMS code.',
                            ),
                            const SizedBox(height: 14),
                            OperatorCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _SectionHeading(
                                    number: '1',
                                    title: 'Verify the farmer',
                                    subtitle:
                                        'Choose how the farmer wants to confirm the service.',
                                    icon: Icons.verified_user_outlined,
                                  ),
                                  const SizedBox(height: 18),
                                  SegmentedButton<String>(
                                    key: ValueKey(
                                      'confirmation-method-$_method',
                                    ),
                                    segments: const [
                                      ButtonSegment(
                                        value: 'pin',
                                        icon: Icon(Icons.pin_outlined),
                                        label: Text('Farmer PIN'),
                                      ),
                                      ButtonSegment(
                                        value: 'otp',
                                        icon: Icon(Icons.sms_outlined),
                                        label: Text('SMS code'),
                                      ),
                                    ],
                                    selected: {_method},
                                    showSelectedIcon: false,
                                    expandedInsets: EdgeInsets.zero,
                                    onSelectionChanged: _busy
                                        ? null
                                        : (values) => setState(() {
                                            _method = values.first;
                                            _credential.clear();
                                            _message = null;
                                          }),
                                  ),
                                  if (!job.farmerHasPin) ...[
                                    const SizedBox(height: 14),
                                    const AppMessage(
                                      title: 'PIN status is still updating',
                                      message:
                                          'You can enter the PIN configured in the portal, pull to refresh, or use an SMS code.',
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  if (_method == 'otp') ...[
                                    SizedBox(
                                      height: 50,
                                      child: OutlinedButton.icon(
                                        onPressed: _busy ? null : _sendOtp,
                                        icon: const Icon(Icons.send_outlined),
                                        label: const Text(
                                          'Send code to farmer',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  TextField(
                                    key: const ValueKey('farmer-credential'),
                                    controller: _credential,
                                    enabled: !_busy,
                                    obscureText: true,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    keyboardType: TextInputType.number,
                                    maxLength: _method == 'pin' ? 4 : 6,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        _method == 'pin'
                                            ? Icons.lock_outline
                                            : Icons.sms_outlined,
                                      ),
                                      labelText: _method == 'pin'
                                          ? 'Farmer four-digit PIN'
                                          : 'Farmer six-digit SMS code',
                                      helperText: _method == 'pin'
                                          ? 'Enter the PIN created in the portal.'
                                          : 'Enter the code sent to the farmer.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            OperatorCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _SectionHeading(
                                    number: '2',
                                    title: 'Service feedback',
                                    subtitle:
                                        'Rating is optional. Report a problem when the farmer is not satisfied.',
                                    icon: Icons.rate_review_outlined,
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Farmer rating (optional)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (var i = 1; i <= 5; i++)
                                        ChoiceChip(
                                          selected: _rating == i,
                                          avatar: Icon(
                                            _rating != null && i <= _rating!
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 18,
                                          ),
                                          label: Text('$i'),
                                          onSelected: _busy
                                              ? null
                                              : (selected) => setState(
                                                  () => _rating = selected
                                                      ? i
                                                      : null,
                                                ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  _DisputeChoice(
                                    selected: _dispute,
                                    enabled: !_busy,
                                    onChanged: (value) =>
                                        setState(() => _dispute = value),
                                  ),
                                  if (_dispute) ...[
                                    const SizedBox(height: 14),
                                    TextField(
                                      controller: _note,
                                      enabled: !_busy,
                                      minLines: 3,
                                      maxLines: 5,
                                      decoration: const InputDecoration(
                                        labelText: 'Describe the problem',
                                        alignLabelWithHint: true,
                                        prefixIcon: Icon(
                                          Icons.report_problem_outlined,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            OperatorCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _SectionHeading(
                                    number: '3',
                                    title: _dispute
                                        ? 'Send problem for review'
                                        : 'Confirm the service',
                                    subtitle: _dispute
                                        ? 'The union manager will review the farmer’s report.'
                                        : 'Submitting records the farmer’s satisfaction for union review.',
                                    icon: _dispute
                                        ? Icons.flag_outlined
                                        : Icons.task_alt_outlined,
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 52,
                                    child: FilledButton.icon(
                                      onPressed: _busy ? null : _submit,
                                      icon: Icon(
                                        _dispute
                                            ? Icons.flag
                                            : Icons.verified_user,
                                      ),
                                      label: Text(
                                        _busy
                                            ? 'Submitting...'
                                            : _dispute
                                            ? 'Farmer: submit problem'
                                            : 'Farmer: confirm satisfaction',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    child: const Text('Confirm later'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _JobSummary extends StatelessWidget {
  const _JobSummary({required this.job});

  final OperatorJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OperatorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.handshake_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.reference ?? job.id,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      job.farmerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.topRight,
                  child: _ConfirmationStatusPill(status: job.status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          _SummaryLine(
            icon: Icons.location_on_outlined,
            label: 'Farm',
            value: job.plot.name,
          ),
          if (job.tractorLabel != null) ...[
            const SizedBox(height: 10),
            _SummaryLine(
              icon: Icons.agriculture_outlined,
              label: 'Tractor',
              value: job.tractorLabel!,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
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
        Icon(icon, size: 19, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 9),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationStatusPill extends StatelessWidget {
  const _ConfirmationStatusPill({required this.status});

  final OperatorJobStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status == OperatorJobStatus.completedPendingConfirmation
        ? const Color(0xFF10B981)
        : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              Positioned(
                right: 1,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 15,
                    child: Center(
                      child: Text(
                        number,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DisputeChoice extends StatelessWidget {
  const _DisputeChoice({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.55)
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? theme.colorScheme.error.withValues(alpha: 0.35)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: CheckboxListTile(
        value: selected,
        enabled: enabled,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        title: const Text('I am not satisfied - report a problem'),
        subtitle: const Text('Send the issue to the union manager for review.'),
        onChanged: enabled ? (value) => onChanged(value ?? false) : null,
      ),
    );
  }
}
