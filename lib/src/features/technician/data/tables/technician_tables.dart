import 'package:drift/drift.dart';

import '../../../../core/data/tables/base_tables.dart';
import '../../../manager/data/tables/operations_tables.dart';

enum MaintenanceTypeDb { scheduledMaintenance, breakdown, inspection, repair }

enum RepairStatusDb { inProgress, completed }

class TechnicianProfiles extends UuidTable {
  TextColumn get userId => text()();

  TextColumn get unionId => text().nullable()();

  TextColumn get employeeNumber => text().nullable()();

  TextColumn get specialization => text().nullable()();

  TextColumn get certificationNumber => text().nullable()();
}

class MaintenanceRecords extends UuidTable {
  TextColumn get tractorId => text().references(Tractors, #id)();

  TextColumn get technicianUserId => text()();

  TextColumn get type => textEnum<MaintenanceTypeDb>()();

  TextColumn get problem => text()();

  TextColumn get workPerformed => text()();

  TextColumn get status => textEnum<RepairStatusDb>().withDefault(
    Constant(RepairStatusDb.inProgress.name),
  )();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get completedAt => dateTime().nullable()();
}

class Parts extends UuidTable {
  TextColumn get name => text()();

  TextColumn get unit => text()();

  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();

  IntColumn get reorderLevel => integer().withDefault(const Constant(0))();
}

class MaintenancePartsUsed extends UuidTable {
  TextColumn get maintenanceRecordId =>
      text().references(MaintenanceRecords, #id)();

  TextColumn get partId => text().references(Parts, #id)();

  IntColumn get quantity => integer().withDefault(const Constant(1))();
}
