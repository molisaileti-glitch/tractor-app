import 'package:uuid/uuid.dart';

import '../../domain/entities/manager_profile.dart';

const _uuid = Uuid();

DateTime _dateTimeFromJson(Object value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

class ManagerProfileModel {
  const ManagerProfileModel({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.positionTitle,
    this.department,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ManagerProfileModel.newLocal({
    required String userId,
    String? unionId,
    String? employeeNumber,
    String? positionTitle,
    String? department,
  }) {
    final now = DateTime.now();
    return ManagerProfileModel(
      id: _uuid.v4(),
      userId: userId,
      unionId: unionId,
      employeeNumber: employeeNumber,
      positionTitle: positionTitle,
      department: department,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ManagerProfileModel.fromJson(Map<String, Object?> json) {
    return ManagerProfileModel(
      id: json['id']! as String,
      userId: json['userId']! as String,
      unionId: json['unionId'] as String?,
      employeeNumber: json['employeeNumber'] as String?,
      positionTitle: json['positionTitle'] as String?,
      department: json['department'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']!),
      updatedAt: _dateTimeFromJson(json['updatedAt']!),
    );
  }

  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? positionTitle;
  final String? department;
  final DateTime createdAt;
  final DateTime updatedAt;

  ManagerProfile toEntity() {
    return ManagerProfile(
      id: id,
      userId: userId,
      unionId: unionId,
      employeeNumber: employeeNumber,
      positionTitle: positionTitle,
      department: department,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'userId': userId,
      'unionId': unionId,
      'employeeNumber': employeeNumber,
      'positionTitle': positionTitle,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
