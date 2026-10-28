import 'package:flutter/material.dart';

import '../../../../components/components.dart';
import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';
import '../widgets/operator_farmer_confirmation_sheet.dart';
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
  bool _refreshing = false;
  bool _sheetOpen = false;
  bool _openedInitially = false;
  String? _message;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await _refresh(announce: false);
    if (!mounted || _openedInitially) return;
    _openedInitially = true;
    final job = widget.repository.maybeJobById(widget.jobId);
    if (_isPending(job)) await _openConfirmationSheet();
  }

  bool _isPending(OperatorJob? job) =>
      job?.status == OperatorJobStatus.completedPendingConfirmation &&
      job?.farmerConfirmedAt == null;

  Future<void> _refresh({bool announce = true}) async {
    if (_refreshing || _sheetOpen) return;
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
        _error = false;
        _message = 'Farmer PIN is now available.';
      } else if (announce) {
        _error = false;
        _message = hasPin
            ? 'Farmer confirmation details are up to date.'
            : 'Details refreshed. Enter the PIN configured in the portal or use an SMS code.';
      }
    });
  }

  Future<void> _openConfirmationSheet() async {
    if (_sheetOpen ||
        !_isPending(widget.repository.maybeJobById(widget.jobId))) {
      return;
    }
    setState(() {
      _sheetOpen = true;
      _message = null;
    });
    final confirmed = await showOperatorFarmerConfirmationSheet(
      context,
      repository: widget.repository,
      jobId: widget.jobId,
    );
    if (!mounted) return;
    setState(() {
      _sheetOpen = false;
      if (confirmed == true) {
        final updated = widget.repository.maybeJobById(widget.jobId);
        _error = false;
        _message = updated?.status == OperatorJobStatus.flagged
            ? 'The service problem was sent to the union for review.'
            : 'Farmer confirmation recorded. The union can now review and verify the work.';
      }
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_sheetOpen,
    child: Scaffold(
      appBar: AppBar(
        title: Text(context.appText('Farmer confirmation')),
        actions: [
          IconButton(
            key: const ValueKey('farmer-confirmation-refresh'),
            onPressed: _sheetOpen || _refreshing ? null : _refresh,
            tooltip: context.appText('Refresh farmer details'),
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
            return Center(
              child: Text(context.appText('This job is no longer available.')),
            );
          }
          final pending = _isPending(job);
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
                            AppMessage(
                              title: context.appText(
                                'Give the phone to the farmer',
                              ),
                              message: context.appText(
                                'The farmer enters their PIN or SMS code, then may rate the tractor service. The rating is optional.',
                              ),
                            ),
                            const SizedBox(height: 14),
                            OperatorCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 28,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.appText(
                                                'Confirm the completed service',
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              context.appText(
                                                'Two short steps: verify the farmer, then collect optional feedback.',
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 52,
                                    child: FilledButton.icon(
                                      key: const ValueKey(
                                        'start-farmer-confirmation',
                                      ),
                                      onPressed: _sheetOpen
                                          ? null
                                          : _openConfirmationSheet,
                                      icon: const Icon(
                                        Icons.how_to_reg_outlined,
                                      ),
                                      label: Text(
                                        context.appText(
                                          'Start farmer confirmation',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: _sheetOpen
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    child: Text(
                                      context.appText('Confirm later'),
                                    ),
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
            label: context.appText('Farm'),
            value: job.plot.name,
          ),
          if (job.tractorLabel != null) ...[
            const SizedBox(height: 10),
            _SummaryLine(
              icon: Icons.agriculture_outlined,
              label: context.appText('Tractor'),
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
