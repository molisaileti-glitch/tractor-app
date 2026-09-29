// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FarmersTable extends Farmers with TableInfo<$FarmersTable, Farmer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _membershipNumberMeta = const VerificationMeta(
    'membershipNumber',
  );
  @override
  late final GeneratedColumn<String> membershipNumber = GeneratedColumn<String>(
    'membership_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta(
    'village',
  );
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SexDb?, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SexDb?>($FarmersTable.$convertersexn);
  @override
  late final GeneratedColumnWithTypeConverter<IdentityDocumentTypeDb?, String>
  identityDocumentType =
      GeneratedColumn<String>(
        'identity_document_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<IdentityDocumentTypeDb?>(
        $FarmersTable.$converteridentityDocumentTypen,
      );
  static const VerificationMeta _identityNumberMeta = const VerificationMeta(
    'identityNumber',
  );
  @override
  late final GeneratedColumn<String> identityNumber = GeneratedColumn<String>(
    'identity_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    middleName,
    lastName,
    phoneNumber,
    email,
    passwordHash,
    membershipNumber,
    village,
    sex,
    identityDocumentType,
    identityNumber,
    dateOfBirth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farmers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Farmer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    }
    if (data.containsKey('membership_number')) {
      context.handle(
        _membershipNumberMeta,
        membershipNumber.isAcceptableOrUnknown(
          data['membership_number']!,
          _membershipNumberMeta,
        ),
      );
    }
    if (data.containsKey('village')) {
      context.handle(
        _villageMeta,
        village.isAcceptableOrUnknown(data['village']!, _villageMeta),
      );
    }
    if (data.containsKey('identity_number')) {
      context.handle(
        _identityNumberMeta,
        identityNumber.isAcceptableOrUnknown(
          data['identity_number']!,
          _identityNumberMeta,
        ),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Farmer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farmer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      ),
      membershipNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_number'],
      ),
      village: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}village'],
      ),
      sex: $FarmersTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        ),
      ),
      identityDocumentType: $FarmersTable.$converteridentityDocumentTypen
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}identity_document_type'],
            ),
          ),
      identityNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_number'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      ),
    );
  }

  @override
  $FarmersTable createAlias(String alias) {
    return $FarmersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SexDb, String, String> $convertersex =
      const EnumNameConverter<SexDb>(SexDb.values);
  static JsonTypeConverter2<SexDb?, String?, String?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
  static JsonTypeConverter2<IdentityDocumentTypeDb, String, String>
  $converteridentityDocumentType =
      const EnumNameConverter<IdentityDocumentTypeDb>(
        IdentityDocumentTypeDb.values,
      );
  static JsonTypeConverter2<IdentityDocumentTypeDb?, String?, String?>
  $converteridentityDocumentTypen = JsonTypeConverter2.asNullable(
    $converteridentityDocumentType,
  );
}

class Farmer extends DataClass implements Insertable<Farmer> {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? phoneNumber;
  final String? email;
  final String? passwordHash;
  final String? membershipNumber;
  final String? village;
  final SexDb? sex;
  final IdentityDocumentTypeDb? identityDocumentType;
  final String? identityNumber;
  final DateTime? dateOfBirth;
  const Farmer({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.phoneNumber,
    this.email,
    this.passwordHash,
    this.membershipNumber,
    this.village,
    this.sex,
    this.identityDocumentType,
    this.identityNumber,
    this.dateOfBirth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || passwordHash != null) {
      map['password_hash'] = Variable<String>(passwordHash);
    }
    if (!nullToAbsent || membershipNumber != null) {
      map['membership_number'] = Variable<String>(membershipNumber);
    }
    if (!nullToAbsent || village != null) {
      map['village'] = Variable<String>(village);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>($FarmersTable.$convertersexn.toSql(sex));
    }
    if (!nullToAbsent || identityDocumentType != null) {
      map['identity_document_type'] = Variable<String>(
        $FarmersTable.$converteridentityDocumentTypen.toSql(
          identityDocumentType,
        ),
      );
    }
    if (!nullToAbsent || identityNumber != null) {
      map['identity_number'] = Variable<String>(identityNumber);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    return map;
  }

  FarmersCompanion toCompanion(bool nullToAbsent) {
    return FarmersCompanion(
      id: Value(id),
      firstName: Value(firstName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      lastName: Value(lastName),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      passwordHash: passwordHash == null && nullToAbsent
          ? const Value.absent()
          : Value(passwordHash),
      membershipNumber: membershipNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(membershipNumber),
      village: village == null && nullToAbsent
          ? const Value.absent()
          : Value(village),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      identityDocumentType: identityDocumentType == null && nullToAbsent
          ? const Value.absent()
          : Value(identityDocumentType),
      identityNumber: identityNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(identityNumber),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
    );
  }

  factory Farmer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farmer(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      email: serializer.fromJson<String?>(json['email']),
      passwordHash: serializer.fromJson<String?>(json['passwordHash']),
      membershipNumber: serializer.fromJson<String?>(json['membershipNumber']),
      village: serializer.fromJson<String?>(json['village']),
      sex: $FarmersTable.$convertersexn.fromJson(
        serializer.fromJson<String?>(json['sex']),
      ),
      identityDocumentType: $FarmersTable.$converteridentityDocumentTypen
          .fromJson(serializer.fromJson<String?>(json['identityDocumentType'])),
      identityNumber: serializer.fromJson<String?>(json['identityNumber']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'middleName': serializer.toJson<String?>(middleName),
      'lastName': serializer.toJson<String>(lastName),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'email': serializer.toJson<String?>(email),
      'passwordHash': serializer.toJson<String?>(passwordHash),
      'membershipNumber': serializer.toJson<String?>(membershipNumber),
      'village': serializer.toJson<String?>(village),
      'sex': serializer.toJson<String?>(
        $FarmersTable.$convertersexn.toJson(sex),
      ),
      'identityDocumentType': serializer.toJson<String?>(
        $FarmersTable.$converteridentityDocumentTypen.toJson(
          identityDocumentType,
        ),
      ),
      'identityNumber': serializer.toJson<String?>(identityNumber),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
    };
  }

  Farmer copyWith({
    String? id,
    String? firstName,
    Value<String?> middleName = const Value.absent(),
    String? lastName,
    Value<String?> phoneNumber = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> passwordHash = const Value.absent(),
    Value<String?> membershipNumber = const Value.absent(),
    Value<String?> village = const Value.absent(),
    Value<SexDb?> sex = const Value.absent(),
    Value<IdentityDocumentTypeDb?> identityDocumentType = const Value.absent(),
    Value<String?> identityNumber = const Value.absent(),
    Value<DateTime?> dateOfBirth = const Value.absent(),
  }) => Farmer(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    middleName: middleName.present ? middleName.value : this.middleName,
    lastName: lastName ?? this.lastName,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    email: email.present ? email.value : this.email,
    passwordHash: passwordHash.present ? passwordHash.value : this.passwordHash,
    membershipNumber: membershipNumber.present
        ? membershipNumber.value
        : this.membershipNumber,
    village: village.present ? village.value : this.village,
    sex: sex.present ? sex.value : this.sex,
    identityDocumentType: identityDocumentType.present
        ? identityDocumentType.value
        : this.identityDocumentType,
    identityNumber: identityNumber.present
        ? identityNumber.value
        : this.identityNumber,
    dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
  );
  Farmer copyWithCompanion(FarmersCompanion data) {
    return Farmer(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      membershipNumber: data.membershipNumber.present
          ? data.membershipNumber.value
          : this.membershipNumber,
      village: data.village.present ? data.village.value : this.village,
      sex: data.sex.present ? data.sex.value : this.sex,
      identityDocumentType: data.identityDocumentType.present
          ? data.identityDocumentType.value
          : this.identityDocumentType,
      identityNumber: data.identityNumber.present
          ? data.identityNumber.value
          : this.identityNumber,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farmer(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('lastName: $lastName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('membershipNumber: $membershipNumber, ')
          ..write('village: $village, ')
          ..write('sex: $sex, ')
          ..write('identityDocumentType: $identityDocumentType, ')
          ..write('identityNumber: $identityNumber, ')
          ..write('dateOfBirth: $dateOfBirth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    middleName,
    lastName,
    phoneNumber,
    email,
    passwordHash,
    membershipNumber,
    village,
    sex,
    identityDocumentType,
    identityNumber,
    dateOfBirth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farmer &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.middleName == this.middleName &&
          other.lastName == this.lastName &&
          other.phoneNumber == this.phoneNumber &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.membershipNumber == this.membershipNumber &&
          other.village == this.village &&
          other.sex == this.sex &&
          other.identityDocumentType == this.identityDocumentType &&
          other.identityNumber == this.identityNumber &&
          other.dateOfBirth == this.dateOfBirth);
}

class FarmersCompanion extends UpdateCompanion<Farmer> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String?> middleName;
  final Value<String> lastName;
  final Value<String?> phoneNumber;
  final Value<String?> email;
  final Value<String?> passwordHash;
  final Value<String?> membershipNumber;
  final Value<String?> village;
  final Value<SexDb?> sex;
  final Value<IdentityDocumentTypeDb?> identityDocumentType;
  final Value<String?> identityNumber;
  final Value<DateTime?> dateOfBirth;
  final Value<int> rowid;
  const FarmersCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.membershipNumber = const Value.absent(),
    this.village = const Value.absent(),
    this.sex = const Value.absent(),
    this.identityDocumentType = const Value.absent(),
    this.identityNumber = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmersCompanion.insert({
    this.id = const Value.absent(),
    required String firstName,
    this.middleName = const Value.absent(),
    required String lastName,
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.membershipNumber = const Value.absent(),
    this.village = const Value.absent(),
    this.sex = const Value.absent(),
    this.identityDocumentType = const Value.absent(),
    this.identityNumber = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : firstName = Value(firstName),
       lastName = Value(lastName);
  static Insertable<Farmer> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? middleName,
    Expression<String>? lastName,
    Expression<String>? phoneNumber,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? membershipNumber,
    Expression<String>? village,
    Expression<String>? sex,
    Expression<String>? identityDocumentType,
    Expression<String>? identityNumber,
    Expression<DateTime>? dateOfBirth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (middleName != null) 'middle_name': middleName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (membershipNumber != null) 'membership_number': membershipNumber,
      if (village != null) 'village': village,
      if (sex != null) 'sex': sex,
      if (identityDocumentType != null)
        'identity_document_type': identityDocumentType,
      if (identityNumber != null) 'identity_number': identityNumber,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmersCompanion copyWith({
    Value<String>? id,
    Value<String>? firstName,
    Value<String?>? middleName,
    Value<String>? lastName,
    Value<String?>? phoneNumber,
    Value<String?>? email,
    Value<String?>? passwordHash,
    Value<String?>? membershipNumber,
    Value<String?>? village,
    Value<SexDb?>? sex,
    Value<IdentityDocumentTypeDb?>? identityDocumentType,
    Value<String?>? identityNumber,
    Value<DateTime?>? dateOfBirth,
    Value<int>? rowid,
  }) {
    return FarmersCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      membershipNumber: membershipNumber ?? this.membershipNumber,
      village: village ?? this.village,
      sex: sex ?? this.sex,
      identityDocumentType: identityDocumentType ?? this.identityDocumentType,
      identityNumber: identityNumber ?? this.identityNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (membershipNumber.present) {
      map['membership_number'] = Variable<String>(membershipNumber.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $FarmersTable.$convertersexn.toSql(sex.value),
      );
    }
    if (identityDocumentType.present) {
      map['identity_document_type'] = Variable<String>(
        $FarmersTable.$converteridentityDocumentTypen.toSql(
          identityDocumentType.value,
        ),
      );
    }
    if (identityNumber.present) {
      map['identity_number'] = Variable<String>(identityNumber.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmersCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('middleName: $middleName, ')
          ..write('lastName: $lastName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('membershipNumber: $membershipNumber, ')
          ..write('village: $village, ')
          ..write('sex: $sex, ')
          ..write('identityDocumentType: $identityDocumentType, ')
          ..write('identityNumber: $identityNumber, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmPlotsTable extends FarmPlots
    with TableInfo<$FarmPlotsTable, FarmPlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmPlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farmers (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationLabelMeta = const VerificationMeta(
    'locationLabel',
  );
  @override
  late final GeneratedColumn<String> locationLabel = GeneratedColumn<String>(
    'location_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaHectaresMeta = const VerificationMeta(
    'areaHectares',
  );
  @override
  late final GeneratedColumn<double> areaHectares = GeneratedColumn<double>(
    'area_hectares',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlotRegistrationStatus, String>
  registrationStatus =
      GeneratedColumn<String>(
        'registration_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(PlotRegistrationStatus.draft.name),
      ).withConverter<PlotRegistrationStatus>(
        $FarmPlotsTable.$converterregistrationStatus,
      );
  static const VerificationMeta _boundaryRegisteredMeta =
      const VerificationMeta('boundaryRegistered');
  @override
  late final GeneratedColumn<bool> boundaryRegistered = GeneratedColumn<bool>(
    'boundary_registered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("boundary_registered" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    farmerId,
    name,
    locationLabel,
    areaHectares,
    registrationStatus,
    boundaryRegistered,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_plots';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmPlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location_label')) {
      context.handle(
        _locationLabelMeta,
        locationLabel.isAcceptableOrUnknown(
          data['location_label']!,
          _locationLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationLabelMeta);
    }
    if (data.containsKey('area_hectares')) {
      context.handle(
        _areaHectaresMeta,
        areaHectares.isAcceptableOrUnknown(
          data['area_hectares']!,
          _areaHectaresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_areaHectaresMeta);
    }
    if (data.containsKey('boundary_registered')) {
      context.handle(
        _boundaryRegisteredMeta,
        boundaryRegistered.isAcceptableOrUnknown(
          data['boundary_registered']!,
          _boundaryRegisteredMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  FarmPlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmPlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_label'],
      )!,
      areaHectares: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_hectares'],
      )!,
      registrationStatus: $FarmPlotsTable.$converterregistrationStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}registration_status'],
        )!,
      ),
      boundaryRegistered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}boundary_registered'],
      )!,
    );
  }

  @override
  $FarmPlotsTable createAlias(String alias) {
    return $FarmPlotsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlotRegistrationStatus, String, String>
  $converterregistrationStatus =
      const EnumNameConverter<PlotRegistrationStatus>(
        PlotRegistrationStatus.values,
      );
}

class FarmPlot extends DataClass implements Insertable<FarmPlot> {
  final String id;
  final String farmerId;
  final String name;
  final String locationLabel;
  final double areaHectares;
  final PlotRegistrationStatus registrationStatus;
  final bool boundaryRegistered;
  const FarmPlot({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.locationLabel,
    required this.areaHectares,
    required this.registrationStatus,
    required this.boundaryRegistered,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farmer_id'] = Variable<String>(farmerId);
    map['name'] = Variable<String>(name);
    map['location_label'] = Variable<String>(locationLabel);
    map['area_hectares'] = Variable<double>(areaHectares);
    {
      map['registration_status'] = Variable<String>(
        $FarmPlotsTable.$converterregistrationStatus.toSql(registrationStatus),
      );
    }
    map['boundary_registered'] = Variable<bool>(boundaryRegistered);
    return map;
  }

  FarmPlotsCompanion toCompanion(bool nullToAbsent) {
    return FarmPlotsCompanion(
      id: Value(id),
      farmerId: Value(farmerId),
      name: Value(name),
      locationLabel: Value(locationLabel),
      areaHectares: Value(areaHectares),
      registrationStatus: Value(registrationStatus),
      boundaryRegistered: Value(boundaryRegistered),
    );
  }

  factory FarmPlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmPlot(
      id: serializer.fromJson<String>(json['id']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      name: serializer.fromJson<String>(json['name']),
      locationLabel: serializer.fromJson<String>(json['locationLabel']),
      areaHectares: serializer.fromJson<double>(json['areaHectares']),
      registrationStatus: $FarmPlotsTable.$converterregistrationStatus.fromJson(
        serializer.fromJson<String>(json['registrationStatus']),
      ),
      boundaryRegistered: serializer.fromJson<bool>(json['boundaryRegistered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmerId': serializer.toJson<String>(farmerId),
      'name': serializer.toJson<String>(name),
      'locationLabel': serializer.toJson<String>(locationLabel),
      'areaHectares': serializer.toJson<double>(areaHectares),
      'registrationStatus': serializer.toJson<String>(
        $FarmPlotsTable.$converterregistrationStatus.toJson(registrationStatus),
      ),
      'boundaryRegistered': serializer.toJson<bool>(boundaryRegistered),
    };
  }

  FarmPlot copyWith({
    String? id,
    String? farmerId,
    String? name,
    String? locationLabel,
    double? areaHectares,
    PlotRegistrationStatus? registrationStatus,
    bool? boundaryRegistered,
  }) => FarmPlot(
    id: id ?? this.id,
    farmerId: farmerId ?? this.farmerId,
    name: name ?? this.name,
    locationLabel: locationLabel ?? this.locationLabel,
    areaHectares: areaHectares ?? this.areaHectares,
    registrationStatus: registrationStatus ?? this.registrationStatus,
    boundaryRegistered: boundaryRegistered ?? this.boundaryRegistered,
  );
  FarmPlot copyWithCompanion(FarmPlotsCompanion data) {
    return FarmPlot(
      id: data.id.present ? data.id.value : this.id,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      name: data.name.present ? data.name.value : this.name,
      locationLabel: data.locationLabel.present
          ? data.locationLabel.value
          : this.locationLabel,
      areaHectares: data.areaHectares.present
          ? data.areaHectares.value
          : this.areaHectares,
      registrationStatus: data.registrationStatus.present
          ? data.registrationStatus.value
          : this.registrationStatus,
      boundaryRegistered: data.boundaryRegistered.present
          ? data.boundaryRegistered.value
          : this.boundaryRegistered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmPlot(')
          ..write('id: $id, ')
          ..write('farmerId: $farmerId, ')
          ..write('name: $name, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('areaHectares: $areaHectares, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('boundaryRegistered: $boundaryRegistered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    farmerId,
    name,
    locationLabel,
    areaHectares,
    registrationStatus,
    boundaryRegistered,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmPlot &&
          other.id == this.id &&
          other.farmerId == this.farmerId &&
          other.name == this.name &&
          other.locationLabel == this.locationLabel &&
          other.areaHectares == this.areaHectares &&
          other.registrationStatus == this.registrationStatus &&
          other.boundaryRegistered == this.boundaryRegistered);
}

class FarmPlotsCompanion extends UpdateCompanion<FarmPlot> {
  final Value<String> id;
  final Value<String> farmerId;
  final Value<String> name;
  final Value<String> locationLabel;
  final Value<double> areaHectares;
  final Value<PlotRegistrationStatus> registrationStatus;
  final Value<bool> boundaryRegistered;
  final Value<int> rowid;
  const FarmPlotsCompanion({
    this.id = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.name = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.areaHectares = const Value.absent(),
    this.registrationStatus = const Value.absent(),
    this.boundaryRegistered = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmPlotsCompanion.insert({
    this.id = const Value.absent(),
    required String farmerId,
    required String name,
    required String locationLabel,
    required double areaHectares,
    this.registrationStatus = const Value.absent(),
    this.boundaryRegistered = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : farmerId = Value(farmerId),
       name = Value(name),
       locationLabel = Value(locationLabel),
       areaHectares = Value(areaHectares);
  static Insertable<FarmPlot> custom({
    Expression<String>? id,
    Expression<String>? farmerId,
    Expression<String>? name,
    Expression<String>? locationLabel,
    Expression<double>? areaHectares,
    Expression<String>? registrationStatus,
    Expression<bool>? boundaryRegistered,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmerId != null) 'farmer_id': farmerId,
      if (name != null) 'name': name,
      if (locationLabel != null) 'location_label': locationLabel,
      if (areaHectares != null) 'area_hectares': areaHectares,
      if (registrationStatus != null) 'registration_status': registrationStatus,
      if (boundaryRegistered != null) 'boundary_registered': boundaryRegistered,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmPlotsCompanion copyWith({
    Value<String>? id,
    Value<String>? farmerId,
    Value<String>? name,
    Value<String>? locationLabel,
    Value<double>? areaHectares,
    Value<PlotRegistrationStatus>? registrationStatus,
    Value<bool>? boundaryRegistered,
    Value<int>? rowid,
  }) {
    return FarmPlotsCompanion(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      locationLabel: locationLabel ?? this.locationLabel,
      areaHectares: areaHectares ?? this.areaHectares,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      boundaryRegistered: boundaryRegistered ?? this.boundaryRegistered,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (areaHectares.present) {
      map['area_hectares'] = Variable<double>(areaHectares.value);
    }
    if (registrationStatus.present) {
      map['registration_status'] = Variable<String>(
        $FarmPlotsTable.$converterregistrationStatus.toSql(
          registrationStatus.value,
        ),
      );
    }
    if (boundaryRegistered.present) {
      map['boundary_registered'] = Variable<bool>(boundaryRegistered.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmPlotsCompanion(')
          ..write('id: $id, ')
          ..write('farmerId: $farmerId, ')
          ..write('name: $name, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('areaHectares: $areaHectares, ')
          ..write('registrationStatus: $registrationStatus, ')
          ..write('boundaryRegistered: $boundaryRegistered, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmBoundaryPointsTable extends FarmBoundaryPoints
    with TableInfo<$FarmBoundaryPointsTable, FarmBoundaryPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmBoundaryPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farm_plots (id)',
    ),
  );
  static const VerificationMeta _pointOrderMeta = const VerificationMeta(
    'pointOrder',
  );
  @override
  late final GeneratedColumn<int> pointOrder = GeneratedColumn<int>(
    'point_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedByUserIdMeta = const VerificationMeta(
    'capturedByUserId',
  );
  @override
  late final GeneratedColumn<String> capturedByUserId = GeneratedColumn<String>(
    'captured_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    plotId,
    pointOrder,
    latitude,
    longitude,
    capturedByUserId,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_boundary_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<FarmBoundaryPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('point_order')) {
      context.handle(
        _pointOrderMeta,
        pointOrder.isAcceptableOrUnknown(data['point_order']!, _pointOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_pointOrderMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('captured_by_user_id')) {
      context.handle(
        _capturedByUserIdMeta,
        capturedByUserId.isAcceptableOrUnknown(
          data['captured_by_user_id']!,
          _capturedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  FarmBoundaryPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmBoundaryPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_id'],
      )!,
      pointOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_order'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      capturedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}captured_by_user_id'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      ),
    );
  }

  @override
  $FarmBoundaryPointsTable createAlias(String alias) {
    return $FarmBoundaryPointsTable(attachedDatabase, alias);
  }
}

class FarmBoundaryPoint extends DataClass
    implements Insertable<FarmBoundaryPoint> {
  final String id;
  final String plotId;
  final int pointOrder;
  final double latitude;
  final double longitude;
  final String? capturedByUserId;
  final DateTime? capturedAt;
  const FarmBoundaryPoint({
    required this.id,
    required this.plotId,
    required this.pointOrder,
    required this.latitude,
    required this.longitude,
    this.capturedByUserId,
    this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plot_id'] = Variable<String>(plotId);
    map['point_order'] = Variable<int>(pointOrder);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || capturedByUserId != null) {
      map['captured_by_user_id'] = Variable<String>(capturedByUserId);
    }
    if (!nullToAbsent || capturedAt != null) {
      map['captured_at'] = Variable<DateTime>(capturedAt);
    }
    return map;
  }

  FarmBoundaryPointsCompanion toCompanion(bool nullToAbsent) {
    return FarmBoundaryPointsCompanion(
      id: Value(id),
      plotId: Value(plotId),
      pointOrder: Value(pointOrder),
      latitude: Value(latitude),
      longitude: Value(longitude),
      capturedByUserId: capturedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedByUserId),
      capturedAt: capturedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(capturedAt),
    );
  }

  factory FarmBoundaryPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmBoundaryPoint(
      id: serializer.fromJson<String>(json['id']),
      plotId: serializer.fromJson<String>(json['plotId']),
      pointOrder: serializer.fromJson<int>(json['pointOrder']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      capturedByUserId: serializer.fromJson<String?>(json['capturedByUserId']),
      capturedAt: serializer.fromJson<DateTime?>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plotId': serializer.toJson<String>(plotId),
      'pointOrder': serializer.toJson<int>(pointOrder),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'capturedByUserId': serializer.toJson<String?>(capturedByUserId),
      'capturedAt': serializer.toJson<DateTime?>(capturedAt),
    };
  }

  FarmBoundaryPoint copyWith({
    String? id,
    String? plotId,
    int? pointOrder,
    double? latitude,
    double? longitude,
    Value<String?> capturedByUserId = const Value.absent(),
    Value<DateTime?> capturedAt = const Value.absent(),
  }) => FarmBoundaryPoint(
    id: id ?? this.id,
    plotId: plotId ?? this.plotId,
    pointOrder: pointOrder ?? this.pointOrder,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    capturedByUserId: capturedByUserId.present
        ? capturedByUserId.value
        : this.capturedByUserId,
    capturedAt: capturedAt.present ? capturedAt.value : this.capturedAt,
  );
  FarmBoundaryPoint copyWithCompanion(FarmBoundaryPointsCompanion data) {
    return FarmBoundaryPoint(
      id: data.id.present ? data.id.value : this.id,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      pointOrder: data.pointOrder.present
          ? data.pointOrder.value
          : this.pointOrder,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      capturedByUserId: data.capturedByUserId.present
          ? data.capturedByUserId.value
          : this.capturedByUserId,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmBoundaryPoint(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('pointOrder: $pointOrder, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedByUserId: $capturedByUserId, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    plotId,
    pointOrder,
    latitude,
    longitude,
    capturedByUserId,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmBoundaryPoint &&
          other.id == this.id &&
          other.plotId == this.plotId &&
          other.pointOrder == this.pointOrder &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.capturedByUserId == this.capturedByUserId &&
          other.capturedAt == this.capturedAt);
}

class FarmBoundaryPointsCompanion extends UpdateCompanion<FarmBoundaryPoint> {
  final Value<String> id;
  final Value<String> plotId;
  final Value<int> pointOrder;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> capturedByUserId;
  final Value<DateTime?> capturedAt;
  final Value<int> rowid;
  const FarmBoundaryPointsCompanion({
    this.id = const Value.absent(),
    this.plotId = const Value.absent(),
    this.pointOrder = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.capturedByUserId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmBoundaryPointsCompanion.insert({
    this.id = const Value.absent(),
    required String plotId,
    required int pointOrder,
    required double latitude,
    required double longitude,
    this.capturedByUserId = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : plotId = Value(plotId),
       pointOrder = Value(pointOrder),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<FarmBoundaryPoint> custom({
    Expression<String>? id,
    Expression<String>? plotId,
    Expression<int>? pointOrder,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? capturedByUserId,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plotId != null) 'plot_id': plotId,
      if (pointOrder != null) 'point_order': pointOrder,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (capturedByUserId != null) 'captured_by_user_id': capturedByUserId,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmBoundaryPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? plotId,
    Value<int>? pointOrder,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? capturedByUserId,
    Value<DateTime?>? capturedAt,
    Value<int>? rowid,
  }) {
    return FarmBoundaryPointsCompanion(
      id: id ?? this.id,
      plotId: plotId ?? this.plotId,
      pointOrder: pointOrder ?? this.pointOrder,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      capturedByUserId: capturedByUserId ?? this.capturedByUserId,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (pointOrder.present) {
      map['point_order'] = Variable<int>(pointOrder.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (capturedByUserId.present) {
      map['captured_by_user_id'] = Variable<String>(capturedByUserId.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmBoundaryPointsCompanion(')
          ..write('id: $id, ')
          ..write('plotId: $plotId, ')
          ..write('pointOrder: $pointOrder, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('capturedByUserId: $capturedByUserId, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServiceRequestsTable extends ServiceRequests
    with TableInfo<$ServiceRequestsTable, ServiceRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _requestNumberMeta = const VerificationMeta(
    'requestNumber',
  );
  @override
  late final GeneratedColumn<String> requestNumber = GeneratedColumn<String>(
    'request_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farmers (id)',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farm_plots (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ServiceKind, String> serviceKind =
      GeneratedColumn<String>(
        'service_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ServiceKind>($ServiceRequestsTable.$converterserviceKind);
  @override
  late final GeneratedColumnWithTypeConverter<ServiceRequestStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => ServiceRequestStatus.pendingApproval.name,
  ).withConverter<ServiceRequestStatus>($ServiceRequestsTable.$converterstatus);
  static const VerificationMeta _preferredDateMeta = const VerificationMeta(
    'preferredDate',
  );
  @override
  late final GeneratedColumn<DateTime> preferredDate =
      GeneratedColumn<DateTime>(
        'preferred_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _alternativeDateMeta = const VerificationMeta(
    'alternativeDate',
  );
  @override
  late final GeneratedColumn<DateTime> alternativeDate =
      GeneratedColumn<DateTime>(
        'alternative_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _farmerNotesMeta = const VerificationMeta(
    'farmerNotes',
  );
  @override
  late final GeneratedColumn<String> farmerNotes = GeneratedColumn<String>(
    'farmer_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectionReasonMeta = const VerificationMeta(
    'rejectionReason',
  );
  @override
  late final GeneratedColumn<String> rejectionReason = GeneratedColumn<String>(
    'rejection_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectionNotesMeta = const VerificationMeta(
    'rejectionNotes',
  );
  @override
  late final GeneratedColumn<String> rejectionNotes = GeneratedColumn<String>(
    'rejection_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedByUserIdMeta = const VerificationMeta(
    'reviewedByUserId',
  );
  @override
  late final GeneratedColumn<String> reviewedByUserId = GeneratedColumn<String>(
    'reviewed_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    requestNumber,
    farmerId,
    plotId,
    serviceKind,
    status,
    preferredDate,
    alternativeDate,
    farmerNotes,
    rejectionReason,
    rejectionNotes,
    reviewedByUserId,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('request_number')) {
      context.handle(
        _requestNumberMeta,
        requestNumber.isAcceptableOrUnknown(
          data['request_number']!,
          _requestNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestNumberMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('preferred_date')) {
      context.handle(
        _preferredDateMeta,
        preferredDate.isAcceptableOrUnknown(
          data['preferred_date']!,
          _preferredDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferredDateMeta);
    }
    if (data.containsKey('alternative_date')) {
      context.handle(
        _alternativeDateMeta,
        alternativeDate.isAcceptableOrUnknown(
          data['alternative_date']!,
          _alternativeDateMeta,
        ),
      );
    }
    if (data.containsKey('farmer_notes')) {
      context.handle(
        _farmerNotesMeta,
        farmerNotes.isAcceptableOrUnknown(
          data['farmer_notes']!,
          _farmerNotesMeta,
        ),
      );
    }
    if (data.containsKey('rejection_reason')) {
      context.handle(
        _rejectionReasonMeta,
        rejectionReason.isAcceptableOrUnknown(
          data['rejection_reason']!,
          _rejectionReasonMeta,
        ),
      );
    }
    if (data.containsKey('rejection_notes')) {
      context.handle(
        _rejectionNotesMeta,
        rejectionNotes.isAcceptableOrUnknown(
          data['rejection_notes']!,
          _rejectionNotesMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_by_user_id')) {
      context.handle(
        _reviewedByUserIdMeta,
        reviewedByUserId.isAcceptableOrUnknown(
          data['reviewed_by_user_id']!,
          _reviewedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ServiceRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      requestNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_number'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_id'],
      )!,
      serviceKind: $ServiceRequestsTable.$converterserviceKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}service_kind'],
        )!,
      ),
      status: $ServiceRequestsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      preferredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}preferred_date'],
      )!,
      alternativeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}alternative_date'],
      ),
      farmerNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_notes'],
      ),
      rejectionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejection_reason'],
      ),
      rejectionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejection_notes'],
      ),
      reviewedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_by_user_id'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
    );
  }

  @override
  $ServiceRequestsTable createAlias(String alias) {
    return $ServiceRequestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ServiceKind, String, String> $converterserviceKind =
      const EnumNameConverter<ServiceKind>(ServiceKind.values);
  static JsonTypeConverter2<ServiceRequestStatus, String, String>
  $converterstatus = const EnumNameConverter<ServiceRequestStatus>(
    ServiceRequestStatus.values,
  );
}

class ServiceRequest extends DataClass implements Insertable<ServiceRequest> {
  final String id;
  final String requestNumber;
  final String farmerId;
  final String plotId;
  final ServiceKind serviceKind;
  final ServiceRequestStatus status;
  final DateTime preferredDate;
  final DateTime? alternativeDate;
  final String? farmerNotes;
  final String? rejectionReason;
  final String? rejectionNotes;
  final String? reviewedByUserId;
  final DateTime? reviewedAt;
  const ServiceRequest({
    required this.id,
    required this.requestNumber,
    required this.farmerId,
    required this.plotId,
    required this.serviceKind,
    required this.status,
    required this.preferredDate,
    this.alternativeDate,
    this.farmerNotes,
    this.rejectionReason,
    this.rejectionNotes,
    this.reviewedByUserId,
    this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['request_number'] = Variable<String>(requestNumber);
    map['farmer_id'] = Variable<String>(farmerId);
    map['plot_id'] = Variable<String>(plotId);
    {
      map['service_kind'] = Variable<String>(
        $ServiceRequestsTable.$converterserviceKind.toSql(serviceKind),
      );
    }
    {
      map['status'] = Variable<String>(
        $ServiceRequestsTable.$converterstatus.toSql(status),
      );
    }
    map['preferred_date'] = Variable<DateTime>(preferredDate);
    if (!nullToAbsent || alternativeDate != null) {
      map['alternative_date'] = Variable<DateTime>(alternativeDate);
    }
    if (!nullToAbsent || farmerNotes != null) {
      map['farmer_notes'] = Variable<String>(farmerNotes);
    }
    if (!nullToAbsent || rejectionReason != null) {
      map['rejection_reason'] = Variable<String>(rejectionReason);
    }
    if (!nullToAbsent || rejectionNotes != null) {
      map['rejection_notes'] = Variable<String>(rejectionNotes);
    }
    if (!nullToAbsent || reviewedByUserId != null) {
      map['reviewed_by_user_id'] = Variable<String>(reviewedByUserId);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    return map;
  }

  ServiceRequestsCompanion toCompanion(bool nullToAbsent) {
    return ServiceRequestsCompanion(
      id: Value(id),
      requestNumber: Value(requestNumber),
      farmerId: Value(farmerId),
      plotId: Value(plotId),
      serviceKind: Value(serviceKind),
      status: Value(status),
      preferredDate: Value(preferredDate),
      alternativeDate: alternativeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(alternativeDate),
      farmerNotes: farmerNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(farmerNotes),
      rejectionReason: rejectionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionReason),
      rejectionNotes: rejectionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionNotes),
      reviewedByUserId: reviewedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedByUserId),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory ServiceRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceRequest(
      id: serializer.fromJson<String>(json['id']),
      requestNumber: serializer.fromJson<String>(json['requestNumber']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      plotId: serializer.fromJson<String>(json['plotId']),
      serviceKind: $ServiceRequestsTable.$converterserviceKind.fromJson(
        serializer.fromJson<String>(json['serviceKind']),
      ),
      status: $ServiceRequestsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      preferredDate: serializer.fromJson<DateTime>(json['preferredDate']),
      alternativeDate: serializer.fromJson<DateTime?>(json['alternativeDate']),
      farmerNotes: serializer.fromJson<String?>(json['farmerNotes']),
      rejectionReason: serializer.fromJson<String?>(json['rejectionReason']),
      rejectionNotes: serializer.fromJson<String?>(json['rejectionNotes']),
      reviewedByUserId: serializer.fromJson<String?>(json['reviewedByUserId']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'requestNumber': serializer.toJson<String>(requestNumber),
      'farmerId': serializer.toJson<String>(farmerId),
      'plotId': serializer.toJson<String>(plotId),
      'serviceKind': serializer.toJson<String>(
        $ServiceRequestsTable.$converterserviceKind.toJson(serviceKind),
      ),
      'status': serializer.toJson<String>(
        $ServiceRequestsTable.$converterstatus.toJson(status),
      ),
      'preferredDate': serializer.toJson<DateTime>(preferredDate),
      'alternativeDate': serializer.toJson<DateTime?>(alternativeDate),
      'farmerNotes': serializer.toJson<String?>(farmerNotes),
      'rejectionReason': serializer.toJson<String?>(rejectionReason),
      'rejectionNotes': serializer.toJson<String?>(rejectionNotes),
      'reviewedByUserId': serializer.toJson<String?>(reviewedByUserId),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
    };
  }

  ServiceRequest copyWith({
    String? id,
    String? requestNumber,
    String? farmerId,
    String? plotId,
    ServiceKind? serviceKind,
    ServiceRequestStatus? status,
    DateTime? preferredDate,
    Value<DateTime?> alternativeDate = const Value.absent(),
    Value<String?> farmerNotes = const Value.absent(),
    Value<String?> rejectionReason = const Value.absent(),
    Value<String?> rejectionNotes = const Value.absent(),
    Value<String?> reviewedByUserId = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
  }) => ServiceRequest(
    id: id ?? this.id,
    requestNumber: requestNumber ?? this.requestNumber,
    farmerId: farmerId ?? this.farmerId,
    plotId: plotId ?? this.plotId,
    serviceKind: serviceKind ?? this.serviceKind,
    status: status ?? this.status,
    preferredDate: preferredDate ?? this.preferredDate,
    alternativeDate: alternativeDate.present
        ? alternativeDate.value
        : this.alternativeDate,
    farmerNotes: farmerNotes.present ? farmerNotes.value : this.farmerNotes,
    rejectionReason: rejectionReason.present
        ? rejectionReason.value
        : this.rejectionReason,
    rejectionNotes: rejectionNotes.present
        ? rejectionNotes.value
        : this.rejectionNotes,
    reviewedByUserId: reviewedByUserId.present
        ? reviewedByUserId.value
        : this.reviewedByUserId,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
  );
  ServiceRequest copyWithCompanion(ServiceRequestsCompanion data) {
    return ServiceRequest(
      id: data.id.present ? data.id.value : this.id,
      requestNumber: data.requestNumber.present
          ? data.requestNumber.value
          : this.requestNumber,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      serviceKind: data.serviceKind.present
          ? data.serviceKind.value
          : this.serviceKind,
      status: data.status.present ? data.status.value : this.status,
      preferredDate: data.preferredDate.present
          ? data.preferredDate.value
          : this.preferredDate,
      alternativeDate: data.alternativeDate.present
          ? data.alternativeDate.value
          : this.alternativeDate,
      farmerNotes: data.farmerNotes.present
          ? data.farmerNotes.value
          : this.farmerNotes,
      rejectionReason: data.rejectionReason.present
          ? data.rejectionReason.value
          : this.rejectionReason,
      rejectionNotes: data.rejectionNotes.present
          ? data.rejectionNotes.value
          : this.rejectionNotes,
      reviewedByUserId: data.reviewedByUserId.present
          ? data.reviewedByUserId.value
          : this.reviewedByUserId,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRequest(')
          ..write('id: $id, ')
          ..write('requestNumber: $requestNumber, ')
          ..write('farmerId: $farmerId, ')
          ..write('plotId: $plotId, ')
          ..write('serviceKind: $serviceKind, ')
          ..write('status: $status, ')
          ..write('preferredDate: $preferredDate, ')
          ..write('alternativeDate: $alternativeDate, ')
          ..write('farmerNotes: $farmerNotes, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('rejectionNotes: $rejectionNotes, ')
          ..write('reviewedByUserId: $reviewedByUserId, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    requestNumber,
    farmerId,
    plotId,
    serviceKind,
    status,
    preferredDate,
    alternativeDate,
    farmerNotes,
    rejectionReason,
    rejectionNotes,
    reviewedByUserId,
    reviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceRequest &&
          other.id == this.id &&
          other.requestNumber == this.requestNumber &&
          other.farmerId == this.farmerId &&
          other.plotId == this.plotId &&
          other.serviceKind == this.serviceKind &&
          other.status == this.status &&
          other.preferredDate == this.preferredDate &&
          other.alternativeDate == this.alternativeDate &&
          other.farmerNotes == this.farmerNotes &&
          other.rejectionReason == this.rejectionReason &&
          other.rejectionNotes == this.rejectionNotes &&
          other.reviewedByUserId == this.reviewedByUserId &&
          other.reviewedAt == this.reviewedAt);
}

class ServiceRequestsCompanion extends UpdateCompanion<ServiceRequest> {
  final Value<String> id;
  final Value<String> requestNumber;
  final Value<String> farmerId;
  final Value<String> plotId;
  final Value<ServiceKind> serviceKind;
  final Value<ServiceRequestStatus> status;
  final Value<DateTime> preferredDate;
  final Value<DateTime?> alternativeDate;
  final Value<String?> farmerNotes;
  final Value<String?> rejectionReason;
  final Value<String?> rejectionNotes;
  final Value<String?> reviewedByUserId;
  final Value<DateTime?> reviewedAt;
  final Value<int> rowid;
  const ServiceRequestsCompanion({
    this.id = const Value.absent(),
    this.requestNumber = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.plotId = const Value.absent(),
    this.serviceKind = const Value.absent(),
    this.status = const Value.absent(),
    this.preferredDate = const Value.absent(),
    this.alternativeDate = const Value.absent(),
    this.farmerNotes = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.rejectionNotes = const Value.absent(),
    this.reviewedByUserId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServiceRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String requestNumber,
    required String farmerId,
    required String plotId,
    required ServiceKind serviceKind,
    this.status = const Value.absent(),
    required DateTime preferredDate,
    this.alternativeDate = const Value.absent(),
    this.farmerNotes = const Value.absent(),
    this.rejectionReason = const Value.absent(),
    this.rejectionNotes = const Value.absent(),
    this.reviewedByUserId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : requestNumber = Value(requestNumber),
       farmerId = Value(farmerId),
       plotId = Value(plotId),
       serviceKind = Value(serviceKind),
       preferredDate = Value(preferredDate);
  static Insertable<ServiceRequest> custom({
    Expression<String>? id,
    Expression<String>? requestNumber,
    Expression<String>? farmerId,
    Expression<String>? plotId,
    Expression<String>? serviceKind,
    Expression<String>? status,
    Expression<DateTime>? preferredDate,
    Expression<DateTime>? alternativeDate,
    Expression<String>? farmerNotes,
    Expression<String>? rejectionReason,
    Expression<String>? rejectionNotes,
    Expression<String>? reviewedByUserId,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestNumber != null) 'request_number': requestNumber,
      if (farmerId != null) 'farmer_id': farmerId,
      if (plotId != null) 'plot_id': plotId,
      if (serviceKind != null) 'service_kind': serviceKind,
      if (status != null) 'status': status,
      if (preferredDate != null) 'preferred_date': preferredDate,
      if (alternativeDate != null) 'alternative_date': alternativeDate,
      if (farmerNotes != null) 'farmer_notes': farmerNotes,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (rejectionNotes != null) 'rejection_notes': rejectionNotes,
      if (reviewedByUserId != null) 'reviewed_by_user_id': reviewedByUserId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServiceRequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? requestNumber,
    Value<String>? farmerId,
    Value<String>? plotId,
    Value<ServiceKind>? serviceKind,
    Value<ServiceRequestStatus>? status,
    Value<DateTime>? preferredDate,
    Value<DateTime?>? alternativeDate,
    Value<String?>? farmerNotes,
    Value<String?>? rejectionReason,
    Value<String?>? rejectionNotes,
    Value<String?>? reviewedByUserId,
    Value<DateTime?>? reviewedAt,
    Value<int>? rowid,
  }) {
    return ServiceRequestsCompanion(
      id: id ?? this.id,
      requestNumber: requestNumber ?? this.requestNumber,
      farmerId: farmerId ?? this.farmerId,
      plotId: plotId ?? this.plotId,
      serviceKind: serviceKind ?? this.serviceKind,
      status: status ?? this.status,
      preferredDate: preferredDate ?? this.preferredDate,
      alternativeDate: alternativeDate ?? this.alternativeDate,
      farmerNotes: farmerNotes ?? this.farmerNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionNotes: rejectionNotes ?? this.rejectionNotes,
      reviewedByUserId: reviewedByUserId ?? this.reviewedByUserId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (requestNumber.present) {
      map['request_number'] = Variable<String>(requestNumber.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (serviceKind.present) {
      map['service_kind'] = Variable<String>(
        $ServiceRequestsTable.$converterserviceKind.toSql(serviceKind.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ServiceRequestsTable.$converterstatus.toSql(status.value),
      );
    }
    if (preferredDate.present) {
      map['preferred_date'] = Variable<DateTime>(preferredDate.value);
    }
    if (alternativeDate.present) {
      map['alternative_date'] = Variable<DateTime>(alternativeDate.value);
    }
    if (farmerNotes.present) {
      map['farmer_notes'] = Variable<String>(farmerNotes.value);
    }
    if (rejectionReason.present) {
      map['rejection_reason'] = Variable<String>(rejectionReason.value);
    }
    if (rejectionNotes.present) {
      map['rejection_notes'] = Variable<String>(rejectionNotes.value);
    }
    if (reviewedByUserId.present) {
      map['reviewed_by_user_id'] = Variable<String>(reviewedByUserId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceRequestsCompanion(')
          ..write('id: $id, ')
          ..write('requestNumber: $requestNumber, ')
          ..write('farmerId: $farmerId, ')
          ..write('plotId: $plotId, ')
          ..write('serviceKind: $serviceKind, ')
          ..write('status: $status, ')
          ..write('preferredDate: $preferredDate, ')
          ..write('alternativeDate: $alternativeDate, ')
          ..write('farmerNotes: $farmerNotes, ')
          ..write('rejectionReason: $rejectionReason, ')
          ..write('rejectionNotes: $rejectionNotes, ')
          ..write('reviewedByUserId: $reviewedByUserId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TractorsTable extends Tractors with TableInfo<$TractorsTable, Tractor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TractorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TractorAvailabilityStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(TractorAvailabilityStatus.available.name),
  ).withConverter<TractorAvailabilityStatus>($TractorsTable.$converterstatus);
  static const VerificationMeta _operatingHoursMeta = const VerificationMeta(
    'operatingHours',
  );
  @override
  late final GeneratedColumn<int> operatingHours = GeneratedColumn<int>(
    'operating_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextServiceHoursMeta = const VerificationMeta(
    'nextServiceHours',
  );
  @override
  late final GeneratedColumn<int> nextServiceHours = GeneratedColumn<int>(
    'next_service_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastServiceAtMeta = const VerificationMeta(
    'lastServiceAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastServiceAt =
      GeneratedColumn<DateTime>(
        'last_service_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusNoteMeta = const VerificationMeta(
    'statusNote',
  );
  @override
  late final GeneratedColumn<String> statusNote = GeneratedColumn<String>(
    'status_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    model,
    status,
    operatingHours,
    nextServiceHours,
    lastServiceAt,
    statusNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tractors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tractor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('operating_hours')) {
      context.handle(
        _operatingHoursMeta,
        operatingHours.isAcceptableOrUnknown(
          data['operating_hours']!,
          _operatingHoursMeta,
        ),
      );
    }
    if (data.containsKey('next_service_hours')) {
      context.handle(
        _nextServiceHoursMeta,
        nextServiceHours.isAcceptableOrUnknown(
          data['next_service_hours']!,
          _nextServiceHoursMeta,
        ),
      );
    }
    if (data.containsKey('last_service_at')) {
      context.handle(
        _lastServiceAtMeta,
        lastServiceAt.isAcceptableOrUnknown(
          data['last_service_at']!,
          _lastServiceAtMeta,
        ),
      );
    }
    if (data.containsKey('status_note')) {
      context.handle(
        _statusNoteMeta,
        statusNote.isAcceptableOrUnknown(data['status_note']!, _statusNoteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Tractor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tractor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      status: $TractorsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      operatingHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operating_hours'],
      )!,
      nextServiceHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_service_hours'],
      ),
      lastServiceAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_service_at'],
      ),
      statusNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_note'],
      ),
    );
  }

  @override
  $TractorsTable createAlias(String alias) {
    return $TractorsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TractorAvailabilityStatus, String, String>
  $converterstatus = const EnumNameConverter<TractorAvailabilityStatus>(
    TractorAvailabilityStatus.values,
  );
}

class Tractor extends DataClass implements Insertable<Tractor> {
  final String id;
  final String code;
  final String model;
  final TractorAvailabilityStatus status;
  final int operatingHours;
  final int? nextServiceHours;
  final DateTime? lastServiceAt;
  final String? statusNote;
  const Tractor({
    required this.id,
    required this.code,
    required this.model,
    required this.status,
    required this.operatingHours,
    this.nextServiceHours,
    this.lastServiceAt,
    this.statusNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['model'] = Variable<String>(model);
    {
      map['status'] = Variable<String>(
        $TractorsTable.$converterstatus.toSql(status),
      );
    }
    map['operating_hours'] = Variable<int>(operatingHours);
    if (!nullToAbsent || nextServiceHours != null) {
      map['next_service_hours'] = Variable<int>(nextServiceHours);
    }
    if (!nullToAbsent || lastServiceAt != null) {
      map['last_service_at'] = Variable<DateTime>(lastServiceAt);
    }
    if (!nullToAbsent || statusNote != null) {
      map['status_note'] = Variable<String>(statusNote);
    }
    return map;
  }

  TractorsCompanion toCompanion(bool nullToAbsent) {
    return TractorsCompanion(
      id: Value(id),
      code: Value(code),
      model: Value(model),
      status: Value(status),
      operatingHours: Value(operatingHours),
      nextServiceHours: nextServiceHours == null && nullToAbsent
          ? const Value.absent()
          : Value(nextServiceHours),
      lastServiceAt: lastServiceAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastServiceAt),
      statusNote: statusNote == null && nullToAbsent
          ? const Value.absent()
          : Value(statusNote),
    );
  }

  factory Tractor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tractor(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      model: serializer.fromJson<String>(json['model']),
      status: $TractorsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      operatingHours: serializer.fromJson<int>(json['operatingHours']),
      nextServiceHours: serializer.fromJson<int?>(json['nextServiceHours']),
      lastServiceAt: serializer.fromJson<DateTime?>(json['lastServiceAt']),
      statusNote: serializer.fromJson<String?>(json['statusNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'model': serializer.toJson<String>(model),
      'status': serializer.toJson<String>(
        $TractorsTable.$converterstatus.toJson(status),
      ),
      'operatingHours': serializer.toJson<int>(operatingHours),
      'nextServiceHours': serializer.toJson<int?>(nextServiceHours),
      'lastServiceAt': serializer.toJson<DateTime?>(lastServiceAt),
      'statusNote': serializer.toJson<String?>(statusNote),
    };
  }

  Tractor copyWith({
    String? id,
    String? code,
    String? model,
    TractorAvailabilityStatus? status,
    int? operatingHours,
    Value<int?> nextServiceHours = const Value.absent(),
    Value<DateTime?> lastServiceAt = const Value.absent(),
    Value<String?> statusNote = const Value.absent(),
  }) => Tractor(
    id: id ?? this.id,
    code: code ?? this.code,
    model: model ?? this.model,
    status: status ?? this.status,
    operatingHours: operatingHours ?? this.operatingHours,
    nextServiceHours: nextServiceHours.present
        ? nextServiceHours.value
        : this.nextServiceHours,
    lastServiceAt: lastServiceAt.present
        ? lastServiceAt.value
        : this.lastServiceAt,
    statusNote: statusNote.present ? statusNote.value : this.statusNote,
  );
  Tractor copyWithCompanion(TractorsCompanion data) {
    return Tractor(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      model: data.model.present ? data.model.value : this.model,
      status: data.status.present ? data.status.value : this.status,
      operatingHours: data.operatingHours.present
          ? data.operatingHours.value
          : this.operatingHours,
      nextServiceHours: data.nextServiceHours.present
          ? data.nextServiceHours.value
          : this.nextServiceHours,
      lastServiceAt: data.lastServiceAt.present
          ? data.lastServiceAt.value
          : this.lastServiceAt,
      statusNote: data.statusNote.present
          ? data.statusNote.value
          : this.statusNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tractor(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('model: $model, ')
          ..write('status: $status, ')
          ..write('operatingHours: $operatingHours, ')
          ..write('nextServiceHours: $nextServiceHours, ')
          ..write('lastServiceAt: $lastServiceAt, ')
          ..write('statusNote: $statusNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    model,
    status,
    operatingHours,
    nextServiceHours,
    lastServiceAt,
    statusNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tractor &&
          other.id == this.id &&
          other.code == this.code &&
          other.model == this.model &&
          other.status == this.status &&
          other.operatingHours == this.operatingHours &&
          other.nextServiceHours == this.nextServiceHours &&
          other.lastServiceAt == this.lastServiceAt &&
          other.statusNote == this.statusNote);
}

class TractorsCompanion extends UpdateCompanion<Tractor> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> model;
  final Value<TractorAvailabilityStatus> status;
  final Value<int> operatingHours;
  final Value<int?> nextServiceHours;
  final Value<DateTime?> lastServiceAt;
  final Value<String?> statusNote;
  final Value<int> rowid;
  const TractorsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.model = const Value.absent(),
    this.status = const Value.absent(),
    this.operatingHours = const Value.absent(),
    this.nextServiceHours = const Value.absent(),
    this.lastServiceAt = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TractorsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String model,
    this.status = const Value.absent(),
    this.operatingHours = const Value.absent(),
    this.nextServiceHours = const Value.absent(),
    this.lastServiceAt = const Value.absent(),
    this.statusNote = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       model = Value(model);
  static Insertable<Tractor> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? model,
    Expression<String>? status,
    Expression<int>? operatingHours,
    Expression<int>? nextServiceHours,
    Expression<DateTime>? lastServiceAt,
    Expression<String>? statusNote,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (model != null) 'model': model,
      if (status != null) 'status': status,
      if (operatingHours != null) 'operating_hours': operatingHours,
      if (nextServiceHours != null) 'next_service_hours': nextServiceHours,
      if (lastServiceAt != null) 'last_service_at': lastServiceAt,
      if (statusNote != null) 'status_note': statusNote,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TractorsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? model,
    Value<TractorAvailabilityStatus>? status,
    Value<int>? operatingHours,
    Value<int?>? nextServiceHours,
    Value<DateTime?>? lastServiceAt,
    Value<String?>? statusNote,
    Value<int>? rowid,
  }) {
    return TractorsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      model: model ?? this.model,
      status: status ?? this.status,
      operatingHours: operatingHours ?? this.operatingHours,
      nextServiceHours: nextServiceHours ?? this.nextServiceHours,
      lastServiceAt: lastServiceAt ?? this.lastServiceAt,
      statusNote: statusNote ?? this.statusNote,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TractorsTable.$converterstatus.toSql(status.value),
      );
    }
    if (operatingHours.present) {
      map['operating_hours'] = Variable<int>(operatingHours.value);
    }
    if (nextServiceHours.present) {
      map['next_service_hours'] = Variable<int>(nextServiceHours.value);
    }
    if (lastServiceAt.present) {
      map['last_service_at'] = Variable<DateTime>(lastServiceAt.value);
    }
    if (statusNote.present) {
      map['status_note'] = Variable<String>(statusNote.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TractorsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('model: $model, ')
          ..write('status: $status, ')
          ..write('operatingHours: $operatingHours, ')
          ..write('nextServiceHours: $nextServiceHours, ')
          ..write('lastServiceAt: $lastServiceAt, ')
          ..write('statusNote: $statusNote, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperatorsTable extends Operators
    with TableInfo<$OperatorsTable, Operator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unionIdMeta = const VerificationMeta(
    'unionId',
  );
  @override
  late final GeneratedColumn<String> unionId = GeneratedColumn<String>(
    'union_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseNumberMeta = const VerificationMeta(
    'licenseNumber',
  );
  @override
  late final GeneratedColumn<String> licenseNumber = GeneratedColumn<String>(
    'license_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    OperatorAvailabilityStatus,
    String
  >
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(OperatorAvailabilityStatus.available.name),
  ).withConverter<OperatorAvailabilityStatus>($OperatorsTable.$converterstatus);
  static const VerificationMeta _assignedTractorIdMeta = const VerificationMeta(
    'assignedTractorId',
  );
  @override
  late final GeneratedColumn<String> assignedTractorId =
      GeneratedColumn<String>(
        'assigned_tractor_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tractors (id)',
        ),
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    unionId,
    licenseNumber,
    status,
    assignedTractorId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operators';
  @override
  VerificationContext validateIntegrity(
    Insertable<Operator> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('union_id')) {
      context.handle(
        _unionIdMeta,
        unionId.isAcceptableOrUnknown(data['union_id']!, _unionIdMeta),
      );
    }
    if (data.containsKey('license_number')) {
      context.handle(
        _licenseNumberMeta,
        licenseNumber.isAcceptableOrUnknown(
          data['license_number']!,
          _licenseNumberMeta,
        ),
      );
    }
    if (data.containsKey('assigned_tractor_id')) {
      context.handle(
        _assignedTractorIdMeta,
        assignedTractorId.isAcceptableOrUnknown(
          data['assigned_tractor_id']!,
          _assignedTractorIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Operator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Operator(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      unionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}union_id'],
      ),
      licenseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_number'],
      ),
      status: $OperatorsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      assignedTractorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_tractor_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $OperatorsTable createAlias(String alias) {
    return $OperatorsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperatorAvailabilityStatus, String, String>
  $converterstatus = const EnumNameConverter<OperatorAvailabilityStatus>(
    OperatorAvailabilityStatus.values,
  );
}

class Operator extends DataClass implements Insertable<Operator> {
  final String id;
  final String userId;
  final String? unionId;
  final String? licenseNumber;
  final OperatorAvailabilityStatus status;
  final String? assignedTractorId;
  final String? note;
  const Operator({
    required this.id,
    required this.userId,
    this.unionId,
    this.licenseNumber,
    required this.status,
    this.assignedTractorId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || unionId != null) {
      map['union_id'] = Variable<String>(unionId);
    }
    if (!nullToAbsent || licenseNumber != null) {
      map['license_number'] = Variable<String>(licenseNumber);
    }
    {
      map['status'] = Variable<String>(
        $OperatorsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || assignedTractorId != null) {
      map['assigned_tractor_id'] = Variable<String>(assignedTractorId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  OperatorsCompanion toCompanion(bool nullToAbsent) {
    return OperatorsCompanion(
      id: Value(id),
      userId: Value(userId),
      unionId: unionId == null && nullToAbsent
          ? const Value.absent()
          : Value(unionId),
      licenseNumber: licenseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseNumber),
      status: Value(status),
      assignedTractorId: assignedTractorId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTractorId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Operator.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Operator(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      unionId: serializer.fromJson<String?>(json['unionId']),
      licenseNumber: serializer.fromJson<String?>(json['licenseNumber']),
      status: $OperatorsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      assignedTractorId: serializer.fromJson<String?>(
        json['assignedTractorId'],
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'unionId': serializer.toJson<String?>(unionId),
      'licenseNumber': serializer.toJson<String?>(licenseNumber),
      'status': serializer.toJson<String>(
        $OperatorsTable.$converterstatus.toJson(status),
      ),
      'assignedTractorId': serializer.toJson<String?>(assignedTractorId),
      'note': serializer.toJson<String?>(note),
    };
  }

  Operator copyWith({
    String? id,
    String? userId,
    Value<String?> unionId = const Value.absent(),
    Value<String?> licenseNumber = const Value.absent(),
    OperatorAvailabilityStatus? status,
    Value<String?> assignedTractorId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => Operator(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    unionId: unionId.present ? unionId.value : this.unionId,
    licenseNumber: licenseNumber.present
        ? licenseNumber.value
        : this.licenseNumber,
    status: status ?? this.status,
    assignedTractorId: assignedTractorId.present
        ? assignedTractorId.value
        : this.assignedTractorId,
    note: note.present ? note.value : this.note,
  );
  Operator copyWithCompanion(OperatorsCompanion data) {
    return Operator(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      unionId: data.unionId.present ? data.unionId.value : this.unionId,
      licenseNumber: data.licenseNumber.present
          ? data.licenseNumber.value
          : this.licenseNumber,
      status: data.status.present ? data.status.value : this.status,
      assignedTractorId: data.assignedTractorId.present
          ? data.assignedTractorId.value
          : this.assignedTractorId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Operator(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('status: $status, ')
          ..write('assignedTractorId: $assignedTractorId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    unionId,
    licenseNumber,
    status,
    assignedTractorId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Operator &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.unionId == this.unionId &&
          other.licenseNumber == this.licenseNumber &&
          other.status == this.status &&
          other.assignedTractorId == this.assignedTractorId &&
          other.note == this.note);
}

class OperatorsCompanion extends UpdateCompanion<Operator> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> unionId;
  final Value<String?> licenseNumber;
  final Value<OperatorAvailabilityStatus> status;
  final Value<String?> assignedTractorId;
  final Value<String?> note;
  final Value<int> rowid;
  const OperatorsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.unionId = const Value.absent(),
    this.licenseNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTractorId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperatorsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.unionId = const Value.absent(),
    this.licenseNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTractorId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<Operator> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? unionId,
    Expression<String>? licenseNumber,
    Expression<String>? status,
    Expression<String>? assignedTractorId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (unionId != null) 'union_id': unionId,
      if (licenseNumber != null) 'license_number': licenseNumber,
      if (status != null) 'status': status,
      if (assignedTractorId != null) 'assigned_tractor_id': assignedTractorId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperatorsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? unionId,
    Value<String?>? licenseNumber,
    Value<OperatorAvailabilityStatus>? status,
    Value<String?>? assignedTractorId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return OperatorsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      unionId: unionId ?? this.unionId,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      status: status ?? this.status,
      assignedTractorId: assignedTractorId ?? this.assignedTractorId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (unionId.present) {
      map['union_id'] = Variable<String>(unionId.value);
    }
    if (licenseNumber.present) {
      map['license_number'] = Variable<String>(licenseNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $OperatorsTable.$converterstatus.toSql(status.value),
      );
    }
    if (assignedTractorId.present) {
      map['assigned_tractor_id'] = Variable<String>(assignedTractorId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OperatorsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('licenseNumber: $licenseNumber, ')
          ..write('status: $status, ')
          ..write('assignedTractorId: $assignedTractorId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManagerProfilesTable extends ManagerProfiles
    with TableInfo<$ManagerProfilesTable, ManagerProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManagerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unionIdMeta = const VerificationMeta(
    'unionId',
  );
  @override
  late final GeneratedColumn<String> unionId = GeneratedColumn<String>(
    'union_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeNumberMeta = const VerificationMeta(
    'employeeNumber',
  );
  @override
  late final GeneratedColumn<String> employeeNumber = GeneratedColumn<String>(
    'employee_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionTitleMeta = const VerificationMeta(
    'positionTitle',
  );
  @override
  late final GeneratedColumn<String> positionTitle = GeneratedColumn<String>(
    'position_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    unionId,
    employeeNumber,
    positionTitle,
    department,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manager_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManagerProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('union_id')) {
      context.handle(
        _unionIdMeta,
        unionId.isAcceptableOrUnknown(data['union_id']!, _unionIdMeta),
      );
    }
    if (data.containsKey('employee_number')) {
      context.handle(
        _employeeNumberMeta,
        employeeNumber.isAcceptableOrUnknown(
          data['employee_number']!,
          _employeeNumberMeta,
        ),
      );
    }
    if (data.containsKey('position_title')) {
      context.handle(
        _positionTitleMeta,
        positionTitle.isAcceptableOrUnknown(
          data['position_title']!,
          _positionTitleMeta,
        ),
      );
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ManagerProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManagerProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      unionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}union_id'],
      ),
      employeeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_number'],
      ),
      positionTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_title'],
      ),
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      ),
    );
  }

  @override
  $ManagerProfilesTable createAlias(String alias) {
    return $ManagerProfilesTable(attachedDatabase, alias);
  }
}

class ManagerProfile extends DataClass implements Insertable<ManagerProfile> {
  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? positionTitle;
  final String? department;
  const ManagerProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.positionTitle,
    this.department,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || unionId != null) {
      map['union_id'] = Variable<String>(unionId);
    }
    if (!nullToAbsent || employeeNumber != null) {
      map['employee_number'] = Variable<String>(employeeNumber);
    }
    if (!nullToAbsent || positionTitle != null) {
      map['position_title'] = Variable<String>(positionTitle);
    }
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    return map;
  }

  ManagerProfilesCompanion toCompanion(bool nullToAbsent) {
    return ManagerProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      unionId: unionId == null && nullToAbsent
          ? const Value.absent()
          : Value(unionId),
      employeeNumber: employeeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeNumber),
      positionTitle: positionTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(positionTitle),
      department: department == null && nullToAbsent
          ? const Value.absent()
          : Value(department),
    );
  }

  factory ManagerProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManagerProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      unionId: serializer.fromJson<String?>(json['unionId']),
      employeeNumber: serializer.fromJson<String?>(json['employeeNumber']),
      positionTitle: serializer.fromJson<String?>(json['positionTitle']),
      department: serializer.fromJson<String?>(json['department']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'unionId': serializer.toJson<String?>(unionId),
      'employeeNumber': serializer.toJson<String?>(employeeNumber),
      'positionTitle': serializer.toJson<String?>(positionTitle),
      'department': serializer.toJson<String?>(department),
    };
  }

  ManagerProfile copyWith({
    String? id,
    String? userId,
    Value<String?> unionId = const Value.absent(),
    Value<String?> employeeNumber = const Value.absent(),
    Value<String?> positionTitle = const Value.absent(),
    Value<String?> department = const Value.absent(),
  }) => ManagerProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    unionId: unionId.present ? unionId.value : this.unionId,
    employeeNumber: employeeNumber.present
        ? employeeNumber.value
        : this.employeeNumber,
    positionTitle: positionTitle.present
        ? positionTitle.value
        : this.positionTitle,
    department: department.present ? department.value : this.department,
  );
  ManagerProfile copyWithCompanion(ManagerProfilesCompanion data) {
    return ManagerProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      unionId: data.unionId.present ? data.unionId.value : this.unionId,
      employeeNumber: data.employeeNumber.present
          ? data.employeeNumber.value
          : this.employeeNumber,
      positionTitle: data.positionTitle.present
          ? data.positionTitle.value
          : this.positionTitle,
      department: data.department.present
          ? data.department.value
          : this.department,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManagerProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('employeeNumber: $employeeNumber, ')
          ..write('positionTitle: $positionTitle, ')
          ..write('department: $department')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    unionId,
    employeeNumber,
    positionTitle,
    department,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManagerProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.unionId == this.unionId &&
          other.employeeNumber == this.employeeNumber &&
          other.positionTitle == this.positionTitle &&
          other.department == this.department);
}

class ManagerProfilesCompanion extends UpdateCompanion<ManagerProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> unionId;
  final Value<String?> employeeNumber;
  final Value<String?> positionTitle;
  final Value<String?> department;
  final Value<int> rowid;
  const ManagerProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.unionId = const Value.absent(),
    this.employeeNumber = const Value.absent(),
    this.positionTitle = const Value.absent(),
    this.department = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManagerProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.unionId = const Value.absent(),
    this.employeeNumber = const Value.absent(),
    this.positionTitle = const Value.absent(),
    this.department = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<ManagerProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? unionId,
    Expression<String>? employeeNumber,
    Expression<String>? positionTitle,
    Expression<String>? department,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (unionId != null) 'union_id': unionId,
      if (employeeNumber != null) 'employee_number': employeeNumber,
      if (positionTitle != null) 'position_title': positionTitle,
      if (department != null) 'department': department,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManagerProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? unionId,
    Value<String?>? employeeNumber,
    Value<String?>? positionTitle,
    Value<String?>? department,
    Value<int>? rowid,
  }) {
    return ManagerProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      unionId: unionId ?? this.unionId,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      positionTitle: positionTitle ?? this.positionTitle,
      department: department ?? this.department,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (unionId.present) {
      map['union_id'] = Variable<String>(unionId.value);
    }
    if (employeeNumber.present) {
      map['employee_number'] = Variable<String>(employeeNumber.value);
    }
    if (positionTitle.present) {
      map['position_title'] = Variable<String>(positionTitle.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManagerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('employeeNumber: $employeeNumber, ')
          ..write('positionTitle: $positionTitle, ')
          ..write('department: $department, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DispatcherProfilesTable extends DispatcherProfiles
    with TableInfo<$DispatcherProfilesTable, DispatcherProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DispatcherProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unionIdMeta = const VerificationMeta(
    'unionId',
  );
  @override
  late final GeneratedColumn<String> unionId = GeneratedColumn<String>(
    'union_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeNumberMeta = const VerificationMeta(
    'employeeNumber',
  );
  @override
  late final GeneratedColumn<String> employeeNumber = GeneratedColumn<String>(
    'employee_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dispatchZoneMeta = const VerificationMeta(
    'dispatchZone',
  );
  @override
  late final GeneratedColumn<String> dispatchZone = GeneratedColumn<String>(
    'dispatch_zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radioCallSignMeta = const VerificationMeta(
    'radioCallSign',
  );
  @override
  late final GeneratedColumn<String> radioCallSign = GeneratedColumn<String>(
    'radio_call_sign',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    unionId,
    employeeNumber,
    dispatchZone,
    radioCallSign,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dispatcher_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<DispatcherProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('union_id')) {
      context.handle(
        _unionIdMeta,
        unionId.isAcceptableOrUnknown(data['union_id']!, _unionIdMeta),
      );
    }
    if (data.containsKey('employee_number')) {
      context.handle(
        _employeeNumberMeta,
        employeeNumber.isAcceptableOrUnknown(
          data['employee_number']!,
          _employeeNumberMeta,
        ),
      );
    }
    if (data.containsKey('dispatch_zone')) {
      context.handle(
        _dispatchZoneMeta,
        dispatchZone.isAcceptableOrUnknown(
          data['dispatch_zone']!,
          _dispatchZoneMeta,
        ),
      );
    }
    if (data.containsKey('radio_call_sign')) {
      context.handle(
        _radioCallSignMeta,
        radioCallSign.isAcceptableOrUnknown(
          data['radio_call_sign']!,
          _radioCallSignMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DispatcherProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DispatcherProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      unionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}union_id'],
      ),
      employeeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_number'],
      ),
      dispatchZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dispatch_zone'],
      ),
      radioCallSign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}radio_call_sign'],
      ),
    );
  }

  @override
  $DispatcherProfilesTable createAlias(String alias) {
    return $DispatcherProfilesTable(attachedDatabase, alias);
  }
}

class DispatcherProfile extends DataClass
    implements Insertable<DispatcherProfile> {
  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? dispatchZone;
  final String? radioCallSign;
  const DispatcherProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.dispatchZone,
    this.radioCallSign,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || unionId != null) {
      map['union_id'] = Variable<String>(unionId);
    }
    if (!nullToAbsent || employeeNumber != null) {
      map['employee_number'] = Variable<String>(employeeNumber);
    }
    if (!nullToAbsent || dispatchZone != null) {
      map['dispatch_zone'] = Variable<String>(dispatchZone);
    }
    if (!nullToAbsent || radioCallSign != null) {
      map['radio_call_sign'] = Variable<String>(radioCallSign);
    }
    return map;
  }

  DispatcherProfilesCompanion toCompanion(bool nullToAbsent) {
    return DispatcherProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      unionId: unionId == null && nullToAbsent
          ? const Value.absent()
          : Value(unionId),
      employeeNumber: employeeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeNumber),
      dispatchZone: dispatchZone == null && nullToAbsent
          ? const Value.absent()
          : Value(dispatchZone),
      radioCallSign: radioCallSign == null && nullToAbsent
          ? const Value.absent()
          : Value(radioCallSign),
    );
  }

  factory DispatcherProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DispatcherProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      unionId: serializer.fromJson<String?>(json['unionId']),
      employeeNumber: serializer.fromJson<String?>(json['employeeNumber']),
      dispatchZone: serializer.fromJson<String?>(json['dispatchZone']),
      radioCallSign: serializer.fromJson<String?>(json['radioCallSign']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'unionId': serializer.toJson<String?>(unionId),
      'employeeNumber': serializer.toJson<String?>(employeeNumber),
      'dispatchZone': serializer.toJson<String?>(dispatchZone),
      'radioCallSign': serializer.toJson<String?>(radioCallSign),
    };
  }

  DispatcherProfile copyWith({
    String? id,
    String? userId,
    Value<String?> unionId = const Value.absent(),
    Value<String?> employeeNumber = const Value.absent(),
    Value<String?> dispatchZone = const Value.absent(),
    Value<String?> radioCallSign = const Value.absent(),
  }) => DispatcherProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    unionId: unionId.present ? unionId.value : this.unionId,
    employeeNumber: employeeNumber.present
        ? employeeNumber.value
        : this.employeeNumber,
    dispatchZone: dispatchZone.present ? dispatchZone.value : this.dispatchZone,
    radioCallSign: radioCallSign.present
        ? radioCallSign.value
        : this.radioCallSign,
  );
  DispatcherProfile copyWithCompanion(DispatcherProfilesCompanion data) {
    return DispatcherProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      unionId: data.unionId.present ? data.unionId.value : this.unionId,
      employeeNumber: data.employeeNumber.present
          ? data.employeeNumber.value
          : this.employeeNumber,
      dispatchZone: data.dispatchZone.present
          ? data.dispatchZone.value
          : this.dispatchZone,
      radioCallSign: data.radioCallSign.present
          ? data.radioCallSign.value
          : this.radioCallSign,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DispatcherProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('employeeNumber: $employeeNumber, ')
          ..write('dispatchZone: $dispatchZone, ')
          ..write('radioCallSign: $radioCallSign')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    unionId,
    employeeNumber,
    dispatchZone,
    radioCallSign,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DispatcherProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.unionId == this.unionId &&
          other.employeeNumber == this.employeeNumber &&
          other.dispatchZone == this.dispatchZone &&
          other.radioCallSign == this.radioCallSign);
}

class DispatcherProfilesCompanion extends UpdateCompanion<DispatcherProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> unionId;
  final Value<String?> employeeNumber;
  final Value<String?> dispatchZone;
  final Value<String?> radioCallSign;
  final Value<int> rowid;
  const DispatcherProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.unionId = const Value.absent(),
    this.employeeNumber = const Value.absent(),
    this.dispatchZone = const Value.absent(),
    this.radioCallSign = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DispatcherProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.unionId = const Value.absent(),
    this.employeeNumber = const Value.absent(),
    this.dispatchZone = const Value.absent(),
    this.radioCallSign = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<DispatcherProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? unionId,
    Expression<String>? employeeNumber,
    Expression<String>? dispatchZone,
    Expression<String>? radioCallSign,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (unionId != null) 'union_id': unionId,
      if (employeeNumber != null) 'employee_number': employeeNumber,
      if (dispatchZone != null) 'dispatch_zone': dispatchZone,
      if (radioCallSign != null) 'radio_call_sign': radioCallSign,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DispatcherProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? unionId,
    Value<String?>? employeeNumber,
    Value<String?>? dispatchZone,
    Value<String?>? radioCallSign,
    Value<int>? rowid,
  }) {
    return DispatcherProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      unionId: unionId ?? this.unionId,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      dispatchZone: dispatchZone ?? this.dispatchZone,
      radioCallSign: radioCallSign ?? this.radioCallSign,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (unionId.present) {
      map['union_id'] = Variable<String>(unionId.value);
    }
    if (employeeNumber.present) {
      map['employee_number'] = Variable<String>(employeeNumber.value);
    }
    if (dispatchZone.present) {
      map['dispatch_zone'] = Variable<String>(dispatchZone.value);
    }
    if (radioCallSign.present) {
      map['radio_call_sign'] = Variable<String>(radioCallSign.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DispatcherProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('employeeNumber: $employeeNumber, ')
          ..write('dispatchZone: $dispatchZone, ')
          ..write('radioCallSign: $radioCallSign, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TechnicianProfilesTable extends TechnicianProfiles
    with TableInfo<$TechnicianProfilesTable, TechnicianProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TechnicianProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unionIdMeta = const VerificationMeta(
    'unionId',
  );
  @override
  late final GeneratedColumn<String> unionId = GeneratedColumn<String>(
    'union_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _employeeNumberMeta = const VerificationMeta(
    'employeeNumber',
  );
  @override
  late final GeneratedColumn<String> employeeNumber = GeneratedColumn<String>(
    'employee_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specializationMeta = const VerificationMeta(
    'specialization',
  );
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
    'specialization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _certificationNumberMeta =
      const VerificationMeta('certificationNumber');
  @override
  late final GeneratedColumn<String> certificationNumber =
      GeneratedColumn<String>(
        'certification_number',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    unionId,
    employeeNumber,
    specialization,
    certificationNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'technician_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<TechnicianProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('union_id')) {
      context.handle(
        _unionIdMeta,
        unionId.isAcceptableOrUnknown(data['union_id']!, _unionIdMeta),
      );
    }
    if (data.containsKey('employee_number')) {
      context.handle(
        _employeeNumberMeta,
        employeeNumber.isAcceptableOrUnknown(
          data['employee_number']!,
          _employeeNumberMeta,
        ),
      );
    }
    if (data.containsKey('specialization')) {
      context.handle(
        _specializationMeta,
        specialization.isAcceptableOrUnknown(
          data['specialization']!,
          _specializationMeta,
        ),
      );
    }
    if (data.containsKey('certification_number')) {
      context.handle(
        _certificationNumberMeta,
        certificationNumber.isAcceptableOrUnknown(
          data['certification_number']!,
          _certificationNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  TechnicianProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TechnicianProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      unionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}union_id'],
      ),
      employeeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_number'],
      ),
      specialization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialization'],
      ),
      certificationNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}certification_number'],
      ),
    );
  }

  @override
  $TechnicianProfilesTable createAlias(String alias) {
    return $TechnicianProfilesTable(attachedDatabase, alias);
  }
}

class TechnicianProfile extends DataClass
    implements Insertable<TechnicianProfile> {
  final String id;
  final String userId;
  final String? unionId;
  final String? employeeNumber;
  final String? specialization;
  final String? certificationNumber;
  const TechnicianProfile({
    required this.id,
    required this.userId,
    this.unionId,
    this.employeeNumber,
    this.specialization,
    this.certificationNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || unionId != null) {
      map['union_id'] = Variable<String>(unionId);
    }
    if (!nullToAbsent || employeeNumber != null) {
      map['employee_number'] = Variable<String>(employeeNumber);
    }
    if (!nullToAbsent || specialization != null) {
      map['specialization'] = Variable<String>(specialization);
    }
    if (!nullToAbsent || certificationNumber != null) {
      map['certification_number'] = Variable<String>(certificationNumber);
    }
    return map;
  }

  TechnicianProfilesCompanion toCompanion(bool nullToAbsent) {
    return TechnicianProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      unionId: unionId == null && nullToAbsent
          ? const Value.absent()
          : Value(unionId),
      employeeNumber: employeeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(employeeNumber),
      specialization: specialization == null && nullToAbsent
          ? const Value.absent()
          : Value(specialization),
      certificationNumber: certificationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(certificationNumber),
    );
  }

  factory TechnicianProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TechnicianProfile(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      unionId: serializer.fromJson<String?>(json['unionId']),
      employeeNumber: serializer.fromJson<String?>(json['employeeNumber']),
      specialization: serializer.fromJson<String?>(json['specialization']),
      certificationNumber: serializer.fromJson<String?>(
        json['certificationNumber'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'unionId': serializer.toJson<String?>(unionId),
      'employeeNumber': serializer.toJson<String?>(employeeNumber),
      'specialization': serializer.toJson<String?>(specialization),
      'certificationNumber': serializer.toJson<String?>(certificationNumber),
    };
  }

  TechnicianProfile copyWith({
    String? id,
    String? userId,
    Value<String?> unionId = const Value.absent(),
    Value<String?> employeeNumber = const Value.absent(),
    Value<String?> specialization = const Value.absent(),
    Value<String?> certificationNumber = const Value.absent(),
  }) => TechnicianProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    unionId: unionId.present ? unionId.value : this.unionId,
    employeeNumber: employeeNumber.present
        ? employeeNumber.value
        : this.employeeNumber,
    specialization: specialization.present
        ? specialization.value
        : this.specialization,
    certificationNumber: certificationNumber.present
        ? certificationNumber.value
        : this.certificationNumber,
  );
  TechnicianProfile copyWithCompanion(TechnicianProfilesCompanion data) {
    return TechnicianProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      unionId: data.unionId.present ? data.unionId.value : this.unionId,
      employeeNumber: data.employeeNumber.present
          ? data.employeeNumber.value
          : this.employeeNumber,
      specialization: data.specialization.present
          ? data.specialization.value
          : this.specialization,
      certificationNumber: data.certificationNumber.present
          ? data.certificationNumber.value
          : this.certificationNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TechnicianProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('employeeNumber: $employeeNumber, ')
          ..write('specialization: $specialization, ')
          ..write('certificationNumber: $certificationNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    unionId,
    employeeNumber,
    specialization,
    certificationNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TechnicianProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.unionId == this.unionId &&
          other.employeeNumber == this.employeeNumber &&
          other.specialization == this.specialization &&
          other.certificationNumber == this.certificationNumber);
}

class TechnicianProfilesCompanion extends UpdateCompanion<TechnicianProfile> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> unionId;
  final Value<String?> employeeNumber;
  final Value<String?> specialization;
  final Value<String?> certificationNumber;
  final Value<int> rowid;
  const TechnicianProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.unionId = const Value.absent(),
    this.employeeNumber = const Value.absent(),
    this.specialization = const Value.absent(),
    this.certificationNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TechnicianProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.unionId = const Value.absent(),
    this.employeeNumber = const Value.absent(),
    this.specialization = const Value.absent(),
    this.certificationNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<TechnicianProfile> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? unionId,
    Expression<String>? employeeNumber,
    Expression<String>? specialization,
    Expression<String>? certificationNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (unionId != null) 'union_id': unionId,
      if (employeeNumber != null) 'employee_number': employeeNumber,
      if (specialization != null) 'specialization': specialization,
      if (certificationNumber != null)
        'certification_number': certificationNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TechnicianProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? unionId,
    Value<String?>? employeeNumber,
    Value<String?>? specialization,
    Value<String?>? certificationNumber,
    Value<int>? rowid,
  }) {
    return TechnicianProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      unionId: unionId ?? this.unionId,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      specialization: specialization ?? this.specialization,
      certificationNumber: certificationNumber ?? this.certificationNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (unionId.present) {
      map['union_id'] = Variable<String>(unionId.value);
    }
    if (employeeNumber.present) {
      map['employee_number'] = Variable<String>(employeeNumber.value);
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    if (certificationNumber.present) {
      map['certification_number'] = Variable<String>(certificationNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TechnicianProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('unionId: $unionId, ')
          ..write('employeeNumber: $employeeNumber, ')
          ..write('specialization: $specialization, ')
          ..write('certificationNumber: $certificationNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _jobNumberMeta = const VerificationMeta(
    'jobNumber',
  );
  @override
  late final GeneratedColumn<String> jobNumber = GeneratedColumn<String>(
    'job_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _serviceRequestIdMeta = const VerificationMeta(
    'serviceRequestId',
  );
  @override
  late final GeneratedColumn<String> serviceRequestId = GeneratedColumn<String>(
    'service_request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_requests (id)',
    ),
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farmers (id)',
    ),
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farm_plots (id)',
    ),
  );
  static const VerificationMeta _tractorIdMeta = const VerificationMeta(
    'tractorId',
  );
  @override
  late final GeneratedColumn<String> tractorId = GeneratedColumn<String>(
    'tractor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tractors (id)',
    ),
  );
  static const VerificationMeta _operatorIdMeta = const VerificationMeta(
    'operatorId',
  );
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
    'operator_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES operators (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ServiceKind, String> serviceKind =
      GeneratedColumn<String>(
        'service_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ServiceKind>($JobsTable.$converterserviceKind);
  @override
  late final GeneratedColumnWithTypeConverter<JobStatusDb, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(JobStatusDb.scheduled.name),
      ).withConverter<JobStatusDb>($JobsTable.$converterstatus);
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedDurationMinutesMeta =
      const VerificationMeta('estimatedDurationMinutes');
  @override
  late final GeneratedColumn<int> estimatedDurationMinutes =
      GeneratedColumn<int>(
        'estimated_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _dispatchedAtMeta = const VerificationMeta(
    'dispatchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> dispatchedAt = GeneratedColumn<DateTime>(
    'dispatched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _journeyStartedAtMeta = const VerificationMeta(
    'journeyStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> journeyStartedAt =
      GeneratedColumn<DateTime>(
        'journey_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _arrivedAtMeta = const VerificationMeta(
    'arrivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> arrivedAt = GeneratedColumn<DateTime>(
    'arrived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _areaServicedHectaresMeta =
      const VerificationMeta('areaServicedHectares');
  @override
  late final GeneratedColumn<double> areaServicedHectares =
      GeneratedColumn<double>(
        'area_serviced_hectares',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _completionNotesMeta = const VerificationMeta(
    'completionNotes',
  );
  @override
  late final GeneratedColumn<String> completionNotes = GeneratedColumn<String>(
    'completion_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobNumber,
    serviceRequestId,
    farmerId,
    plotId,
    tractorId,
    operatorId,
    serviceKind,
    status,
    scheduledAt,
    estimatedDurationMinutes,
    dispatchedAt,
    journeyStartedAt,
    arrivedAt,
    startedAt,
    finishedAt,
    areaServicedHectares,
    completionNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_number')) {
      context.handle(
        _jobNumberMeta,
        jobNumber.isAcceptableOrUnknown(data['job_number']!, _jobNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_jobNumberMeta);
    }
    if (data.containsKey('service_request_id')) {
      context.handle(
        _serviceRequestIdMeta,
        serviceRequestId.isAcceptableOrUnknown(
          data['service_request_id']!,
          _serviceRequestIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceRequestIdMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('plot_id')) {
      context.handle(
        _plotIdMeta,
        plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('tractor_id')) {
      context.handle(
        _tractorIdMeta,
        tractorId.isAcceptableOrUnknown(data['tractor_id']!, _tractorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tractorIdMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
        _operatorIdMeta,
        operatorId.isAcceptableOrUnknown(data['operator_id']!, _operatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('estimated_duration_minutes')) {
      context.handle(
        _estimatedDurationMinutesMeta,
        estimatedDurationMinutes.isAcceptableOrUnknown(
          data['estimated_duration_minutes']!,
          _estimatedDurationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedDurationMinutesMeta);
    }
    if (data.containsKey('dispatched_at')) {
      context.handle(
        _dispatchedAtMeta,
        dispatchedAt.isAcceptableOrUnknown(
          data['dispatched_at']!,
          _dispatchedAtMeta,
        ),
      );
    }
    if (data.containsKey('journey_started_at')) {
      context.handle(
        _journeyStartedAtMeta,
        journeyStartedAt.isAcceptableOrUnknown(
          data['journey_started_at']!,
          _journeyStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('arrived_at')) {
      context.handle(
        _arrivedAtMeta,
        arrivedAt.isAcceptableOrUnknown(data['arrived_at']!, _arrivedAtMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('area_serviced_hectares')) {
      context.handle(
        _areaServicedHectaresMeta,
        areaServicedHectares.isAcceptableOrUnknown(
          data['area_serviced_hectares']!,
          _areaServicedHectaresMeta,
        ),
      );
    }
    if (data.containsKey('completion_notes')) {
      context.handle(
        _completionNotesMeta,
        completionNotes.isAcceptableOrUnknown(
          data['completion_notes']!,
          _completionNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_number'],
      )!,
      serviceRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_request_id'],
      )!,
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      )!,
      plotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_id'],
      )!,
      tractorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tractor_id'],
      )!,
      operatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_id'],
      )!,
      serviceKind: $JobsTable.$converterserviceKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}service_kind'],
        )!,
      ),
      status: $JobsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      estimatedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_duration_minutes'],
      )!,
      dispatchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dispatched_at'],
      ),
      journeyStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}journey_started_at'],
      ),
      arrivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrived_at'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      areaServicedHectares: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_serviced_hectares'],
      ),
      completionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_notes'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ServiceKind, String, String> $converterserviceKind =
      const EnumNameConverter<ServiceKind>(ServiceKind.values);
  static JsonTypeConverter2<JobStatusDb, String, String> $converterstatus =
      const EnumNameConverter<JobStatusDb>(JobStatusDb.values);
}

class Job extends DataClass implements Insertable<Job> {
  final String id;
  final String jobNumber;
  final String serviceRequestId;
  final String farmerId;
  final String plotId;
  final String tractorId;
  final String operatorId;
  final ServiceKind serviceKind;
  final JobStatusDb status;
  final DateTime scheduledAt;
  final int estimatedDurationMinutes;
  final DateTime? dispatchedAt;
  final DateTime? journeyStartedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final double? areaServicedHectares;
  final String? completionNotes;
  const Job({
    required this.id,
    required this.jobNumber,
    required this.serviceRequestId,
    required this.farmerId,
    required this.plotId,
    required this.tractorId,
    required this.operatorId,
    required this.serviceKind,
    required this.status,
    required this.scheduledAt,
    required this.estimatedDurationMinutes,
    this.dispatchedAt,
    this.journeyStartedAt,
    this.arrivedAt,
    this.startedAt,
    this.finishedAt,
    this.areaServicedHectares,
    this.completionNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_number'] = Variable<String>(jobNumber);
    map['service_request_id'] = Variable<String>(serviceRequestId);
    map['farmer_id'] = Variable<String>(farmerId);
    map['plot_id'] = Variable<String>(plotId);
    map['tractor_id'] = Variable<String>(tractorId);
    map['operator_id'] = Variable<String>(operatorId);
    {
      map['service_kind'] = Variable<String>(
        $JobsTable.$converterserviceKind.toSql(serviceKind),
      );
    }
    {
      map['status'] = Variable<String>(
        $JobsTable.$converterstatus.toSql(status),
      );
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['estimated_duration_minutes'] = Variable<int>(estimatedDurationMinutes);
    if (!nullToAbsent || dispatchedAt != null) {
      map['dispatched_at'] = Variable<DateTime>(dispatchedAt);
    }
    if (!nullToAbsent || journeyStartedAt != null) {
      map['journey_started_at'] = Variable<DateTime>(journeyStartedAt);
    }
    if (!nullToAbsent || arrivedAt != null) {
      map['arrived_at'] = Variable<DateTime>(arrivedAt);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    if (!nullToAbsent || areaServicedHectares != null) {
      map['area_serviced_hectares'] = Variable<double>(areaServicedHectares);
    }
    if (!nullToAbsent || completionNotes != null) {
      map['completion_notes'] = Variable<String>(completionNotes);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      jobNumber: Value(jobNumber),
      serviceRequestId: Value(serviceRequestId),
      farmerId: Value(farmerId),
      plotId: Value(plotId),
      tractorId: Value(tractorId),
      operatorId: Value(operatorId),
      serviceKind: Value(serviceKind),
      status: Value(status),
      scheduledAt: Value(scheduledAt),
      estimatedDurationMinutes: Value(estimatedDurationMinutes),
      dispatchedAt: dispatchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dispatchedAt),
      journeyStartedAt: journeyStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(journeyStartedAt),
      arrivedAt: arrivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      areaServicedHectares: areaServicedHectares == null && nullToAbsent
          ? const Value.absent()
          : Value(areaServicedHectares),
      completionNotes: completionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(completionNotes),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<String>(json['id']),
      jobNumber: serializer.fromJson<String>(json['jobNumber']),
      serviceRequestId: serializer.fromJson<String>(json['serviceRequestId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      plotId: serializer.fromJson<String>(json['plotId']),
      tractorId: serializer.fromJson<String>(json['tractorId']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      serviceKind: $JobsTable.$converterserviceKind.fromJson(
        serializer.fromJson<String>(json['serviceKind']),
      ),
      status: $JobsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      estimatedDurationMinutes: serializer.fromJson<int>(
        json['estimatedDurationMinutes'],
      ),
      dispatchedAt: serializer.fromJson<DateTime?>(json['dispatchedAt']),
      journeyStartedAt: serializer.fromJson<DateTime?>(
        json['journeyStartedAt'],
      ),
      arrivedAt: serializer.fromJson<DateTime?>(json['arrivedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      areaServicedHectares: serializer.fromJson<double?>(
        json['areaServicedHectares'],
      ),
      completionNotes: serializer.fromJson<String?>(json['completionNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobNumber': serializer.toJson<String>(jobNumber),
      'serviceRequestId': serializer.toJson<String>(serviceRequestId),
      'farmerId': serializer.toJson<String>(farmerId),
      'plotId': serializer.toJson<String>(plotId),
      'tractorId': serializer.toJson<String>(tractorId),
      'operatorId': serializer.toJson<String>(operatorId),
      'serviceKind': serializer.toJson<String>(
        $JobsTable.$converterserviceKind.toJson(serviceKind),
      ),
      'status': serializer.toJson<String>(
        $JobsTable.$converterstatus.toJson(status),
      ),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'estimatedDurationMinutes': serializer.toJson<int>(
        estimatedDurationMinutes,
      ),
      'dispatchedAt': serializer.toJson<DateTime?>(dispatchedAt),
      'journeyStartedAt': serializer.toJson<DateTime?>(journeyStartedAt),
      'arrivedAt': serializer.toJson<DateTime?>(arrivedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'areaServicedHectares': serializer.toJson<double?>(areaServicedHectares),
      'completionNotes': serializer.toJson<String?>(completionNotes),
    };
  }

  Job copyWith({
    String? id,
    String? jobNumber,
    String? serviceRequestId,
    String? farmerId,
    String? plotId,
    String? tractorId,
    String? operatorId,
    ServiceKind? serviceKind,
    JobStatusDb? status,
    DateTime? scheduledAt,
    int? estimatedDurationMinutes,
    Value<DateTime?> dispatchedAt = const Value.absent(),
    Value<DateTime?> journeyStartedAt = const Value.absent(),
    Value<DateTime?> arrivedAt = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<double?> areaServicedHectares = const Value.absent(),
    Value<String?> completionNotes = const Value.absent(),
  }) => Job(
    id: id ?? this.id,
    jobNumber: jobNumber ?? this.jobNumber,
    serviceRequestId: serviceRequestId ?? this.serviceRequestId,
    farmerId: farmerId ?? this.farmerId,
    plotId: plotId ?? this.plotId,
    tractorId: tractorId ?? this.tractorId,
    operatorId: operatorId ?? this.operatorId,
    serviceKind: serviceKind ?? this.serviceKind,
    status: status ?? this.status,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    estimatedDurationMinutes:
        estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    dispatchedAt: dispatchedAt.present ? dispatchedAt.value : this.dispatchedAt,
    journeyStartedAt: journeyStartedAt.present
        ? journeyStartedAt.value
        : this.journeyStartedAt,
    arrivedAt: arrivedAt.present ? arrivedAt.value : this.arrivedAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    areaServicedHectares: areaServicedHectares.present
        ? areaServicedHectares.value
        : this.areaServicedHectares,
    completionNotes: completionNotes.present
        ? completionNotes.value
        : this.completionNotes,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      jobNumber: data.jobNumber.present ? data.jobNumber.value : this.jobNumber,
      serviceRequestId: data.serviceRequestId.present
          ? data.serviceRequestId.value
          : this.serviceRequestId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      tractorId: data.tractorId.present ? data.tractorId.value : this.tractorId,
      operatorId: data.operatorId.present
          ? data.operatorId.value
          : this.operatorId,
      serviceKind: data.serviceKind.present
          ? data.serviceKind.value
          : this.serviceKind,
      status: data.status.present ? data.status.value : this.status,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      estimatedDurationMinutes: data.estimatedDurationMinutes.present
          ? data.estimatedDurationMinutes.value
          : this.estimatedDurationMinutes,
      dispatchedAt: data.dispatchedAt.present
          ? data.dispatchedAt.value
          : this.dispatchedAt,
      journeyStartedAt: data.journeyStartedAt.present
          ? data.journeyStartedAt.value
          : this.journeyStartedAt,
      arrivedAt: data.arrivedAt.present ? data.arrivedAt.value : this.arrivedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      areaServicedHectares: data.areaServicedHectares.present
          ? data.areaServicedHectares.value
          : this.areaServicedHectares,
      completionNotes: data.completionNotes.present
          ? data.completionNotes.value
          : this.completionNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('jobNumber: $jobNumber, ')
          ..write('serviceRequestId: $serviceRequestId, ')
          ..write('farmerId: $farmerId, ')
          ..write('plotId: $plotId, ')
          ..write('tractorId: $tractorId, ')
          ..write('operatorId: $operatorId, ')
          ..write('serviceKind: $serviceKind, ')
          ..write('status: $status, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('dispatchedAt: $dispatchedAt, ')
          ..write('journeyStartedAt: $journeyStartedAt, ')
          ..write('arrivedAt: $arrivedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('areaServicedHectares: $areaServicedHectares, ')
          ..write('completionNotes: $completionNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobNumber,
    serviceRequestId,
    farmerId,
    plotId,
    tractorId,
    operatorId,
    serviceKind,
    status,
    scheduledAt,
    estimatedDurationMinutes,
    dispatchedAt,
    journeyStartedAt,
    arrivedAt,
    startedAt,
    finishedAt,
    areaServicedHectares,
    completionNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.jobNumber == this.jobNumber &&
          other.serviceRequestId == this.serviceRequestId &&
          other.farmerId == this.farmerId &&
          other.plotId == this.plotId &&
          other.tractorId == this.tractorId &&
          other.operatorId == this.operatorId &&
          other.serviceKind == this.serviceKind &&
          other.status == this.status &&
          other.scheduledAt == this.scheduledAt &&
          other.estimatedDurationMinutes == this.estimatedDurationMinutes &&
          other.dispatchedAt == this.dispatchedAt &&
          other.journeyStartedAt == this.journeyStartedAt &&
          other.arrivedAt == this.arrivedAt &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.areaServicedHectares == this.areaServicedHectares &&
          other.completionNotes == this.completionNotes);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<String> id;
  final Value<String> jobNumber;
  final Value<String> serviceRequestId;
  final Value<String> farmerId;
  final Value<String> plotId;
  final Value<String> tractorId;
  final Value<String> operatorId;
  final Value<ServiceKind> serviceKind;
  final Value<JobStatusDb> status;
  final Value<DateTime> scheduledAt;
  final Value<int> estimatedDurationMinutes;
  final Value<DateTime?> dispatchedAt;
  final Value<DateTime?> journeyStartedAt;
  final Value<DateTime?> arrivedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<double?> areaServicedHectares;
  final Value<String?> completionNotes;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.jobNumber = const Value.absent(),
    this.serviceRequestId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.plotId = const Value.absent(),
    this.tractorId = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.serviceKind = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.estimatedDurationMinutes = const Value.absent(),
    this.dispatchedAt = const Value.absent(),
    this.journeyStartedAt = const Value.absent(),
    this.arrivedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.areaServicedHectares = const Value.absent(),
    this.completionNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    this.id = const Value.absent(),
    required String jobNumber,
    required String serviceRequestId,
    required String farmerId,
    required String plotId,
    required String tractorId,
    required String operatorId,
    required ServiceKind serviceKind,
    this.status = const Value.absent(),
    required DateTime scheduledAt,
    required int estimatedDurationMinutes,
    this.dispatchedAt = const Value.absent(),
    this.journeyStartedAt = const Value.absent(),
    this.arrivedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.areaServicedHectares = const Value.absent(),
    this.completionNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jobNumber = Value(jobNumber),
       serviceRequestId = Value(serviceRequestId),
       farmerId = Value(farmerId),
       plotId = Value(plotId),
       tractorId = Value(tractorId),
       operatorId = Value(operatorId),
       serviceKind = Value(serviceKind),
       scheduledAt = Value(scheduledAt),
       estimatedDurationMinutes = Value(estimatedDurationMinutes);
  static Insertable<Job> custom({
    Expression<String>? id,
    Expression<String>? jobNumber,
    Expression<String>? serviceRequestId,
    Expression<String>? farmerId,
    Expression<String>? plotId,
    Expression<String>? tractorId,
    Expression<String>? operatorId,
    Expression<String>? serviceKind,
    Expression<String>? status,
    Expression<DateTime>? scheduledAt,
    Expression<int>? estimatedDurationMinutes,
    Expression<DateTime>? dispatchedAt,
    Expression<DateTime>? journeyStartedAt,
    Expression<DateTime>? arrivedAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<double>? areaServicedHectares,
    Expression<String>? completionNotes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobNumber != null) 'job_number': jobNumber,
      if (serviceRequestId != null) 'service_request_id': serviceRequestId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (plotId != null) 'plot_id': plotId,
      if (tractorId != null) 'tractor_id': tractorId,
      if (operatorId != null) 'operator_id': operatorId,
      if (serviceKind != null) 'service_kind': serviceKind,
      if (status != null) 'status': status,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
      if (dispatchedAt != null) 'dispatched_at': dispatchedAt,
      if (journeyStartedAt != null) 'journey_started_at': journeyStartedAt,
      if (arrivedAt != null) 'arrived_at': arrivedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (areaServicedHectares != null)
        'area_serviced_hectares': areaServicedHectares,
      if (completionNotes != null) 'completion_notes': completionNotes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobNumber,
    Value<String>? serviceRequestId,
    Value<String>? farmerId,
    Value<String>? plotId,
    Value<String>? tractorId,
    Value<String>? operatorId,
    Value<ServiceKind>? serviceKind,
    Value<JobStatusDb>? status,
    Value<DateTime>? scheduledAt,
    Value<int>? estimatedDurationMinutes,
    Value<DateTime?>? dispatchedAt,
    Value<DateTime?>? journeyStartedAt,
    Value<DateTime?>? arrivedAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<double?>? areaServicedHectares,
    Value<String?>? completionNotes,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      jobNumber: jobNumber ?? this.jobNumber,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      farmerId: farmerId ?? this.farmerId,
      plotId: plotId ?? this.plotId,
      tractorId: tractorId ?? this.tractorId,
      operatorId: operatorId ?? this.operatorId,
      serviceKind: serviceKind ?? this.serviceKind,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      journeyStartedAt: journeyStartedAt ?? this.journeyStartedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      areaServicedHectares: areaServicedHectares ?? this.areaServicedHectares,
      completionNotes: completionNotes ?? this.completionNotes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobNumber.present) {
      map['job_number'] = Variable<String>(jobNumber.value);
    }
    if (serviceRequestId.present) {
      map['service_request_id'] = Variable<String>(serviceRequestId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (tractorId.present) {
      map['tractor_id'] = Variable<String>(tractorId.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (serviceKind.present) {
      map['service_kind'] = Variable<String>(
        $JobsTable.$converterserviceKind.toSql(serviceKind.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $JobsTable.$converterstatus.toSql(status.value),
      );
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (estimatedDurationMinutes.present) {
      map['estimated_duration_minutes'] = Variable<int>(
        estimatedDurationMinutes.value,
      );
    }
    if (dispatchedAt.present) {
      map['dispatched_at'] = Variable<DateTime>(dispatchedAt.value);
    }
    if (journeyStartedAt.present) {
      map['journey_started_at'] = Variable<DateTime>(journeyStartedAt.value);
    }
    if (arrivedAt.present) {
      map['arrived_at'] = Variable<DateTime>(arrivedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (areaServicedHectares.present) {
      map['area_serviced_hectares'] = Variable<double>(
        areaServicedHectares.value,
      );
    }
    if (completionNotes.present) {
      map['completion_notes'] = Variable<String>(completionNotes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('jobNumber: $jobNumber, ')
          ..write('serviceRequestId: $serviceRequestId, ')
          ..write('farmerId: $farmerId, ')
          ..write('plotId: $plotId, ')
          ..write('tractorId: $tractorId, ')
          ..write('operatorId: $operatorId, ')
          ..write('serviceKind: $serviceKind, ')
          ..write('status: $status, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('estimatedDurationMinutes: $estimatedDurationMinutes, ')
          ..write('dispatchedAt: $dispatchedAt, ')
          ..write('journeyStartedAt: $journeyStartedAt, ')
          ..write('arrivedAt: $arrivedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('areaServicedHectares: $areaServicedHectares, ')
          ..write('completionNotes: $completionNotes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobTrackingPointsTable extends JobTrackingPoints
    with TableInfo<$JobTrackingPointsTable, JobTrackingPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobTrackingPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id)',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insideAssignedPlotMeta =
      const VerificationMeta('insideAssignedPlot');
  @override
  late final GeneratedColumn<bool> insideAssignedPlot = GeneratedColumn<bool>(
    'inside_assigned_plot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("inside_assigned_plot" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    latitude,
    longitude,
    accuracyMeters,
    recordedAt,
    insideAssignedPlot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_tracking_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobTrackingPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('inside_assigned_plot')) {
      context.handle(
        _insideAssignedPlotMeta,
        insideAssignedPlot.isAcceptableOrUnknown(
          data['inside_assigned_plot']!,
          _insideAssignedPlotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  JobTrackingPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobTrackingPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      insideAssignedPlot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}inside_assigned_plot'],
      )!,
    );
  }

  @override
  $JobTrackingPointsTable createAlias(String alias) {
    return $JobTrackingPointsTable(attachedDatabase, alias);
  }
}

class JobTrackingPoint extends DataClass
    implements Insertable<JobTrackingPoint> {
  final String id;
  final String jobId;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime recordedAt;
  final bool insideAssignedPlot;
  const JobTrackingPoint({
    required this.id,
    required this.jobId,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.recordedAt,
    required this.insideAssignedPlot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_id'] = Variable<String>(jobId);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['inside_assigned_plot'] = Variable<bool>(insideAssignedPlot);
    return map;
  }

  JobTrackingPointsCompanion toCompanion(bool nullToAbsent) {
    return JobTrackingPointsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
      recordedAt: Value(recordedAt),
      insideAssignedPlot: Value(insideAssignedPlot),
    );
  }

  factory JobTrackingPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobTrackingPoint(
      id: serializer.fromJson<String>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      insideAssignedPlot: serializer.fromJson<bool>(json['insideAssignedPlot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobId': serializer.toJson<String>(jobId),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'insideAssignedPlot': serializer.toJson<bool>(insideAssignedPlot),
    };
  }

  JobTrackingPoint copyWith({
    String? id,
    String? jobId,
    double? latitude,
    double? longitude,
    Value<double?> accuracyMeters = const Value.absent(),
    DateTime? recordedAt,
    bool? insideAssignedPlot,
  }) => JobTrackingPoint(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
    recordedAt: recordedAt ?? this.recordedAt,
    insideAssignedPlot: insideAssignedPlot ?? this.insideAssignedPlot,
  );
  JobTrackingPoint copyWithCompanion(JobTrackingPointsCompanion data) {
    return JobTrackingPoint(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      insideAssignedPlot: data.insideAssignedPlot.present
          ? data.insideAssignedPlot.value
          : this.insideAssignedPlot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobTrackingPoint(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('insideAssignedPlot: $insideAssignedPlot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    latitude,
    longitude,
    accuracyMeters,
    recordedAt,
    insideAssignedPlot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobTrackingPoint &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracyMeters == this.accuracyMeters &&
          other.recordedAt == this.recordedAt &&
          other.insideAssignedPlot == this.insideAssignedPlot);
}

class JobTrackingPointsCompanion extends UpdateCompanion<JobTrackingPoint> {
  final Value<String> id;
  final Value<String> jobId;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> accuracyMeters;
  final Value<DateTime> recordedAt;
  final Value<bool> insideAssignedPlot;
  final Value<int> rowid;
  const JobTrackingPointsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.insideAssignedPlot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobTrackingPointsCompanion.insert({
    this.id = const Value.absent(),
    required String jobId,
    required double latitude,
    required double longitude,
    this.accuracyMeters = const Value.absent(),
    required DateTime recordedAt,
    this.insideAssignedPlot = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : jobId = Value(jobId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAt = Value(recordedAt);
  static Insertable<JobTrackingPoint> custom({
    Expression<String>? id,
    Expression<String>? jobId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracyMeters,
    Expression<DateTime>? recordedAt,
    Expression<bool>? insideAssignedPlot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (insideAssignedPlot != null)
        'inside_assigned_plot': insideAssignedPlot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobTrackingPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobId,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? accuracyMeters,
    Value<DateTime>? recordedAt,
    Value<bool>? insideAssignedPlot,
    Value<int>? rowid,
  }) {
    return JobTrackingPointsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      recordedAt: recordedAt ?? this.recordedAt,
      insideAssignedPlot: insideAssignedPlot ?? this.insideAssignedPlot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (insideAssignedPlot.present) {
      map['inside_assigned_plot'] = Variable<bool>(insideAssignedPlot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobTrackingPointsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('insideAssignedPlot: $insideAssignedPlot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobNotesTable extends JobNotes with TableInfo<$JobNotesTable, JobNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES jobs (id)',
    ),
  );
  static const VerificationMeta _authorUserIdMeta = const VerificationMeta(
    'authorUserId',
  );
  @override
  late final GeneratedColumn<String> authorUserId = GeneratedColumn<String>(
    'author_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, jobId, authorUserId, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('author_user_id')) {
      context.handle(
        _authorUserIdMeta,
        authorUserId.isAcceptableOrUnknown(
          data['author_user_id']!,
          _authorUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorUserIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  JobNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      authorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_user_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
    );
  }

  @override
  $JobNotesTable createAlias(String alias) {
    return $JobNotesTable(attachedDatabase, alias);
  }
}

class JobNote extends DataClass implements Insertable<JobNote> {
  final String id;
  final String jobId;
  final String authorUserId;
  final String note;
  const JobNote({
    required this.id,
    required this.jobId,
    required this.authorUserId,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_id'] = Variable<String>(jobId);
    map['author_user_id'] = Variable<String>(authorUserId);
    map['note'] = Variable<String>(note);
    return map;
  }

  JobNotesCompanion toCompanion(bool nullToAbsent) {
    return JobNotesCompanion(
      id: Value(id),
      jobId: Value(jobId),
      authorUserId: Value(authorUserId),
      note: Value(note),
    );
  }

  factory JobNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobNote(
      id: serializer.fromJson<String>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      authorUserId: serializer.fromJson<String>(json['authorUserId']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobId': serializer.toJson<String>(jobId),
      'authorUserId': serializer.toJson<String>(authorUserId),
      'note': serializer.toJson<String>(note),
    };
  }

  JobNote copyWith({
    String? id,
    String? jobId,
    String? authorUserId,
    String? note,
  }) => JobNote(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    authorUserId: authorUserId ?? this.authorUserId,
    note: note ?? this.note,
  );
  JobNote copyWithCompanion(JobNotesCompanion data) {
    return JobNote(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      authorUserId: data.authorUserId.present
          ? data.authorUserId.value
          : this.authorUserId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobNote(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('authorUserId: $authorUserId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jobId, authorUserId, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobNote &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.authorUserId == this.authorUserId &&
          other.note == this.note);
}

class JobNotesCompanion extends UpdateCompanion<JobNote> {
  final Value<String> id;
  final Value<String> jobId;
  final Value<String> authorUserId;
  final Value<String> note;
  final Value<int> rowid;
  const JobNotesCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.authorUserId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobNotesCompanion.insert({
    this.id = const Value.absent(),
    required String jobId,
    required String authorUserId,
    required String note,
    this.rowid = const Value.absent(),
  }) : jobId = Value(jobId),
       authorUserId = Value(authorUserId),
       note = Value(note);
  static Insertable<JobNote> custom({
    Expression<String>? id,
    Expression<String>? jobId,
    Expression<String>? authorUserId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (authorUserId != null) 'author_user_id': authorUserId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? jobId,
    Value<String>? authorUserId,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return JobNotesCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      authorUserId: authorUserId ?? this.authorUserId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (authorUserId.present) {
      map['author_user_id'] = Variable<String>(authorUserId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobNotesCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('authorUserId: $authorUserId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DisputesTable extends Disputes with TableInfo<$DisputesTable, Dispute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DisputesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _serviceRequestIdMeta = const VerificationMeta(
    'serviceRequestId',
  );
  @override
  late final GeneratedColumn<String> serviceRequestId = GeneratedColumn<String>(
    'service_request_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_requests (id)',
    ),
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta(
    'farmerId',
  );
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES farmers (id)',
    ),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DisputeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(DisputeStatus.open.name),
      ).withConverter<DisputeStatus>($DisputesTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceRequestId,
    jobId,
    farmerId,
    reason,
    description,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'disputes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dispute> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_request_id')) {
      context.handle(
        _serviceRequestIdMeta,
        serviceRequestId.isAcceptableOrUnknown(
          data['service_request_id']!,
          _serviceRequestIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceRequestIdMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    }
    if (data.containsKey('farmer_id')) {
      context.handle(
        _farmerIdMeta,
        farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Dispute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dispute(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serviceRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_request_id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      ),
      farmerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}farmer_id'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: $DisputesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $DisputesTable createAlias(String alias) {
    return $DisputesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DisputeStatus, String, String> $converterstatus =
      const EnumNameConverter<DisputeStatus>(DisputeStatus.values);
}

class Dispute extends DataClass implements Insertable<Dispute> {
  final String id;
  final String serviceRequestId;
  final String? jobId;
  final String farmerId;
  final String reason;
  final String description;
  final DisputeStatus status;
  const Dispute({
    required this.id,
    required this.serviceRequestId,
    this.jobId,
    required this.farmerId,
    required this.reason,
    required this.description,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_request_id'] = Variable<String>(serviceRequestId);
    if (!nullToAbsent || jobId != null) {
      map['job_id'] = Variable<String>(jobId);
    }
    map['farmer_id'] = Variable<String>(farmerId);
    map['reason'] = Variable<String>(reason);
    map['description'] = Variable<String>(description);
    {
      map['status'] = Variable<String>(
        $DisputesTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  DisputesCompanion toCompanion(bool nullToAbsent) {
    return DisputesCompanion(
      id: Value(id),
      serviceRequestId: Value(serviceRequestId),
      jobId: jobId == null && nullToAbsent
          ? const Value.absent()
          : Value(jobId),
      farmerId: Value(farmerId),
      reason: Value(reason),
      description: Value(description),
      status: Value(status),
    );
  }

  factory Dispute.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dispute(
      id: serializer.fromJson<String>(json['id']),
      serviceRequestId: serializer.fromJson<String>(json['serviceRequestId']),
      jobId: serializer.fromJson<String?>(json['jobId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      reason: serializer.fromJson<String>(json['reason']),
      description: serializer.fromJson<String>(json['description']),
      status: $DisputesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceRequestId': serializer.toJson<String>(serviceRequestId),
      'jobId': serializer.toJson<String?>(jobId),
      'farmerId': serializer.toJson<String>(farmerId),
      'reason': serializer.toJson<String>(reason),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(
        $DisputesTable.$converterstatus.toJson(status),
      ),
    };
  }

  Dispute copyWith({
    String? id,
    String? serviceRequestId,
    Value<String?> jobId = const Value.absent(),
    String? farmerId,
    String? reason,
    String? description,
    DisputeStatus? status,
  }) => Dispute(
    id: id ?? this.id,
    serviceRequestId: serviceRequestId ?? this.serviceRequestId,
    jobId: jobId.present ? jobId.value : this.jobId,
    farmerId: farmerId ?? this.farmerId,
    reason: reason ?? this.reason,
    description: description ?? this.description,
    status: status ?? this.status,
  );
  Dispute copyWithCompanion(DisputesCompanion data) {
    return Dispute(
      id: data.id.present ? data.id.value : this.id,
      serviceRequestId: data.serviceRequestId.present
          ? data.serviceRequestId.value
          : this.serviceRequestId,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      reason: data.reason.present ? data.reason.value : this.reason,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dispute(')
          ..write('id: $id, ')
          ..write('serviceRequestId: $serviceRequestId, ')
          ..write('jobId: $jobId, ')
          ..write('farmerId: $farmerId, ')
          ..write('reason: $reason, ')
          ..write('description: $description, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serviceRequestId,
    jobId,
    farmerId,
    reason,
    description,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dispute &&
          other.id == this.id &&
          other.serviceRequestId == this.serviceRequestId &&
          other.jobId == this.jobId &&
          other.farmerId == this.farmerId &&
          other.reason == this.reason &&
          other.description == this.description &&
          other.status == this.status);
}

class DisputesCompanion extends UpdateCompanion<Dispute> {
  final Value<String> id;
  final Value<String> serviceRequestId;
  final Value<String?> jobId;
  final Value<String> farmerId;
  final Value<String> reason;
  final Value<String> description;
  final Value<DisputeStatus> status;
  final Value<int> rowid;
  const DisputesCompanion({
    this.id = const Value.absent(),
    this.serviceRequestId = const Value.absent(),
    this.jobId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.reason = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DisputesCompanion.insert({
    this.id = const Value.absent(),
    required String serviceRequestId,
    this.jobId = const Value.absent(),
    required String farmerId,
    required String reason,
    required String description,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : serviceRequestId = Value(serviceRequestId),
       farmerId = Value(farmerId),
       reason = Value(reason),
       description = Value(description);
  static Insertable<Dispute> custom({
    Expression<String>? id,
    Expression<String>? serviceRequestId,
    Expression<String>? jobId,
    Expression<String>? farmerId,
    Expression<String>? reason,
    Expression<String>? description,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceRequestId != null) 'service_request_id': serviceRequestId,
      if (jobId != null) 'job_id': jobId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (reason != null) 'reason': reason,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DisputesCompanion copyWith({
    Value<String>? id,
    Value<String>? serviceRequestId,
    Value<String?>? jobId,
    Value<String>? farmerId,
    Value<String>? reason,
    Value<String>? description,
    Value<DisputeStatus>? status,
    Value<int>? rowid,
  }) {
    return DisputesCompanion(
      id: id ?? this.id,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      jobId: jobId ?? this.jobId,
      farmerId: farmerId ?? this.farmerId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceRequestId.present) {
      map['service_request_id'] = Variable<String>(serviceRequestId.value);
    }
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DisputesTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DisputesCompanion(')
          ..write('id: $id, ')
          ..write('serviceRequestId: $serviceRequestId, ')
          ..write('jobId: $jobId, ')
          ..write('farmerId: $farmerId, ')
          ..write('reason: $reason, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceRecordsTable extends MaintenanceRecords
    with TableInfo<$MaintenanceRecordsTable, MaintenanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _tractorIdMeta = const VerificationMeta(
    'tractorId',
  );
  @override
  late final GeneratedColumn<String> tractorId = GeneratedColumn<String>(
    'tractor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tractors (id)',
    ),
  );
  static const VerificationMeta _technicianUserIdMeta = const VerificationMeta(
    'technicianUserId',
  );
  @override
  late final GeneratedColumn<String> technicianUserId = GeneratedColumn<String>(
    'technician_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MaintenanceTypeDb, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MaintenanceTypeDb>(
        $MaintenanceRecordsTable.$convertertype,
      );
  static const VerificationMeta _problemMeta = const VerificationMeta(
    'problem',
  );
  @override
  late final GeneratedColumn<String> problem = GeneratedColumn<String>(
    'problem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workPerformedMeta = const VerificationMeta(
    'workPerformed',
  );
  @override
  late final GeneratedColumn<String> workPerformed = GeneratedColumn<String>(
    'work_performed',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RepairStatusDb, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(RepairStatusDb.inProgress.name),
      ).withConverter<RepairStatusDb>(
        $MaintenanceRecordsTable.$converterstatus,
      );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tractorId,
    technicianUserId,
    type,
    problem,
    workPerformed,
    status,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tractor_id')) {
      context.handle(
        _tractorIdMeta,
        tractorId.isAcceptableOrUnknown(data['tractor_id']!, _tractorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tractorIdMeta);
    }
    if (data.containsKey('technician_user_id')) {
      context.handle(
        _technicianUserIdMeta,
        technicianUserId.isAcceptableOrUnknown(
          data['technician_user_id']!,
          _technicianUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_technicianUserIdMeta);
    }
    if (data.containsKey('problem')) {
      context.handle(
        _problemMeta,
        problem.isAcceptableOrUnknown(data['problem']!, _problemMeta),
      );
    } else if (isInserting) {
      context.missing(_problemMeta);
    }
    if (data.containsKey('work_performed')) {
      context.handle(
        _workPerformedMeta,
        workPerformed.isAcceptableOrUnknown(
          data['work_performed']!,
          _workPerformedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workPerformedMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MaintenanceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tractorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tractor_id'],
      )!,
      technicianUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}technician_user_id'],
      )!,
      type: $MaintenanceRecordsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      problem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem'],
      )!,
      workPerformed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_performed'],
      )!,
      status: $MaintenanceRecordsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $MaintenanceRecordsTable createAlias(String alias) {
    return $MaintenanceRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MaintenanceTypeDb, String, String> $convertertype =
      const EnumNameConverter<MaintenanceTypeDb>(MaintenanceTypeDb.values);
  static JsonTypeConverter2<RepairStatusDb, String, String> $converterstatus =
      const EnumNameConverter<RepairStatusDb>(RepairStatusDb.values);
}

class MaintenanceRecord extends DataClass
    implements Insertable<MaintenanceRecord> {
  final String id;
  final String tractorId;
  final String technicianUserId;
  final MaintenanceTypeDb type;
  final String problem;
  final String workPerformed;
  final RepairStatusDb status;
  final DateTime startedAt;
  final DateTime? completedAt;
  const MaintenanceRecord({
    required this.id,
    required this.tractorId,
    required this.technicianUserId,
    required this.type,
    required this.problem,
    required this.workPerformed,
    required this.status,
    required this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tractor_id'] = Variable<String>(tractorId);
    map['technician_user_id'] = Variable<String>(technicianUserId);
    {
      map['type'] = Variable<String>(
        $MaintenanceRecordsTable.$convertertype.toSql(type),
      );
    }
    map['problem'] = Variable<String>(problem);
    map['work_performed'] = Variable<String>(workPerformed);
    {
      map['status'] = Variable<String>(
        $MaintenanceRecordsTable.$converterstatus.toSql(status),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  MaintenanceRecordsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceRecordsCompanion(
      id: Value(id),
      tractorId: Value(tractorId),
      technicianUserId: Value(technicianUserId),
      type: Value(type),
      problem: Value(problem),
      workPerformed: Value(workPerformed),
      status: Value(status),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory MaintenanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceRecord(
      id: serializer.fromJson<String>(json['id']),
      tractorId: serializer.fromJson<String>(json['tractorId']),
      technicianUserId: serializer.fromJson<String>(json['technicianUserId']),
      type: $MaintenanceRecordsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      problem: serializer.fromJson<String>(json['problem']),
      workPerformed: serializer.fromJson<String>(json['workPerformed']),
      status: $MaintenanceRecordsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tractorId': serializer.toJson<String>(tractorId),
      'technicianUserId': serializer.toJson<String>(technicianUserId),
      'type': serializer.toJson<String>(
        $MaintenanceRecordsTable.$convertertype.toJson(type),
      ),
      'problem': serializer.toJson<String>(problem),
      'workPerformed': serializer.toJson<String>(workPerformed),
      'status': serializer.toJson<String>(
        $MaintenanceRecordsTable.$converterstatus.toJson(status),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  MaintenanceRecord copyWith({
    String? id,
    String? tractorId,
    String? technicianUserId,
    MaintenanceTypeDb? type,
    String? problem,
    String? workPerformed,
    RepairStatusDb? status,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => MaintenanceRecord(
    id: id ?? this.id,
    tractorId: tractorId ?? this.tractorId,
    technicianUserId: technicianUserId ?? this.technicianUserId,
    type: type ?? this.type,
    problem: problem ?? this.problem,
    workPerformed: workPerformed ?? this.workPerformed,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  MaintenanceRecord copyWithCompanion(MaintenanceRecordsCompanion data) {
    return MaintenanceRecord(
      id: data.id.present ? data.id.value : this.id,
      tractorId: data.tractorId.present ? data.tractorId.value : this.tractorId,
      technicianUserId: data.technicianUserId.present
          ? data.technicianUserId.value
          : this.technicianUserId,
      type: data.type.present ? data.type.value : this.type,
      problem: data.problem.present ? data.problem.value : this.problem,
      workPerformed: data.workPerformed.present
          ? data.workPerformed.value
          : this.workPerformed,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecord(')
          ..write('id: $id, ')
          ..write('tractorId: $tractorId, ')
          ..write('technicianUserId: $technicianUserId, ')
          ..write('type: $type, ')
          ..write('problem: $problem, ')
          ..write('workPerformed: $workPerformed, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tractorId,
    technicianUserId,
    type,
    problem,
    workPerformed,
    status,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceRecord &&
          other.id == this.id &&
          other.tractorId == this.tractorId &&
          other.technicianUserId == this.technicianUserId &&
          other.type == this.type &&
          other.problem == this.problem &&
          other.workPerformed == this.workPerformed &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class MaintenanceRecordsCompanion extends UpdateCompanion<MaintenanceRecord> {
  final Value<String> id;
  final Value<String> tractorId;
  final Value<String> technicianUserId;
  final Value<MaintenanceTypeDb> type;
  final Value<String> problem;
  final Value<String> workPerformed;
  final Value<RepairStatusDb> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const MaintenanceRecordsCompanion({
    this.id = const Value.absent(),
    this.tractorId = const Value.absent(),
    this.technicianUserId = const Value.absent(),
    this.type = const Value.absent(),
    this.problem = const Value.absent(),
    this.workPerformed = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaintenanceRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String tractorId,
    required String technicianUserId,
    required MaintenanceTypeDb type,
    required String problem,
    required String workPerformed,
    this.status = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tractorId = Value(tractorId),
       technicianUserId = Value(technicianUserId),
       type = Value(type),
       problem = Value(problem),
       workPerformed = Value(workPerformed),
       startedAt = Value(startedAt);
  static Insertable<MaintenanceRecord> custom({
    Expression<String>? id,
    Expression<String>? tractorId,
    Expression<String>? technicianUserId,
    Expression<String>? type,
    Expression<String>? problem,
    Expression<String>? workPerformed,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tractorId != null) 'tractor_id': tractorId,
      if (technicianUserId != null) 'technician_user_id': technicianUserId,
      if (type != null) 'type': type,
      if (problem != null) 'problem': problem,
      if (workPerformed != null) 'work_performed': workPerformed,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaintenanceRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? tractorId,
    Value<String>? technicianUserId,
    Value<MaintenanceTypeDb>? type,
    Value<String>? problem,
    Value<String>? workPerformed,
    Value<RepairStatusDb>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return MaintenanceRecordsCompanion(
      id: id ?? this.id,
      tractorId: tractorId ?? this.tractorId,
      technicianUserId: technicianUserId ?? this.technicianUserId,
      type: type ?? this.type,
      problem: problem ?? this.problem,
      workPerformed: workPerformed ?? this.workPerformed,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tractorId.present) {
      map['tractor_id'] = Variable<String>(tractorId.value);
    }
    if (technicianUserId.present) {
      map['technician_user_id'] = Variable<String>(technicianUserId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $MaintenanceRecordsTable.$convertertype.toSql(type.value),
      );
    }
    if (problem.present) {
      map['problem'] = Variable<String>(problem.value);
    }
    if (workPerformed.present) {
      map['work_performed'] = Variable<String>(workPerformed.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MaintenanceRecordsTable.$converterstatus.toSql(status.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceRecordsCompanion(')
          ..write('id: $id, ')
          ..write('tractorId: $tractorId, ')
          ..write('technicianUserId: $technicianUserId, ')
          ..write('type: $type, ')
          ..write('problem: $problem, ')
          ..write('workPerformed: $workPerformed, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartsTable extends Parts with TableInfo<$PartsTable, Part> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<int> stockQuantity = GeneratedColumn<int>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
    'reorder_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    unit,
    stockQuantity,
    reorderLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Part> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Part map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Part(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_quantity'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reorder_level'],
      )!,
    );
  }

  @override
  $PartsTable createAlias(String alias) {
    return $PartsTable(attachedDatabase, alias);
  }
}

class Part extends DataClass implements Insertable<Part> {
  final String id;
  final String name;
  final String unit;
  final int stockQuantity;
  final int reorderLevel;
  const Part({
    required this.id,
    required this.name,
    required this.unit,
    required this.stockQuantity,
    required this.reorderLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['stock_quantity'] = Variable<int>(stockQuantity);
    map['reorder_level'] = Variable<int>(reorderLevel);
    return map;
  }

  PartsCompanion toCompanion(bool nullToAbsent) {
    return PartsCompanion(
      id: Value(id),
      name: Value(name),
      unit: Value(unit),
      stockQuantity: Value(stockQuantity),
      reorderLevel: Value(reorderLevel),
    );
  }

  factory Part.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Part(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      stockQuantity: serializer.fromJson<int>(json['stockQuantity']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'stockQuantity': serializer.toJson<int>(stockQuantity),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
    };
  }

  Part copyWith({
    String? id,
    String? name,
    String? unit,
    int? stockQuantity,
    int? reorderLevel,
  }) => Part(
    id: id ?? this.id,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    reorderLevel: reorderLevel ?? this.reorderLevel,
  );
  Part copyWithCompanion(PartsCompanion data) {
    return Part(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Part(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('reorderLevel: $reorderLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, unit, stockQuantity, reorderLevel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Part &&
          other.id == this.id &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.stockQuantity == this.stockQuantity &&
          other.reorderLevel == this.reorderLevel);
}

class PartsCompanion extends UpdateCompanion<Part> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> unit;
  final Value<int> stockQuantity;
  final Value<int> reorderLevel;
  final Value<int> rowid;
  const PartsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String unit,
    this.stockQuantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       unit = Value(unit);
  static Insertable<Part> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<int>? stockQuantity,
    Expression<int>? reorderLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? unit,
    Value<int>? stockQuantity,
    Value<int>? reorderLevel,
    Value<int>? rowid,
  }) {
    return PartsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<int>(stockQuantity.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaintenancePartsUsedTable extends MaintenancePartsUsed
    with TableInfo<$MaintenancePartsUsedTable, MaintenancePartsUsedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenancePartsUsedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => appUuid.v4(),
  );
  static const VerificationMeta _maintenanceRecordIdMeta =
      const VerificationMeta('maintenanceRecordId');
  @override
  late final GeneratedColumn<String> maintenanceRecordId =
      GeneratedColumn<String>(
        'maintenance_record_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES maintenance_records (id)',
        ),
      );
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
    'part_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parts (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    maintenanceRecordId,
    partId,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_parts_used';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenancePartsUsedData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('maintenance_record_id')) {
      context.handle(
        _maintenanceRecordIdMeta,
        maintenanceRecordId.isAcceptableOrUnknown(
          data['maintenance_record_id']!,
          _maintenanceRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maintenanceRecordIdMeta);
    }
    if (data.containsKey('part_id')) {
      context.handle(
        _partIdMeta,
        partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta),
      );
    } else if (isInserting) {
      context.missing(_partIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MaintenancePartsUsedData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenancePartsUsedData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      maintenanceRecordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maintenance_record_id'],
      )!,
      partId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $MaintenancePartsUsedTable createAlias(String alias) {
    return $MaintenancePartsUsedTable(attachedDatabase, alias);
  }
}

class MaintenancePartsUsedData extends DataClass
    implements Insertable<MaintenancePartsUsedData> {
  final String id;
  final String maintenanceRecordId;
  final String partId;
  final int quantity;
  const MaintenancePartsUsedData({
    required this.id,
    required this.maintenanceRecordId,
    required this.partId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['maintenance_record_id'] = Variable<String>(maintenanceRecordId);
    map['part_id'] = Variable<String>(partId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  MaintenancePartsUsedCompanion toCompanion(bool nullToAbsent) {
    return MaintenancePartsUsedCompanion(
      id: Value(id),
      maintenanceRecordId: Value(maintenanceRecordId),
      partId: Value(partId),
      quantity: Value(quantity),
    );
  }

  factory MaintenancePartsUsedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenancePartsUsedData(
      id: serializer.fromJson<String>(json['id']),
      maintenanceRecordId: serializer.fromJson<String>(
        json['maintenanceRecordId'],
      ),
      partId: serializer.fromJson<String>(json['partId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'maintenanceRecordId': serializer.toJson<String>(maintenanceRecordId),
      'partId': serializer.toJson<String>(partId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  MaintenancePartsUsedData copyWith({
    String? id,
    String? maintenanceRecordId,
    String? partId,
    int? quantity,
  }) => MaintenancePartsUsedData(
    id: id ?? this.id,
    maintenanceRecordId: maintenanceRecordId ?? this.maintenanceRecordId,
    partId: partId ?? this.partId,
    quantity: quantity ?? this.quantity,
  );
  MaintenancePartsUsedData copyWithCompanion(
    MaintenancePartsUsedCompanion data,
  ) {
    return MaintenancePartsUsedData(
      id: data.id.present ? data.id.value : this.id,
      maintenanceRecordId: data.maintenanceRecordId.present
          ? data.maintenanceRecordId.value
          : this.maintenanceRecordId,
      partId: data.partId.present ? data.partId.value : this.partId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenancePartsUsedData(')
          ..write('id: $id, ')
          ..write('maintenanceRecordId: $maintenanceRecordId, ')
          ..write('partId: $partId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, maintenanceRecordId, partId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenancePartsUsedData &&
          other.id == this.id &&
          other.maintenanceRecordId == this.maintenanceRecordId &&
          other.partId == this.partId &&
          other.quantity == this.quantity);
}

class MaintenancePartsUsedCompanion
    extends UpdateCompanion<MaintenancePartsUsedData> {
  final Value<String> id;
  final Value<String> maintenanceRecordId;
  final Value<String> partId;
  final Value<int> quantity;
  final Value<int> rowid;
  const MaintenancePartsUsedCompanion({
    this.id = const Value.absent(),
    this.maintenanceRecordId = const Value.absent(),
    this.partId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaintenancePartsUsedCompanion.insert({
    this.id = const Value.absent(),
    required String maintenanceRecordId,
    required String partId,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : maintenanceRecordId = Value(maintenanceRecordId),
       partId = Value(partId);
  static Insertable<MaintenancePartsUsedData> custom({
    Expression<String>? id,
    Expression<String>? maintenanceRecordId,
    Expression<String>? partId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maintenanceRecordId != null)
        'maintenance_record_id': maintenanceRecordId,
      if (partId != null) 'part_id': partId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaintenancePartsUsedCompanion copyWith({
    Value<String>? id,
    Value<String>? maintenanceRecordId,
    Value<String>? partId,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return MaintenancePartsUsedCompanion(
      id: id ?? this.id,
      maintenanceRecordId: maintenanceRecordId ?? this.maintenanceRecordId,
      partId: partId ?? this.partId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (maintenanceRecordId.present) {
      map['maintenance_record_id'] = Variable<String>(
        maintenanceRecordId.value,
      );
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenancePartsUsedCompanion(')
          ..write('id: $id, ')
          ..write('maintenanceRecordId: $maintenanceRecordId, ')
          ..write('partId: $partId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FarmersTable farmers = $FarmersTable(this);
  late final $FarmPlotsTable farmPlots = $FarmPlotsTable(this);
  late final $FarmBoundaryPointsTable farmBoundaryPoints =
      $FarmBoundaryPointsTable(this);
  late final $ServiceRequestsTable serviceRequests = $ServiceRequestsTable(
    this,
  );
  late final $TractorsTable tractors = $TractorsTable(this);
  late final $OperatorsTable operators = $OperatorsTable(this);
  late final $ManagerProfilesTable managerProfiles = $ManagerProfilesTable(
    this,
  );
  late final $DispatcherProfilesTable dispatcherProfiles =
      $DispatcherProfilesTable(this);
  late final $TechnicianProfilesTable technicianProfiles =
      $TechnicianProfilesTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $JobTrackingPointsTable jobTrackingPoints =
      $JobTrackingPointsTable(this);
  late final $JobNotesTable jobNotes = $JobNotesTable(this);
  late final $DisputesTable disputes = $DisputesTable(this);
  late final $MaintenanceRecordsTable maintenanceRecords =
      $MaintenanceRecordsTable(this);
  late final $PartsTable parts = $PartsTable(this);
  late final $MaintenancePartsUsedTable maintenancePartsUsed =
      $MaintenancePartsUsedTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    farmers,
    farmPlots,
    farmBoundaryPoints,
    serviceRequests,
    tractors,
    operators,
    managerProfiles,
    dispatcherProfiles,
    technicianProfiles,
    jobs,
    jobTrackingPoints,
    jobNotes,
    disputes,
    maintenanceRecords,
    parts,
    maintenancePartsUsed,
  ];
}

typedef $$FarmersTableCreateCompanionBuilder =
    FarmersCompanion Function({
      Value<String> id,
      required String firstName,
      Value<String?> middleName,
      required String lastName,
      Value<String?> phoneNumber,
      Value<String?> email,
      Value<String?> passwordHash,
      Value<String?> membershipNumber,
      Value<String?> village,
      Value<SexDb?> sex,
      Value<IdentityDocumentTypeDb?> identityDocumentType,
      Value<String?> identityNumber,
      Value<DateTime?> dateOfBirth,
      Value<int> rowid,
    });
typedef $$FarmersTableUpdateCompanionBuilder =
    FarmersCompanion Function({
      Value<String> id,
      Value<String> firstName,
      Value<String?> middleName,
      Value<String> lastName,
      Value<String?> phoneNumber,
      Value<String?> email,
      Value<String?> passwordHash,
      Value<String?> membershipNumber,
      Value<String?> village,
      Value<SexDb?> sex,
      Value<IdentityDocumentTypeDb?> identityDocumentType,
      Value<String?> identityNumber,
      Value<DateTime?> dateOfBirth,
      Value<int> rowid,
    });

final class $$FarmersTableReferences
    extends BaseReferences<_$AppDatabase, $FarmersTable, Farmer> {
  $$FarmersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FarmPlotsTable, List<FarmPlot>>
  _farmPlotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.farmPlots,
    aliasName: 'farmers__id__farm_plots__farmer_id',
  );

  $$FarmPlotsTableProcessedTableManager get farmPlotsRefs {
    final manager = $$FarmPlotsTableTableManager(
      $_db,
      $_db.farmPlots,
    ).filter((f) => f.farmerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmPlotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceRequestsTable, List<ServiceRequest>>
  _serviceRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceRequests,
    aliasName: 'farmers__id__service_requests__farmer_id',
  );

  $$ServiceRequestsTableProcessedTableManager get serviceRequestsRefs {
    final manager = $$ServiceRequestsTableTableManager(
      $_db,
      $_db.serviceRequests,
    ).filter((f) => f.farmerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _serviceRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'farmers__id__jobs__farmer_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.farmerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DisputesTable, List<Dispute>> _disputesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.disputes,
    aliasName: 'farmers__id__disputes__farmer_id',
  );

  $$DisputesTableProcessedTableManager get disputesRefs {
    final manager = $$DisputesTableTableManager(
      $_db,
      $_db.disputes,
    ).filter((f) => f.farmerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_disputesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FarmersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipNumber => $composableBuilder(
    column: $table.membershipNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SexDb?, SexDb, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<
    IdentityDocumentTypeDb?,
    IdentityDocumentTypeDb,
    String
  >
  get identityDocumentType => $composableBuilder(
    column: $table.identityDocumentType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get identityNumber => $composableBuilder(
    column: $table.identityNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> farmPlotsRefs(
    Expression<bool> Function($$FarmPlotsTableFilterComposer f) f,
  ) {
    final $$FarmPlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableFilterComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceRequestsRefs(
    Expression<bool> Function($$ServiceRequestsTableFilterComposer f) f,
  ) {
    final $$ServiceRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> disputesRefs(
    Expression<bool> Function($$DisputesTableFilterComposer f) f,
  ) {
    final $$DisputesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disputes,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisputesTableFilterComposer(
            $db: $db,
            $table: $db.disputes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FarmersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipNumber => $composableBuilder(
    column: $table.membershipNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get village => $composableBuilder(
    column: $table.village,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identityDocumentType => $composableBuilder(
    column: $table.identityDocumentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identityNumber => $composableBuilder(
    column: $table.identityNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FarmersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get membershipNumber => $composableBuilder(
    column: $table.membershipNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SexDb?, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IdentityDocumentTypeDb?, String>
  get identityDocumentType => $composableBuilder(
    column: $table.identityDocumentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get identityNumber => $composableBuilder(
    column: $table.identityNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  Expression<T> farmPlotsRefs<T extends Object>(
    Expression<T> Function($$FarmPlotsTableAnnotationComposer a) f,
  ) {
    final $$FarmPlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> serviceRequestsRefs<T extends Object>(
    Expression<T> Function($$ServiceRequestsTableAnnotationComposer a) f,
  ) {
    final $$ServiceRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> disputesRefs<T extends Object>(
    Expression<T> Function($$DisputesTableAnnotationComposer a) f,
  ) {
    final $$DisputesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disputes,
      getReferencedColumn: (t) => t.farmerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisputesTableAnnotationComposer(
            $db: $db,
            $table: $db.disputes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FarmersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmersTable,
          Farmer,
          $$FarmersTableFilterComposer,
          $$FarmersTableOrderingComposer,
          $$FarmersTableAnnotationComposer,
          $$FarmersTableCreateCompanionBuilder,
          $$FarmersTableUpdateCompanionBuilder,
          (Farmer, $$FarmersTableReferences),
          Farmer,
          PrefetchHooks Function({
            bool farmPlotsRefs,
            bool serviceRequestsRefs,
            bool jobsRefs,
            bool disputesRefs,
          })
        > {
  $$FarmersTableTableManager(_$AppDatabase db, $FarmersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<String?> membershipNumber = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<SexDb?> sex = const Value.absent(),
                Value<IdentityDocumentTypeDb?> identityDocumentType =
                    const Value.absent(),
                Value<String?> identityNumber = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmersCompanion(
                id: id,
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
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String firstName,
                Value<String?> middleName = const Value.absent(),
                required String lastName,
                Value<String?> phoneNumber = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> passwordHash = const Value.absent(),
                Value<String?> membershipNumber = const Value.absent(),
                Value<String?> village = const Value.absent(),
                Value<SexDb?> sex = const Value.absent(),
                Value<IdentityDocumentTypeDb?> identityDocumentType =
                    const Value.absent(),
                Value<String?> identityNumber = const Value.absent(),
                Value<DateTime?> dateOfBirth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmersCompanion.insert(
                id: id,
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
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FarmersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                farmPlotsRefs = false,
                serviceRequestsRefs = false,
                jobsRefs = false,
                disputesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (farmPlotsRefs) db.farmPlots,
                    if (serviceRequestsRefs) db.serviceRequests,
                    if (jobsRefs) db.jobs,
                    if (disputesRefs) db.disputes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (farmPlotsRefs)
                        await $_getPrefetchedData<
                          Farmer,
                          $FarmersTable,
                          FarmPlot
                        >(
                          currentTable: table,
                          referencedTable: $$FarmersTableReferences
                              ._farmPlotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmersTableReferences(
                                db,
                                table,
                                p0,
                              ).farmPlotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.farmerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceRequestsRefs)
                        await $_getPrefetchedData<
                          Farmer,
                          $FarmersTable,
                          ServiceRequest
                        >(
                          currentTable: table,
                          referencedTable: $$FarmersTableReferences
                              ._serviceRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmersTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.farmerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobsRefs)
                        await $_getPrefetchedData<Farmer, $FarmersTable, Job>(
                          currentTable: table,
                          referencedTable: $$FarmersTableReferences
                              ._jobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmersTableReferences(db, table, p0).jobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.farmerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (disputesRefs)
                        await $_getPrefetchedData<
                          Farmer,
                          $FarmersTable,
                          Dispute
                        >(
                          currentTable: table,
                          referencedTable: $$FarmersTableReferences
                              ._disputesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmersTableReferences(
                                db,
                                table,
                                p0,
                              ).disputesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.farmerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FarmersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmersTable,
      Farmer,
      $$FarmersTableFilterComposer,
      $$FarmersTableOrderingComposer,
      $$FarmersTableAnnotationComposer,
      $$FarmersTableCreateCompanionBuilder,
      $$FarmersTableUpdateCompanionBuilder,
      (Farmer, $$FarmersTableReferences),
      Farmer,
      PrefetchHooks Function({
        bool farmPlotsRefs,
        bool serviceRequestsRefs,
        bool jobsRefs,
        bool disputesRefs,
      })
    >;
typedef $$FarmPlotsTableCreateCompanionBuilder =
    FarmPlotsCompanion Function({
      Value<String> id,
      required String farmerId,
      required String name,
      required String locationLabel,
      required double areaHectares,
      Value<PlotRegistrationStatus> registrationStatus,
      Value<bool> boundaryRegistered,
      Value<int> rowid,
    });
typedef $$FarmPlotsTableUpdateCompanionBuilder =
    FarmPlotsCompanion Function({
      Value<String> id,
      Value<String> farmerId,
      Value<String> name,
      Value<String> locationLabel,
      Value<double> areaHectares,
      Value<PlotRegistrationStatus> registrationStatus,
      Value<bool> boundaryRegistered,
      Value<int> rowid,
    });

final class $$FarmPlotsTableReferences
    extends BaseReferences<_$AppDatabase, $FarmPlotsTable, FarmPlot> {
  $$FarmPlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FarmersTable _farmerIdTable(_$AppDatabase db) =>
      db.farmers.createAlias('farm_plots__farmer_id__farmers__id');

  $$FarmersTableProcessedTableManager get farmerId {
    final $_column = $_itemColumn<String>('farmer_id')!;

    final manager = $$FarmersTableTableManager(
      $_db,
      $_db.farmers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FarmBoundaryPointsTable, List<FarmBoundaryPoint>>
  _farmBoundaryPointsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.farmBoundaryPoints,
        aliasName: 'farm_plots__id__farm_boundary_points__plot_id',
      );

  $$FarmBoundaryPointsTableProcessedTableManager get farmBoundaryPointsRefs {
    final manager = $$FarmBoundaryPointsTableTableManager(
      $_db,
      $_db.farmBoundaryPoints,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _farmBoundaryPointsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ServiceRequestsTable, List<ServiceRequest>>
  _serviceRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.serviceRequests,
    aliasName: 'farm_plots__id__service_requests__plot_id',
  );

  $$ServiceRequestsTableProcessedTableManager get serviceRequestsRefs {
    final manager = $$ServiceRequestsTableTableManager(
      $_db,
      $_db.serviceRequests,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _serviceRequestsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'farm_plots__id__jobs__plot_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.plotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FarmPlotsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmPlotsTable> {
  $$FarmPlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaHectares => $composableBuilder(
    column: $table.areaHectares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    PlotRegistrationStatus,
    PlotRegistrationStatus,
    String
  >
  get registrationStatus => $composableBuilder(
    column: $table.registrationStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get boundaryRegistered => $composableBuilder(
    column: $table.boundaryRegistered,
    builder: (column) => ColumnFilters(column),
  );

  $$FarmersTableFilterComposer get farmerId {
    final $$FarmersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableFilterComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> farmBoundaryPointsRefs(
    Expression<bool> Function($$FarmBoundaryPointsTableFilterComposer f) f,
  ) {
    final $$FarmBoundaryPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.farmBoundaryPoints,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmBoundaryPointsTableFilterComposer(
            $db: $db,
            $table: $db.farmBoundaryPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceRequestsRefs(
    Expression<bool> Function($$ServiceRequestsTableFilterComposer f) f,
  ) {
    final $$ServiceRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FarmPlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmPlotsTable> {
  $$FarmPlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaHectares => $composableBuilder(
    column: $table.areaHectares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registrationStatus => $composableBuilder(
    column: $table.registrationStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get boundaryRegistered => $composableBuilder(
    column: $table.boundaryRegistered,
    builder: (column) => ColumnOrderings(column),
  );

  $$FarmersTableOrderingComposer get farmerId {
    final $$FarmersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableOrderingComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmPlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmPlotsTable> {
  $$FarmPlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get locationLabel => $composableBuilder(
    column: $table.locationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaHectares => $composableBuilder(
    column: $table.areaHectares,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PlotRegistrationStatus, String>
  get registrationStatus => $composableBuilder(
    column: $table.registrationStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get boundaryRegistered => $composableBuilder(
    column: $table.boundaryRegistered,
    builder: (column) => column,
  );

  $$FarmersTableAnnotationComposer get farmerId {
    final $$FarmersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableAnnotationComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> farmBoundaryPointsRefs<T extends Object>(
    Expression<T> Function($$FarmBoundaryPointsTableAnnotationComposer a) f,
  ) {
    final $$FarmBoundaryPointsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.farmBoundaryPoints,
          getReferencedColumn: (t) => t.plotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FarmBoundaryPointsTableAnnotationComposer(
                $db: $db,
                $table: $db.farmBoundaryPoints,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> serviceRequestsRefs<T extends Object>(
    Expression<T> Function($$ServiceRequestsTableAnnotationComposer a) f,
  ) {
    final $$ServiceRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.plotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FarmPlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmPlotsTable,
          FarmPlot,
          $$FarmPlotsTableFilterComposer,
          $$FarmPlotsTableOrderingComposer,
          $$FarmPlotsTableAnnotationComposer,
          $$FarmPlotsTableCreateCompanionBuilder,
          $$FarmPlotsTableUpdateCompanionBuilder,
          (FarmPlot, $$FarmPlotsTableReferences),
          FarmPlot,
          PrefetchHooks Function({
            bool farmerId,
            bool farmBoundaryPointsRefs,
            bool serviceRequestsRefs,
            bool jobsRefs,
          })
        > {
  $$FarmPlotsTableTableManager(_$AppDatabase db, $FarmPlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmPlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmPlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmPlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> locationLabel = const Value.absent(),
                Value<double> areaHectares = const Value.absent(),
                Value<PlotRegistrationStatus> registrationStatus =
                    const Value.absent(),
                Value<bool> boundaryRegistered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmPlotsCompanion(
                id: id,
                farmerId: farmerId,
                name: name,
                locationLabel: locationLabel,
                areaHectares: areaHectares,
                registrationStatus: registrationStatus,
                boundaryRegistered: boundaryRegistered,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String farmerId,
                required String name,
                required String locationLabel,
                required double areaHectares,
                Value<PlotRegistrationStatus> registrationStatus =
                    const Value.absent(),
                Value<bool> boundaryRegistered = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmPlotsCompanion.insert(
                id: id,
                farmerId: farmerId,
                name: name,
                locationLabel: locationLabel,
                areaHectares: areaHectares,
                registrationStatus: registrationStatus,
                boundaryRegistered: boundaryRegistered,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FarmPlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                farmerId = false,
                farmBoundaryPointsRefs = false,
                serviceRequestsRefs = false,
                jobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (farmBoundaryPointsRefs) db.farmBoundaryPoints,
                    if (serviceRequestsRefs) db.serviceRequests,
                    if (jobsRefs) db.jobs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (farmerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.farmerId,
                                    referencedTable: $$FarmPlotsTableReferences
                                        ._farmerIdTable(db),
                                    referencedColumn: $$FarmPlotsTableReferences
                                        ._farmerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (farmBoundaryPointsRefs)
                        await $_getPrefetchedData<
                          FarmPlot,
                          $FarmPlotsTable,
                          FarmBoundaryPoint
                        >(
                          currentTable: table,
                          referencedTable: $$FarmPlotsTableReferences
                              ._farmBoundaryPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmPlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).farmBoundaryPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceRequestsRefs)
                        await $_getPrefetchedData<
                          FarmPlot,
                          $FarmPlotsTable,
                          ServiceRequest
                        >(
                          currentTable: table,
                          referencedTable: $$FarmPlotsTableReferences
                              ._serviceRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmPlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobsRefs)
                        await $_getPrefetchedData<
                          FarmPlot,
                          $FarmPlotsTable,
                          Job
                        >(
                          currentTable: table,
                          referencedTable: $$FarmPlotsTableReferences
                              ._jobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FarmPlotsTableReferences(
                                db,
                                table,
                                p0,
                              ).jobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.plotId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FarmPlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmPlotsTable,
      FarmPlot,
      $$FarmPlotsTableFilterComposer,
      $$FarmPlotsTableOrderingComposer,
      $$FarmPlotsTableAnnotationComposer,
      $$FarmPlotsTableCreateCompanionBuilder,
      $$FarmPlotsTableUpdateCompanionBuilder,
      (FarmPlot, $$FarmPlotsTableReferences),
      FarmPlot,
      PrefetchHooks Function({
        bool farmerId,
        bool farmBoundaryPointsRefs,
        bool serviceRequestsRefs,
        bool jobsRefs,
      })
    >;
typedef $$FarmBoundaryPointsTableCreateCompanionBuilder =
    FarmBoundaryPointsCompanion Function({
      Value<String> id,
      required String plotId,
      required int pointOrder,
      required double latitude,
      required double longitude,
      Value<String?> capturedByUserId,
      Value<DateTime?> capturedAt,
      Value<int> rowid,
    });
typedef $$FarmBoundaryPointsTableUpdateCompanionBuilder =
    FarmBoundaryPointsCompanion Function({
      Value<String> id,
      Value<String> plotId,
      Value<int> pointOrder,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> capturedByUserId,
      Value<DateTime?> capturedAt,
      Value<int> rowid,
    });

final class $$FarmBoundaryPointsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FarmBoundaryPointsTable,
          FarmBoundaryPoint
        > {
  $$FarmBoundaryPointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FarmPlotsTable _plotIdTable(_$AppDatabase db) =>
      db.farmPlots.createAlias('farm_boundary_points__plot_id__farm_plots__id');

  $$FarmPlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<String>('plot_id')!;

    final manager = $$FarmPlotsTableTableManager(
      $_db,
      $_db.farmPlots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FarmBoundaryPointsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmBoundaryPointsTable> {
  $$FarmBoundaryPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointOrder => $composableBuilder(
    column: $table.pointOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capturedByUserId => $composableBuilder(
    column: $table.capturedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FarmPlotsTableFilterComposer get plotId {
    final $$FarmPlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableFilterComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmBoundaryPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmBoundaryPointsTable> {
  $$FarmBoundaryPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointOrder => $composableBuilder(
    column: $table.pointOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capturedByUserId => $composableBuilder(
    column: $table.capturedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FarmPlotsTableOrderingComposer get plotId {
    final $$FarmPlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableOrderingComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmBoundaryPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmBoundaryPointsTable> {
  $$FarmBoundaryPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pointOrder => $composableBuilder(
    column: $table.pointOrder,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get capturedByUserId => $composableBuilder(
    column: $table.capturedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  $$FarmPlotsTableAnnotationComposer get plotId {
    final $$FarmPlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FarmBoundaryPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmBoundaryPointsTable,
          FarmBoundaryPoint,
          $$FarmBoundaryPointsTableFilterComposer,
          $$FarmBoundaryPointsTableOrderingComposer,
          $$FarmBoundaryPointsTableAnnotationComposer,
          $$FarmBoundaryPointsTableCreateCompanionBuilder,
          $$FarmBoundaryPointsTableUpdateCompanionBuilder,
          (FarmBoundaryPoint, $$FarmBoundaryPointsTableReferences),
          FarmBoundaryPoint,
          PrefetchHooks Function({bool plotId})
        > {
  $$FarmBoundaryPointsTableTableManager(
    _$AppDatabase db,
    $FarmBoundaryPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmBoundaryPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmBoundaryPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmBoundaryPointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> plotId = const Value.absent(),
                Value<int> pointOrder = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> capturedByUserId = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmBoundaryPointsCompanion(
                id: id,
                plotId: plotId,
                pointOrder: pointOrder,
                latitude: latitude,
                longitude: longitude,
                capturedByUserId: capturedByUserId,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String plotId,
                required int pointOrder,
                required double latitude,
                required double longitude,
                Value<String?> capturedByUserId = const Value.absent(),
                Value<DateTime?> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmBoundaryPointsCompanion.insert(
                id: id,
                plotId: plotId,
                pointOrder: pointOrder,
                latitude: latitude,
                longitude: longitude,
                capturedByUserId: capturedByUserId,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FarmBoundaryPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plotId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (plotId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.plotId,
                                referencedTable:
                                    $$FarmBoundaryPointsTableReferences
                                        ._plotIdTable(db),
                                referencedColumn:
                                    $$FarmBoundaryPointsTableReferences
                                        ._plotIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FarmBoundaryPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmBoundaryPointsTable,
      FarmBoundaryPoint,
      $$FarmBoundaryPointsTableFilterComposer,
      $$FarmBoundaryPointsTableOrderingComposer,
      $$FarmBoundaryPointsTableAnnotationComposer,
      $$FarmBoundaryPointsTableCreateCompanionBuilder,
      $$FarmBoundaryPointsTableUpdateCompanionBuilder,
      (FarmBoundaryPoint, $$FarmBoundaryPointsTableReferences),
      FarmBoundaryPoint,
      PrefetchHooks Function({bool plotId})
    >;
typedef $$ServiceRequestsTableCreateCompanionBuilder =
    ServiceRequestsCompanion Function({
      Value<String> id,
      required String requestNumber,
      required String farmerId,
      required String plotId,
      required ServiceKind serviceKind,
      Value<ServiceRequestStatus> status,
      required DateTime preferredDate,
      Value<DateTime?> alternativeDate,
      Value<String?> farmerNotes,
      Value<String?> rejectionReason,
      Value<String?> rejectionNotes,
      Value<String?> reviewedByUserId,
      Value<DateTime?> reviewedAt,
      Value<int> rowid,
    });
typedef $$ServiceRequestsTableUpdateCompanionBuilder =
    ServiceRequestsCompanion Function({
      Value<String> id,
      Value<String> requestNumber,
      Value<String> farmerId,
      Value<String> plotId,
      Value<ServiceKind> serviceKind,
      Value<ServiceRequestStatus> status,
      Value<DateTime> preferredDate,
      Value<DateTime?> alternativeDate,
      Value<String?> farmerNotes,
      Value<String?> rejectionReason,
      Value<String?> rejectionNotes,
      Value<String?> reviewedByUserId,
      Value<DateTime?> reviewedAt,
      Value<int> rowid,
    });

final class $$ServiceRequestsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ServiceRequestsTable, ServiceRequest> {
  $$ServiceRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FarmersTable _farmerIdTable(_$AppDatabase db) =>
      db.farmers.createAlias('service_requests__farmer_id__farmers__id');

  $$FarmersTableProcessedTableManager get farmerId {
    final $_column = $_itemColumn<String>('farmer_id')!;

    final manager = $$FarmersTableTableManager(
      $_db,
      $_db.farmers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FarmPlotsTable _plotIdTable(_$AppDatabase db) =>
      db.farmPlots.createAlias('service_requests__plot_id__farm_plots__id');

  $$FarmPlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<String>('plot_id')!;

    final manager = $$FarmPlotsTableTableManager(
      $_db,
      $_db.farmPlots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'service_requests__id__jobs__service_request_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager($_db, $_db.jobs).filter(
      (f) => f.serviceRequestId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DisputesTable, List<Dispute>> _disputesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.disputes,
    aliasName: 'service_requests__id__disputes__service_request_id',
  );

  $$DisputesTableProcessedTableManager get disputesRefs {
    final manager = $$DisputesTableTableManager($_db, $_db.disputes).filter(
      (f) => f.serviceRequestId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_disputesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServiceRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceRequestsTable> {
  $$ServiceRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestNumber => $composableBuilder(
    column: $table.requestNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ServiceKind, ServiceKind, String>
  get serviceKind => $composableBuilder(
    column: $table.serviceKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ServiceRequestStatus,
    ServiceRequestStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get preferredDate => $composableBuilder(
    column: $table.preferredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get alternativeDate => $composableBuilder(
    column: $table.alternativeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get farmerNotes => $composableBuilder(
    column: $table.farmerNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectionNotes => $composableBuilder(
    column: $table.rejectionNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedByUserId => $composableBuilder(
    column: $table.reviewedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FarmersTableFilterComposer get farmerId {
    final $$FarmersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableFilterComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmPlotsTableFilterComposer get plotId {
    final $$FarmPlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableFilterComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.serviceRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> disputesRefs(
    Expression<bool> Function($$DisputesTableFilterComposer f) f,
  ) {
    final $$DisputesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disputes,
      getReferencedColumn: (t) => t.serviceRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisputesTableFilterComposer(
            $db: $db,
            $table: $db.disputes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceRequestsTable> {
  $$ServiceRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestNumber => $composableBuilder(
    column: $table.requestNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceKind => $composableBuilder(
    column: $table.serviceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get preferredDate => $composableBuilder(
    column: $table.preferredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get alternativeDate => $composableBuilder(
    column: $table.alternativeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get farmerNotes => $composableBuilder(
    column: $table.farmerNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectionNotes => $composableBuilder(
    column: $table.rejectionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedByUserId => $composableBuilder(
    column: $table.reviewedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FarmersTableOrderingComposer get farmerId {
    final $$FarmersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableOrderingComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmPlotsTableOrderingComposer get plotId {
    final $$FarmPlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableOrderingComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceRequestsTable> {
  $$ServiceRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get requestNumber => $composableBuilder(
    column: $table.requestNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ServiceKind, String> get serviceKind =>
      $composableBuilder(
        column: $table.serviceKind,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ServiceRequestStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get preferredDate => $composableBuilder(
    column: $table.preferredDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get alternativeDate => $composableBuilder(
    column: $table.alternativeDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get farmerNotes => $composableBuilder(
    column: $table.farmerNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectionReason => $composableBuilder(
    column: $table.rejectionReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectionNotes => $composableBuilder(
    column: $table.rejectionNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewedByUserId => $composableBuilder(
    column: $table.reviewedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  $$FarmersTableAnnotationComposer get farmerId {
    final $$FarmersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableAnnotationComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmPlotsTableAnnotationComposer get plotId {
    final $$FarmPlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.serviceRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> disputesRefs<T extends Object>(
    Expression<T> Function($$DisputesTableAnnotationComposer a) f,
  ) {
    final $$DisputesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.disputes,
      getReferencedColumn: (t) => t.serviceRequestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DisputesTableAnnotationComposer(
            $db: $db,
            $table: $db.disputes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceRequestsTable,
          ServiceRequest,
          $$ServiceRequestsTableFilterComposer,
          $$ServiceRequestsTableOrderingComposer,
          $$ServiceRequestsTableAnnotationComposer,
          $$ServiceRequestsTableCreateCompanionBuilder,
          $$ServiceRequestsTableUpdateCompanionBuilder,
          (ServiceRequest, $$ServiceRequestsTableReferences),
          ServiceRequest,
          PrefetchHooks Function({
            bool farmerId,
            bool plotId,
            bool jobsRefs,
            bool disputesRefs,
          })
        > {
  $$ServiceRequestsTableTableManager(
    _$AppDatabase db,
    $ServiceRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> requestNumber = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String> plotId = const Value.absent(),
                Value<ServiceKind> serviceKind = const Value.absent(),
                Value<ServiceRequestStatus> status = const Value.absent(),
                Value<DateTime> preferredDate = const Value.absent(),
                Value<DateTime?> alternativeDate = const Value.absent(),
                Value<String?> farmerNotes = const Value.absent(),
                Value<String?> rejectionReason = const Value.absent(),
                Value<String?> rejectionNotes = const Value.absent(),
                Value<String?> reviewedByUserId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceRequestsCompanion(
                id: id,
                requestNumber: requestNumber,
                farmerId: farmerId,
                plotId: plotId,
                serviceKind: serviceKind,
                status: status,
                preferredDate: preferredDate,
                alternativeDate: alternativeDate,
                farmerNotes: farmerNotes,
                rejectionReason: rejectionReason,
                rejectionNotes: rejectionNotes,
                reviewedByUserId: reviewedByUserId,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String requestNumber,
                required String farmerId,
                required String plotId,
                required ServiceKind serviceKind,
                Value<ServiceRequestStatus> status = const Value.absent(),
                required DateTime preferredDate,
                Value<DateTime?> alternativeDate = const Value.absent(),
                Value<String?> farmerNotes = const Value.absent(),
                Value<String?> rejectionReason = const Value.absent(),
                Value<String?> rejectionNotes = const Value.absent(),
                Value<String?> reviewedByUserId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServiceRequestsCompanion.insert(
                id: id,
                requestNumber: requestNumber,
                farmerId: farmerId,
                plotId: plotId,
                serviceKind: serviceKind,
                status: status,
                preferredDate: preferredDate,
                alternativeDate: alternativeDate,
                farmerNotes: farmerNotes,
                rejectionReason: rejectionReason,
                rejectionNotes: rejectionNotes,
                reviewedByUserId: reviewedByUserId,
                reviewedAt: reviewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                farmerId = false,
                plotId = false,
                jobsRefs = false,
                disputesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jobsRefs) db.jobs,
                    if (disputesRefs) db.disputes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (farmerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.farmerId,
                                    referencedTable:
                                        $$ServiceRequestsTableReferences
                                            ._farmerIdTable(db),
                                    referencedColumn:
                                        $$ServiceRequestsTableReferences
                                            ._farmerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (plotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plotId,
                                    referencedTable:
                                        $$ServiceRequestsTableReferences
                                            ._plotIdTable(db),
                                    referencedColumn:
                                        $$ServiceRequestsTableReferences
                                            ._plotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jobsRefs)
                        await $_getPrefetchedData<
                          ServiceRequest,
                          $ServiceRequestsTable,
                          Job
                        >(
                          currentTable: table,
                          referencedTable: $$ServiceRequestsTableReferences
                              ._jobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServiceRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).jobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serviceRequestId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (disputesRefs)
                        await $_getPrefetchedData<
                          ServiceRequest,
                          $ServiceRequestsTable,
                          Dispute
                        >(
                          currentTable: table,
                          referencedTable: $$ServiceRequestsTableReferences
                              ._disputesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ServiceRequestsTableReferences(
                                db,
                                table,
                                p0,
                              ).disputesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.serviceRequestId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ServiceRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceRequestsTable,
      ServiceRequest,
      $$ServiceRequestsTableFilterComposer,
      $$ServiceRequestsTableOrderingComposer,
      $$ServiceRequestsTableAnnotationComposer,
      $$ServiceRequestsTableCreateCompanionBuilder,
      $$ServiceRequestsTableUpdateCompanionBuilder,
      (ServiceRequest, $$ServiceRequestsTableReferences),
      ServiceRequest,
      PrefetchHooks Function({
        bool farmerId,
        bool plotId,
        bool jobsRefs,
        bool disputesRefs,
      })
    >;
typedef $$TractorsTableCreateCompanionBuilder =
    TractorsCompanion Function({
      Value<String> id,
      required String code,
      required String model,
      Value<TractorAvailabilityStatus> status,
      Value<int> operatingHours,
      Value<int?> nextServiceHours,
      Value<DateTime?> lastServiceAt,
      Value<String?> statusNote,
      Value<int> rowid,
    });
typedef $$TractorsTableUpdateCompanionBuilder =
    TractorsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> model,
      Value<TractorAvailabilityStatus> status,
      Value<int> operatingHours,
      Value<int?> nextServiceHours,
      Value<DateTime?> lastServiceAt,
      Value<String?> statusNote,
      Value<int> rowid,
    });

final class $$TractorsTableReferences
    extends BaseReferences<_$AppDatabase, $TractorsTable, Tractor> {
  $$TractorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OperatorsTable, List<Operator>>
  _operatorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.operators,
    aliasName: 'tractors__id__operators__assigned_tractor_id',
  );

  $$OperatorsTableProcessedTableManager get operatorsRefs {
    final manager = $$OperatorsTableTableManager($_db, $_db.operators).filter(
      (f) => f.assignedTractorId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_operatorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'tractors__id__jobs__tractor_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.tractorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceRecordsTable, List<MaintenanceRecord>>
  _maintenanceRecordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceRecords,
        aliasName: 'tractors__id__maintenance_records__tractor_id',
      );

  $$MaintenanceRecordsTableProcessedTableManager get maintenanceRecordsRefs {
    final manager = $$MaintenanceRecordsTableTableManager(
      $_db,
      $_db.maintenanceRecords,
    ).filter((f) => f.tractorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TractorsTableFilterComposer
    extends Composer<_$AppDatabase, $TractorsTable> {
  $$TractorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TractorAvailabilityStatus,
    TractorAvailabilityStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get operatingHours => $composableBuilder(
    column: $table.operatingHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextServiceHours => $composableBuilder(
    column: $table.nextServiceHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastServiceAt => $composableBuilder(
    column: $table.lastServiceAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> operatorsRefs(
    Expression<bool> Function($$OperatorsTableFilterComposer f) f,
  ) {
    final $$OperatorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operators,
      getReferencedColumn: (t) => t.assignedTractorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperatorsTableFilterComposer(
            $db: $db,
            $table: $db.operators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.tractorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceRecordsRefs(
    Expression<bool> Function($$MaintenanceRecordsTableFilterComposer f) f,
  ) {
    final $$MaintenanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.tractorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TractorsTableOrderingComposer
    extends Composer<_$AppDatabase, $TractorsTable> {
  $$TractorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operatingHours => $composableBuilder(
    column: $table.operatingHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextServiceHours => $composableBuilder(
    column: $table.nextServiceHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastServiceAt => $composableBuilder(
    column: $table.lastServiceAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TractorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TractorsTable> {
  $$TractorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TractorAvailabilityStatus, String>
  get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get operatingHours => $composableBuilder(
    column: $table.operatingHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextServiceHours => $composableBuilder(
    column: $table.nextServiceHours,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastServiceAt => $composableBuilder(
    column: $table.lastServiceAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statusNote => $composableBuilder(
    column: $table.statusNote,
    builder: (column) => column,
  );

  Expression<T> operatorsRefs<T extends Object>(
    Expression<T> Function($$OperatorsTableAnnotationComposer a) f,
  ) {
    final $$OperatorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operators,
      getReferencedColumn: (t) => t.assignedTractorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperatorsTableAnnotationComposer(
            $db: $db,
            $table: $db.operators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.tractorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceRecordsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceRecordsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceRecords,
          getReferencedColumn: (t) => t.tractorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TractorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TractorsTable,
          Tractor,
          $$TractorsTableFilterComposer,
          $$TractorsTableOrderingComposer,
          $$TractorsTableAnnotationComposer,
          $$TractorsTableCreateCompanionBuilder,
          $$TractorsTableUpdateCompanionBuilder,
          (Tractor, $$TractorsTableReferences),
          Tractor,
          PrefetchHooks Function({
            bool operatorsRefs,
            bool jobsRefs,
            bool maintenanceRecordsRefs,
          })
        > {
  $$TractorsTableTableManager(_$AppDatabase db, $TractorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TractorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TractorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TractorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<TractorAvailabilityStatus> status = const Value.absent(),
                Value<int> operatingHours = const Value.absent(),
                Value<int?> nextServiceHours = const Value.absent(),
                Value<DateTime?> lastServiceAt = const Value.absent(),
                Value<String?> statusNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TractorsCompanion(
                id: id,
                code: code,
                model: model,
                status: status,
                operatingHours: operatingHours,
                nextServiceHours: nextServiceHours,
                lastServiceAt: lastServiceAt,
                statusNote: statusNote,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String code,
                required String model,
                Value<TractorAvailabilityStatus> status = const Value.absent(),
                Value<int> operatingHours = const Value.absent(),
                Value<int?> nextServiceHours = const Value.absent(),
                Value<DateTime?> lastServiceAt = const Value.absent(),
                Value<String?> statusNote = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TractorsCompanion.insert(
                id: id,
                code: code,
                model: model,
                status: status,
                operatingHours: operatingHours,
                nextServiceHours: nextServiceHours,
                lastServiceAt: lastServiceAt,
                statusNote: statusNote,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TractorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                operatorsRefs = false,
                jobsRefs = false,
                maintenanceRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operatorsRefs) db.operators,
                    if (jobsRefs) db.jobs,
                    if (maintenanceRecordsRefs) db.maintenanceRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operatorsRefs)
                        await $_getPrefetchedData<
                          Tractor,
                          $TractorsTable,
                          Operator
                        >(
                          currentTable: table,
                          referencedTable: $$TractorsTableReferences
                              ._operatorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TractorsTableReferences(
                                db,
                                table,
                                p0,
                              ).operatorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assignedTractorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobsRefs)
                        await $_getPrefetchedData<Tractor, $TractorsTable, Job>(
                          currentTable: table,
                          referencedTable: $$TractorsTableReferences
                              ._jobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TractorsTableReferences(db, table, p0).jobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tractorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceRecordsRefs)
                        await $_getPrefetchedData<
                          Tractor,
                          $TractorsTable,
                          MaintenanceRecord
                        >(
                          currentTable: table,
                          referencedTable: $$TractorsTableReferences
                              ._maintenanceRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TractorsTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tractorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TractorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TractorsTable,
      Tractor,
      $$TractorsTableFilterComposer,
      $$TractorsTableOrderingComposer,
      $$TractorsTableAnnotationComposer,
      $$TractorsTableCreateCompanionBuilder,
      $$TractorsTableUpdateCompanionBuilder,
      (Tractor, $$TractorsTableReferences),
      Tractor,
      PrefetchHooks Function({
        bool operatorsRefs,
        bool jobsRefs,
        bool maintenanceRecordsRefs,
      })
    >;
typedef $$OperatorsTableCreateCompanionBuilder =
    OperatorsCompanion Function({
      Value<String> id,
      required String userId,
      Value<String?> unionId,
      Value<String?> licenseNumber,
      Value<OperatorAvailabilityStatus> status,
      Value<String?> assignedTractorId,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$OperatorsTableUpdateCompanionBuilder =
    OperatorsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> unionId,
      Value<String?> licenseNumber,
      Value<OperatorAvailabilityStatus> status,
      Value<String?> assignedTractorId,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$OperatorsTableReferences
    extends BaseReferences<_$AppDatabase, $OperatorsTable, Operator> {
  $$OperatorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TractorsTable _assignedTractorIdTable(_$AppDatabase db) =>
      db.tractors.createAlias('operators__assigned_tractor_id__tractors__id');

  $$TractorsTableProcessedTableManager? get assignedTractorId {
    final $_column = $_itemColumn<String>('assigned_tractor_id');
    if ($_column == null) return null;
    final manager = $$TractorsTableTableManager(
      $_db,
      $_db.tractors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assignedTractorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JobsTable, List<Job>> _jobsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobs,
    aliasName: 'operators__id__jobs__operator_id',
  );

  $$JobsTableProcessedTableManager get jobsRefs {
    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.operatorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OperatorsTableFilterComposer
    extends Composer<_$AppDatabase, $OperatorsTable> {
  $$OperatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    OperatorAvailabilityStatus,
    OperatorAvailabilityStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$TractorsTableFilterComposer get assignedTractorId {
    final $$TractorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assignedTractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableFilterComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jobsRefs(
    Expression<bool> Function($$JobsTableFilterComposer f) f,
  ) {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.operatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperatorsTable> {
  $$OperatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$TractorsTableOrderingComposer get assignedTractorId {
    final $$TractorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assignedTractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableOrderingComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperatorsTable> {
  $$OperatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get unionId =>
      $composableBuilder(column: $table.unionId, builder: (column) => column);

  GeneratedColumn<String> get licenseNumber => $composableBuilder(
    column: $table.licenseNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OperatorAvailabilityStatus, String>
  get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$TractorsTableAnnotationComposer get assignedTractorId {
    final $$TractorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assignedTractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableAnnotationComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jobsRefs<T extends Object>(
    Expression<T> Function($$JobsTableAnnotationComposer a) f,
  ) {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.operatorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperatorsTable,
          Operator,
          $$OperatorsTableFilterComposer,
          $$OperatorsTableOrderingComposer,
          $$OperatorsTableAnnotationComposer,
          $$OperatorsTableCreateCompanionBuilder,
          $$OperatorsTableUpdateCompanionBuilder,
          (Operator, $$OperatorsTableReferences),
          Operator,
          PrefetchHooks Function({bool assignedTractorId, bool jobsRefs})
        > {
  $$OperatorsTableTableManager(_$AppDatabase db, $OperatorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> unionId = const Value.absent(),
                Value<String?> licenseNumber = const Value.absent(),
                Value<OperatorAvailabilityStatus> status = const Value.absent(),
                Value<String?> assignedTractorId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperatorsCompanion(
                id: id,
                userId: userId,
                unionId: unionId,
                licenseNumber: licenseNumber,
                status: status,
                assignedTractorId: assignedTractorId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String userId,
                Value<String?> unionId = const Value.absent(),
                Value<String?> licenseNumber = const Value.absent(),
                Value<OperatorAvailabilityStatus> status = const Value.absent(),
                Value<String?> assignedTractorId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperatorsCompanion.insert(
                id: id,
                userId: userId,
                unionId: unionId,
                licenseNumber: licenseNumber,
                status: status,
                assignedTractorId: assignedTractorId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperatorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({assignedTractorId = false, jobsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (jobsRefs) db.jobs],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (assignedTractorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.assignedTractorId,
                                    referencedTable: $$OperatorsTableReferences
                                        ._assignedTractorIdTable(db),
                                    referencedColumn: $$OperatorsTableReferences
                                        ._assignedTractorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jobsRefs)
                        await $_getPrefetchedData<
                          Operator,
                          $OperatorsTable,
                          Job
                        >(
                          currentTable: table,
                          referencedTable: $$OperatorsTableReferences
                              ._jobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OperatorsTableReferences(
                                db,
                                table,
                                p0,
                              ).jobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.operatorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OperatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperatorsTable,
      Operator,
      $$OperatorsTableFilterComposer,
      $$OperatorsTableOrderingComposer,
      $$OperatorsTableAnnotationComposer,
      $$OperatorsTableCreateCompanionBuilder,
      $$OperatorsTableUpdateCompanionBuilder,
      (Operator, $$OperatorsTableReferences),
      Operator,
      PrefetchHooks Function({bool assignedTractorId, bool jobsRefs})
    >;
typedef $$ManagerProfilesTableCreateCompanionBuilder =
    ManagerProfilesCompanion Function({
      Value<String> id,
      required String userId,
      Value<String?> unionId,
      Value<String?> employeeNumber,
      Value<String?> positionTitle,
      Value<String?> department,
      Value<int> rowid,
    });
typedef $$ManagerProfilesTableUpdateCompanionBuilder =
    ManagerProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> unionId,
      Value<String?> employeeNumber,
      Value<String?> positionTitle,
      Value<String?> department,
      Value<int> rowid,
    });

class $$ManagerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ManagerProfilesTable> {
  $$ManagerProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionTitle => $composableBuilder(
    column: $table.positionTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ManagerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ManagerProfilesTable> {
  $$ManagerProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionTitle => $composableBuilder(
    column: $table.positionTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManagerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManagerProfilesTable> {
  $$ManagerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get unionId =>
      $composableBuilder(column: $table.unionId, builder: (column) => column);

  GeneratedColumn<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get positionTitle => $composableBuilder(
    column: $table.positionTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );
}

class $$ManagerProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManagerProfilesTable,
          ManagerProfile,
          $$ManagerProfilesTableFilterComposer,
          $$ManagerProfilesTableOrderingComposer,
          $$ManagerProfilesTableAnnotationComposer,
          $$ManagerProfilesTableCreateCompanionBuilder,
          $$ManagerProfilesTableUpdateCompanionBuilder,
          (
            ManagerProfile,
            BaseReferences<
              _$AppDatabase,
              $ManagerProfilesTable,
              ManagerProfile
            >,
          ),
          ManagerProfile,
          PrefetchHooks Function()
        > {
  $$ManagerProfilesTableTableManager(
    _$AppDatabase db,
    $ManagerProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManagerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManagerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManagerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> unionId = const Value.absent(),
                Value<String?> employeeNumber = const Value.absent(),
                Value<String?> positionTitle = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagerProfilesCompanion(
                id: id,
                userId: userId,
                unionId: unionId,
                employeeNumber: employeeNumber,
                positionTitle: positionTitle,
                department: department,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String userId,
                Value<String?> unionId = const Value.absent(),
                Value<String?> employeeNumber = const Value.absent(),
                Value<String?> positionTitle = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManagerProfilesCompanion.insert(
                id: id,
                userId: userId,
                unionId: unionId,
                employeeNumber: employeeNumber,
                positionTitle: positionTitle,
                department: department,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManagerProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManagerProfilesTable,
      ManagerProfile,
      $$ManagerProfilesTableFilterComposer,
      $$ManagerProfilesTableOrderingComposer,
      $$ManagerProfilesTableAnnotationComposer,
      $$ManagerProfilesTableCreateCompanionBuilder,
      $$ManagerProfilesTableUpdateCompanionBuilder,
      (
        ManagerProfile,
        BaseReferences<_$AppDatabase, $ManagerProfilesTable, ManagerProfile>,
      ),
      ManagerProfile,
      PrefetchHooks Function()
    >;
typedef $$DispatcherProfilesTableCreateCompanionBuilder =
    DispatcherProfilesCompanion Function({
      Value<String> id,
      required String userId,
      Value<String?> unionId,
      Value<String?> employeeNumber,
      Value<String?> dispatchZone,
      Value<String?> radioCallSign,
      Value<int> rowid,
    });
typedef $$DispatcherProfilesTableUpdateCompanionBuilder =
    DispatcherProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> unionId,
      Value<String?> employeeNumber,
      Value<String?> dispatchZone,
      Value<String?> radioCallSign,
      Value<int> rowid,
    });

class $$DispatcherProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $DispatcherProfilesTable> {
  $$DispatcherProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dispatchZone => $composableBuilder(
    column: $table.dispatchZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get radioCallSign => $composableBuilder(
    column: $table.radioCallSign,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DispatcherProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $DispatcherProfilesTable> {
  $$DispatcherProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dispatchZone => $composableBuilder(
    column: $table.dispatchZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get radioCallSign => $composableBuilder(
    column: $table.radioCallSign,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DispatcherProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DispatcherProfilesTable> {
  $$DispatcherProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get unionId =>
      $composableBuilder(column: $table.unionId, builder: (column) => column);

  GeneratedColumn<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dispatchZone => $composableBuilder(
    column: $table.dispatchZone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get radioCallSign => $composableBuilder(
    column: $table.radioCallSign,
    builder: (column) => column,
  );
}

class $$DispatcherProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DispatcherProfilesTable,
          DispatcherProfile,
          $$DispatcherProfilesTableFilterComposer,
          $$DispatcherProfilesTableOrderingComposer,
          $$DispatcherProfilesTableAnnotationComposer,
          $$DispatcherProfilesTableCreateCompanionBuilder,
          $$DispatcherProfilesTableUpdateCompanionBuilder,
          (
            DispatcherProfile,
            BaseReferences<
              _$AppDatabase,
              $DispatcherProfilesTable,
              DispatcherProfile
            >,
          ),
          DispatcherProfile,
          PrefetchHooks Function()
        > {
  $$DispatcherProfilesTableTableManager(
    _$AppDatabase db,
    $DispatcherProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DispatcherProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DispatcherProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DispatcherProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> unionId = const Value.absent(),
                Value<String?> employeeNumber = const Value.absent(),
                Value<String?> dispatchZone = const Value.absent(),
                Value<String?> radioCallSign = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DispatcherProfilesCompanion(
                id: id,
                userId: userId,
                unionId: unionId,
                employeeNumber: employeeNumber,
                dispatchZone: dispatchZone,
                radioCallSign: radioCallSign,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String userId,
                Value<String?> unionId = const Value.absent(),
                Value<String?> employeeNumber = const Value.absent(),
                Value<String?> dispatchZone = const Value.absent(),
                Value<String?> radioCallSign = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DispatcherProfilesCompanion.insert(
                id: id,
                userId: userId,
                unionId: unionId,
                employeeNumber: employeeNumber,
                dispatchZone: dispatchZone,
                radioCallSign: radioCallSign,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DispatcherProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DispatcherProfilesTable,
      DispatcherProfile,
      $$DispatcherProfilesTableFilterComposer,
      $$DispatcherProfilesTableOrderingComposer,
      $$DispatcherProfilesTableAnnotationComposer,
      $$DispatcherProfilesTableCreateCompanionBuilder,
      $$DispatcherProfilesTableUpdateCompanionBuilder,
      (
        DispatcherProfile,
        BaseReferences<
          _$AppDatabase,
          $DispatcherProfilesTable,
          DispatcherProfile
        >,
      ),
      DispatcherProfile,
      PrefetchHooks Function()
    >;
typedef $$TechnicianProfilesTableCreateCompanionBuilder =
    TechnicianProfilesCompanion Function({
      Value<String> id,
      required String userId,
      Value<String?> unionId,
      Value<String?> employeeNumber,
      Value<String?> specialization,
      Value<String?> certificationNumber,
      Value<int> rowid,
    });
typedef $$TechnicianProfilesTableUpdateCompanionBuilder =
    TechnicianProfilesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> unionId,
      Value<String?> employeeNumber,
      Value<String?> specialization,
      Value<String?> certificationNumber,
      Value<int> rowid,
    });

class $$TechnicianProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $TechnicianProfilesTable> {
  $$TechnicianProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get certificationNumber => $composableBuilder(
    column: $table.certificationNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TechnicianProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $TechnicianProfilesTable> {
  $$TechnicianProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unionId => $composableBuilder(
    column: $table.unionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get certificationNumber => $composableBuilder(
    column: $table.certificationNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TechnicianProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TechnicianProfilesTable> {
  $$TechnicianProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get unionId =>
      $composableBuilder(column: $table.unionId, builder: (column) => column);

  GeneratedColumn<String> get employeeNumber => $composableBuilder(
    column: $table.employeeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => column,
  );

  GeneratedColumn<String> get certificationNumber => $composableBuilder(
    column: $table.certificationNumber,
    builder: (column) => column,
  );
}

class $$TechnicianProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TechnicianProfilesTable,
          TechnicianProfile,
          $$TechnicianProfilesTableFilterComposer,
          $$TechnicianProfilesTableOrderingComposer,
          $$TechnicianProfilesTableAnnotationComposer,
          $$TechnicianProfilesTableCreateCompanionBuilder,
          $$TechnicianProfilesTableUpdateCompanionBuilder,
          (
            TechnicianProfile,
            BaseReferences<
              _$AppDatabase,
              $TechnicianProfilesTable,
              TechnicianProfile
            >,
          ),
          TechnicianProfile,
          PrefetchHooks Function()
        > {
  $$TechnicianProfilesTableTableManager(
    _$AppDatabase db,
    $TechnicianProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TechnicianProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TechnicianProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TechnicianProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> unionId = const Value.absent(),
                Value<String?> employeeNumber = const Value.absent(),
                Value<String?> specialization = const Value.absent(),
                Value<String?> certificationNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TechnicianProfilesCompanion(
                id: id,
                userId: userId,
                unionId: unionId,
                employeeNumber: employeeNumber,
                specialization: specialization,
                certificationNumber: certificationNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String userId,
                Value<String?> unionId = const Value.absent(),
                Value<String?> employeeNumber = const Value.absent(),
                Value<String?> specialization = const Value.absent(),
                Value<String?> certificationNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TechnicianProfilesCompanion.insert(
                id: id,
                userId: userId,
                unionId: unionId,
                employeeNumber: employeeNumber,
                specialization: specialization,
                certificationNumber: certificationNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TechnicianProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TechnicianProfilesTable,
      TechnicianProfile,
      $$TechnicianProfilesTableFilterComposer,
      $$TechnicianProfilesTableOrderingComposer,
      $$TechnicianProfilesTableAnnotationComposer,
      $$TechnicianProfilesTableCreateCompanionBuilder,
      $$TechnicianProfilesTableUpdateCompanionBuilder,
      (
        TechnicianProfile,
        BaseReferences<
          _$AppDatabase,
          $TechnicianProfilesTable,
          TechnicianProfile
        >,
      ),
      TechnicianProfile,
      PrefetchHooks Function()
    >;
typedef $$JobsTableCreateCompanionBuilder =
    JobsCompanion Function({
      Value<String> id,
      required String jobNumber,
      required String serviceRequestId,
      required String farmerId,
      required String plotId,
      required String tractorId,
      required String operatorId,
      required ServiceKind serviceKind,
      Value<JobStatusDb> status,
      required DateTime scheduledAt,
      required int estimatedDurationMinutes,
      Value<DateTime?> dispatchedAt,
      Value<DateTime?> journeyStartedAt,
      Value<DateTime?> arrivedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<double?> areaServicedHectares,
      Value<String?> completionNotes,
      Value<int> rowid,
    });
typedef $$JobsTableUpdateCompanionBuilder =
    JobsCompanion Function({
      Value<String> id,
      Value<String> jobNumber,
      Value<String> serviceRequestId,
      Value<String> farmerId,
      Value<String> plotId,
      Value<String> tractorId,
      Value<String> operatorId,
      Value<ServiceKind> serviceKind,
      Value<JobStatusDb> status,
      Value<DateTime> scheduledAt,
      Value<int> estimatedDurationMinutes,
      Value<DateTime?> dispatchedAt,
      Value<DateTime?> journeyStartedAt,
      Value<DateTime?> arrivedAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> finishedAt,
      Value<double?> areaServicedHectares,
      Value<String?> completionNotes,
      Value<int> rowid,
    });

final class $$JobsTableReferences
    extends BaseReferences<_$AppDatabase, $JobsTable, Job> {
  $$JobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ServiceRequestsTable _serviceRequestIdTable(_$AppDatabase db) => db
      .serviceRequests
      .createAlias('jobs__service_request_id__service_requests__id');

  $$ServiceRequestsTableProcessedTableManager get serviceRequestId {
    final $_column = $_itemColumn<String>('service_request_id')!;

    final manager = $$ServiceRequestsTableTableManager(
      $_db,
      $_db.serviceRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceRequestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FarmersTable _farmerIdTable(_$AppDatabase db) =>
      db.farmers.createAlias('jobs__farmer_id__farmers__id');

  $$FarmersTableProcessedTableManager get farmerId {
    final $_column = $_itemColumn<String>('farmer_id')!;

    final manager = $$FarmersTableTableManager(
      $_db,
      $_db.farmers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FarmPlotsTable _plotIdTable(_$AppDatabase db) =>
      db.farmPlots.createAlias('jobs__plot_id__farm_plots__id');

  $$FarmPlotsTableProcessedTableManager get plotId {
    final $_column = $_itemColumn<String>('plot_id')!;

    final manager = $$FarmPlotsTableTableManager(
      $_db,
      $_db.farmPlots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TractorsTable _tractorIdTable(_$AppDatabase db) =>
      db.tractors.createAlias('jobs__tractor_id__tractors__id');

  $$TractorsTableProcessedTableManager get tractorId {
    final $_column = $_itemColumn<String>('tractor_id')!;

    final manager = $$TractorsTableTableManager(
      $_db,
      $_db.tractors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tractorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OperatorsTable _operatorIdTable(_$AppDatabase db) =>
      db.operators.createAlias('jobs__operator_id__operators__id');

  $$OperatorsTableProcessedTableManager get operatorId {
    final $_column = $_itemColumn<String>('operator_id')!;

    final manager = $$OperatorsTableTableManager(
      $_db,
      $_db.operators,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_operatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$JobTrackingPointsTable, List<JobTrackingPoint>>
  _jobTrackingPointsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.jobTrackingPoints,
        aliasName: 'jobs__id__job_tracking_points__job_id',
      );

  $$JobTrackingPointsTableProcessedTableManager get jobTrackingPointsRefs {
    final manager = $$JobTrackingPointsTableTableManager(
      $_db,
      $_db.jobTrackingPoints,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _jobTrackingPointsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JobNotesTable, List<JobNote>> _jobNotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.jobNotes,
    aliasName: 'jobs__id__job_notes__job_id',
  );

  $$JobNotesTableProcessedTableManager get jobNotesRefs {
    final manager = $$JobNotesTableTableManager(
      $_db,
      $_db.jobNotes,
    ).filter((f) => f.jobId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_jobNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$JobsTableFilterComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobNumber => $composableBuilder(
    column: $table.jobNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ServiceKind, ServiceKind, String>
  get serviceKind => $composableBuilder(
    column: $table.serviceKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<JobStatusDb, JobStatusDb, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dispatchedAt => $composableBuilder(
    column: $table.dispatchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get journeyStartedAt => $composableBuilder(
    column: $table.journeyStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivedAt => $composableBuilder(
    column: $table.arrivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaServicedHectares => $composableBuilder(
    column: $table.areaServicedHectares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionNotes => $composableBuilder(
    column: $table.completionNotes,
    builder: (column) => ColumnFilters(column),
  );

  $$ServiceRequestsTableFilterComposer get serviceRequestId {
    final $$ServiceRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRequestId,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmersTableFilterComposer get farmerId {
    final $$FarmersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableFilterComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmPlotsTableFilterComposer get plotId {
    final $$FarmPlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableFilterComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TractorsTableFilterComposer get tractorId {
    final $$TractorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableFilterComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperatorsTableFilterComposer get operatorId {
    final $$OperatorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operatorId,
      referencedTable: $db.operators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperatorsTableFilterComposer(
            $db: $db,
            $table: $db.operators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> jobTrackingPointsRefs(
    Expression<bool> Function($$JobTrackingPointsTableFilterComposer f) f,
  ) {
    final $$JobTrackingPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobTrackingPoints,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobTrackingPointsTableFilterComposer(
            $db: $db,
            $table: $db.jobTrackingPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> jobNotesRefs(
    Expression<bool> Function($$JobNotesTableFilterComposer f) f,
  ) {
    final $$JobNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobNotes,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobNotesTableFilterComposer(
            $db: $db,
            $table: $db.jobNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableOrderingComposer extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobNumber => $composableBuilder(
    column: $table.jobNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceKind => $composableBuilder(
    column: $table.serviceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dispatchedAt => $composableBuilder(
    column: $table.dispatchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get journeyStartedAt => $composableBuilder(
    column: $table.journeyStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivedAt => $composableBuilder(
    column: $table.arrivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaServicedHectares => $composableBuilder(
    column: $table.areaServicedHectares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionNotes => $composableBuilder(
    column: $table.completionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServiceRequestsTableOrderingComposer get serviceRequestId {
    final $$ServiceRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRequestId,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmersTableOrderingComposer get farmerId {
    final $$FarmersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableOrderingComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmPlotsTableOrderingComposer get plotId {
    final $$FarmPlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableOrderingComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TractorsTableOrderingComposer get tractorId {
    final $$TractorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableOrderingComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperatorsTableOrderingComposer get operatorId {
    final $$OperatorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operatorId,
      referencedTable: $db.operators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperatorsTableOrderingComposer(
            $db: $db,
            $table: $db.operators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobNumber =>
      $composableBuilder(column: $table.jobNumber, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ServiceKind, String> get serviceKind =>
      $composableBuilder(
        column: $table.serviceKind,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<JobStatusDb, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedDurationMinutes => $composableBuilder(
    column: $table.estimatedDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dispatchedAt => $composableBuilder(
    column: $table.dispatchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get journeyStartedAt => $composableBuilder(
    column: $table.journeyStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get arrivedAt =>
      $composableBuilder(column: $table.arrivedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaServicedHectares => $composableBuilder(
    column: $table.areaServicedHectares,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionNotes => $composableBuilder(
    column: $table.completionNotes,
    builder: (column) => column,
  );

  $$ServiceRequestsTableAnnotationComposer get serviceRequestId {
    final $$ServiceRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRequestId,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmersTableAnnotationComposer get farmerId {
    final $$FarmersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableAnnotationComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmPlotsTableAnnotationComposer get plotId {
    final $$FarmPlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plotId,
      referencedTable: $db.farmPlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmPlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.farmPlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TractorsTableAnnotationComposer get tractorId {
    final $$TractorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableAnnotationComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperatorsTableAnnotationComposer get operatorId {
    final $$OperatorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operatorId,
      referencedTable: $db.operators,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperatorsTableAnnotationComposer(
            $db: $db,
            $table: $db.operators,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> jobTrackingPointsRefs<T extends Object>(
    Expression<T> Function($$JobTrackingPointsTableAnnotationComposer a) f,
  ) {
    final $$JobTrackingPointsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.jobTrackingPoints,
          getReferencedColumn: (t) => t.jobId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$JobTrackingPointsTableAnnotationComposer(
                $db: $db,
                $table: $db.jobTrackingPoints,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> jobNotesRefs<T extends Object>(
    Expression<T> Function($$JobNotesTableAnnotationComposer a) f,
  ) {
    final $$JobNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.jobNotes,
      getReferencedColumn: (t) => t.jobId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.jobNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, $$JobsTableReferences),
          Job,
          PrefetchHooks Function({
            bool serviceRequestId,
            bool farmerId,
            bool plotId,
            bool tractorId,
            bool operatorId,
            bool jobTrackingPointsRefs,
            bool jobNotesRefs,
          })
        > {
  $$JobsTableTableManager(_$AppDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobNumber = const Value.absent(),
                Value<String> serviceRequestId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String> plotId = const Value.absent(),
                Value<String> tractorId = const Value.absent(),
                Value<String> operatorId = const Value.absent(),
                Value<ServiceKind> serviceKind = const Value.absent(),
                Value<JobStatusDb> status = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<int> estimatedDurationMinutes = const Value.absent(),
                Value<DateTime?> dispatchedAt = const Value.absent(),
                Value<DateTime?> journeyStartedAt = const Value.absent(),
                Value<DateTime?> arrivedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<double?> areaServicedHectares = const Value.absent(),
                Value<String?> completionNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                jobNumber: jobNumber,
                serviceRequestId: serviceRequestId,
                farmerId: farmerId,
                plotId: plotId,
                tractorId: tractorId,
                operatorId: operatorId,
                serviceKind: serviceKind,
                status: status,
                scheduledAt: scheduledAt,
                estimatedDurationMinutes: estimatedDurationMinutes,
                dispatchedAt: dispatchedAt,
                journeyStartedAt: journeyStartedAt,
                arrivedAt: arrivedAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
                areaServicedHectares: areaServicedHectares,
                completionNotes: completionNotes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String jobNumber,
                required String serviceRequestId,
                required String farmerId,
                required String plotId,
                required String tractorId,
                required String operatorId,
                required ServiceKind serviceKind,
                Value<JobStatusDb> status = const Value.absent(),
                required DateTime scheduledAt,
                required int estimatedDurationMinutes,
                Value<DateTime?> dispatchedAt = const Value.absent(),
                Value<DateTime?> journeyStartedAt = const Value.absent(),
                Value<DateTime?> arrivedAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<double?> areaServicedHectares = const Value.absent(),
                Value<String?> completionNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                jobNumber: jobNumber,
                serviceRequestId: serviceRequestId,
                farmerId: farmerId,
                plotId: plotId,
                tractorId: tractorId,
                operatorId: operatorId,
                serviceKind: serviceKind,
                status: status,
                scheduledAt: scheduledAt,
                estimatedDurationMinutes: estimatedDurationMinutes,
                dispatchedAt: dispatchedAt,
                journeyStartedAt: journeyStartedAt,
                arrivedAt: arrivedAt,
                startedAt: startedAt,
                finishedAt: finishedAt,
                areaServicedHectares: areaServicedHectares,
                completionNotes: completionNotes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$JobsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                serviceRequestId = false,
                farmerId = false,
                plotId = false,
                tractorId = false,
                operatorId = false,
                jobTrackingPointsRefs = false,
                jobNotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (jobTrackingPointsRefs) db.jobTrackingPoints,
                    if (jobNotesRefs) db.jobNotes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (serviceRequestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.serviceRequestId,
                                    referencedTable: $$JobsTableReferences
                                        ._serviceRequestIdTable(db),
                                    referencedColumn: $$JobsTableReferences
                                        ._serviceRequestIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (farmerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.farmerId,
                                    referencedTable: $$JobsTableReferences
                                        ._farmerIdTable(db),
                                    referencedColumn: $$JobsTableReferences
                                        ._farmerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (plotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.plotId,
                                    referencedTable: $$JobsTableReferences
                                        ._plotIdTable(db),
                                    referencedColumn: $$JobsTableReferences
                                        ._plotIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (tractorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tractorId,
                                    referencedTable: $$JobsTableReferences
                                        ._tractorIdTable(db),
                                    referencedColumn: $$JobsTableReferences
                                        ._tractorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (operatorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.operatorId,
                                    referencedTable: $$JobsTableReferences
                                        ._operatorIdTable(db),
                                    referencedColumn: $$JobsTableReferences
                                        ._operatorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (jobTrackingPointsRefs)
                        await $_getPrefetchedData<
                          Job,
                          $JobsTable,
                          JobTrackingPoint
                        >(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._jobTrackingPointsRefsTable(db),
                          managerFromTypedResult: (p0) => $$JobsTableReferences(
                            db,
                            table,
                            p0,
                          ).jobTrackingPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (jobNotesRefs)
                        await $_getPrefetchedData<Job, $JobsTable, JobNote>(
                          currentTable: table,
                          referencedTable: $$JobsTableReferences
                              ._jobNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$JobsTableReferences(db, table, p0).jobNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.jobId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, $$JobsTableReferences),
      Job,
      PrefetchHooks Function({
        bool serviceRequestId,
        bool farmerId,
        bool plotId,
        bool tractorId,
        bool operatorId,
        bool jobTrackingPointsRefs,
        bool jobNotesRefs,
      })
    >;
typedef $$JobTrackingPointsTableCreateCompanionBuilder =
    JobTrackingPointsCompanion Function({
      Value<String> id,
      required String jobId,
      required double latitude,
      required double longitude,
      Value<double?> accuracyMeters,
      required DateTime recordedAt,
      Value<bool> insideAssignedPlot,
      Value<int> rowid,
    });
typedef $$JobTrackingPointsTableUpdateCompanionBuilder =
    JobTrackingPointsCompanion Function({
      Value<String> id,
      Value<String> jobId,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> accuracyMeters,
      Value<DateTime> recordedAt,
      Value<bool> insideAssignedPlot,
      Value<int> rowid,
    });

final class $$JobTrackingPointsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $JobTrackingPointsTable,
          JobTrackingPoint
        > {
  $$JobTrackingPointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('job_tracking_points__job_id__jobs__id');

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<String>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobTrackingPointsTableFilterComposer
    extends Composer<_$AppDatabase, $JobTrackingPointsTable> {
  $$JobTrackingPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get insideAssignedPlot => $composableBuilder(
    column: $table.insideAssignedPlot,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobTrackingPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobTrackingPointsTable> {
  $$JobTrackingPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get insideAssignedPlot => $composableBuilder(
    column: $table.insideAssignedPlot,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobTrackingPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobTrackingPointsTable> {
  $$JobTrackingPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get insideAssignedPlot => $composableBuilder(
    column: $table.insideAssignedPlot,
    builder: (column) => column,
  );

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobTrackingPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobTrackingPointsTable,
          JobTrackingPoint,
          $$JobTrackingPointsTableFilterComposer,
          $$JobTrackingPointsTableOrderingComposer,
          $$JobTrackingPointsTableAnnotationComposer,
          $$JobTrackingPointsTableCreateCompanionBuilder,
          $$JobTrackingPointsTableUpdateCompanionBuilder,
          (JobTrackingPoint, $$JobTrackingPointsTableReferences),
          JobTrackingPoint,
          PrefetchHooks Function({bool jobId})
        > {
  $$JobTrackingPointsTableTableManager(
    _$AppDatabase db,
    $JobTrackingPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobTrackingPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobTrackingPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobTrackingPointsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<bool> insideAssignedPlot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobTrackingPointsCompanion(
                id: id,
                jobId: jobId,
                latitude: latitude,
                longitude: longitude,
                accuracyMeters: accuracyMeters,
                recordedAt: recordedAt,
                insideAssignedPlot: insideAssignedPlot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String jobId,
                required double latitude,
                required double longitude,
                Value<double?> accuracyMeters = const Value.absent(),
                required DateTime recordedAt,
                Value<bool> insideAssignedPlot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobTrackingPointsCompanion.insert(
                id: id,
                jobId: jobId,
                latitude: latitude,
                longitude: longitude,
                accuracyMeters: accuracyMeters,
                recordedAt: recordedAt,
                insideAssignedPlot: insideAssignedPlot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobTrackingPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable:
                                    $$JobTrackingPointsTableReferences
                                        ._jobIdTable(db),
                                referencedColumn:
                                    $$JobTrackingPointsTableReferences
                                        ._jobIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JobTrackingPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobTrackingPointsTable,
      JobTrackingPoint,
      $$JobTrackingPointsTableFilterComposer,
      $$JobTrackingPointsTableOrderingComposer,
      $$JobTrackingPointsTableAnnotationComposer,
      $$JobTrackingPointsTableCreateCompanionBuilder,
      $$JobTrackingPointsTableUpdateCompanionBuilder,
      (JobTrackingPoint, $$JobTrackingPointsTableReferences),
      JobTrackingPoint,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$JobNotesTableCreateCompanionBuilder =
    JobNotesCompanion Function({
      Value<String> id,
      required String jobId,
      required String authorUserId,
      required String note,
      Value<int> rowid,
    });
typedef $$JobNotesTableUpdateCompanionBuilder =
    JobNotesCompanion Function({
      Value<String> id,
      Value<String> jobId,
      Value<String> authorUserId,
      Value<String> note,
      Value<int> rowid,
    });

final class $$JobNotesTableReferences
    extends BaseReferences<_$AppDatabase, $JobNotesTable, JobNote> {
  $$JobNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $JobsTable _jobIdTable(_$AppDatabase db) =>
      db.jobs.createAlias('job_notes__job_id__jobs__id');

  $$JobsTableProcessedTableManager get jobId {
    final $_column = $_itemColumn<String>('job_id')!;

    final manager = $$JobsTableTableManager(
      $_db,
      $_db.jobs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_jobIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JobNotesTableFilterComposer
    extends Composer<_$AppDatabase, $JobNotesTable> {
  $$JobNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorUserId => $composableBuilder(
    column: $table.authorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$JobsTableFilterComposer get jobId {
    final $$JobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableFilterComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $JobNotesTable> {
  $$JobNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorUserId => $composableBuilder(
    column: $table.authorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$JobsTableOrderingComposer get jobId {
    final $$JobsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableOrderingComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobNotesTable> {
  $$JobNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get authorUserId => $composableBuilder(
    column: $table.authorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$JobsTableAnnotationComposer get jobId {
    final $$JobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.jobId,
      referencedTable: $db.jobs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JobsTableAnnotationComposer(
            $db: $db,
            $table: $db.jobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JobNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobNotesTable,
          JobNote,
          $$JobNotesTableFilterComposer,
          $$JobNotesTableOrderingComposer,
          $$JobNotesTableAnnotationComposer,
          $$JobNotesTableCreateCompanionBuilder,
          $$JobNotesTableUpdateCompanionBuilder,
          (JobNote, $$JobNotesTableReferences),
          JobNote,
          PrefetchHooks Function({bool jobId})
        > {
  $$JobNotesTableTableManager(_$AppDatabase db, $JobNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<String> authorUserId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobNotesCompanion(
                id: id,
                jobId: jobId,
                authorUserId: authorUserId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String jobId,
                required String authorUserId,
                required String note,
                Value<int> rowid = const Value.absent(),
              }) => JobNotesCompanion.insert(
                id: id,
                jobId: jobId,
                authorUserId: authorUserId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JobNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({jobId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (jobId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.jobId,
                                referencedTable: $$JobNotesTableReferences
                                    ._jobIdTable(db),
                                referencedColumn: $$JobNotesTableReferences
                                    ._jobIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JobNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobNotesTable,
      JobNote,
      $$JobNotesTableFilterComposer,
      $$JobNotesTableOrderingComposer,
      $$JobNotesTableAnnotationComposer,
      $$JobNotesTableCreateCompanionBuilder,
      $$JobNotesTableUpdateCompanionBuilder,
      (JobNote, $$JobNotesTableReferences),
      JobNote,
      PrefetchHooks Function({bool jobId})
    >;
typedef $$DisputesTableCreateCompanionBuilder =
    DisputesCompanion Function({
      Value<String> id,
      required String serviceRequestId,
      Value<String?> jobId,
      required String farmerId,
      required String reason,
      required String description,
      Value<DisputeStatus> status,
      Value<int> rowid,
    });
typedef $$DisputesTableUpdateCompanionBuilder =
    DisputesCompanion Function({
      Value<String> id,
      Value<String> serviceRequestId,
      Value<String?> jobId,
      Value<String> farmerId,
      Value<String> reason,
      Value<String> description,
      Value<DisputeStatus> status,
      Value<int> rowid,
    });

final class $$DisputesTableReferences
    extends BaseReferences<_$AppDatabase, $DisputesTable, Dispute> {
  $$DisputesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ServiceRequestsTable _serviceRequestIdTable(_$AppDatabase db) => db
      .serviceRequests
      .createAlias('disputes__service_request_id__service_requests__id');

  $$ServiceRequestsTableProcessedTableManager get serviceRequestId {
    final $_column = $_itemColumn<String>('service_request_id')!;

    final manager = $$ServiceRequestsTableTableManager(
      $_db,
      $_db.serviceRequests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_serviceRequestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FarmersTable _farmerIdTable(_$AppDatabase db) =>
      db.farmers.createAlias('disputes__farmer_id__farmers__id');

  $$FarmersTableProcessedTableManager get farmerId {
    final $_column = $_itemColumn<String>('farmer_id')!;

    final manager = $$FarmersTableTableManager(
      $_db,
      $_db.farmers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DisputesTableFilterComposer
    extends Composer<_$AppDatabase, $DisputesTable> {
  $$DisputesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DisputeStatus, DisputeStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ServiceRequestsTableFilterComposer get serviceRequestId {
    final $$ServiceRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRequestId,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableFilterComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmersTableFilterComposer get farmerId {
    final $$FarmersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableFilterComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DisputesTableOrderingComposer
    extends Composer<_$AppDatabase, $DisputesTable> {
  $$DisputesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServiceRequestsTableOrderingComposer get serviceRequestId {
    final $$ServiceRequestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRequestId,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableOrderingComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmersTableOrderingComposer get farmerId {
    final $$FarmersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableOrderingComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DisputesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DisputesTable> {
  $$DisputesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DisputeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ServiceRequestsTableAnnotationComposer get serviceRequestId {
    final $$ServiceRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.serviceRequestId,
      referencedTable: $db.serviceRequests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FarmersTableAnnotationComposer get farmerId {
    final $$FarmersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.farmerId,
      referencedTable: $db.farmers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FarmersTableAnnotationComposer(
            $db: $db,
            $table: $db.farmers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DisputesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DisputesTable,
          Dispute,
          $$DisputesTableFilterComposer,
          $$DisputesTableOrderingComposer,
          $$DisputesTableAnnotationComposer,
          $$DisputesTableCreateCompanionBuilder,
          $$DisputesTableUpdateCompanionBuilder,
          (Dispute, $$DisputesTableReferences),
          Dispute,
          PrefetchHooks Function({bool serviceRequestId, bool farmerId})
        > {
  $$DisputesTableTableManager(_$AppDatabase db, $DisputesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DisputesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DisputesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DisputesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serviceRequestId = const Value.absent(),
                Value<String?> jobId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DisputeStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DisputesCompanion(
                id: id,
                serviceRequestId: serviceRequestId,
                jobId: jobId,
                farmerId: farmerId,
                reason: reason,
                description: description,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String serviceRequestId,
                Value<String?> jobId = const Value.absent(),
                required String farmerId,
                required String reason,
                required String description,
                Value<DisputeStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DisputesCompanion.insert(
                id: id,
                serviceRequestId: serviceRequestId,
                jobId: jobId,
                farmerId: farmerId,
                reason: reason,
                description: description,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DisputesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({serviceRequestId = false, farmerId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (serviceRequestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.serviceRequestId,
                                    referencedTable: $$DisputesTableReferences
                                        ._serviceRequestIdTable(db),
                                    referencedColumn: $$DisputesTableReferences
                                        ._serviceRequestIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (farmerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.farmerId,
                                    referencedTable: $$DisputesTableReferences
                                        ._farmerIdTable(db),
                                    referencedColumn: $$DisputesTableReferences
                                        ._farmerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$DisputesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DisputesTable,
      Dispute,
      $$DisputesTableFilterComposer,
      $$DisputesTableOrderingComposer,
      $$DisputesTableAnnotationComposer,
      $$DisputesTableCreateCompanionBuilder,
      $$DisputesTableUpdateCompanionBuilder,
      (Dispute, $$DisputesTableReferences),
      Dispute,
      PrefetchHooks Function({bool serviceRequestId, bool farmerId})
    >;
typedef $$MaintenanceRecordsTableCreateCompanionBuilder =
    MaintenanceRecordsCompanion Function({
      Value<String> id,
      required String tractorId,
      required String technicianUserId,
      required MaintenanceTypeDb type,
      required String problem,
      required String workPerformed,
      Value<RepairStatusDb> status,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$MaintenanceRecordsTableUpdateCompanionBuilder =
    MaintenanceRecordsCompanion Function({
      Value<String> id,
      Value<String> tractorId,
      Value<String> technicianUserId,
      Value<MaintenanceTypeDb> type,
      Value<String> problem,
      Value<String> workPerformed,
      Value<RepairStatusDb> status,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$MaintenanceRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceRecordsTable,
          MaintenanceRecord
        > {
  $$MaintenanceRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TractorsTable _tractorIdTable(_$AppDatabase db) =>
      db.tractors.createAlias('maintenance_records__tractor_id__tractors__id');

  $$TractorsTableProcessedTableManager get tractorId {
    final $_column = $_itemColumn<String>('tractor_id')!;

    final manager = $$TractorsTableTableManager(
      $_db,
      $_db.tractors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tractorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MaintenancePartsUsedTable,
    List<MaintenancePartsUsedData>
  >
  _maintenancePartsUsedRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.maintenancePartsUsed,
    aliasName:
        'maintenance_records__id__maintenance_parts_used__maintenance_record_id',
  );

  $$MaintenancePartsUsedTableProcessedTableManager
  get maintenancePartsUsedRefs {
    final manager =
        $$MaintenancePartsUsedTableTableManager(
          $_db,
          $_db.maintenancePartsUsed,
        ).filter(
          (f) =>
              f.maintenanceRecordId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _maintenancePartsUsedRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaintenanceRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get technicianUserId => $composableBuilder(
    column: $table.technicianUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MaintenanceTypeDb, MaintenanceTypeDb, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get problem => $composableBuilder(
    column: $table.problem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workPerformed => $composableBuilder(
    column: $table.workPerformed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RepairStatusDb, RepairStatusDb, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TractorsTableFilterComposer get tractorId {
    final $$TractorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableFilterComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> maintenancePartsUsedRefs(
    Expression<bool> Function($$MaintenancePartsUsedTableFilterComposer f) f,
  ) {
    final $$MaintenancePartsUsedTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenancePartsUsed,
      getReferencedColumn: (t) => t.maintenanceRecordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenancePartsUsedTableFilterComposer(
            $db: $db,
            $table: $db.maintenancePartsUsed,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaintenanceRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get technicianUserId => $composableBuilder(
    column: $table.technicianUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problem => $composableBuilder(
    column: $table.problem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workPerformed => $composableBuilder(
    column: $table.workPerformed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TractorsTableOrderingComposer get tractorId {
    final $$TractorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableOrderingComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceRecordsTable> {
  $$MaintenanceRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get technicianUserId => $composableBuilder(
    column: $table.technicianUserId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MaintenanceTypeDb, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get problem =>
      $composableBuilder(column: $table.problem, builder: (column) => column);

  GeneratedColumn<String> get workPerformed => $composableBuilder(
    column: $table.workPerformed,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RepairStatusDb, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$TractorsTableAnnotationComposer get tractorId {
    final $$TractorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tractorId,
      referencedTable: $db.tractors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TractorsTableAnnotationComposer(
            $db: $db,
            $table: $db.tractors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> maintenancePartsUsedRefs<T extends Object>(
    Expression<T> Function($$MaintenancePartsUsedTableAnnotationComposer a) f,
  ) {
    final $$MaintenancePartsUsedTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenancePartsUsed,
          getReferencedColumn: (t) => t.maintenanceRecordId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenancePartsUsedTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenancePartsUsed,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MaintenanceRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceRecordsTable,
          MaintenanceRecord,
          $$MaintenanceRecordsTableFilterComposer,
          $$MaintenanceRecordsTableOrderingComposer,
          $$MaintenanceRecordsTableAnnotationComposer,
          $$MaintenanceRecordsTableCreateCompanionBuilder,
          $$MaintenanceRecordsTableUpdateCompanionBuilder,
          (MaintenanceRecord, $$MaintenanceRecordsTableReferences),
          MaintenanceRecord,
          PrefetchHooks Function({
            bool tractorId,
            bool maintenancePartsUsedRefs,
          })
        > {
  $$MaintenanceRecordsTableTableManager(
    _$AppDatabase db,
    $MaintenanceRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tractorId = const Value.absent(),
                Value<String> technicianUserId = const Value.absent(),
                Value<MaintenanceTypeDb> type = const Value.absent(),
                Value<String> problem = const Value.absent(),
                Value<String> workPerformed = const Value.absent(),
                Value<RepairStatusDb> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceRecordsCompanion(
                id: id,
                tractorId: tractorId,
                technicianUserId: technicianUserId,
                type: type,
                problem: problem,
                workPerformed: workPerformed,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String tractorId,
                required String technicianUserId,
                required MaintenanceTypeDb type,
                required String problem,
                required String workPerformed,
                Value<RepairStatusDb> status = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceRecordsCompanion.insert(
                id: id,
                tractorId: tractorId,
                technicianUserId: technicianUserId,
                type: type,
                problem: problem,
                workPerformed: workPerformed,
                status: status,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tractorId = false, maintenancePartsUsedRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (maintenancePartsUsedRefs) db.maintenancePartsUsed,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tractorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tractorId,
                                    referencedTable:
                                        $$MaintenanceRecordsTableReferences
                                            ._tractorIdTable(db),
                                    referencedColumn:
                                        $$MaintenanceRecordsTableReferences
                                            ._tractorIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (maintenancePartsUsedRefs)
                        await $_getPrefetchedData<
                          MaintenanceRecord,
                          $MaintenanceRecordsTable,
                          MaintenancePartsUsedData
                        >(
                          currentTable: table,
                          referencedTable: $$MaintenanceRecordsTableReferences
                              ._maintenancePartsUsedRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MaintenanceRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenancePartsUsedRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.maintenanceRecordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MaintenanceRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceRecordsTable,
      MaintenanceRecord,
      $$MaintenanceRecordsTableFilterComposer,
      $$MaintenanceRecordsTableOrderingComposer,
      $$MaintenanceRecordsTableAnnotationComposer,
      $$MaintenanceRecordsTableCreateCompanionBuilder,
      $$MaintenanceRecordsTableUpdateCompanionBuilder,
      (MaintenanceRecord, $$MaintenanceRecordsTableReferences),
      MaintenanceRecord,
      PrefetchHooks Function({bool tractorId, bool maintenancePartsUsedRefs})
    >;
typedef $$PartsTableCreateCompanionBuilder =
    PartsCompanion Function({
      Value<String> id,
      required String name,
      required String unit,
      Value<int> stockQuantity,
      Value<int> reorderLevel,
      Value<int> rowid,
    });
typedef $$PartsTableUpdateCompanionBuilder =
    PartsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> unit,
      Value<int> stockQuantity,
      Value<int> reorderLevel,
      Value<int> rowid,
    });

final class $$PartsTableReferences
    extends BaseReferences<_$AppDatabase, $PartsTable, Part> {
  $$PartsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $MaintenancePartsUsedTable,
    List<MaintenancePartsUsedData>
  >
  _maintenancePartsUsedRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenancePartsUsed,
        aliasName: 'parts__id__maintenance_parts_used__part_id',
      );

  $$MaintenancePartsUsedTableProcessedTableManager
  get maintenancePartsUsedRefs {
    final manager = $$MaintenancePartsUsedTableTableManager(
      $_db,
      $_db.maintenancePartsUsed,
    ).filter((f) => f.partId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenancePartsUsedRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartsTableFilterComposer extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> maintenancePartsUsedRefs(
    Expression<bool> Function($$MaintenancePartsUsedTableFilterComposer f) f,
  ) {
    final $$MaintenancePartsUsedTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenancePartsUsed,
      getReferencedColumn: (t) => t.partId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenancePartsUsedTableFilterComposer(
            $db: $db,
            $table: $db.maintenancePartsUsed,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartsTable> {
  $$PartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  Expression<T> maintenancePartsUsedRefs<T extends Object>(
    Expression<T> Function($$MaintenancePartsUsedTableAnnotationComposer a) f,
  ) {
    final $$MaintenancePartsUsedTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenancePartsUsed,
          getReferencedColumn: (t) => t.partId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenancePartsUsedTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenancePartsUsed,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartsTable,
          Part,
          $$PartsTableFilterComposer,
          $$PartsTableOrderingComposer,
          $$PartsTableAnnotationComposer,
          $$PartsTableCreateCompanionBuilder,
          $$PartsTableUpdateCompanionBuilder,
          (Part, $$PartsTableReferences),
          Part,
          PrefetchHooks Function({bool maintenancePartsUsedRefs})
        > {
  $$PartsTableTableManager(_$AppDatabase db, $PartsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> stockQuantity = const Value.absent(),
                Value<int> reorderLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion(
                id: id,
                name: name,
                unit: unit,
                stockQuantity: stockQuantity,
                reorderLevel: reorderLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String unit,
                Value<int> stockQuantity = const Value.absent(),
                Value<int> reorderLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartsCompanion.insert(
                id: id,
                name: name,
                unit: unit,
                stockQuantity: stockQuantity,
                reorderLevel: reorderLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PartsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({maintenancePartsUsedRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (maintenancePartsUsedRefs) db.maintenancePartsUsed,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (maintenancePartsUsedRefs)
                    await $_getPrefetchedData<
                      Part,
                      $PartsTable,
                      MaintenancePartsUsedData
                    >(
                      currentTable: table,
                      referencedTable: $$PartsTableReferences
                          ._maintenancePartsUsedRefsTable(db),
                      managerFromTypedResult: (p0) => $$PartsTableReferences(
                        db,
                        table,
                        p0,
                      ).maintenancePartsUsedRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.partId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartsTable,
      Part,
      $$PartsTableFilterComposer,
      $$PartsTableOrderingComposer,
      $$PartsTableAnnotationComposer,
      $$PartsTableCreateCompanionBuilder,
      $$PartsTableUpdateCompanionBuilder,
      (Part, $$PartsTableReferences),
      Part,
      PrefetchHooks Function({bool maintenancePartsUsedRefs})
    >;
typedef $$MaintenancePartsUsedTableCreateCompanionBuilder =
    MaintenancePartsUsedCompanion Function({
      Value<String> id,
      required String maintenanceRecordId,
      required String partId,
      Value<int> quantity,
      Value<int> rowid,
    });
typedef $$MaintenancePartsUsedTableUpdateCompanionBuilder =
    MaintenancePartsUsedCompanion Function({
      Value<String> id,
      Value<String> maintenanceRecordId,
      Value<String> partId,
      Value<int> quantity,
      Value<int> rowid,
    });

final class $$MaintenancePartsUsedTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenancePartsUsedTable,
          MaintenancePartsUsedData
        > {
  $$MaintenancePartsUsedTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MaintenanceRecordsTable _maintenanceRecordIdTable(
    _$AppDatabase db,
  ) => db.maintenanceRecords.createAlias(
    'maintenance_parts_used__maintenance_record_id__maintenance_records__id',
  );

  $$MaintenanceRecordsTableProcessedTableManager get maintenanceRecordId {
    final $_column = $_itemColumn<String>('maintenance_record_id')!;

    final manager = $$MaintenanceRecordsTableTableManager(
      $_db,
      $_db.maintenanceRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_maintenanceRecordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PartsTable _partIdTable(_$AppDatabase db) =>
      db.parts.createAlias('maintenance_parts_used__part_id__parts__id');

  $$PartsTableProcessedTableManager get partId {
    final $_column = $_itemColumn<String>('part_id')!;

    final manager = $$PartsTableTableManager(
      $_db,
      $_db.parts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenancePartsUsedTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenancePartsUsedTable> {
  $$MaintenancePartsUsedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  $$MaintenanceRecordsTableFilterComposer get maintenanceRecordId {
    final $$MaintenanceRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maintenanceRecordId,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartsTableFilterComposer get partId {
    final $$PartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.parts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartsTableFilterComposer(
            $db: $db,
            $table: $db.parts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenancePartsUsedTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenancePartsUsedTable> {
  $$MaintenancePartsUsedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$MaintenanceRecordsTableOrderingComposer get maintenanceRecordId {
    final $$MaintenanceRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.maintenanceRecordId,
      referencedTable: $db.maintenanceRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.maintenanceRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartsTableOrderingComposer get partId {
    final $$PartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.parts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartsTableOrderingComposer(
            $db: $db,
            $table: $db.parts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenancePartsUsedTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenancePartsUsedTable> {
  $$MaintenancePartsUsedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$MaintenanceRecordsTableAnnotationComposer get maintenanceRecordId {
    final $$MaintenanceRecordsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.maintenanceRecordId,
          referencedTable: $db.maintenanceRecords,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceRecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceRecords,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PartsTableAnnotationComposer get partId {
    final $$PartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partId,
      referencedTable: $db.parts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartsTableAnnotationComposer(
            $db: $db,
            $table: $db.parts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenancePartsUsedTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenancePartsUsedTable,
          MaintenancePartsUsedData,
          $$MaintenancePartsUsedTableFilterComposer,
          $$MaintenancePartsUsedTableOrderingComposer,
          $$MaintenancePartsUsedTableAnnotationComposer,
          $$MaintenancePartsUsedTableCreateCompanionBuilder,
          $$MaintenancePartsUsedTableUpdateCompanionBuilder,
          (MaintenancePartsUsedData, $$MaintenancePartsUsedTableReferences),
          MaintenancePartsUsedData,
          PrefetchHooks Function({bool maintenanceRecordId, bool partId})
        > {
  $$MaintenancePartsUsedTableTableManager(
    _$AppDatabase db,
    $MaintenancePartsUsedTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenancePartsUsedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenancePartsUsedTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenancePartsUsedTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> maintenanceRecordId = const Value.absent(),
                Value<String> partId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenancePartsUsedCompanion(
                id: id,
                maintenanceRecordId: maintenanceRecordId,
                partId: partId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String maintenanceRecordId,
                required String partId,
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenancePartsUsedCompanion.insert(
                id: id,
                maintenanceRecordId: maintenanceRecordId,
                partId: partId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenancePartsUsedTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({maintenanceRecordId = false, partId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (maintenanceRecordId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.maintenanceRecordId,
                                    referencedTable:
                                        $$MaintenancePartsUsedTableReferences
                                            ._maintenanceRecordIdTable(db),
                                    referencedColumn:
                                        $$MaintenancePartsUsedTableReferences
                                            ._maintenanceRecordIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (partId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partId,
                                    referencedTable:
                                        $$MaintenancePartsUsedTableReferences
                                            ._partIdTable(db),
                                    referencedColumn:
                                        $$MaintenancePartsUsedTableReferences
                                            ._partIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MaintenancePartsUsedTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenancePartsUsedTable,
      MaintenancePartsUsedData,
      $$MaintenancePartsUsedTableFilterComposer,
      $$MaintenancePartsUsedTableOrderingComposer,
      $$MaintenancePartsUsedTableAnnotationComposer,
      $$MaintenancePartsUsedTableCreateCompanionBuilder,
      $$MaintenancePartsUsedTableUpdateCompanionBuilder,
      (MaintenancePartsUsedData, $$MaintenancePartsUsedTableReferences),
      MaintenancePartsUsedData,
      PrefetchHooks Function({bool maintenanceRecordId, bool partId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FarmersTableTableManager get farmers =>
      $$FarmersTableTableManager(_db, _db.farmers);
  $$FarmPlotsTableTableManager get farmPlots =>
      $$FarmPlotsTableTableManager(_db, _db.farmPlots);
  $$FarmBoundaryPointsTableTableManager get farmBoundaryPoints =>
      $$FarmBoundaryPointsTableTableManager(_db, _db.farmBoundaryPoints);
  $$ServiceRequestsTableTableManager get serviceRequests =>
      $$ServiceRequestsTableTableManager(_db, _db.serviceRequests);
  $$TractorsTableTableManager get tractors =>
      $$TractorsTableTableManager(_db, _db.tractors);
  $$OperatorsTableTableManager get operators =>
      $$OperatorsTableTableManager(_db, _db.operators);
  $$ManagerProfilesTableTableManager get managerProfiles =>
      $$ManagerProfilesTableTableManager(_db, _db.managerProfiles);
  $$DispatcherProfilesTableTableManager get dispatcherProfiles =>
      $$DispatcherProfilesTableTableManager(_db, _db.dispatcherProfiles);
  $$TechnicianProfilesTableTableManager get technicianProfiles =>
      $$TechnicianProfilesTableTableManager(_db, _db.technicianProfiles);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$JobTrackingPointsTableTableManager get jobTrackingPoints =>
      $$JobTrackingPointsTableTableManager(_db, _db.jobTrackingPoints);
  $$JobNotesTableTableManager get jobNotes =>
      $$JobNotesTableTableManager(_db, _db.jobNotes);
  $$DisputesTableTableManager get disputes =>
      $$DisputesTableTableManager(_db, _db.disputes);
  $$MaintenanceRecordsTableTableManager get maintenanceRecords =>
      $$MaintenanceRecordsTableTableManager(_db, _db.maintenanceRecords);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db, _db.parts);
  $$MaintenancePartsUsedTableTableManager get maintenancePartsUsed =>
      $$MaintenancePartsUsedTableTableManager(_db, _db.maintenancePartsUsed);
}
