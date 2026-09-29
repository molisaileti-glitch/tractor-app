enum FarmerSex { female, male }

enum FarmerIdentityDocumentType { nida, votersId, drivingLicence }

extension FarmerIdentityDocumentTypeLabel on FarmerIdentityDocumentType {
  String get label {
    return switch (this) {
      FarmerIdentityDocumentType.nida => 'NIDA',
      FarmerIdentityDocumentType.votersId => 'Voters ID',
      FarmerIdentityDocumentType.drivingLicence => 'Driving Licence',
    };
  }
}

class FarmerProfile {
  const FarmerProfile({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.phoneNumber,
    this.email,
    this.membershipNumber,
    this.village,
    required this.sex,
    required this.identityDocumentType,
    required this.identityNumber,
    required this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? phoneNumber;
  final String? email;
  final String? membershipNumber;
  final String? village;
  final FarmerSex sex;
  final FarmerIdentityDocumentType identityDocumentType;
  final String identityNumber;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName {
    final parts = [firstName, ?middleName, lastName];
    return parts.where((part) => part.trim().isNotEmpty).join(' ');
  }
}
