import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../tables/app_tables.dart';

export '../tables/app_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Farmers,
    FarmPlots,
    FarmBoundaryPoints,
    ServiceRequests,
    Tractors,
    Operators,
    ManagerProfiles,
    DispatcherProfiles,
    TechnicianProfiles,
    Jobs,
    JobTrackingPoints,
    JobNotes,
    Disputes,
    MaintenanceRecords,
    Parts,
    MaintenancePartsUsed,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) async {
        await _resetPrototypeDatabase(this);
        await migrator.createAll();
      },
    );
  }
}

Future<void> _resetPrototypeDatabase(AppDatabase db) async {
  const tables = [
    'maintenance_parts_used',
    'maintenance_records',
    'parts',
    'job_notes',
    'job_tracking_points',
    'jobs',
    'technician_profiles',
    'dispatcher_profiles',
    'manager_profiles',
    'operators',
    'tractors',
    'disputes',
    'service_requests',
    'farm_boundary_points',
    'farm_plots',
    'farmers',
    'sync_outbox',
    'attachments',
    'app_users',
    'unions',
  ];
  for (final table in tables) {
    await db.customStatement('DROP TABLE IF EXISTS $table');
  }
}

DatabaseConnection _openConnection() {
  return driftDatabase(
    name: 'shamba_bora_offline',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
