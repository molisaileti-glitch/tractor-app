import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../../../../components/components.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../farmer/presentation/widgets/farmer_formatters.dart';
import '../../data/repositories/union_operations_repository.dart';
import '../../domain/entities/operations_models.dart';
import '../widgets/operations_widgets.dart';

enum _OversightTab { overrides, exceptions }

class OperationsOversightView extends StatefulWidget {
  const OperationsOversightView({super.key, required this.repository});

  final UnionOperationsRepository repository;

  @override
  State<OperationsOversightView> createState() =>
      _OperationsOversightViewState();
}

class _OperationsOversightViewState extends State<OperationsOversightView> {
  _OversightTab _tab = _OversightTab.overrides;

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    final strings = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.oversight,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: '${strings.refresh} ${strings.oversight.toLowerCase()}',
              onPressed: repository.refreshOversightData,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(strings.oversightDescription),
        if (repository.mechanizationActionError != null) ...[
          const SizedBox(height: 14),
          _ActionError(message: repository.mechanizationActionError!),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _OversightTabButton(
                selected: _tab == _OversightTab.overrides,
                icon: Icons.rule_folder_outlined,
                label: strings.overrides,
                count: repository.overrides.length,
                onTap: () => setState(() => _tab = _OversightTab.overrides),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OversightTabButton(
                selected: _tab == _OversightTab.exceptions,
                icon: Icons.report_problem_outlined,
                label: strings.exceptions,
                count: repository.exceptions.length,
                onTap: () => setState(() => _tab = _OversightTab.exceptions),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PageTransitionSwitcher(
          duration: AppMotion.duration(context, AppMotion.standard),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
              FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: Colors.transparent,
                child: child,
              ),
          child: KeyedSubtree(
            key: ValueKey(_tab),
            child: switch (_tab) {
              _OversightTab.overrides =>
                repository.overrides.isEmpty
                    ? _OversightEmptyState(
                        icon: Icons.rule_folder_outlined,
                        message: strings.noOverridesFound,
                      )
                    : Column(
                        children: [
                          for (final item in repository.overrides) ...[
                            _OverrideCard(repository: repository, item: item),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
              _OversightTab.exceptions =>
                repository.exceptions.isEmpty
                    ? _OversightEmptyState(
                        icon: Icons.report_problem_outlined,
                        message: strings.noExceptionsFound,
                      )
                    : Column(
                        children: [
                          for (final item in repository.exceptions) ...[
                            _ExceptionCard(repository: repository, item: item),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
            },
          ),
        ),
      ],
    );
  }
}

class _OversightTabButton extends StatelessWidget {
  const _OversightTabButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$label $count',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OversightEmptyState extends StatelessWidget {
  const _OversightEmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 46,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.42),
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

class _OverrideCard extends StatelessWidget {
  const _OverrideCard({required this.repository, required this.item});

  final UnionOperationsRepository repository;
  final MechanizationOverride item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context)!;
    final isPending = item.status.toLowerCase() == 'pending';
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Icon(Icons.lock_open_outlined)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.jobId.isEmpty ? item.id : 'Job ${item.jobId}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(strings.requestedBy(item.requestedBy)),
                  ],
                ),
              ),
              _SmallStatus(label: item.status, color: theme.colorScheme.error),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.reason),
          if (item.failedChecks.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final check in item.failedChecks)
                  Chip(label: Text(check.replaceAll('_', ' '))),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _FactsLine(
            values: [
              if (item.requestedAt != null)
                strings.requestedAt(formatDateTime(item.requestedAt!)),
              if (item.expiresAt != null)
                strings.expiresAt(formatDateTime(item.expiresAt!)),
              if (item.distanceToPlotMeters != null)
                strings.metersFromPlot(item.distanceToPlotMeters!.round()),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPending
                      ? () async {
                          final note = await _promptNote(
                            context,
                            title: strings.denyOverride,
                            label: strings.decisionNote,
                            cancelLabel: strings.cancel,
                            confirmLabel: strings.submit,
                          );
                          if (note == null || note.trim().isEmpty) return;
                          if (!context.mounted) return;
                          final confirmed = await showAppConfirmationDialog(
                            context,
                            title: 'Deny override?',
                            message:
                                'The operator will not be able to use this override to start the job.',
                            confirmLabel: 'Deny',
                            danger: true,
                          );
                          if (!confirmed) return;
                          await repository.decideOverride(
                            overrideId: item.id,
                            approve: false,
                            note: note.trim(),
                          );
                          if (!context.mounted) return;
                          await _showOversightActionResult(
                            context,
                            repository,
                            successTitle: 'Override denied',
                            successMessage:
                                'The operator cannot use this override. It is now recorded under decided overrides.',
                          );
                        }
                      : null,
                  icon: const Icon(Icons.close),
                  label: Text(strings.deny),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isPending
                      ? () async {
                          final note = await _promptNote(
                            context,
                            title: strings.approveOverride,
                            label: strings.decisionNote,
                            cancelLabel: strings.cancel,
                            confirmLabel: strings.submit,
                          );
                          if (note == null || note.trim().isEmpty) return;
                          if (!context.mounted) return;
                          final confirmed = await showAppConfirmationDialog(
                            context,
                            title: 'Approve override?',
                            message:
                                'The operator may use this approval to bypass the allowed failed start checks until it expires.',
                            confirmLabel: 'Approve',
                          );
                          if (!confirmed) return;
                          await repository.decideOverride(
                            overrideId: item.id,
                            approve: true,
                            note: note.trim(),
                          );
                          if (!context.mounted) return;
                          await _showOversightActionResult(
                            context,
                            repository,
                            successTitle: 'Override approved',
                            successMessage:
                                'The operator can rerun the start check and use this override before it expires.',
                          );
                        }
                      : null,
                  icon: const Icon(Icons.check),
                  label: Text(strings.approve),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExceptionCard extends StatelessWidget {
  const _ExceptionCard({required this.repository, required this.item});

  final UnionOperationsRepository repository;
  final MechanizationException item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context)!;
    final status = item.status.toLowerCase();
    final canAcknowledge = status == 'open';
    final canResolve = status == 'open' || status == 'acknowledged';
    return OperationsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.report_problem_outlined,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _FactsLine(
                      values: [
                        item.type,
                        item.jobReference,
                        item.tractorLabel,
                        if (item.openedAt != null)
                          formatDateTime(item.openedAt!),
                      ],
                    ),
                  ],
                ),
              ),
              _SmallStatus(label: item.severity),
            ],
          ),
          if (item.detail != null) ...[
            const SizedBox(height: 10),
            Text(item.detail!),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: canAcknowledge
                      ? () async {
                          final confirmed = await showAppConfirmationDialog(
                            context,
                            title: 'Acknowledge exception?',
                            message:
                                'This records that the exception has been seen and is being handled.',
                            confirmLabel: 'Acknowledge',
                          );
                          if (confirmed) {
                            final acknowledged = await repository
                                .acknowledgeException(item.id);
                            if (!context.mounted) return;
                            showAppSnackBar(
                              context,
                              message: acknowledged
                                  ? 'Exception acknowledged. It is now marked as being handled.'
                                  : repository.mechanizationActionError ??
                                        'The exception could not be acknowledged.',
                              type: acknowledged
                                  ? AppSnackType.success
                                  : AppSnackType.error,
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(strings.acknowledge),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: canResolve
                      ? () async {
                          final note = await _promptNote(
                            context,
                            title: strings.resolveException,
                            label: strings.resolutionNote,
                            cancelLabel: strings.cancel,
                            confirmLabel: strings.submit,
                          );
                          if (note == null || note.trim().isEmpty) return;
                          if (!context.mounted) return;
                          final confirmed = await showAppConfirmationDialog(
                            context,
                            title: 'Resolve exception?',
                            message:
                                'Confirm that the issue has been handled. The resolution note will be recorded.',
                            confirmLabel: 'Resolve',
                          );
                          if (!confirmed) return;
                          await repository.resolveException(
                            exceptionId: item.id,
                            remarks: note.trim(),
                          );
                          if (!context.mounted) return;
                          await _showOversightActionResult(
                            context,
                            repository,
                            successTitle: 'Exception resolved',
                            successMessage:
                                'The resolution has been recorded and the item is no longer an open exception.',
                          );
                        }
                      : null,
                  icon: const Icon(Icons.done_all),
                  label: Text(strings.resolve),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showOversightActionResult(
  BuildContext context,
  UnionOperationsRepository repository, {
  required String successTitle,
  required String successMessage,
}) async {
  final error = repository.mechanizationActionError;
  if (error != null) {
    await showAppErrorDialog(
      context,
      title: AppLocalizations.of(context)!.actionNotCompleted,
      message: error,
    );
    return;
  }
  await showAppSuccessDialog(
    context,
    title: successTitle,
    message: successMessage,
  );
}

Future<String?> _promptNote(
  BuildContext context, {
  required String title,
  required String label,
  String? cancelLabel,
  String? confirmLabel,
}) {
  return showAppTextInputDialog(
    context,
    title: title,
    label: label,
    cancelLabel: cancelLabel ?? 'Cancel',
    confirmLabel: confirmLabel ?? 'Submit',
  );
}

class _ActionError extends StatelessWidget {
  const _ActionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return OperationsCard(
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactsLine extends StatelessWidget {
  const _FactsLine({required this.values});

  final List<String?> values;

  @override
  Widget build(BuildContext context) {
    final visible = values
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Text(
      visible.join(' - '),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SmallStatus extends StatelessWidget {
  const _SmallStatus({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final statusColor = color ?? _statusColor(context, label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900),
      ),
    );
  }

  Color _statusColor(BuildContext context, String value) {
    final normalized = value.trim().toLowerCase();
    final scheme = Theme.of(context).colorScheme;
    return switch (normalized) {
      'critical' || 'error' || 'failed' || 'denied' => scheme.error,
      'warning' || 'acknowledged' => AppColors.warning,
      'resolved' || 'approved' => AppColors.adaptiveSuccess(context),
      _ => scheme.primary,
    };
  }
}
