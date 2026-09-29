import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../../domain/entities/farm_plot.dart';
import '../../domain/entities/service_request.dart';
import '../widgets/farmer_formatters.dart';
import '../widgets/farmer_scaffold.dart';
import 'request_details_screen.dart';

class RequestServiceFlow extends StatefulWidget {
  const RequestServiceFlow({
    super.key,
    required this.repository,
    this.initialPlotId,
  });

  final FarmerLocalRepository repository;
  final String? initialPlotId;

  @override
  State<RequestServiceFlow> createState() => _RequestServiceFlowState();
}

class _RequestServiceFlowState extends State<RequestServiceFlow> {
  final _notesController = TextEditingController();
  int _step = 0;
  String? _plotId;
  ServiceType? _serviceType;
  DateTime _preferredDate = DateTime(2026, 9, 28);
  DateTime _alternativeDate = DateTime(2026, 9, 29);
  String? _submittedRequestId;

  @override
  void initState() {
    super.initState();
    _plotId = widget.initialPlotId;
    if (_plotId != null) _step = 1;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedRequestId != null) return _successView();

    return FarmerPage(
      title: 'Request Tractor Service',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepIndicator(step: _step),
          const SizedBox(height: 22),
          if (_step == 0) _plotStep(),
          if (_step == 1) _serviceStep(),
          if (_step == 2) _dateStep(),
          if (_step == 3) _reviewStep(),
        ],
      ),
    );
  }

  Widget _plotStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Question('Which farm needs service?'),
        const SizedBox(height: 12),
        for (final plot in widget.repository.plots) ...[
          _PlotOption(
            plot: plot,
            selected: _plotId == plot.id,
            onTap: () => setState(() => _plotId = plot.id),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _plotId == null ? null : () => setState(() => _step = 1),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _serviceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Question('What service do you need?'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ServiceType.values.map((type) {
            return _ServiceOption(
              type: type,
              selected: _serviceType == type,
              onTap: () => setState(() => _serviceType = type),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _serviceType == null
              ? null
              : () => setState(() => _step = 2),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _dateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Question('When would you prefer the service?'),
        const SizedBox(height: 12),
        _DateTile(
          label: 'Preferred Date',
          value: formatDate(_preferredDate),
          onTap: () => _pickDate(isPreferred: true),
        ),
        const SizedBox(height: 12),
        _DateTile(
          label: 'Alternative Date',
          value: formatDate(_alternativeDate),
          onTap: () => _pickDate(isPreferred: false),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Notes (optional)'),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => setState(() => _step = 3),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final plot = widget.repository.plotById(_plotId!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Question('Review Request'),
        const SizedBox(height: 12),
        InfoCard(
          child: Column(
            children: [
              _ReviewRow(label: 'Service', value: _serviceType!.label),
              _ReviewRow(label: 'Plot', value: plot.name),
              _ReviewRow(
                label: 'Area',
                value: '${plot.areaHectares.toStringAsFixed(1)} hectares',
              ),
              _ReviewRow(
                label: 'Preferred Date',
                value: formatDate(_preferredDate),
              ),
              const _ReviewRow(label: 'Location', value: 'Registered plot'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit Request'),
        ),
      ],
    );
  }

  Widget _successView() {
    final requestId = _submittedRequestId!;
    return FarmerPage(
      title: 'Request submitted',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.check, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 18),
          Text(
            'Request submitted',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text('Your union will review your request.'),
          const SizedBox(height: 18),
          InfoCard(
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Request #$requestId',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => RequestDetailsScreen(
                  repository: widget.repository,
                  requestId: requestId,
                ),
              ),
            ),
            child: const Text('View Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isPreferred}) async {
    final initial = isPreferred ? _preferredDate : _alternativeDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2026, 9, 24),
      lastDate: DateTime(2027, 12, 31),
    );
    if (selected == null) return;
    setState(() {
      if (isPreferred) {
        _preferredDate = selected;
      } else {
        _alternativeDate = selected;
      }
    });
  }

  void _submit() {
    final requestId = widget.repository.submitRequest(
      plotId: _plotId!,
      serviceType: _serviceType!,
      preferredDate: _preferredDate,
      alternativeDate: _alternativeDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    setState(() => _submittedRequestId = requestId);
  }
}

class _Question extends StatelessWidget {
  const _Question(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _PlotOption extends StatelessWidget {
  const _PlotOption({
    required this.plot,
    required this.selected,
    required this.onTap,
  });

  final FarmPlot plot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
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
                  plot.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('${plot.areaHectares.toStringAsFixed(1)} hectares'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ServiceType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Colors.black.withValues(alpha: 0.12);
    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, size: 34),
              const SizedBox(height: 18),
              Text(
                type.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (type) {
      ServiceType.ploughing => Icons.agriculture,
      ServiceType.harrowing => Icons.grass,
      ServiceType.planting => Icons.spa,
    };
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.calendar_month_outlined),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final active = index <= step;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black.withValues(alpha: 0.12),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (index < 3)
                Expanded(
                  child: Container(
                    height: 3,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black.withValues(alpha: 0.10),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
