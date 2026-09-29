class TechnicianProfile {
  const TechnicianProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.specialization,
    this.certificationNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? specialization;
  final String? certificationNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
}
