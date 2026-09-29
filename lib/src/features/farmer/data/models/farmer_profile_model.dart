import 'package:uuid/uuid.dart';

import '../../domain/entities/farmer_profile.dart';

const _uuid = Uuid();

FarmerSex _sexFromJson(String value) {
  return FarmerSex.values.byName(value);
}

FarmerIdentityDocumentType _identityDocumentTypeFromJson(String value) {
  return FarmerIdentityDocumentType.values.byName(value);
}

DateTime _dateTimeFromJson(Object value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

class FarmerProfileModel {
  const FarmerProfileModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.phoneNumber,
    this.email,
    this.passwordHash,
    this.membershipNumber,
    this.village,
    required this.sex,
    required this.identityDocumentType,
    required this.identityNumber,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FarmerProfileModel.newLocal({
    required String firstName,
    String? middleName,
    required String lastName,
    String? phoneNumber,
    String? email,
    String? passwordHash,
    String? membershipNumber,
    String? village,
    required FarmerSex sex,
    required FarmerIdentityDocumentType identityDocumentType,
    required String identityNumber,
    required DateTime dateOfBirth,
  }) {
    final now = DateTime.now();
    return FarmerProfileModel(
      id: _uuid.v4(),
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      passwordHash: passwordHash,
      membershipNumber: membershipNumber,
      village: village,
      sex: sex,
      identityDocumentType: identityDocumentType,
      identityNumber: identityNumber,
      dateOfBirth: dateOfBirth,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory FarmerProfileModel.fromJson(Map<String, Object?> json) {
    return FarmerProfileModel(
      id: json['id']! as String,
      firstName: json['firstName']! as String,
      middleName: json['middleName'] as String?,
      lastName: json['lastName']! as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      passwordHash: json['passwordHash'] as String?,
      membershipNumber: json['membershipNumber'] as String?,
      village: json['village'] as String?,
      sex: _sexFromJson(json['sex']! as String),
      identityDocumentType: _identityDocumentTypeFromJson(
        json['identityDocumentType']! as String,
      ),
      identityNumber: json['identityNumber']! as String,
      dateOfBirth: _dateTimeFromJson(json['dateOfBirth']!),
      createdAt: _dateTimeFromJson(json['createdAt']!),
      updatedAt: _dateTimeFromJson(json['updatedAt']!),
    );
  }

  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? phoneNumber;
  final String? email;
  final String? passwordHash;
  final String? membershipNumber;
  final String? village;
  final FarmerSex sex;
  final FarmerIdentityDocumentType identityDocumentType;
  final String identityNumber;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  FarmerProfile toEntity() {
    return FarmerProfile(
      id: id,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      membershipNumber: membershipNumber,
      village: village,
      sex: sex,
      identityDocumentType: identityDocumentType,
      identityNumber: identityNumber,
      dateOfBirth: dateOfBirth,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'passwordHash': passwordHash,
      'membershipNumber': membershipNumber,
      'village': village,
      'sex': sex.name,
      'identityDocumentType': identityDocumentType.name,
      'identityNumber': identityNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
