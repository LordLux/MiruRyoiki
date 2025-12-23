import '../common/fragments.graphql.dart';
import '../schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Query$GetCurrentUser {
  Query$GetCurrentUser({
    this.Viewer,
    this.$__typename = 'Query',
  });

  factory Query$GetCurrentUser.fromJson(Map<String, dynamic> json) {
    final l$Viewer = json['Viewer'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUser(
      Viewer: l$Viewer == null
          ? null
          : Query$GetCurrentUser$Viewer.fromJson(
              (l$Viewer as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetCurrentUser$Viewer? Viewer;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Viewer = Viewer;
    _resultData['Viewer'] = l$Viewer?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Viewer = Viewer;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Viewer,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUser || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Viewer = Viewer;
    final lOther$Viewer = other.Viewer;
    if (l$Viewer != lOther$Viewer) {
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

extension UtilityExtension$Query$GetCurrentUser on Query$GetCurrentUser {
  CopyWith$Query$GetCurrentUser<Query$GetCurrentUser> get copyWith =>
      CopyWith$Query$GetCurrentUser(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetCurrentUser<TRes> {
  factory CopyWith$Query$GetCurrentUser(
    Query$GetCurrentUser instance,
    TRes Function(Query$GetCurrentUser) then,
  ) = _CopyWithImpl$Query$GetCurrentUser;

  factory CopyWith$Query$GetCurrentUser.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUser;

  TRes call({
    Query$GetCurrentUser$Viewer? Viewer,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUser$Viewer<TRes> get Viewer;
}

class _CopyWithImpl$Query$GetCurrentUser<TRes>
    implements CopyWith$Query$GetCurrentUser<TRes> {
  _CopyWithImpl$Query$GetCurrentUser(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUser _instance;

  final TRes Function(Query$GetCurrentUser) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Viewer = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUser(
        Viewer: Viewer == _undefined
            ? _instance.Viewer
            : (Viewer as Query$GetCurrentUser$Viewer?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUser$Viewer<TRes> get Viewer {
    final local$Viewer = _instance.Viewer;
    return local$Viewer == null
        ? CopyWith$Query$GetCurrentUser$Viewer.stub(_then(_instance))
        : CopyWith$Query$GetCurrentUser$Viewer(
            local$Viewer, (e) => call(Viewer: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUser<TRes>
    implements CopyWith$Query$GetCurrentUser<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUser(this._res);

  TRes _res;

  call({
    Query$GetCurrentUser$Viewer? Viewer,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUser$Viewer<TRes> get Viewer =>
      CopyWith$Query$GetCurrentUser$Viewer.stub(_res);
}

const documentNodeQueryGetCurrentUser = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetCurrentUser'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Viewer'),
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
            name: NameNode(value: 'name'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'avatar'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'large'),
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
            name: NameNode(value: 'bannerImage'),
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
Query$GetCurrentUser _parserFn$Query$GetCurrentUser(
        Map<String, dynamic> data) =>
    Query$GetCurrentUser.fromJson(data);
typedef OnQueryComplete$Query$GetCurrentUser = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetCurrentUser?,
);

class Options$Query$GetCurrentUser
    extends graphql.QueryOptions<Query$GetCurrentUser> {
  Options$Query$GetCurrentUser({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCurrentUser? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetCurrentUser? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null ? null : _parserFn$Query$GetCurrentUser(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetCurrentUser,
          parserFn: _parserFn$Query$GetCurrentUser,
        );

  final OnQueryComplete$Query$GetCurrentUser? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetCurrentUser
    extends graphql.WatchQueryOptions<Query$GetCurrentUser> {
  WatchOptions$Query$GetCurrentUser({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCurrentUser? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetCurrentUser,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetCurrentUser,
        );
}

class FetchMoreOptions$Query$GetCurrentUser extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetCurrentUser(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetCurrentUser,
        );
}

extension ClientExtension$Query$GetCurrentUser on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetCurrentUser>> query$GetCurrentUser(
          [Options$Query$GetCurrentUser? options]) async =>
      await this.query(options ?? Options$Query$GetCurrentUser());
  graphql.ObservableQuery<Query$GetCurrentUser> watchQuery$GetCurrentUser(
          [WatchOptions$Query$GetCurrentUser? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetCurrentUser());
  void writeQuery$GetCurrentUser({
    required Query$GetCurrentUser data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation:
                graphql.Operation(document: documentNodeQueryGetCurrentUser)),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetCurrentUser? readQuery$GetCurrentUser({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetCurrentUser)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetCurrentUser.fromJson(result);
  }
}

class Query$GetCurrentUser$Viewer {
  Query$GetCurrentUser$Viewer({
    required this.id,
    required this.name,
    this.avatar,
    this.bannerImage,
    this.$__typename = 'User',
  });

  factory Query$GetCurrentUser$Viewer.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$avatar = json['avatar'];
    final l$bannerImage = json['bannerImage'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUser$Viewer(
      id: (l$id as int),
      name: (l$name as String),
      avatar: l$avatar == null
          ? null
          : Query$GetCurrentUser$Viewer$avatar.fromJson(
              (l$avatar as Map<String, dynamic>)),
      bannerImage: (l$bannerImage as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final Query$GetCurrentUser$Viewer$avatar? avatar;

  final String? bannerImage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$avatar = avatar;
    _resultData['avatar'] = l$avatar?.toJson();
    final l$bannerImage = bannerImage;
    _resultData['bannerImage'] = l$bannerImage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$avatar = avatar;
    final l$bannerImage = bannerImage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$avatar,
      l$bannerImage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUser$Viewer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$avatar = avatar;
    final lOther$avatar = other.avatar;
    if (l$avatar != lOther$avatar) {
      return false;
    }
    final l$bannerImage = bannerImage;
    final lOther$bannerImage = other.bannerImage;
    if (l$bannerImage != lOther$bannerImage) {
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

extension UtilityExtension$Query$GetCurrentUser$Viewer
    on Query$GetCurrentUser$Viewer {
  CopyWith$Query$GetCurrentUser$Viewer<Query$GetCurrentUser$Viewer>
      get copyWith => CopyWith$Query$GetCurrentUser$Viewer(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUser$Viewer<TRes> {
  factory CopyWith$Query$GetCurrentUser$Viewer(
    Query$GetCurrentUser$Viewer instance,
    TRes Function(Query$GetCurrentUser$Viewer) then,
  ) = _CopyWithImpl$Query$GetCurrentUser$Viewer;

  factory CopyWith$Query$GetCurrentUser$Viewer.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUser$Viewer;

  TRes call({
    int? id,
    String? name,
    Query$GetCurrentUser$Viewer$avatar? avatar,
    String? bannerImage,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUser$Viewer$avatar<TRes> get avatar;
}

class _CopyWithImpl$Query$GetCurrentUser$Viewer<TRes>
    implements CopyWith$Query$GetCurrentUser$Viewer<TRes> {
  _CopyWithImpl$Query$GetCurrentUser$Viewer(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUser$Viewer _instance;

  final TRes Function(Query$GetCurrentUser$Viewer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? avatar = _undefined,
    Object? bannerImage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUser$Viewer(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        avatar: avatar == _undefined
            ? _instance.avatar
            : (avatar as Query$GetCurrentUser$Viewer$avatar?),
        bannerImage: bannerImage == _undefined
            ? _instance.bannerImage
            : (bannerImage as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUser$Viewer$avatar<TRes> get avatar {
    final local$avatar = _instance.avatar;
    return local$avatar == null
        ? CopyWith$Query$GetCurrentUser$Viewer$avatar.stub(_then(_instance))
        : CopyWith$Query$GetCurrentUser$Viewer$avatar(
            local$avatar, (e) => call(avatar: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUser$Viewer<TRes>
    implements CopyWith$Query$GetCurrentUser$Viewer<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUser$Viewer(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    Query$GetCurrentUser$Viewer$avatar? avatar,
    String? bannerImage,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUser$Viewer$avatar<TRes> get avatar =>
      CopyWith$Query$GetCurrentUser$Viewer$avatar.stub(_res);
}

class Query$GetCurrentUser$Viewer$avatar {
  Query$GetCurrentUser$Viewer$avatar({
    this.large,
    this.$__typename = 'UserAvatar',
  });

  factory Query$GetCurrentUser$Viewer$avatar.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUser$Viewer$avatar(
      large: (l$large as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUser$Viewer$avatar ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
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

extension UtilityExtension$Query$GetCurrentUser$Viewer$avatar
    on Query$GetCurrentUser$Viewer$avatar {
  CopyWith$Query$GetCurrentUser$Viewer$avatar<
          Query$GetCurrentUser$Viewer$avatar>
      get copyWith => CopyWith$Query$GetCurrentUser$Viewer$avatar(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUser$Viewer$avatar<TRes> {
  factory CopyWith$Query$GetCurrentUser$Viewer$avatar(
    Query$GetCurrentUser$Viewer$avatar instance,
    TRes Function(Query$GetCurrentUser$Viewer$avatar) then,
  ) = _CopyWithImpl$Query$GetCurrentUser$Viewer$avatar;

  factory CopyWith$Query$GetCurrentUser$Viewer$avatar.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUser$Viewer$avatar;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUser$Viewer$avatar<TRes>
    implements CopyWith$Query$GetCurrentUser$Viewer$avatar<TRes> {
  _CopyWithImpl$Query$GetCurrentUser$Viewer$avatar(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUser$Viewer$avatar _instance;

  final TRes Function(Query$GetCurrentUser$Viewer$avatar) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUser$Viewer$avatar(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUser$Viewer$avatar<TRes>
    implements CopyWith$Query$GetCurrentUser$Viewer$avatar<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUser$Viewer$avatar(this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData {
  Query$GetCurrentUserData({
    this.Viewer,
    this.$__typename = 'Query',
  });

  factory Query$GetCurrentUserData.fromJson(Map<String, dynamic> json) {
    final l$Viewer = json['Viewer'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData(
      Viewer: l$Viewer == null
          ? null
          : Query$GetCurrentUserData$Viewer.fromJson(
              (l$Viewer as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetCurrentUserData$Viewer? Viewer;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Viewer = Viewer;
    _resultData['Viewer'] = l$Viewer?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Viewer = Viewer;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Viewer,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$Viewer = Viewer;
    final lOther$Viewer = other.Viewer;
    if (l$Viewer != lOther$Viewer) {
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

extension UtilityExtension$Query$GetCurrentUserData
    on Query$GetCurrentUserData {
  CopyWith$Query$GetCurrentUserData<Query$GetCurrentUserData> get copyWith =>
      CopyWith$Query$GetCurrentUserData(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetCurrentUserData<TRes> {
  factory CopyWith$Query$GetCurrentUserData(
    Query$GetCurrentUserData instance,
    TRes Function(Query$GetCurrentUserData) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData;

  factory CopyWith$Query$GetCurrentUserData.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData;

  TRes call({
    Query$GetCurrentUserData$Viewer? Viewer,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer<TRes> get Viewer;
}

class _CopyWithImpl$Query$GetCurrentUserData<TRes>
    implements CopyWith$Query$GetCurrentUserData<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData _instance;

  final TRes Function(Query$GetCurrentUserData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Viewer = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData(
        Viewer: Viewer == _undefined
            ? _instance.Viewer
            : (Viewer as Query$GetCurrentUserData$Viewer?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer<TRes> get Viewer {
    final local$Viewer = _instance.Viewer;
    return local$Viewer == null
        ? CopyWith$Query$GetCurrentUserData$Viewer.stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer(
            local$Viewer, (e) => call(Viewer: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData<TRes>
    implements CopyWith$Query$GetCurrentUserData<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData(this._res);

  TRes _res;

  call({
    Query$GetCurrentUserData$Viewer? Viewer,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer<TRes> get Viewer =>
      CopyWith$Query$GetCurrentUserData$Viewer.stub(_res);
}

const documentNodeQueryGetCurrentUserData = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetCurrentUserData'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Viewer'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'about'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'siteUrl'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'options'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'titleLanguage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'displayAdultContent'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'airingNotifications'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'profileColor'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'timezone'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'activityMergeTime'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'restrictMessagesToFollowing'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'staffNameLanguage'),
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
            name: NameNode(value: 'favourites'),
            alias: null,
            arguments: [],
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
                name: NameNode(value: 'characters'),
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
                        name: NameNode(value: 'name'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'full'),
                            alias: null,
                            arguments: [],
                            directives: [],
                            selectionSet: null,
                          ),
                          FieldNode(
                            name: NameNode(value: 'native'),
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
                        name: NameNode(value: 'image'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'large'),
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
                        name: NameNode(value: 'siteUrl'),
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
                name: NameNode(value: 'staff'),
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
                        name: NameNode(value: 'name'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'full'),
                            alias: null,
                            arguments: [],
                            directives: [],
                            selectionSet: null,
                          ),
                          FieldNode(
                            name: NameNode(value: 'native'),
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
                        name: NameNode(value: 'image'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'large'),
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
                        name: NameNode(value: 'siteUrl'),
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
                name: NameNode(value: 'studios'),
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
                        name: NameNode(value: 'name'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'siteUrl'),
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
            name: NameNode(value: 'stats'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'activityHistory'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'date'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'amount'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'level'),
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
            name: NameNode(value: 'statistics'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'anime'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'count'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'meanScore'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'standardDeviation'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'minutesWatched'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'episodesWatched'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'genres'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FieldNode(
                        name: NameNode(value: 'genre'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'count'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'meanScore'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'minutesWatched'),
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
                    name: NameNode(value: 'tags'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FieldNode(
                        name: NameNode(value: 'tag'),
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
                            name: NameNode(value: 'name'),
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
                        name: NameNode(value: 'count'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'meanScore'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'minutesWatched'),
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
                    name: NameNode(value: 'formats'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FieldNode(
                        name: NameNode(value: 'format'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'count'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'meanScore'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'minutesWatched'),
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
                    name: NameNode(value: 'statuses'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FieldNode(
                        name: NameNode(value: 'status'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'count'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'meanScore'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'minutesWatched'),
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
            name: NameNode(value: 'donatorTier'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
          FieldNode(
            name: NameNode(value: 'donatorBadge'),
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
            name: NameNode(value: 'updatedAt'),
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
  fragmentDefinitionAnimeCard,
]);
Query$GetCurrentUserData _parserFn$Query$GetCurrentUserData(
        Map<String, dynamic> data) =>
    Query$GetCurrentUserData.fromJson(data);
typedef OnQueryComplete$Query$GetCurrentUserData = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetCurrentUserData?,
);

class Options$Query$GetCurrentUserData
    extends graphql.QueryOptions<Query$GetCurrentUserData> {
  Options$Query$GetCurrentUserData({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCurrentUserData? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetCurrentUserData? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null
                        ? null
                        : _parserFn$Query$GetCurrentUserData(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetCurrentUserData,
          parserFn: _parserFn$Query$GetCurrentUserData,
        );

  final OnQueryComplete$Query$GetCurrentUserData? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetCurrentUserData
    extends graphql.WatchQueryOptions<Query$GetCurrentUserData> {
  WatchOptions$Query$GetCurrentUserData({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCurrentUserData? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetCurrentUserData,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetCurrentUserData,
        );
}

class FetchMoreOptions$Query$GetCurrentUserData
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetCurrentUserData(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetCurrentUserData,
        );
}

extension ClientExtension$Query$GetCurrentUserData on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetCurrentUserData>>
      query$GetCurrentUserData(
              [Options$Query$GetCurrentUserData? options]) async =>
          await this.query(options ?? Options$Query$GetCurrentUserData());
  graphql.ObservableQuery<Query$GetCurrentUserData>
      watchQuery$GetCurrentUserData(
              [WatchOptions$Query$GetCurrentUserData? options]) =>
          this.watchQuery(options ?? WatchOptions$Query$GetCurrentUserData());
  void writeQuery$GetCurrentUserData({
    required Query$GetCurrentUserData data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation: graphql.Operation(
                document: documentNodeQueryGetCurrentUserData)),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetCurrentUserData? readQuery$GetCurrentUserData(
      {bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetCurrentUserData)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetCurrentUserData.fromJson(result);
  }
}

class Query$GetCurrentUserData$Viewer {
  Query$GetCurrentUserData$Viewer({
    this.about,
    this.siteUrl,
    this.options,
    this.favourites,
    this.stats,
    this.statistics,
    this.donatorTier,
    this.donatorBadge,
    this.createdAt,
    this.updatedAt,
    this.$__typename = 'User',
  });

  factory Query$GetCurrentUserData$Viewer.fromJson(Map<String, dynamic> json) {
    final l$about = json['about'];
    final l$siteUrl = json['siteUrl'];
    final l$options = json['options'];
    final l$favourites = json['favourites'];
    final l$stats = json['stats'];
    final l$statistics = json['statistics'];
    final l$donatorTier = json['donatorTier'];
    final l$donatorBadge = json['donatorBadge'];
    final l$createdAt = json['createdAt'];
    final l$updatedAt = json['updatedAt'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer(
      about: (l$about as String?),
      siteUrl: (l$siteUrl as String?),
      options: l$options == null
          ? null
          : Query$GetCurrentUserData$Viewer$options.fromJson(
              (l$options as Map<String, dynamic>)),
      favourites: l$favourites == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites.fromJson(
              (l$favourites as Map<String, dynamic>)),
      stats: l$stats == null
          ? null
          : Query$GetCurrentUserData$Viewer$stats.fromJson(
              (l$stats as Map<String, dynamic>)),
      statistics: l$statistics == null
          ? null
          : Query$GetCurrentUserData$Viewer$statistics.fromJson(
              (l$statistics as Map<String, dynamic>)),
      donatorTier: (l$donatorTier as int?),
      donatorBadge: (l$donatorBadge as String?),
      createdAt: (l$createdAt as int?),
      updatedAt: (l$updatedAt as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? about;

  final String? siteUrl;

  final Query$GetCurrentUserData$Viewer$options? options;

  final Query$GetCurrentUserData$Viewer$favourites? favourites;

  @Deprecated('Deprecated. Replaced with statistics field.')
  final Query$GetCurrentUserData$Viewer$stats? stats;

  final Query$GetCurrentUserData$Viewer$statistics? statistics;

  final int? donatorTier;

  final String? donatorBadge;

  final int? createdAt;

  final int? updatedAt;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$about = about;
    _resultData['about'] = l$about;
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$options = options;
    _resultData['options'] = l$options?.toJson();
    final l$favourites = favourites;
    _resultData['favourites'] = l$favourites?.toJson();
    final l$stats = stats;
    _resultData['stats'] = l$stats?.toJson();
    final l$statistics = statistics;
    _resultData['statistics'] = l$statistics?.toJson();
    final l$donatorTier = donatorTier;
    _resultData['donatorTier'] = l$donatorTier;
    final l$donatorBadge = donatorBadge;
    _resultData['donatorBadge'] = l$donatorBadge;
    final l$createdAt = createdAt;
    _resultData['createdAt'] = l$createdAt;
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$about = about;
    final l$siteUrl = siteUrl;
    final l$options = options;
    final l$favourites = favourites;
    final l$stats = stats;
    final l$statistics = statistics;
    final l$donatorTier = donatorTier;
    final l$donatorBadge = donatorBadge;
    final l$createdAt = createdAt;
    final l$updatedAt = updatedAt;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$about,
      l$siteUrl,
      l$options,
      l$favourites,
      l$stats,
      l$statistics,
      l$donatorTier,
      l$donatorBadge,
      l$createdAt,
      l$updatedAt,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$about = about;
    final lOther$about = other.about;
    if (l$about != lOther$about) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
      return false;
    }
    final l$options = options;
    final lOther$options = other.options;
    if (l$options != lOther$options) {
      return false;
    }
    final l$favourites = favourites;
    final lOther$favourites = other.favourites;
    if (l$favourites != lOther$favourites) {
      return false;
    }
    final l$stats = stats;
    final lOther$stats = other.stats;
    if (l$stats != lOther$stats) {
      return false;
    }
    final l$statistics = statistics;
    final lOther$statistics = other.statistics;
    if (l$statistics != lOther$statistics) {
      return false;
    }
    final l$donatorTier = donatorTier;
    final lOther$donatorTier = other.donatorTier;
    if (l$donatorTier != lOther$donatorTier) {
      return false;
    }
    final l$donatorBadge = donatorBadge;
    final lOther$donatorBadge = other.donatorBadge;
    if (l$donatorBadge != lOther$donatorBadge) {
      return false;
    }
    final l$createdAt = createdAt;
    final lOther$createdAt = other.createdAt;
    if (l$createdAt != lOther$createdAt) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer
    on Query$GetCurrentUserData$Viewer {
  CopyWith$Query$GetCurrentUserData$Viewer<Query$GetCurrentUserData$Viewer>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer(
    Query$GetCurrentUserData$Viewer instance,
    TRes Function(Query$GetCurrentUserData$Viewer) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer;

  factory CopyWith$Query$GetCurrentUserData$Viewer.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer;

  TRes call({
    String? about,
    String? siteUrl,
    Query$GetCurrentUserData$Viewer$options? options,
    Query$GetCurrentUserData$Viewer$favourites? favourites,
    Query$GetCurrentUserData$Viewer$stats? stats,
    Query$GetCurrentUserData$Viewer$statistics? statistics,
    int? donatorTier,
    String? donatorBadge,
    int? createdAt,
    int? updatedAt,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$options<TRes> get options;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites<TRes> get favourites;
  CopyWith$Query$GetCurrentUserData$Viewer$stats<TRes> get stats;
  CopyWith$Query$GetCurrentUserData$Viewer$statistics<TRes> get statistics;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? about = _undefined,
    Object? siteUrl = _undefined,
    Object? options = _undefined,
    Object? favourites = _undefined,
    Object? stats = _undefined,
    Object? statistics = _undefined,
    Object? donatorTier = _undefined,
    Object? donatorBadge = _undefined,
    Object? createdAt = _undefined,
    Object? updatedAt = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer(
        about: about == _undefined ? _instance.about : (about as String?),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        options: options == _undefined
            ? _instance.options
            : (options as Query$GetCurrentUserData$Viewer$options?),
        favourites: favourites == _undefined
            ? _instance.favourites
            : (favourites as Query$GetCurrentUserData$Viewer$favourites?),
        stats: stats == _undefined
            ? _instance.stats
            : (stats as Query$GetCurrentUserData$Viewer$stats?),
        statistics: statistics == _undefined
            ? _instance.statistics
            : (statistics as Query$GetCurrentUserData$Viewer$statistics?),
        donatorTier: donatorTier == _undefined
            ? _instance.donatorTier
            : (donatorTier as int?),
        donatorBadge: donatorBadge == _undefined
            ? _instance.donatorBadge
            : (donatorBadge as String?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$options<TRes> get options {
    final local$options = _instance.options;
    return local$options == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$options.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$options(
            local$options, (e) => call(options: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites<TRes> get favourites {
    final local$favourites = _instance.favourites;
    return local$favourites == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites(
            local$favourites, (e) => call(favourites: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$stats<TRes> get stats {
    final local$stats = _instance.stats;
    return local$stats == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$stats.stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$stats(
            local$stats, (e) => call(stats: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$statistics<TRes> get statistics {
    final local$statistics = _instance.statistics;
    return local$statistics == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$statistics.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$statistics(
            local$statistics, (e) => call(statistics: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer(this._res);

  TRes _res;

  call({
    String? about,
    String? siteUrl,
    Query$GetCurrentUserData$Viewer$options? options,
    Query$GetCurrentUserData$Viewer$favourites? favourites,
    Query$GetCurrentUserData$Viewer$stats? stats,
    Query$GetCurrentUserData$Viewer$statistics? statistics,
    int? donatorTier,
    String? donatorBadge,
    int? createdAt,
    int? updatedAt,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$options<TRes> get options =>
      CopyWith$Query$GetCurrentUserData$Viewer$options.stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites<TRes> get favourites =>
      CopyWith$Query$GetCurrentUserData$Viewer$favourites.stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$stats<TRes> get stats =>
      CopyWith$Query$GetCurrentUserData$Viewer$stats.stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$statistics<TRes> get statistics =>
      CopyWith$Query$GetCurrentUserData$Viewer$statistics.stub(_res);
}

class Query$GetCurrentUserData$Viewer$options {
  Query$GetCurrentUserData$Viewer$options({
    this.titleLanguage,
    this.displayAdultContent,
    this.airingNotifications,
    this.profileColor,
    this.timezone,
    this.activityMergeTime,
    this.restrictMessagesToFollowing,
    this.staffNameLanguage,
    this.$__typename = 'UserOptions',
  });

  factory Query$GetCurrentUserData$Viewer$options.fromJson(
      Map<String, dynamic> json) {
    final l$titleLanguage = json['titleLanguage'];
    final l$displayAdultContent = json['displayAdultContent'];
    final l$airingNotifications = json['airingNotifications'];
    final l$profileColor = json['profileColor'];
    final l$timezone = json['timezone'];
    final l$activityMergeTime = json['activityMergeTime'];
    final l$restrictMessagesToFollowing = json['restrictMessagesToFollowing'];
    final l$staffNameLanguage = json['staffNameLanguage'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$options(
      titleLanguage: l$titleLanguage == null
          ? null
          : fromJson$Enum$UserTitleLanguage((l$titleLanguage as String)),
      displayAdultContent: (l$displayAdultContent as bool?),
      airingNotifications: (l$airingNotifications as bool?),
      profileColor: (l$profileColor as String?),
      timezone: (l$timezone as String?),
      activityMergeTime: (l$activityMergeTime as int?),
      restrictMessagesToFollowing: (l$restrictMessagesToFollowing as bool?),
      staffNameLanguage: l$staffNameLanguage == null
          ? null
          : fromJson$Enum$UserStaffNameLanguage(
              (l$staffNameLanguage as String)),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$UserTitleLanguage? titleLanguage;

  final bool? displayAdultContent;

  final bool? airingNotifications;

  final String? profileColor;

  final String? timezone;

  final int? activityMergeTime;

  final bool? restrictMessagesToFollowing;

  final Enum$UserStaffNameLanguage? staffNameLanguage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$titleLanguage = titleLanguage;
    _resultData['titleLanguage'] = l$titleLanguage == null
        ? null
        : toJson$Enum$UserTitleLanguage(l$titleLanguage);
    final l$displayAdultContent = displayAdultContent;
    _resultData['displayAdultContent'] = l$displayAdultContent;
    final l$airingNotifications = airingNotifications;
    _resultData['airingNotifications'] = l$airingNotifications;
    final l$profileColor = profileColor;
    _resultData['profileColor'] = l$profileColor;
    final l$timezone = timezone;
    _resultData['timezone'] = l$timezone;
    final l$activityMergeTime = activityMergeTime;
    _resultData['activityMergeTime'] = l$activityMergeTime;
    final l$restrictMessagesToFollowing = restrictMessagesToFollowing;
    _resultData['restrictMessagesToFollowing'] = l$restrictMessagesToFollowing;
    final l$staffNameLanguage = staffNameLanguage;
    _resultData['staffNameLanguage'] = l$staffNameLanguage == null
        ? null
        : toJson$Enum$UserStaffNameLanguage(l$staffNameLanguage);
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$titleLanguage = titleLanguage;
    final l$displayAdultContent = displayAdultContent;
    final l$airingNotifications = airingNotifications;
    final l$profileColor = profileColor;
    final l$timezone = timezone;
    final l$activityMergeTime = activityMergeTime;
    final l$restrictMessagesToFollowing = restrictMessagesToFollowing;
    final l$staffNameLanguage = staffNameLanguage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$titleLanguage,
      l$displayAdultContent,
      l$airingNotifications,
      l$profileColor,
      l$timezone,
      l$activityMergeTime,
      l$restrictMessagesToFollowing,
      l$staffNameLanguage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$options ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$titleLanguage = titleLanguage;
    final lOther$titleLanguage = other.titleLanguage;
    if (l$titleLanguage != lOther$titleLanguage) {
      return false;
    }
    final l$displayAdultContent = displayAdultContent;
    final lOther$displayAdultContent = other.displayAdultContent;
    if (l$displayAdultContent != lOther$displayAdultContent) {
      return false;
    }
    final l$airingNotifications = airingNotifications;
    final lOther$airingNotifications = other.airingNotifications;
    if (l$airingNotifications != lOther$airingNotifications) {
      return false;
    }
    final l$profileColor = profileColor;
    final lOther$profileColor = other.profileColor;
    if (l$profileColor != lOther$profileColor) {
      return false;
    }
    final l$timezone = timezone;
    final lOther$timezone = other.timezone;
    if (l$timezone != lOther$timezone) {
      return false;
    }
    final l$activityMergeTime = activityMergeTime;
    final lOther$activityMergeTime = other.activityMergeTime;
    if (l$activityMergeTime != lOther$activityMergeTime) {
      return false;
    }
    final l$restrictMessagesToFollowing = restrictMessagesToFollowing;
    final lOther$restrictMessagesToFollowing =
        other.restrictMessagesToFollowing;
    if (l$restrictMessagesToFollowing != lOther$restrictMessagesToFollowing) {
      return false;
    }
    final l$staffNameLanguage = staffNameLanguage;
    final lOther$staffNameLanguage = other.staffNameLanguage;
    if (l$staffNameLanguage != lOther$staffNameLanguage) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$options
    on Query$GetCurrentUserData$Viewer$options {
  CopyWith$Query$GetCurrentUserData$Viewer$options<
          Query$GetCurrentUserData$Viewer$options>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$options(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$options<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$options(
    Query$GetCurrentUserData$Viewer$options instance,
    TRes Function(Query$GetCurrentUserData$Viewer$options) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$options;

  factory CopyWith$Query$GetCurrentUserData$Viewer$options.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$options;

  TRes call({
    Enum$UserTitleLanguage? titleLanguage,
    bool? displayAdultContent,
    bool? airingNotifications,
    String? profileColor,
    String? timezone,
    int? activityMergeTime,
    bool? restrictMessagesToFollowing,
    Enum$UserStaffNameLanguage? staffNameLanguage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$options<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$options<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$options(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$options _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$options) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? titleLanguage = _undefined,
    Object? displayAdultContent = _undefined,
    Object? airingNotifications = _undefined,
    Object? profileColor = _undefined,
    Object? timezone = _undefined,
    Object? activityMergeTime = _undefined,
    Object? restrictMessagesToFollowing = _undefined,
    Object? staffNameLanguage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$options(
        titleLanguage: titleLanguage == _undefined
            ? _instance.titleLanguage
            : (titleLanguage as Enum$UserTitleLanguage?),
        displayAdultContent: displayAdultContent == _undefined
            ? _instance.displayAdultContent
            : (displayAdultContent as bool?),
        airingNotifications: airingNotifications == _undefined
            ? _instance.airingNotifications
            : (airingNotifications as bool?),
        profileColor: profileColor == _undefined
            ? _instance.profileColor
            : (profileColor as String?),
        timezone:
            timezone == _undefined ? _instance.timezone : (timezone as String?),
        activityMergeTime: activityMergeTime == _undefined
            ? _instance.activityMergeTime
            : (activityMergeTime as int?),
        restrictMessagesToFollowing: restrictMessagesToFollowing == _undefined
            ? _instance.restrictMessagesToFollowing
            : (restrictMessagesToFollowing as bool?),
        staffNameLanguage: staffNameLanguage == _undefined
            ? _instance.staffNameLanguage
            : (staffNameLanguage as Enum$UserStaffNameLanguage?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$options<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$options<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$options(this._res);

  TRes _res;

  call({
    Enum$UserTitleLanguage? titleLanguage,
    bool? displayAdultContent,
    bool? airingNotifications,
    String? profileColor,
    String? timezone,
    int? activityMergeTime,
    bool? restrictMessagesToFollowing,
    Enum$UserStaffNameLanguage? staffNameLanguage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$favourites {
  Query$GetCurrentUserData$Viewer$favourites({
    this.anime,
    this.characters,
    this.staff,
    this.studios,
    this.$__typename = 'Favourites',
  });

  factory Query$GetCurrentUserData$Viewer$favourites.fromJson(
      Map<String, dynamic> json) {
    final l$anime = json['anime'];
    final l$characters = json['characters'];
    final l$staff = json['staff'];
    final l$studios = json['studios'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites(
      anime: l$anime == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$anime.fromJson(
              (l$anime as Map<String, dynamic>)),
      characters: l$characters == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$characters.fromJson(
              (l$characters as Map<String, dynamic>)),
      staff: l$staff == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$staff.fromJson(
              (l$staff as Map<String, dynamic>)),
      studios: l$studios == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$studios.fromJson(
              (l$studios as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetCurrentUserData$Viewer$favourites$anime? anime;

  final Query$GetCurrentUserData$Viewer$favourites$characters? characters;

  final Query$GetCurrentUserData$Viewer$favourites$staff? staff;

  final Query$GetCurrentUserData$Viewer$favourites$studios? studios;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$anime = anime;
    _resultData['anime'] = l$anime?.toJson();
    final l$characters = characters;
    _resultData['characters'] = l$characters?.toJson();
    final l$staff = staff;
    _resultData['staff'] = l$staff?.toJson();
    final l$studios = studios;
    _resultData['studios'] = l$studios?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$anime = anime;
    final l$characters = characters;
    final l$staff = staff;
    final l$studios = studios;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$anime,
      l$characters,
      l$staff,
      l$studios,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$favourites ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$anime = anime;
    final lOther$anime = other.anime;
    if (l$anime != lOther$anime) {
      return false;
    }
    final l$characters = characters;
    final lOther$characters = other.characters;
    if (l$characters != lOther$characters) {
      return false;
    }
    final l$staff = staff;
    final lOther$staff = other.staff;
    if (l$staff != lOther$staff) {
      return false;
    }
    final l$studios = studios;
    final lOther$studios = other.studios;
    if (l$studios != lOther$studios) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites
    on Query$GetCurrentUserData$Viewer$favourites {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites<
          Query$GetCurrentUserData$Viewer$favourites>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$favourites(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites(
    Query$GetCurrentUserData$Viewer$favourites instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites;

  TRes call({
    Query$GetCurrentUserData$Viewer$favourites$anime? anime,
    Query$GetCurrentUserData$Viewer$favourites$characters? characters,
    Query$GetCurrentUserData$Viewer$favourites$staff? staff,
    Query$GetCurrentUserData$Viewer$favourites$studios? studios,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<TRes> get anime;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<TRes>
      get characters;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<TRes> get staff;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<TRes> get studios;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$favourites<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? anime = _undefined,
    Object? characters = _undefined,
    Object? staff = _undefined,
    Object? studios = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites(
        anime: anime == _undefined
            ? _instance.anime
            : (anime as Query$GetCurrentUserData$Viewer$favourites$anime?),
        characters: characters == _undefined
            ? _instance.characters
            : (characters
                as Query$GetCurrentUserData$Viewer$favourites$characters?),
        staff: staff == _undefined
            ? _instance.staff
            : (staff as Query$GetCurrentUserData$Viewer$favourites$staff?),
        studios: studios == _undefined
            ? _instance.studios
            : (studios as Query$GetCurrentUserData$Viewer$favourites$studios?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<TRes> get anime {
    final local$anime = _instance.anime;
    return local$anime == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime(
            local$anime, (e) => call(anime: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<TRes>
      get characters {
    final local$characters = _instance.characters;
    return local$characters == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters(
            local$characters, (e) => call(characters: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<TRes> get staff {
    final local$staff = _instance.staff;
    return local$staff == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff(
            local$staff, (e) => call(staff: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<TRes>
      get studios {
    final local$studios = _instance.studios;
    return local$studios == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios(
            local$studios, (e) => call(studios: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$favourites<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites(this._res);

  TRes _res;

  call({
    Query$GetCurrentUserData$Viewer$favourites$anime? anime,
    Query$GetCurrentUserData$Viewer$favourites$characters? characters,
    Query$GetCurrentUserData$Viewer$favourites$staff? staff,
    Query$GetCurrentUserData$Viewer$favourites$studios? studios,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<TRes> get anime =>
      CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime.stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<TRes>
      get characters =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters.stub(
              _res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<TRes> get staff =>
      CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff.stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<TRes>
      get studios =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios.stub(
              _res);
}

class Query$GetCurrentUserData$Viewer$favourites$anime {
  Query$GetCurrentUserData$Viewer$favourites$anime({
    this.nodes,
    this.$__typename = 'MediaConnection',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$anime.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$anime(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$favourites$anime$nodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetCurrentUserData$Viewer$favourites$anime$nodes?>? nodes;

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
    if (other is! Query$GetCurrentUserData$Viewer$favourites$anime ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$anime
    on Query$GetCurrentUserData$Viewer$favourites$anime {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<
          Query$GetCurrentUserData$Viewer$favourites$anime>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime(
    Query$GetCurrentUserData$Viewer$favourites$anime instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$anime) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime;

  TRes call({
    List<Query$GetCurrentUserData$Viewer$favourites$anime$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Query$GetCurrentUserData$Viewer$favourites$anime$nodes?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<
                      Query$GetCurrentUserData$Viewer$favourites$anime$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$anime _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$anime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$anime(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes as List<
                Query$GetCurrentUserData$Viewer$favourites$anime$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Query$GetCurrentUserData$Viewer$favourites$anime$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<
                          Query$GetCurrentUserData$Viewer$favourites$anime$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime(this._res);

  TRes _res;

  call({
    List<Query$GetCurrentUserData$Viewer$favourites$anime$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Query$GetCurrentUserData$Viewer$favourites$anime$nodes
    implements Fragment$AnimeCard {
  Query$GetCurrentUserData$Viewer$favourites$anime$nodes({
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
  });

  factory Query$GetCurrentUserData$Viewer$favourites$anime$nodes.fromJson(
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
    return Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title
              .fromJson((l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage
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
          : Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
              .fromJson((l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate
              .fromJson((l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      siteUrl: (l$siteUrl as String?),
    );
  }

  final int id;

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title? title;

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage?
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

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode?
      nextAiringEpisode;

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate?
      startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? siteUrl;

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
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$favourites$anime$nodes ||
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
    return true;
  }
}

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$anime$nodes
    on Query$GetCurrentUserData$Viewer$favourites$anime$nodes {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$anime$nodes) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes;

  TRes call({
    int? id,
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title? title,
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage?
        coverImage,
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
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode?
        nextAiringEpisode,
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? siteUrl,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<TRes>
      get title;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
      TRes> get coverImage;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
      TRes> get nextAiringEpisode;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
      TRes> get startDate;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$anime$nodes)
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
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage?),
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
                as Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate
                as Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate?),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<TRes>
      get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
      TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
      TRes> get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
      TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
            local$startDate, (e) => call(startDate: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title? title,
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage?
        coverImage,
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
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode?
        nextAiringEpisode,
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? siteUrl,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<TRes>
      get title =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title
              .stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
          TRes>
      get coverImage =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage
              .stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
          TRes>
      get nextAiringEpisode =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
              .stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
          TRes>
      get startDate =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate
              .stub(_res);
}

class Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title
    implements Fragment$AnimeCard$title {
  Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title.fromJson(
      Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
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
    if (other
            is! Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title
    on Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
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

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$title(
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

class Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage
    implements Fragment$AnimeCard$coverImage {
  Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
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
            is! Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage
    on Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage instance,
    TRes Function(
            Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage
      _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
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

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$coverImage(
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

class Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
    implements Fragment$AnimeCard$nextAiringEpisode {
  Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
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
            is! Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
    on Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
        instance,
    TRes Function(
            Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode
      _instance;

  final TRes Function(
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
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

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$nextAiringEpisode(
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

class Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate
    implements Fragment$AnimeCard$startDate {
  Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
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
            is! Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate
    on Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
          Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
    Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate instance,
    TRes Function(
            Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate
      _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$anime$nodes$startDate(
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

class Query$GetCurrentUserData$Viewer$favourites$characters {
  Query$GetCurrentUserData$Viewer$favourites$characters({
    this.nodes,
    this.$__typename = 'CharacterConnection',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$characters.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$characters(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$favourites$characters$nodes
                  .fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetCurrentUserData$Viewer$favourites$characters$nodes?>?
      nodes;

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
    if (other is! Query$GetCurrentUserData$Viewer$favourites$characters ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$characters
    on Query$GetCurrentUserData$Viewer$favourites$characters {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<
          Query$GetCurrentUserData$Viewer$favourites$characters>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters(
    Query$GetCurrentUserData$Viewer$favourites$characters instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$characters) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters;

  TRes call({
    List<Query$GetCurrentUserData$Viewer$favourites$characters$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Query$GetCurrentUserData$Viewer$favourites$characters$nodes?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
                      Query$GetCurrentUserData$Viewer$favourites$characters$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$characters _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$characters)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$characters(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes as List<
                Query$GetCurrentUserData$Viewer$favourites$characters$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Query$GetCurrentUserData$Viewer$favourites$characters$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
                          Query$GetCurrentUserData$Viewer$favourites$characters$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters(
      this._res);

  TRes _res;

  call({
    List<Query$GetCurrentUserData$Viewer$favourites$characters$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Query$GetCurrentUserData$Viewer$favourites$characters$nodes {
  Query$GetCurrentUserData$Viewer$favourites$characters$nodes({
    required this.id,
    this.name,
    this.image,
    this.siteUrl,
    this.$__typename = 'Character',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$characters$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image = json['image'];
    final l$siteUrl = json['siteUrl'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
      id: (l$id as int),
      name: l$name == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name
              .fromJson((l$name as Map<String, dynamic>)),
      image: l$image == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image
              .fromJson((l$image as Map<String, dynamic>)),
      siteUrl: (l$siteUrl as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name? name;

  final Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image?
      image;

  final String? siteUrl;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name?.toJson();
    final l$image = image;
    _resultData['image'] = l$image?.toJson();
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image = image;
    final l$siteUrl = siteUrl;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$image,
      l$siteUrl,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$favourites$characters$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$image = image;
    final lOther$image = other.image;
    if (l$image != lOther$image) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$characters$nodes
    on Query$GetCurrentUserData$Viewer$favourites$characters$nodes {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
          Query$GetCurrentUserData$Viewer$favourites$characters$nodes>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$characters$nodes)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes;

  TRes call({
    int? id,
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name? name,
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image? image,
    String? siteUrl,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
      TRes> get name;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
      TRes> get image;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$characters$nodes _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$characters$nodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image = _undefined,
    Object? siteUrl = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined
            ? _instance.name
            : (name
                as Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name?),
        image: image == _undefined
            ? _instance.image
            : (image
                as Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image?),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
      TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
            local$name, (e) => call(name: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
      TRes> get image {
    final local$image = _instance.image;
    return local$image == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
            local$image, (e) => call(image: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name? name,
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image? image,
    String? siteUrl,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
          TRes>
      get name =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name
              .stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
          TRes>
      get image =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image
              .stub(_res);
}

class Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name {
  Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name({
    this.full,
    this.native,
    this.$__typename = 'CharacterName',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name.fromJson(
      Map<String, dynamic> json) {
    final l$full = json['full'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
      full: (l$full as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? full;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$full = full;
    _resultData['full'] = l$full;
    final l$native = native;
    _resultData['native'] = l$native;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$full = full;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$full,
      l$native,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$full = full;
    final lOther$full = other.full;
    if (l$full != lOther$full) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name
    on Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
          Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name instance,
    TRes Function(
            Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name;

  TRes call({
    String? full,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name
      _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? full = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
        full: full == _undefined ? _instance.full : (full as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$name(
      this._res);

  TRes _res;

  call({
    String? full,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image {
  Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image({
    this.large,
    this.$__typename = 'CharacterImage',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
      large: (l$large as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image
    on Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
          Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
    Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image instance,
    TRes Function(
            Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image
      _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$characters$nodes$image(
      this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$favourites$staff {
  Query$GetCurrentUserData$Viewer$favourites$staff({
    this.nodes,
    this.$__typename = 'StaffConnection',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$staff.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$staff(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$favourites$staff$nodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetCurrentUserData$Viewer$favourites$staff$nodes?>? nodes;

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
    if (other is! Query$GetCurrentUserData$Viewer$favourites$staff ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$staff
    on Query$GetCurrentUserData$Viewer$favourites$staff {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<
          Query$GetCurrentUserData$Viewer$favourites$staff>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff(
    Query$GetCurrentUserData$Viewer$favourites$staff instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$staff) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff;

  TRes call({
    List<Query$GetCurrentUserData$Viewer$favourites$staff$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Query$GetCurrentUserData$Viewer$favourites$staff$nodes?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<
                      Query$GetCurrentUserData$Viewer$favourites$staff$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$staff _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$staff) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$staff(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes as List<
                Query$GetCurrentUserData$Viewer$favourites$staff$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Query$GetCurrentUserData$Viewer$favourites$staff$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<
                          Query$GetCurrentUserData$Viewer$favourites$staff$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff(this._res);

  TRes _res;

  call({
    List<Query$GetCurrentUserData$Viewer$favourites$staff$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Query$GetCurrentUserData$Viewer$favourites$staff$nodes {
  Query$GetCurrentUserData$Viewer$favourites$staff$nodes({
    required this.id,
    this.name,
    this.image,
    this.siteUrl,
    this.$__typename = 'Staff',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$staff$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image = json['image'];
    final l$siteUrl = json['siteUrl'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
      id: (l$id as int),
      name: l$name == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name
              .fromJson((l$name as Map<String, dynamic>)),
      image: l$image == null
          ? null
          : Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image
              .fromJson((l$image as Map<String, dynamic>)),
      siteUrl: (l$siteUrl as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name? name;

  final Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image? image;

  final String? siteUrl;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name?.toJson();
    final l$image = image;
    _resultData['image'] = l$image?.toJson();
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image = image;
    final l$siteUrl = siteUrl;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$image,
      l$siteUrl,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$favourites$staff$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$image = image;
    final lOther$image = other.image;
    if (l$image != lOther$image) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$staff$nodes
    on Query$GetCurrentUserData$Viewer$favourites$staff$nodes {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<
          Query$GetCurrentUserData$Viewer$favourites$staff$nodes>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$staff$nodes) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes;

  TRes call({
    int? id,
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name? name,
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image? image,
    String? siteUrl,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<TRes>
      get name;
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<TRes>
      get image;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$staff$nodes _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$staff$nodes)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image = _undefined,
    Object? siteUrl = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined
            ? _instance.name
            : (name
                as Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name?),
        image: image == _undefined
            ? _instance.image
            : (image
                as Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image?),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<TRes>
      get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
            local$name, (e) => call(name: e));
  }

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<TRes>
      get image {
    final local$image = _instance.image;
    return local$image == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
            local$image, (e) => call(image: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name? name,
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image? image,
    String? siteUrl,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<TRes>
      get name =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name
              .stub(_res);

  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<TRes>
      get image =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image
              .stub(_res);
}

class Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name {
  Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name({
    this.full,
    this.native,
    this.$__typename = 'StaffName',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name.fromJson(
      Map<String, dynamic> json) {
    final l$full = json['full'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
      full: (l$full as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? full;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$full = full;
    _resultData['full'] = l$full;
    final l$native = native;
    _resultData['native'] = l$native;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$full = full;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$full,
      l$native,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$full = full;
    final lOther$full = other.full;
    if (l$full != lOther$full) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name
    on Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<
          Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name;

  TRes call({
    String? full,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? full = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
        full: full == _undefined ? _instance.full : (full as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$name(
      this._res);

  TRes _res;

  call({
    String? full,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image {
  Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image({
    this.large,
    this.$__typename = 'StaffImage',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
      large: (l$large as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image
    on Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<
          Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
    Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image _instance;

  final TRes Function(
      Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$staff$nodes$image(
      this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$favourites$studios {
  Query$GetCurrentUserData$Viewer$favourites$studios({
    this.nodes,
    this.$__typename = 'StudioConnection',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$studios.fromJson(
      Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$studios(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$favourites$studios$nodes
                  .fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetCurrentUserData$Viewer$favourites$studios$nodes?>? nodes;

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
    if (other is! Query$GetCurrentUserData$Viewer$favourites$studios ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$studios
    on Query$GetCurrentUserData$Viewer$favourites$studios {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<
          Query$GetCurrentUserData$Viewer$favourites$studios>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios(
    Query$GetCurrentUserData$Viewer$favourites$studios instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$studios) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$studios;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$studios;

  TRes call({
    List<Query$GetCurrentUserData$Viewer$favourites$studios$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Query$GetCurrentUserData$Viewer$favourites$studios$nodes?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
                      Query$GetCurrentUserData$Viewer$favourites$studios$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$studios<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$studios(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$studios _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$studios) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$studios(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes as List<
                Query$GetCurrentUserData$Viewer$favourites$studios$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Query$GetCurrentUserData$Viewer$favourites$studios$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
                          Query$GetCurrentUserData$Viewer$favourites$studios$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$studios<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$studios(
      this._res);

  TRes _res;

  call({
    List<Query$GetCurrentUserData$Viewer$favourites$studios$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Query$GetCurrentUserData$Viewer$favourites$studios$nodes {
  Query$GetCurrentUserData$Viewer$favourites$studios$nodes({
    required this.id,
    required this.name,
    this.siteUrl,
    this.$__typename = 'Studio',
  });

  factory Query$GetCurrentUserData$Viewer$favourites$studios$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$siteUrl = json['siteUrl'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
      id: (l$id as int),
      name: (l$name as String),
      siteUrl: (l$siteUrl as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final String? siteUrl;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$siteUrl = siteUrl;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$siteUrl,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$favourites$studios$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$favourites$studios$nodes
    on Query$GetCurrentUserData$Viewer$favourites$studios$nodes {
  CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
          Query$GetCurrentUserData$Viewer$favourites$studios$nodes>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
    Query$GetCurrentUserData$Viewer$favourites$studios$nodes instance,
    TRes Function(Query$GetCurrentUserData$Viewer$favourites$studios$nodes)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$studios$nodes;

  factory CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$studios$nodes;

  TRes call({
    int? id,
    String? name,
    String? siteUrl,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$favourites$studios$nodes _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$favourites$studios$nodes)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? siteUrl = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$favourites$studios$nodes<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$favourites$studios$nodes(
      this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    String? siteUrl,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$stats {
  Query$GetCurrentUserData$Viewer$stats({
    this.activityHistory,
    this.$__typename = 'UserStats',
  });

  factory Query$GetCurrentUserData$Viewer$stats.fromJson(
      Map<String, dynamic> json) {
    final l$activityHistory = json['activityHistory'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$stats(
      activityHistory: (l$activityHistory as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$stats$activityHistory.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetCurrentUserData$Viewer$stats$activityHistory?>?
      activityHistory;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$activityHistory = activityHistory;
    _resultData['activityHistory'] =
        l$activityHistory?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$activityHistory = activityHistory;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$activityHistory == null
          ? null
          : Object.hashAll(l$activityHistory.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$stats ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$activityHistory = activityHistory;
    final lOther$activityHistory = other.activityHistory;
    if (l$activityHistory != null && lOther$activityHistory != null) {
      if (l$activityHistory.length != lOther$activityHistory.length) {
        return false;
      }
      for (int i = 0; i < l$activityHistory.length; i++) {
        final l$activityHistory$entry = l$activityHistory[i];
        final lOther$activityHistory$entry = lOther$activityHistory[i];
        if (l$activityHistory$entry != lOther$activityHistory$entry) {
          return false;
        }
      }
    } else if (l$activityHistory != lOther$activityHistory) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$stats
    on Query$GetCurrentUserData$Viewer$stats {
  CopyWith$Query$GetCurrentUserData$Viewer$stats<
          Query$GetCurrentUserData$Viewer$stats>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$stats(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$stats<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$stats(
    Query$GetCurrentUserData$Viewer$stats instance,
    TRes Function(Query$GetCurrentUserData$Viewer$stats) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$stats;

  factory CopyWith$Query$GetCurrentUserData$Viewer$stats.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$stats;

  TRes call({
    List<Query$GetCurrentUserData$Viewer$stats$activityHistory?>?
        activityHistory,
    String? $__typename,
  });
  TRes activityHistory(
      Iterable<Query$GetCurrentUserData$Viewer$stats$activityHistory?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory<
                      Query$GetCurrentUserData$Viewer$stats$activityHistory>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$stats<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$stats<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$stats(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$stats _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$stats) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? activityHistory = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$stats(
        activityHistory: activityHistory == _undefined
            ? _instance.activityHistory
            : (activityHistory as List<
                Query$GetCurrentUserData$Viewer$stats$activityHistory?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes activityHistory(
          Iterable<Query$GetCurrentUserData$Viewer$stats$activityHistory?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory<
                          Query$GetCurrentUserData$Viewer$stats$activityHistory>?>?)
              _fn) =>
      call(
          activityHistory: _fn(_instance.activityHistory?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$stats<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$stats<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$stats(this._res);

  TRes _res;

  call({
    List<Query$GetCurrentUserData$Viewer$stats$activityHistory?>?
        activityHistory,
    String? $__typename,
  }) =>
      _res;

  activityHistory(_fn) => _res;
}

class Query$GetCurrentUserData$Viewer$stats$activityHistory {
  Query$GetCurrentUserData$Viewer$stats$activityHistory({
    this.date,
    this.amount,
    this.level,
    this.$__typename = 'UserActivityHistory',
  });

  factory Query$GetCurrentUserData$Viewer$stats$activityHistory.fromJson(
      Map<String, dynamic> json) {
    final l$date = json['date'];
    final l$amount = json['amount'];
    final l$level = json['level'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$stats$activityHistory(
      date: (l$date as int?),
      amount: (l$amount as int?),
      level: (l$level as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? date;

  final int? amount;

  final int? level;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$date = date;
    _resultData['date'] = l$date;
    final l$amount = amount;
    _resultData['amount'] = l$amount;
    final l$level = level;
    _resultData['level'] = l$level;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$date = date;
    final l$amount = amount;
    final l$level = level;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$date,
      l$amount,
      l$level,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$stats$activityHistory ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    final l$amount = amount;
    final lOther$amount = other.amount;
    if (l$amount != lOther$amount) {
      return false;
    }
    final l$level = level;
    final lOther$level = other.level;
    if (l$level != lOther$level) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$stats$activityHistory
    on Query$GetCurrentUserData$Viewer$stats$activityHistory {
  CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory<
          Query$GetCurrentUserData$Viewer$stats$activityHistory>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory(
    Query$GetCurrentUserData$Viewer$stats$activityHistory instance,
    TRes Function(Query$GetCurrentUserData$Viewer$stats$activityHistory) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$stats$activityHistory;

  factory CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$stats$activityHistory;

  TRes call({
    int? date,
    int? amount,
    int? level,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$stats$activityHistory<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$stats$activityHistory(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$stats$activityHistory _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$stats$activityHistory)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? date = _undefined,
    Object? amount = _undefined,
    Object? level = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$stats$activityHistory(
        date: date == _undefined ? _instance.date : (date as int?),
        amount: amount == _undefined ? _instance.amount : (amount as int?),
        level: level == _undefined ? _instance.level : (level as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$stats$activityHistory<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$stats$activityHistory<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$stats$activityHistory(
      this._res);

  TRes _res;

  call({
    int? date,
    int? amount,
    int? level,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$statistics {
  Query$GetCurrentUserData$Viewer$statistics({
    this.anime,
    this.$__typename = 'UserStatisticTypes',
  });

  factory Query$GetCurrentUserData$Viewer$statistics.fromJson(
      Map<String, dynamic> json) {
    final l$anime = json['anime'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics(
      anime: l$anime == null
          ? null
          : Query$GetCurrentUserData$Viewer$statistics$anime.fromJson(
              (l$anime as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetCurrentUserData$Viewer$statistics$anime? anime;

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
    if (other is! Query$GetCurrentUserData$Viewer$statistics ||
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics
    on Query$GetCurrentUserData$Viewer$statistics {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics<
          Query$GetCurrentUserData$Viewer$statistics>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$statistics(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics(
    Query$GetCurrentUserData$Viewer$statistics instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics;

  TRes call({
    Query$GetCurrentUserData$Viewer$statistics$anime? anime,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<TRes> get anime;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$statistics<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? anime = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics(
        anime: anime == _undefined
            ? _instance.anime
            : (anime as Query$GetCurrentUserData$Viewer$statistics$anime?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<TRes> get anime {
    final local$anime = _instance.anime;
    return local$anime == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime.stub(
            _then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime(
            local$anime, (e) => call(anime: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$statistics<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics(this._res);

  TRes _res;

  call({
    Query$GetCurrentUserData$Viewer$statistics$anime? anime,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<TRes> get anime =>
      CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime.stub(_res);
}

class Query$GetCurrentUserData$Viewer$statistics$anime {
  Query$GetCurrentUserData$Viewer$statistics$anime({
    required this.count,
    required this.meanScore,
    required this.standardDeviation,
    required this.minutesWatched,
    required this.episodesWatched,
    this.genres,
    this.tags,
    this.formats,
    this.statuses,
    this.$__typename = 'UserStatistics',
  });

  factory Query$GetCurrentUserData$Viewer$statistics$anime.fromJson(
      Map<String, dynamic> json) {
    final l$count = json['count'];
    final l$meanScore = json['meanScore'];
    final l$standardDeviation = json['standardDeviation'];
    final l$minutesWatched = json['minutesWatched'];
    final l$episodesWatched = json['episodesWatched'];
    final l$genres = json['genres'];
    final l$tags = json['tags'];
    final l$formats = json['formats'];
    final l$statuses = json['statuses'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics$anime(
      count: (l$count as int),
      meanScore: (l$meanScore as num).toDouble(),
      standardDeviation: (l$standardDeviation as num).toDouble(),
      minutesWatched: (l$minutesWatched as int),
      episodesWatched: (l$episodesWatched as int),
      genres: (l$genres as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$statistics$anime$genres
                  .fromJson((e as Map<String, dynamic>)))
          .toList(),
      tags: (l$tags as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$statistics$anime$tags.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      formats: (l$formats as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$statistics$anime$formats
                  .fromJson((e as Map<String, dynamic>)))
          .toList(),
      statuses: (l$statuses as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetCurrentUserData$Viewer$statistics$anime$statuses
                  .fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final double meanScore;

  final double standardDeviation;

  final int minutesWatched;

  final int episodesWatched;

  final List<Query$GetCurrentUserData$Viewer$statistics$anime$genres?>? genres;

  final List<Query$GetCurrentUserData$Viewer$statistics$anime$tags?>? tags;

  final List<Query$GetCurrentUserData$Viewer$statistics$anime$formats?>?
      formats;

  final List<Query$GetCurrentUserData$Viewer$statistics$anime$statuses?>?
      statuses;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$standardDeviation = standardDeviation;
    _resultData['standardDeviation'] = l$standardDeviation;
    final l$minutesWatched = minutesWatched;
    _resultData['minutesWatched'] = l$minutesWatched;
    final l$episodesWatched = episodesWatched;
    _resultData['episodesWatched'] = l$episodesWatched;
    final l$genres = genres;
    _resultData['genres'] = l$genres?.map((e) => e?.toJson()).toList();
    final l$tags = tags;
    _resultData['tags'] = l$tags?.map((e) => e?.toJson()).toList();
    final l$formats = formats;
    _resultData['formats'] = l$formats?.map((e) => e?.toJson()).toList();
    final l$statuses = statuses;
    _resultData['statuses'] = l$statuses?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$meanScore = meanScore;
    final l$standardDeviation = standardDeviation;
    final l$minutesWatched = minutesWatched;
    final l$episodesWatched = episodesWatched;
    final l$genres = genres;
    final l$tags = tags;
    final l$formats = formats;
    final l$statuses = statuses;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      l$meanScore,
      l$standardDeviation,
      l$minutesWatched,
      l$episodesWatched,
      l$genres == null ? null : Object.hashAll(l$genres.map((v) => v)),
      l$tags == null ? null : Object.hashAll(l$tags.map((v) => v)),
      l$formats == null ? null : Object.hashAll(l$formats.map((v) => v)),
      l$statuses == null ? null : Object.hashAll(l$statuses.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$statistics$anime ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$standardDeviation = standardDeviation;
    final lOther$standardDeviation = other.standardDeviation;
    if (l$standardDeviation != lOther$standardDeviation) {
      return false;
    }
    final l$minutesWatched = minutesWatched;
    final lOther$minutesWatched = other.minutesWatched;
    if (l$minutesWatched != lOther$minutesWatched) {
      return false;
    }
    final l$episodesWatched = episodesWatched;
    final lOther$episodesWatched = other.episodesWatched;
    if (l$episodesWatched != lOther$episodesWatched) {
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
    final l$tags = tags;
    final lOther$tags = other.tags;
    if (l$tags != null && lOther$tags != null) {
      if (l$tags.length != lOther$tags.length) {
        return false;
      }
      for (int i = 0; i < l$tags.length; i++) {
        final l$tags$entry = l$tags[i];
        final lOther$tags$entry = lOther$tags[i];
        if (l$tags$entry != lOther$tags$entry) {
          return false;
        }
      }
    } else if (l$tags != lOther$tags) {
      return false;
    }
    final l$formats = formats;
    final lOther$formats = other.formats;
    if (l$formats != null && lOther$formats != null) {
      if (l$formats.length != lOther$formats.length) {
        return false;
      }
      for (int i = 0; i < l$formats.length; i++) {
        final l$formats$entry = l$formats[i];
        final lOther$formats$entry = lOther$formats[i];
        if (l$formats$entry != lOther$formats$entry) {
          return false;
        }
      }
    } else if (l$formats != lOther$formats) {
      return false;
    }
    final l$statuses = statuses;
    final lOther$statuses = other.statuses;
    if (l$statuses != null && lOther$statuses != null) {
      if (l$statuses.length != lOther$statuses.length) {
        return false;
      }
      for (int i = 0; i < l$statuses.length; i++) {
        final l$statuses$entry = l$statuses[i];
        final lOther$statuses$entry = lOther$statuses[i];
        if (l$statuses$entry != lOther$statuses$entry) {
          return false;
        }
      }
    } else if (l$statuses != lOther$statuses) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics$anime
    on Query$GetCurrentUserData$Viewer$statistics$anime {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<
          Query$GetCurrentUserData$Viewer$statistics$anime>
      get copyWith => CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime(
    Query$GetCurrentUserData$Viewer$statistics$anime instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime;

  TRes call({
    int? count,
    double? meanScore,
    double? standardDeviation,
    int? minutesWatched,
    int? episodesWatched,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$genres?>? genres,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$tags?>? tags,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$formats?>? formats,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$statuses?>? statuses,
    String? $__typename,
  });
  TRes genres(
      Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$genres?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres<
                      Query$GetCurrentUserData$Viewer$statistics$anime$genres>?>?)
          _fn);
  TRes tags(
      Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$tags?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags<
                      Query$GetCurrentUserData$Viewer$statistics$anime$tags>?>?)
          _fn);
  TRes formats(
      Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$formats?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
                      Query$GetCurrentUserData$Viewer$statistics$anime$formats>?>?)
          _fn);
  TRes statuses(
      Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$statuses?>? Function(
              Iterable<
                  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
                      Query$GetCurrentUserData$Viewer$statistics$anime$statuses>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics$anime _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? meanScore = _undefined,
    Object? standardDeviation = _undefined,
    Object? minutesWatched = _undefined,
    Object? episodesWatched = _undefined,
    Object? genres = _undefined,
    Object? tags = _undefined,
    Object? formats = _undefined,
    Object? statuses = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics$anime(
        count: count == _undefined || count == null
            ? _instance.count
            : (count as int),
        meanScore: meanScore == _undefined || meanScore == null
            ? _instance.meanScore
            : (meanScore as double),
        standardDeviation:
            standardDeviation == _undefined || standardDeviation == null
                ? _instance.standardDeviation
                : (standardDeviation as double),
        minutesWatched: minutesWatched == _undefined || minutesWatched == null
            ? _instance.minutesWatched
            : (minutesWatched as int),
        episodesWatched:
            episodesWatched == _undefined || episodesWatched == null
                ? _instance.episodesWatched
                : (episodesWatched as int),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<
                Query$GetCurrentUserData$Viewer$statistics$anime$genres?>?),
        tags: tags == _undefined
            ? _instance.tags
            : (tags as List<
                Query$GetCurrentUserData$Viewer$statistics$anime$tags?>?),
        formats: formats == _undefined
            ? _instance.formats
            : (formats as List<
                Query$GetCurrentUserData$Viewer$statistics$anime$formats?>?),
        statuses: statuses == _undefined
            ? _instance.statuses
            : (statuses as List<
                Query$GetCurrentUserData$Viewer$statistics$anime$statuses?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes genres(
          Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$genres?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres<
                          Query$GetCurrentUserData$Viewer$statistics$anime$genres>?>?)
              _fn) =>
      call(
          genres: _fn(_instance.genres?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres(
                  e,
                  (i) => i,
                )))?.toList());

  TRes tags(
          Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$tags?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags<
                          Query$GetCurrentUserData$Viewer$statistics$anime$tags>?>?)
              _fn) =>
      call(
          tags: _fn(_instance.tags?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags(
                  e,
                  (i) => i,
                )))?.toList());

  TRes formats(
          Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$formats?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
                          Query$GetCurrentUserData$Viewer$statistics$anime$formats>?>?)
              _fn) =>
      call(
          formats: _fn(_instance.formats?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats(
                  e,
                  (i) => i,
                )))?.toList());

  TRes statuses(
          Iterable<Query$GetCurrentUserData$Viewer$statistics$anime$statuses?>? Function(
                  Iterable<
                      CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
                          Query$GetCurrentUserData$Viewer$statistics$anime$statuses>?>?)
              _fn) =>
      call(
          statuses: _fn(_instance.statuses?.map((e) => e == null
              ? null
              : CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime<TRes>
    implements CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime(this._res);

  TRes _res;

  call({
    int? count,
    double? meanScore,
    double? standardDeviation,
    int? minutesWatched,
    int? episodesWatched,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$genres?>? genres,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$tags?>? tags,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$formats?>? formats,
    List<Query$GetCurrentUserData$Viewer$statistics$anime$statuses?>? statuses,
    String? $__typename,
  }) =>
      _res;

  genres(_fn) => _res;

  tags(_fn) => _res;

  formats(_fn) => _res;

  statuses(_fn) => _res;
}

class Query$GetCurrentUserData$Viewer$statistics$anime$genres {
  Query$GetCurrentUserData$Viewer$statistics$anime$genres({
    this.genre,
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    this.$__typename = 'UserGenreStatistic',
  });

  factory Query$GetCurrentUserData$Viewer$statistics$anime$genres.fromJson(
      Map<String, dynamic> json) {
    final l$genre = json['genre'];
    final l$count = json['count'];
    final l$meanScore = json['meanScore'];
    final l$minutesWatched = json['minutesWatched'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics$anime$genres(
      genre: (l$genre as String?),
      count: (l$count as int),
      meanScore: (l$meanScore as num).toDouble(),
      minutesWatched: (l$minutesWatched as int),
      $__typename: (l$$__typename as String),
    );
  }

  final String? genre;

  final int count;

  final double meanScore;

  final int minutesWatched;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$genre = genre;
    _resultData['genre'] = l$genre;
    final l$count = count;
    _resultData['count'] = l$count;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$minutesWatched = minutesWatched;
    _resultData['minutesWatched'] = l$minutesWatched;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$genre = genre;
    final l$count = count;
    final l$meanScore = meanScore;
    final l$minutesWatched = minutesWatched;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$genre,
      l$count,
      l$meanScore,
      l$minutesWatched,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$statistics$anime$genres ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$genre = genre;
    final lOther$genre = other.genre;
    if (l$genre != lOther$genre) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$minutesWatched = minutesWatched;
    final lOther$minutesWatched = other.minutesWatched;
    if (l$minutesWatched != lOther$minutesWatched) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics$anime$genres
    on Query$GetCurrentUserData$Viewer$statistics$anime$genres {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres<
          Query$GetCurrentUserData$Viewer$statistics$anime$genres>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres(
    Query$GetCurrentUserData$Viewer$statistics$anime$genres instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$genres) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$genres;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$genres;

  TRes call({
    String? genre,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$genres<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$genres(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics$anime$genres _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$genres)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? genre = _undefined,
    Object? count = _undefined,
    Object? meanScore = _undefined,
    Object? minutesWatched = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics$anime$genres(
        genre: genre == _undefined ? _instance.genre : (genre as String?),
        count: count == _undefined || count == null
            ? _instance.count
            : (count as int),
        meanScore: meanScore == _undefined || meanScore == null
            ? _instance.meanScore
            : (meanScore as double),
        minutesWatched: minutesWatched == _undefined || minutesWatched == null
            ? _instance.minutesWatched
            : (minutesWatched as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$genres<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$genres<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$genres(
      this._res);

  TRes _res;

  call({
    String? genre,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$statistics$anime$tags {
  Query$GetCurrentUserData$Viewer$statistics$anime$tags({
    this.tag,
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    this.$__typename = 'UserTagStatistic',
  });

  factory Query$GetCurrentUserData$Viewer$statistics$anime$tags.fromJson(
      Map<String, dynamic> json) {
    final l$tag = json['tag'];
    final l$count = json['count'];
    final l$meanScore = json['meanScore'];
    final l$minutesWatched = json['minutesWatched'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics$anime$tags(
      tag: l$tag == null
          ? null
          : Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag.fromJson(
              (l$tag as Map<String, dynamic>)),
      count: (l$count as int),
      meanScore: (l$meanScore as num).toDouble(),
      minutesWatched: (l$minutesWatched as int),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag? tag;

  final int count;

  final double meanScore;

  final int minutesWatched;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$tag = tag;
    _resultData['tag'] = l$tag?.toJson();
    final l$count = count;
    _resultData['count'] = l$count;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$minutesWatched = minutesWatched;
    _resultData['minutesWatched'] = l$minutesWatched;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$tag = tag;
    final l$count = count;
    final l$meanScore = meanScore;
    final l$minutesWatched = minutesWatched;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$tag,
      l$count,
      l$meanScore,
      l$minutesWatched,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$statistics$anime$tags ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$tag = tag;
    final lOther$tag = other.tag;
    if (l$tag != lOther$tag) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$minutesWatched = minutesWatched;
    final lOther$minutesWatched = other.minutesWatched;
    if (l$minutesWatched != lOther$minutesWatched) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics$anime$tags
    on Query$GetCurrentUserData$Viewer$statistics$anime$tags {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags<
          Query$GetCurrentUserData$Viewer$statistics$anime$tags>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags(
    Query$GetCurrentUserData$Viewer$statistics$anime$tags instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$tags) then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags;

  TRes call({
    Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag? tag,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  });
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<TRes>
      get tag;
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags<TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags<TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics$anime$tags _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$tags)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? tag = _undefined,
    Object? count = _undefined,
    Object? meanScore = _undefined,
    Object? minutesWatched = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics$anime$tags(
        tag: tag == _undefined
            ? _instance.tag
            : (tag
                as Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag?),
        count: count == _undefined || count == null
            ? _instance.count
            : (count as int),
        meanScore: meanScore == _undefined || meanScore == null
            ? _instance.meanScore
            : (meanScore as double),
        minutesWatched: minutesWatched == _undefined || minutesWatched == null
            ? _instance.minutesWatched
            : (minutesWatched as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<TRes>
      get tag {
    final local$tag = _instance.tag;
    return local$tag == null
        ? CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag
            .stub(_then(_instance))
        : CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
            local$tag, (e) => call(tag: e));
  }
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags<TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags(
      this._res);

  TRes _res;

  call({
    Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag? tag,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<TRes>
      get tag =>
          CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag
              .stub(_res);
}

class Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag {
  Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag({
    required this.id,
    required this.name,
    this.$__typename = 'MediaTag',
  });

  factory Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
      id: (l$id as int),
      name: (l$name as String),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag
    on Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<
          Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
    Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag;

  TRes call({
    int? id,
    String? name,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$tags$tag(
      this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$statistics$anime$formats {
  Query$GetCurrentUserData$Viewer$statistics$anime$formats({
    this.format,
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    this.$__typename = 'UserFormatStatistic',
  });

  factory Query$GetCurrentUserData$Viewer$statistics$anime$formats.fromJson(
      Map<String, dynamic> json) {
    final l$format = json['format'];
    final l$count = json['count'];
    final l$meanScore = json['meanScore'];
    final l$minutesWatched = json['minutesWatched'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics$anime$formats(
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      count: (l$count as int),
      meanScore: (l$meanScore as num).toDouble(),
      minutesWatched: (l$minutesWatched as int),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$MediaFormat? format;

  final int count;

  final double meanScore;

  final int minutesWatched;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$format = format;
    _resultData['format'] =
        l$format == null ? null : toJson$Enum$MediaFormat(l$format);
    final l$count = count;
    _resultData['count'] = l$count;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$minutesWatched = minutesWatched;
    _resultData['minutesWatched'] = l$minutesWatched;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$format = format;
    final l$count = count;
    final l$meanScore = meanScore;
    final l$minutesWatched = minutesWatched;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$format,
      l$count,
      l$meanScore,
      l$minutesWatched,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$statistics$anime$formats ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$format = format;
    final lOther$format = other.format;
    if (l$format != lOther$format) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$minutesWatched = minutesWatched;
    final lOther$minutesWatched = other.minutesWatched;
    if (l$minutesWatched != lOther$minutesWatched) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics$anime$formats
    on Query$GetCurrentUserData$Viewer$statistics$anime$formats {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
          Query$GetCurrentUserData$Viewer$statistics$anime$formats>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats(
    Query$GetCurrentUserData$Viewer$statistics$anime$formats instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$formats)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$formats;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$formats;

  TRes call({
    Enum$MediaFormat? format,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$formats(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics$anime$formats _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$formats)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? format = _undefined,
    Object? count = _undefined,
    Object? meanScore = _undefined,
    Object? minutesWatched = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics$anime$formats(
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        count: count == _undefined || count == null
            ? _instance.count
            : (count as int),
        meanScore: meanScore == _undefined || meanScore == null
            ? _instance.meanScore
            : (meanScore as double),
        minutesWatched: minutesWatched == _undefined || minutesWatched == null
            ? _instance.minutesWatched
            : (minutesWatched as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$formats<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$formats(
      this._res);

  TRes _res;

  call({
    Enum$MediaFormat? format,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetCurrentUserData$Viewer$statistics$anime$statuses {
  Query$GetCurrentUserData$Viewer$statistics$anime$statuses({
    this.status,
    required this.count,
    required this.meanScore,
    required this.minutesWatched,
    this.$__typename = 'UserStatusStatistic',
  });

  factory Query$GetCurrentUserData$Viewer$statistics$anime$statuses.fromJson(
      Map<String, dynamic> json) {
    final l$status = json['status'];
    final l$count = json['count'];
    final l$meanScore = json['meanScore'];
    final l$minutesWatched = json['minutesWatched'];
    final l$$__typename = json['__typename'];
    return Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      count: (l$count as int),
      meanScore: (l$meanScore as num).toDouble(),
      minutesWatched: (l$minutesWatched as int),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$MediaListStatus? status;

  final int count;

  final double meanScore;

  final int minutesWatched;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$count = count;
    _resultData['count'] = l$count;
    final l$meanScore = meanScore;
    _resultData['meanScore'] = l$meanScore;
    final l$minutesWatched = minutesWatched;
    _resultData['minutesWatched'] = l$minutesWatched;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$status = status;
    final l$count = count;
    final l$meanScore = meanScore;
    final l$minutesWatched = minutesWatched;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$status,
      l$count,
      l$meanScore,
      l$minutesWatched,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetCurrentUserData$Viewer$statistics$anime$statuses ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$meanScore = meanScore;
    final lOther$meanScore = other.meanScore;
    if (l$meanScore != lOther$meanScore) {
      return false;
    }
    final l$minutesWatched = minutesWatched;
    final lOther$minutesWatched = other.minutesWatched;
    if (l$minutesWatched != lOther$minutesWatched) {
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

extension UtilityExtension$Query$GetCurrentUserData$Viewer$statistics$anime$statuses
    on Query$GetCurrentUserData$Viewer$statistics$anime$statuses {
  CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
          Query$GetCurrentUserData$Viewer$statistics$anime$statuses>
      get copyWith =>
          CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
    TRes> {
  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
    Query$GetCurrentUserData$Viewer$statistics$anime$statuses instance,
    TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$statuses)
        then,
  ) = _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$statuses;

  factory CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$statuses;

  TRes call({
    Enum$MediaListStatus? status,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
            TRes> {
  _CopyWithImpl$Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
    this._instance,
    this._then,
  );

  final Query$GetCurrentUserData$Viewer$statistics$anime$statuses _instance;

  final TRes Function(Query$GetCurrentUserData$Viewer$statistics$anime$statuses)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? status = _undefined,
    Object? count = _undefined,
    Object? meanScore = _undefined,
    Object? minutesWatched = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        count: count == _undefined || count == null
            ? _instance.count
            : (count as int),
        meanScore: meanScore == _undefined || meanScore == null
            ? _instance.meanScore
            : (meanScore as double),
        minutesWatched: minutesWatched == _undefined || minutesWatched == null
            ? _instance.minutesWatched
            : (minutesWatched as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
        TRes>
    implements
        CopyWith$Query$GetCurrentUserData$Viewer$statistics$anime$statuses<
            TRes> {
  _CopyWithStubImpl$Query$GetCurrentUserData$Viewer$statistics$anime$statuses(
      this._res);

  TRes _res;

  call({
    Enum$MediaListStatus? status,
    int? count,
    double? meanScore,
    int? minutesWatched,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Query$GetUserAnimeLists {
  factory Variables$Query$GetUserAnimeLists({
    String? userName,
    int? userId,
  }) =>
      Variables$Query$GetUserAnimeLists._({
        if (userName != null) r'userName': userName,
        if (userId != null) r'userId': userId,
      });

  Variables$Query$GetUserAnimeLists._(this._$data);

  factory Variables$Query$GetUserAnimeLists.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('userName')) {
      final l$userName = data['userName'];
      result$data['userName'] = (l$userName as String?);
    }
    if (data.containsKey('userId')) {
      final l$userId = data['userId'];
      result$data['userId'] = (l$userId as int?);
    }
    return Variables$Query$GetUserAnimeLists._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get userName => (_$data['userName'] as String?);

  int? get userId => (_$data['userId'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('userName')) {
      final l$userName = userName;
      result$data['userName'] = l$userName;
    }
    if (_$data.containsKey('userId')) {
      final l$userId = userId;
      result$data['userId'] = l$userId;
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetUserAnimeLists<Variables$Query$GetUserAnimeLists>
      get copyWith => CopyWith$Variables$Query$GetUserAnimeLists(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetUserAnimeLists ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$userName = userName;
    final lOther$userName = other.userName;
    if (_$data.containsKey('userName') !=
        other._$data.containsKey('userName')) {
      return false;
    }
    if (l$userName != lOther$userName) {
      return false;
    }
    final l$userId = userId;
    final lOther$userId = other.userId;
    if (_$data.containsKey('userId') != other._$data.containsKey('userId')) {
      return false;
    }
    if (l$userId != lOther$userId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$userName = userName;
    final l$userId = userId;
    return Object.hashAll([
      _$data.containsKey('userName') ? l$userName : const {},
      _$data.containsKey('userId') ? l$userId : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetUserAnimeLists<TRes> {
  factory CopyWith$Variables$Query$GetUserAnimeLists(
    Variables$Query$GetUserAnimeLists instance,
    TRes Function(Variables$Query$GetUserAnimeLists) then,
  ) = _CopyWithImpl$Variables$Query$GetUserAnimeLists;

  factory CopyWith$Variables$Query$GetUserAnimeLists.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetUserAnimeLists;

  TRes call({
    String? userName,
    int? userId,
  });
}

class _CopyWithImpl$Variables$Query$GetUserAnimeLists<TRes>
    implements CopyWith$Variables$Query$GetUserAnimeLists<TRes> {
  _CopyWithImpl$Variables$Query$GetUserAnimeLists(
    this._instance,
    this._then,
  );

  final Variables$Query$GetUserAnimeLists _instance;

  final TRes Function(Variables$Query$GetUserAnimeLists) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userName = _undefined,
    Object? userId = _undefined,
  }) =>
      _then(Variables$Query$GetUserAnimeLists._({
        ..._instance._$data,
        if (userName != _undefined) 'userName': (userName as String?),
        if (userId != _undefined) 'userId': (userId as int?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetUserAnimeLists<TRes>
    implements CopyWith$Variables$Query$GetUserAnimeLists<TRes> {
  _CopyWithStubImpl$Variables$Query$GetUserAnimeLists(this._res);

  TRes _res;

  call({
    String? userName,
    int? userId,
  }) =>
      _res;
}

class Query$GetUserAnimeLists {
  Query$GetUserAnimeLists({
    this.MediaListCollection,
    this.$__typename = 'Query',
  });

  factory Query$GetUserAnimeLists.fromJson(Map<String, dynamic> json) {
    final l$MediaListCollection = json['MediaListCollection'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists(
      MediaListCollection: l$MediaListCollection == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection.fromJson(
              (l$MediaListCollection as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetUserAnimeLists$MediaListCollection? MediaListCollection;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$MediaListCollection = MediaListCollection;
    _resultData['MediaListCollection'] = l$MediaListCollection?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$MediaListCollection = MediaListCollection;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$MediaListCollection,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUserAnimeLists || runtimeType != other.runtimeType) {
      return false;
    }
    final l$MediaListCollection = MediaListCollection;
    final lOther$MediaListCollection = other.MediaListCollection;
    if (l$MediaListCollection != lOther$MediaListCollection) {
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

extension UtilityExtension$Query$GetUserAnimeLists on Query$GetUserAnimeLists {
  CopyWith$Query$GetUserAnimeLists<Query$GetUserAnimeLists> get copyWith =>
      CopyWith$Query$GetUserAnimeLists(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetUserAnimeLists<TRes> {
  factory CopyWith$Query$GetUserAnimeLists(
    Query$GetUserAnimeLists instance,
    TRes Function(Query$GetUserAnimeLists) then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists;

  factory CopyWith$Query$GetUserAnimeLists.stub(TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists;

  TRes call({
    Query$GetUserAnimeLists$MediaListCollection? MediaListCollection,
    String? $__typename,
  });
  CopyWith$Query$GetUserAnimeLists$MediaListCollection<TRes>
      get MediaListCollection;
}

class _CopyWithImpl$Query$GetUserAnimeLists<TRes>
    implements CopyWith$Query$GetUserAnimeLists<TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists _instance;

  final TRes Function(Query$GetUserAnimeLists) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? MediaListCollection = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists(
        MediaListCollection: MediaListCollection == _undefined
            ? _instance.MediaListCollection
            : (MediaListCollection
                as Query$GetUserAnimeLists$MediaListCollection?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetUserAnimeLists$MediaListCollection<TRes>
      get MediaListCollection {
    final local$MediaListCollection = _instance.MediaListCollection;
    return local$MediaListCollection == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection.stub(
            _then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection(
            local$MediaListCollection, (e) => call(MediaListCollection: e));
  }
}

class _CopyWithStubImpl$Query$GetUserAnimeLists<TRes>
    implements CopyWith$Query$GetUserAnimeLists<TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists(this._res);

  TRes _res;

  call({
    Query$GetUserAnimeLists$MediaListCollection? MediaListCollection,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetUserAnimeLists$MediaListCollection<TRes>
      get MediaListCollection =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection.stub(_res);
}

const documentNodeQueryGetUserAnimeLists = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetUserAnimeLists'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'userName')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'userId')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'MediaListCollection'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'userName'),
            value: VariableNode(name: NameNode(value: 'userName')),
          ),
          ArgumentNode(
            name: NameNode(value: 'userId'),
            value: VariableNode(name: NameNode(value: 'userId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'type'),
            value: EnumValueNode(name: NameNode(value: 'ANIME')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'lists'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'name'),
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
                name: NameNode(value: 'entries'),
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
                    name: NameNode(value: 'progress'),
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
                        value: EnumValueNode(name: NameNode(value: 'POINT_10')),
                      )
                    ],
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
                    name: NameNode(value: 'priority'),
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
                    name: NameNode(value: 'updatedAt'),
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
                    name: NameNode(value: 'customLists'),
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
          FieldNode(
            name: NameNode(value: 'user'),
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
                name: NameNode(value: 'name'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'mediaListOptions'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'animeList'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FieldNode(
                        name: NameNode(value: 'customLists'),
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
Query$GetUserAnimeLists _parserFn$Query$GetUserAnimeLists(
        Map<String, dynamic> data) =>
    Query$GetUserAnimeLists.fromJson(data);
typedef OnQueryComplete$Query$GetUserAnimeLists = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetUserAnimeLists?,
);

class Options$Query$GetUserAnimeLists
    extends graphql.QueryOptions<Query$GetUserAnimeLists> {
  Options$Query$GetUserAnimeLists({
    String? operationName,
    Variables$Query$GetUserAnimeLists? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetUserAnimeLists? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetUserAnimeLists? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables?.toJson() ?? {},
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null
                        ? null
                        : _parserFn$Query$GetUserAnimeLists(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetUserAnimeLists,
          parserFn: _parserFn$Query$GetUserAnimeLists,
        );

  final OnQueryComplete$Query$GetUserAnimeLists? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetUserAnimeLists
    extends graphql.WatchQueryOptions<Query$GetUserAnimeLists> {
  WatchOptions$Query$GetUserAnimeLists({
    String? operationName,
    Variables$Query$GetUserAnimeLists? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetUserAnimeLists? typedOptimisticResult,
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
          document: documentNodeQueryGetUserAnimeLists,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetUserAnimeLists,
        );
}

class FetchMoreOptions$Query$GetUserAnimeLists
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetUserAnimeLists({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetUserAnimeLists? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetUserAnimeLists,
        );
}

extension ClientExtension$Query$GetUserAnimeLists on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetUserAnimeLists>> query$GetUserAnimeLists(
          [Options$Query$GetUserAnimeLists? options]) async =>
      await this.query(options ?? Options$Query$GetUserAnimeLists());
  graphql.ObservableQuery<Query$GetUserAnimeLists> watchQuery$GetUserAnimeLists(
          [WatchOptions$Query$GetUserAnimeLists? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetUserAnimeLists());
  void writeQuery$GetUserAnimeLists({
    required Query$GetUserAnimeLists data,
    Variables$Query$GetUserAnimeLists? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetUserAnimeLists),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetUserAnimeLists? readQuery$GetUserAnimeLists({
    Variables$Query$GetUserAnimeLists? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetUserAnimeLists),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetUserAnimeLists.fromJson(result);
  }
}

class Query$GetUserAnimeLists$MediaListCollection {
  Query$GetUserAnimeLists$MediaListCollection({
    this.lists,
    this.user,
    this.$__typename = 'MediaListCollection',
  });

  factory Query$GetUserAnimeLists$MediaListCollection.fromJson(
      Map<String, dynamic> json) {
    final l$lists = json['lists'];
    final l$user = json['user'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection(
      lists: (l$lists as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetUserAnimeLists$MediaListCollection$lists.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      user: l$user == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$user.fromJson(
              (l$user as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetUserAnimeLists$MediaListCollection$lists?>? lists;

  final Query$GetUserAnimeLists$MediaListCollection$user? user;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$lists = lists;
    _resultData['lists'] = l$lists?.map((e) => e?.toJson()).toList();
    final l$user = user;
    _resultData['user'] = l$user?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$lists = lists;
    final l$user = user;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$lists == null ? null : Object.hashAll(l$lists.map((v) => v)),
      l$user,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUserAnimeLists$MediaListCollection ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$lists = lists;
    final lOther$lists = other.lists;
    if (l$lists != null && lOther$lists != null) {
      if (l$lists.length != lOther$lists.length) {
        return false;
      }
      for (int i = 0; i < l$lists.length; i++) {
        final l$lists$entry = l$lists[i];
        final lOther$lists$entry = lOther$lists[i];
        if (l$lists$entry != lOther$lists$entry) {
          return false;
        }
      }
    } else if (l$lists != lOther$lists) {
      return false;
    }
    final l$user = user;
    final lOther$user = other.user;
    if (l$user != lOther$user) {
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection
    on Query$GetUserAnimeLists$MediaListCollection {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection<
          Query$GetUserAnimeLists$MediaListCollection>
      get copyWith => CopyWith$Query$GetUserAnimeLists$MediaListCollection(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection<TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection(
    Query$GetUserAnimeLists$MediaListCollection instance,
    TRes Function(Query$GetUserAnimeLists$MediaListCollection) then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection.stub(TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection;

  TRes call({
    List<Query$GetUserAnimeLists$MediaListCollection$lists?>? lists,
    Query$GetUserAnimeLists$MediaListCollection$user? user,
    String? $__typename,
  });
  TRes lists(
      Iterable<Query$GetUserAnimeLists$MediaListCollection$lists?>? Function(
              Iterable<
                  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists<
                      Query$GetUserAnimeLists$MediaListCollection$lists>?>?)
          _fn);
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<TRes> get user;
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection<TRes>
    implements CopyWith$Query$GetUserAnimeLists$MediaListCollection<TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection _instance;

  final TRes Function(Query$GetUserAnimeLists$MediaListCollection) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? lists = _undefined,
    Object? user = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists$MediaListCollection(
        lists: lists == _undefined
            ? _instance.lists
            : (lists
                as List<Query$GetUserAnimeLists$MediaListCollection$lists?>?),
        user: user == _undefined
            ? _instance.user
            : (user as Query$GetUserAnimeLists$MediaListCollection$user?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes lists(
          Iterable<Query$GetUserAnimeLists$MediaListCollection$lists?>? Function(
                  Iterable<
                      CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists<
                          Query$GetUserAnimeLists$MediaListCollection$lists>?>?)
              _fn) =>
      call(
          lists: _fn(_instance.lists?.map((e) => e == null
              ? null
              : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists(
                  e,
                  (i) => i,
                )))?.toList());

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<TRes> get user {
    final local$user = _instance.user;
    return local$user == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$user.stub(
            _then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$user(
            local$user, (e) => call(user: e));
  }
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection<TRes>
    implements CopyWith$Query$GetUserAnimeLists$MediaListCollection<TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection(this._res);

  TRes _res;

  call({
    List<Query$GetUserAnimeLists$MediaListCollection$lists?>? lists,
    Query$GetUserAnimeLists$MediaListCollection$user? user,
    String? $__typename,
  }) =>
      _res;

  lists(_fn) => _res;

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<TRes> get user =>
      CopyWith$Query$GetUserAnimeLists$MediaListCollection$user.stub(_res);
}

class Query$GetUserAnimeLists$MediaListCollection$lists {
  Query$GetUserAnimeLists$MediaListCollection$lists({
    this.name,
    this.status,
    this.entries,
    this.$__typename = 'MediaListGroup',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists.fromJson(
      Map<String, dynamic> json) {
    final l$name = json['name'];
    final l$status = json['status'];
    final l$entries = json['entries'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists(
      name: (l$name as String?),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      entries: (l$entries as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetUserAnimeLists$MediaListCollection$lists$entries
                  .fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? name;

  final Enum$MediaListStatus? status;

  final List<Query$GetUserAnimeLists$MediaListCollection$lists$entries?>?
      entries;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$name = name;
    _resultData['name'] = l$name;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$entries = entries;
    _resultData['entries'] = l$entries?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$name = name;
    final l$status = status;
    final l$entries = entries;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$name,
      l$status,
      l$entries == null ? null : Object.hashAll(l$entries.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUserAnimeLists$MediaListCollection$lists ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$entries = entries;
    final lOther$entries = other.entries;
    if (l$entries != null && lOther$entries != null) {
      if (l$entries.length != lOther$entries.length) {
        return false;
      }
      for (int i = 0; i < l$entries.length; i++) {
        final l$entries$entry = l$entries[i];
        final lOther$entries$entry = lOther$entries[i];
        if (l$entries$entry != lOther$entries$entry) {
          return false;
        }
      }
    } else if (l$entries != lOther$entries) {
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists
    on Query$GetUserAnimeLists$MediaListCollection$lists {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists<
          Query$GetUserAnimeLists$MediaListCollection$lists>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists(
    Query$GetUserAnimeLists$MediaListCollection$lists instance,
    TRes Function(Query$GetUserAnimeLists$MediaListCollection$lists) then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists;

  TRes call({
    String? name,
    Enum$MediaListStatus? status,
    List<Query$GetUserAnimeLists$MediaListCollection$lists$entries?>? entries,
    String? $__typename,
  });
  TRes entries(
      Iterable<Query$GetUserAnimeLists$MediaListCollection$lists$entries?>? Function(
              Iterable<
                  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
                      Query$GetUserAnimeLists$MediaListCollection$lists$entries>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists<TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists<TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists _instance;

  final TRes Function(Query$GetUserAnimeLists$MediaListCollection$lists) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? name = _undefined,
    Object? status = _undefined,
    Object? entries = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists$MediaListCollection$lists(
        name: name == _undefined ? _instance.name : (name as String?),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        entries: entries == _undefined
            ? _instance.entries
            : (entries as List<
                Query$GetUserAnimeLists$MediaListCollection$lists$entries?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes entries(
          Iterable<Query$GetUserAnimeLists$MediaListCollection$lists$entries?>? Function(
                  Iterable<
                      CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
                          Query$GetUserAnimeLists$MediaListCollection$lists$entries>?>?)
              _fn) =>
      call(
          entries: _fn(_instance.entries?.map((e) => e == null
              ? null
              : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists<TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists<TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists(
      this._res);

  TRes _res;

  call({
    String? name,
    Enum$MediaListStatus? status,
    List<Query$GetUserAnimeLists$MediaListCollection$lists$entries?>? entries,
    String? $__typename,
  }) =>
      _res;

  entries(_fn) => _res;
}

class Query$GetUserAnimeLists$MediaListCollection$lists$entries {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries({
    required this.id,
    required this.mediaId,
    this.status,
    this.progress,
    this.score,
    this.hiddenFromStatusLists,
    this.priority,
    this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.customLists,
    this.media,
    this.$__typename = 'MediaList',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$mediaId = json['mediaId'];
    final l$status = json['status'];
    final l$progress = json['progress'];
    final l$score = json['score'];
    final l$hiddenFromStatusLists = json['hiddenFromStatusLists'];
    final l$priority = json['priority'];
    final l$createdAt = json['createdAt'];
    final l$updatedAt = json['updatedAt'];
    final l$startedAt = json['startedAt'];
    final l$completedAt = json['completedAt'];
    final l$customLists = json['customLists'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries(
      id: (l$id as int),
      mediaId: (l$mediaId as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      progress: (l$progress as int?),
      score: (l$score as num?)?.toDouble(),
      hiddenFromStatusLists: (l$hiddenFromStatusLists as bool?),
      priority: (l$priority as int?),
      createdAt: (l$createdAt as int?),
      updatedAt: (l$updatedAt as int?),
      startedAt: l$startedAt == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt
              .fromJson((l$startedAt as Map<String, dynamic>)),
      completedAt: l$completedAt == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt
              .fromJson((l$completedAt as Map<String, dynamic>)),
      customLists: (l$customLists as dynamic?),
      media: l$media == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$media
              .fromJson((l$media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int mediaId;

  final Enum$MediaListStatus? status;

  final int? progress;

  final double? score;

  final bool? hiddenFromStatusLists;

  final int? priority;

  final int? createdAt;

  final int? updatedAt;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt?
      startedAt;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt?
      completedAt;

  final dynamic? customLists;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media? media;

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
    final l$progress = progress;
    _resultData['progress'] = l$progress;
    final l$score = score;
    _resultData['score'] = l$score;
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    _resultData['hiddenFromStatusLists'] = l$hiddenFromStatusLists;
    final l$priority = priority;
    _resultData['priority'] = l$priority;
    final l$createdAt = createdAt;
    _resultData['createdAt'] = l$createdAt;
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$startedAt = startedAt;
    _resultData['startedAt'] = l$startedAt?.toJson();
    final l$completedAt = completedAt;
    _resultData['completedAt'] = l$completedAt?.toJson();
    final l$customLists = customLists;
    _resultData['customLists'] = l$customLists;
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
    final l$progress = progress;
    final l$score = score;
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    final l$priority = priority;
    final l$createdAt = createdAt;
    final l$updatedAt = updatedAt;
    final l$startedAt = startedAt;
    final l$completedAt = completedAt;
    final l$customLists = customLists;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$mediaId,
      l$status,
      l$progress,
      l$score,
      l$hiddenFromStatusLists,
      l$priority,
      l$createdAt,
      l$updatedAt,
      l$startedAt,
      l$completedAt,
      l$customLists,
      l$media,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUserAnimeLists$MediaListCollection$lists$entries ||
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
    final l$progress = progress;
    final lOther$progress = other.progress;
    if (l$progress != lOther$progress) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
      return false;
    }
    final l$hiddenFromStatusLists = hiddenFromStatusLists;
    final lOther$hiddenFromStatusLists = other.hiddenFromStatusLists;
    if (l$hiddenFromStatusLists != lOther$hiddenFromStatusLists) {
      return false;
    }
    final l$priority = priority;
    final lOther$priority = other.priority;
    if (l$priority != lOther$priority) {
      return false;
    }
    final l$createdAt = createdAt;
    final lOther$createdAt = other.createdAt;
    if (l$createdAt != lOther$createdAt) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
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
    final l$customLists = customLists;
    final lOther$customLists = other.customLists;
    if (l$customLists != lOther$customLists) {
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries instance,
    TRes Function(Query$GetUserAnimeLists$MediaListCollection$lists$entries)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries;

  TRes call({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    int? progress,
    double? score,
    bool? hiddenFromStatusLists,
    int? priority,
    int? createdAt,
    int? updatedAt,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt?
        startedAt,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt?
        completedAt,
    dynamic? customLists,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media? media,
    String? $__typename,
  });
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
      TRes> get startedAt;
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
      TRes> get completedAt;
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<TRes>
      get media;
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries _instance;

  final TRes Function(Query$GetUserAnimeLists$MediaListCollection$lists$entries)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? mediaId = _undefined,
    Object? status = _undefined,
    Object? progress = _undefined,
    Object? score = _undefined,
    Object? hiddenFromStatusLists = _undefined,
    Object? priority = _undefined,
    Object? createdAt = _undefined,
    Object? updatedAt = _undefined,
    Object? startedAt = _undefined,
    Object? completedAt = _undefined,
    Object? customLists = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists$MediaListCollection$lists$entries(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        mediaId: mediaId == _undefined || mediaId == null
            ? _instance.mediaId
            : (mediaId as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        progress:
            progress == _undefined ? _instance.progress : (progress as int?),
        score: score == _undefined ? _instance.score : (score as double?),
        hiddenFromStatusLists: hiddenFromStatusLists == _undefined
            ? _instance.hiddenFromStatusLists
            : (hiddenFromStatusLists as bool?),
        priority:
            priority == _undefined ? _instance.priority : (priority as int?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        startedAt: startedAt == _undefined
            ? _instance.startedAt
            : (startedAt
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt?),
        completedAt: completedAt == _undefined
            ? _instance.completedAt
            : (completedAt
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt?),
        customLists: customLists == _undefined
            ? _instance.customLists
            : (customLists as dynamic?),
        media: media == _undefined
            ? _instance.media
            : (media
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
      TRes> get startedAt {
    final local$startedAt = _instance.startedAt;
    return local$startedAt == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
            local$startedAt, (e) => call(startedAt: e));
  }

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
      TRes> get completedAt {
    final local$completedAt = _instance.completedAt;
    return local$completedAt == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
            local$completedAt, (e) => call(completedAt: e));
  }

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<TRes>
      get media {
    final local$media = _instance.media;
    return local$media == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
            local$media, (e) => call(media: e));
  }
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries(
      this._res);

  TRes _res;

  call({
    int? id,
    int? mediaId,
    Enum$MediaListStatus? status,
    int? progress,
    double? score,
    bool? hiddenFromStatusLists,
    int? priority,
    int? createdAt,
    int? updatedAt,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt?
        startedAt,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt?
        completedAt,
    dynamic? customLists,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media? media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
          TRes>
      get startedAt =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt
              .stub(_res);

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
          TRes>
      get completedAt =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt
              .stub(_res);

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<TRes>
      get media =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media
              .stub(_res);
}

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
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
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$startedAt(
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

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
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
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$completedAt(
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

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$media
    implements Fragment$AnimeCard {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$media({
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

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$media.fromJson(
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
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
              .fromJson((l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
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
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
              .fromJson((l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
              .fromJson((l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      siteUrl: (l$siteUrl as String?),
      mediaListEntry: l$mediaListEntry == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry
              .fromJson((l$mediaListEntry as Map<String, dynamic>)),
    );
  }

  final int id;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title?
      title;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage?
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

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode?
      nextAiringEpisode;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate?
      startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? siteUrl;

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry?
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
    if (other
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$media ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$media {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$media)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media;

  TRes call({
    int? id,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title?
        title,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage?
        coverImage,
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
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode?
        nextAiringEpisode,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate?
        startDate,
    List<String?>? genres,
    String? $__typename,
    String? siteUrl,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry?
        mediaListEntry,
  });
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
      TRes> get title;
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
      TRes> get coverImage;
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
      TRes> get nextAiringEpisode;
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
      TRes> get startDate;
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
      TRes> get mediaListEntry;
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media
      _instance;

  final TRes Function(
      Query$GetUserAnimeLists$MediaListCollection$lists$entries$media) _then;

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
      _then(Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage?),
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
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate?),
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
                as Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry?),
      ));

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
      TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
      TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
      TRes> get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
      TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
      TRes> get mediaListEntry {
    final local$mediaListEntry = _instance.mediaListEntry;
    return local$mediaListEntry == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
            local$mediaListEntry, (e) => call(mediaListEntry: e));
  }
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title?
        title,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage?
        coverImage,
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
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode?
        nextAiringEpisode,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate?
        startDate,
    List<String?>? genres,
    String? $__typename,
    String? siteUrl,
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry?
        mediaListEntry,
  }) =>
      _res;

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
          TRes>
      get title =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
              .stub(_res);

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
          TRes>
      get coverImage =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
              .stub(_res);

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
          TRes>
      get nextAiringEpisode =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
              .stub(_res);

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
          TRes>
      get startDate =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
              .stub(_res);

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
          TRes>
      get mediaListEntry =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry
              .stub(_res);
}

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
    implements Fragment$AnimeCard$title {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
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
    if (other
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
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

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$title(
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

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
    implements Fragment$AnimeCard$coverImage {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
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
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
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

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$coverImage(
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

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
    implements Fragment$AnimeCard$nextAiringEpisode {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
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
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
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

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$nextAiringEpisode(
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

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
    implements Fragment$AnimeCard$startDate {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
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
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$startDate(
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

class Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry {
  Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry({
    required this.id,
    this.$__typename = 'MediaList',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
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
            is! Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry ||
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry
    on Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
    Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry;

  TRes call({
    int? id,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$lists$entries$media$mediaListEntry(
      this._res);

  TRes _res;

  call({
    int? id,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetUserAnimeLists$MediaListCollection$user {
  Query$GetUserAnimeLists$MediaListCollection$user({
    required this.id,
    required this.name,
    this.mediaListOptions,
    this.$__typename = 'User',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$user.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$mediaListOptions = json['mediaListOptions'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$user(
      id: (l$id as int),
      name: (l$name as String),
      mediaListOptions: l$mediaListOptions == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions
              .fromJson((l$mediaListOptions as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions?
      mediaListOptions;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$mediaListOptions = mediaListOptions;
    _resultData['mediaListOptions'] = l$mediaListOptions?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$mediaListOptions = mediaListOptions;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$mediaListOptions,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetUserAnimeLists$MediaListCollection$user ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$mediaListOptions = mediaListOptions;
    final lOther$mediaListOptions = other.mediaListOptions;
    if (l$mediaListOptions != lOther$mediaListOptions) {
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$user
    on Query$GetUserAnimeLists$MediaListCollection$user {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<
          Query$GetUserAnimeLists$MediaListCollection$user>
      get copyWith => CopyWith$Query$GetUserAnimeLists$MediaListCollection$user(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$user(
    Query$GetUserAnimeLists$MediaListCollection$user instance,
    TRes Function(Query$GetUserAnimeLists$MediaListCollection$user) then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$user.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user;

  TRes call({
    int? id,
    String? name,
    Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions?
        mediaListOptions,
    String? $__typename,
  });
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
      TRes> get mediaListOptions;
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user<TRes>
    implements CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$user _instance;

  final TRes Function(Query$GetUserAnimeLists$MediaListCollection$user) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? mediaListOptions = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists$MediaListCollection$user(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        mediaListOptions: mediaListOptions == _undefined
            ? _instance.mediaListOptions
            : (mediaListOptions
                as Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
      TRes> get mediaListOptions {
    final local$mediaListOptions = _instance.mediaListOptions;
    return local$mediaListOptions == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
            local$mediaListOptions, (e) => call(mediaListOptions: e));
  }
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user<TRes>
    implements CopyWith$Query$GetUserAnimeLists$MediaListCollection$user<TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions?
        mediaListOptions,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
          TRes>
      get mediaListOptions =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions
              .stub(_res);
}

class Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions {
  Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions({
    this.animeList,
    this.$__typename = 'MediaListOptions',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions.fromJson(
      Map<String, dynamic> json) {
    final l$animeList = json['animeList'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
      animeList: l$animeList == null
          ? null
          : Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList
              .fromJson((l$animeList as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList?
      animeList;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$animeList = animeList;
    _resultData['animeList'] = l$animeList?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$animeList = animeList;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$animeList,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$animeList = animeList;
    final lOther$animeList = other.animeList;
    if (l$animeList != lOther$animeList) {
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

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions
    on Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
          Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
    Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions;

  TRes call({
    Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList?
        animeList,
    String? $__typename,
  });
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
      TRes> get animeList;
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions
      _instance;

  final TRes Function(
      Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? animeList = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
        animeList: animeList == _undefined
            ? _instance.animeList
            : (animeList
                as Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
      TRes> get animeList {
    final local$animeList = _instance.animeList;
    return local$animeList == null
        ? CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList
            .stub(_then(_instance))
        : CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
            local$animeList, (e) => call(animeList: e));
  }
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions(
      this._res);

  TRes _res;

  call({
    Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList?
        animeList,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
          TRes>
      get animeList =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList
              .stub(_res);
}

class Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList {
  Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList({
    this.customLists,
    this.$__typename = 'MediaListTypeOptions',
  });

  factory Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList.fromJson(
      Map<String, dynamic> json) {
    final l$customLists = json['customLists'];
    final l$$__typename = json['__typename'];
    return Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
      customLists: (l$customLists as List<dynamic>?)
          ?.map((e) => (e as String?))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<String?>? customLists;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$customLists = customLists;
    _resultData['customLists'] = l$customLists?.map((e) => e).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$customLists = customLists;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$customLists == null
          ? null
          : Object.hashAll(l$customLists.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$customLists = customLists;
    final lOther$customLists = other.customLists;
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList
    on Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList {
  CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
          Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList>
      get copyWith =>
          CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
    TRes> {
  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
    Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList
        instance,
    TRes Function(
            Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList)
        then,
  ) = _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList;

  factory CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList;

  TRes call({
    List<String?>? customLists,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
            TRes> {
  _CopyWithImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
    this._instance,
    this._then,
  );

  final Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList
      _instance;

  final TRes Function(
          Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? customLists = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
        customLists: customLists == _undefined
            ? _instance.customLists
            : (customLists as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
        TRes>
    implements
        CopyWith$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList<
            TRes> {
  _CopyWithStubImpl$Query$GetUserAnimeLists$MediaListCollection$user$mediaListOptions$animeList(
      this._res);

  TRes _res;

  call({
    List<String?>? customLists,
    String? $__typename,
  }) =>
      _res;
}
