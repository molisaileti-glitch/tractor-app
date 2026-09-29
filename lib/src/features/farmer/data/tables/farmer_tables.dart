import 'package:drift/drift.dart';

import '../../../../core/data/tables/base_tables.dart';

enum SexDb { female, male }

enum IdentityDocumentTypeDb { nida, votersId, drivingLicence }

enum PlotRegistrationStatus { draft, boundaryPending, registered, rejected }

enum ServiceRequestStatus {
  draft,
  pendingApproval,
  approved,
  rejected,
  scheduled,
  inProgress,
  completedPendingConfirmation,
  confirmed,
  disputed,
  closed,
}

enum ServiceKind { ploughing, harrowing, planting }

enum DisputeStatus { open, underReview, resolved, rejected }

class Farmers extends UuidTable {
  TextColumn get firstName => text()();

  TextColumn get middleName => text().nullable()();

  TextColumn get lastName => text()();

  TextColumn get phoneNumber => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get passwordHash => text().nullable()();

  TextColumn get membershipNumber => text().nullable()();

  TextColumn get village => text().nullable()();

  TextColumn get sex => textEnum<SexDb>().nullable()();

  TextColumn get identityDocumentType =>
      textEnum<IdentityDocumentTypeDb>().nullable()();

  TextColumn get identityNumber => text().nullable()();

  DateTimeColumn get dateOfBirth => dateTime().nullable()();
}

class FarmPlots extends UuidTable {
  TextColumn get farmerId => text().references(Farmers, #id)();

  TextColumn get name => text()();

  TextColumn get locationLabel => text()();

  RealColumn get areaHectares => real()();

  TextColumn get registrationStatus => textEnum<PlotRegistrationStatus>()
      .withDefault(Constant(PlotRegistrationStatus.draft.name))();

  BoolColumn get boundaryRegistered =>
      boolean().withDefault(const Constant(false))();
}

class FarmBoundaryPoints extends UuidTable {
  TextColumn get plotId => text().references(FarmPlots, #id)();

  IntColumn get pointOrder => integer()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  TextColumn get capturedByUserId => text().nullable()();

  DateTimeColumn get capturedAt => dateTime().nullable()();
}

class ServiceRequests extends UuidTable {
  TextColumn get requestNumber => text().unique()();

  TextColumn get farmerId => text().references(Farmers, #id)();

  TextColumn get plotId => text().references(FarmPlots, #id)();

  TextColumn get serviceKind => textEnum<ServiceKind>()();

  TextColumn get status => textEnum<ServiceRequestStatus>().clientDefault(
    () => ServiceRequestStatus.pendingApproval.name,
  )();

  DateTimeColumn get preferredDate => dateTime()();

  DateTimeColumn get alternativeDate => dateTime().nullable()();

  TextColumn get farmerNotes => text().nullable()();

  TextColumn get rejectionReason => text().nullable()();

  TextColumn get rejectionNotes => text().nullable()();

  TextColumn get reviewedByUserId => text().nullable()();

  DateTimeColumn get reviewedAt => dateTime().nullable()();
}

class Disputes extends UuidTable {
  TextColumn get serviceRequestId => text().references(ServiceRequests, #id)();

  TextColumn get jobId => text().nullable()();

  TextColumn get farmerId => text().references(Farmers, #id)();

  TextColumn get reason => text()();

  TextColumn get description => text()();

  TextColumn get status => textEnum<DisputeStatus>().withDefault(
    Constant(DisputeStatus.open.name),
  )();
}
