class ManagerProfile {
  const ManagerProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.positionTitle,
    this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? positionTitle;
  final String? department;
  final DateTime createdAt;
  final DateTime updatedAt;
}
