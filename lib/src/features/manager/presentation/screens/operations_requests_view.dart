import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/presentation/components/components.dart';
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
    _loadRemoteRequests();
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
                'Service Requests',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _showRegisterSheet,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Register'),
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
              _FilterChip(
                label: 'All ${widget.repository.requests.length}',
                selected: _status == null,
                onSelected: () => setState(() => _status = null),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (requests.isEmpty)
          const _RequestsEmptyState(message: 'No requests found.')
        else
          _RequestCardGrid(
            requests: requests,
            onOpen: (id) => _openRequest(context, id),
          ),
      ],
    );
  }

  void _openRequest(BuildContext context, String id) {
    unawaited(widget.repository.refreshRequestDetail(id));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OperationsRequestDetailScreen(
          repository: widget.repository,
          requestId: id,
        ),
      ),
    );
  }

  Future<void> _loadRemoteRequests() async {
    setState(() => _loadingRemoteRequests = true);
    await widget.repository.refreshServiceRequests();
    if (!mounted) return;
    setState(() {
      _remoteRequestsError = widget.repository.mechanizationActionError;
      _loadingRemoteRequests = false;
    });
  }

  void _showRegisterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RegisterRequestSheet(repository: widget.repository),
    );
  }
}

class _RequestsEmptyState extends StatelessWidget {
  const _RequestsEmptyState({required this.message});

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
                color: Colors.black.withValues(alpha: 0.62),
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
                color: Colors.black.withValues(alpha: 0.74),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
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
  const _RequestCardGrid({required this.requests, required this.onOpen});

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
            text: formatDate(request.preferredDate),
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
                color: Colors.black.withValues(alpha: 0.70),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Open request',
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
        Icon(icon, size: 18, color: Colors.black54),
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
        final request = repository.requestById(requestId);
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
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Service request',
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
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
                              _Fact(label: 'Farmer', value: request.farmerName),
                              _Fact(
                                label: 'Service',
                                value: request.serviceType.label,
                              ),
                              _Fact(
                                label: 'Preferred Date',
                                value: formatDate(request.preferredDate),
                              ),
                              _Fact(label: 'Plot', value: request.plot.name),
                              _Fact(
                                label: 'Area',
                                value:
                                    '${request.plot.areaHectares.toStringAsFixed(1)} hectares',
                              ),
                              _Fact(
                                label: 'Location',
                                value: request.plot.location,
                              ),
                              const Divider(height: 26),
                              Text(
                                request.notes ?? 'No farmer notes added.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              if (request.status ==
                                  OperationsRequestStatus.pending)
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showRejectSheet(context, request),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _returnForCorrection(
                                        context,
                                        request,
                                      ),
                                      icon: const Icon(Icons.keyboard_return),
                                      label: const Text('Return'),
                                    ),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _approve(context, request.id),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                    ),
                                  ],
                                )
                              else if (request.status ==
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
                                      label: const Text('Schedule Service'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _cancelRequest(context, request),
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text('Cancel'),
                                    ),
                                  ],
                                )
                              else if (request.status ==
                                  OperationsRequestStatus.scheduled)
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    const Text(
                                      'This request has been scheduled.',
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _cancelRequest(context, request),
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text('Cancel'),
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

  void _approve(BuildContext context, String id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ApproveRequestSheet(
        onSubmit:
            ({required num amount, required String priority, String? note}) {
              unawaited(
                repository.approveRequest(
                  id: id,
                  estimateAmount: amount,
                  priority: priority,
                  note: note,
                ),
              );
              _showSchedulePrompt(context, id);
            },
      ),
    );
  }

  void _showSchedulePrompt(BuildContext context, String id) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Approved'),
        content: const Text('Next step: schedule service.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openSchedule(context, id);
            },
            child: const Text('Schedule Service'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnForCorrection(
    BuildContext context,
    OperationsServiceRequest request,
  ) async {
    final reason = await _askForText(
      context,
      title: 'Return For Correction',
      label: 'Reason',
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!context.mounted) return;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Return request?',
      message:
          'The request will be returned for correction with the reason you entered.',
      confirmLabel: 'Return',
    );
    if (!confirmed) return;
    unawaited(repository.returnRequest(id: request.id, reason: reason.trim()));
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _cancelRequest(
    BuildContext context,
    OperationsServiceRequest request,
  ) async {
    final reason = await _askForText(
      context,
      title: 'Cancel Request',
      label: 'Reason',
    );
    if (reason == null || reason.trim().isEmpty) return;
    if (!context.mounted) return;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Cancel request?',
      message:
          'This request will be cancelled and cannot proceed to scheduling.',
      confirmLabel: 'Cancel Request',
      danger: true,
    );
    if (!confirmed) return;
    unawaited(
      repository.cancelRequest(
        id: request.id,
        reason: reason.trim(),
        notes: '',
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<String?> _askForText(
    BuildContext context, {
    required String title,
    required String label,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _openSchedule(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(
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

typedef _ApproveSubmit =
    void Function({
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
            'Approve Request',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Estimate amount'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: const [
              DropdownMenuItem(value: 'normal', child: Text('Normal')),
              DropdownMenuItem(value: 'high', child: Text('High')),
              DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
            ],
            onChanged: (value) =>
                setState(() => _priority = value ?? _priority),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Review note'),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Approve'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid estimate amount.')),
      );
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Approve request?',
      message:
          'Approve this service request with an estimated amount of $amount?',
      confirmLabel: 'Approve',
    );
    if (!confirmed || !mounted) return;
    Navigator.of(context).pop();
    widget.onSubmit(
      amount: amount,
      priority: _priority,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
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
              'Register Service Request',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _farmerIdController,
              decoration: const InputDecoration(labelText: 'Farmer ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _plotIdController,
              decoration: const InputDecoration(labelText: 'Plot ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serviceTypeIdController,
              decoration: const InputDecoration(labelText: 'Service type ID'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _acresController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Requested acres'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('Preferred date: ${formatDate(_date)}'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _window,
              decoration: const InputDecoration(labelText: 'Preferred window'),
              items: const [
                DropdownMenuItem(value: 'morning', child: Text('Morning')),
                DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
                DropdownMenuItem(value: 'full_day', child: Text('Full day')),
              ],
              onChanged: (value) => setState(() => _window = value ?? _window),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: const [
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (value) =>
                  setState(() => _priority = value ?? _priority),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Registering...' : 'Register'),
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
        acres == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all required IDs and acres.')),
      );
      return;
    }
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Register service request?',
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
            'Reject Request',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final reason in _reasons)
            InkWell(
              onTap: () => setState(() => _reason = reason),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final confirmed = await showAppConfirmationDialog(
                      context,
                      title: 'Reject request?',
                      message: 'This request will be rejected for: $_reason.',
                      confirmLabel: 'Reject',
                      danger: true,
                    );
                    if (!confirmed) return;
                    unawaited(
                      widget.repository.rejectRequest(
                        id: widget.request.id,
                        reason: _reason,
                        notes: '',
                      ),
                    );
                    navigator.pop();
                    navigator.pop();
                  },
                  child: const Text('Reject Request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
        child: const Text(
          'No plot coordinates returned for this request.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      );
    }

    final center = _center(points);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: points.length >= 3 ? 16 : 15,
      ),
      markers: {
        Marker(
          markerId: MarkerId('request-plot-${request.id}'),
          position: center,
          infoWindow: InfoWindow(
            title: request.plot.name,
            snippet: request.farmerName,
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
      zoomControlsEnabled: false,
      compassEnabled: true,
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
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.60)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
