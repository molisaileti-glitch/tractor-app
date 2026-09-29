import 'package:flutter/foundation.dart';

import '../../domain/entities/technician_models.dart';

class TechnicianLocalRepository extends ChangeNotifier {
  TechnicianLocalRepository.seeded()
    : _records = [
        const MaintenanceRecord(
          tractorId: 'TR-002',
          dateLabel: '20 Sep',
          type: MaintenanceType.scheduledMaintenance,
          problem: 'Engine oil interval reached',
          workPerformed: 'Engine oil replacement',
          status: RepairStatus.completed,
          partsUsed: ['Engine oil', 'Oil filter'],
        ),
        const MaintenanceRecord(
          tractorId: 'TR-002',
          dateLabel: '10 Aug',
          type: MaintenanceType.inspection,
          problem: 'Routine service',
          workPerformed: 'General service',
          status: RepairStatus.completed,
        ),
        const MaintenanceRecord(
          tractorId: 'TR-002',
          dateLabel: '14 May',
          type: MaintenanceType.repair,
          problem: 'Hydraulic pressure drop',
          workPerformed: 'Hydraulic repair',
          status: RepairStatus.completed,
          partsUsed: ['Hydraulic seal kit'],
        ),
      ],
      _parts = [
        const PartsItem(
          name: 'Engine oil',
          stock: 18,
          unit: 'litres',
          reorderLevel: 8,
        ),
        const PartsItem(
          name: 'Oil filter',
          stock: 4,
          unit: 'pcs',
          reorderLevel: 5,
        ),
        const PartsItem(
          name: 'Hydraulic seal kit',
          stock: 2,
          unit: 'kits',
          reorderLevel: 2,
        ),
      ];

  final List<MaintenanceRecord> _records;
  final List<PartsItem> _parts;

  List<MaintenanceRecord> get records => List.unmodifiable(_records);
  List<PartsItem> get parts => List.unmodifiable(_parts);

  List<MaintenanceRecord> recordsForTractor(String tractorId) {
    return _records.where((record) => record.tractorId == tractorId).toList();
  }

  void addRecord(MaintenanceRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }
}
