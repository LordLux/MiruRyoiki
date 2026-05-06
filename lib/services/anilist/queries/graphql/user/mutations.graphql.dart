import '../common/fragments.graphql.dart';
import '../schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Variables$Mutation$SaveMediaListEntry {
  factory Variables$Mutation$SaveMediaListEntry({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    int? scoreRaw,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    List<String?>? customLists,
    Input$FuzzyDateInput? startedAt,
    Input$FuzzyDateInput? completedAt,
  }) =>
      Variables$Mutation$SaveMediaListEntry._({
        if (id != null) r'id': id,
        if (mediaId != null) r'mediaId': mediaId,
        if (status != null) r'status': status,
        if (scoreRaw != null) r'scoreRaw': scoreRaw,
        if (progress != null) r'progress': progress,
        if (repeat != null) r'repeat': repeat,
        if (priority != null) r'priority': priority,
        if (private != null) r'private': private,
        if (notes != null) r'notes': notes,
        if (hiddenFromStatusLists != null)
          r'hiddenFromStatusLists': hiddenFromStatusLists,
        if (customLists != null) r'customLists': customLists,
        if (startedAt != null) r'startedAt': startedAt,
        if (completedAt != null) r'completedAt': completedAt,
      });

  Variables$Mutation$SaveMediaListEntry._(this._$data);

  factory Variables$Mutation$SaveMediaListEntry.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('id')) {
      final l$id = data['id'];
      result$data['id'] = (l$id as int?);
    }
    if (data.containsKey('mediaId')) {
      final l$mediaId = data['mediaId'];
      result$data['mediaId'] = (l$mediaId as int?);
    }
    if (data.containsKey('status')) {
      final l$status = data['status'];
      result$data['status'] = l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String));
    }
    if (data.containsKey('scoreRaw')) {
      final l$scoreRaw = data['scoreRaw'];
      result$data['scoreRaw'] = (l$scoreRaw as int?);
    }
    if (data.containsKey('progress')) {
      final l$progress = data['progress'];
      result$data['progress'] = (l$progress as int?);
    }
    if (data.containsKey('repeat')) {
      final l$repeat = data['repeat'];
      result$data['repeat'] = (l$repeat as int?);
    }
    if (data.containsKey('priority')) {
      final l$priority = data['priority'];
      result$data['priority'] = (l$priority as int?);
    }
    if (data.containsKey('private')) {
      final l$private = data['private'];
      result$data['private'] = (l$private as bool?);
    }
    if (data.containsKey('notes')) {
      final l$notes = data['notes'];
      result$data['notes'] = (l$notes as String?);
    }
    if (data.containsKey('hiddenFromStatusLists')) {
      final l$hiddenFromStatusLists = data['hiddenFromStatusLists'];
      result$data['hiddenFromStatusLists'] = (l$hiddenFromStatusLists as bool?);
    }
    if (data.containsKey('customLists')) {
      final l$customLists = data['customLists'];
      result$data['customLists'] = (l$customLists as List<dynamic>?)
          ?.map((e) => (e as String?))
          .toList();
    }
    if (data.containsKey('startedAt')) {
      final l$startedAt = data['startedAt'];
      result$data['startedAt'] = l$startedAt == null
          ? null
          : Input$FuzzyDateInput.fromJson(
              (l$startedAt as Map<String, dynamic>));
    }
    if (data.containsKey('completedAt')) {
      final l$completedAt = data['completedAt'];
      result$data['completedAt'] = l$completedAt == null
          ? null
          : Input$FuzzyDateInput.fromJson(
              (l$completedAt as Map<String, dynamic>));
    }
    return Variables$Mutation$SaveMediaListEntry._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get id => (_$data['id'] as int?);

  int? get mediaId => (_$data['mediaId'] as int?);

  Enum$MediaListStatus? get status =>
      (_$data['status'] as Enum$MediaListStatus?);

  int? get scoreRaw => (_$data['scoreRaw'] as int?);

  int? get progress => (_$data['progress'] as int?);

  int? get repeat => (_$data['repeat'] as int?);

  int? get priority => (_$data['priority'] as int?);

  bool? get private => (_$data['private'] as bool?);

  String? get notes => (_$data['notes'] as String?);

  bool? get hiddenFromStatusLists => (_$data['hiddenFromStatusLists'] as bool?);

  List<String?>? get customLists => (_$data['customLists'] as List<String?>?);

  Input$FuzzyDateInput? get startedAt =>
      (_$data['startedAt'] as Input$FuzzyDateInput?);

  Input$FuzzyDateInput? get completedAt =>
      (_$data['completedAt'] as Input$FuzzyDateInput?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('id')) {
      final l$id = id;
      result$data['id'] = l$id;
    }
    if (_$data.containsKey('mediaId')) {
      final l$mediaId = mediaId;
      result$data['mediaId'] = l$mediaId;
    }
    if (_$data.containsKey('status')) {
      final l$status = status;
      result$data['status'] =
          l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    }
    if (_$data.containsKey('scoreRaw')) {
      final l$scoreRaw = scoreRaw;
      result$data['scoreRaw'] = l$scoreRaw;
    }
    if (_$data.containsKey('progress')) {
      final l$progress = progress;
      result$data['progress'] = l$progress;
    }
    if (_$data.containsKey('repeat')) {
      final l$repeat = repeat;
      result$data['repeat'] = l$repeat;
    }
    if (_$data.containsKey('priority')) {
      final l$priority = priority;
      result$data['priority'] = l$priority;
    }
    if (_$data.containsKey('private')) {
      final l$private = private;
      result$data['private'] = l$private;
    }
    if (_$data.containsKey('notes')) {
      final l$notes = notes;
      result$data['notes'] = l$notes;
    }
    if (_$data.containsKey('hiddenFromStatusLists')) {
      final l$hiddenFromStatusLists = hiddenFromStatusLists;
      result$data['hiddenFromStatusLists'] = l$hiddenFromStatusLists;
    }
    if (_$data.containsKey('customLists')) {
      final l$customLists = customLists;
      result$data['customLists'] = l$customLists?.map((e) => e).toList();
    }
    if (_$data.containsKey('startedAt')) {
      final l$startedAt = startedAt;
      result$data['startedAt'] = l$startedAt?.toJson();
    }
    if (_$data.containsKey('completedAt')) {
      final l$completedAt = completedAt;
      result$data['completedAt'] = l$completedAt?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$SaveMediaListEntry<
          Variables$Mutation$SaveMediaListEntry>
      get copyWith => CopyWith$Variables$Mutation$SaveMediaListEntry(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$SaveMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (_$data.containsKey('id') != other._$data.containsKey('id')) {
      return false;
    }
    if (l$id != lOther$id) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (_$data.containsKey('mediaId') != other._$data.containsKey('mediaId')) {
      return false;
    }
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (_$data.containsKey('status') != other._$data.containsKey('status')) {
      return false;
    }
    if (l$status != lOther$status) {
      return false;
    }
    final l$scoreRaw = scoreRaw;
    final lOther$scoreRaw = other.scoreRaw;
    if (_$data.containsKey('scoreRaw') !=
        other._$data.containsKey('scoreRaw')) {
      return false;
    }
    if (l$scoreRaw != lOther$scoreRaw) {
      return false;
    }
    final l$progress = progress;
    final lOther$progress = other.progress;
    if (_$data.containsKey('progress') !=
        other._$data.containsKey('progress')) {
      return false;
    }
    if (l$progress != lOther$progress) {
      return false;
    }
    final l$repeat = repeat;
    final lOther$repeat = other.repeat;
    if (_$data.containsKey('repeat') != other._$data.containsKey('repeat')) {
      return false;
    }
    if (l$repeat != lOther$repeat) {
      return false;
    }
    final l$priority = priority;
    final lOther$priority = other.priority;
    if (_$data.containsKey('priority') !=
        other._$data.containsKey('priority')) {
      return false;
    }
    if (l$priority != lOther$priority) {
      return false;
    }
    final l$private = private;
    final lOther$private = other.private;
    if (_$data.containsKey('private') != other._$data.containsKey('private')) {
      return false;
    }
    if (l$private != lOther$private) {
      return false;
    }
    final l$notes = notes;
    final lOther$notes = other.notes;
    if (_$data.containsKey('notes') != other._$data.containsKey('notes')) {
      return false;
    }
    if (l$notes != lOther$notes) {
      return false;
    }
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    final lOther$hiddenFromStatusLists = other.hiddenFromStatusLists;
    if (_$data.containsKey('hiddenFromStatusLists') !=
        other._$data.containsKey('hiddenFromStatusLists')) {
      return false;
    }
    if (l$hiddenFromStatusLists != lOther$hiddenFromStatusLists) {
      return false;
    }
    final l$customLists = customLists;
    final lOther$customLists = other.customLists;
    if (_$data.containsKey('customLists') !=
        other._$data.containsKey('customLists')) {
      return false;
    }
    if (l$customLists != null && lOther$customLists != null) {
      if (l$customLists.length != lOther$customLists.length) {
        return false;
      }
      for (int i = 0; i < l$customLists.length; i++) {
        final l$customLists$entry = l$customLists[i];
        final lOther$customLists$entry = lOther$customLists[i];
        if (l$customLists$entry != lOther$customLists$entry) {
          return false;
        }
      }
    } else if (l$customLists != lOther$customLists) {
      return false;
    }
    final l$startedAt = startedAt;
    final lOther$startedAt = other.startedAt;
    if (_$data.containsKey('startedAt') !=
        other._$data.containsKey('startedAt')) {
      return false;
    }
    if (l$startedAt != lOther$startedAt) {
      return false;
    }
    final l$completedAt = completedAt;
    final lOther$completedAt = other.completedAt;
    if (_$data.containsKey('completedAt') !=
        other._$data.containsKey('completedAt')) {
      return false;
    }
    if (l$completedAt != lOther$completedAt) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$mediaId = mediaId;
    final l$status = status;
    final l$scoreRaw = scoreRaw;
    final l$progress = progress;
    final l$repeat = repeat;
    final l$priority = priority;
    final l$private = private;
    final l$notes = notes;
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    final l$customLists = customLists;
    final l$startedAt = startedAt;
    final l$completedAt = completedAt;
    return Object.hashAll([
      _$data.containsKey('id') ? l$id : const {},
      _$data.containsKey('mediaId') ? l$mediaId : const {},
      _$data.containsKey('status') ? l$status : const {},
      _$data.containsKey('scoreRaw') ? l$scoreRaw : const {},
      _$data.containsKey('progress') ? l$progress : const {},
      _$data.containsKey('repeat') ? l$repeat : const {},
      _$data.containsKey('priority') ? l$priority : const {},
      _$data.containsKey('private') ? l$private : const {},
      _$data.containsKey('notes') ? l$notes : const {},
      _$data.containsKey('hiddenFromStatusLists')
          ? l$hiddenFromStatusLists
          : const {},
      _$data.containsKey('customLists')
          ? l$customLists == null
              ? null
              : Object.hashAll(l$customLists.map((v) => v))
          : const {},
      _$data.containsKey('startedAt') ? l$startedAt : const {},
      _$data.containsKey('completedAt') ? l$completedAt : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$SaveMediaListEntry<TRes> {
  factory CopyWith$Variables$Mutation$SaveMediaListEntry(
    Variables$Mutation$SaveMediaListEntry instance,
    TRes Function(Variables$Mutation$SaveMediaListEntry) then,
  ) = _CopyWithImpl$Variables$Mutation$SaveMediaListEntry;

  factory CopyWith$Variables$Mutation$SaveMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$SaveMediaListEntry;

  TRes call({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    int? scoreRaw,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    List<String?>? customLists,
    Input$FuzzyDateInput? startedAt,
    Input$FuzzyDateInput? completedAt,
  });
}

class _CopyWithImpl$Variables$Mutation$SaveMediaListEntry<TRes>
    implements CopyWith$Variables$Mutation$SaveMediaListEntry<TRes> {
  _CopyWithImpl$Variables$Mutation$SaveMediaListEntry(
    this._instance,
    this._then,
  );

  final Variables$Mutation$SaveMediaListEntry _instance;

  final TRes Function(Variables$Mutation$SaveMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? mediaId = _undefined,
    Object? status = _undefined,
    Object? scoreRaw = _undefined,
    Object? progress = _undefined,
    Object? repeat = _undefined,
    Object? priority = _undefined,
    Object? private = _undefined,
    Object? notes = _undefined,
    Object? hiddenFromStatusLists = _undefined,
    Object? customLists = _undefined,
    Object? startedAt = _undefined,
    Object? completedAt = _undefined,
  }) =>
      _then(Variables$Mutation$SaveMediaListEntry._({
        ..._instance._$data,
        if (id != _undefined) 'id': (id as int?),
        if (mediaId != _undefined) 'mediaId': (mediaId as int?),
        if (status != _undefined) 'status': (status as Enum$MediaListStatus?),
        if (scoreRaw != _undefined) 'scoreRaw': (scoreRaw as int?),
        if (progress != _undefined) 'progress': (progress as int?),
        if (repeat != _undefined) 'repeat': (repeat as int?),
        if (priority != _undefined) 'priority': (priority as int?),
        if (private != _undefined) 'private': (private as bool?),
        if (notes != _undefined) 'notes': (notes as String?),
        if (hiddenFromStatusLists != _undefined)
          'hiddenFromStatusLists': (hiddenFromStatusLists as bool?),
        if (customLists != _undefined)
          'customLists': (customLists as List<String?>?),
        if (startedAt != _undefined)
          'startedAt': (startedAt as Input$FuzzyDateInput?),
        if (completedAt != _undefined)
          'completedAt': (completedAt as Input$FuzzyDateInput?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$SaveMediaListEntry<TRes>
    implements CopyWith$Variables$Mutation$SaveMediaListEntry<TRes> {
  _CopyWithStubImpl$Variables$Mutation$SaveMediaListEntry(this._res);

  TRes _res;

  call({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    int? scoreRaw,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    List<String?>? customLists,
    Input$FuzzyDateInput? startedAt,
    Input$FuzzyDateInput? completedAt,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry {
  Mutation$SaveMediaListEntry({
    this.SaveMediaListEntry,
    this.$__typename = 'Mutation',
  });

  factory Mutation$SaveMediaListEntry.fromJson(Map<String, dynamic> json) {
    final l$SaveMediaListEntry = json['SaveMediaListEntry'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry(
      SaveMediaListEntry: l$SaveMediaListEntry == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry.fromJson(
              (l$SaveMediaListEntry as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$SaveMediaListEntry$SaveMediaListEntry? SaveMediaListEntry;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$SaveMediaListEntry = SaveMediaListEntry;
    _resultData['SaveMediaListEntry'] = l$SaveMediaListEntry?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$SaveMediaListEntry = SaveMediaListEntry;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$SaveMediaListEntry,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SaveMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$SaveMediaListEntry = SaveMediaListEntry;
    final lOther$SaveMediaListEntry = other.SaveMediaListEntry;
    if (l$SaveMediaListEntry != lOther$SaveMediaListEntry) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry
    on Mutation$SaveMediaListEntry {
  CopyWith$Mutation$SaveMediaListEntry<Mutation$SaveMediaListEntry>
      get copyWith => CopyWith$Mutation$SaveMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry<TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry(
    Mutation$SaveMediaListEntry instance,
    TRes Function(Mutation$SaveMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry;

  factory CopyWith$Mutation$SaveMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry;

  TRes call({
    Mutation$SaveMediaListEntry$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  });
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes>
      get SaveMediaListEntry;
}

class _CopyWithImpl$Mutation$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$SaveMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry _instance;

  final TRes Function(Mutation$SaveMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? SaveMediaListEntry = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry(
        SaveMediaListEntry: SaveMediaListEntry == _undefined
            ? _instance.SaveMediaListEntry
            : (SaveMediaListEntry
                as Mutation$SaveMediaListEntry$SaveMediaListEntry?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes>
      get SaveMediaListEntry {
    final local$SaveMediaListEntry = _instance.SaveMediaListEntry;
    return local$SaveMediaListEntry == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry.stub(
            _then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry(
            local$SaveMediaListEntry, (e) => call(SaveMediaListEntry: e));
  }
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$SaveMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry(this._res);

  TRes _res;

  call({
    Mutation$SaveMediaListEntry$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes>
      get SaveMediaListEntry =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry.stub(_res);
}

const documentNodeMutationSaveMediaListEntry = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'SaveMediaListEntry'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'mediaId')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'status')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaListStatus'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'scoreRaw')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'progress')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'repeat')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'priority')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'private')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'notes')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'hiddenFromStatusLists')),
        type: NamedTypeNode(
          name: NameNode(value: 'Boolean'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'customLists')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'String'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'startedAt')),
        type: NamedTypeNode(
          name: NameNode(value: 'FuzzyDateInput'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'completedAt')),
        type: NamedTypeNode(
          name: NameNode(value: 'FuzzyDateInput'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'SaveMediaListEntry'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          ),
          ArgumentNode(
            name: NameNode(value: 'mediaId'),
            value: VariableNode(name: NameNode(value: 'mediaId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'status'),
            value: VariableNode(name: NameNode(value: 'status')),
          ),
          ArgumentNode(
            name: NameNode(value: 'scoreRaw'),
            value: VariableNode(name: NameNode(value: 'scoreRaw')),
          ),
          ArgumentNode(
            name: NameNode(value: 'progress'),
            value: VariableNode(name: NameNode(value: 'progress')),
          ),
          ArgumentNode(
            name: NameNode(value: 'repeat'),
            value: VariableNode(name: NameNode(value: 'repeat')),
          ),
          ArgumentNode(
            name: NameNode(value: 'priority'),
            value: VariableNode(name: NameNode(value: 'priority')),
          ),
          ArgumentNode(
            name: NameNode(value: 'private'),
            value: VariableNode(name: NameNode(value: 'private')),
          ),
          ArgumentNode(
            name: NameNode(value: 'notes'),
            value: VariableNode(name: NameNode(value: 'notes')),
          ),
          ArgumentNode(
            name: NameNode(value: 'hiddenFromStatusLists'),
            value: VariableNode(name: NameNode(value: 'hiddenFromStatusLists')),
          ),
          ArgumentNode(
            name: NameNode(value: 'customLists'),
            value: VariableNode(name: NameNode(value: 'customLists')),
          ),
          ArgumentNode(
            name: NameNode(value: 'startedAt'),
            value: VariableNode(name: NameNode(value: 'startedAt')),
          ),
          ArgumentNode(
            name: NameNode(value: 'completedAt'),
            value: VariableNode(name: NameNode(value: 'completedAt')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'id'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'mediaId'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'status'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'score'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'format'),
                value: EnumValueNode(name: NameNode(value: 'POINT_100')),
              )
            ],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'progress'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'repeat'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'priority'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'private'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'notes'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'hiddenFromStatusLists'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'customLists'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'startedAt'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'year'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'month'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'day'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: 'completedAt'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'year'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'month'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'day'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: 'updatedAt'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'createdAt'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'media'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'AnimeCard'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: 'siteUrl'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'mediaListEntry'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'id'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionAnimeCard,
]);
Mutation$SaveMediaListEntry _parserFn$Mutation$SaveMediaListEntry(
        Map<String, dynamic> data) =>
    Mutation$SaveMediaListEntry.fromJson(data);
typedef OnMutationCompleted$Mutation$SaveMediaListEntry = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$SaveMediaListEntry?,
);

class Options$Mutation$SaveMediaListEntry
    extends graphql.MutationOptions<Mutation$SaveMediaListEntry> {
  Options$Mutation$SaveMediaListEntry({
    String? operationName,
    Variables$Mutation$SaveMediaListEntry? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SaveMediaListEntry? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$SaveMediaListEntry? onCompleted,
    graphql.OnMutationUpdate<Mutation$SaveMediaListEntry>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$SaveMediaListEntry(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationSaveMediaListEntry,
          parserFn: _parserFn$Mutation$SaveMediaListEntry,
        );

  final OnMutationCompleted$Mutation$SaveMediaListEntry? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$SaveMediaListEntry
    extends graphql.WatchQueryOptions<Mutation$SaveMediaListEntry> {
  WatchOptions$Mutation$SaveMediaListEntry({
    String? operationName,
    Variables$Mutation$SaveMediaListEntry? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$SaveMediaListEntry? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationSaveMediaListEntry,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$SaveMediaListEntry,
        );
}

extension ClientExtension$Mutation$SaveMediaListEntry on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$SaveMediaListEntry>>
      mutate$SaveMediaListEntry(
              [Options$Mutation$SaveMediaListEntry? options]) async =>
          await this.mutate(options ?? Options$Mutation$SaveMediaListEntry());
  graphql.ObservableQuery<
      Mutation$SaveMediaListEntry> watchMutation$SaveMediaListEntry(
          [WatchOptions$Mutation$SaveMediaListEntry? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$SaveMediaListEntry());
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry {
  Mutation$SaveMediaListEntry$SaveMediaListEntry({
    required this.id,
    required this.mediaId,
    this.status,
    this.score,
    this.progress,
    this.repeat,
    this.priority,
    this.private,
    this.notes,
    this.hiddenFromStatusLists,
    this.customLists,
    this.startedAt,
    this.completedAt,
    this.updatedAt,
    this.createdAt,
    this.media,
    this.$__typename = 'MediaList',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$mediaId = json['mediaId'];
    final l$status = json['status'];
    final l$score = json['score'];
    final l$progress = json['progress'];
    final l$repeat = json['repeat'];
    final l$priority = json['priority'];
    final l$private = json['private'];
    final l$notes = json['notes'];
    final l$hiddenFromStatusLists = json['hiddenFromStatusLists'];
    final l$customLists = json['customLists'];
    final l$startedAt = json['startedAt'];
    final l$completedAt = json['completedAt'];
    final l$updatedAt = json['updatedAt'];
    final l$createdAt = json['createdAt'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry(
      id: (l$id as int),
      mediaId: (l$mediaId as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      score: (l$score as num?)?.toDouble(),
      progress: (l$progress as int?),
      repeat: (l$repeat as int?),
      priority: (l$priority as int?),
      private: (l$private as bool?),
      notes: (l$notes as String?),
      hiddenFromStatusLists: (l$hiddenFromStatusLists as bool?),
      customLists: (l$customLists as dynamic?),
      startedAt: l$startedAt == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt.fromJson(
              (l$startedAt as Map<String, dynamic>)),
      completedAt: l$completedAt == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt.fromJson(
              (l$completedAt as Map<String, dynamic>)),
      updatedAt: (l$updatedAt as int?),
      createdAt: (l$createdAt as int?),
      media: l$media == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$media.fromJson(
              (l$media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int mediaId;

  final Enum$MediaListStatus? status;

  final double? score;

  final int? progress;

  final int? repeat;

  final int? priority;

  final bool? private;

  final String? notes;

  final bool? hiddenFromStatusLists;

  final dynamic? customLists;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt? startedAt;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt? completedAt;

  final int? updatedAt;

  final int? createdAt;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media? media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$mediaId = mediaId;
    _resultData['mediaId'] = l$mediaId;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$score = score;
    _resultData['score'] = l$score;
    final l$progress = progress;
    _resultData['progress'] = l$progress;
    final l$repeat = repeat;
    _resultData['repeat'] = l$repeat;
    final l$priority = priority;
    _resultData['priority'] = l$priority;
    final l$private = private;
    _resultData['private'] = l$private;
    final l$notes = notes;
    _resultData['notes'] = l$notes;
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    _resultData['hiddenFromStatusLists'] = l$hiddenFromStatusLists;
    final l$customLists = customLists;
    _resultData['customLists'] = l$customLists;
    final l$startedAt = startedAt;
    _resultData['startedAt'] = l$startedAt?.toJson();
    final l$completedAt = completedAt;
    _resultData['completedAt'] = l$completedAt?.toJson();
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$createdAt = createdAt;
    _resultData['createdAt'] = l$createdAt;
    final l$media = media;
    _resultData['media'] = l$media?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$mediaId = mediaId;
    final l$status = status;
    final l$score = score;
    final l$progress = progress;
    final l$repeat = repeat;
    final l$priority = priority;
    final l$private = private;
    final l$notes = notes;
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    final l$customLists = customLists;
    final l$startedAt = startedAt;
    final l$completedAt = completedAt;
    final l$updatedAt = updatedAt;
    final l$createdAt = createdAt;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$mediaId,
      l$status,
      l$score,
      l$progress,
      l$repeat,
      l$priority,
      l$private,
      l$notes,
      l$hiddenFromStatusLists,
      l$customLists,
      l$startedAt,
      l$completedAt,
      l$updatedAt,
      l$createdAt,
      l$media,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SaveMediaListEntry$SaveMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
      return false;
    }
    final l$progress = progress;
    final lOther$progress = other.progress;
    if (l$progress != lOther$progress) {
      return false;
    }
    final l$repeat = repeat;
    final lOther$repeat = other.repeat;
    if (l$repeat != lOther$repeat) {
      return false;
    }
    final l$priority = priority;
    final lOther$priority = other.priority;
    if (l$priority != lOther$priority) {
      return false;
    }
    final l$private = private;
    final lOther$private = other.private;
    if (l$private != lOther$private) {
      return false;
    }
    final l$notes = notes;
    final lOther$notes = other.notes;
    if (l$notes != lOther$notes) {
      return false;
    }
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    final lOther$hiddenFromStatusLists = other.hiddenFromStatusLists;
    if (l$hiddenFromStatusLists != lOther$hiddenFromStatusLists) {
      return false;
    }
    final l$customLists = customLists;
    final lOther$customLists = other.customLists;
    if (l$customLists != lOther$customLists) {
      return false;
    }
    final l$startedAt = startedAt;
    final lOther$startedAt = other.startedAt;
    if (l$startedAt != lOther$startedAt) {
      return false;
    }
    final l$completedAt = completedAt;
    final lOther$completedAt = other.completedAt;
    if (l$completedAt != lOther$completedAt) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
      return false;
    }
    final l$createdAt = createdAt;
    final lOther$createdAt = other.createdAt;
    if (l$createdAt != lOther$createdAt) {
      return false;
    }
    final l$media = media;
    final lOther$media = other.media;
    if (l$media != lOther$media) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry
    on Mutation$SaveMediaListEntry$SaveMediaListEntry {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<
          Mutation$SaveMediaListEntry$SaveMediaListEntry>
      get copyWith => CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry(
    Mutation$SaveMediaListEntry$SaveMediaListEntry instance,
    TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry;

  TRes call({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    double? score,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    dynamic? customLists,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt? startedAt,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt? completedAt,
    int? updatedAt,
    int? createdAt,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media? media,
    String? $__typename,
  });
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<TRes>
      get startedAt;
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<TRes>
      get completedAt;
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<TRes> get media;
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry _instance;

  final TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? mediaId = _undefined,
    Object? status = _undefined,
    Object? score = _undefined,
    Object? progress = _undefined,
    Object? repeat = _undefined,
    Object? priority = _undefined,
    Object? private = _undefined,
    Object? notes = _undefined,
    Object? hiddenFromStatusLists = _undefined,
    Object? customLists = _undefined,
    Object? startedAt = _undefined,
    Object? completedAt = _undefined,
    Object? updatedAt = _undefined,
    Object? createdAt = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        mediaId: mediaId == _undefined || mediaId == null
            ? _instance.mediaId
            : (mediaId as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        score: score == _undefined ? _instance.score : (score as double?),
        progress:
            progress == _undefined ? _instance.progress : (progress as int?),
        repeat: repeat == _undefined ? _instance.repeat : (repeat as int?),
        priority:
            priority == _undefined ? _instance.priority : (priority as int?),
        private: private == _undefined ? _instance.private : (private as bool?),
        notes: notes == _undefined ? _instance.notes : (notes as String?),
        hiddenFromStatusLists: hiddenFromStatusLists == _undefined
            ? _instance.hiddenFromStatusLists
            : (hiddenFromStatusLists as bool?),
        customLists: customLists == _undefined
            ? _instance.customLists
            : (customLists as dynamic?),
        startedAt: startedAt == _undefined
            ? _instance.startedAt
            : (startedAt
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt?),
        completedAt: completedAt == _undefined
            ? _instance.completedAt
            : (completedAt
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        media: media == _undefined
            ? _instance.media
            : (media as Mutation$SaveMediaListEntry$SaveMediaListEntry$media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<TRes>
      get startedAt {
    final local$startedAt = _instance.startedAt;
    return local$startedAt == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
            local$startedAt, (e) => call(startedAt: e));
  }

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<TRes>
      get completedAt {
    final local$completedAt = _instance.completedAt;
    return local$completedAt == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
            local$completedAt, (e) => call(completedAt: e));
  }

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<TRes>
      get media {
    final local$media = _instance.media;
    return local$media == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media.stub(
            _then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
            local$media, (e) => call(media: e));
  }
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry(this._res);

  TRes _res;

  call({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    double? score,
    int? progress,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    dynamic? customLists,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt? startedAt,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt? completedAt,
    int? updatedAt,
    int? createdAt,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media? media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<TRes>
      get startedAt =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt
              .stub(_res);

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<TRes>
      get completedAt =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt
              .stub(_res);

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<TRes>
      get media =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media.stub(
              _res);
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
      year: (l$year as int?),
      month: (l$month as int?),
      day: (l$day as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? year;

  final int? month;

  final int? day;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$year = year;
    _resultData['year'] = l$year;
    final l$month = month;
    _resultData['month'] = l$month;
    final l$day = day;
    _resultData['day'] = l$day;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$year = year;
    final l$month = month;
    final l$day = day;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$year,
      l$month,
      l$day,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$month = month;
    final lOther$month = other.month;
    if (l$month != lOther$month) {
      return false;
    }
    final l$day = day;
    final lOther$day = other.day;
    if (l$day != lOther$day) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt instance,
    TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt _instance;

  final TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$startedAt(
      this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
      year: (l$year as int?),
      month: (l$month as int?),
      day: (l$day as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? year;

  final int? month;

  final int? day;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$year = year;
    _resultData['year'] = l$year;
    final l$month = month;
    _resultData['month'] = l$month;
    final l$day = day;
    _resultData['day'] = l$day;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$year = year;
    final l$month = month;
    final l$day = day;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$year,
      l$month,
      l$day,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$month = month;
    final lOther$month = other.month;
    if (l$month != lOther$month) {
      return false;
    }
    final l$day = day;
    final lOther$day = other.day;
    if (l$day != lOther$day) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt instance,
    TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt _instance;

  final TRes Function(
      Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$completedAt(
      this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$media
    implements Fragment$AnimeCard {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$media({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.status,
    this.episodes,
    this.seasonYear,
    this.season,
    this.averageScore,
    this.meanScore,
    this.popularity,
    this.isAdult,
    required this.isFavourite,
    this.nextAiringEpisode,
    this.startDate,
    this.genres,
    this.$__typename = 'Media',
    this.siteUrl,
    this.mediaListEntry,
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$coverImage = json['coverImage'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$status = json['status'];
    final l$episodes = json['episodes'];
    final l$seasonYear = json['seasonYear'];
    final l$season = json['season'];
    final l$averageScore = json['averageScore'];
    final l$meanScore = json['meanScore'];
    final l$popularity = json['popularity'];
    final l$isAdult = json['isAdult'];
    final l$isFavourite = json['isFavourite'];
    final l$nextAiringEpisode = json['nextAiringEpisode'];
    final l$startDate = json['startDate'];
    final l$genres = json['genres'];
    final l$$__typename = json['__typename'];
    final l$siteUrl = json['siteUrl'];
    final l$mediaListEntry = json['mediaListEntry'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title.fromJson(
              (l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage
              .fromJson((l$coverImage as Map<String, dynamic>)),
      type: l$type == null ? null : fromJson$Enum$MediaType((l$type as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaStatus((l$status as String)),
      episodes: (l$episodes as int?),
      seasonYear: (l$seasonYear as int?),
      season: l$season == null
          ? null
          : fromJson$Enum$MediaSeason((l$season as String)),
      averageScore: (l$averageScore as int?),
      meanScore: (l$meanScore as int?),
      popularity: (l$popularity as int?),
      isAdult: (l$isAdult as bool?),
      isFavourite: (l$isFavourite as bool),
      nextAiringEpisode: l$nextAiringEpisode == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
              .fromJson((l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate
              .fromJson((l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      siteUrl: (l$siteUrl as String?),
      mediaListEntry: l$mediaListEntry == null
          ? null
          : Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry
              .fromJson((l$mediaListEntry as Map<String, dynamic>)),
    );
  }

  final int id;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title? title;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage?
      coverImage;

  final Enum$MediaType? type;

  final Enum$MediaFormat? format;

  final Enum$MediaStatus? status;

  final int? episodes;

  final int? seasonYear;

  final Enum$MediaSeason? season;

  final int? averageScore;

  final int? meanScore;

  final int? popularity;

  final bool? isAdult;

  final bool isFavourite;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode?
      nextAiringEpisode;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate?
      startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? siteUrl;

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry?
      mediaListEntry;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$title = title;
    _resultData['title'] = l$title?.toJson();
    final l$coverImage = coverImage;
    _resultData['coverImage'] = l$coverImage?.toJson();
    final l$type = type;
    _resultData['type'] = l$type == null ? null : toJson$Enum$MediaType(l$type);
    final l$format = format;
    _resultData['format'] =
        l$format == null ? null : toJson$Enum$MediaFormat(l$format);
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaStatus(l$status);
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$seasonYear = seasonYear;
    _resultData['seasonYear'] = l$seasonYear;
    final l$season = season;
    _resultData['season'] =
        l$season == null ? null : toJson$Enum$MediaSeason(l$season);
    final l$averageScore = averageScore;
    _resultData['averageScore'] = l$averageScore;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$popularity = popularity;
    _resultData['popularity'] = l$popularity;
    final l$isAdult = isAdult;
    _resultData['isAdult'] = l$isAdult;
    final l$isFavourite = isFavourite;
    _resultData['isFavourite'] = l$isFavourite;
    final l$nextAiringEpisode = nextAiringEpisode;
    _resultData['nextAiringEpisode'] = l$nextAiringEpisode?.toJson();
    final l$startDate = startDate;
    _resultData['startDate'] = l$startDate?.toJson();
    final l$genres = genres;
    _resultData['genres'] = l$genres?.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$mediaListEntry = mediaListEntry;
    _resultData['mediaListEntry'] = l$mediaListEntry?.toJson();
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$coverImage = coverImage;
    final l$type = type;
    final l$format = format;
    final l$status = status;
    final l$episodes = episodes;
    final l$seasonYear = seasonYear;
    final l$season = season;
    final l$averageScore = averageScore;
    final l$meanScore = meanScore;
    final l$popularity = popularity;
    final l$isAdult = isAdult;
    final l$isFavourite = isFavourite;
    final l$nextAiringEpisode = nextAiringEpisode;
    final l$startDate = startDate;
    final l$genres = genres;
    final l$$__typename = $__typename;
    final l$siteUrl = siteUrl;
    final l$mediaListEntry = mediaListEntry;
    return Object.hashAll([
      l$id,
      l$title,
      l$coverImage,
      l$type,
      l$format,
      l$status,
      l$episodes,
      l$seasonYear,
      l$season,
      l$averageScore,
      l$meanScore,
      l$popularity,
      l$isAdult,
      l$isFavourite,
      l$nextAiringEpisode,
      l$startDate,
      l$genres == null ? null : Object.hashAll(l$genres.map((v) => v)),
      l$$__typename,
      l$siteUrl,
      l$mediaListEntry,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SaveMediaListEntry$SaveMediaListEntry$media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$coverImage = coverImage;
    final lOther$coverImage = other.coverImage;
    if (l$coverImage != lOther$coverImage) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$format = format;
    final lOther$format = other.format;
    if (l$format != lOther$format) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
      return false;
    }
    final l$seasonYear = seasonYear;
    final lOther$seasonYear = other.seasonYear;
    if (l$seasonYear != lOther$seasonYear) {
      return false;
    }
    final l$season = season;
    final lOther$season = other.season;
    if (l$season != lOther$season) {
      return false;
    }
    final l$averageScore = averageScore;
    final lOther$averageScore = other.averageScore;
    if (l$averageScore != lOther$averageScore) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$popularity = popularity;
    final lOther$popularity = other.popularity;
    if (l$popularity != lOther$popularity) {
      return false;
    }
    final l$isAdult = isAdult;
    final lOther$isAdult = other.isAdult;
    if (l$isAdult != lOther$isAdult) {
      return false;
    }
    final l$isFavourite = isFavourite;
    final lOther$isFavourite = other.isFavourite;
    if (l$isFavourite != lOther$isFavourite) {
      return false;
    }
    final l$nextAiringEpisode = nextAiringEpisode;
    final lOther$nextAiringEpisode = other.nextAiringEpisode;
    if (l$nextAiringEpisode != lOther$nextAiringEpisode) {
      return false;
    }
    final l$startDate = startDate;
    final lOther$startDate = other.startDate;
    if (l$startDate != lOther$startDate) {
      return false;
    }
    final l$genres = genres;
    final lOther$genres = other.genres;
    if (l$genres != null && lOther$genres != null) {
      if (l$genres.length != lOther$genres.length) {
        return false;
      }
      for (int i = 0; i < l$genres.length; i++) {
        final l$genres$entry = l$genres[i];
        final lOther$genres$entry = lOther$genres[i];
        if (l$genres$entry != lOther$genres$entry) {
          return false;
        }
      }
    } else if (l$genres != lOther$genres) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
      return false;
    }
    final l$mediaListEntry = mediaListEntry;
    final lOther$mediaListEntry = other.mediaListEntry;
    if (l$mediaListEntry != lOther$mediaListEntry) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$media
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$media {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media instance,
    TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry$media) then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media;

  TRes call({
    int? id,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title? title,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage? coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    Enum$MediaStatus? status,
    int? episodes,
    int? seasonYear,
    Enum$MediaSeason? season,
    int? averageScore,
    int? meanScore,
    int? popularity,
    bool? isAdult,
    bool? isFavourite,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode?
        nextAiringEpisode,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? siteUrl,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry?
        mediaListEntry,
  });
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<TRes>
      get title;
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<TRes>
      get coverImage;
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
      TRes> get nextAiringEpisode;
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<TRes>
      get startDate;
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
      TRes> get mediaListEntry;
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media _instance;

  final TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry$media)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImage = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? status = _undefined,
    Object? episodes = _undefined,
    Object? seasonYear = _undefined,
    Object? season = _undefined,
    Object? averageScore = _undefined,
    Object? meanScore = _undefined,
    Object? popularity = _undefined,
    Object? isAdult = _undefined,
    Object? isFavourite = _undefined,
    Object? nextAiringEpisode = _undefined,
    Object? startDate = _undefined,
    Object? genres = _undefined,
    Object? $__typename = _undefined,
    Object? siteUrl = _undefined,
    Object? mediaListEntry = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage?),
        type: type == _undefined ? _instance.type : (type as Enum$MediaType?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaStatus?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        seasonYear: seasonYear == _undefined
            ? _instance.seasonYear
            : (seasonYear as int?),
        season: season == _undefined
            ? _instance.season
            : (season as Enum$MediaSeason?),
        averageScore: averageScore == _undefined
            ? _instance.averageScore
            : (averageScore as int?),
        meanScore:
            meanScore == _undefined ? _instance.meanScore : (meanScore as int?),
        popularity: popularity == _undefined
            ? _instance.popularity
            : (popularity as int?),
        isAdult: isAdult == _undefined ? _instance.isAdult : (isAdult as bool?),
        isFavourite: isFavourite == _undefined || isFavourite == null
            ? _instance.isFavourite
            : (isFavourite as bool),
        nextAiringEpisode: nextAiringEpisode == _undefined
            ? _instance.nextAiringEpisode
            : (nextAiringEpisode
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate?),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        mediaListEntry: mediaListEntry == _undefined
            ? _instance.mediaListEntry
            : (mediaListEntry
                as Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry?),
      ));

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<TRes>
      get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<TRes>
      get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
      TRes> get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<TRes>
      get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
      TRes> get mediaListEntry {
    final local$mediaListEntry = _instance.mediaListEntry;
    return local$mediaListEntry == null
        ? CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry
            .stub(_then(_instance))
        : CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
            local$mediaListEntry, (e) => call(mediaListEntry: e));
  }
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media<TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media(
      this._res);

  TRes _res;

  call({
    int? id,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title? title,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage? coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    Enum$MediaStatus? status,
    int? episodes,
    int? seasonYear,
    Enum$MediaSeason? season,
    int? averageScore,
    int? meanScore,
    int? popularity,
    bool? isAdult,
    bool? isFavourite,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode?
        nextAiringEpisode,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? siteUrl,
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry?
        mediaListEntry,
  }) =>
      _res;

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<TRes>
      get title =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title
              .stub(_res);

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<TRes>
      get coverImage =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage
              .stub(_res);

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
          TRes>
      get nextAiringEpisode =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
              .stub(_res);

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<TRes>
      get startDate =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate
              .stub(_res);

  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
          TRes>
      get mediaListEntry =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry
              .stub(_res);
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title
    implements Fragment$AnimeCard$title {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
      userPreferred: (l$userPreferred as String?),
      romaji: (l$romaji as String?),
      english: (l$english as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? userPreferred;

  final String? romaji;

  final String? english;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$userPreferred = userPreferred;
    _resultData['userPreferred'] = l$userPreferred;
    final l$romaji = romaji;
    _resultData['romaji'] = l$romaji;
    final l$english = english;
    _resultData['english'] = l$english;
    final l$native = native;
    _resultData['native'] = l$native;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$userPreferred = userPreferred;
    final l$romaji = romaji;
    final l$english = english;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$userPreferred,
      l$romaji,
      l$english,
      l$native,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$userPreferred = userPreferred;
    final lOther$userPreferred = other.userPreferred;
    if (l$userPreferred != lOther$userPreferred) {
      return false;
    }
    final l$romaji = romaji;
    final lOther$romaji = other.romaji;
    if (l$romaji != lOther$romaji) {
      return false;
    }
    final l$english = english;
    final lOther$english = other.english;
    if (l$english != lOther$english) {
      return false;
    }
    final l$native = native;
    final lOther$native = other.native;
    if (l$native != lOther$native) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title instance,
    TRes Function(Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title _instance;

  final TRes Function(
      Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
        userPreferred: userPreferred == _undefined
            ? _instance.userPreferred
            : (userPreferred as String?),
        romaji: romaji == _undefined ? _instance.romaji : (romaji as String?),
        english:
            english == _undefined ? _instance.english : (english as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$title(
      this._res);

  TRes _res;

  call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage
    implements Fragment$AnimeCard$coverImage {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
      extraLarge: (l$extraLarge as String?),
      large: (l$large as String?),
      color: (l$color as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? extraLarge;

  final String? large;

  final String? color;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$extraLarge = extraLarge;
    _resultData['extraLarge'] = l$extraLarge;
    final l$large = large;
    _resultData['large'] = l$large;
    final l$color = color;
    _resultData['color'] = l$color;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$extraLarge = extraLarge;
    final l$large = large;
    final l$color = color;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$extraLarge,
      l$large,
      l$color,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$extraLarge = extraLarge;
    final lOther$extraLarge = other.extraLarge;
    if (l$extraLarge != lOther$extraLarge) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
      return false;
    }
    final l$color = color;
    final lOther$color = other.color;
    if (l$color != lOther$color) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage instance,
    TRes Function(
            Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage
      _instance;

  final TRes Function(
      Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
        extraLarge: extraLarge == _undefined
            ? _instance.extraLarge
            : (extraLarge as String?),
        large: large == _undefined ? _instance.large : (large as String?),
        color: color == _undefined ? _instance.color : (color as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$coverImage(
      this._res);

  TRes _res;

  call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
    implements Fragment$AnimeCard$nextAiringEpisode {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
      airingAt: (l$airingAt as int),
      timeUntilAiring: (l$timeUntilAiring as int),
      episode: (l$episode as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int airingAt;

  final int timeUntilAiring;

  final int episode;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$airingAt = airingAt;
    _resultData['airingAt'] = l$airingAt;
    final l$timeUntilAiring = timeUntilAiring;
    _resultData['timeUntilAiring'] = l$timeUntilAiring;
    final l$episode = episode;
    _resultData['episode'] = l$episode;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$airingAt = airingAt;
    final l$timeUntilAiring = timeUntilAiring;
    final l$episode = episode;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$airingAt,
      l$timeUntilAiring,
      l$episode,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$airingAt = airingAt;
    final lOther$airingAt = other.airingAt;
    if (l$airingAt != lOther$airingAt) {
      return false;
    }
    final l$timeUntilAiring = timeUntilAiring;
    final lOther$timeUntilAiring = other.timeUntilAiring;
    if (l$timeUntilAiring != lOther$timeUntilAiring) {
      return false;
    }
    final l$episode = episode;
    final lOther$episode = other.episode;
    if (l$episode != lOther$episode) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
        instance,
    TRes Function(
            Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode
      _instance;

  final TRes Function(
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
        airingAt: airingAt == _undefined || airingAt == null
            ? _instance.airingAt
            : (airingAt as int),
        timeUntilAiring:
            timeUntilAiring == _undefined || timeUntilAiring == null
                ? _instance.timeUntilAiring
                : (timeUntilAiring as int),
        episode: episode == _undefined || episode == null
            ? _instance.episode
            : (episode as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$nextAiringEpisode(
      this._res);

  TRes _res;

  call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate
    implements Fragment$AnimeCard$startDate {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
      year: (l$year as int?),
      month: (l$month as int?),
      day: (l$day as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? year;

  final int? month;

  final int? day;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$year = year;
    _resultData['year'] = l$year;
    final l$month = month;
    _resultData['month'] = l$month;
    final l$day = day;
    _resultData['day'] = l$day;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$year = year;
    final l$month = month;
    final l$day = day;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$year,
      l$month,
      l$day,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$month = month;
    final lOther$month = other.month;
    if (l$month != lOther$month) {
      return false;
    }
    final l$day = day;
    final lOther$day = other.day;
    if (l$day != lOther$day) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate instance,
    TRes Function(
            Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate
      _instance;

  final TRes Function(
      Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$startDate(
      this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry {
  Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry({
    required this.id,
    this.$__typename = 'MediaList',
  });

  factory Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
      id: (l$id as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry
    on Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry {
  CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry>
      get copyWith =>
          CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
    TRes> {
  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
    Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry
        instance,
    TRes Function(
            Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry)
        then,
  ) = _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry;

  factory CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry;

  TRes call({
    int? id,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
            TRes> {
  _CopyWithImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry
      _instance;

  final TRes Function(
          Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
        TRes>
    implements
        CopyWith$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry<
            TRes> {
  _CopyWithStubImpl$Mutation$SaveMediaListEntry$SaveMediaListEntry$media$mediaListEntry(
      this._res);

  TRes _res;

  call({
    int? id,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Mutation$DeleteMediaListEntry {
  factory Variables$Mutation$DeleteMediaListEntry({required int id}) =>
      Variables$Mutation$DeleteMediaListEntry._({
        r'id': id,
      });

  Variables$Mutation$DeleteMediaListEntry._(this._$data);

  factory Variables$Mutation$DeleteMediaListEntry.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Mutation$DeleteMediaListEntry._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Mutation$DeleteMediaListEntry<
          Variables$Mutation$DeleteMediaListEntry>
      get copyWith => CopyWith$Variables$Mutation$DeleteMediaListEntry(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$DeleteMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Mutation$DeleteMediaListEntry<TRes> {
  factory CopyWith$Variables$Mutation$DeleteMediaListEntry(
    Variables$Mutation$DeleteMediaListEntry instance,
    TRes Function(Variables$Mutation$DeleteMediaListEntry) then,
  ) = _CopyWithImpl$Variables$Mutation$DeleteMediaListEntry;

  factory CopyWith$Variables$Mutation$DeleteMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$DeleteMediaListEntry;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Mutation$DeleteMediaListEntry<TRes>
    implements CopyWith$Variables$Mutation$DeleteMediaListEntry<TRes> {
  _CopyWithImpl$Variables$Mutation$DeleteMediaListEntry(
    this._instance,
    this._then,
  );

  final Variables$Mutation$DeleteMediaListEntry _instance;

  final TRes Function(Variables$Mutation$DeleteMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Mutation$DeleteMediaListEntry._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$DeleteMediaListEntry<TRes>
    implements CopyWith$Variables$Mutation$DeleteMediaListEntry<TRes> {
  _CopyWithStubImpl$Variables$Mutation$DeleteMediaListEntry(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Mutation$DeleteMediaListEntry {
  Mutation$DeleteMediaListEntry({
    this.DeleteMediaListEntry,
    this.$__typename = 'Mutation',
  });

  factory Mutation$DeleteMediaListEntry.fromJson(Map<String, dynamic> json) {
    final l$DeleteMediaListEntry = json['DeleteMediaListEntry'];
    final l$$__typename = json['__typename'];
    return Mutation$DeleteMediaListEntry(
      DeleteMediaListEntry: l$DeleteMediaListEntry == null
          ? null
          : Mutation$DeleteMediaListEntry$DeleteMediaListEntry.fromJson(
              (l$DeleteMediaListEntry as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$DeleteMediaListEntry$DeleteMediaListEntry?
      DeleteMediaListEntry;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$DeleteMediaListEntry = DeleteMediaListEntry;
    _resultData['DeleteMediaListEntry'] = l$DeleteMediaListEntry?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$DeleteMediaListEntry = DeleteMediaListEntry;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$DeleteMediaListEntry,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DeleteMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$DeleteMediaListEntry = DeleteMediaListEntry;
    final lOther$DeleteMediaListEntry = other.DeleteMediaListEntry;
    if (l$DeleteMediaListEntry != lOther$DeleteMediaListEntry) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$DeleteMediaListEntry
    on Mutation$DeleteMediaListEntry {
  CopyWith$Mutation$DeleteMediaListEntry<Mutation$DeleteMediaListEntry>
      get copyWith => CopyWith$Mutation$DeleteMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DeleteMediaListEntry<TRes> {
  factory CopyWith$Mutation$DeleteMediaListEntry(
    Mutation$DeleteMediaListEntry instance,
    TRes Function(Mutation$DeleteMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$DeleteMediaListEntry;

  factory CopyWith$Mutation$DeleteMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Mutation$DeleteMediaListEntry;

  TRes call({
    Mutation$DeleteMediaListEntry$DeleteMediaListEntry? DeleteMediaListEntry,
    String? $__typename,
  });
  CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes>
      get DeleteMediaListEntry;
}

class _CopyWithImpl$Mutation$DeleteMediaListEntry<TRes>
    implements CopyWith$Mutation$DeleteMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$DeleteMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$DeleteMediaListEntry _instance;

  final TRes Function(Mutation$DeleteMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? DeleteMediaListEntry = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$DeleteMediaListEntry(
        DeleteMediaListEntry: DeleteMediaListEntry == _undefined
            ? _instance.DeleteMediaListEntry
            : (DeleteMediaListEntry
                as Mutation$DeleteMediaListEntry$DeleteMediaListEntry?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes>
      get DeleteMediaListEntry {
    final local$DeleteMediaListEntry = _instance.DeleteMediaListEntry;
    return local$DeleteMediaListEntry == null
        ? CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry.stub(
            _then(_instance))
        : CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
            local$DeleteMediaListEntry, (e) => call(DeleteMediaListEntry: e));
  }
}

class _CopyWithStubImpl$Mutation$DeleteMediaListEntry<TRes>
    implements CopyWith$Mutation$DeleteMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$DeleteMediaListEntry(this._res);

  TRes _res;

  call({
    Mutation$DeleteMediaListEntry$DeleteMediaListEntry? DeleteMediaListEntry,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes>
      get DeleteMediaListEntry =>
          CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry.stub(
              _res);
}

const documentNodeMutationDeleteMediaListEntry = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'DeleteMediaListEntry'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'DeleteMediaListEntry'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'deleted'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Mutation$DeleteMediaListEntry _parserFn$Mutation$DeleteMediaListEntry(
        Map<String, dynamic> data) =>
    Mutation$DeleteMediaListEntry.fromJson(data);
typedef OnMutationCompleted$Mutation$DeleteMediaListEntry = FutureOr<void>
    Function(
  Map<String, dynamic>?,
  Mutation$DeleteMediaListEntry?,
);

class Options$Mutation$DeleteMediaListEntry
    extends graphql.MutationOptions<Mutation$DeleteMediaListEntry> {
  Options$Mutation$DeleteMediaListEntry({
    String? operationName,
    required Variables$Mutation$DeleteMediaListEntry variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteMediaListEntry? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$DeleteMediaListEntry? onCompleted,
    graphql.OnMutationUpdate<Mutation$DeleteMediaListEntry>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$DeleteMediaListEntry(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationDeleteMediaListEntry,
          parserFn: _parserFn$Mutation$DeleteMediaListEntry,
        );

  final OnMutationCompleted$Mutation$DeleteMediaListEntry?
      onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$DeleteMediaListEntry
    extends graphql.WatchQueryOptions<Mutation$DeleteMediaListEntry> {
  WatchOptions$Mutation$DeleteMediaListEntry({
    String? operationName,
    required Variables$Mutation$DeleteMediaListEntry variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$DeleteMediaListEntry? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationDeleteMediaListEntry,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$DeleteMediaListEntry,
        );
}

extension ClientExtension$Mutation$DeleteMediaListEntry
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$DeleteMediaListEntry>>
      mutate$DeleteMediaListEntry(
              Options$Mutation$DeleteMediaListEntry options) async =>
          await this.mutate(options);
  graphql.ObservableQuery<Mutation$DeleteMediaListEntry>
      watchMutation$DeleteMediaListEntry(
              WatchOptions$Mutation$DeleteMediaListEntry options) =>
          this.watchMutation(options);
}

class Mutation$DeleteMediaListEntry$DeleteMediaListEntry {
  Mutation$DeleteMediaListEntry$DeleteMediaListEntry({
    this.deleted,
    this.$__typename = 'Deleted',
  });

  factory Mutation$DeleteMediaListEntry$DeleteMediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$deleted = json['deleted'];
    final l$$__typename = json['__typename'];
    return Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
      deleted: (l$deleted as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final bool? deleted;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$deleted = deleted;
    _resultData['deleted'] = l$deleted;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$deleted = deleted;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$deleted,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$DeleteMediaListEntry$DeleteMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$deleted = deleted;
    final lOther$deleted = other.deleted;
    if (l$deleted != lOther$deleted) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$DeleteMediaListEntry$DeleteMediaListEntry
    on Mutation$DeleteMediaListEntry$DeleteMediaListEntry {
  CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<
          Mutation$DeleteMediaListEntry$DeleteMediaListEntry>
      get copyWith =>
          CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<
    TRes> {
  factory CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
    Mutation$DeleteMediaListEntry$DeleteMediaListEntry instance,
    TRes Function(Mutation$DeleteMediaListEntry$DeleteMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$DeleteMediaListEntry$DeleteMediaListEntry;

  factory CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$DeleteMediaListEntry$DeleteMediaListEntry;

  TRes call({
    bool? deleted,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes>
    implements
        CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$DeleteMediaListEntry$DeleteMediaListEntry _instance;

  final TRes Function(Mutation$DeleteMediaListEntry$DeleteMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? deleted = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
        deleted: deleted == _undefined ? _instance.deleted : (deleted as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes>
    implements
        CopyWith$Mutation$DeleteMediaListEntry$DeleteMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$DeleteMediaListEntry$DeleteMediaListEntry(
      this._res);

  TRes _res;

  call({
    bool? deleted,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Mutation$ToggleFavourite {
  factory Variables$Mutation$ToggleFavourite({int? animeId}) =>
      Variables$Mutation$ToggleFavourite._({
        if (animeId != null) r'animeId': animeId,
      });

  Variables$Mutation$ToggleFavourite._(this._$data);

  factory Variables$Mutation$ToggleFavourite.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('animeId')) {
      final l$animeId = data['animeId'];
      result$data['animeId'] = (l$animeId as int?);
    }
    return Variables$Mutation$ToggleFavourite._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get animeId => (_$data['animeId'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('animeId')) {
      final l$animeId = animeId;
      result$data['animeId'] = l$animeId;
    }
    return result$data;
  }

  CopyWith$Variables$Mutation$ToggleFavourite<
          Variables$Mutation$ToggleFavourite>
      get copyWith => CopyWith$Variables$Mutation$ToggleFavourite(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$ToggleFavourite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$animeId = animeId;
    final lOther$animeId = other.animeId;
    if (_$data.containsKey('animeId') != other._$data.containsKey('animeId')) {
      return false;
    }
    if (l$animeId != lOther$animeId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$animeId = animeId;
    return Object.hashAll(
        [_$data.containsKey('animeId') ? l$animeId : const {}]);
  }
}

abstract class CopyWith$Variables$Mutation$ToggleFavourite<TRes> {
  factory CopyWith$Variables$Mutation$ToggleFavourite(
    Variables$Mutation$ToggleFavourite instance,
    TRes Function(Variables$Mutation$ToggleFavourite) then,
  ) = _CopyWithImpl$Variables$Mutation$ToggleFavourite;

  factory CopyWith$Variables$Mutation$ToggleFavourite.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ToggleFavourite;

  TRes call({int? animeId});
}

class _CopyWithImpl$Variables$Mutation$ToggleFavourite<TRes>
    implements CopyWith$Variables$Mutation$ToggleFavourite<TRes> {
  _CopyWithImpl$Variables$Mutation$ToggleFavourite(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ToggleFavourite _instance;

  final TRes Function(Variables$Mutation$ToggleFavourite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? animeId = _undefined}) =>
      _then(Variables$Mutation$ToggleFavourite._({
        ..._instance._$data,
        if (animeId != _undefined) 'animeId': (animeId as int?),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ToggleFavourite<TRes>
    implements CopyWith$Variables$Mutation$ToggleFavourite<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ToggleFavourite(this._res);

  TRes _res;

  call({int? animeId}) => _res;
}

class Mutation$ToggleFavourite {
  Mutation$ToggleFavourite({
    this.ToggleFavourite,
    this.$__typename = 'Mutation',
  });

  factory Mutation$ToggleFavourite.fromJson(Map<String, dynamic> json) {
    final l$ToggleFavourite = json['ToggleFavourite'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleFavourite(
      ToggleFavourite: l$ToggleFavourite == null
          ? null
          : Mutation$ToggleFavourite$ToggleFavourite.fromJson(
              (l$ToggleFavourite as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleFavourite$ToggleFavourite? ToggleFavourite;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$ToggleFavourite = ToggleFavourite;
    _resultData['ToggleFavourite'] = l$ToggleFavourite?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$ToggleFavourite = ToggleFavourite;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$ToggleFavourite,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ToggleFavourite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ToggleFavourite = ToggleFavourite;
    final lOther$ToggleFavourite = other.ToggleFavourite;
    if (l$ToggleFavourite != lOther$ToggleFavourite) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$ToggleFavourite
    on Mutation$ToggleFavourite {
  CopyWith$Mutation$ToggleFavourite<Mutation$ToggleFavourite> get copyWith =>
      CopyWith$Mutation$ToggleFavourite(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$ToggleFavourite<TRes> {
  factory CopyWith$Mutation$ToggleFavourite(
    Mutation$ToggleFavourite instance,
    TRes Function(Mutation$ToggleFavourite) then,
  ) = _CopyWithImpl$Mutation$ToggleFavourite;

  factory CopyWith$Mutation$ToggleFavourite.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleFavourite;

  TRes call({
    Mutation$ToggleFavourite$ToggleFavourite? ToggleFavourite,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleFavourite$ToggleFavourite<TRes> get ToggleFavourite;
}

class _CopyWithImpl$Mutation$ToggleFavourite<TRes>
    implements CopyWith$Mutation$ToggleFavourite<TRes> {
  _CopyWithImpl$Mutation$ToggleFavourite(
    this._instance,
    this._then,
  );

  final Mutation$ToggleFavourite _instance;

  final TRes Function(Mutation$ToggleFavourite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? ToggleFavourite = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleFavourite(
        ToggleFavourite: ToggleFavourite == _undefined
            ? _instance.ToggleFavourite
            : (ToggleFavourite as Mutation$ToggleFavourite$ToggleFavourite?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleFavourite$ToggleFavourite<TRes> get ToggleFavourite {
    final local$ToggleFavourite = _instance.ToggleFavourite;
    return local$ToggleFavourite == null
        ? CopyWith$Mutation$ToggleFavourite$ToggleFavourite.stub(
            _then(_instance))
        : CopyWith$Mutation$ToggleFavourite$ToggleFavourite(
            local$ToggleFavourite, (e) => call(ToggleFavourite: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleFavourite<TRes>
    implements CopyWith$Mutation$ToggleFavourite<TRes> {
  _CopyWithStubImpl$Mutation$ToggleFavourite(this._res);

  TRes _res;

  call({
    Mutation$ToggleFavourite$ToggleFavourite? ToggleFavourite,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleFavourite$ToggleFavourite<TRes> get ToggleFavourite =>
      CopyWith$Mutation$ToggleFavourite$ToggleFavourite.stub(_res);
}

const documentNodeMutationToggleFavourite = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ToggleFavourite'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'animeId')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'ToggleFavourite'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'animeId'),
            value: VariableNode(name: NameNode(value: 'animeId')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'anime'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'nodes'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'id'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ]),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Mutation$ToggleFavourite _parserFn$Mutation$ToggleFavourite(
        Map<String, dynamic> data) =>
    Mutation$ToggleFavourite.fromJson(data);
typedef OnMutationCompleted$Mutation$ToggleFavourite = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ToggleFavourite?,
);

class Options$Mutation$ToggleFavourite
    extends graphql.MutationOptions<Mutation$ToggleFavourite> {
  Options$Mutation$ToggleFavourite({
    String? operationName,
    Variables$Mutation$ToggleFavourite? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleFavourite? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ToggleFavourite? onCompleted,
    graphql.OnMutationUpdate<Mutation$ToggleFavourite>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null
                        ? null
                        : _parserFn$Mutation$ToggleFavourite(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationToggleFavourite,
          parserFn: _parserFn$Mutation$ToggleFavourite,
        );

  final OnMutationCompleted$Mutation$ToggleFavourite? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ToggleFavourite
    extends graphql.WatchQueryOptions<Mutation$ToggleFavourite> {
  WatchOptions$Mutation$ToggleFavourite({
    String? operationName,
    Variables$Mutation$ToggleFavourite? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ToggleFavourite? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationToggleFavourite,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ToggleFavourite,
        );
}

extension ClientExtension$Mutation$ToggleFavourite on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ToggleFavourite>> mutate$ToggleFavourite(
          [Options$Mutation$ToggleFavourite? options]) async =>
      await this.mutate(options ?? Options$Mutation$ToggleFavourite());
  graphql.ObservableQuery<
      Mutation$ToggleFavourite> watchMutation$ToggleFavourite(
          [WatchOptions$Mutation$ToggleFavourite? options]) =>
      this.watchMutation(options ?? WatchOptions$Mutation$ToggleFavourite());
}

class Mutation$ToggleFavourite$ToggleFavourite {
  Mutation$ToggleFavourite$ToggleFavourite({
    this.anime,
    this.$__typename = 'Favourites',
  });

  factory Mutation$ToggleFavourite$ToggleFavourite.fromJson(
      Map<String, dynamic> json) {
    final l$anime = json['anime'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleFavourite$ToggleFavourite(
      anime: l$anime == null
          ? null
          : Mutation$ToggleFavourite$ToggleFavourite$anime.fromJson(
              (l$anime as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$ToggleFavourite$ToggleFavourite$anime? anime;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$anime = anime;
    _resultData['anime'] = l$anime?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$anime = anime;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$anime,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ToggleFavourite$ToggleFavourite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$anime = anime;
    final lOther$anime = other.anime;
    if (l$anime != lOther$anime) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$ToggleFavourite$ToggleFavourite
    on Mutation$ToggleFavourite$ToggleFavourite {
  CopyWith$Mutation$ToggleFavourite$ToggleFavourite<
          Mutation$ToggleFavourite$ToggleFavourite>
      get copyWith => CopyWith$Mutation$ToggleFavourite$ToggleFavourite(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleFavourite$ToggleFavourite<TRes> {
  factory CopyWith$Mutation$ToggleFavourite$ToggleFavourite(
    Mutation$ToggleFavourite$ToggleFavourite instance,
    TRes Function(Mutation$ToggleFavourite$ToggleFavourite) then,
  ) = _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite;

  factory CopyWith$Mutation$ToggleFavourite$ToggleFavourite.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite;

  TRes call({
    Mutation$ToggleFavourite$ToggleFavourite$anime? anime,
    String? $__typename,
  });
  CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes> get anime;
}

class _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite<TRes>
    implements CopyWith$Mutation$ToggleFavourite$ToggleFavourite<TRes> {
  _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite(
    this._instance,
    this._then,
  );

  final Mutation$ToggleFavourite$ToggleFavourite _instance;

  final TRes Function(Mutation$ToggleFavourite$ToggleFavourite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? anime = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleFavourite$ToggleFavourite(
        anime: anime == _undefined
            ? _instance.anime
            : (anime as Mutation$ToggleFavourite$ToggleFavourite$anime?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes> get anime {
    final local$anime = _instance.anime;
    return local$anime == null
        ? CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime.stub(
            _then(_instance))
        : CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime(
            local$anime, (e) => call(anime: e));
  }
}

class _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite<TRes>
    implements CopyWith$Mutation$ToggleFavourite$ToggleFavourite<TRes> {
  _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite(this._res);

  TRes _res;

  call({
    Mutation$ToggleFavourite$ToggleFavourite$anime? anime,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes> get anime =>
      CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime.stub(_res);
}

class Mutation$ToggleFavourite$ToggleFavourite$anime {
  Mutation$ToggleFavourite$ToggleFavourite$anime({
    this.nodes,
    this.$__typename = 'MediaConnection',
  });

  factory Mutation$ToggleFavourite$ToggleFavourite$anime.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleFavourite$ToggleFavourite$anime(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Mutation$ToggleFavourite$ToggleFavourite$anime$nodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Mutation$ToggleFavourite$ToggleFavourite$anime$nodes?>? nodes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$nodes = nodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$nodes == null ? null : Object.hashAll(l$nodes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ToggleFavourite$ToggleFavourite$anime ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$nodes = nodes;
    final lOther$nodes = other.nodes;
    if (l$nodes != null && lOther$nodes != null) {
      if (l$nodes.length != lOther$nodes.length) {
        return false;
      }
      for (int i = 0; i < l$nodes.length; i++) {
        final l$nodes$entry = l$nodes[i];
        final lOther$nodes$entry = lOther$nodes[i];
        if (l$nodes$entry != lOther$nodes$entry) {
          return false;
        }
      }
    } else if (l$nodes != lOther$nodes) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$ToggleFavourite$ToggleFavourite$anime
    on Mutation$ToggleFavourite$ToggleFavourite$anime {
  CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<
          Mutation$ToggleFavourite$ToggleFavourite$anime>
      get copyWith => CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes> {
  factory CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime(
    Mutation$ToggleFavourite$ToggleFavourite$anime instance,
    TRes Function(Mutation$ToggleFavourite$ToggleFavourite$anime) then,
  ) = _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite$anime;

  factory CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite$anime;

  TRes call({
    List<Mutation$ToggleFavourite$ToggleFavourite$anime$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Mutation$ToggleFavourite$ToggleFavourite$anime$nodes?>? Function(
              Iterable<
                  CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<
                      Mutation$ToggleFavourite$ToggleFavourite$anime$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes>
    implements CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes> {
  _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite$anime(
    this._instance,
    this._then,
  );

  final Mutation$ToggleFavourite$ToggleFavourite$anime _instance;

  final TRes Function(Mutation$ToggleFavourite$ToggleFavourite$anime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleFavourite$ToggleFavourite$anime(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes as List<
                Mutation$ToggleFavourite$ToggleFavourite$anime$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Mutation$ToggleFavourite$ToggleFavourite$anime$nodes?>? Function(
                  Iterable<
                      CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<
                          Mutation$ToggleFavourite$ToggleFavourite$anime$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes>
    implements CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime<TRes> {
  _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite$anime(this._res);

  TRes _res;

  call({
    List<Mutation$ToggleFavourite$ToggleFavourite$anime$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Mutation$ToggleFavourite$ToggleFavourite$anime$nodes {
  Mutation$ToggleFavourite$ToggleFavourite$anime$nodes({
    required this.id,
    this.$__typename = 'Media',
  });

  factory Mutation$ToggleFavourite$ToggleFavourite$anime$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
      id: (l$id as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$ToggleFavourite$ToggleFavourite$anime$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes
    on Mutation$ToggleFavourite$ToggleFavourite$anime$nodes {
  CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<
          Mutation$ToggleFavourite$ToggleFavourite$anime$nodes>
      get copyWith =>
          CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<
    TRes> {
  factory CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
    Mutation$ToggleFavourite$ToggleFavourite$anime$nodes instance,
    TRes Function(Mutation$ToggleFavourite$ToggleFavourite$anime$nodes) then,
  ) = _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes;

  factory CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes;

  TRes call({
    int? id,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<TRes>
    implements
        CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<TRes> {
  _CopyWithImpl$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
    this._instance,
    this._then,
  );

  final Mutation$ToggleFavourite$ToggleFavourite$anime$nodes _instance;

  final TRes Function(Mutation$ToggleFavourite$ToggleFavourite$anime$nodes)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<
        TRes>
    implements
        CopyWith$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes<TRes> {
  _CopyWithStubImpl$Mutation$ToggleFavourite$ToggleFavourite$anime$nodes(
      this._res);

  TRes _res;

  call({
    int? id,
    String? $__typename,
  }) =>
      _res;
}
