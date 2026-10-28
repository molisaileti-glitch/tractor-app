import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/operator_local_repository.dart';
import '../../domain/entities/operator_job.dart';

Future<bool?> showOperatorFarmerConfirmationSheet(
  BuildContext context, {
  required OperatorLocalRepository repository,
  required String jobId,
}) {
  final job = repository.maybeJobById(jobId);
  if (job == null) return Future<bool?>.value(false);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _FarmerConfirmationSheet(repository: repository, job: job),
  );
}

class _FarmerConfirmationSheet extends StatefulWidget {
  const _FarmerConfirmationSheet({required this.repository, required this.job});

  final OperatorLocalRepository repository;
  final OperatorJob job;

  @override
  State<_FarmerConfirmationSheet> createState() =>
      _FarmerConfirmationSheetState();
}

class _FarmerConfirmationSheetState extends State<_FarmerConfirmationSheet> {
  final _credential = TextEditingController();
  final _note = TextEditingController();
  String _method = 'pin';
  int _step = 0;
  int? _rating;
  bool _dispute = false;
  bool _busy = false;
  String? _message;

  bool get _credentialIsValid => RegExp(
    _method == 'pin' ? r'^\d{4}$' : r'^\d{6}$',
  ).hasMatch(_credential.text.trim());

  @override
  void dispose() {
    _credential.clear();
    _credential.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final sent = await widget.repository.sendFarmerOtp(widget.job.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = sent
          ? 'Code sent to the farmer. It expires in 10 minutes.'
          : widget.repository.lastActionError ?? 'The code could not be sent.';
    });
  }

  void _continueToRating() {
    if (!_credentialIsValid) {
      setState(() {
        _message = _method == 'pin'
            ? 'Enter the farmer’s four-digit PIN.'
            : 'Enter the six-digit code sent to the farmer.';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _step = 1;
      _message = null;
    });
  }

  Future<void> _submit({required bool includeRating}) async {
    if (_busy || !_credentialIsValid) return;
    if (_dispute && _note.text.trim().isEmpty) {
      setState(() => _message = 'Describe the problem before submitting it.');
      return;
    }
    if (!_dispute && includeRating && _rating == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final confirmed = await widget.repository.confirmFarmerService(
      jobId: widget.job.id,
      method: _method,
      credential: _credential.text.trim(),
      rating: includeRating && !_dispute ? _rating : null,
      dispute: _dispute,
      note: _note.text.trim(),
    );
    if (!mounted) return;
    if (confirmed) {
      _credential.clear();
      Navigator.of(context).pop(true);
      return;
    }
    _credential.clear();
    setState(() {
      _busy = false;
      _step = 0;
      _message =
          widget.repository.lastActionError ??
          'Confirmation failed. Enter the farmer credential and try again.';
    });
  }

  void _close() {
    if (!_busy) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return PopScope(
      canPop: !_busy,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
          child: SingleChildScrollView(
            key: const ValueKey('farmer-confirmation-sheet'),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _step == 0 ? _buildCredentialStep() : _buildRatingStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialStep() {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('farmer-confirmation-step-credential'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHandle(),
        _SheetHeader(
          title: 'Farmer confirmation',
          subtitle: 'Step 1 of 2',
          onClose: _busy ? null : _close,
        ),
        const SizedBox(height: 8),
        _JobContext(job: widget.job),
        const SizedBox(height: 18),
        Text(
          'Give the phone to the farmer',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'The farmer should enter their own PIN or SMS code. The credential is submitted only after the next step.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        SegmentedButton<String>(
          key: ValueKey('confirmation-method-$_method'),
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
        if (_method == 'pin' && !widget.job.farmerHasPin) ...[
          const SizedBox(height: 12),
          const _InlineNotice(
            icon: Icons.info_outline,
            text:
                'PIN status is still updating. Enter the PIN configured in the portal or use an SMS code.',
          ),
        ],
        if (_method == 'otp') ...[
          const SizedBox(height: 14),
          OutlinedButton.icon(
            key: const ValueKey('send-farmer-otp'),
            onPressed: _busy ? null : _sendOtp,
            icon: const Icon(Icons.send_outlined),
            label: const Text('Send code to farmer'),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('farmer-credential'),
          controller: _credential,
          enabled: !_busy,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.number,
          maxLength: _method == 'pin' ? 4 : 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _message = null),
          decoration: InputDecoration(
            prefixIcon: Icon(
              _method == 'pin' ? Icons.lock_outline : Icons.sms_outlined,
            ),
            labelText: _method == 'pin'
                ? 'Farmer four-digit PIN'
                : 'Farmer six-digit SMS code',
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 10),
          _InlineNotice(
            key: const ValueKey('farmer-confirmation-message'),
            icon: Icons.info_outline,
            text: _message!,
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _busy ? null : _close,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const ValueKey('farmer-confirmation-continue'),
                onPressed: _busy || !_credentialIsValid
                    ? null
                    : _continueToRating,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingStep() {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('farmer-confirmation-step-rating'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SheetHandle(),
        _SheetHeader(
          title: 'How was the tractor service?',
          subtitle: 'Step 2 of 2',
          onBack: _busy
              ? null
              : () => setState(() {
                  _step = 0;
                  _message = null;
                }),
          onClose: _busy ? null : _close,
        ),
        const SizedBox(height: 10),
        Text(
          'Your feedback helps the union improve mechanization services.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        _RatingStars(
          rating: _rating,
          enabled: !_busy && !_dispute,
          onSelected: (rating) => setState(() {
            _rating = rating;
            _dispute = false;
            _message = null;
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _ratingLabel(_rating),
          key: const ValueKey('farmer-rating-label'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: _rating == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 22),
        _DisputeChoice(
          selected: _dispute,
          enabled: !_busy,
          onChanged: (value) => setState(() {
            _dispute = value;
            if (value) _rating = null;
            _message = null;
          }),
        ),
        if (_dispute) ...[
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('farmer-dispute-note'),
            controller: _note,
            enabled: !_busy,
            minLines: 3,
            maxLines: 5,
            onChanged: (_) => setState(() => _message = null),
            decoration: const InputDecoration(
              labelText: 'Describe the problem',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.report_problem_outlined),
            ),
          ),
        ],
        if (_message != null) ...[
          const SizedBox(height: 10),
          _InlineNotice(
            key: const ValueKey('farmer-confirmation-message'),
            icon: Icons.error_outline,
            text: _message!,
            error: true,
          ),
        ],
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const ValueKey('farmer-rating-skip'),
                onPressed: _busy
                    ? null
                    : _dispute
                    ? () => setState(() {
                        _step = 0;
                        _message = null;
                      })
                    : () => _submit(includeRating: false),
                child: Text(_dispute ? 'Back' : 'Skip rating'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                key: const ValueKey('farmer-rating-submit'),
                onPressed:
                    _busy ||
                        (_dispute ? _note.text.trim().isEmpty : _rating == null)
                    ? null
                    : () => _submit(includeRating: true),
                child: _busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_dispute ? 'Submit problem' : 'Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(999),
      ),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.subtitle,
    required this.onClose,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onClose;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: 48,
          child: onBack == null
              ? null
              : IconButton(
                  key: const ValueKey('farmer-confirmation-back'),
                  onPressed: onBack,
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back),
                ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox.square(
          dimension: 48,
          child: IconButton.filledTonal(
            key: const ValueKey('farmer-confirmation-close'),
            onPressed: onClose,
            tooltip: 'Close',
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _JobContext extends StatelessWidget {
  const _JobContext({required this.job});

  final OperatorJob job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.agriculture_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${job.reference ?? job.id} • ${job.farmerName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({
    required this.rating,
    required this.enabled,
    required this.onSelected,
  });

  final int? rating;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var value = 1; value <= 5; value++)
          Semantics(
            button: true,
            selected: rating == value,
            label: '$value ${value == 1 ? 'star' : 'stars'}',
            child: IconButton(
              key: ValueKey('farmer-rating-star-$value'),
              onPressed: enabled ? () => onSelected(value) : null,
              iconSize: 38,
              color: color,
              disabledColor: color.withValues(alpha: 0.35),
              icon: Icon(
                rating != null && value <= rating!
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
              ),
            ),
          ),
      ],
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    super.key,
    required this.icon,
    required this.text,
    this.error = false,
  });

  final IconData icon;
  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = error ? theme.colorScheme.error : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        title: const Text('Report a service problem'),
        subtitle: const Text('The union manager will review the issue.'),
        onChanged: enabled ? (value) => onChanged(value ?? false) : null,
      ),
    );
  }
}

String _ratingLabel(int? rating) => switch (rating) {
  1 => 'Poor',
  2 => 'Fair',
  3 => 'Good',
  4 => 'Very good',
  5 => 'Excellent',
  _ => 'Select a rating or skip',
};
