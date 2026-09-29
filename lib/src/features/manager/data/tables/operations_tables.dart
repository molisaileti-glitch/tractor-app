import 'package:drift/drift.dart';

import '../../../../core/data/tables/base_tables.dart';
import '../../../farmer/data/tables/farmer_tables.dart';

enum TractorAvailabilityStatus {
  available,
  scheduled,
  underMaintenance,
  outOfService,
}

enum OperatorAvailabilityStatus { available, assigned, unavailable }

enum JobStatusDb {
  scheduled,
  dispatched,
  enRoute,
  arrived,
  inProgress,
  completedPendingConfirmation,
  closed,
  disputed,
}

class Tractors extends UuidTable {
  TextColumn get code => text().unique()();

  TextColumn get model => text()();

  TextColumn get status => textEnum<TractorAvailabilityStatus>().withDefault(
    Constant(TractorAvailabilityStatus.available.name),
  )();

  IntColumn get operatingHours => integer().withDefault(const Constant(0))();

  IntColumn get nextServiceHours => integer().nullable()();

  DateTimeColumn get lastServiceAt => dateTime().nullable()();

  TextColumn get statusNote => text().nullable()();
}

class Operators extends UuidTable {
  TextColumn get userId => text()();

  TextColumn get unionId => text().nullable()();

  TextColumn get licenseNumber => text().nullable()();

  TextColumn get status => textEnum<OperatorAvailabilityStatus>().withDefault(
    Constant(OperatorAvailabilityStatus.available.name),
  )();

  TextColumn get assignedTractorId =>
      text().nullable().references(Tractors, #id)();

  TextColumn get note => text().nullable()();
}

class ManagerProfiles extends UuidTable {
  TextColumn get userId => text()();

  TextColumn get unionId => text().nullable()();

  TextColumn get employeeNumber => text().nullable()();

  TextColumn get positionTitle => text().nullable()();

  TextColumn get department => text().nullable()();
}

class DispatcherProfiles extends UuidTable {
  TextColumn get userId => text()();

  TextColumn get unionId => text().nullable()();

  TextColumn get employeeNumber => text().nullable()();

  TextColumn get dispatchZone => text().nullable()();

  TextColumn get radioCallSign => text().nullable()();
}

class Jobs extends UuidTable {
  TextColumn get jobNumber => text().unique()();

  TextColumn get serviceRequestId => text().references(ServiceRequests, #id)();

  TextColumn get farmerId => text().references(Farmers, #id)();

  TextColumn get plotId => text().references(FarmPlots, #id)();

  TextColumn get tractorId => text().references(Tractors, #id)();

  TextColumn get operatorId => text().references(Operators, #id)();

  TextColumn get serviceKind => textEnum<ServiceKind>()();

  TextColumn get status => textEnum<JobStatusDb>().withDefault(
    Constant(JobStatusDb.scheduled.name),
  )();

  DateTimeColumn get scheduledAt => dateTime()();

  IntColumn get estimatedDurationMinutes => integer()();

  DateTimeColumn get dispatchedAt => dateTime().nullable()();

  DateTimeColumn get journeyStartedAt => dateTime().nullable()();

  DateTimeColumn get arrivedAt => dateTime().nullable()();

  DateTimeColumn get startedAt => dateTime().nullable()();

  DateTimeColumn get finishedAt => dateTime().nullable()();

  RealColumn get areaServicedHectares => real().nullable()();

  TextColumn get completionNotes => text().nullable()();
}

class JobTrackingPoints extends UuidTable {
  TextColumn get jobId => text().references(Jobs, #id)();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  RealColumn get accuracyMeters => real().nullable()();

  DateTimeColumn get recordedAt => dateTime()();

  BoolColumn get insideAssignedPlot =>
      boolean().withDefault(const Constant(false))();
}

class JobNotes extends UuidTable {
  TextColumn get jobId => text().references(Jobs, #id)();

  TextColumn get authorUserId => text()();

  TextColumn get note => text()();
}
