import 'package:uuid/uuid.dart';

import '../../domain/entities/dispatcher_profile.dart';

const _uuid = Uuid();

DateTime _dateTimeFromJson(Object value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

class DispatcherProfileModel {
  const DispatcherProfileModel({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.dispatchZone,
    this.radioCallSign,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DispatcherProfileModel.newLocal({
    required String userId,
    String? unionId,
    String? employeeNumber,
    String? dispatchZone,
    String? radioCallSign,
  }) {
    final now = DateTime.now();
    return DispatcherProfileModel(
      id: _uuid.v4(),
      userId: userId,
      unionId: unionId,
      employeeNumber: employeeNumber,
      dispatchZone: dispatchZone,
      radioCallSign: radioCallSign,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory DispatcherProfileModel.fromJson(Map<String, Object?> json) {
    return DispatcherProfileModel(
      id: json['id']! as String,
      userId: json['userId']! as String,
      unionId: json['unionId'] as String?,
      employeeNumber: json['employeeNumber'] as String?,
      dispatchZone: json['dispatchZone'] as String?,
      radioCallSign: json['radioCallSign'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']!),
      updatedAt: _dateTimeFromJson(json['updatedAt']!),
    );
  }

  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? dispatchZone;
  final String? radioCallSign;
  final DateTime createdAt;
  final DateTime updatedAt;

  DispatcherProfile toEntity() {
    return DispatcherProfile(
      id: id,
      userId: userId,
      unionId: unionId,
      employeeNumber: employeeNumber,
      dispatchZone: dispatchZone,
      radioCallSign: radioCallSign,
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
      'dispatchZone': dispatchZone,
      'radioCallSign': radioCallSign,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
