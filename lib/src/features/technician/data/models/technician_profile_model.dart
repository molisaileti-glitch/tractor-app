import 'package:uuid/uuid.dart';

import '../../domain/entities/technician_profile.dart';

const _uuid = Uuid();

DateTime _dateTimeFromJson(Object value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

class TechnicianProfileModel {
  const TechnicianProfileModel({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.specialization,
    this.certificationNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TechnicianProfileModel.newLocal({
    required String userId,
    String? unionId,
    String? employeeNumber,
    String? specialization,
    String? certificationNumber,
  }) {
    final now = DateTime.now();
    return TechnicianProfileModel(
      id: _uuid.v4(),
      userId: userId,
      unionId: unionId,
      employeeNumber: employeeNumber,
      specialization: specialization,
      certificationNumber: certificationNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory TechnicianProfileModel.fromJson(Map<String, Object?> json) {
    return TechnicianProfileModel(
      id: json['id']! as String,
      userId: json['userId']! as String,
      unionId: json['unionId'] as String?,
      employeeNumber: json['employeeNumber'] as String?,
      specialization: json['specialization'] as String?,
      certificationNumber: json['certificationNumber'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']!),
      updatedAt: _dateTimeFromJson(json['updatedAt']!),
    );
  }

  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? specialization;
  final String? certificationNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  TechnicianProfile toEntity() {
    return TechnicianProfile(
      id: id,
      userId: userId,
      unionId: unionId,
      employeeNumber: employeeNumber,
      specialization: specialization,
      certificationNumber: certificationNumber,
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
      'specialization': specialization,
      'certificationNumber': certificationNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
