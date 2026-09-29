import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../farmer/domain/entities/farm_plot.dart';
import '../../../farmer/domain/entities/service_request.dart';
import '../../domain/entities/operator_job.dart';

class OperatorLocalRepository extends ChangeNotifier {
  OperatorLocalRepository.seeded()
    : _jobs = [
        OperatorJob(
          id: 'JOB-201',
          farmerName: 'Juma Ally',
          serviceType: ServiceType.ploughing,
          plot: _kibahaPlot,
          tractorId: 'TR-001',
          scheduledAt: DateTime(2026, 9, 28, 8),
          status: OperatorJobStatus.scheduled,
        ),
        OperatorJob(
          id: 'JOB-198',
          farmerName: 'Anna John',
          serviceType: ServiceType.harrowing,
          plot: _mlandiziPlot,
          tractorId: 'TR-003',
          scheduledAt: DateTime(2026, 9, 24, 10),
          status: OperatorJobStatus.completedPendingConfirmation,
          journeyStartedAt: DateTime(2026, 9, 24, 8, 30),
          startedAt: DateTime(2026, 9, 24, 9, 4),
          finishedAt: DateTime(2026, 9, 24, 12, 36),
          areaServicedHectares: 2.7,
          completionNotes: 'Completed harrowing on the registered plot.',
        ),
      ];

  final List<OperatorJob> _jobs;

  List<OperatorJob> get jobs => List.unmodifiable(_jobs);

  OperatorJob get todayJob {
    return _jobs.firstWhere((job) => !job.isComplete);
  }

  List<OperatorJob> get history {
    return _jobs.where((job) => job.isComplete).toList(growable: false);
  }

  OperatorJob jobById(String id) {
    return _jobs.firstWhere((job) => job.id == id);
  }

  void startJourney(String jobId) {
    _replace(
      jobId,
      jobById(jobId).copyWith(
        status: OperatorJobStatus.enRoute,
        journeyStartedAt: DateTime(2026, 9, 28, 8, 12),
      ),
    );
  }

  void startJob(String jobId) {
    _replace(
      jobId,
      jobById(jobId).copyWith(
        status: OperatorJobStatus.inProgress,
        startedAt: DateTime(2026, 9, 28, 9, 4),
      ),
    );
  }

  void completeJob({
    required String jobId,
    required double areaServicedHectares,
    required String notes,
  }) {
    _replace(
      jobId,
      jobById(jobId).copyWith(
        status: OperatorJobStatus.completedPendingConfirmation,
        finishedAt: DateTime(2026, 9, 28, 12, 36),
        areaServicedHectares: areaServicedHectares,
        completionNotes: notes,
      ),
    );
  }

  void reportProblem({
    required String jobId,
    required OperatorProblemReason reason,
    required String notes,
  }) {
    final job = jobById(jobId);
    _replace(
      jobId,
      job.copyWith(
        problemReports: [
          ...job.problemReports,
          OperatorProblemReport(
            id: const Uuid().v4(),
            reason: reason,
            notes: notes,
            reportedAt: DateTime(2026, 9, 28, 8, 42),
          ),
        ],
      ),
    );
  }

  void _replace(String jobId, OperatorJob updated) {
    final index = _jobs.indexWhere((job) => job.id == jobId);
    if (index == -1) return;
    _jobs[index] = updated;
    notifyListeners();
  }
}

const _kibahaPlot = FarmPlot(
  id: 'plot-kibaha',
  name: 'Kibaha Farm',
  areaHectares: 4.2,
  location: 'Kibaha, Pwani',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'North west', latitude: -6.8001, longitude: 38.9112),
    BoundaryPoint(label: 'North east', latitude: -6.7998, longitude: 38.9189),
    BoundaryPoint(label: 'South east', latitude: -6.8063, longitude: 38.9201),
    BoundaryPoint(label: 'South west', latitude: -6.8071, longitude: 38.9120),
  ],
);

const _mlandiziPlot = FarmPlot(
  id: 'plot-mlandizi',
  name: 'Mlandizi Farm',
  areaHectares: 2.8,
  location: 'Mlandizi',
  boundaryRegistered: true,
  boundaryPoints: [
    BoundaryPoint(label: 'North west', latitude: -6.7291, longitude: 38.7420),
    BoundaryPoint(label: 'North east', latitude: -6.7287, longitude: 38.7488),
    BoundaryPoint(label: 'South east', latitude: -6.7336, longitude: 38.7494),
    BoundaryPoint(label: 'South west', latitude: -6.7341, longitude: 38.7424),
  ],
);
