import 'package:flutter/material.dart';

import '../../../manager/data/repositories/union_operations_repository.dart';
import '../../../manager/domain/entities/operations_models.dart';
import '../../data/repositories/technician_local_repository.dart';
import '../../domain/entities/technician_models.dart';
import '../widgets/technician_widgets.dart';

class LogMaintenanceScreen extends StatefulWidget {
  const LogMaintenanceScreen({
    super.key,
    required this.operationsRepository,
    required this.technicianRepository,
    required this.tractorId,
  });

  final UnionOperationsRepository operationsRepository;
  final TechnicianLocalRepository technicianRepository;
  final String tractorId;

  @override
  State<LogMaintenanceScreen> createState() => _LogMaintenanceScreenState();
}

class _LogMaintenanceScreenState extends State<LogMaintenanceScreen> {
  final _problemController = TextEditingController(text: 'Engine service');
  final _workController = TextEditingController();
  MaintenanceType _type = MaintenanceType.scheduledMaintenance;
  RepairStatus _status = RepairStatus.inProgress;
  bool _oil = true;
  bool _filter = true;
  bool _sealKit = false;

  @override
  void dispose() {
    _problemController.dispose();
    _workController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Maintenance / Repair')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TechnicianCard(
                  child: Row(
                    children: [
                      const Icon(Icons.agriculture),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.tractorId,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                TechnicianCard(
                  child: Column(
                    children: MaintenanceType.values.map((type) {
                      return _OptionRow(
                        selected: _type == type,
                        label: type.label,
                        onTap: () => setState(() => _type = type),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _problemController,
                  decoration: const InputDecoration(labelText: 'Problem'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _workController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Work performed',
                  ),
                ),
                const SizedBox(height: 14),
                TechnicianCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parts used',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _oil,
                        onChanged: (value) =>
                            setState(() => _oil = value ?? _oil),
                        title: const Text('Engine oil'),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _filter,
                        onChanged: (value) =>
                            setState(() => _filter = value ?? _filter),
                        title: const Text('Oil filter'),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _sealKit,
                        onChanged: (value) =>
                            setState(() => _sealKit = value ?? _sealKit),
                        title: const Text('Hydraulic seal kit'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TechnicianCard(
                  child: Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Start: 24 Sep - 10:30',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                TechnicianCard(
                  child: Column(
                    children: RepairStatus.values.map((status) {
                      return _OptionRow(
                        selected: _status == status,
                        label: status.label,
                        onTap: () => setState(() => _status = status),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    final parts = [
      if (_oil) 'Engine oil',
      if (_filter) 'Oil filter',
      if (_sealKit) 'Hydraulic seal kit',
    ];
    widget.technicianRepository.addRecord(
      MaintenanceRecord(
        tractorId: widget.tractorId,
        dateLabel: '24 Sep',
        type: _type,
        problem: _problemController.text.trim(),
        workPerformed: _workController.text.trim().isEmpty
            ? _type.label
            : _workController.text.trim(),
        status: _status,
        partsUsed: parts,
      ),
    );
    widget.operationsRepository.updateTractorStatus(
      tractorId: widget.tractorId,
      status: _status == RepairStatus.completed
          ? TractorStatus.available
          : TractorStatus.underMaintenance,
      note: _status == RepairStatus.completed
          ? 'Ready for dispatch'
          : _problemController.text.trim(),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Maintenance record saved')));
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
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
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
