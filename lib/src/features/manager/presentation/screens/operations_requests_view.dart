import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../components/components.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';
import 'schedule_service_screen.dart';

class OperationsRequestsView extends StatefulWidget {
  const OperationsRequestsView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  State<OperationsRequestsView> createState() => _OperationsRequestsViewState();
}

class _OperationsRequestsViewState extends State<OperationsRequestsView> {
  OperationsRequestStatus? _status = OperationsRequestStatus.pending;
  bool _loadingRemoteRequests = false;
  String? _remoteRequestsError;

  @override
  void initState() {
    super.initState();
    _loadRemoteRequests(initial: true);
  }

  @override
  Widget build(BuildContext context) {
    final requests = widget.repository.requestsByStatus(_status).toList();
    final pendingCount = widget.repository
        .requestsByStatus(OperationsRequestStatus.pending)
        .length;
    final approvedCount = widget.repository
        .requestsByStatus(OperationsRequestStatus.approved)
        .length;
    final rejectedCount = widget.repository
        .requestsByStatus(OperationsRequestStatus.rejected)
        .length;
    final returnedCount = widget.repository
        .requestsByStatus(OperationsRequestStatus.returned)
        .length;
    final scheduledCount = widget.repository
        .requestsByStatus(OperationsRequestStatus.scheduled)
        .length;
    final cancelledCount = widget.repository
        .requestsByStatus(OperationsRequestStatus.cancelled)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.appText('Service Requests'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: widget.repository.can('mech.requests.manage')
                  ? _openRegisterRequest
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.add),
              label: Text(context.appText('Register')),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _RemoteRequestsBanner(
          isLoading: _loadingRemoteRequests,
          error:
              _remoteRequestsError ??
              widget.repository.mechanizationActionError,
          onRefresh: _loadRemoteRequests,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'Pending $pendingCount',
                selected: _status == OperationsRequestStatus.pending,
                onSelected: () =>
                    setState(() => _status = OperationsRequestStatus.pending),
              ),
              _FilterChip(
                label: 'Approved $approvedCount',
                selected: _status == OperationsRequestStatus.approved,
                onSelected: () =>
                    setState(() => _status = OperationsRequestStatus.approved),
              ),
              _FilterChip(
                label: 'Rejected $rejectedCount',
                selected: _status == OperationsRequestStatus.rejected,
                onSelected: () =>
                    setState(() => _status = OperationsRequestStatus.rejected),
              ),
              _FilterChip(
                label: 'Returned $returnedCount',
                selected: _status == OperationsRequestStatus.returned,
                onSelected: () =>
                    setState(() => _status = OperationsRequestStatus.returned),
              ),
              _FilterChip(
                label: 'Scheduled $scheduledCount',
                selected: _status == OperationsRequestStatus.scheduled,
                onSelected: () =>
                    setState(() => _status = OperationsRequestStatus.scheduled),
              ),
              _FilterChip(
                label: 'Cancelled $cancelledCount',
                selected: _status == OperationsRequestStatus.cancelled,
                onSelected: () =>
                    setState(() => _status = OperationsRequestStatus.cancelled),
              ),
              for (final status in [
                OperationsRequestStatus.inProgress,
                OperationsRequestStatus.paused,
                OperationsRequestStatus.completed,
                OperationsRequestStatus.verified,
                OperationsRequestStatus.closed,
                OperationsRequestStatus.flagged,
              ])
                _FilterChip(
                  label:
                      '${status.label} ${widget.repository.requestsByStatus(status).length}',
                  selected: _status == status,
                  onSelected: () => setState(() => _status = status),
                ),
              _FilterChip(
                label: 'All ${widget.repository.requests.length}',
                selected: _status == null,
                onSelected: () => setState(() => _status = null),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PageTransitionSwitcher(
          duration: AppMotion.duration(context, AppMotion.standard),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: Colors.transparent,
                child: child,
              ),
          child: requests.isEmpty
              ? _RequestsEmptyState(
                  key: ValueKey('empty-$_status'),
                  message: context.appText('No requests found.'),
                )
              : _RequestCardGrid(
                  key: ValueKey('requests-$_status'),
                  requests: requests,
                  onOpen: (id) => _openRequest(context, id),
                ),
        ),
      ],
    );
  }

  void _openRequest(BuildContext context, String id) {
    unawaited(widget.repository.refreshRequestDetail(id));
    Navigator.of(context).push(
      appPageRoute(
        builder: (_) => OperationsRequestDetailScreen(
          repository: widget.repository,
          requestId: id,
        ),
      ),
    );
  }

  Future<void> _openRegisterRequest() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _RegisterRequestSheet(repository: widget.repository),
    );
    if (!mounted) return;
    await _loadRemoteRequests();
  }

  Future<void> _loadRemoteRequests({bool initial = false}) async {
    setState(() => _loadingRemoteRequests = true);
    if (initial) {
      await widget.repository.ensureScreenLoaded(UnionDataScreen.requests);
    } else {
      await widget.repository.refreshScreen(UnionDataScreen.requests);
    }
    if (!mounted) return;
    setState(() {
      _remoteRequestsError = widget.repository.screenError(
        UnionDataScreen.requests,
      );
      _loadingRemoteRequests = false;
    });
  }
}

class _RequestsEmptyState extends StatelessWidget {
  const _RequestsEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 44,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoteRequestsBanner extends StatelessWidget {
  const _RemoteRequestsBanner({
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && error == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final color = error != null
        ? const Color(0xFFC8872B)
        : theme.colorScheme.primary;
    final text = isLoading
        ? 'Refreshing service requests...'
        : error != null
        ? 'Service requests unavailable - $error'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            isLoading ? Icons.sync : Icons.cloud_done_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: context.appText('Refresh'),
            onPressed: isLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _RequestCardGrid extends StatelessWidget {
  const _RequestCardGrid({
    super.key,
    required this.requests,
    required this.onOpen,
  });

  final List<OperationsServiceRequest> requests;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980
            ? 3
            : constraints.maxWidth >= 650
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final request in requests)
              SizedBox(
                width: width,
                child: _RequestPreviewCard(
                  request: request,
                  onTap: () => onOpen(request.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RequestPreviewCard extends StatelessWidget {
  const _RequestPreviewCard({required this.request, required this.onTap});

  final OperationsServiceRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OperationsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      request.serviceType.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('${request.farmerName} - ${request.plot.name}'),
                  ],
                ),
              ),
              OperationsStatusChip.request(requestStatus: request.status),
            ],
          ),
          const SizedBox(height: 16),
          _MiniFact(
            icon: Icons.calendar_today_outlined,
            text: 'Farmer preferred: ${formatDate(request.preferredDate)}',
          ),
          const SizedBox(height: 8),
          _MiniFact(
            icon: Icons.landscape_outlined,
            text: '${request.plot.areaHectares.toStringAsFixed(1)} hectares',
          ),
          const SizedBox(height: 8),
          _MiniFact(
            icon: Icons.location_on_outlined,
            text: request.plot.location.isEmpty
                ? request.plot.name
                : request.plot.location,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.landscape_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${request.plot.areaHectares.toStringAsFixed(1)} ha - ${request.plot.location}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (request.rejectionReason != null &&
              request.status != OperationsRequestStatus.pending) ...[
            Text(
              request.rejectionReason!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              context.appText('Open request'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFact extends StatelessWidget {
  const _MiniFact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class OperationsRequestDetailScreen extends StatelessWidget {
  const OperationsRequestDetailScreen({
    super.key,
    required this.repository,
    required this.requestId,
  });

  final UnionOperationsRepository repository;
  final String requestId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final request = repository.maybeRequestById(requestId);
        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.appText('Request unavailable'))),
            body: Center(
              child: Text(
                context.appText('This request is no longer available.'),
              ),
            ),
          );
        }
        final requestNotes = _RequestNotes.parse(request.notes);
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: _RequestPlotMap(request: request)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            context.appText('Service request'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.42,
                minChildSize: 0.22,
                maxChildSize: 0.78,
                snap: true,
                snapSizes: const [0.22, 0.42, 0.78],
                builder: (context, scrollController) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 760),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${request.serviceType.label} for ${request.farmerName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  OperationsStatusChip.request(
                                    requestStatus: request.status,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _Fact(
                                label: context.appText('Farmer'),
                                value: request.farmerName,
                              ),
                              _Fact(
                                label: context.appText('Service'),
                                value: request.serviceType.label,
                              ),
                              _Fact(
                                label: context.appText('Preferred Date'),
                                value: formatDate(request.preferredDate),
                              ),
                              _Fact(
                                label: context.appText('Plot'),
                                value: request.plot.name,
                              ),
                              _Fact(
                                label: context.appText('Area'),
                                value:
                                    '${request.plot.areaHectares.toStringAsFixed(1)} hectares',
                              ),
                              _Fact(
                                label: context.appText('Location'),
                                value: request.plot.location.isEmpty
                                    ? 'Not provided'
                                    : request.plot.location,
                              ),
                              if (requestNotes.amcos != null)
                                _Fact(
                                  label: context.appText('AMCOS'),
                                  value: requestNotes.amcos!,
                                ),
                              if (requestNotes.mcu != null)
                                _Fact(
                                  label: context.appText('MCU'),
                                  value: requestNotes.mcu!,
                                ),
                              if (requestNotes.season != null)
                                _Fact(
                                  label: context.appText('Season'),
                                  value: requestNotes.season!,
                                ),
                              if (requestNotes.crop != null)
                                _Fact(
                                  label: context.appText('Crop'),
                                  value: requestNotes.crop!,
                                ),
                              const Divider(height: 26),
                              if (requestNotes.other.isNotEmpty) ...[
                                Text(
                                  requestNotes.other,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 6),
                              ],
                              if (repository.can('mech.requests.manage') &&
                                  request.status ==
                                      OperationsRequestStatus.pending)
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showRejectSheet(context, request),
                                      icon: const Icon(Icons.close),
                                      label: Text(context.appText('Reject')),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _returnForCorrection(
                                        context,
                                        request,
                                      ),
                                      icon: const Icon(Icons.keyboard_return),
                                      label: Text(context.appText('Return')),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _approve(context, request.id),
                                      icon: const Icon(Icons.check),
                                      label: Text(context.appText('Approve')),
                                    ),
                                  ],
                                )
                              else if (repository.can('mech.jobs.manage') &&
                                  request.status ==
                                      OperationsRequestStatus.approved)
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _openSchedule(context, request.id),
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                      ),
                                      label: Text(
                                        context.appText('Schedule Service'),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _cancelRequest(context, request),
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: Text(context.appText('Cancel')),
                                    ),
                                  ],
                                )
                              else if (repository.can('mech.requests.manage') &&
                                  request.status ==
                                      OperationsRequestStatus.scheduled)
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    Text(
                                      context.appText(
                                        'This request has been scheduled.',
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _cancelRequest(context, request),
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: Text(context.appText('Cancel')),
                                    ),
                                  ],
                                )
                              else if (request.status ==
                                      OperationsRequestStatus.cancelled ||
                                  request.status ==
                                      OperationsRequestStatus.rejected ||
                                  request.status ==
                                      OperationsRequestStatus.returned)
                                Text(
                                  '${request.status.label}: ${request.rejectionReason ?? 'No reason recorded.'}',
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _approve(BuildContext context, String id) async {
    var scheduleAfterApproval = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ApproveRequestSheet(
        onSubmit:
            ({
              required num amount,
              required String priority,
              String? note,
            }) async {
              await repository.approveRequest(
                id: id,
                estimateAmount: amount,
                priority: priority,
                note: note,
              );
              if (!context.mounted) return;
              final error = repository.mechanizationActionError;
              if (error != null) {
                await showAppErrorDialog(
                  context,
                  title: context.appText('Request not approved'),
                  message: error,
                );
                return;
              }
              final scheduleNow = await showAppConfirmationDialog(
                context,
                title: context.appText('Request approved'),
                message: context.appText(
                  'The request is ready for scheduling. Schedule it now, or find it later under the Approved tab.',
                ),
                confirmLabel: 'Schedule',
                cancelLabel: 'Later',
              );
              scheduleAfterApproval = scheduleNow;
            },
      ),
    );
    if (scheduleAfterApproval && context.mounted) {
      _openSchedule(context, id);
    }
  }

  Future<void> _returnForCorrection(
    BuildContext context,
    OperationsServiceRequest request,
  ) async {
    final reason = await _askForText(
      context,
      title: context.appText('Return For Correction'),
      label: context.appText('Reason'),
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!context.mounted) return;
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Return request?'),
      message: context.appText(
        'The request will be returned for correction with the reason you entered.',
      ),
      onConfirm: () =>
          repository.returnRequest(id: request.id, reason: reason.trim()),
      confirmLabel: 'Return',
      workingLabel: 'Returning...',
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    final error = repository.mechanizationActionError;
    if (error != null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Request not returned'),
        message: error,
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: context.appText('Returned for correction'),
      message: context.appText(
        'The request is now under the Returned tab and can be corrected from the farmer side.',
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _cancelRequest(
    BuildContext context,
    OperationsServiceRequest request,
  ) async {
    final reason = await _askForText(
      context,
      title: context.appText('Cancel Request'),
      label: context.appText('Reason'),
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!context.mounted) return;
    final confirmed = await showAppAsyncConfirmationDialog(
      context,
      title: context.appText('Cancel request?'),
      message: context.appText(
        'This request will be cancelled and cannot proceed to scheduling.',
      ),
      onConfirm: () => repository.cancelRequest(
        id: request.id,
        reason: reason.trim(),
        notes: '',
      ),
      confirmLabel: 'Cancel Request',
      workingLabel: 'Cancelling...',
      danger: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    final error = repository.mechanizationActionError;
    if (error != null) {
      await showAppErrorDialog(
        context,
        title: context.appText('Request not cancelled'),
        message: error,
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: context.appText('Request cancelled'),
      message: context.appText(
        'The request is now available under the Cancelled tab.',
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<String?> _askForText(
    BuildContext context, {
    required String title,
    required String label,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _RequestReasonDialog(title: title, label: label),
    );
  }

  void _openSchedule(BuildContext context, String id) {
    Navigator.of(context).push(
      appPageRoute(
        builder: (_) =>
            ScheduleServiceScreen(repository: repository, requestId: id),
      ),
    );
  }

  void _showRejectSheet(
    BuildContext context,
    OperationsServiceRequest request,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _RejectRequestSheet(repository: repository, request: request),
    );
  }
}

class _RequestReasonDialog extends StatefulWidget {
  const _RequestReasonDialog({required this.title, required this.label});

  final String title;
  final String label;

  @override
  State<_RequestReasonDialog> createState() => _RequestReasonDialogState();
}

class _RequestReasonDialogState extends State<_RequestReasonDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(labelText: widget.label),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        AppDialogActions(
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}

typedef _ApproveSubmit =
    Future<void> Function({
      required num amount,
      required String priority,
      String? note,
    });

class _ApproveRequestSheet extends StatefulWidget {
  const _ApproveRequestSheet({required this.onSubmit});

  final _ApproveSubmit onSubmit;

  @override
  State<_ApproveRequestSheet> createState() => _ApproveRequestSheetState();
}

class _ApproveRequestSheetState extends State<_ApproveRequestSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _priority = 'normal';
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.appText('Approve Request'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            enabled: !_submitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.appText('Estimate amount'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: InputDecoration(labelText: context.appText('Priority')),
            items: [
              DropdownMenuItem(
                value: 'normal',
                child: Text(context.appText('Normal')),
              ),
              DropdownMenuItem(
                value: 'high',
                child: Text(context.appText('High')),
              ),
              DropdownMenuItem(
                value: 'urgent',
                child: Text(context.appText('Urgent')),
              ),
            ],
            onChanged: _submitting
                ? null
                : (value) => setState(() => _priority = value ?? _priority),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            enabled: !_submitting,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: context.appText('Review note'),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(context.appText('Cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: AppButtonContent(
                    loading: _submitting,
                    loadingLabel: context.appText('Approving...'),
                    label: context.appText('Approve'),
                    icon: Icons.check_circle_outline,
                    progressColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amount = num.tryParse(_amountController.text.trim());
    if (amount == null) {
      showAppSnackBar(
        context,
        message: context.appText('Enter a valid estimate amount.'),
        type: AppSnackType.warning,
      );
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Approve request?'),
      message:
          'Approve this service request with an estimated amount of $amount?',
      confirmLabel: 'Approve',
    );
    if (!confirmed || !mounted) return;
    setState(() => _submitting = true);
    await widget.onSubmit(
      amount: amount,
      priority: _priority,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _RegisterRequestSheet extends StatefulWidget {
  const _RegisterRequestSheet({required this.repository});

  final UnionOperationsRepository repository;

  @override
  State<_RegisterRequestSheet> createState() => _RegisterRequestSheetState();
}

class _RegisterRequestSheetState extends State<_RegisterRequestSheet> {
  final _farmerIdController = TextEditingController();
  final _plotIdController = TextEditingController();
  final _serviceTypeIdController = TextEditingController();
  final _acresController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _window = 'morning';
  String _priority = 'normal';
  bool _submitting = false;
  bool _loadingPickers = true;
  bool _loadingPlots = false;
  int _plotLoadVersion = 0;
  String? _pickerError;
  List<Map<String, Object?>> _serviceTypes = [];
  List<Map<String, Object?>> _plots = [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadPickers());
  }

  Future<void> _loadPickers() async {
    try {
      await widget.repository.refreshFarmers();
      final services = await widget.repository.serviceTypeOptions();
      if (!mounted) return;
      setState(() {
        _serviceTypes = services;
        _loadingPickers = false;
        _pickerError = widget.repository.mechanizationSyncError;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _pickerError = error.toString();
          _loadingPickers = false;
        });
      }
    }
  }

  Future<void> _selectFarmer(String? farmerId) async {
    final version = ++_plotLoadVersion;
    setState(() {
      _farmerIdController.text = farmerId ?? '';
      _plotIdController.clear();
      _plots = [];
      _loadingPlots = true;
      _pickerError = null;
    });
    try {
      final plots = farmerId == null
          ? <Map<String, Object?>>[]
          : await widget.repository.farmerPlotOptions(farmerId);
      if (!mounted || version != _plotLoadVersion) return;
      setState(() {
        _plots = plots;
        _loadingPlots = false;
      });
    } catch (error) {
      if (mounted && version == _plotLoadVersion) {
        setState(() {
          _pickerError = error.toString();
          _loadingPlots = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _farmerIdController.dispose();
    _plotIdController.dispose();
    _serviceTypeIdController.dispose();
    _acresController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.appText('Register Service Request'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            if (_loadingPickers) const LinearProgressIndicator(),
            if (_pickerError != null)
              AppMessage(message: _pickerError!, type: AppMessageType.error),
            DropdownButtonFormField<String>(
              initialValue: _farmerIdController.text.isEmpty
                  ? null
                  : _farmerIdController.text,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.appText('Farmer')),
              items: [
                for (final farmer in widget.repository.farmers)
                  DropdownMenuItem(
                    value: farmer.id,
                    child: Text(farmer.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: _loadingPickers || _submitting ? null : _selectFarmer,
            ),
            const SizedBox(height: 10),
            if (_loadingPlots) const LinearProgressIndicator(),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'plots-${_farmerIdController.text}-$_plotLoadVersion',
              ),
              initialValue: _plotIdController.text.isEmpty
                  ? null
                  : _plotIdController.text,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.appText('Mapped plot'),
              ),
              items: [
                for (final plot in _plots)
                  if (plot['mapped'] == true ||
                      (plot['boundary'] is List &&
                          (plot['boundary'] as List).length >= 3))
                    DropdownMenuItem(
                      value: plot['id'].toString(),
                      child: Text(
                        plot['name']?.toString() ?? 'Plot',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ],
              onChanged: _loadingPlots || _submitting
                  ? null
                  : (value) =>
                        setState(() => _plotIdController.text = value ?? ''),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _serviceTypeIdController.text.isEmpty
                  ? null
                  : _serviceTypeIdController.text,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: context.appText('Service'),
              ),
              items: [
                for (final service in _serviceTypes)
                  DropdownMenuItem(
                    value: service['id'].toString(),
                    child: Text(
                      service['name']?.toString() ?? service['code'].toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _loadingPickers || _submitting
                  ? null
                  : (value) => setState(
                      () => _serviceTypeIdController.text = value ?? '',
                    ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _acresController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: context.appText('Requested acres'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('Preferred date: ${formatDate(_date)}'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _window,
              decoration: InputDecoration(
                labelText: context.appText('Preferred window'),
              ),
              items: [
                DropdownMenuItem(
                  value: 'morning',
                  child: Text(context.appText('Morning')),
                ),
                DropdownMenuItem(
                  value: 'afternoon',
                  child: Text(context.appText('Afternoon')),
                ),
                DropdownMenuItem(
                  value: 'full_day',
                  child: Text(context.appText('Full day')),
                ),
              ],
              onChanged: (value) => setState(() => _window = value ?? _window),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: InputDecoration(
                labelText: context.appText('Priority'),
              ),
              items: [
                DropdownMenuItem(
                  value: 'normal',
                  child: Text(context.appText('Normal')),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text(context.appText('High')),
                ),
                DropdownMenuItem(
                  value: 'urgent',
                  child: Text(context.appText('Urgent')),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _priority = value ?? _priority),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(labelText: context.appText('Notes')),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(context.appText('Cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting || _loadingPickers || _loadingPlots
                        ? null
                        : _submit,
                    child: AppButtonContent(
                      loading: _submitting,
                      loadingLabel: context.appText('Registering...'),
                      label: context.appText('Register'),
                      icon: Icons.add_task_outlined,
                      progressColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
    setState(() => _date = selected);
  }

  Future<void> _submit() async {
    final farmerId = _farmerIdController.text.trim();
    final plotId = _plotIdController.text.trim();
    final serviceTypeId = _serviceTypeIdController.text.trim();
    final acres = num.tryParse(_acresController.text.trim());
    if (farmerId.isEmpty ||
        plotId.isEmpty ||
        serviceTypeId.isEmpty ||
        acres == null ||
        !acres.isFinite ||
        acres <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.appText(
              'Select a farmer, mapped plot and service, and enter positive acres.',
            ),
          ),
        ),
      );
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Register service request?'),
      message: 'Create a request for $acres acres on ${formatDate(_date)}?',
      confirmLabel: 'Register',
    );
    if (!confirmed || !mounted) return;
    setState(() => _submitting = true);
    await widget.repository.registerRequest(
      farmerId: farmerId,
      plotId: plotId,
      serviceTypeId: serviceTypeId,
      requestedAcres: acres,
      preferredDate: _date,
      preferredWindow: _window,
      priority: _priority,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    final error = widget.repository.mechanizationActionError;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop();
  }
}

class _RejectRequestSheet extends StatefulWidget {
  const _RejectRequestSheet({required this.repository, required this.request});

  final UnionOperationsRepository repository;
  final OperationsServiceRequest request;

  @override
  State<_RejectRequestSheet> createState() => _RejectRequestSheetState();
}

class _RejectRequestSheetState extends State<_RejectRequestSheet> {
  String _reason = 'No tractor available';
  bool _submitting = false;

  static const _reasons = [
    'No tractor available',
    'Service unavailable',
    'Invalid plot information',
    'Duplicate request',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.appText('Reject Request'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final reason in _reasons)
            InkWell(
              onTap: _submitting
                  ? null
                  : () => setState(() => _reason = reason),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _reason == reason
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(context.appText('Cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: AppButtonContent(
                    loading: _submitting,
                    loadingLabel: context.appText('Rejecting...'),
                    label: context.appText('Reject Request'),
                    icon: Icons.block_outlined,
                    progressColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: context.appText('Reject request?'),
      message: 'This request will be rejected for: $_reason.',
      confirmLabel: 'Reject',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _submitting = true);
    await widget.repository.rejectRequest(
      id: widget.request.id,
      reason: _reason,
      notes: '',
    );
    if (!mounted) return;
    final error = widget.repository.mechanizationActionError;
    if (error != null) {
      setState(() => _submitting = false);
      await showAppErrorDialog(
        context,
        title: context.appText('Request not rejected'),
        message: error,
      );
      return;
    }
    await showAppSuccessDialog(
      context,
      title: context.appText('Request rejected'),
      message: context.appText(
        'The request is now available under the Rejected tab.',
      ),
    );
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop();
  }
}

class _RequestPlotMap extends StatelessWidget {
  const _RequestPlotMap({required this.request});

  final OperationsServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final points = request.plot.boundaryPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    if (points.isEmpty) {
      return Container(
        color: const Color(0xFF1D3028),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          context.appText('No plot coordinates returned for this request.'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      );
    }

    final center = _center(points);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: points.length >= 3 ? 17 : 18.5,
      ),
      onMapCreated: (controller) {
        if (points.length < 2) return;
        controller.moveCamera(
          CameraUpdate.newLatLngBounds(_boundsFor(points), 48),
        );
      },
      mapType: MapType.hybrid,
      markers: {
        Marker(
          markerId: MarkerId('request-plot-${request.id}'),
          position: center,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Farm: ${request.plot.name}',
            snippet: '${request.farmerName} - plot centre',
          ),
        ),
      },
      polygons: {
        if (points.length >= 3)
          Polygon(
            polygonId: PolygonId('request-boundary-${request.id}'),
            points: points,
            fillColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            strokeColor: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
      },
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      compassEnabled: true,
      buildingsEnabled: true,
    );
  }

  LatLng _center(List<LatLng> points) {
    final latitude =
        points.fold<double>(0, (sum, point) => sum + point.latitude) /
        points.length;
    final longitude =
        points.fold<double>(0, (sum, point) => sum + point.longitude) /
        points.length;
    return LatLng(latitude, longitude);
  }

  LatLngBounds _boundsFor(List<LatLng> points) {
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }
}

class _RequestNotes {
  const _RequestNotes({
    this.amcos,
    this.mcu,
    this.season,
    this.crop,
    required this.other,
  });

  final String? amcos;
  final String? mcu;
  final String? season;
  final String? crop;
  final String other;

  factory _RequestNotes.parse(String? notes) {
    String? amcos;
    String? mcu;
    String? season;
    String? crop;
    final other = <String>[];

    for (final rawPart in (notes ?? '').split('|')) {
      final part = rawPart.trim();
      if (part.isEmpty) continue;
      final separator = part.indexOf(':');
      if (separator < 0) {
        other.add(part);
        continue;
      }

      final key = part.substring(0, separator).trim().toLowerCase();
      final value = part.substring(separator + 1).trim();
      if (value.isEmpty) continue;
      switch (key) {
        case 'amcos':
          amcos = value;
        case 'mcu':
          mcu = value;
        case 'season':
          season = value;
        case 'crop':
          crop = value;
        default:
          other.add(part);
      }
    }

    return _RequestNotes(
      amcos: amcos,
      mcu: mcu,
      season: season,
      crop: crop,
      other: other.join(' | '),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final labelWidth = constraints.maxWidth * 0.36;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: labelWidth,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.left,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
