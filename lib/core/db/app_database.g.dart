// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ActasLocalTable extends ActasLocal
    with TableInfo<$ActasLocalTable, ActasLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActasLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mesaIdMeta = const VerificationMeta('mesaId');
  @override
  late final GeneratedColumn<String> mesaId = GeneratedColumn<String>(
      'mesa_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dignidadMeta =
      const VerificationMeta('dignidad');
  @override
  late final GeneratedColumn<String> dignidad = GeneratedColumn<String>(
      'dignidad', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _votosJsonMeta =
      const VerificationMeta('votosJson');
  @override
  late final GeneratedColumn<String> votosJson = GeneratedColumn<String>(
      'votos_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _votosBlancosMeta =
      const VerificationMeta('votosBlancos');
  @override
  late final GeneratedColumn<int> votosBlancos = GeneratedColumn<int>(
      'votos_blancos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _votosNulosMeta =
      const VerificationMeta('votosNulos');
  @override
  late final GeneratedColumn<int> votosNulos = GeneratedColumn<int>(
      'votos_nulos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalSufragantesMeta =
      const VerificationMeta('totalSufragantes');
  @override
  late final GeneratedColumn<int> totalSufragantes = GeneratedColumn<int>(
      'total_sufragantes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fotoLocalPathMeta =
      const VerificationMeta('fotoLocalPath');
  @override
  late final GeneratedColumn<String> fotoLocalPath = GeneratedColumn<String>(
      'foto_local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fotoPathMeta =
      const VerificationMeta('fotoPath');
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
      'foto_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gpsLatMeta = const VerificationMeta('gpsLat');
  @override
  late final GeneratedColumn<double> gpsLat = GeneratedColumn<double>(
      'gps_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _gpsLngMeta = const VerificationMeta('gpsLng');
  @override
  late final GeneratedColumn<double> gpsLng = GeneratedColumn<double>(
      'gps_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('registrada'));
  static const VerificationMeta _registradoPorMeta =
      const VerificationMeta('registradoPor');
  @override
  late final GeneratedColumn<String> registradoPor = GeneratedColumn<String>(
      'registrado_por', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mesaId,
        dignidad,
        votosJson,
        votosBlancos,
        votosNulos,
        totalSufragantes,
        fotoLocalPath,
        fotoPath,
        gpsLat,
        gpsLng,
        status,
        registradoPor,
        updatedAt,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actas_local';
  @override
  VerificationContext validateIntegrity(Insertable<ActasLocalData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mesa_id')) {
      context.handle(_mesaIdMeta,
          mesaId.isAcceptableOrUnknown(data['mesa_id']!, _mesaIdMeta));
    } else if (isInserting) {
      context.missing(_mesaIdMeta);
    }
    if (data.containsKey('dignidad')) {
      context.handle(_dignidadMeta,
          dignidad.isAcceptableOrUnknown(data['dignidad']!, _dignidadMeta));
    } else if (isInserting) {
      context.missing(_dignidadMeta);
    }
    if (data.containsKey('votos_json')) {
      context.handle(_votosJsonMeta,
          votosJson.isAcceptableOrUnknown(data['votos_json']!, _votosJsonMeta));
    }
    if (data.containsKey('votos_blancos')) {
      context.handle(
          _votosBlancosMeta,
          votosBlancos.isAcceptableOrUnknown(
              data['votos_blancos']!, _votosBlancosMeta));
    }
    if (data.containsKey('votos_nulos')) {
      context.handle(
          _votosNulosMeta,
          votosNulos.isAcceptableOrUnknown(
              data['votos_nulos']!, _votosNulosMeta));
    }
    if (data.containsKey('total_sufragantes')) {
      context.handle(
          _totalSufragantesMeta,
          totalSufragantes.isAcceptableOrUnknown(
              data['total_sufragantes']!, _totalSufragantesMeta));
    }
    if (data.containsKey('foto_local_path')) {
      context.handle(
          _fotoLocalPathMeta,
          fotoLocalPath.isAcceptableOrUnknown(
              data['foto_local_path']!, _fotoLocalPathMeta));
    }
    if (data.containsKey('foto_path')) {
      context.handle(_fotoPathMeta,
          fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta));
    }
    if (data.containsKey('gps_lat')) {
      context.handle(_gpsLatMeta,
          gpsLat.isAcceptableOrUnknown(data['gps_lat']!, _gpsLatMeta));
    }
    if (data.containsKey('gps_lng')) {
      context.handle(_gpsLngMeta,
          gpsLng.isAcceptableOrUnknown(data['gps_lng']!, _gpsLngMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('registrado_por')) {
      context.handle(
          _registradoPorMeta,
          registradoPor.isAcceptableOrUnknown(
              data['registrado_por']!, _registradoPorMeta));
    } else if (isInserting) {
      context.missing(_registradoPorMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActasLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActasLocalData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mesaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mesa_id'])!,
      dignidad: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dignidad'])!,
      votosJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}votos_json'])!,
      votosBlancos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}votos_blancos'])!,
      votosNulos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}votos_nulos'])!,
      totalSufragantes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_sufragantes'])!,
      fotoLocalPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_local_path']),
      fotoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}foto_path']),
      gpsLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lat']),
      gpsLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_lng']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      registradoPor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}registrado_por'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $ActasLocalTable createAlias(String alias) {
    return $ActasLocalTable(attachedDatabase, alias);
  }
}

class ActasLocalData extends DataClass implements Insertable<ActasLocalData> {
  final String id;
  final String mesaId;
  final String dignidad;
  final String votosJson;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final String? fotoLocalPath;
  final String? fotoPath;
  final double? gpsLat;
  final double? gpsLng;
  final String status;
  final String registradoPor;
  final DateTime updatedAt;
  final bool synced;
  const ActasLocalData(
      {required this.id,
      required this.mesaId,
      required this.dignidad,
      required this.votosJson,
      required this.votosBlancos,
      required this.votosNulos,
      required this.totalSufragantes,
      this.fotoLocalPath,
      this.fotoPath,
      this.gpsLat,
      this.gpsLng,
      required this.status,
      required this.registradoPor,
      required this.updatedAt,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mesa_id'] = Variable<String>(mesaId);
    map['dignidad'] = Variable<String>(dignidad);
    map['votos_json'] = Variable<String>(votosJson);
    map['votos_blancos'] = Variable<int>(votosBlancos);
    map['votos_nulos'] = Variable<int>(votosNulos);
    map['total_sufragantes'] = Variable<int>(totalSufragantes);
    if (!nullToAbsent || fotoLocalPath != null) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath);
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    if (!nullToAbsent || gpsLat != null) {
      map['gps_lat'] = Variable<double>(gpsLat);
    }
    if (!nullToAbsent || gpsLng != null) {
      map['gps_lng'] = Variable<double>(gpsLng);
    }
    map['status'] = Variable<String>(status);
    map['registrado_por'] = Variable<String>(registradoPor);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ActasLocalCompanion toCompanion(bool nullToAbsent) {
    return ActasLocalCompanion(
      id: Value(id),
      mesaId: Value(mesaId),
      dignidad: Value(dignidad),
      votosJson: Value(votosJson),
      votosBlancos: Value(votosBlancos),
      votosNulos: Value(votosNulos),
      totalSufragantes: Value(totalSufragantes),
      fotoLocalPath: fotoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoLocalPath),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      gpsLat:
          gpsLat == null && nullToAbsent ? const Value.absent() : Value(gpsLat),
      gpsLng:
          gpsLng == null && nullToAbsent ? const Value.absent() : Value(gpsLng),
      status: Value(status),
      registradoPor: Value(registradoPor),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
    );
  }

  factory ActasLocalData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActasLocalData(
      id: serializer.fromJson<String>(json['id']),
      mesaId: serializer.fromJson<String>(json['mesaId']),
      dignidad: serializer.fromJson<String>(json['dignidad']),
      votosJson: serializer.fromJson<String>(json['votosJson']),
      votosBlancos: serializer.fromJson<int>(json['votosBlancos']),
      votosNulos: serializer.fromJson<int>(json['votosNulos']),
      totalSufragantes: serializer.fromJson<int>(json['totalSufragantes']),
      fotoLocalPath: serializer.fromJson<String?>(json['fotoLocalPath']),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      gpsLat: serializer.fromJson<double?>(json['gpsLat']),
      gpsLng: serializer.fromJson<double?>(json['gpsLng']),
      status: serializer.fromJson<String>(json['status']),
      registradoPor: serializer.fromJson<String>(json['registradoPor']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mesaId': serializer.toJson<String>(mesaId),
      'dignidad': serializer.toJson<String>(dignidad),
      'votosJson': serializer.toJson<String>(votosJson),
      'votosBlancos': serializer.toJson<int>(votosBlancos),
      'votosNulos': serializer.toJson<int>(votosNulos),
      'totalSufragantes': serializer.toJson<int>(totalSufragantes),
      'fotoLocalPath': serializer.toJson<String?>(fotoLocalPath),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'gpsLat': serializer.toJson<double?>(gpsLat),
      'gpsLng': serializer.toJson<double?>(gpsLng),
      'status': serializer.toJson<String>(status),
      'registradoPor': serializer.toJson<String>(registradoPor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ActasLocalData copyWith(
          {String? id,
          String? mesaId,
          String? dignidad,
          String? votosJson,
          int? votosBlancos,
          int? votosNulos,
          int? totalSufragantes,
          Value<String?> fotoLocalPath = const Value.absent(),
          Value<String?> fotoPath = const Value.absent(),
          Value<double?> gpsLat = const Value.absent(),
          Value<double?> gpsLng = const Value.absent(),
          String? status,
          String? registradoPor,
          DateTime? updatedAt,
          bool? synced}) =>
      ActasLocalData(
        id: id ?? this.id,
        mesaId: mesaId ?? this.mesaId,
        dignidad: dignidad ?? this.dignidad,
        votosJson: votosJson ?? this.votosJson,
        votosBlancos: votosBlancos ?? this.votosBlancos,
        votosNulos: votosNulos ?? this.votosNulos,
        totalSufragantes: totalSufragantes ?? this.totalSufragantes,
        fotoLocalPath:
            fotoLocalPath.present ? fotoLocalPath.value : this.fotoLocalPath,
        fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
        gpsLat: gpsLat.present ? gpsLat.value : this.gpsLat,
        gpsLng: gpsLng.present ? gpsLng.value : this.gpsLng,
        status: status ?? this.status,
        registradoPor: registradoPor ?? this.registradoPor,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
      );
  ActasLocalData copyWithCompanion(ActasLocalCompanion data) {
    return ActasLocalData(
      id: data.id.present ? data.id.value : this.id,
      mesaId: data.mesaId.present ? data.mesaId.value : this.mesaId,
      dignidad: data.dignidad.present ? data.dignidad.value : this.dignidad,
      votosJson: data.votosJson.present ? data.votosJson.value : this.votosJson,
      votosBlancos: data.votosBlancos.present
          ? data.votosBlancos.value
          : this.votosBlancos,
      votosNulos:
          data.votosNulos.present ? data.votosNulos.value : this.votosNulos,
      totalSufragantes: data.totalSufragantes.present
          ? data.totalSufragantes.value
          : this.totalSufragantes,
      fotoLocalPath: data.fotoLocalPath.present
          ? data.fotoLocalPath.value
          : this.fotoLocalPath,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      gpsLat: data.gpsLat.present ? data.gpsLat.value : this.gpsLat,
      gpsLng: data.gpsLng.present ? data.gpsLng.value : this.gpsLng,
      status: data.status.present ? data.status.value : this.status,
      registradoPor: data.registradoPor.present
          ? data.registradoPor.value
          : this.registradoPor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActasLocalData(')
          ..write('id: $id, ')
          ..write('mesaId: $mesaId, ')
          ..write('dignidad: $dignidad, ')
          ..write('votosJson: $votosJson, ')
          ..write('votosBlancos: $votosBlancos, ')
          ..write('votosNulos: $votosNulos, ')
          ..write('totalSufragantes: $totalSufragantes, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('status: $status, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      mesaId,
      dignidad,
      votosJson,
      votosBlancos,
      votosNulos,
      totalSufragantes,
      fotoLocalPath,
      fotoPath,
      gpsLat,
      gpsLng,
      status,
      registradoPor,
      updatedAt,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActasLocalData &&
          other.id == this.id &&
          other.mesaId == this.mesaId &&
          other.dignidad == this.dignidad &&
          other.votosJson == this.votosJson &&
          other.votosBlancos == this.votosBlancos &&
          other.votosNulos == this.votosNulos &&
          other.totalSufragantes == this.totalSufragantes &&
          other.fotoLocalPath == this.fotoLocalPath &&
          other.fotoPath == this.fotoPath &&
          other.gpsLat == this.gpsLat &&
          other.gpsLng == this.gpsLng &&
          other.status == this.status &&
          other.registradoPor == this.registradoPor &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced);
}

class ActasLocalCompanion extends UpdateCompanion<ActasLocalData> {
  final Value<String> id;
  final Value<String> mesaId;
  final Value<String> dignidad;
  final Value<String> votosJson;
  final Value<int> votosBlancos;
  final Value<int> votosNulos;
  final Value<int> totalSufragantes;
  final Value<String?> fotoLocalPath;
  final Value<String?> fotoPath;
  final Value<double?> gpsLat;
  final Value<double?> gpsLng;
  final Value<String> status;
  final Value<String> registradoPor;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<int> rowid;
  const ActasLocalCompanion({
    this.id = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.dignidad = const Value.absent(),
    this.votosJson = const Value.absent(),
    this.votosBlancos = const Value.absent(),
    this.votosNulos = const Value.absent(),
    this.totalSufragantes = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.status = const Value.absent(),
    this.registradoPor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActasLocalCompanion.insert({
    required String id,
    required String mesaId,
    required String dignidad,
    this.votosJson = const Value.absent(),
    this.votosBlancos = const Value.absent(),
    this.votosNulos = const Value.absent(),
    this.totalSufragantes = const Value.absent(),
    this.fotoLocalPath = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.gpsLat = const Value.absent(),
    this.gpsLng = const Value.absent(),
    this.status = const Value.absent(),
    required String registradoPor,
    required DateTime updatedAt,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mesaId = Value(mesaId),
        dignidad = Value(dignidad),
        registradoPor = Value(registradoPor),
        updatedAt = Value(updatedAt);
  static Insertable<ActasLocalData> custom({
    Expression<String>? id,
    Expression<String>? mesaId,
    Expression<String>? dignidad,
    Expression<String>? votosJson,
    Expression<int>? votosBlancos,
    Expression<int>? votosNulos,
    Expression<int>? totalSufragantes,
    Expression<String>? fotoLocalPath,
    Expression<String>? fotoPath,
    Expression<double>? gpsLat,
    Expression<double>? gpsLng,
    Expression<String>? status,
    Expression<String>? registradoPor,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mesaId != null) 'mesa_id': mesaId,
      if (dignidad != null) 'dignidad': dignidad,
      if (votosJson != null) 'votos_json': votosJson,
      if (votosBlancos != null) 'votos_blancos': votosBlancos,
      if (votosNulos != null) 'votos_nulos': votosNulos,
      if (totalSufragantes != null) 'total_sufragantes': totalSufragantes,
      if (fotoLocalPath != null) 'foto_local_path': fotoLocalPath,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (gpsLat != null) 'gps_lat': gpsLat,
      if (gpsLng != null) 'gps_lng': gpsLng,
      if (status != null) 'status': status,
      if (registradoPor != null) 'registrado_por': registradoPor,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActasLocalCompanion copyWith(
      {Value<String>? id,
      Value<String>? mesaId,
      Value<String>? dignidad,
      Value<String>? votosJson,
      Value<int>? votosBlancos,
      Value<int>? votosNulos,
      Value<int>? totalSufragantes,
      Value<String?>? fotoLocalPath,
      Value<String?>? fotoPath,
      Value<double?>? gpsLat,
      Value<double?>? gpsLng,
      Value<String>? status,
      Value<String>? registradoPor,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<int>? rowid}) {
    return ActasLocalCompanion(
      id: id ?? this.id,
      mesaId: mesaId ?? this.mesaId,
      dignidad: dignidad ?? this.dignidad,
      votosJson: votosJson ?? this.votosJson,
      votosBlancos: votosBlancos ?? this.votosBlancos,
      votosNulos: votosNulos ?? this.votosNulos,
      totalSufragantes: totalSufragantes ?? this.totalSufragantes,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      fotoPath: fotoPath ?? this.fotoPath,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      status: status ?? this.status,
      registradoPor: registradoPor ?? this.registradoPor,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mesaId.present) {
      map['mesa_id'] = Variable<String>(mesaId.value);
    }
    if (dignidad.present) {
      map['dignidad'] = Variable<String>(dignidad.value);
    }
    if (votosJson.present) {
      map['votos_json'] = Variable<String>(votosJson.value);
    }
    if (votosBlancos.present) {
      map['votos_blancos'] = Variable<int>(votosBlancos.value);
    }
    if (votosNulos.present) {
      map['votos_nulos'] = Variable<int>(votosNulos.value);
    }
    if (totalSufragantes.present) {
      map['total_sufragantes'] = Variable<int>(totalSufragantes.value);
    }
    if (fotoLocalPath.present) {
      map['foto_local_path'] = Variable<String>(fotoLocalPath.value);
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (gpsLat.present) {
      map['gps_lat'] = Variable<double>(gpsLat.value);
    }
    if (gpsLng.present) {
      map['gps_lng'] = Variable<double>(gpsLng.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (registradoPor.present) {
      map['registrado_por'] = Variable<String>(registradoPor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActasLocalCompanion(')
          ..write('id: $id, ')
          ..write('mesaId: $mesaId, ')
          ..write('dignidad: $dignidad, ')
          ..write('votosJson: $votosJson, ')
          ..write('votosBlancos: $votosBlancos, ')
          ..write('votosNulos: $votosNulos, ')
          ..write('totalSufragantes: $totalSufragantes, ')
          ..write('fotoLocalPath: $fotoLocalPath, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('gpsLat: $gpsLat, ')
          ..write('gpsLng: $gpsLng, ')
          ..write('status: $status, ')
          ..write('registradoPor: $registradoPor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entity,
        operation,
        entityId,
        payloadJson,
        createdAt,
        attempts,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int id;
  final String entity;
  final String operation;
  final String entityId;
  final String payloadJson;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const OutboxData(
      {required this.id,
      required this.entity,
      required this.operation,
      required this.entityId,
      required this.payloadJson,
      required this.createdAt,
      required this.attempts,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['operation'] = Variable<String>(operation);
    map['entity_id'] = Variable<String>(entityId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      entity: Value(entity),
      operation: Value(operation),
      entityId: Value(entityId),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      operation: serializer.fromJson<String>(json['operation']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'operation': serializer.toJson<String>(operation),
      'entityId': serializer.toJson<String>(entityId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxData copyWith(
          {int? id,
          String? entity,
          String? operation,
          String? entityId,
          String? payloadJson,
          DateTime? createdAt,
          int? attempts,
          Value<String?> lastError = const Value.absent()}) =>
      OutboxData(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        operation: operation ?? this.operation,
        entityId: entityId ?? this.entityId,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      operation: data.operation.present ? data.operation.value : this.operation,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('operation: $operation, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entity, operation, entityId, payloadJson,
      createdAt, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.operation == this.operation &&
          other.entityId == this.entityId &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> operation;
  final Value<String> entityId;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.operation = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String operation,
    required String entityId,
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : entity = Value(entity),
        operation = Value(operation),
        entityId = Value(entityId),
        payloadJson = Value(payloadJson);
  static Insertable<OutboxData> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? operation,
    Expression<String>? entityId,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (operation != null) 'operation': operation,
      if (entityId != null) 'entity_id': entityId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? entity,
      Value<String>? operation,
      Value<String>? entityId,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? attempts,
      Value<String?>? lastError}) {
    return OutboxCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      operation: operation ?? this.operation,
      entityId: entityId ?? this.entityId,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('operation: $operation, ')
          ..write('entityId: $entityId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ActasLocalTable actasLocal = $ActasLocalTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [actasLocal, outbox];
}

typedef $$ActasLocalTableCreateCompanionBuilder = ActasLocalCompanion Function({
  required String id,
  required String mesaId,
  required String dignidad,
  Value<String> votosJson,
  Value<int> votosBlancos,
  Value<int> votosNulos,
  Value<int> totalSufragantes,
  Value<String?> fotoLocalPath,
  Value<String?> fotoPath,
  Value<double?> gpsLat,
  Value<double?> gpsLng,
  Value<String> status,
  required String registradoPor,
  required DateTime updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});
typedef $$ActasLocalTableUpdateCompanionBuilder = ActasLocalCompanion Function({
  Value<String> id,
  Value<String> mesaId,
  Value<String> dignidad,
  Value<String> votosJson,
  Value<int> votosBlancos,
  Value<int> votosNulos,
  Value<int> totalSufragantes,
  Value<String?> fotoLocalPath,
  Value<String?> fotoPath,
  Value<double?> gpsLat,
  Value<double?> gpsLng,
  Value<String> status,
  Value<String> registradoPor,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<int> rowid,
});

class $$ActasLocalTableFilterComposer
    extends Composer<_$AppDatabase, $ActasLocalTable> {
  $$ActasLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mesaId => $composableBuilder(
      column: $table.mesaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dignidad => $composableBuilder(
      column: $table.dignidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get votosJson => $composableBuilder(
      column: $table.votosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get votosBlancos => $composableBuilder(
      column: $table.votosBlancos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get votosNulos => $composableBuilder(
      column: $table.votosNulos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSufragantes => $composableBuilder(
      column: $table.totalSufragantes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fotoLocalPath => $composableBuilder(
      column: $table.fotoLocalPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registradoPor => $composableBuilder(
      column: $table.registradoPor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$ActasLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $ActasLocalTable> {
  $$ActasLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mesaId => $composableBuilder(
      column: $table.mesaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dignidad => $composableBuilder(
      column: $table.dignidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get votosJson => $composableBuilder(
      column: $table.votosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get votosBlancos => $composableBuilder(
      column: $table.votosBlancos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get votosNulos => $composableBuilder(
      column: $table.votosNulos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSufragantes => $composableBuilder(
      column: $table.totalSufragantes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fotoLocalPath => $composableBuilder(
      column: $table.fotoLocalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fotoPath => $composableBuilder(
      column: $table.fotoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLat => $composableBuilder(
      column: $table.gpsLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsLng => $composableBuilder(
      column: $table.gpsLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registradoPor => $composableBuilder(
      column: $table.registradoPor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$ActasLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActasLocalTable> {
  $$ActasLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mesaId =>
      $composableBuilder(column: $table.mesaId, builder: (column) => column);

  GeneratedColumn<String> get dignidad =>
      $composableBuilder(column: $table.dignidad, builder: (column) => column);

  GeneratedColumn<String> get votosJson =>
      $composableBuilder(column: $table.votosJson, builder: (column) => column);

  GeneratedColumn<int> get votosBlancos => $composableBuilder(
      column: $table.votosBlancos, builder: (column) => column);

  GeneratedColumn<int> get votosNulos => $composableBuilder(
      column: $table.votosNulos, builder: (column) => column);

  GeneratedColumn<int> get totalSufragantes => $composableBuilder(
      column: $table.totalSufragantes, builder: (column) => column);

  GeneratedColumn<String> get fotoLocalPath => $composableBuilder(
      column: $table.fotoLocalPath, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<double> get gpsLat =>
      $composableBuilder(column: $table.gpsLat, builder: (column) => column);

  GeneratedColumn<double> get gpsLng =>
      $composableBuilder(column: $table.gpsLng, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get registradoPor => $composableBuilder(
      column: $table.registradoPor, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ActasLocalTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActasLocalTable,
    ActasLocalData,
    $$ActasLocalTableFilterComposer,
    $$ActasLocalTableOrderingComposer,
    $$ActasLocalTableAnnotationComposer,
    $$ActasLocalTableCreateCompanionBuilder,
    $$ActasLocalTableUpdateCompanionBuilder,
    (
      ActasLocalData,
      BaseReferences<_$AppDatabase, $ActasLocalTable, ActasLocalData>
    ),
    ActasLocalData,
    PrefetchHooks Function()> {
  $$ActasLocalTableTableManager(_$AppDatabase db, $ActasLocalTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActasLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActasLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActasLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mesaId = const Value.absent(),
            Value<String> dignidad = const Value.absent(),
            Value<String> votosJson = const Value.absent(),
            Value<int> votosBlancos = const Value.absent(),
            Value<int> votosNulos = const Value.absent(),
            Value<int> totalSufragantes = const Value.absent(),
            Value<String?> fotoLocalPath = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<double?> gpsLat = const Value.absent(),
            Value<double?> gpsLng = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> registradoPor = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActasLocalCompanion(
            id: id,
            mesaId: mesaId,
            dignidad: dignidad,
            votosJson: votosJson,
            votosBlancos: votosBlancos,
            votosNulos: votosNulos,
            totalSufragantes: totalSufragantes,
            fotoLocalPath: fotoLocalPath,
            fotoPath: fotoPath,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            status: status,
            registradoPor: registradoPor,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mesaId,
            required String dignidad,
            Value<String> votosJson = const Value.absent(),
            Value<int> votosBlancos = const Value.absent(),
            Value<int> votosNulos = const Value.absent(),
            Value<int> totalSufragantes = const Value.absent(),
            Value<String?> fotoLocalPath = const Value.absent(),
            Value<String?> fotoPath = const Value.absent(),
            Value<double?> gpsLat = const Value.absent(),
            Value<double?> gpsLng = const Value.absent(),
            Value<String> status = const Value.absent(),
            required String registradoPor,
            required DateTime updatedAt,
            Value<bool> synced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActasLocalCompanion.insert(
            id: id,
            mesaId: mesaId,
            dignidad: dignidad,
            votosJson: votosJson,
            votosBlancos: votosBlancos,
            votosNulos: votosNulos,
            totalSufragantes: totalSufragantes,
            fotoLocalPath: fotoLocalPath,
            fotoPath: fotoPath,
            gpsLat: gpsLat,
            gpsLng: gpsLng,
            status: status,
            registradoPor: registradoPor,
            updatedAt: updatedAt,
            synced: synced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActasLocalTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActasLocalTable,
    ActasLocalData,
    $$ActasLocalTableFilterComposer,
    $$ActasLocalTableOrderingComposer,
    $$ActasLocalTableAnnotationComposer,
    $$ActasLocalTableCreateCompanionBuilder,
    $$ActasLocalTableUpdateCompanionBuilder,
    (
      ActasLocalData,
      BaseReferences<_$AppDatabase, $ActasLocalTable, ActasLocalData>
    ),
    ActasLocalData,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String entity,
  required String operation,
  required String entityId,
  required String payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> entity,
  Value<String> operation,
  Value<String> entityId,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            entity: entity,
            operation: operation,
            entityId: entityId,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attempts: attempts,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entity,
            required String operation,
            required String entityId,
            required String payloadJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            entity: entity,
            operation: operation,
            entityId: entityId,
            payloadJson: payloadJson,
            createdAt: createdAt,
            attempts: attempts,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ActasLocalTableTableManager get actasLocal =>
      $$ActasLocalTableTableManager(_db, _db.actasLocal);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
}
