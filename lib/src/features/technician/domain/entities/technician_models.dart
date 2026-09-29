enum MaintenanceType {
  scheduledMaintenance('Scheduled Maintenance'),
  breakdown('Breakdown'),
  inspection('Inspection'),
  repair('Repair');

  const MaintenanceType(this.label);
  final String label;
}

enum RepairStatus {
  inProgress('In Progress'),
  completed('Completed');

  const RepairStatus(this.label);
  final String label;
}

class MaintenanceRecord {
  const MaintenanceRecord({
    required this.tractorId,
    required this.dateLabel,
    required this.type,
    required this.problem,
    required this.workPerformed,
    required this.status,
    this.partsUsed = const [],
  });

  final String tractorId;
  final String dateLabel;
  final MaintenanceType type;
  final String problem;
  final String workPerformed;
  final RepairStatus status;
  final List<String> partsUsed;
}

class PartsItem {
  const PartsItem({
    required this.name,
    required this.stock,
    required this.unit,
    required this.reorderLevel,
  });

  final String name;
  final int stock;
  final String unit;
  final int reorderLevel;

  bool get needsReorder => stock <= reorderLevel;
}
