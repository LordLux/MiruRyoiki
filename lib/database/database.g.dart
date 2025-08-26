// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SeriesTableTable extends SeriesTable
    with TableInfo<$SeriesTableTable, SeriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PathString, String> path =
      GeneratedColumn<String>('path', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PathString>($SeriesTableTable.$converterpath);
  @override
  late final GeneratedColumnWithTypeConverter<PathString?, String>
      folderPosterPath = GeneratedColumn<String>(
              'folder_poster_path', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PathString?>(
              $SeriesTableTable.$converterfolderPosterPathn);
  @override
  late final GeneratedColumnWithTypeConverter<PathString?, String>
      folderBannerPath = GeneratedColumn<String>(
              'folder_banner_path', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PathString?>(
              $SeriesTableTable.$converterfolderBannerPathn);
  static const VerificationMeta _primaryAnilistIdMeta =
      const VerificationMeta('primaryAnilistId');
  @override
  late final GeneratedColumn<int> primaryAnilistId = GeneratedColumn<int>(
      'primary_anilist_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isHiddenMeta =
      const VerificationMeta('isHidden');
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
      'is_hidden', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_hidden" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _customListNameMeta =
      const VerificationMeta('customListName');
  @override
  late final GeneratedColumn<String> customListName = GeneratedColumn<String>(
      'custom_list_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dominantColorMeta =
      const VerificationMeta('dominantColor');
  @override
  late final GeneratedColumn<String> dominantColor = GeneratedColumn<String>(
      'dominant_color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preferredPosterSourceMeta =
      const VerificationMeta('preferredPosterSource');
  @override
  late final GeneratedColumn<String> preferredPosterSource =
      GeneratedColumn<String>('preferred_poster_source', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preferredBannerSourceMeta =
      const VerificationMeta('preferredBannerSource');
  @override
  late final GeneratedColumn<String> preferredBannerSource =
      GeneratedColumn<String>('preferred_banner_source', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anilistPosterUrlMeta =
      const VerificationMeta('anilistPosterUrl');
  @override
  late final GeneratedColumn<String> anilistPosterUrl = GeneratedColumn<String>(
      'anilist_poster_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anilistBannerUrlMeta =
      const VerificationMeta('anilistBannerUrl');
  @override
  late final GeneratedColumn<String> anilistBannerUrl = GeneratedColumn<String>(
      'anilist_banner_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _watchedPercentageMeta =
      const VerificationMeta('watchedPercentage');
  @override
  late final GeneratedColumn<double> watchedPercentage =
      GeneratedColumn<double>('watched_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
      'added_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        path,
        folderPosterPath,
        folderBannerPath,
        primaryAnilistId,
        isHidden,
        customListName,
        dominantColor,
        preferredPosterSource,
        preferredBannerSource,
        anilistPosterUrl,
        anilistBannerUrl,
        watchedPercentage,
        addedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_table';
  @override
  VerificationContext validateIntegrity(Insertable<SeriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('primary_anilist_id')) {
      context.handle(
          _primaryAnilistIdMeta,
          primaryAnilistId.isAcceptableOrUnknown(
              data['primary_anilist_id']!, _primaryAnilistIdMeta));
    }
    if (data.containsKey('is_hidden')) {
      context.handle(_isHiddenMeta,
          isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta));
    }
    if (data.containsKey('custom_list_name')) {
      context.handle(
          _customListNameMeta,
          customListName.isAcceptableOrUnknown(
              data['custom_list_name']!, _customListNameMeta));
    }
    if (data.containsKey('dominant_color')) {
      context.handle(
          _dominantColorMeta,
          dominantColor.isAcceptableOrUnknown(
              data['dominant_color']!, _dominantColorMeta));
    }
    if (data.containsKey('preferred_poster_source')) {
      context.handle(
          _preferredPosterSourceMeta,
          preferredPosterSource.isAcceptableOrUnknown(
              data['preferred_poster_source']!, _preferredPosterSourceMeta));
    }
    if (data.containsKey('preferred_banner_source')) {
      context.handle(
          _preferredBannerSourceMeta,
          preferredBannerSource.isAcceptableOrUnknown(
              data['preferred_banner_source']!, _preferredBannerSourceMeta));
    }
    if (data.containsKey('anilist_poster_url')) {
      context.handle(
          _anilistPosterUrlMeta,
          anilistPosterUrl.isAcceptableOrUnknown(
              data['anilist_poster_url']!, _anilistPosterUrlMeta));
    }
    if (data.containsKey('anilist_banner_url')) {
      context.handle(
          _anilistBannerUrlMeta,
          anilistBannerUrl.isAcceptableOrUnknown(
              data['anilist_banner_url']!, _anilistBannerUrlMeta));
    }
    if (data.containsKey('watched_percentage')) {
      context.handle(
          _watchedPercentageMeta,
          watchedPercentage.isAcceptableOrUnknown(
              data['watched_percentage']!, _watchedPercentageMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      path: $SeriesTableTable.$converterpath.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!),
      folderPosterPath: $SeriesTableTable.$converterfolderPosterPathn.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}folder_poster_path'])),
      folderBannerPath: $SeriesTableTable.$converterfolderBannerPathn.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}folder_banner_path'])),
      primaryAnilistId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}primary_anilist_id']),
      isHidden: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_hidden'])!,
      customListName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}custom_list_name']),
      dominantColor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dominant_color']),
      preferredPosterSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_poster_source']),
      preferredBannerSource: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_banner_source']),
      anilistPosterUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}anilist_poster_url']),
      anilistBannerUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}anilist_banner_url']),
      watchedPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}watched_percentage'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}added_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SeriesTableTable createAlias(String alias) {
    return $SeriesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<PathString, String> $converterpath =
      const PathStringConverter();
  static TypeConverter<PathString, String> $converterfolderPosterPath =
      const PathStringConverter();
  static TypeConverter<PathString?, String?> $converterfolderPosterPathn =
      NullAwareTypeConverter.wrap($converterfolderPosterPath);
  static TypeConverter<PathString, String> $converterfolderBannerPath =
      const PathStringConverter();
  static TypeConverter<PathString?, String?> $converterfolderBannerPathn =
      NullAwareTypeConverter.wrap($converterfolderBannerPath);
}

class SeriesTableData extends DataClass implements Insertable<SeriesTableData> {
  final int id;
  final String name;
  final PathString path;
  final PathString? folderPosterPath;
  final PathString? folderBannerPath;
  final int? primaryAnilistId;
  final bool isHidden;

  /// Custom list name for unlinked series
  final String? customListName;
  final String? dominantColor;
  final String? preferredPosterSource;
  final String? preferredBannerSource;
  final String? anilistPosterUrl;
  final String? anilistBannerUrl;
  final double watchedPercentage;
  final DateTime addedAt;
  final DateTime updatedAt;
  const SeriesTableData(
      {required this.id,
      required this.name,
      required this.path,
      this.folderPosterPath,
      this.folderBannerPath,
      this.primaryAnilistId,
      required this.isHidden,
      this.customListName,
      this.dominantColor,
      this.preferredPosterSource,
      this.preferredBannerSource,
      this.anilistPosterUrl,
      this.anilistBannerUrl,
      required this.watchedPercentage,
      required this.addedAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['path'] =
          Variable<String>($SeriesTableTable.$converterpath.toSql(path));
    }
    if (!nullToAbsent || folderPosterPath != null) {
      map['folder_poster_path'] = Variable<String>($SeriesTableTable
          .$converterfolderPosterPathn
          .toSql(folderPosterPath));
    }
    if (!nullToAbsent || folderBannerPath != null) {
      map['folder_banner_path'] = Variable<String>($SeriesTableTable
          .$converterfolderBannerPathn
          .toSql(folderBannerPath));
    }
    if (!nullToAbsent || primaryAnilistId != null) {
      map['primary_anilist_id'] = Variable<int>(primaryAnilistId);
    }
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || customListName != null) {
      map['custom_list_name'] = Variable<String>(customListName);
    }
    if (!nullToAbsent || dominantColor != null) {
      map['dominant_color'] = Variable<String>(dominantColor);
    }
    if (!nullToAbsent || preferredPosterSource != null) {
      map['preferred_poster_source'] = Variable<String>(preferredPosterSource);
    }
    if (!nullToAbsent || preferredBannerSource != null) {
      map['preferred_banner_source'] = Variable<String>(preferredBannerSource);
    }
    if (!nullToAbsent || anilistPosterUrl != null) {
      map['anilist_poster_url'] = Variable<String>(anilistPosterUrl);
    }
    if (!nullToAbsent || anilistBannerUrl != null) {
      map['anilist_banner_url'] = Variable<String>(anilistBannerUrl);
    }
    map['watched_percentage'] = Variable<double>(watchedPercentage);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SeriesTableCompanion toCompanion(bool nullToAbsent) {
    return SeriesTableCompanion(
      id: Value(id),
      name: Value(name),
      path: Value(path),
      folderPosterPath: folderPosterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(folderPosterPath),
      folderBannerPath: folderBannerPath == null && nullToAbsent
          ? const Value.absent()
          : Value(folderBannerPath),
      primaryAnilistId: primaryAnilistId == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryAnilistId),
      isHidden: Value(isHidden),
      customListName: customListName == null && nullToAbsent
          ? const Value.absent()
          : Value(customListName),
      dominantColor: dominantColor == null && nullToAbsent
          ? const Value.absent()
          : Value(dominantColor),
      preferredPosterSource: preferredPosterSource == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredPosterSource),
      preferredBannerSource: preferredBannerSource == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredBannerSource),
      anilistPosterUrl: anilistPosterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(anilistPosterUrl),
      anilistBannerUrl: anilistBannerUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(anilistBannerUrl),
      watchedPercentage: Value(watchedPercentage),
      addedAt: Value(addedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SeriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<PathString>(json['path']),
      folderPosterPath:
          serializer.fromJson<PathString?>(json['folderPosterPath']),
      folderBannerPath:
          serializer.fromJson<PathString?>(json['folderBannerPath']),
      primaryAnilistId: serializer.fromJson<int?>(json['primaryAnilistId']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      customListName: serializer.fromJson<String?>(json['customListName']),
      dominantColor: serializer.fromJson<String?>(json['dominantColor']),
      preferredPosterSource:
          serializer.fromJson<String?>(json['preferredPosterSource']),
      preferredBannerSource:
          serializer.fromJson<String?>(json['preferredBannerSource']),
      anilistPosterUrl: serializer.fromJson<String?>(json['anilistPosterUrl']),
      anilistBannerUrl: serializer.fromJson<String?>(json['anilistBannerUrl']),
      watchedPercentage: serializer.fromJson<double>(json['watchedPercentage']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<PathString>(path),
      'folderPosterPath': serializer.toJson<PathString?>(folderPosterPath),
      'folderBannerPath': serializer.toJson<PathString?>(folderBannerPath),
      'primaryAnilistId': serializer.toJson<int?>(primaryAnilistId),
      'isHidden': serializer.toJson<bool>(isHidden),
      'customListName': serializer.toJson<String?>(customListName),
      'dominantColor': serializer.toJson<String?>(dominantColor),
      'preferredPosterSource':
          serializer.toJson<String?>(preferredPosterSource),
      'preferredBannerSource':
          serializer.toJson<String?>(preferredBannerSource),
      'anilistPosterUrl': serializer.toJson<String?>(anilistPosterUrl),
      'anilistBannerUrl': serializer.toJson<String?>(anilistBannerUrl),
      'watchedPercentage': serializer.toJson<double>(watchedPercentage),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SeriesTableData copyWith(
          {int? id,
          String? name,
          PathString? path,
          Value<PathString?> folderPosterPath = const Value.absent(),
          Value<PathString?> folderBannerPath = const Value.absent(),
          Value<int?> primaryAnilistId = const Value.absent(),
          bool? isHidden,
          Value<String?> customListName = const Value.absent(),
          Value<String?> dominantColor = const Value.absent(),
          Value<String?> preferredPosterSource = const Value.absent(),
          Value<String?> preferredBannerSource = const Value.absent(),
          Value<String?> anilistPosterUrl = const Value.absent(),
          Value<String?> anilistBannerUrl = const Value.absent(),
          double? watchedPercentage,
          DateTime? addedAt,
          DateTime? updatedAt}) =>
      SeriesTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        path: path ?? this.path,
        folderPosterPath: folderPosterPath.present
            ? folderPosterPath.value
            : this.folderPosterPath,
        folderBannerPath: folderBannerPath.present
            ? folderBannerPath.value
            : this.folderBannerPath,
        primaryAnilistId: primaryAnilistId.present
            ? primaryAnilistId.value
            : this.primaryAnilistId,
        isHidden: isHidden ?? this.isHidden,
        customListName:
            customListName.present ? customListName.value : this.customListName,
        dominantColor:
            dominantColor.present ? dominantColor.value : this.dominantColor,
        preferredPosterSource: preferredPosterSource.present
            ? preferredPosterSource.value
            : this.preferredPosterSource,
        preferredBannerSource: preferredBannerSource.present
            ? preferredBannerSource.value
            : this.preferredBannerSource,
        anilistPosterUrl: anilistPosterUrl.present
            ? anilistPosterUrl.value
            : this.anilistPosterUrl,
        anilistBannerUrl: anilistBannerUrl.present
            ? anilistBannerUrl.value
            : this.anilistBannerUrl,
        watchedPercentage: watchedPercentage ?? this.watchedPercentage,
        addedAt: addedAt ?? this.addedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SeriesTableData copyWithCompanion(SeriesTableCompanion data) {
    return SeriesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      folderPosterPath: data.folderPosterPath.present
          ? data.folderPosterPath.value
          : this.folderPosterPath,
      folderBannerPath: data.folderBannerPath.present
          ? data.folderBannerPath.value
          : this.folderBannerPath,
      primaryAnilistId: data.primaryAnilistId.present
          ? data.primaryAnilistId.value
          : this.primaryAnilistId,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      customListName: data.customListName.present
          ? data.customListName.value
          : this.customListName,
      dominantColor: data.dominantColor.present
          ? data.dominantColor.value
          : this.dominantColor,
      preferredPosterSource: data.preferredPosterSource.present
          ? data.preferredPosterSource.value
          : this.preferredPosterSource,
      preferredBannerSource: data.preferredBannerSource.present
          ? data.preferredBannerSource.value
          : this.preferredBannerSource,
      anilistPosterUrl: data.anilistPosterUrl.present
          ? data.anilistPosterUrl.value
          : this.anilistPosterUrl,
      anilistBannerUrl: data.anilistBannerUrl.present
          ? data.anilistBannerUrl.value
          : this.anilistBannerUrl,
      watchedPercentage: data.watchedPercentage.present
          ? data.watchedPercentage.value
          : this.watchedPercentage,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('folderPosterPath: $folderPosterPath, ')
          ..write('folderBannerPath: $folderBannerPath, ')
          ..write('primaryAnilistId: $primaryAnilistId, ')
          ..write('isHidden: $isHidden, ')
          ..write('customListName: $customListName, ')
          ..write('dominantColor: $dominantColor, ')
          ..write('preferredPosterSource: $preferredPosterSource, ')
          ..write('preferredBannerSource: $preferredBannerSource, ')
          ..write('anilistPosterUrl: $anilistPosterUrl, ')
          ..write('anilistBannerUrl: $anilistBannerUrl, ')
          ..write('watchedPercentage: $watchedPercentage, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      path,
      folderPosterPath,
      folderBannerPath,
      primaryAnilistId,
      isHidden,
      customListName,
      dominantColor,
      preferredPosterSource,
      preferredBannerSource,
      anilistPosterUrl,
      anilistBannerUrl,
      watchedPercentage,
      addedAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.path == this.path &&
          other.folderPosterPath == this.folderPosterPath &&
          other.folderBannerPath == this.folderBannerPath &&
          other.primaryAnilistId == this.primaryAnilistId &&
          other.isHidden == this.isHidden &&
          other.customListName == this.customListName &&
          other.dominantColor == this.dominantColor &&
          other.preferredPosterSource == this.preferredPosterSource &&
          other.preferredBannerSource == this.preferredBannerSource &&
          other.anilistPosterUrl == this.anilistPosterUrl &&
          other.anilistBannerUrl == this.anilistBannerUrl &&
          other.watchedPercentage == this.watchedPercentage &&
          other.addedAt == this.addedAt &&
          other.updatedAt == this.updatedAt);
}

class SeriesTableCompanion extends UpdateCompanion<SeriesTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<PathString> path;
  final Value<PathString?> folderPosterPath;
  final Value<PathString?> folderBannerPath;
  final Value<int?> primaryAnilistId;
  final Value<bool> isHidden;
  final Value<String?> customListName;
  final Value<String?> dominantColor;
  final Value<String?> preferredPosterSource;
  final Value<String?> preferredBannerSource;
  final Value<String?> anilistPosterUrl;
  final Value<String?> anilistBannerUrl;
  final Value<double> watchedPercentage;
  final Value<DateTime> addedAt;
  final Value<DateTime> updatedAt;
  const SeriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.folderPosterPath = const Value.absent(),
    this.folderBannerPath = const Value.absent(),
    this.primaryAnilistId = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.customListName = const Value.absent(),
    this.dominantColor = const Value.absent(),
    this.preferredPosterSource = const Value.absent(),
    this.preferredBannerSource = const Value.absent(),
    this.anilistPosterUrl = const Value.absent(),
    this.anilistBannerUrl = const Value.absent(),
    this.watchedPercentage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SeriesTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required PathString path,
    this.folderPosterPath = const Value.absent(),
    this.folderBannerPath = const Value.absent(),
    this.primaryAnilistId = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.customListName = const Value.absent(),
    this.dominantColor = const Value.absent(),
    this.preferredPosterSource = const Value.absent(),
    this.preferredBannerSource = const Value.absent(),
    this.anilistPosterUrl = const Value.absent(),
    this.anilistBannerUrl = const Value.absent(),
    this.watchedPercentage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        path = Value(path);
  static Insertable<SeriesTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? folderPosterPath,
    Expression<String>? folderBannerPath,
    Expression<int>? primaryAnilistId,
    Expression<bool>? isHidden,
    Expression<String>? customListName,
    Expression<String>? dominantColor,
    Expression<String>? preferredPosterSource,
    Expression<String>? preferredBannerSource,
    Expression<String>? anilistPosterUrl,
    Expression<String>? anilistBannerUrl,
    Expression<double>? watchedPercentage,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (folderPosterPath != null) 'folder_poster_path': folderPosterPath,
      if (folderBannerPath != null) 'folder_banner_path': folderBannerPath,
      if (primaryAnilistId != null) 'primary_anilist_id': primaryAnilistId,
      if (isHidden != null) 'is_hidden': isHidden,
      if (customListName != null) 'custom_list_name': customListName,
      if (dominantColor != null) 'dominant_color': dominantColor,
      if (preferredPosterSource != null)
        'preferred_poster_source': preferredPosterSource,
      if (preferredBannerSource != null)
        'preferred_banner_source': preferredBannerSource,
      if (anilistPosterUrl != null) 'anilist_poster_url': anilistPosterUrl,
      if (anilistBannerUrl != null) 'anilist_banner_url': anilistBannerUrl,
      if (watchedPercentage != null) 'watched_percentage': watchedPercentage,
      if (addedAt != null) 'added_at': addedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SeriesTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<PathString>? path,
      Value<PathString?>? folderPosterPath,
      Value<PathString?>? folderBannerPath,
      Value<int?>? primaryAnilistId,
      Value<bool>? isHidden,
      Value<String?>? customListName,
      Value<String?>? dominantColor,
      Value<String?>? preferredPosterSource,
      Value<String?>? preferredBannerSource,
      Value<String?>? anilistPosterUrl,
      Value<String?>? anilistBannerUrl,
      Value<double>? watchedPercentage,
      Value<DateTime>? addedAt,
      Value<DateTime>? updatedAt}) {
    return SeriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      folderPosterPath: folderPosterPath ?? this.folderPosterPath,
      folderBannerPath: folderBannerPath ?? this.folderBannerPath,
      primaryAnilistId: primaryAnilistId ?? this.primaryAnilistId,
      isHidden: isHidden ?? this.isHidden,
      customListName: customListName ?? this.customListName,
      dominantColor: dominantColor ?? this.dominantColor,
      preferredPosterSource:
          preferredPosterSource ?? this.preferredPosterSource,
      preferredBannerSource:
          preferredBannerSource ?? this.preferredBannerSource,
      anilistPosterUrl: anilistPosterUrl ?? this.anilistPosterUrl,
      anilistBannerUrl: anilistBannerUrl ?? this.anilistBannerUrl,
      watchedPercentage: watchedPercentage ?? this.watchedPercentage,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] =
          Variable<String>($SeriesTableTable.$converterpath.toSql(path.value));
    }
    if (folderPosterPath.present) {
      map['folder_poster_path'] = Variable<String>($SeriesTableTable
          .$converterfolderPosterPathn
          .toSql(folderPosterPath.value));
    }
    if (folderBannerPath.present) {
      map['folder_banner_path'] = Variable<String>($SeriesTableTable
          .$converterfolderBannerPathn
          .toSql(folderBannerPath.value));
    }
    if (primaryAnilistId.present) {
      map['primary_anilist_id'] = Variable<int>(primaryAnilistId.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (customListName.present) {
      map['custom_list_name'] = Variable<String>(customListName.value);
    }
    if (dominantColor.present) {
      map['dominant_color'] = Variable<String>(dominantColor.value);
    }
    if (preferredPosterSource.present) {
      map['preferred_poster_source'] =
          Variable<String>(preferredPosterSource.value);
    }
    if (preferredBannerSource.present) {
      map['preferred_banner_source'] =
          Variable<String>(preferredBannerSource.value);
    }
    if (anilistPosterUrl.present) {
      map['anilist_poster_url'] = Variable<String>(anilistPosterUrl.value);
    }
    if (anilistBannerUrl.present) {
      map['anilist_banner_url'] = Variable<String>(anilistBannerUrl.value);
    }
    if (watchedPercentage.present) {
      map['watched_percentage'] = Variable<double>(watchedPercentage.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('folderPosterPath: $folderPosterPath, ')
          ..write('folderBannerPath: $folderBannerPath, ')
          ..write('primaryAnilistId: $primaryAnilistId, ')
          ..write('isHidden: $isHidden, ')
          ..write('customListName: $customListName, ')
          ..write('dominantColor: $dominantColor, ')
          ..write('preferredPosterSource: $preferredPosterSource, ')
          ..write('preferredBannerSource: $preferredBannerSource, ')
          ..write('anilistPosterUrl: $anilistPosterUrl, ')
          ..write('anilistBannerUrl: $anilistBannerUrl, ')
          ..write('watchedPercentage: $watchedPercentage, ')
          ..write('addedAt: $addedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SeasonsTableTable extends SeasonsTable
    with TableInfo<$SeasonsTableTable, SeasonsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeasonsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _seriesIdMeta =
      const VerificationMeta('seriesId');
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
      'series_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES series_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PathString, String> path =
      GeneratedColumn<String>('path', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PathString>($SeasonsTableTable.$converterpath);
  @override
  List<GeneratedColumn> get $columns => [id, seriesId, name, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seasons_table';
  @override
  VerificationContext validateIntegrity(Insertable<SeasonsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(_seriesIdMeta,
          seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta));
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeasonsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeasonsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seriesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}series_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      path: $SeasonsTableTable.$converterpath.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!),
    );
  }

  @override
  $SeasonsTableTable createAlias(String alias) {
    return $SeasonsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<PathString, String> $converterpath =
      const PathStringConverter();
}

class SeasonsTableData extends DataClass
    implements Insertable<SeasonsTableData> {
  final int id;
  final int seriesId;
  final String name;
  final PathString path;
  const SeasonsTableData(
      {required this.id,
      required this.seriesId,
      required this.name,
      required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['series_id'] = Variable<int>(seriesId);
    map['name'] = Variable<String>(name);
    {
      map['path'] =
          Variable<String>($SeasonsTableTable.$converterpath.toSql(path));
    }
    return map;
  }

  SeasonsTableCompanion toCompanion(bool nullToAbsent) {
    return SeasonsTableCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      name: Value(name),
      path: Value(path),
    );
  }

  factory SeasonsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeasonsTableData(
      id: serializer.fromJson<int>(json['id']),
      seriesId: serializer.fromJson<int>(json['seriesId']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<PathString>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seriesId': serializer.toJson<int>(seriesId),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<PathString>(path),
    };
  }

  SeasonsTableData copyWith(
          {int? id, int? seriesId, String? name, PathString? path}) =>
      SeasonsTableData(
        id: id ?? this.id,
        seriesId: seriesId ?? this.seriesId,
        name: name ?? this.name,
        path: path ?? this.path,
      );
  SeasonsTableData copyWithCompanion(SeasonsTableCompanion data) {
    return SeasonsTableData(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeasonsTableData(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('name: $name, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seriesId, name, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeasonsTableData &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.name == this.name &&
          other.path == this.path);
}

class SeasonsTableCompanion extends UpdateCompanion<SeasonsTableData> {
  final Value<int> id;
  final Value<int> seriesId;
  final Value<String> name;
  final Value<PathString> path;
  const SeasonsTableCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
  });
  SeasonsTableCompanion.insert({
    this.id = const Value.absent(),
    required int seriesId,
    required String name,
    required PathString path,
  })  : seriesId = Value(seriesId),
        name = Value(name),
        path = Value(path);
  static Insertable<SeasonsTableData> custom({
    Expression<int>? id,
    Expression<int>? seriesId,
    Expression<String>? name,
    Expression<String>? path,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
    });
  }

  SeasonsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? seriesId,
      Value<String>? name,
      Value<PathString>? path}) {
    return SeasonsTableCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      path: path ?? this.path,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] =
          Variable<String>($SeasonsTableTable.$converterpath.toSql(path.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeasonsTableCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('name: $name, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTableTable extends EpisodesTable
    with TableInfo<$EpisodesTableTable, EpisodesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _seasonIdMeta =
      const VerificationMeta('seasonId');
  @override
  late final GeneratedColumn<int> seasonId = GeneratedColumn<int>(
      'season_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES seasons_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PathString, String> path =
      GeneratedColumn<String>('path', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PathString>($EpisodesTableTable.$converterpath);
  @override
  late final GeneratedColumnWithTypeConverter<PathString?, String>
      thumbnailPath = GeneratedColumn<String>(
              'thumbnail_path', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PathString?>(
              $EpisodesTableTable.$converterthumbnailPathn);
  static const VerificationMeta _watchedMeta =
      const VerificationMeta('watched');
  @override
  late final GeneratedColumn<bool> watched = GeneratedColumn<bool>(
      'watched', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("watched" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _watchedPercentageMeta =
      const VerificationMeta('watchedPercentage');
  @override
  late final GeneratedColumn<double> watchedPercentage =
      GeneratedColumn<double>('watched_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _thumbnailUnavailableMeta =
      const VerificationMeta('thumbnailUnavailable');
  @override
  late final GeneratedColumn<bool> thumbnailUnavailable = GeneratedColumn<bool>(
      'thumbnail_unavailable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("thumbnail_unavailable" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<Metadata?, String> metadata =
      GeneratedColumn<String>('metadata', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Metadata?>($EpisodesTableTable.$convertermetadata);
  @override
  late final GeneratedColumnWithTypeConverter<MkvMetadata?, String>
      mkvMetadata = GeneratedColumn<String>('mkv_metadata', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<MkvMetadata?>(
              $EpisodesTableTable.$convertermkvMetadata);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seasonId,
        name,
        path,
        thumbnailPath,
        watched,
        watchedPercentage,
        thumbnailUnavailable,
        metadata,
        mkvMetadata
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes_table';
  @override
  VerificationContext validateIntegrity(Insertable<EpisodesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('season_id')) {
      context.handle(_seasonIdMeta,
          seasonId.isAcceptableOrUnknown(data['season_id']!, _seasonIdMeta));
    } else if (isInserting) {
      context.missing(_seasonIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('watched')) {
      context.handle(_watchedMeta,
          watched.isAcceptableOrUnknown(data['watched']!, _watchedMeta));
    }
    if (data.containsKey('watched_percentage')) {
      context.handle(
          _watchedPercentageMeta,
          watchedPercentage.isAcceptableOrUnknown(
              data['watched_percentage']!, _watchedPercentageMeta));
    }
    if (data.containsKey('thumbnail_unavailable')) {
      context.handle(
          _thumbnailUnavailableMeta,
          thumbnailUnavailable.isAcceptableOrUnknown(
              data['thumbnail_unavailable']!, _thumbnailUnavailableMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EpisodesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seasonId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}season_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      path: $EpisodesTableTable.$converterpath.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!),
      thumbnailPath: $EpisodesTableTable.$converterthumbnailPathn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}thumbnail_path'])),
      watched: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}watched'])!,
      watchedPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}watched_percentage'])!,
      thumbnailUnavailable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}thumbnail_unavailable'])!,
      metadata: $EpisodesTableTable.$convertermetadata.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])),
      mkvMetadata: $EpisodesTableTable.$convertermkvMetadata.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}mkv_metadata'])),
    );
  }

  @override
  $EpisodesTableTable createAlias(String alias) {
    return $EpisodesTableTable(attachedDatabase, alias);
  }

  static TypeConverter<PathString, String> $converterpath =
      const PathStringConverter();
  static TypeConverter<PathString, String> $converterthumbnailPath =
      const PathStringConverter();
  static TypeConverter<PathString?, String?> $converterthumbnailPathn =
      NullAwareTypeConverter.wrap($converterthumbnailPath);
  static TypeConverter<Metadata?, String?> $convertermetadata =
      const MetadataConverter();
  static TypeConverter<MkvMetadata?, String?> $convertermkvMetadata =
      const MkvMetadataConverter();
}

class EpisodesTableData extends DataClass
    implements Insertable<EpisodesTableData> {
  final int id;
  final int seasonId;
  final String name;
  final PathString path;
  final PathString? thumbnailPath;
  final bool watched;
  final double watchedPercentage;
  final bool thumbnailUnavailable;
  final Metadata? metadata;
  final MkvMetadata? mkvMetadata;
  const EpisodesTableData(
      {required this.id,
      required this.seasonId,
      required this.name,
      required this.path,
      this.thumbnailPath,
      required this.watched,
      required this.watchedPercentage,
      required this.thumbnailUnavailable,
      this.metadata,
      this.mkvMetadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['season_id'] = Variable<int>(seasonId);
    map['name'] = Variable<String>(name);
    {
      map['path'] =
          Variable<String>($EpisodesTableTable.$converterpath.toSql(path));
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(
          $EpisodesTableTable.$converterthumbnailPathn.toSql(thumbnailPath));
    }
    map['watched'] = Variable<bool>(watched);
    map['watched_percentage'] = Variable<double>(watchedPercentage);
    map['thumbnail_unavailable'] = Variable<bool>(thumbnailUnavailable);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(
          $EpisodesTableTable.$convertermetadata.toSql(metadata));
    }
    if (!nullToAbsent || mkvMetadata != null) {
      map['mkv_metadata'] = Variable<String>(
          $EpisodesTableTable.$convertermkvMetadata.toSql(mkvMetadata));
    }
    return map;
  }

  EpisodesTableCompanion toCompanion(bool nullToAbsent) {
    return EpisodesTableCompanion(
      id: Value(id),
      seasonId: Value(seasonId),
      name: Value(name),
      path: Value(path),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      watched: Value(watched),
      watchedPercentage: Value(watchedPercentage),
      thumbnailUnavailable: Value(thumbnailUnavailable),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      mkvMetadata: mkvMetadata == null && nullToAbsent
          ? const Value.absent()
          : Value(mkvMetadata),
    );
  }

  factory EpisodesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodesTableData(
      id: serializer.fromJson<int>(json['id']),
      seasonId: serializer.fromJson<int>(json['seasonId']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<PathString>(json['path']),
      thumbnailPath: serializer.fromJson<PathString?>(json['thumbnailPath']),
      watched: serializer.fromJson<bool>(json['watched']),
      watchedPercentage: serializer.fromJson<double>(json['watchedPercentage']),
      thumbnailUnavailable:
          serializer.fromJson<bool>(json['thumbnailUnavailable']),
      metadata: serializer.fromJson<Metadata?>(json['metadata']),
      mkvMetadata: serializer.fromJson<MkvMetadata?>(json['mkvMetadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seasonId': serializer.toJson<int>(seasonId),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<PathString>(path),
      'thumbnailPath': serializer.toJson<PathString?>(thumbnailPath),
      'watched': serializer.toJson<bool>(watched),
      'watchedPercentage': serializer.toJson<double>(watchedPercentage),
      'thumbnailUnavailable': serializer.toJson<bool>(thumbnailUnavailable),
      'metadata': serializer.toJson<Metadata?>(metadata),
      'mkvMetadata': serializer.toJson<MkvMetadata?>(mkvMetadata),
    };
  }

  EpisodesTableData copyWith(
          {int? id,
          int? seasonId,
          String? name,
          PathString? path,
          Value<PathString?> thumbnailPath = const Value.absent(),
          bool? watched,
          double? watchedPercentage,
          bool? thumbnailUnavailable,
          Value<Metadata?> metadata = const Value.absent(),
          Value<MkvMetadata?> mkvMetadata = const Value.absent()}) =>
      EpisodesTableData(
        id: id ?? this.id,
        seasonId: seasonId ?? this.seasonId,
        name: name ?? this.name,
        path: path ?? this.path,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        watched: watched ?? this.watched,
        watchedPercentage: watchedPercentage ?? this.watchedPercentage,
        thumbnailUnavailable: thumbnailUnavailable ?? this.thumbnailUnavailable,
        metadata: metadata.present ? metadata.value : this.metadata,
        mkvMetadata: mkvMetadata.present ? mkvMetadata.value : this.mkvMetadata,
      );
  EpisodesTableData copyWithCompanion(EpisodesTableCompanion data) {
    return EpisodesTableData(
      id: data.id.present ? data.id.value : this.id,
      seasonId: data.seasonId.present ? data.seasonId.value : this.seasonId,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      watched: data.watched.present ? data.watched.value : this.watched,
      watchedPercentage: data.watchedPercentage.present
          ? data.watchedPercentage.value
          : this.watchedPercentage,
      thumbnailUnavailable: data.thumbnailUnavailable.present
          ? data.thumbnailUnavailable.value
          : this.thumbnailUnavailable,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      mkvMetadata:
          data.mkvMetadata.present ? data.mkvMetadata.value : this.mkvMetadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesTableData(')
          ..write('id: $id, ')
          ..write('seasonId: $seasonId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('watched: $watched, ')
          ..write('watchedPercentage: $watchedPercentage, ')
          ..write('thumbnailUnavailable: $thumbnailUnavailable, ')
          ..write('metadata: $metadata, ')
          ..write('mkvMetadata: $mkvMetadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seasonId, name, path, thumbnailPath,
      watched, watchedPercentage, thumbnailUnavailable, metadata, mkvMetadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodesTableData &&
          other.id == this.id &&
          other.seasonId == this.seasonId &&
          other.name == this.name &&
          other.path == this.path &&
          other.thumbnailPath == this.thumbnailPath &&
          other.watched == this.watched &&
          other.watchedPercentage == this.watchedPercentage &&
          other.thumbnailUnavailable == this.thumbnailUnavailable &&
          other.metadata == this.metadata &&
          other.mkvMetadata == this.mkvMetadata);
}

class EpisodesTableCompanion extends UpdateCompanion<EpisodesTableData> {
  final Value<int> id;
  final Value<int> seasonId;
  final Value<String> name;
  final Value<PathString> path;
  final Value<PathString?> thumbnailPath;
  final Value<bool> watched;
  final Value<double> watchedPercentage;
  final Value<bool> thumbnailUnavailable;
  final Value<Metadata?> metadata;
  final Value<MkvMetadata?> mkvMetadata;
  const EpisodesTableCompanion({
    this.id = const Value.absent(),
    this.seasonId = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.watched = const Value.absent(),
    this.watchedPercentage = const Value.absent(),
    this.thumbnailUnavailable = const Value.absent(),
    this.metadata = const Value.absent(),
    this.mkvMetadata = const Value.absent(),
  });
  EpisodesTableCompanion.insert({
    this.id = const Value.absent(),
    required int seasonId,
    required String name,
    required PathString path,
    this.thumbnailPath = const Value.absent(),
    this.watched = const Value.absent(),
    this.watchedPercentage = const Value.absent(),
    this.thumbnailUnavailable = const Value.absent(),
    this.metadata = const Value.absent(),
    this.mkvMetadata = const Value.absent(),
  })  : seasonId = Value(seasonId),
        name = Value(name),
        path = Value(path);
  static Insertable<EpisodesTableData> custom({
    Expression<int>? id,
    Expression<int>? seasonId,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? thumbnailPath,
    Expression<bool>? watched,
    Expression<double>? watchedPercentage,
    Expression<bool>? thumbnailUnavailable,
    Expression<String>? metadata,
    Expression<String>? mkvMetadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seasonId != null) 'season_id': seasonId,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (watched != null) 'watched': watched,
      if (watchedPercentage != null) 'watched_percentage': watchedPercentage,
      if (thumbnailUnavailable != null)
        'thumbnail_unavailable': thumbnailUnavailable,
      if (metadata != null) 'metadata': metadata,
      if (mkvMetadata != null) 'mkv_metadata': mkvMetadata,
    });
  }

  EpisodesTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? seasonId,
      Value<String>? name,
      Value<PathString>? path,
      Value<PathString?>? thumbnailPath,
      Value<bool>? watched,
      Value<double>? watchedPercentage,
      Value<bool>? thumbnailUnavailable,
      Value<Metadata?>? metadata,
      Value<MkvMetadata?>? mkvMetadata}) {
    return EpisodesTableCompanion(
      id: id ?? this.id,
      seasonId: seasonId ?? this.seasonId,
      name: name ?? this.name,
      path: path ?? this.path,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      watched: watched ?? this.watched,
      watchedPercentage: watchedPercentage ?? this.watchedPercentage,
      thumbnailUnavailable: thumbnailUnavailable ?? this.thumbnailUnavailable,
      metadata: metadata ?? this.metadata,
      mkvMetadata: mkvMetadata ?? this.mkvMetadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seasonId.present) {
      map['season_id'] = Variable<int>(seasonId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(
          $EpisodesTableTable.$converterpath.toSql(path.value));
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>($EpisodesTableTable
          .$converterthumbnailPathn
          .toSql(thumbnailPath.value));
    }
    if (watched.present) {
      map['watched'] = Variable<bool>(watched.value);
    }
    if (watchedPercentage.present) {
      map['watched_percentage'] = Variable<double>(watchedPercentage.value);
    }
    if (thumbnailUnavailable.present) {
      map['thumbnail_unavailable'] = Variable<bool>(thumbnailUnavailable.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(
          $EpisodesTableTable.$convertermetadata.toSql(metadata.value));
    }
    if (mkvMetadata.present) {
      map['mkv_metadata'] = Variable<String>(
          $EpisodesTableTable.$convertermkvMetadata.toSql(mkvMetadata.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesTableCompanion(')
          ..write('id: $id, ')
          ..write('seasonId: $seasonId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('watched: $watched, ')
          ..write('watchedPercentage: $watchedPercentage, ')
          ..write('thumbnailUnavailable: $thumbnailUnavailable, ')
          ..write('metadata: $metadata, ')
          ..write('mkvMetadata: $mkvMetadata')
          ..write(')'))
        .toString();
  }
}

class $AnilistMappingsTableTable extends AnilistMappingsTable
    with TableInfo<$AnilistMappingsTableTable, AnilistMappingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnilistMappingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _seriesIdMeta =
      const VerificationMeta('seriesId');
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
      'series_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES series_table (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<PathString, String> localPath =
      GeneratedColumn<String>('local_path', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PathString>(
              $AnilistMappingsTableTable.$converterlocalPath);
  static const VerificationMeta _anilistIdMeta =
      const VerificationMeta('anilistId');
  @override
  late final GeneratedColumn<int> anilistId = GeneratedColumn<int>(
      'anilist_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedMeta =
      const VerificationMeta('lastSynced');
  @override
  late final GeneratedColumn<DateTime> lastSynced = GeneratedColumn<DateTime>(
      'last_synced', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _anilistDataMeta =
      const VerificationMeta('anilistData');
  @override
  late final GeneratedColumn<String> anilistData = GeneratedColumn<String>(
      'anilist_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, seriesId, localPath, anilistId, title, lastSynced, anilistData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anilist_mappings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnilistMappingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(_seriesIdMeta,
          seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta));
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('anilist_id')) {
      context.handle(_anilistIdMeta,
          anilistId.isAcceptableOrUnknown(data['anilist_id']!, _anilistIdMeta));
    } else if (isInserting) {
      context.missing(_anilistIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('last_synced')) {
      context.handle(
          _lastSyncedMeta,
          lastSynced.isAcceptableOrUnknown(
              data['last_synced']!, _lastSyncedMeta));
    }
    if (data.containsKey('anilist_data')) {
      context.handle(
          _anilistDataMeta,
          anilistData.isAcceptableOrUnknown(
              data['anilist_data']!, _anilistDataMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnilistMappingsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnilistMappingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seriesId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}series_id'])!,
      localPath: $AnilistMappingsTableTable.$converterlocalPath.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}local_path'])!),
      anilistId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}anilist_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      lastSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_synced']),
      anilistData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anilist_data']),
    );
  }

  @override
  $AnilistMappingsTableTable createAlias(String alias) {
    return $AnilistMappingsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<PathString, String> $converterlocalPath =
      const PathStringConverter();
}

class AnilistMappingsTableData extends DataClass
    implements Insertable<AnilistMappingsTableData> {
  final int id;
  final int seriesId;
  final PathString localPath;
  final int anilistId;
  final String? title;
  final DateTime? lastSynced;
  final String? anilistData;
  const AnilistMappingsTableData(
      {required this.id,
      required this.seriesId,
      required this.localPath,
      required this.anilistId,
      this.title,
      this.lastSynced,
      this.anilistData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['series_id'] = Variable<int>(seriesId);
    {
      map['local_path'] = Variable<String>(
          $AnilistMappingsTableTable.$converterlocalPath.toSql(localPath));
    }
    map['anilist_id'] = Variable<int>(anilistId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || lastSynced != null) {
      map['last_synced'] = Variable<DateTime>(lastSynced);
    }
    if (!nullToAbsent || anilistData != null) {
      map['anilist_data'] = Variable<String>(anilistData);
    }
    return map;
  }

  AnilistMappingsTableCompanion toCompanion(bool nullToAbsent) {
    return AnilistMappingsTableCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      localPath: Value(localPath),
      anilistId: Value(anilistId),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      lastSynced: lastSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSynced),
      anilistData: anilistData == null && nullToAbsent
          ? const Value.absent()
          : Value(anilistData),
    );
  }

  factory AnilistMappingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnilistMappingsTableData(
      id: serializer.fromJson<int>(json['id']),
      seriesId: serializer.fromJson<int>(json['seriesId']),
      localPath: serializer.fromJson<PathString>(json['localPath']),
      anilistId: serializer.fromJson<int>(json['anilistId']),
      title: serializer.fromJson<String?>(json['title']),
      lastSynced: serializer.fromJson<DateTime?>(json['lastSynced']),
      anilistData: serializer.fromJson<String?>(json['anilistData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seriesId': serializer.toJson<int>(seriesId),
      'localPath': serializer.toJson<PathString>(localPath),
      'anilistId': serializer.toJson<int>(anilistId),
      'title': serializer.toJson<String?>(title),
      'lastSynced': serializer.toJson<DateTime?>(lastSynced),
      'anilistData': serializer.toJson<String?>(anilistData),
    };
  }

  AnilistMappingsTableData copyWith(
          {int? id,
          int? seriesId,
          PathString? localPath,
          int? anilistId,
          Value<String?> title = const Value.absent(),
          Value<DateTime?> lastSynced = const Value.absent(),
          Value<String?> anilistData = const Value.absent()}) =>
      AnilistMappingsTableData(
        id: id ?? this.id,
        seriesId: seriesId ?? this.seriesId,
        localPath: localPath ?? this.localPath,
        anilistId: anilistId ?? this.anilistId,
        title: title.present ? title.value : this.title,
        lastSynced: lastSynced.present ? lastSynced.value : this.lastSynced,
        anilistData: anilistData.present ? anilistData.value : this.anilistData,
      );
  AnilistMappingsTableData copyWithCompanion(
      AnilistMappingsTableCompanion data) {
    return AnilistMappingsTableData(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      anilistId: data.anilistId.present ? data.anilistId.value : this.anilistId,
      title: data.title.present ? data.title.value : this.title,
      lastSynced:
          data.lastSynced.present ? data.lastSynced.value : this.lastSynced,
      anilistData:
          data.anilistData.present ? data.anilistData.value : this.anilistData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnilistMappingsTableData(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('localPath: $localPath, ')
          ..write('anilistId: $anilistId, ')
          ..write('title: $title, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('anilistData: $anilistData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, seriesId, localPath, anilistId, title, lastSynced, anilistData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnilistMappingsTableData &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.localPath == this.localPath &&
          other.anilistId == this.anilistId &&
          other.title == this.title &&
          other.lastSynced == this.lastSynced &&
          other.anilistData == this.anilistData);
}

class AnilistMappingsTableCompanion
    extends UpdateCompanion<AnilistMappingsTableData> {
  final Value<int> id;
  final Value<int> seriesId;
  final Value<PathString> localPath;
  final Value<int> anilistId;
  final Value<String?> title;
  final Value<DateTime?> lastSynced;
  final Value<String?> anilistData;
  const AnilistMappingsTableCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.anilistId = const Value.absent(),
    this.title = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.anilistData = const Value.absent(),
  });
  AnilistMappingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int seriesId,
    required PathString localPath,
    required int anilistId,
    this.title = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.anilistData = const Value.absent(),
  })  : seriesId = Value(seriesId),
        localPath = Value(localPath),
        anilistId = Value(anilistId);
  static Insertable<AnilistMappingsTableData> custom({
    Expression<int>? id,
    Expression<int>? seriesId,
    Expression<String>? localPath,
    Expression<int>? anilistId,
    Expression<String>? title,
    Expression<DateTime>? lastSynced,
    Expression<String>? anilistData,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (localPath != null) 'local_path': localPath,
      if (anilistId != null) 'anilist_id': anilistId,
      if (title != null) 'title': title,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (anilistData != null) 'anilist_data': anilistData,
    });
  }

  AnilistMappingsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? seriesId,
      Value<PathString>? localPath,
      Value<int>? anilistId,
      Value<String?>? title,
      Value<DateTime?>? lastSynced,
      Value<String?>? anilistData}) {
    return AnilistMappingsTableCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      localPath: localPath ?? this.localPath,
      anilistId: anilistId ?? this.anilistId,
      title: title ?? this.title,
      lastSynced: lastSynced ?? this.lastSynced,
      anilistData: anilistData ?? this.anilistData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>($AnilistMappingsTableTable
          .$converterlocalPath
          .toSql(localPath.value));
    }
    if (anilistId.present) {
      map['anilist_id'] = Variable<int>(anilistId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<DateTime>(lastSynced.value);
    }
    if (anilistData.present) {
      map['anilist_data'] = Variable<String>(anilistData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnilistMappingsTableCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('localPath: $localPath, ')
          ..write('anilistId: $anilistId, ')
          ..write('title: $title, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('anilistData: $anilistData')
          ..write(')'))
        .toString();
  }
}

class $WatchRecordsTableTable extends WatchRecordsTable
    with TableInfo<$WatchRecordsTableTable, WatchRecordsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<double> position = GeneratedColumn<double>(
      'position', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<double> duration = GeneratedColumn<double>(
      'duration', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, filePath, position, duration, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_records_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<WatchRecordsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchRecordsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchRecordsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}position'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}duration'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $WatchRecordsTableTable createAlias(String alias) {
    return $WatchRecordsTableTable(attachedDatabase, alias);
  }
}

class WatchRecordsTableData extends DataClass
    implements Insertable<WatchRecordsTableData> {
  final int id;
  final String filePath;
  final double position;
  final double duration;
  final DateTime timestamp;
  const WatchRecordsTableData(
      {required this.id,
      required this.filePath,
      required this.position,
      required this.duration,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    map['position'] = Variable<double>(position);
    map['duration'] = Variable<double>(duration);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  WatchRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return WatchRecordsTableCompanion(
      id: Value(id),
      filePath: Value(filePath),
      position: Value(position),
      duration: Value(duration),
      timestamp: Value(timestamp),
    );
  }

  factory WatchRecordsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchRecordsTableData(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      position: serializer.fromJson<double>(json['position']),
      duration: serializer.fromJson<double>(json['duration']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'position': serializer.toJson<double>(position),
      'duration': serializer.toJson<double>(duration),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  WatchRecordsTableData copyWith(
          {int? id,
          String? filePath,
          double? position,
          double? duration,
          DateTime? timestamp}) =>
      WatchRecordsTableData(
        id: id ?? this.id,
        filePath: filePath ?? this.filePath,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        timestamp: timestamp ?? this.timestamp,
      );
  WatchRecordsTableData copyWithCompanion(WatchRecordsTableCompanion data) {
    return WatchRecordsTableData(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      position: data.position.present ? data.position.value : this.position,
      duration: data.duration.present ? data.duration.value : this.duration,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchRecordsTableData(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, filePath, position, duration, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchRecordsTableData &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.position == this.position &&
          other.duration == this.duration &&
          other.timestamp == this.timestamp);
}

class WatchRecordsTableCompanion
    extends UpdateCompanion<WatchRecordsTableData> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<double> position;
  final Value<double> duration;
  final Value<DateTime> timestamp;
  const WatchRecordsTableCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.position = const Value.absent(),
    this.duration = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  WatchRecordsTableCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    required double position,
    required double duration,
    this.timestamp = const Value.absent(),
  })  : filePath = Value(filePath),
        position = Value(position),
        duration = Value(duration);
  static Insertable<WatchRecordsTableData> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<double>? position,
    Expression<double>? duration,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (position != null) 'position': position,
      if (duration != null) 'duration': duration,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  WatchRecordsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? filePath,
      Value<double>? position,
      Value<double>? duration,
      Value<DateTime>? timestamp}) {
    return WatchRecordsTableCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (position.present) {
      map['position'] = Variable<double>(position.value);
    }
    if (duration.present) {
      map['duration'] = Variable<double>(duration.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTableTable extends NotificationsTable
    with TableInfo<$NotificationsTableTable, NotificationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<NotificationType>(
              $NotificationsTableTable.$convertertype);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _animeIdMeta =
      const VerificationMeta('animeId');
  @override
  late final GeneratedColumn<int> animeId = GeneratedColumn<int>(
      'anime_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _episodeMeta =
      const VerificationMeta('episode');
  @override
  late final GeneratedColumn<int> episode = GeneratedColumn<int>(
      'episode', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> contexts =
      GeneratedColumn<String>('contexts', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $NotificationsTableTable.$convertercontexts);
  static const VerificationMeta _mediaIdMeta =
      const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<int> mediaId = GeneratedColumn<int>(
      'media_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String>
      deletedMediaTitles = GeneratedColumn<String>(
              'deleted_media_titles', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>(
              $NotificationsTableTable.$converterdeletedMediaTitles);
  static const VerificationMeta _deletedMediaTitleMeta =
      const VerificationMeta('deletedMediaTitle');
  @override
  late final GeneratedColumn<String> deletedMediaTitle =
      GeneratedColumn<String>('deleted_media_title', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<MediaInfo?, String> mediaInfo =
      GeneratedColumn<String>('media_info', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<MediaInfo?>(
              $NotificationsTableTable.$convertermediaInfo);
  static const VerificationMeta _localCreatedAtMeta =
      const VerificationMeta('localCreatedAt');
  @override
  late final GeneratedColumn<DateTime> localCreatedAt =
      GeneratedColumn<DateTime>('local_created_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  static const VerificationMeta _localUpdatedAtMeta =
      const VerificationMeta('localUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> localUpdatedAt =
      GeneratedColumn<DateTime>('local_updated_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        createdAt,
        isRead,
        animeId,
        episode,
        contexts,
        mediaId,
        context,
        reason,
        deletedMediaTitles,
        deletedMediaTitle,
        mediaInfo,
        localCreatedAt,
        localUpdatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
      Insertable<NotificationsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('anime_id')) {
      context.handle(_animeIdMeta,
          animeId.isAcceptableOrUnknown(data['anime_id']!, _animeIdMeta));
    }
    if (data.containsKey('episode')) {
      context.handle(_episodeMeta,
          episode.isAcceptableOrUnknown(data['episode']!, _episodeMeta));
    }
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta,
          mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('deleted_media_title')) {
      context.handle(
          _deletedMediaTitleMeta,
          deletedMediaTitle.isAcceptableOrUnknown(
              data['deleted_media_title']!, _deletedMediaTitleMeta));
    }
    if (data.containsKey('local_created_at')) {
      context.handle(
          _localCreatedAtMeta,
          localCreatedAt.isAcceptableOrUnknown(
              data['local_created_at']!, _localCreatedAtMeta));
    }
    if (data.containsKey('local_updated_at')) {
      context.handle(
          _localUpdatedAtMeta,
          localUpdatedAt.isAcceptableOrUnknown(
              data['local_updated_at']!, _localUpdatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: $NotificationsTableTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      animeId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}anime_id']),
      episode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}episode']),
      contexts: $NotificationsTableTable.$convertercontexts.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}contexts'])),
      mediaId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}media_id']),
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context']),
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      deletedMediaTitles: $NotificationsTableTable.$converterdeletedMediaTitles
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}deleted_media_titles'])),
      deletedMediaTitle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deleted_media_title']),
      mediaInfo: $NotificationsTableTable.$convertermediaInfo.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}media_info'])),
      localCreatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_created_at'])!,
      localUpdatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}local_updated_at'])!,
    );
  }

  @override
  $NotificationsTableTable createAlias(String alias) {
    return $NotificationsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<NotificationType, int> $convertertype =
      const NotificationTypeConverter();
  static TypeConverter<List<String>?, String?> $convertercontexts =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterdeletedMediaTitles =
      const StringListConverter();
  static TypeConverter<MediaInfo?, String?> $convertermediaInfo =
      const MediaInfoConverter();
}

class NotificationsTableData extends DataClass
    implements Insertable<NotificationsTableData> {
  final int id;
  final NotificationType type;
  final int createdAt;
  final bool isRead;
  final int? animeId;
  final int? episode;
  final List<String>? contexts;
  final int? mediaId;
  final String? context;
  final String? reason;
  final List<String>? deletedMediaTitles;
  final String? deletedMediaTitle;
  final MediaInfo? mediaInfo;
  final DateTime localCreatedAt;
  final DateTime localUpdatedAt;
  const NotificationsTableData(
      {required this.id,
      required this.type,
      required this.createdAt,
      required this.isRead,
      this.animeId,
      this.episode,
      this.contexts,
      this.mediaId,
      this.context,
      this.reason,
      this.deletedMediaTitles,
      this.deletedMediaTitle,
      this.mediaInfo,
      required this.localCreatedAt,
      required this.localUpdatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] =
          Variable<int>($NotificationsTableTable.$convertertype.toSql(type));
    }
    map['created_at'] = Variable<int>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || animeId != null) {
      map['anime_id'] = Variable<int>(animeId);
    }
    if (!nullToAbsent || episode != null) {
      map['episode'] = Variable<int>(episode);
    }
    if (!nullToAbsent || contexts != null) {
      map['contexts'] = Variable<String>(
          $NotificationsTableTable.$convertercontexts.toSql(contexts));
    }
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<int>(mediaId);
    }
    if (!nullToAbsent || context != null) {
      map['context'] = Variable<String>(context);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || deletedMediaTitles != null) {
      map['deleted_media_titles'] = Variable<String>($NotificationsTableTable
          .$converterdeletedMediaTitles
          .toSql(deletedMediaTitles));
    }
    if (!nullToAbsent || deletedMediaTitle != null) {
      map['deleted_media_title'] = Variable<String>(deletedMediaTitle);
    }
    if (!nullToAbsent || mediaInfo != null) {
      map['media_info'] = Variable<String>(
          $NotificationsTableTable.$convertermediaInfo.toSql(mediaInfo));
    }
    map['local_created_at'] = Variable<DateTime>(localCreatedAt);
    map['local_updated_at'] = Variable<DateTime>(localUpdatedAt);
    return map;
  }

  NotificationsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationsTableCompanion(
      id: Value(id),
      type: Value(type),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
      animeId: animeId == null && nullToAbsent
          ? const Value.absent()
          : Value(animeId),
      episode: episode == null && nullToAbsent
          ? const Value.absent()
          : Value(episode),
      contexts: contexts == null && nullToAbsent
          ? const Value.absent()
          : Value(contexts),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      context: context == null && nullToAbsent
          ? const Value.absent()
          : Value(context),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      deletedMediaTitles: deletedMediaTitles == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedMediaTitles),
      deletedMediaTitle: deletedMediaTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedMediaTitle),
      mediaInfo: mediaInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaInfo),
      localCreatedAt: Value(localCreatedAt),
      localUpdatedAt: Value(localUpdatedAt),
    );
  }

  factory NotificationsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationsTableData(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<NotificationType>(json['type']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      animeId: serializer.fromJson<int?>(json['animeId']),
      episode: serializer.fromJson<int?>(json['episode']),
      contexts: serializer.fromJson<List<String>?>(json['contexts']),
      mediaId: serializer.fromJson<int?>(json['mediaId']),
      context: serializer.fromJson<String?>(json['context']),
      reason: serializer.fromJson<String?>(json['reason']),
      deletedMediaTitles:
          serializer.fromJson<List<String>?>(json['deletedMediaTitles']),
      deletedMediaTitle:
          serializer.fromJson<String?>(json['deletedMediaTitle']),
      mediaInfo: serializer.fromJson<MediaInfo?>(json['mediaInfo']),
      localCreatedAt: serializer.fromJson<DateTime>(json['localCreatedAt']),
      localUpdatedAt: serializer.fromJson<DateTime>(json['localUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<NotificationType>(type),
      'createdAt': serializer.toJson<int>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
      'animeId': serializer.toJson<int?>(animeId),
      'episode': serializer.toJson<int?>(episode),
      'contexts': serializer.toJson<List<String>?>(contexts),
      'mediaId': serializer.toJson<int?>(mediaId),
      'context': serializer.toJson<String?>(context),
      'reason': serializer.toJson<String?>(reason),
      'deletedMediaTitles':
          serializer.toJson<List<String>?>(deletedMediaTitles),
      'deletedMediaTitle': serializer.toJson<String?>(deletedMediaTitle),
      'mediaInfo': serializer.toJson<MediaInfo?>(mediaInfo),
      'localCreatedAt': serializer.toJson<DateTime>(localCreatedAt),
      'localUpdatedAt': serializer.toJson<DateTime>(localUpdatedAt),
    };
  }

  NotificationsTableData copyWith(
          {int? id,
          NotificationType? type,
          int? createdAt,
          bool? isRead,
          Value<int?> animeId = const Value.absent(),
          Value<int?> episode = const Value.absent(),
          Value<List<String>?> contexts = const Value.absent(),
          Value<int?> mediaId = const Value.absent(),
          Value<String?> context = const Value.absent(),
          Value<String?> reason = const Value.absent(),
          Value<List<String>?> deletedMediaTitles = const Value.absent(),
          Value<String?> deletedMediaTitle = const Value.absent(),
          Value<MediaInfo?> mediaInfo = const Value.absent(),
          DateTime? localCreatedAt,
          DateTime? localUpdatedAt}) =>
      NotificationsTableData(
        id: id ?? this.id,
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
        animeId: animeId.present ? animeId.value : this.animeId,
        episode: episode.present ? episode.value : this.episode,
        contexts: contexts.present ? contexts.value : this.contexts,
        mediaId: mediaId.present ? mediaId.value : this.mediaId,
        context: context.present ? context.value : this.context,
        reason: reason.present ? reason.value : this.reason,
        deletedMediaTitles: deletedMediaTitles.present
            ? deletedMediaTitles.value
            : this.deletedMediaTitles,
        deletedMediaTitle: deletedMediaTitle.present
            ? deletedMediaTitle.value
            : this.deletedMediaTitle,
        mediaInfo: mediaInfo.present ? mediaInfo.value : this.mediaInfo,
        localCreatedAt: localCreatedAt ?? this.localCreatedAt,
        localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
      );
  NotificationsTableData copyWithCompanion(NotificationsTableCompanion data) {
    return NotificationsTableData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      animeId: data.animeId.present ? data.animeId.value : this.animeId,
      episode: data.episode.present ? data.episode.value : this.episode,
      contexts: data.contexts.present ? data.contexts.value : this.contexts,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      context: data.context.present ? data.context.value : this.context,
      reason: data.reason.present ? data.reason.value : this.reason,
      deletedMediaTitles: data.deletedMediaTitles.present
          ? data.deletedMediaTitles.value
          : this.deletedMediaTitles,
      deletedMediaTitle: data.deletedMediaTitle.present
          ? data.deletedMediaTitle.value
          : this.deletedMediaTitle,
      mediaInfo: data.mediaInfo.present ? data.mediaInfo.value : this.mediaInfo,
      localCreatedAt: data.localCreatedAt.present
          ? data.localCreatedAt.value
          : this.localCreatedAt,
      localUpdatedAt: data.localUpdatedAt.present
          ? data.localUpdatedAt.value
          : this.localUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsTableData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('animeId: $animeId, ')
          ..write('episode: $episode, ')
          ..write('contexts: $contexts, ')
          ..write('mediaId: $mediaId, ')
          ..write('context: $context, ')
          ..write('reason: $reason, ')
          ..write('deletedMediaTitles: $deletedMediaTitles, ')
          ..write('deletedMediaTitle: $deletedMediaTitle, ')
          ..write('mediaInfo: $mediaInfo, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      createdAt,
      isRead,
      animeId,
      episode,
      contexts,
      mediaId,
      context,
      reason,
      deletedMediaTitles,
      deletedMediaTitle,
      mediaInfo,
      localCreatedAt,
      localUpdatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationsTableData &&
          other.id == this.id &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead &&
          other.animeId == this.animeId &&
          other.episode == this.episode &&
          other.contexts == this.contexts &&
          other.mediaId == this.mediaId &&
          other.context == this.context &&
          other.reason == this.reason &&
          other.deletedMediaTitles == this.deletedMediaTitles &&
          other.deletedMediaTitle == this.deletedMediaTitle &&
          other.mediaInfo == this.mediaInfo &&
          other.localCreatedAt == this.localCreatedAt &&
          other.localUpdatedAt == this.localUpdatedAt);
}

class NotificationsTableCompanion
    extends UpdateCompanion<NotificationsTableData> {
  final Value<int> id;
  final Value<NotificationType> type;
  final Value<int> createdAt;
  final Value<bool> isRead;
  final Value<int?> animeId;
  final Value<int?> episode;
  final Value<List<String>?> contexts;
  final Value<int?> mediaId;
  final Value<String?> context;
  final Value<String?> reason;
  final Value<List<String>?> deletedMediaTitles;
  final Value<String?> deletedMediaTitle;
  final Value<MediaInfo?> mediaInfo;
  final Value<DateTime> localCreatedAt;
  final Value<DateTime> localUpdatedAt;
  const NotificationsTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.animeId = const Value.absent(),
    this.episode = const Value.absent(),
    this.contexts = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.context = const Value.absent(),
    this.reason = const Value.absent(),
    this.deletedMediaTitles = const Value.absent(),
    this.deletedMediaTitle = const Value.absent(),
    this.mediaInfo = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  });
  NotificationsTableCompanion.insert({
    this.id = const Value.absent(),
    required NotificationType type,
    required int createdAt,
    this.isRead = const Value.absent(),
    this.animeId = const Value.absent(),
    this.episode = const Value.absent(),
    this.contexts = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.context = const Value.absent(),
    this.reason = const Value.absent(),
    this.deletedMediaTitles = const Value.absent(),
    this.deletedMediaTitle = const Value.absent(),
    this.mediaInfo = const Value.absent(),
    this.localCreatedAt = const Value.absent(),
    this.localUpdatedAt = const Value.absent(),
  })  : type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<NotificationsTableData> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<int>? createdAt,
    Expression<bool>? isRead,
    Expression<int>? animeId,
    Expression<int>? episode,
    Expression<String>? contexts,
    Expression<int>? mediaId,
    Expression<String>? context,
    Expression<String>? reason,
    Expression<String>? deletedMediaTitles,
    Expression<String>? deletedMediaTitle,
    Expression<String>? mediaInfo,
    Expression<DateTime>? localCreatedAt,
    Expression<DateTime>? localUpdatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (animeId != null) 'anime_id': animeId,
      if (episode != null) 'episode': episode,
      if (contexts != null) 'contexts': contexts,
      if (mediaId != null) 'media_id': mediaId,
      if (context != null) 'context': context,
      if (reason != null) 'reason': reason,
      if (deletedMediaTitles != null)
        'deleted_media_titles': deletedMediaTitles,
      if (deletedMediaTitle != null) 'deleted_media_title': deletedMediaTitle,
      if (mediaInfo != null) 'media_info': mediaInfo,
      if (localCreatedAt != null) 'local_created_at': localCreatedAt,
      if (localUpdatedAt != null) 'local_updated_at': localUpdatedAt,
    });
  }

  NotificationsTableCompanion copyWith(
      {Value<int>? id,
      Value<NotificationType>? type,
      Value<int>? createdAt,
      Value<bool>? isRead,
      Value<int?>? animeId,
      Value<int?>? episode,
      Value<List<String>?>? contexts,
      Value<int?>? mediaId,
      Value<String?>? context,
      Value<String?>? reason,
      Value<List<String>?>? deletedMediaTitles,
      Value<String?>? deletedMediaTitle,
      Value<MediaInfo?>? mediaInfo,
      Value<DateTime>? localCreatedAt,
      Value<DateTime>? localUpdatedAt}) {
    return NotificationsTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      animeId: animeId ?? this.animeId,
      episode: episode ?? this.episode,
      contexts: contexts ?? this.contexts,
      mediaId: mediaId ?? this.mediaId,
      context: context ?? this.context,
      reason: reason ?? this.reason,
      deletedMediaTitles: deletedMediaTitles ?? this.deletedMediaTitles,
      deletedMediaTitle: deletedMediaTitle ?? this.deletedMediaTitle,
      mediaInfo: mediaInfo ?? this.mediaInfo,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      localUpdatedAt: localUpdatedAt ?? this.localUpdatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
          $NotificationsTableTable.$convertertype.toSql(type.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (animeId.present) {
      map['anime_id'] = Variable<int>(animeId.value);
    }
    if (episode.present) {
      map['episode'] = Variable<int>(episode.value);
    }
    if (contexts.present) {
      map['contexts'] = Variable<String>(
          $NotificationsTableTable.$convertercontexts.toSql(contexts.value));
    }
    if (mediaId.present) {
      map['media_id'] = Variable<int>(mediaId.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (deletedMediaTitles.present) {
      map['deleted_media_titles'] = Variable<String>($NotificationsTableTable
          .$converterdeletedMediaTitles
          .toSql(deletedMediaTitles.value));
    }
    if (deletedMediaTitle.present) {
      map['deleted_media_title'] = Variable<String>(deletedMediaTitle.value);
    }
    if (mediaInfo.present) {
      map['media_info'] = Variable<String>(
          $NotificationsTableTable.$convertermediaInfo.toSql(mediaInfo.value));
    }
    if (localCreatedAt.present) {
      map['local_created_at'] = Variable<DateTime>(localCreatedAt.value);
    }
    if (localUpdatedAt.present) {
      map['local_updated_at'] = Variable<DateTime>(localUpdatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('animeId: $animeId, ')
          ..write('episode: $episode, ')
          ..write('contexts: $contexts, ')
          ..write('mediaId: $mediaId, ')
          ..write('context: $context, ')
          ..write('reason: $reason, ')
          ..write('deletedMediaTitles: $deletedMediaTitles, ')
          ..write('deletedMediaTitle: $deletedMediaTitle, ')
          ..write('mediaInfo: $mediaInfo, ')
          ..write('localCreatedAt: $localCreatedAt, ')
          ..write('localUpdatedAt: $localUpdatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SeriesTableTable seriesTable = $SeriesTableTable(this);
  late final $SeasonsTableTable seasonsTable = $SeasonsTableTable(this);
  late final $EpisodesTableTable episodesTable = $EpisodesTableTable(this);
  late final $AnilistMappingsTableTable anilistMappingsTable =
      $AnilistMappingsTableTable(this);
  late final $WatchRecordsTableTable watchRecordsTable =
      $WatchRecordsTableTable(this);
  late final $NotificationsTableTable notificationsTable =
      $NotificationsTableTable(this);
  late final SeriesDao seriesDao = SeriesDao(this as AppDatabase);
  late final EpisodesDao episodesDao = EpisodesDao(this as AppDatabase);
  late final WatchDao watchDao = WatchDao(this as AppDatabase);
  late final NotificationsDao notificationsDao =
      NotificationsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        seriesTable,
        seasonsTable,
        episodesTable,
        anilistMappingsTable,
        watchRecordsTable,
        notificationsTable
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('series_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('seasons_table', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('seasons_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('episodes_table', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('series_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('anilist_mappings_table', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$SeriesTableTableCreateCompanionBuilder = SeriesTableCompanion
    Function({
  Value<int> id,
  required String name,
  required PathString path,
  Value<PathString?> folderPosterPath,
  Value<PathString?> folderBannerPath,
  Value<int?> primaryAnilistId,
  Value<bool> isHidden,
  Value<String?> customListName,
  Value<String?> dominantColor,
  Value<String?> preferredPosterSource,
  Value<String?> preferredBannerSource,
  Value<String?> anilistPosterUrl,
  Value<String?> anilistBannerUrl,
  Value<double> watchedPercentage,
  Value<DateTime> addedAt,
  Value<DateTime> updatedAt,
});
typedef $$SeriesTableTableUpdateCompanionBuilder = SeriesTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<PathString> path,
  Value<PathString?> folderPosterPath,
  Value<PathString?> folderBannerPath,
  Value<int?> primaryAnilistId,
  Value<bool> isHidden,
  Value<String?> customListName,
  Value<String?> dominantColor,
  Value<String?> preferredPosterSource,
  Value<String?> preferredBannerSource,
  Value<String?> anilistPosterUrl,
  Value<String?> anilistBannerUrl,
  Value<double> watchedPercentage,
  Value<DateTime> addedAt,
  Value<DateTime> updatedAt,
});

final class $$SeriesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SeriesTableTable, SeriesTableData> {
  $$SeriesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SeasonsTableTable, List<SeasonsTableData>>
      _seasonsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.seasonsTable,
              aliasName: $_aliasNameGenerator(
                  db.seriesTable.id, db.seasonsTable.seriesId));

  $$SeasonsTableTableProcessedTableManager get seasonsTableRefs {
    final manager = $$SeasonsTableTableTableManager($_db, $_db.seasonsTable)
        .filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_seasonsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AnilistMappingsTableTable,
      List<AnilistMappingsTableData>> _anilistMappingsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.anilistMappingsTable,
          aliasName: $_aliasNameGenerator(
              db.seriesTable.id, db.anilistMappingsTable.seriesId));

  $$AnilistMappingsTableTableProcessedTableManager
      get anilistMappingsTableRefs {
    final manager =
        $$AnilistMappingsTableTableTableManager($_db, $_db.anilistMappingsTable)
            .filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_anilistMappingsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SeriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PathString, PathString, String> get path =>
      $composableBuilder(
          column: $table.path,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PathString?, PathString, String>
      get folderPosterPath => $composableBuilder(
          column: $table.folderPosterPath,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PathString?, PathString, String>
      get folderBannerPath => $composableBuilder(
          column: $table.folderBannerPath,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get primaryAnilistId => $composableBuilder(
      column: $table.primaryAnilistId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHidden => $composableBuilder(
      column: $table.isHidden, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customListName => $composableBuilder(
      column: $table.customListName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dominantColor => $composableBuilder(
      column: $table.dominantColor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredPosterSource => $composableBuilder(
      column: $table.preferredPosterSource,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredBannerSource => $composableBuilder(
      column: $table.preferredBannerSource,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anilistPosterUrl => $composableBuilder(
      column: $table.anilistPosterUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anilistBannerUrl => $composableBuilder(
      column: $table.anilistBannerUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get watchedPercentage => $composableBuilder(
      column: $table.watchedPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> seasonsTableRefs(
      Expression<bool> Function($$SeasonsTableTableFilterComposer f) f) {
    final $$SeasonsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.seasonsTable,
        getReferencedColumn: (t) => t.seriesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeasonsTableTableFilterComposer(
              $db: $db,
              $table: $db.seasonsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> anilistMappingsTableRefs(
      Expression<bool> Function($$AnilistMappingsTableTableFilterComposer f)
          f) {
    final $$AnilistMappingsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.anilistMappingsTable,
        getReferencedColumn: (t) => t.seriesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AnilistMappingsTableTableFilterComposer(
              $db: $db,
              $table: $db.anilistMappingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SeriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folderPosterPath => $composableBuilder(
      column: $table.folderPosterPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folderBannerPath => $composableBuilder(
      column: $table.folderBannerPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get primaryAnilistId => $composableBuilder(
      column: $table.primaryAnilistId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHidden => $composableBuilder(
      column: $table.isHidden, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customListName => $composableBuilder(
      column: $table.customListName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dominantColor => $composableBuilder(
      column: $table.dominantColor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredPosterSource => $composableBuilder(
      column: $table.preferredPosterSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredBannerSource => $composableBuilder(
      column: $table.preferredBannerSource,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anilistPosterUrl => $composableBuilder(
      column: $table.anilistPosterUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anilistBannerUrl => $composableBuilder(
      column: $table.anilistBannerUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get watchedPercentage => $composableBuilder(
      column: $table.watchedPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SeriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTableTable> {
  $$SeriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString, String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString?, String> get folderPosterPath =>
      $composableBuilder(
          column: $table.folderPosterPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString?, String> get folderBannerPath =>
      $composableBuilder(
          column: $table.folderBannerPath, builder: (column) => column);

  GeneratedColumn<int> get primaryAnilistId => $composableBuilder(
      column: $table.primaryAnilistId, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<String> get customListName => $composableBuilder(
      column: $table.customListName, builder: (column) => column);

  GeneratedColumn<String> get dominantColor => $composableBuilder(
      column: $table.dominantColor, builder: (column) => column);

  GeneratedColumn<String> get preferredPosterSource => $composableBuilder(
      column: $table.preferredPosterSource, builder: (column) => column);

  GeneratedColumn<String> get preferredBannerSource => $composableBuilder(
      column: $table.preferredBannerSource, builder: (column) => column);

  GeneratedColumn<String> get anilistPosterUrl => $composableBuilder(
      column: $table.anilistPosterUrl, builder: (column) => column);

  GeneratedColumn<String> get anilistBannerUrl => $composableBuilder(
      column: $table.anilistBannerUrl, builder: (column) => column);

  GeneratedColumn<double> get watchedPercentage => $composableBuilder(
      column: $table.watchedPercentage, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> seasonsTableRefs<T extends Object>(
      Expression<T> Function($$SeasonsTableTableAnnotationComposer a) f) {
    final $$SeasonsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.seasonsTable,
        getReferencedColumn: (t) => t.seriesId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeasonsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.seasonsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> anilistMappingsTableRefs<T extends Object>(
      Expression<T> Function($$AnilistMappingsTableTableAnnotationComposer a)
          f) {
    final $$AnilistMappingsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.anilistMappingsTable,
            getReferencedColumn: (t) => t.seriesId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AnilistMappingsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.anilistMappingsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SeriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SeriesTableTable,
    SeriesTableData,
    $$SeriesTableTableFilterComposer,
    $$SeriesTableTableOrderingComposer,
    $$SeriesTableTableAnnotationComposer,
    $$SeriesTableTableCreateCompanionBuilder,
    $$SeriesTableTableUpdateCompanionBuilder,
    (SeriesTableData, $$SeriesTableTableReferences),
    SeriesTableData,
    PrefetchHooks Function(
        {bool seasonsTableRefs, bool anilistMappingsTableRefs})> {
  $$SeriesTableTableTableManager(_$AppDatabase db, $SeriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<PathString> path = const Value.absent(),
            Value<PathString?> folderPosterPath = const Value.absent(),
            Value<PathString?> folderBannerPath = const Value.absent(),
            Value<int?> primaryAnilistId = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<String?> customListName = const Value.absent(),
            Value<String?> dominantColor = const Value.absent(),
            Value<String?> preferredPosterSource = const Value.absent(),
            Value<String?> preferredBannerSource = const Value.absent(),
            Value<String?> anilistPosterUrl = const Value.absent(),
            Value<String?> anilistBannerUrl = const Value.absent(),
            Value<double> watchedPercentage = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SeriesTableCompanion(
            id: id,
            name: name,
            path: path,
            folderPosterPath: folderPosterPath,
            folderBannerPath: folderBannerPath,
            primaryAnilistId: primaryAnilistId,
            isHidden: isHidden,
            customListName: customListName,
            dominantColor: dominantColor,
            preferredPosterSource: preferredPosterSource,
            preferredBannerSource: preferredBannerSource,
            anilistPosterUrl: anilistPosterUrl,
            anilistBannerUrl: anilistBannerUrl,
            watchedPercentage: watchedPercentage,
            addedAt: addedAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required PathString path,
            Value<PathString?> folderPosterPath = const Value.absent(),
            Value<PathString?> folderBannerPath = const Value.absent(),
            Value<int?> primaryAnilistId = const Value.absent(),
            Value<bool> isHidden = const Value.absent(),
            Value<String?> customListName = const Value.absent(),
            Value<String?> dominantColor = const Value.absent(),
            Value<String?> preferredPosterSource = const Value.absent(),
            Value<String?> preferredBannerSource = const Value.absent(),
            Value<String?> anilistPosterUrl = const Value.absent(),
            Value<String?> anilistBannerUrl = const Value.absent(),
            Value<double> watchedPercentage = const Value.absent(),
            Value<DateTime> addedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SeriesTableCompanion.insert(
            id: id,
            name: name,
            path: path,
            folderPosterPath: folderPosterPath,
            folderBannerPath: folderBannerPath,
            primaryAnilistId: primaryAnilistId,
            isHidden: isHidden,
            customListName: customListName,
            dominantColor: dominantColor,
            preferredPosterSource: preferredPosterSource,
            preferredBannerSource: preferredBannerSource,
            anilistPosterUrl: anilistPosterUrl,
            anilistBannerUrl: anilistBannerUrl,
            watchedPercentage: watchedPercentage,
            addedAt: addedAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SeriesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {seasonsTableRefs = false, anilistMappingsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (seasonsTableRefs) db.seasonsTable,
                if (anilistMappingsTableRefs) db.anilistMappingsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (seasonsTableRefs)
                    await $_getPrefetchedData<SeriesTableData,
                            $SeriesTableTable, SeasonsTableData>(
                        currentTable: table,
                        referencedTable: $$SeriesTableTableReferences
                            ._seasonsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeriesTableTableReferences(db, table, p0)
                                .seasonsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.seriesId == item.id),
                        typedResults: items),
                  if (anilistMappingsTableRefs)
                    await $_getPrefetchedData<SeriesTableData,
                            $SeriesTableTable, AnilistMappingsTableData>(
                        currentTable: table,
                        referencedTable: $$SeriesTableTableReferences
                            ._anilistMappingsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeriesTableTableReferences(db, table, p0)
                                .anilistMappingsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.seriesId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SeriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SeriesTableTable,
    SeriesTableData,
    $$SeriesTableTableFilterComposer,
    $$SeriesTableTableOrderingComposer,
    $$SeriesTableTableAnnotationComposer,
    $$SeriesTableTableCreateCompanionBuilder,
    $$SeriesTableTableUpdateCompanionBuilder,
    (SeriesTableData, $$SeriesTableTableReferences),
    SeriesTableData,
    PrefetchHooks Function(
        {bool seasonsTableRefs, bool anilistMappingsTableRefs})>;
typedef $$SeasonsTableTableCreateCompanionBuilder = SeasonsTableCompanion
    Function({
  Value<int> id,
  required int seriesId,
  required String name,
  required PathString path,
});
typedef $$SeasonsTableTableUpdateCompanionBuilder = SeasonsTableCompanion
    Function({
  Value<int> id,
  Value<int> seriesId,
  Value<String> name,
  Value<PathString> path,
});

final class $$SeasonsTableTableReferences extends BaseReferences<_$AppDatabase,
    $SeasonsTableTable, SeasonsTableData> {
  $$SeasonsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeriesTableTable _seriesIdTable(_$AppDatabase db) =>
      db.seriesTable.createAlias(
          $_aliasNameGenerator(db.seasonsTable.seriesId, db.seriesTable.id));

  $$SeriesTableTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<int>('series_id')!;

    final manager = $$SeriesTableTableTableManager($_db, $_db.seriesTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EpisodesTableTable, List<EpisodesTableData>>
      _episodesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.episodesTable,
              aliasName: $_aliasNameGenerator(
                  db.seasonsTable.id, db.episodesTable.seasonId));

  $$EpisodesTableTableProcessedTableManager get episodesTableRefs {
    final manager = $$EpisodesTableTableTableManager($_db, $_db.episodesTable)
        .filter((f) => f.seasonId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SeasonsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SeasonsTableTable> {
  $$SeasonsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PathString, PathString, String> get path =>
      $composableBuilder(
          column: $table.path,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$SeriesTableTableFilterComposer get seriesId {
    final $$SeriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.seriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeriesTableTableFilterComposer(
              $db: $db,
              $table: $db.seriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> episodesTableRefs(
      Expression<bool> Function($$EpisodesTableTableFilterComposer f) f) {
    final $$EpisodesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.episodesTable,
        getReferencedColumn: (t) => t.seasonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableTableFilterComposer(
              $db: $db,
              $table: $db.episodesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SeasonsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SeasonsTableTable> {
  $$SeasonsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  $$SeriesTableTableOrderingComposer get seriesId {
    final $$SeriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.seriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.seriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SeasonsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeasonsTableTable> {
  $$SeasonsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString, String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  $$SeriesTableTableAnnotationComposer get seriesId {
    final $$SeriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.seriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.seriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> episodesTableRefs<T extends Object>(
      Expression<T> Function($$EpisodesTableTableAnnotationComposer a) f) {
    final $$EpisodesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.episodesTable,
        getReferencedColumn: (t) => t.seasonId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EpisodesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.episodesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SeasonsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SeasonsTableTable,
    SeasonsTableData,
    $$SeasonsTableTableFilterComposer,
    $$SeasonsTableTableOrderingComposer,
    $$SeasonsTableTableAnnotationComposer,
    $$SeasonsTableTableCreateCompanionBuilder,
    $$SeasonsTableTableUpdateCompanionBuilder,
    (SeasonsTableData, $$SeasonsTableTableReferences),
    SeasonsTableData,
    PrefetchHooks Function({bool seriesId, bool episodesTableRefs})> {
  $$SeasonsTableTableTableManager(_$AppDatabase db, $SeasonsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeasonsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeasonsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeasonsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> seriesId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<PathString> path = const Value.absent(),
          }) =>
              SeasonsTableCompanion(
            id: id,
            seriesId: seriesId,
            name: name,
            path: path,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int seriesId,
            required String name,
            required PathString path,
          }) =>
              SeasonsTableCompanion.insert(
            id: id,
            seriesId: seriesId,
            name: name,
            path: path,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SeasonsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {seriesId = false, episodesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (episodesTableRefs) db.episodesTable
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (seriesId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seriesId,
                    referencedTable:
                        $$SeasonsTableTableReferences._seriesIdTable(db),
                    referencedColumn:
                        $$SeasonsTableTableReferences._seriesIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (episodesTableRefs)
                    await $_getPrefetchedData<SeasonsTableData,
                            $SeasonsTableTable, EpisodesTableData>(
                        currentTable: table,
                        referencedTable: $$SeasonsTableTableReferences
                            ._episodesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SeasonsTableTableReferences(db, table, p0)
                                .episodesTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.seasonId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SeasonsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SeasonsTableTable,
    SeasonsTableData,
    $$SeasonsTableTableFilterComposer,
    $$SeasonsTableTableOrderingComposer,
    $$SeasonsTableTableAnnotationComposer,
    $$SeasonsTableTableCreateCompanionBuilder,
    $$SeasonsTableTableUpdateCompanionBuilder,
    (SeasonsTableData, $$SeasonsTableTableReferences),
    SeasonsTableData,
    PrefetchHooks Function({bool seriesId, bool episodesTableRefs})>;
typedef $$EpisodesTableTableCreateCompanionBuilder = EpisodesTableCompanion
    Function({
  Value<int> id,
  required int seasonId,
  required String name,
  required PathString path,
  Value<PathString?> thumbnailPath,
  Value<bool> watched,
  Value<double> watchedPercentage,
  Value<bool> thumbnailUnavailable,
  Value<Metadata?> metadata,
  Value<MkvMetadata?> mkvMetadata,
});
typedef $$EpisodesTableTableUpdateCompanionBuilder = EpisodesTableCompanion
    Function({
  Value<int> id,
  Value<int> seasonId,
  Value<String> name,
  Value<PathString> path,
  Value<PathString?> thumbnailPath,
  Value<bool> watched,
  Value<double> watchedPercentage,
  Value<bool> thumbnailUnavailable,
  Value<Metadata?> metadata,
  Value<MkvMetadata?> mkvMetadata,
});

final class $$EpisodesTableTableReferences extends BaseReferences<_$AppDatabase,
    $EpisodesTableTable, EpisodesTableData> {
  $$EpisodesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SeasonsTableTable _seasonIdTable(_$AppDatabase db) =>
      db.seasonsTable.createAlias(
          $_aliasNameGenerator(db.episodesTable.seasonId, db.seasonsTable.id));

  $$SeasonsTableTableProcessedTableManager get seasonId {
    final $_column = $_itemColumn<int>('season_id')!;

    final manager = $$SeasonsTableTableTableManager($_db, $_db.seasonsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seasonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EpisodesTableTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTableTable> {
  $$EpisodesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PathString, PathString, String> get path =>
      $composableBuilder(
          column: $table.path,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PathString?, PathString, String>
      get thumbnailPath => $composableBuilder(
          column: $table.thumbnailPath,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get watched => $composableBuilder(
      column: $table.watched, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get watchedPercentage => $composableBuilder(
      column: $table.watchedPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get thumbnailUnavailable => $composableBuilder(
      column: $table.thumbnailUnavailable,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Metadata?, Metadata, String> get metadata =>
      $composableBuilder(
          column: $table.metadata,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<MkvMetadata?, MkvMetadata, String>
      get mkvMetadata => $composableBuilder(
          column: $table.mkvMetadata,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$SeasonsTableTableFilterComposer get seasonId {
    final $$SeasonsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seasonId,
        referencedTable: $db.seasonsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeasonsTableTableFilterComposer(
              $db: $db,
              $table: $db.seasonsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EpisodesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTableTable> {
  $$EpisodesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get watched => $composableBuilder(
      column: $table.watched, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get watchedPercentage => $composableBuilder(
      column: $table.watchedPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get thumbnailUnavailable => $composableBuilder(
      column: $table.thumbnailUnavailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mkvMetadata => $composableBuilder(
      column: $table.mkvMetadata, builder: (column) => ColumnOrderings(column));

  $$SeasonsTableTableOrderingComposer get seasonId {
    final $$SeasonsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seasonId,
        referencedTable: $db.seasonsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeasonsTableTableOrderingComposer(
              $db: $db,
              $table: $db.seasonsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EpisodesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTableTable> {
  $$EpisodesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString, String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString?, String> get thumbnailPath =>
      $composableBuilder(
          column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<bool> get watched =>
      $composableBuilder(column: $table.watched, builder: (column) => column);

  GeneratedColumn<double> get watchedPercentage => $composableBuilder(
      column: $table.watchedPercentage, builder: (column) => column);

  GeneratedColumn<bool> get thumbnailUnavailable => $composableBuilder(
      column: $table.thumbnailUnavailable, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Metadata?, String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MkvMetadata?, String> get mkvMetadata =>
      $composableBuilder(
          column: $table.mkvMetadata, builder: (column) => column);

  $$SeasonsTableTableAnnotationComposer get seasonId {
    final $$SeasonsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seasonId,
        referencedTable: $db.seasonsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeasonsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.seasonsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EpisodesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EpisodesTableTable,
    EpisodesTableData,
    $$EpisodesTableTableFilterComposer,
    $$EpisodesTableTableOrderingComposer,
    $$EpisodesTableTableAnnotationComposer,
    $$EpisodesTableTableCreateCompanionBuilder,
    $$EpisodesTableTableUpdateCompanionBuilder,
    (EpisodesTableData, $$EpisodesTableTableReferences),
    EpisodesTableData,
    PrefetchHooks Function({bool seasonId})> {
  $$EpisodesTableTableTableManager(_$AppDatabase db, $EpisodesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> seasonId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<PathString> path = const Value.absent(),
            Value<PathString?> thumbnailPath = const Value.absent(),
            Value<bool> watched = const Value.absent(),
            Value<double> watchedPercentage = const Value.absent(),
            Value<bool> thumbnailUnavailable = const Value.absent(),
            Value<Metadata?> metadata = const Value.absent(),
            Value<MkvMetadata?> mkvMetadata = const Value.absent(),
          }) =>
              EpisodesTableCompanion(
            id: id,
            seasonId: seasonId,
            name: name,
            path: path,
            thumbnailPath: thumbnailPath,
            watched: watched,
            watchedPercentage: watchedPercentage,
            thumbnailUnavailable: thumbnailUnavailable,
            metadata: metadata,
            mkvMetadata: mkvMetadata,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int seasonId,
            required String name,
            required PathString path,
            Value<PathString?> thumbnailPath = const Value.absent(),
            Value<bool> watched = const Value.absent(),
            Value<double> watchedPercentage = const Value.absent(),
            Value<bool> thumbnailUnavailable = const Value.absent(),
            Value<Metadata?> metadata = const Value.absent(),
            Value<MkvMetadata?> mkvMetadata = const Value.absent(),
          }) =>
              EpisodesTableCompanion.insert(
            id: id,
            seasonId: seasonId,
            name: name,
            path: path,
            thumbnailPath: thumbnailPath,
            watched: watched,
            watchedPercentage: watchedPercentage,
            thumbnailUnavailable: thumbnailUnavailable,
            metadata: metadata,
            mkvMetadata: mkvMetadata,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EpisodesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({seasonId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (seasonId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seasonId,
                    referencedTable:
                        $$EpisodesTableTableReferences._seasonIdTable(db),
                    referencedColumn:
                        $$EpisodesTableTableReferences._seasonIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EpisodesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EpisodesTableTable,
    EpisodesTableData,
    $$EpisodesTableTableFilterComposer,
    $$EpisodesTableTableOrderingComposer,
    $$EpisodesTableTableAnnotationComposer,
    $$EpisodesTableTableCreateCompanionBuilder,
    $$EpisodesTableTableUpdateCompanionBuilder,
    (EpisodesTableData, $$EpisodesTableTableReferences),
    EpisodesTableData,
    PrefetchHooks Function({bool seasonId})>;
typedef $$AnilistMappingsTableTableCreateCompanionBuilder
    = AnilistMappingsTableCompanion Function({
  Value<int> id,
  required int seriesId,
  required PathString localPath,
  required int anilistId,
  Value<String?> title,
  Value<DateTime?> lastSynced,
  Value<String?> anilistData,
});
typedef $$AnilistMappingsTableTableUpdateCompanionBuilder
    = AnilistMappingsTableCompanion Function({
  Value<int> id,
  Value<int> seriesId,
  Value<PathString> localPath,
  Value<int> anilistId,
  Value<String?> title,
  Value<DateTime?> lastSynced,
  Value<String?> anilistData,
});

final class $$AnilistMappingsTableTableReferences extends BaseReferences<
    _$AppDatabase, $AnilistMappingsTableTable, AnilistMappingsTableData> {
  $$AnilistMappingsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SeriesTableTable _seriesIdTable(_$AppDatabase db) =>
      db.seriesTable.createAlias($_aliasNameGenerator(
          db.anilistMappingsTable.seriesId, db.seriesTable.id));

  $$SeriesTableTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<int>('series_id')!;

    final manager = $$SeriesTableTableTableManager($_db, $_db.seriesTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AnilistMappingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AnilistMappingsTableTable> {
  $$AnilistMappingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PathString, PathString, String>
      get localPath => $composableBuilder(
          column: $table.localPath,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get anilistId => $composableBuilder(
      column: $table.anilistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSynced => $composableBuilder(
      column: $table.lastSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anilistData => $composableBuilder(
      column: $table.anilistData, builder: (column) => ColumnFilters(column));

  $$SeriesTableTableFilterComposer get seriesId {
    final $$SeriesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.seriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeriesTableTableFilterComposer(
              $db: $db,
              $table: $db.seriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnilistMappingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AnilistMappingsTableTable> {
  $$AnilistMappingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get anilistId => $composableBuilder(
      column: $table.anilistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSynced => $composableBuilder(
      column: $table.lastSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anilistData => $composableBuilder(
      column: $table.anilistData, builder: (column) => ColumnOrderings(column));

  $$SeriesTableTableOrderingComposer get seriesId {
    final $$SeriesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.seriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeriesTableTableOrderingComposer(
              $db: $db,
              $table: $db.seriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnilistMappingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnilistMappingsTableTable> {
  $$AnilistMappingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PathString, String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get anilistId =>
      $composableBuilder(column: $table.anilistId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSynced => $composableBuilder(
      column: $table.lastSynced, builder: (column) => column);

  GeneratedColumn<String> get anilistData => $composableBuilder(
      column: $table.anilistData, builder: (column) => column);

  $$SeriesTableTableAnnotationComposer get seriesId {
    final $$SeriesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.seriesId,
        referencedTable: $db.seriesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SeriesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.seriesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AnilistMappingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnilistMappingsTableTable,
    AnilistMappingsTableData,
    $$AnilistMappingsTableTableFilterComposer,
    $$AnilistMappingsTableTableOrderingComposer,
    $$AnilistMappingsTableTableAnnotationComposer,
    $$AnilistMappingsTableTableCreateCompanionBuilder,
    $$AnilistMappingsTableTableUpdateCompanionBuilder,
    (AnilistMappingsTableData, $$AnilistMappingsTableTableReferences),
    AnilistMappingsTableData,
    PrefetchHooks Function({bool seriesId})> {
  $$AnilistMappingsTableTableTableManager(
      _$AppDatabase db, $AnilistMappingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnilistMappingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnilistMappingsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnilistMappingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> seriesId = const Value.absent(),
            Value<PathString> localPath = const Value.absent(),
            Value<int> anilistId = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<DateTime?> lastSynced = const Value.absent(),
            Value<String?> anilistData = const Value.absent(),
          }) =>
              AnilistMappingsTableCompanion(
            id: id,
            seriesId: seriesId,
            localPath: localPath,
            anilistId: anilistId,
            title: title,
            lastSynced: lastSynced,
            anilistData: anilistData,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int seriesId,
            required PathString localPath,
            required int anilistId,
            Value<String?> title = const Value.absent(),
            Value<DateTime?> lastSynced = const Value.absent(),
            Value<String?> anilistData = const Value.absent(),
          }) =>
              AnilistMappingsTableCompanion.insert(
            id: id,
            seriesId: seriesId,
            localPath: localPath,
            anilistId: anilistId,
            title: title,
            lastSynced: lastSynced,
            anilistData: anilistData,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AnilistMappingsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({seriesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (seriesId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.seriesId,
                    referencedTable: $$AnilistMappingsTableTableReferences
                        ._seriesIdTable(db),
                    referencedColumn: $$AnilistMappingsTableTableReferences
                        ._seriesIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AnilistMappingsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AnilistMappingsTableTable,
        AnilistMappingsTableData,
        $$AnilistMappingsTableTableFilterComposer,
        $$AnilistMappingsTableTableOrderingComposer,
        $$AnilistMappingsTableTableAnnotationComposer,
        $$AnilistMappingsTableTableCreateCompanionBuilder,
        $$AnilistMappingsTableTableUpdateCompanionBuilder,
        (AnilistMappingsTableData, $$AnilistMappingsTableTableReferences),
        AnilistMappingsTableData,
        PrefetchHooks Function({bool seriesId})>;
typedef $$WatchRecordsTableTableCreateCompanionBuilder
    = WatchRecordsTableCompanion Function({
  Value<int> id,
  required String filePath,
  required double position,
  required double duration,
  Value<DateTime> timestamp,
});
typedef $$WatchRecordsTableTableUpdateCompanionBuilder
    = WatchRecordsTableCompanion Function({
  Value<int> id,
  Value<String> filePath,
  Value<double> position,
  Value<double> duration,
  Value<DateTime> timestamp,
});

class $$WatchRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WatchRecordsTableTable> {
  $$WatchRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$WatchRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchRecordsTableTable> {
  $$WatchRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$WatchRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchRecordsTableTable> {
  $$WatchRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<double> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$WatchRecordsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WatchRecordsTableTable,
    WatchRecordsTableData,
    $$WatchRecordsTableTableFilterComposer,
    $$WatchRecordsTableTableOrderingComposer,
    $$WatchRecordsTableTableAnnotationComposer,
    $$WatchRecordsTableTableCreateCompanionBuilder,
    $$WatchRecordsTableTableUpdateCompanionBuilder,
    (
      WatchRecordsTableData,
      BaseReferences<_$AppDatabase, $WatchRecordsTableTable,
          WatchRecordsTableData>
    ),
    WatchRecordsTableData,
    PrefetchHooks Function()> {
  $$WatchRecordsTableTableTableManager(
      _$AppDatabase db, $WatchRecordsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchRecordsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchRecordsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchRecordsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<double> position = const Value.absent(),
            Value<double> duration = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              WatchRecordsTableCompanion(
            id: id,
            filePath: filePath,
            position: position,
            duration: duration,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String filePath,
            required double position,
            required double duration,
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              WatchRecordsTableCompanion.insert(
            id: id,
            filePath: filePath,
            position: position,
            duration: duration,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WatchRecordsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WatchRecordsTableTable,
    WatchRecordsTableData,
    $$WatchRecordsTableTableFilterComposer,
    $$WatchRecordsTableTableOrderingComposer,
    $$WatchRecordsTableTableAnnotationComposer,
    $$WatchRecordsTableTableCreateCompanionBuilder,
    $$WatchRecordsTableTableUpdateCompanionBuilder,
    (
      WatchRecordsTableData,
      BaseReferences<_$AppDatabase, $WatchRecordsTableTable,
          WatchRecordsTableData>
    ),
    WatchRecordsTableData,
    PrefetchHooks Function()>;
typedef $$NotificationsTableTableCreateCompanionBuilder
    = NotificationsTableCompanion Function({
  Value<int> id,
  required NotificationType type,
  required int createdAt,
  Value<bool> isRead,
  Value<int?> animeId,
  Value<int?> episode,
  Value<List<String>?> contexts,
  Value<int?> mediaId,
  Value<String?> context,
  Value<String?> reason,
  Value<List<String>?> deletedMediaTitles,
  Value<String?> deletedMediaTitle,
  Value<MediaInfo?> mediaInfo,
  Value<DateTime> localCreatedAt,
  Value<DateTime> localUpdatedAt,
});
typedef $$NotificationsTableTableUpdateCompanionBuilder
    = NotificationsTableCompanion Function({
  Value<int> id,
  Value<NotificationType> type,
  Value<int> createdAt,
  Value<bool> isRead,
  Value<int?> animeId,
  Value<int?> episode,
  Value<List<String>?> contexts,
  Value<int?> mediaId,
  Value<String?> context,
  Value<String?> reason,
  Value<List<String>?> deletedMediaTitles,
  Value<String?> deletedMediaTitle,
  Value<MediaInfo?> mediaInfo,
  Value<DateTime> localCreatedAt,
  Value<DateTime> localUpdatedAt,
});

class $$NotificationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<NotificationType, NotificationType, int>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get animeId => $composableBuilder(
      column: $table.animeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get contexts => $composableBuilder(
          column: $table.contexts,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get deletedMediaTitles => $composableBuilder(
          column: $table.deletedMediaTitles,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deletedMediaTitle => $composableBuilder(
      column: $table.deletedMediaTitle,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<MediaInfo?, MediaInfo, String> get mediaInfo =>
      $composableBuilder(
          column: $table.mediaInfo,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get localCreatedAt => $composableBuilder(
      column: $table.localCreatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnFilters(column));
}

class $$NotificationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get animeId => $composableBuilder(
      column: $table.animeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get episode => $composableBuilder(
      column: $table.episode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contexts => $composableBuilder(
      column: $table.contexts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mediaId => $composableBuilder(
      column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedMediaTitles => $composableBuilder(
      column: $table.deletedMediaTitles,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deletedMediaTitle => $composableBuilder(
      column: $table.deletedMediaTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaInfo => $composableBuilder(
      column: $table.mediaInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localCreatedAt => $composableBuilder(
      column: $table.localCreatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$NotificationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTableTable> {
  $$NotificationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get animeId =>
      $composableBuilder(column: $table.animeId, builder: (column) => column);

  GeneratedColumn<int> get episode =>
      $composableBuilder(column: $table.episode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get contexts =>
      $composableBuilder(column: $table.contexts, builder: (column) => column);

  GeneratedColumn<int> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String>
      get deletedMediaTitles => $composableBuilder(
          column: $table.deletedMediaTitles, builder: (column) => column);

  GeneratedColumn<String> get deletedMediaTitle => $composableBuilder(
      column: $table.deletedMediaTitle, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaInfo?, String> get mediaInfo =>
      $composableBuilder(column: $table.mediaInfo, builder: (column) => column);

  GeneratedColumn<DateTime> get localCreatedAt => $composableBuilder(
      column: $table.localCreatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get localUpdatedAt => $composableBuilder(
      column: $table.localUpdatedAt, builder: (column) => column);
}

class $$NotificationsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTableTable,
    NotificationsTableData,
    $$NotificationsTableTableFilterComposer,
    $$NotificationsTableTableOrderingComposer,
    $$NotificationsTableTableAnnotationComposer,
    $$NotificationsTableTableCreateCompanionBuilder,
    $$NotificationsTableTableUpdateCompanionBuilder,
    (
      NotificationsTableData,
      BaseReferences<_$AppDatabase, $NotificationsTableTable,
          NotificationsTableData>
    ),
    NotificationsTableData,
    PrefetchHooks Function()> {
  $$NotificationsTableTableTableManager(
      _$AppDatabase db, $NotificationsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<NotificationType> type = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<int?> animeId = const Value.absent(),
            Value<int?> episode = const Value.absent(),
            Value<List<String>?> contexts = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            Value<String?> context = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<List<String>?> deletedMediaTitles = const Value.absent(),
            Value<String?> deletedMediaTitle = const Value.absent(),
            Value<MediaInfo?> mediaInfo = const Value.absent(),
            Value<DateTime> localCreatedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
          }) =>
              NotificationsTableCompanion(
            id: id,
            type: type,
            createdAt: createdAt,
            isRead: isRead,
            animeId: animeId,
            episode: episode,
            contexts: contexts,
            mediaId: mediaId,
            context: context,
            reason: reason,
            deletedMediaTitles: deletedMediaTitles,
            deletedMediaTitle: deletedMediaTitle,
            mediaInfo: mediaInfo,
            localCreatedAt: localCreatedAt,
            localUpdatedAt: localUpdatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required NotificationType type,
            required int createdAt,
            Value<bool> isRead = const Value.absent(),
            Value<int?> animeId = const Value.absent(),
            Value<int?> episode = const Value.absent(),
            Value<List<String>?> contexts = const Value.absent(),
            Value<int?> mediaId = const Value.absent(),
            Value<String?> context = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<List<String>?> deletedMediaTitles = const Value.absent(),
            Value<String?> deletedMediaTitle = const Value.absent(),
            Value<MediaInfo?> mediaInfo = const Value.absent(),
            Value<DateTime> localCreatedAt = const Value.absent(),
            Value<DateTime> localUpdatedAt = const Value.absent(),
          }) =>
              NotificationsTableCompanion.insert(
            id: id,
            type: type,
            createdAt: createdAt,
            isRead: isRead,
            animeId: animeId,
            episode: episode,
            contexts: contexts,
            mediaId: mediaId,
            context: context,
            reason: reason,
            deletedMediaTitles: deletedMediaTitles,
            deletedMediaTitle: deletedMediaTitle,
            mediaInfo: mediaInfo,
            localCreatedAt: localCreatedAt,
            localUpdatedAt: localUpdatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTableTable,
    NotificationsTableData,
    $$NotificationsTableTableFilterComposer,
    $$NotificationsTableTableOrderingComposer,
    $$NotificationsTableTableAnnotationComposer,
    $$NotificationsTableTableCreateCompanionBuilder,
    $$NotificationsTableTableUpdateCompanionBuilder,
    (
      NotificationsTableData,
      BaseReferences<_$AppDatabase, $NotificationsTableTable,
          NotificationsTableData>
    ),
    NotificationsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SeriesTableTableTableManager get seriesTable =>
      $$SeriesTableTableTableManager(_db, _db.seriesTable);
  $$SeasonsTableTableTableManager get seasonsTable =>
      $$SeasonsTableTableTableManager(_db, _db.seasonsTable);
  $$EpisodesTableTableTableManager get episodesTable =>
      $$EpisodesTableTableTableManager(_db, _db.episodesTable);
  $$AnilistMappingsTableTableTableManager get anilistMappingsTable =>
      $$AnilistMappingsTableTableTableManager(_db, _db.anilistMappingsTable);
  $$WatchRecordsTableTableTableManager get watchRecordsTable =>
      $$WatchRecordsTableTableTableManager(_db, _db.watchRecordsTable);
  $$NotificationsTableTableTableManager get notificationsTable =>
      $$NotificationsTableTableTableManager(_db, _db.notificationsTable);
}
