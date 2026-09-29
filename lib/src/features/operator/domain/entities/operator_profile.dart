class OperatorProfile {
  const OperatorProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.licenseNumber,
    this.assignedTractorId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? unionId;
  final String? licenseNumber;
  final String? assignedTractorId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}
