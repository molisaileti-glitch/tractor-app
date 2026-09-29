import 'package:uuid/uuid.dart';

import '../../domain/entities/operator_profile.dart';

const _uuid = Uuid();

DateTime _dateTimeFromJson(Object value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

class OperatorProfileModel {
  const OperatorProfileModel({
    required this.id,
    required this.userId,
    this.unionId,
    this.licenseNumber,
    this.assignedTractorId,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OperatorProfileModel.newLocal({
    required String userId,
    String? unionId,
    String? licenseNumber,
    String? assignedTractorId,
    String? note,
  }) {
    final now = DateTime.now();
    return OperatorProfileModel(
      id: _uuid.v4(),
      userId: userId,
      unionId: unionId,
      licenseNumber: licenseNumber,
      assignedTractorId: assignedTractorId,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory OperatorProfileModel.fromJson(Map<String, Object?> json) {
    return OperatorProfileModel(
      id: json['id']! as String,
      userId: json['userId']! as String,
      unionId: json['unionId'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      assignedTractorId: json['assignedTractorId'] as String?,
      note: json['note'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']!),
      updatedAt: _dateTimeFromJson(json['updatedAt']!),
    );
  }

  final String id;
  final String userId;
  final String? unionId;
  final String? licenseNumber;
  final String? assignedTractorId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OperatorProfile toEntity() {
    return OperatorProfile(
      id: id,
      userId: userId,
      unionId: unionId,
      licenseNumber: licenseNumber,
      assignedTractorId: assignedTractorId,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'userId': userId,
      'unionId': unionId,
      'licenseNumber': licenseNumber,
      'assignedTractorId': assignedTractorId,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
