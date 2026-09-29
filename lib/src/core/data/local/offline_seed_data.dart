import 'package:drift/drift.dart';

import 'app_database.dart';

class OfflineSeedIds {
  const OfflineSeedIds._();

  static const farmerJuma = '33333333-3333-4333-8333-333333333301';
  static const farmerAnna = '33333333-3333-4333-8333-333333333302';
  static const farmerMusa = '33333333-3333-4333-8333-333333333303';

  static const plotKibaha = '44444444-4444-4444-8444-444444444401';
  static const plotMlandizi = '44444444-4444-4444-8444-444444444402';
  static const plotBagamoyo = '44444444-4444-4444-8444-444444444403';

  static const tractor001 = '55555555-5555-4555-8555-555555555501';
  static const tractor002 = '55555555-5555-4555-8555-555555555502';
  static const tractor003 = '55555555-5555-4555-8555-555555555503';
  static const tractor004 = '55555555-5555-4555-8555-555555555504';

  static const operatorJohn = '66666666-6666-4666-8666-666666666601';
  static const operatorPeter = '66666666-6666-4666-8666-666666666602';

  static const request1024 = '77777777-7777-4777-8777-777777777701';
  static const request1025 = '77777777-7777-4777-8777-777777777702';
  static const request1026 = '77777777-7777-4777-8777-777777777703';

  static const job201 = '88888888-8888-4888-8888-888888888801';
  static const job202 = '88888888-8888-4888-8888-888888888802';

  static const technicianProfile = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1';
  static const partEngineOil = '99999999-9999-4999-8999-999999999901';
  static const partOilFilter = '99999999-9999-4999-8999-999999999902';
  static const partHydraulicSeal = '99999999-9999-4999-8999-999999999903';
}

class OfflineBootstrapper {
  const OfflineBootstrapper(this.db);

  final AppDatabase db;

  Future<void> seedDemoDataIfEmpty() async {
    final existingFarmers = await db.select(db.farmers).get();
    if (existingFarmers.isNotEmpty) return;

    await db.transaction(() async {
      await _insertFarmers();
      await _insertPlots();
      await _insertTractorsAndOperators();
      await _insertRequestsAndJobs();
      await _insertMaintenanceAndParts();
    });
  }

  Future<void> _insertFarmers() async {
    await db.batch((batch) {
      batch.insertAll(db.farmers, [
        _farmer(
          OfflineSeedIds.farmerJuma,
          firstName: 'Juma',
          lastName: 'Ally',
          village: 'Kibaha',
          identityNumber: '19900101-00001',
        ),
        _farmer(
          OfflineSeedIds.farmerAnna,
          firstName: 'Anna',
          lastName: 'John',
          village: 'Mlandizi',
          identityNumber: '19920304-00002',
        ),
        _farmer(
          OfflineSeedIds.farmerMusa,
          firstName: 'Musa',
          lastName: 'Said',
          village: 'Bagamoyo',
          identityNumber: '19880412-00003',
        ),
      ]);
    });
  }

  FarmersCompanion _farmer(
    String id, {
    required String firstName,
    required String lastName,
    required String village,
    required String identityNumber,
  }) {
    return FarmersCompanion.insert(
      id: Value(id),
      firstName: firstName,
      lastName: lastName,
      village: Value(village),
      sex: const Value(SexDb.male),
      identityDocumentType: const Value(IdentityDocumentTypeDb.nida),
      identityNumber: Value(identityNumber),
      dateOfBirth: Value(DateTime(1990, 1, 1)),
    );
  }

  Future<void> _insertPlots() async {
    await db.batch((batch) {
      batch.insertAll(db.farmPlots, [
        _plot(
          OfflineSeedIds.plotKibaha,
          OfflineSeedIds.farmerJuma,
          'Kibaha Farm',
          'Kibaha, Pwani',
          4.2,
        ),
        _plot(
          OfflineSeedIds.plotMlandizi,
          OfflineSeedIds.farmerAnna,
          'Mlandizi Farm',
          'Mlandizi',
          2.8,
        ),
        _plot(
          OfflineSeedIds.plotBagamoyo,
          OfflineSeedIds.farmerMusa,
          'Bagamoyo Farm',
          'Bagamoyo',
          6.1,
        ),
      ]);
      batch.insertAll(db.farmBoundaryPoints, [
        ..._boundary(OfflineSeedIds.plotKibaha, -6.8001, 38.9112),
        ..._boundary(OfflineSeedIds.plotMlandizi, -6.7291, 38.7420),
        ..._boundary(OfflineSeedIds.plotBagamoyo, -6.4301, 38.9044),
      ]);
    });
  }

  FarmPlotsCompanion _plot(
    String id,
    String farmerId,
    String name,
    String location,
    double area,
  ) {
    return FarmPlotsCompanion.insert(
      id: Value(id),
      farmerId: farmerId,
      name: name,
      locationLabel: location,
      areaHectares: area,
      registrationStatus: const Value(PlotRegistrationStatus.registered),
      boundaryRegistered: const Value(true),
    );
  }

  List<FarmBoundaryPointsCompanion> _boundary(
    String plotId,
    double latitude,
    double longitude,
  ) {
    return List.generate(4, (index) {
      return FarmBoundaryPointsCompanion.insert(
        plotId: plotId,
        pointOrder: index + 1,
        latitude: latitude - (index * 0.002),
        longitude: longitude + (index * 0.003),
        capturedAt: Value(DateTime(2026, 9, 24, 9 + index)),
      );
    });
  }

  Future<void> _insertTractorsAndOperators() async {
    await db.batch((batch) {
      batch.insertAll(db.tractors, [
        _tractor(
          OfflineSeedIds.tractor001,
          'TR-001',
          'Massey Ferguson',
          TractorAvailabilityStatus.available,
          1230,
        ),
        _tractor(
          OfflineSeedIds.tractor002,
          'TR-002',
          'John Deere 5075E',
          TractorAvailabilityStatus.underMaintenance,
          1845,
          note: 'Engine service',
        ),
        _tractor(
          OfflineSeedIds.tractor003,
          'TR-003',
          'New Holland',
          TractorAvailabilityStatus.scheduled,
          990,
          note: 'Scheduled 08:00-11:00',
        ),
        _tractor(
          OfflineSeedIds.tractor004,
          'TR-004',
          'Kubota M7040',
          TractorAvailabilityStatus.available,
          740,
        ),
      ]);
      batch.insertAll(db.operators, [
        OperatorsCompanion.insert(
          id: const Value(OfflineSeedIds.operatorJohn),
          userId: 'backend-operator-john',
          status: const Value(OperatorAvailabilityStatus.available),
          assignedTractorId: const Value(OfflineSeedIds.tractor001),
        ),
        OperatorsCompanion.insert(
          id: const Value(OfflineSeedIds.operatorPeter),
          userId: 'backend-operator-peter',
          status: const Value(OperatorAvailabilityStatus.assigned),
          assignedTractorId: const Value(OfflineSeedIds.tractor003),
          note: const Value('Assigned until 11:00'),
        ),
      ]);
    });
  }

  TractorsCompanion _tractor(
    String id,
    String code,
    String model,
    TractorAvailabilityStatus status,
    int hours, {
    String? note,
  }) {
    return TractorsCompanion.insert(
      id: Value(id),
      code: code,
      model: model,
      status: Value(status),
      operatingHours: Value(hours),
      nextServiceHours: const Value(2000),
      lastServiceAt: Value(DateTime(2026, 8, 10)),
      statusNote: Value(note),
    );
  }

  Future<void> _insertRequestsAndJobs() async {
    await db.batch((batch) {
      batch.insertAll(db.serviceRequests, [
        ServiceRequestsCompanion.insert(
          id: const Value(OfflineSeedIds.request1024),
          requestNumber: 'SR-1024',
          farmerId: OfflineSeedIds.farmerJuma,
          plotId: OfflineSeedIds.plotKibaha,
          serviceKind: ServiceKind.ploughing,
          status: const Value(ServiceRequestStatus.approved),
          preferredDate: DateTime(2026, 9, 28),
          alternativeDate: Value(DateTime(2026, 9, 29)),
          farmerNotes: const Value('Please start from the eastern side.'),
        ),
        ServiceRequestsCompanion.insert(
          id: const Value(OfflineSeedIds.request1025),
          requestNumber: 'SR-1025',
          farmerId: OfflineSeedIds.farmerAnna,
          plotId: OfflineSeedIds.plotMlandizi,
          serviceKind: ServiceKind.harrowing,
          preferredDate: DateTime(2026, 9, 28),
        ),
        ServiceRequestsCompanion.insert(
          id: const Value(OfflineSeedIds.request1026),
          requestNumber: 'SR-1026',
          farmerId: OfflineSeedIds.farmerMusa,
          plotId: OfflineSeedIds.plotBagamoyo,
          serviceKind: ServiceKind.ploughing,
          preferredDate: DateTime(2026, 9, 29),
        ),
      ]);
      batch.insertAll(db.jobs, [
        JobsCompanion.insert(
          id: const Value(OfflineSeedIds.job201),
          jobNumber: 'JOB-201',
          serviceRequestId: OfflineSeedIds.request1024,
          farmerId: OfflineSeedIds.farmerJuma,
          plotId: OfflineSeedIds.plotKibaha,
          tractorId: OfflineSeedIds.tractor001,
          operatorId: OfflineSeedIds.operatorJohn,
          serviceKind: ServiceKind.ploughing,
          status: const Value(JobStatusDb.dispatched),
          scheduledAt: DateTime(2026, 9, 28, 8),
          estimatedDurationMinutes: 240,
          dispatchedAt: Value(DateTime(2026, 9, 28, 8, 2)),
        ),
        JobsCompanion.insert(
          id: const Value(OfflineSeedIds.job202),
          jobNumber: 'JOB-202',
          serviceRequestId: OfflineSeedIds.request1025,
          farmerId: OfflineSeedIds.farmerAnna,
          plotId: OfflineSeedIds.plotMlandizi,
          tractorId: OfflineSeedIds.tractor003,
          operatorId: OfflineSeedIds.operatorPeter,
          serviceKind: ServiceKind.harrowing,
          scheduledAt: DateTime(2026, 9, 28, 10),
          estimatedDurationMinutes: 180,
        ),
      ]);
    });
  }

  Future<void> _insertMaintenanceAndParts() async {
    await db.batch((batch) {
      batch.insert(
        db.technicianProfiles,
        TechnicianProfilesCompanion.insert(
          id: const Value(OfflineSeedIds.technicianProfile),
          userId: 'backend-technician',
          employeeNumber: const Value('TECH-001'),
          specialization: const Value('Tractor maintenance'),
        ),
      );
      batch.insertAll(db.parts, [
        PartsCompanion.insert(
          id: const Value(OfflineSeedIds.partEngineOil),
          name: 'Engine oil',
          unit: 'litres',
          stockQuantity: const Value(18),
          reorderLevel: const Value(8),
        ),
        PartsCompanion.insert(
          id: const Value(OfflineSeedIds.partOilFilter),
          name: 'Oil filter',
          unit: 'pcs',
          stockQuantity: const Value(4),
          reorderLevel: const Value(5),
        ),
        PartsCompanion.insert(
          id: const Value(OfflineSeedIds.partHydraulicSeal),
          name: 'Hydraulic seal kit',
          unit: 'kits',
          stockQuantity: const Value(2),
          reorderLevel: const Value(2),
        ),
      ]);
      batch.insert(
        db.maintenanceRecords,
        MaintenanceRecordsCompanion.insert(
          tractorId: OfflineSeedIds.tractor002,
          technicianUserId: 'backend-technician',
          type: MaintenanceTypeDb.scheduledMaintenance,
          problem: 'Engine oil interval reached',
          workPerformed: 'Engine oil replacement',
          status: const Value(RepairStatusDb.completed),
          startedAt: DateTime(2026, 9, 20, 10),
          completedAt: Value(DateTime(2026, 9, 20, 12)),
        ),
      );
    });
  }
}
