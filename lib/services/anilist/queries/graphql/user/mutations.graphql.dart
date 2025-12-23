import '../schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Variables$Mutation$UpdateProgress {
  factory Variables$Mutation$UpdateProgress({
    required int mediaId,
    required int progress,
  }) =>
      Variables$Mutation$UpdateProgress._({
        r'mediaId': mediaId,
        r'progress': progress,
      });

  Variables$Mutation$UpdateProgress._(this._$data);

  factory Variables$Mutation$UpdateProgress.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$mediaId = data['mediaId'];
    result$data['mediaId'] = (l$mediaId as int);
    final l$progress = data['progress'];
    result$data['progress'] = (l$progress as int);
    return Variables$Mutation$UpdateProgress._(result$data);
  }

  Map<String, dynamic> _$data;

  int get mediaId => (_$data['mediaId'] as int);

  int get progress => (_$data['progress'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$mediaId = mediaId;
    result$data['mediaId'] = l$mediaId;
    final l$progress = progress;
    result$data['progress'] = l$progress;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateProgress<Variables$Mutation$UpdateProgress>
      get copyWith => CopyWith$Variables$Mutation$UpdateProgress(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateProgress ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$progress = progress;
    final lOther$progress = other.progress;
    if (l$progress != lOther$progress) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$mediaId = mediaId;
    final l$progress = progress;
    return Object.hashAll([
      l$mediaId,
      l$progress,
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateProgress<TRes> {
  factory CopyWith$Variables$Mutation$UpdateProgress(
    Variables$Mutation$UpdateProgress instance,
    TRes Function(Variables$Mutation$UpdateProgress) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateProgress;

  factory CopyWith$Variables$Mutation$UpdateProgress.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateProgress;

  TRes call({
    int? mediaId,
    int? progress,
  });
}

class _CopyWithImpl$Variables$Mutation$UpdateProgress<TRes>
    implements CopyWith$Variables$Mutation$UpdateProgress<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateProgress(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateProgress _instance;

  final TRes Function(Variables$Mutation$UpdateProgress) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mediaId = _undefined,
    Object? progress = _undefined,
  }) =>
      _then(Variables$Mutation$UpdateProgress._({
        ..._instance._$data,
        if (mediaId != _undefined && mediaId != null)
          'mediaId': (mediaId as int),
        if (progress != _undefined && progress != null)
          'progress': (progress as int),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateProgress<TRes>
    implements CopyWith$Variables$Mutation$UpdateProgress<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateProgress(this._res);

  TRes _res;

  call({
    int? mediaId,
    int? progress,
  }) =>
      _res;
}

class Mutation$UpdateProgress {
  Mutation$UpdateProgress({
    this.SaveMediaListEntry,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateProgress.fromJson(Map<String, dynamic> json) {
    final l$SaveMediaListEntry = json['SaveMediaListEntry'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateProgress(
      SaveMediaListEntry: l$SaveMediaListEntry == null
          ? null
          : Mutation$UpdateProgress$SaveMediaListEntry.fromJson(
              (l$SaveMediaListEntry as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateProgress$SaveMediaListEntry? SaveMediaListEntry;

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
    if (other is! Mutation$UpdateProgress || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$UpdateProgress on Mutation$UpdateProgress {
  CopyWith$Mutation$UpdateProgress<Mutation$UpdateProgress> get copyWith =>
      CopyWith$Mutation$UpdateProgress(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateProgress<TRes> {
  factory CopyWith$Mutation$UpdateProgress(
    Mutation$UpdateProgress instance,
    TRes Function(Mutation$UpdateProgress) then,
  ) = _CopyWithImpl$Mutation$UpdateProgress;

  factory CopyWith$Mutation$UpdateProgress.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateProgress;

  TRes call({
    Mutation$UpdateProgress$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<TRes>
      get SaveMediaListEntry;
}

class _CopyWithImpl$Mutation$UpdateProgress<TRes>
    implements CopyWith$Mutation$UpdateProgress<TRes> {
  _CopyWithImpl$Mutation$UpdateProgress(
    this._instance,
    this._then,
  );

  final Mutation$UpdateProgress _instance;

  final TRes Function(Mutation$UpdateProgress) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? SaveMediaListEntry = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateProgress(
        SaveMediaListEntry: SaveMediaListEntry == _undefined
            ? _instance.SaveMediaListEntry
            : (SaveMediaListEntry
                as Mutation$UpdateProgress$SaveMediaListEntry?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<TRes>
      get SaveMediaListEntry {
    final local$SaveMediaListEntry = _instance.SaveMediaListEntry;
    return local$SaveMediaListEntry == null
        ? CopyWith$Mutation$UpdateProgress$SaveMediaListEntry.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateProgress$SaveMediaListEntry(
            local$SaveMediaListEntry, (e) => call(SaveMediaListEntry: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateProgress<TRes>
    implements CopyWith$Mutation$UpdateProgress<TRes> {
  _CopyWithStubImpl$Mutation$UpdateProgress(this._res);

  TRes _res;

  call({
    Mutation$UpdateProgress$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<TRes>
      get SaveMediaListEntry =>
          CopyWith$Mutation$UpdateProgress$SaveMediaListEntry.stub(_res);
}

const documentNodeMutationUpdateProgress = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateProgress'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'mediaId')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'progress')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
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
            name: NameNode(value: 'mediaId'),
            value: VariableNode(name: NameNode(value: 'mediaId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'progress'),
            value: VariableNode(name: NameNode(value: 'progress')),
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
            name: NameNode(value: 'progress'),
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
Mutation$UpdateProgress _parserFn$Mutation$UpdateProgress(
        Map<String, dynamic> data) =>
    Mutation$UpdateProgress.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateProgress = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateProgress?,
);

class Options$Mutation$UpdateProgress
    extends graphql.MutationOptions<Mutation$UpdateProgress> {
  Options$Mutation$UpdateProgress({
    String? operationName,
    required Variables$Mutation$UpdateProgress variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateProgress? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateProgress? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateProgress>? update,
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
                        : _parserFn$Mutation$UpdateProgress(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateProgress,
          parserFn: _parserFn$Mutation$UpdateProgress,
        );

  final OnMutationCompleted$Mutation$UpdateProgress? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateProgress
    extends graphql.WatchQueryOptions<Mutation$UpdateProgress> {
  WatchOptions$Mutation$UpdateProgress({
    String? operationName,
    required Variables$Mutation$UpdateProgress variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateProgress? typedOptimisticResult,
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
          document: documentNodeMutationUpdateProgress,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateProgress,
        );
}

extension ClientExtension$Mutation$UpdateProgress on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateProgress>> mutate$UpdateProgress(
          Options$Mutation$UpdateProgress options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$UpdateProgress> watchMutation$UpdateProgress(
          WatchOptions$Mutation$UpdateProgress options) =>
      this.watchMutation(options);
}

class Mutation$UpdateProgress$SaveMediaListEntry {
  Mutation$UpdateProgress$SaveMediaListEntry({
    required this.id,
    this.progress,
    this.$__typename = 'MediaList',
  });

  factory Mutation$UpdateProgress$SaveMediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$progress = json['progress'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateProgress$SaveMediaListEntry(
      id: (l$id as int),
      progress: (l$progress as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int? progress;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$progress = progress;
    _resultData['progress'] = l$progress;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$progress = progress;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$progress,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateProgress$SaveMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$progress = progress;
    final lOther$progress = other.progress;
    if (l$progress != lOther$progress) {
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

extension UtilityExtension$Mutation$UpdateProgress$SaveMediaListEntry
    on Mutation$UpdateProgress$SaveMediaListEntry {
  CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<
          Mutation$UpdateProgress$SaveMediaListEntry>
      get copyWith => CopyWith$Mutation$UpdateProgress$SaveMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<TRes> {
  factory CopyWith$Mutation$UpdateProgress$SaveMediaListEntry(
    Mutation$UpdateProgress$SaveMediaListEntry instance,
    TRes Function(Mutation$UpdateProgress$SaveMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$UpdateProgress$SaveMediaListEntry;

  factory CopyWith$Mutation$UpdateProgress$SaveMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateProgress$SaveMediaListEntry;

  TRes call({
    int? id,
    int? progress,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$UpdateProgress$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$UpdateProgress$SaveMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$UpdateProgress$SaveMediaListEntry _instance;

  final TRes Function(Mutation$UpdateProgress$SaveMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? progress = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateProgress$SaveMediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        progress:
            progress == _undefined ? _instance.progress : (progress as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$UpdateProgress$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$UpdateProgress$SaveMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$UpdateProgress$SaveMediaListEntry(this._res);

  TRes _res;

  call({
    int? id,
    int? progress,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Mutation$UpdateStatus {
  factory Variables$Mutation$UpdateStatus({
    required int mediaId,
    required Enum$MediaListStatus status,
  }) =>
      Variables$Mutation$UpdateStatus._({
        r'mediaId': mediaId,
        r'status': status,
      });

  Variables$Mutation$UpdateStatus._(this._$data);

  factory Variables$Mutation$UpdateStatus.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$mediaId = data['mediaId'];
    result$data['mediaId'] = (l$mediaId as int);
    final l$status = data['status'];
    result$data['status'] = fromJson$Enum$MediaListStatus((l$status as String));
    return Variables$Mutation$UpdateStatus._(result$data);
  }

  Map<String, dynamic> _$data;

  int get mediaId => (_$data['mediaId'] as int);

  Enum$MediaListStatus get status => (_$data['status'] as Enum$MediaListStatus);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$mediaId = mediaId;
    result$data['mediaId'] = l$mediaId;
    final l$status = status;
    result$data['status'] = toJson$Enum$MediaListStatus(l$status);
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateStatus<Variables$Mutation$UpdateStatus>
      get copyWith => CopyWith$Variables$Mutation$UpdateStatus(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateStatus ||
        runtimeType != other.runtimeType) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$mediaId = mediaId;
    final l$status = status;
    return Object.hashAll([
      l$mediaId,
      l$status,
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateStatus<TRes> {
  factory CopyWith$Variables$Mutation$UpdateStatus(
    Variables$Mutation$UpdateStatus instance,
    TRes Function(Variables$Mutation$UpdateStatus) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateStatus;

  factory CopyWith$Variables$Mutation$UpdateStatus.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateStatus;

  TRes call({
    int? mediaId,
    Enum$MediaListStatus? status,
  });
}

class _CopyWithImpl$Variables$Mutation$UpdateStatus<TRes>
    implements CopyWith$Variables$Mutation$UpdateStatus<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateStatus(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateStatus _instance;

  final TRes Function(Variables$Mutation$UpdateStatus) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mediaId = _undefined,
    Object? status = _undefined,
  }) =>
      _then(Variables$Mutation$UpdateStatus._({
        ..._instance._$data,
        if (mediaId != _undefined && mediaId != null)
          'mediaId': (mediaId as int),
        if (status != _undefined && status != null)
          'status': (status as Enum$MediaListStatus),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateStatus<TRes>
    implements CopyWith$Variables$Mutation$UpdateStatus<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateStatus(this._res);

  TRes _res;

  call({
    int? mediaId,
    Enum$MediaListStatus? status,
  }) =>
      _res;
}

class Mutation$UpdateStatus {
  Mutation$UpdateStatus({
    this.SaveMediaListEntry,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateStatus.fromJson(Map<String, dynamic> json) {
    final l$SaveMediaListEntry = json['SaveMediaListEntry'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateStatus(
      SaveMediaListEntry: l$SaveMediaListEntry == null
          ? null
          : Mutation$UpdateStatus$SaveMediaListEntry.fromJson(
              (l$SaveMediaListEntry as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateStatus$SaveMediaListEntry? SaveMediaListEntry;

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
    if (other is! Mutation$UpdateStatus || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$UpdateStatus on Mutation$UpdateStatus {
  CopyWith$Mutation$UpdateStatus<Mutation$UpdateStatus> get copyWith =>
      CopyWith$Mutation$UpdateStatus(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateStatus<TRes> {
  factory CopyWith$Mutation$UpdateStatus(
    Mutation$UpdateStatus instance,
    TRes Function(Mutation$UpdateStatus) then,
  ) = _CopyWithImpl$Mutation$UpdateStatus;

  factory CopyWith$Mutation$UpdateStatus.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateStatus;

  TRes call({
    Mutation$UpdateStatus$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<TRes>
      get SaveMediaListEntry;
}

class _CopyWithImpl$Mutation$UpdateStatus<TRes>
    implements CopyWith$Mutation$UpdateStatus<TRes> {
  _CopyWithImpl$Mutation$UpdateStatus(
    this._instance,
    this._then,
  );

  final Mutation$UpdateStatus _instance;

  final TRes Function(Mutation$UpdateStatus) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? SaveMediaListEntry = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateStatus(
        SaveMediaListEntry: SaveMediaListEntry == _undefined
            ? _instance.SaveMediaListEntry
            : (SaveMediaListEntry as Mutation$UpdateStatus$SaveMediaListEntry?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<TRes>
      get SaveMediaListEntry {
    final local$SaveMediaListEntry = _instance.SaveMediaListEntry;
    return local$SaveMediaListEntry == null
        ? CopyWith$Mutation$UpdateStatus$SaveMediaListEntry.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateStatus$SaveMediaListEntry(
            local$SaveMediaListEntry, (e) => call(SaveMediaListEntry: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateStatus<TRes>
    implements CopyWith$Mutation$UpdateStatus<TRes> {
  _CopyWithStubImpl$Mutation$UpdateStatus(this._res);

  TRes _res;

  call({
    Mutation$UpdateStatus$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<TRes>
      get SaveMediaListEntry =>
          CopyWith$Mutation$UpdateStatus$SaveMediaListEntry.stub(_res);
}

const documentNodeMutationUpdateStatus = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateStatus'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'mediaId')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'status')),
        type: NamedTypeNode(
          name: NameNode(value: 'MediaListStatus'),
          isNonNull: true,
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
            name: NameNode(value: 'mediaId'),
            value: VariableNode(name: NameNode(value: 'mediaId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'status'),
            value: VariableNode(name: NameNode(value: 'status')),
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
            name: NameNode(value: 'status'),
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
Mutation$UpdateStatus _parserFn$Mutation$UpdateStatus(
        Map<String, dynamic> data) =>
    Mutation$UpdateStatus.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateStatus = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateStatus?,
);

class Options$Mutation$UpdateStatus
    extends graphql.MutationOptions<Mutation$UpdateStatus> {
  Options$Mutation$UpdateStatus({
    String? operationName,
    required Variables$Mutation$UpdateStatus variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateStatus? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateStatus? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateStatus>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdateStatus(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateStatus,
          parserFn: _parserFn$Mutation$UpdateStatus,
        );

  final OnMutationCompleted$Mutation$UpdateStatus? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateStatus
    extends graphql.WatchQueryOptions<Mutation$UpdateStatus> {
  WatchOptions$Mutation$UpdateStatus({
    String? operationName,
    required Variables$Mutation$UpdateStatus variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateStatus? typedOptimisticResult,
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
          document: documentNodeMutationUpdateStatus,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateStatus,
        );
}

extension ClientExtension$Mutation$UpdateStatus on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateStatus>> mutate$UpdateStatus(
          Options$Mutation$UpdateStatus options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$UpdateStatus> watchMutation$UpdateStatus(
          WatchOptions$Mutation$UpdateStatus options) =>
      this.watchMutation(options);
}

class Mutation$UpdateStatus$SaveMediaListEntry {
  Mutation$UpdateStatus$SaveMediaListEntry({
    required this.id,
    this.status,
    this.$__typename = 'MediaList',
  });

  factory Mutation$UpdateStatus$SaveMediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$status = json['status'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateStatus$SaveMediaListEntry(
      id: (l$id as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$MediaListStatus? status;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$status = status;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$status,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateStatus$SaveMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
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

extension UtilityExtension$Mutation$UpdateStatus$SaveMediaListEntry
    on Mutation$UpdateStatus$SaveMediaListEntry {
  CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<
          Mutation$UpdateStatus$SaveMediaListEntry>
      get copyWith => CopyWith$Mutation$UpdateStatus$SaveMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<TRes> {
  factory CopyWith$Mutation$UpdateStatus$SaveMediaListEntry(
    Mutation$UpdateStatus$SaveMediaListEntry instance,
    TRes Function(Mutation$UpdateStatus$SaveMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$UpdateStatus$SaveMediaListEntry;

  factory CopyWith$Mutation$UpdateStatus$SaveMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateStatus$SaveMediaListEntry;

  TRes call({
    int? id,
    Enum$MediaListStatus? status,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$UpdateStatus$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$UpdateStatus$SaveMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$UpdateStatus$SaveMediaListEntry _instance;

  final TRes Function(Mutation$UpdateStatus$SaveMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? status = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateStatus$SaveMediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$UpdateStatus$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$UpdateStatus$SaveMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$UpdateStatus$SaveMediaListEntry(this._res);

  TRes _res;

  call({
    int? id,
    Enum$MediaListStatus? status,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Mutation$UpdateScore {
  factory Variables$Mutation$UpdateScore({
    required int mediaId,
    required double score,
  }) =>
      Variables$Mutation$UpdateScore._({
        r'mediaId': mediaId,
        r'score': score,
      });

  Variables$Mutation$UpdateScore._(this._$data);

  factory Variables$Mutation$UpdateScore.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$mediaId = data['mediaId'];
    result$data['mediaId'] = (l$mediaId as int);
    final l$score = data['score'];
    result$data['score'] = (l$score as num).toDouble();
    return Variables$Mutation$UpdateScore._(result$data);
  }

  Map<String, dynamic> _$data;

  int get mediaId => (_$data['mediaId'] as int);

  double get score => (_$data['score'] as double);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$mediaId = mediaId;
    result$data['mediaId'] = l$mediaId;
    final l$score = score;
    result$data['score'] = l$score;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateScore<Variables$Mutation$UpdateScore>
      get copyWith => CopyWith$Variables$Mutation$UpdateScore(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdateScore ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$mediaId = mediaId;
    final l$score = score;
    return Object.hashAll([
      l$mediaId,
      l$score,
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateScore<TRes> {
  factory CopyWith$Variables$Mutation$UpdateScore(
    Variables$Mutation$UpdateScore instance,
    TRes Function(Variables$Mutation$UpdateScore) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateScore;

  factory CopyWith$Variables$Mutation$UpdateScore.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateScore;

  TRes call({
    int? mediaId,
    double? score,
  });
}

class _CopyWithImpl$Variables$Mutation$UpdateScore<TRes>
    implements CopyWith$Variables$Mutation$UpdateScore<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateScore(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateScore _instance;

  final TRes Function(Variables$Mutation$UpdateScore) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mediaId = _undefined,
    Object? score = _undefined,
  }) =>
      _then(Variables$Mutation$UpdateScore._({
        ..._instance._$data,
        if (mediaId != _undefined && mediaId != null)
          'mediaId': (mediaId as int),
        if (score != _undefined && score != null) 'score': (score as double),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateScore<TRes>
    implements CopyWith$Variables$Mutation$UpdateScore<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateScore(this._res);

  TRes _res;

  call({
    int? mediaId,
    double? score,
  }) =>
      _res;
}

class Mutation$UpdateScore {
  Mutation$UpdateScore({
    this.SaveMediaListEntry,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdateScore.fromJson(Map<String, dynamic> json) {
    final l$SaveMediaListEntry = json['SaveMediaListEntry'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateScore(
      SaveMediaListEntry: l$SaveMediaListEntry == null
          ? null
          : Mutation$UpdateScore$SaveMediaListEntry.fromJson(
              (l$SaveMediaListEntry as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdateScore$SaveMediaListEntry? SaveMediaListEntry;

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
    if (other is! Mutation$UpdateScore || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Mutation$UpdateScore on Mutation$UpdateScore {
  CopyWith$Mutation$UpdateScore<Mutation$UpdateScore> get copyWith =>
      CopyWith$Mutation$UpdateScore(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateScore<TRes> {
  factory CopyWith$Mutation$UpdateScore(
    Mutation$UpdateScore instance,
    TRes Function(Mutation$UpdateScore) then,
  ) = _CopyWithImpl$Mutation$UpdateScore;

  factory CopyWith$Mutation$UpdateScore.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateScore;

  TRes call({
    Mutation$UpdateScore$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  });
  CopyWith$Mutation$UpdateScore$SaveMediaListEntry<TRes> get SaveMediaListEntry;
}

class _CopyWithImpl$Mutation$UpdateScore<TRes>
    implements CopyWith$Mutation$UpdateScore<TRes> {
  _CopyWithImpl$Mutation$UpdateScore(
    this._instance,
    this._then,
  );

  final Mutation$UpdateScore _instance;

  final TRes Function(Mutation$UpdateScore) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? SaveMediaListEntry = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateScore(
        SaveMediaListEntry: SaveMediaListEntry == _undefined
            ? _instance.SaveMediaListEntry
            : (SaveMediaListEntry as Mutation$UpdateScore$SaveMediaListEntry?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Mutation$UpdateScore$SaveMediaListEntry<TRes>
      get SaveMediaListEntry {
    final local$SaveMediaListEntry = _instance.SaveMediaListEntry;
    return local$SaveMediaListEntry == null
        ? CopyWith$Mutation$UpdateScore$SaveMediaListEntry.stub(
            _then(_instance))
        : CopyWith$Mutation$UpdateScore$SaveMediaListEntry(
            local$SaveMediaListEntry, (e) => call(SaveMediaListEntry: e));
  }
}

class _CopyWithStubImpl$Mutation$UpdateScore<TRes>
    implements CopyWith$Mutation$UpdateScore<TRes> {
  _CopyWithStubImpl$Mutation$UpdateScore(this._res);

  TRes _res;

  call({
    Mutation$UpdateScore$SaveMediaListEntry? SaveMediaListEntry,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Mutation$UpdateScore$SaveMediaListEntry<TRes>
      get SaveMediaListEntry =>
          CopyWith$Mutation$UpdateScore$SaveMediaListEntry.stub(_res);
}

const documentNodeMutationUpdateScore = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateScore'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'mediaId')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'score')),
        type: NamedTypeNode(
          name: NameNode(value: 'Float'),
          isNonNull: true,
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
            name: NameNode(value: 'mediaId'),
            value: VariableNode(name: NameNode(value: 'mediaId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'score'),
            value: VariableNode(name: NameNode(value: 'score')),
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
            name: NameNode(value: 'score'),
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
Mutation$UpdateScore _parserFn$Mutation$UpdateScore(
        Map<String, dynamic> data) =>
    Mutation$UpdateScore.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateScore = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateScore?,
);

class Options$Mutation$UpdateScore
    extends graphql.MutationOptions<Mutation$UpdateScore> {
  Options$Mutation$UpdateScore({
    String? operationName,
    required Variables$Mutation$UpdateScore variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateScore? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateScore? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateScore>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdateScore(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateScore,
          parserFn: _parserFn$Mutation$UpdateScore,
        );

  final OnMutationCompleted$Mutation$UpdateScore? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateScore
    extends graphql.WatchQueryOptions<Mutation$UpdateScore> {
  WatchOptions$Mutation$UpdateScore({
    String? operationName,
    required Variables$Mutation$UpdateScore variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateScore? typedOptimisticResult,
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
          document: documentNodeMutationUpdateScore,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateScore,
        );
}

extension ClientExtension$Mutation$UpdateScore on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateScore>> mutate$UpdateScore(
          Options$Mutation$UpdateScore options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$UpdateScore> watchMutation$UpdateScore(
          WatchOptions$Mutation$UpdateScore options) =>
      this.watchMutation(options);
}

class Mutation$UpdateScore$SaveMediaListEntry {
  Mutation$UpdateScore$SaveMediaListEntry({
    required this.id,
    this.score,
    this.$__typename = 'MediaList',
  });

  factory Mutation$UpdateScore$SaveMediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$score = json['score'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateScore$SaveMediaListEntry(
      id: (l$id as int),
      score: (l$score as num?)?.toDouble(),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final double? score;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$score = score;
    _resultData['score'] = l$score;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$score = score;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$score,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdateScore$SaveMediaListEntry ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
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

extension UtilityExtension$Mutation$UpdateScore$SaveMediaListEntry
    on Mutation$UpdateScore$SaveMediaListEntry {
  CopyWith$Mutation$UpdateScore$SaveMediaListEntry<
          Mutation$UpdateScore$SaveMediaListEntry>
      get copyWith => CopyWith$Mutation$UpdateScore$SaveMediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Mutation$UpdateScore$SaveMediaListEntry<TRes> {
  factory CopyWith$Mutation$UpdateScore$SaveMediaListEntry(
    Mutation$UpdateScore$SaveMediaListEntry instance,
    TRes Function(Mutation$UpdateScore$SaveMediaListEntry) then,
  ) = _CopyWithImpl$Mutation$UpdateScore$SaveMediaListEntry;

  factory CopyWith$Mutation$UpdateScore$SaveMediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateScore$SaveMediaListEntry;

  TRes call({
    int? id,
    double? score,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$UpdateScore$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$UpdateScore$SaveMediaListEntry<TRes> {
  _CopyWithImpl$Mutation$UpdateScore$SaveMediaListEntry(
    this._instance,
    this._then,
  );

  final Mutation$UpdateScore$SaveMediaListEntry _instance;

  final TRes Function(Mutation$UpdateScore$SaveMediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? score = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateScore$SaveMediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        score: score == _undefined ? _instance.score : (score as double?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$UpdateScore$SaveMediaListEntry<TRes>
    implements CopyWith$Mutation$UpdateScore$SaveMediaListEntry<TRes> {
  _CopyWithStubImpl$Mutation$UpdateScore$SaveMediaListEntry(this._res);

  TRes _res;

  call({
    int? id,
    double? score,
    String? $__typename,
  }) =>
      _res;
}
