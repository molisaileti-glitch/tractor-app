class DispatcherProfile {
  const DispatcherProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.dispatchZone,
    this.radioCallSign,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? dispatchZone;
  final String? radioCallSign;
  final DateTime createdAt;
  final DateTime updatedAt;
}
