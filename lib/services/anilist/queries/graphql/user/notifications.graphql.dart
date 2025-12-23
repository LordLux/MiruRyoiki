import '../schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Variables$Query$GetNotifications {
  factory Variables$Query$GetNotifications({
    int? page,
    int? perPage,
    List<Enum$NotificationType?>? type_in,
  }) =>
      Variables$Query$GetNotifications._({
        if (page != null) r'page': page,
        if (perPage != null) r'perPage': perPage,
        if (type_in != null) r'type_in': type_in,
      });

  Variables$Query$GetNotifications._(this._$data);

  factory Variables$Query$GetNotifications.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('page')) {
      final l$page = data['page'];
      result$data['page'] = (l$page as int?);
    }
    if (data.containsKey('perPage')) {
      final l$perPage = data['perPage'];
      result$data['perPage'] = (l$perPage as int?);
    }
    if (data.containsKey('type_in')) {
      final l$type_in = data['type_in'];
      result$data['type_in'] = (l$type_in as List<dynamic>?)
          ?.map((e) =>
              e == null ? null : fromJson$Enum$NotificationType((e as String)))
          .toList();
    }
    return Variables$Query$GetNotifications._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get page => (_$data['page'] as int?);

  int? get perPage => (_$data['perPage'] as int?);

  List<Enum$NotificationType?>? get type_in =>
      (_$data['type_in'] as List<Enum$NotificationType?>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('page')) {
      final l$page = page;
      result$data['page'] = l$page;
    }
    if (_$data.containsKey('perPage')) {
      final l$perPage = perPage;
      result$data['perPage'] = l$perPage;
    }
    if (_$data.containsKey('type_in')) {
      final l$type_in = type_in;
      result$data['type_in'] = l$type_in
          ?.map((e) => e == null ? null : toJson$Enum$NotificationType(e))
          .toList();
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetNotifications<Variables$Query$GetNotifications>
      get copyWith => CopyWith$Variables$Query$GetNotifications(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetNotifications ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$page = page;
    final lOther$page = other.page;
    if (_$data.containsKey('page') != other._$data.containsKey('page')) {
      return false;
    }
    if (l$page != lOther$page) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (_$data.containsKey('perPage') != other._$data.containsKey('perPage')) {
      return false;
    }
    if (l$perPage != lOther$perPage) {
      return false;
    }
    final l$type_in = type_in;
    final lOther$type_in = other.type_in;
    if (_$data.containsKey('type_in') != other._$data.containsKey('type_in')) {
      return false;
    }
    if (l$type_in != null && lOther$type_in != null) {
      if (l$type_in.length != lOther$type_in.length) {
        return false;
      }
      for (int i = 0; i < l$type_in.length; i++) {
        final l$type_in$entry = l$type_in[i];
        final lOther$type_in$entry = lOther$type_in[i];
        if (l$type_in$entry != lOther$type_in$entry) {
          return false;
        }
      }
    } else if (l$type_in != lOther$type_in) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$page = page;
    final l$perPage = perPage;
    final l$type_in = type_in;
    return Object.hashAll([
      _$data.containsKey('page') ? l$page : const {},
      _$data.containsKey('perPage') ? l$perPage : const {},
      _$data.containsKey('type_in')
          ? l$type_in == null
              ? null
              : Object.hashAll(l$type_in.map((v) => v))
          : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetNotifications<TRes> {
  factory CopyWith$Variables$Query$GetNotifications(
    Variables$Query$GetNotifications instance,
    TRes Function(Variables$Query$GetNotifications) then,
  ) = _CopyWithImpl$Variables$Query$GetNotifications;

  factory CopyWith$Variables$Query$GetNotifications.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetNotifications;

  TRes call({
    int? page,
    int? perPage,
    List<Enum$NotificationType?>? type_in,
  });
}

class _CopyWithImpl$Variables$Query$GetNotifications<TRes>
    implements CopyWith$Variables$Query$GetNotifications<TRes> {
  _CopyWithImpl$Variables$Query$GetNotifications(
    this._instance,
    this._then,
  );

  final Variables$Query$GetNotifications _instance;

  final TRes Function(Variables$Query$GetNotifications) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? page = _undefined,
    Object? perPage = _undefined,
    Object? type_in = _undefined,
  }) =>
      _then(Variables$Query$GetNotifications._({
        ..._instance._$data,
        if (page != _undefined) 'page': (page as int?),
        if (perPage != _undefined) 'perPage': (perPage as int?),
        if (type_in != _undefined)
          'type_in': (type_in as List<Enum$NotificationType?>?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetNotifications<TRes>
    implements CopyWith$Variables$Query$GetNotifications<TRes> {
  _CopyWithStubImpl$Variables$Query$GetNotifications(this._res);

  TRes _res;

  call({
    int? page,
    int? perPage,
    List<Enum$NotificationType?>? type_in,
  }) =>
      _res;
}

class Query$GetNotifications {
  Query$GetNotifications({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetNotifications.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications(
      Page: l$Page == null
          ? null
          : Query$GetNotifications$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetNotifications$Page? Page;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Page = Page;
    _resultData['Page'] = l$Page?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Page = Page;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Page,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetNotifications || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Page = Page;
    final lOther$Page = other.Page;
    if (l$Page != lOther$Page) {
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

extension UtilityExtension$Query$GetNotifications on Query$GetNotifications {
  CopyWith$Query$GetNotifications<Query$GetNotifications> get copyWith =>
      CopyWith$Query$GetNotifications(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetNotifications<TRes> {
  factory CopyWith$Query$GetNotifications(
    Query$GetNotifications instance,
    TRes Function(Query$GetNotifications) then,
  ) = _CopyWithImpl$Query$GetNotifications;

  factory CopyWith$Query$GetNotifications.stub(TRes res) =
      _CopyWithStubImpl$Query$GetNotifications;

  TRes call({
    Query$GetNotifications$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetNotifications<TRes>
    implements CopyWith$Query$GetNotifications<TRes> {
  _CopyWithImpl$Query$GetNotifications(
    this._instance,
    this._then,
  );

  final Query$GetNotifications _instance;

  final TRes Function(Query$GetNotifications) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetNotifications(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetNotifications$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetNotifications$Page.stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page(
            local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications<TRes>
    implements CopyWith$Query$GetNotifications<TRes> {
  _CopyWithStubImpl$Query$GetNotifications(this._res);

  TRes _res;

  call({
    Query$GetNotifications$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page<TRes> get Page =>
      CopyWith$Query$GetNotifications$Page.stub(_res);
}

const documentNodeQueryGetNotifications = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetNotifications'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'page')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '1')),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'perPage')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: IntValueNode(value: '25')),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'type_in')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'NotificationType'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'page'),
            value: VariableNode(name: NameNode(value: 'page')),
          ),
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: VariableNode(name: NameNode(value: 'perPage')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'pageInfo'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'total'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'currentPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'lastPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'hasNextPage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'perPage'),
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
            name: NameNode(value: 'notifications'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'type_in'),
                value: VariableNode(name: NameNode(value: 'type_in')),
              )
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              InlineFragmentNode(
                typeCondition: TypeConditionNode(
                    on: NamedTypeNode(
                  name: NameNode(value: 'AiringNotification'),
                  isNonNull: false,
                )),
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
                    name: NameNode(value: 'type'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'animeId'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'episode'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'contexts'),
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
                      FieldNode(
                        name: NameNode(value: 'id'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'title'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'romaji'),
                            alias: null,
                            arguments: [],
                            directives: [],
                            selectionSet: null,
                          ),
                          FieldNode(
                            name: NameNode(value: 'english'),
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
                        name: NameNode(value: 'coverImage'),
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
                            name: NameNode(value: 'medium'),
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
                        name: NameNode(value: 'type'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'format'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'episodes'),
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
              InlineFragmentNode(
                typeCondition: TypeConditionNode(
                    on: NamedTypeNode(
                  name: NameNode(value: 'RelatedMediaAdditionNotification'),
                  isNonNull: false,
                )),
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
                    name: NameNode(value: 'type'),
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
                    name: NameNode(value: 'context'),
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
                      FieldNode(
                        name: NameNode(value: 'id'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'title'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'romaji'),
                            alias: null,
                            arguments: [],
                            directives: [],
                            selectionSet: null,
                          ),
                          FieldNode(
                            name: NameNode(value: 'english'),
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
                        name: NameNode(value: 'coverImage'),
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
                            name: NameNode(value: 'medium'),
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
                        name: NameNode(value: 'type'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'format'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'episodes'),
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
              InlineFragmentNode(
                typeCondition: TypeConditionNode(
                    on: NamedTypeNode(
                  name: NameNode(value: 'MediaDataChangeNotification'),
                  isNonNull: false,
                )),
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
                    name: NameNode(value: 'type'),
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
                    name: NameNode(value: 'context'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'reason'),
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
                      FieldNode(
                        name: NameNode(value: 'id'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'title'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'romaji'),
                            alias: null,
                            arguments: [],
                            directives: [],
                            selectionSet: null,
                          ),
                          FieldNode(
                            name: NameNode(value: 'english'),
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
                        name: NameNode(value: 'coverImage'),
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
                            name: NameNode(value: 'medium'),
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
                        name: NameNode(value: 'type'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'format'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'episodes'),
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
              InlineFragmentNode(
                typeCondition: TypeConditionNode(
                    on: NamedTypeNode(
                  name: NameNode(value: 'MediaMergeNotification'),
                  isNonNull: false,
                )),
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
                    name: NameNode(value: 'type'),
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
                    name: NameNode(value: 'deletedMediaTitles'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'context'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'reason'),
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
                      FieldNode(
                        name: NameNode(value: 'id'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'title'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: SelectionSetNode(selections: [
                          FieldNode(
                            name: NameNode(value: 'romaji'),
                            alias: null,
                            arguments: [],
                            directives: [],
                            selectionSet: null,
                          ),
                          FieldNode(
                            name: NameNode(value: 'english'),
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
                        name: NameNode(value: 'coverImage'),
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
                            name: NameNode(value: 'medium'),
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
                        name: NameNode(value: 'type'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'format'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                      FieldNode(
                        name: NameNode(value: 'episodes'),
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
              InlineFragmentNode(
                typeCondition: TypeConditionNode(
                    on: NamedTypeNode(
                  name: NameNode(value: 'MediaDeletionNotification'),
                  isNonNull: false,
                )),
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
                    name: NameNode(value: 'type'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'deletedMediaTitle'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'context'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'reason'),
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
Query$GetNotifications _parserFn$Query$GetNotifications(
        Map<String, dynamic> data) =>
    Query$GetNotifications.fromJson(data);
typedef OnQueryComplete$Query$GetNotifications = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetNotifications?,
);

class Options$Query$GetNotifications
    extends graphql.QueryOptions<Query$GetNotifications> {
  Options$Query$GetNotifications({
    String? operationName,
    Variables$Query$GetNotifications? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetNotifications? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetNotifications? onComplete,
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
                        : _parserFn$Query$GetNotifications(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetNotifications,
          parserFn: _parserFn$Query$GetNotifications,
        );

  final OnQueryComplete$Query$GetNotifications? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetNotifications
    extends graphql.WatchQueryOptions<Query$GetNotifications> {
  WatchOptions$Query$GetNotifications({
    String? operationName,
    Variables$Query$GetNotifications? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetNotifications? typedOptimisticResult,
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
          document: documentNodeQueryGetNotifications,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetNotifications,
        );
}

class FetchMoreOptions$Query$GetNotifications extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetNotifications({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetNotifications? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetNotifications,
        );
}

extension ClientExtension$Query$GetNotifications on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetNotifications>> query$GetNotifications(
          [Options$Query$GetNotifications? options]) async =>
      await this.query(options ?? Options$Query$GetNotifications());
  graphql.ObservableQuery<Query$GetNotifications> watchQuery$GetNotifications(
          [WatchOptions$Query$GetNotifications? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetNotifications());
  void writeQuery$GetNotifications({
    required Query$GetNotifications data,
    Variables$Query$GetNotifications? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetNotifications),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetNotifications? readQuery$GetNotifications({
    Variables$Query$GetNotifications? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetNotifications),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetNotifications.fromJson(result);
  }
}

class Query$GetNotifications$Page {
  Query$GetNotifications$Page({
    this.pageInfo,
    this.notifications,
    this.$__typename = 'Page',
  });

  factory Query$GetNotifications$Page.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$notifications = json['notifications'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetNotifications$Page$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      notifications: (l$notifications as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetNotifications$Page$notifications.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetNotifications$Page$pageInfo? pageInfo;

  final List<Query$GetNotifications$Page$notifications?>? notifications;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$notifications = notifications;
    _resultData['notifications'] =
        l$notifications?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$notifications = notifications;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$notifications == null
          ? null
          : Object.hashAll(l$notifications.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetNotifications$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$notifications = notifications;
    final lOther$notifications = other.notifications;
    if (l$notifications != null && lOther$notifications != null) {
      if (l$notifications.length != lOther$notifications.length) {
        return false;
      }
      for (int i = 0; i < l$notifications.length; i++) {
        final l$notifications$entry = l$notifications[i];
        final lOther$notifications$entry = lOther$notifications[i];
        if (l$notifications$entry != lOther$notifications$entry) {
          return false;
        }
      }
    } else if (l$notifications != lOther$notifications) {
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

extension UtilityExtension$Query$GetNotifications$Page
    on Query$GetNotifications$Page {
  CopyWith$Query$GetNotifications$Page<Query$GetNotifications$Page>
      get copyWith => CopyWith$Query$GetNotifications$Page(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page<TRes> {
  factory CopyWith$Query$GetNotifications$Page(
    Query$GetNotifications$Page instance,
    TRes Function(Query$GetNotifications$Page) then,
  ) = _CopyWithImpl$Query$GetNotifications$Page;

  factory CopyWith$Query$GetNotifications$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page;

  TRes call({
    Query$GetNotifications$Page$pageInfo? pageInfo,
    List<Query$GetNotifications$Page$notifications?>? notifications,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$pageInfo<TRes> get pageInfo;
  TRes notifications(
      Iterable<Query$GetNotifications$Page$notifications?>? Function(
              Iterable<
                  CopyWith$Query$GetNotifications$Page$notifications<
                      Query$GetNotifications$Page$notifications>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetNotifications$Page<TRes>
    implements CopyWith$Query$GetNotifications$Page<TRes> {
  _CopyWithImpl$Query$GetNotifications$Page(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page _instance;

  final TRes Function(Query$GetNotifications$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? notifications = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetNotifications$Page(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$GetNotifications$Page$pageInfo?),
        notifications: notifications == _undefined
            ? _instance.notifications
            : (notifications
                as List<Query$GetNotifications$Page$notifications?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$pageInfo<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetNotifications$Page$pageInfo.stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes notifications(
          Iterable<Query$GetNotifications$Page$notifications?>? Function(
                  Iterable<
                      CopyWith$Query$GetNotifications$Page$notifications<
                          Query$GetNotifications$Page$notifications>?>?)
              _fn) =>
      call(
          notifications: _fn(_instance.notifications?.map((e) => e == null
              ? null
              : CopyWith$Query$GetNotifications$Page$notifications(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetNotifications$Page<TRes>
    implements CopyWith$Query$GetNotifications$Page<TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page(this._res);

  TRes _res;

  call({
    Query$GetNotifications$Page$pageInfo? pageInfo,
    List<Query$GetNotifications$Page$notifications?>? notifications,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$pageInfo<TRes> get pageInfo =>
      CopyWith$Query$GetNotifications$Page$pageInfo.stub(_res);

  notifications(_fn) => _res;
}

class Query$GetNotifications$Page$pageInfo {
  Query$GetNotifications$Page$pageInfo({
    this.total,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.perPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetNotifications$Page$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$perPage = json['perPage'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$pageInfo(
      total: (l$total as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      perPage: (l$perPage as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final int? perPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$perPage = perPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$perPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetNotifications$Page$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$currentPage = currentPage;
    final lOther$currentPage = other.currentPage;
    if (l$currentPage != lOther$currentPage) {
      return false;
    }
    final l$lastPage = lastPage;
    final lOther$lastPage = other.lastPage;
    if (l$lastPage != lOther$lastPage) {
      return false;
    }
    final l$hasNextPage = hasNextPage;
    final lOther$hasNextPage = other.hasNextPage;
    if (l$hasNextPage != lOther$hasNextPage) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
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

extension UtilityExtension$Query$GetNotifications$Page$pageInfo
    on Query$GetNotifications$Page$pageInfo {
  CopyWith$Query$GetNotifications$Page$pageInfo<
          Query$GetNotifications$Page$pageInfo>
      get copyWith => CopyWith$Query$GetNotifications$Page$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$pageInfo<TRes> {
  factory CopyWith$Query$GetNotifications$Page$pageInfo(
    Query$GetNotifications$Page$pageInfo instance,
    TRes Function(Query$GetNotifications$Page$pageInfo) then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$pageInfo;

  factory CopyWith$Query$GetNotifications$Page$pageInfo.stub(TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$pageInfo;

  TRes call({
    int? total,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    int? perPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$pageInfo<TRes>
    implements CopyWith$Query$GetNotifications$Page$pageInfo<TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$pageInfo _instance;

  final TRes Function(Query$GetNotifications$Page$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? perPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetNotifications$Page$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$pageInfo<TRes>
    implements CopyWith$Query$GetNotifications$Page$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$pageInfo(this._res);

  TRes _res;

  call({
    int? total,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    int? perPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications({required this.$__typename});

  factory Query$GetNotifications$Page$notifications.fromJson(
      Map<String, dynamic> json) {
    switch (json["__typename"] as String) {
      case "AiringNotification":
        return Query$GetNotifications$Page$notifications$$AiringNotification
            .fromJson(json);

      case "RelatedMediaAdditionNotification":
        return Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification
            .fromJson(json);

      case "MediaDataChangeNotification":
        return Query$GetNotifications$Page$notifications$$MediaDataChangeNotification
            .fromJson(json);

      case "MediaMergeNotification":
        return Query$GetNotifications$Page$notifications$$MediaMergeNotification
            .fromJson(json);

      case "MediaDeletionNotification":
        return Query$GetNotifications$Page$notifications$$MediaDeletionNotification
            .fromJson(json);

      case "FollowingNotification":
        return Query$GetNotifications$Page$notifications$$FollowingNotification
            .fromJson(json);

      case "ActivityMessageNotification":
        return Query$GetNotifications$Page$notifications$$ActivityMessageNotification
            .fromJson(json);

      case "ActivityMentionNotification":
        return Query$GetNotifications$Page$notifications$$ActivityMentionNotification
            .fromJson(json);

      case "ActivityReplyNotification":
        return Query$GetNotifications$Page$notifications$$ActivityReplyNotification
            .fromJson(json);

      case "ActivityReplySubscribedNotification":
        return Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification
            .fromJson(json);

      case "ActivityLikeNotification":
        return Query$GetNotifications$Page$notifications$$ActivityLikeNotification
            .fromJson(json);

      case "ActivityReplyLikeNotification":
        return Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification
            .fromJson(json);

      case "ThreadCommentMentionNotification":
        return Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification
            .fromJson(json);

      case "ThreadCommentReplyNotification":
        return Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification
            .fromJson(json);

      case "ThreadCommentSubscribedNotification":
        return Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification
            .fromJson(json);

      case "ThreadCommentLikeNotification":
        return Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification
            .fromJson(json);

      case "ThreadLikeNotification":
        return Query$GetNotifications$Page$notifications$$ThreadLikeNotification
            .fromJson(json);

      default:
        final l$$__typename = json['__typename'];
        return Query$GetNotifications$Page$notifications(
            $__typename: (l$$__typename as String));
    }
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetNotifications$Page$notifications ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications
    on Query$GetNotifications$Page$notifications {
  CopyWith$Query$GetNotifications$Page$notifications<
          Query$GetNotifications$Page$notifications>
      get copyWith => CopyWith$Query$GetNotifications$Page$notifications(
            this,
            (i) => i,
          );
  _T when<_T>({
    required _T Function(
            Query$GetNotifications$Page$notifications$$AiringNotification)
        airingNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification)
        relatedMediaAdditionNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$MediaDataChangeNotification)
        mediaDataChangeNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$MediaMergeNotification)
        mediaMergeNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$MediaDeletionNotification)
        mediaDeletionNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$FollowingNotification)
        followingNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ActivityMessageNotification)
        activityMessageNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ActivityMentionNotification)
        activityMentionNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ActivityReplyNotification)
        activityReplyNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification)
        activityReplySubscribedNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ActivityLikeNotification)
        activityLikeNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification)
        activityReplyLikeNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification)
        threadCommentMentionNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification)
        threadCommentReplyNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification)
        threadCommentSubscribedNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification)
        threadCommentLikeNotification,
    required _T Function(
            Query$GetNotifications$Page$notifications$$ThreadLikeNotification)
        threadLikeNotification,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "AiringNotification":
        return airingNotification(this
            as Query$GetNotifications$Page$notifications$$AiringNotification);

      case "RelatedMediaAdditionNotification":
        return relatedMediaAdditionNotification(this
            as Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification);

      case "MediaDataChangeNotification":
        return mediaDataChangeNotification(this
            as Query$GetNotifications$Page$notifications$$MediaDataChangeNotification);

      case "MediaMergeNotification":
        return mediaMergeNotification(this
            as Query$GetNotifications$Page$notifications$$MediaMergeNotification);

      case "MediaDeletionNotification":
        return mediaDeletionNotification(this
            as Query$GetNotifications$Page$notifications$$MediaDeletionNotification);

      case "FollowingNotification":
        return followingNotification(this
            as Query$GetNotifications$Page$notifications$$FollowingNotification);

      case "ActivityMessageNotification":
        return activityMessageNotification(this
            as Query$GetNotifications$Page$notifications$$ActivityMessageNotification);

      case "ActivityMentionNotification":
        return activityMentionNotification(this
            as Query$GetNotifications$Page$notifications$$ActivityMentionNotification);

      case "ActivityReplyNotification":
        return activityReplyNotification(this
            as Query$GetNotifications$Page$notifications$$ActivityReplyNotification);

      case "ActivityReplySubscribedNotification":
        return activityReplySubscribedNotification(this
            as Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification);

      case "ActivityLikeNotification":
        return activityLikeNotification(this
            as Query$GetNotifications$Page$notifications$$ActivityLikeNotification);

      case "ActivityReplyLikeNotification":
        return activityReplyLikeNotification(this
            as Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification);

      case "ThreadCommentMentionNotification":
        return threadCommentMentionNotification(this
            as Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification);

      case "ThreadCommentReplyNotification":
        return threadCommentReplyNotification(this
            as Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification);

      case "ThreadCommentSubscribedNotification":
        return threadCommentSubscribedNotification(this
            as Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification);

      case "ThreadCommentLikeNotification":
        return threadCommentLikeNotification(this
            as Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification);

      case "ThreadLikeNotification":
        return threadLikeNotification(this
            as Query$GetNotifications$Page$notifications$$ThreadLikeNotification);

      default:
        return orElse();
    }
  }

  _T maybeWhen<_T>({
    _T Function(Query$GetNotifications$Page$notifications$$AiringNotification)?
        airingNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification)?
        relatedMediaAdditionNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$MediaDataChangeNotification)?
        mediaDataChangeNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$MediaMergeNotification)?
        mediaMergeNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$MediaDeletionNotification)?
        mediaDeletionNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$FollowingNotification)?
        followingNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ActivityMessageNotification)?
        activityMessageNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ActivityMentionNotification)?
        activityMentionNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ActivityReplyNotification)?
        activityReplyNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification)?
        activityReplySubscribedNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ActivityLikeNotification)?
        activityLikeNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification)?
        activityReplyLikeNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification)?
        threadCommentMentionNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification)?
        threadCommentReplyNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification)?
        threadCommentSubscribedNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification)?
        threadCommentLikeNotification,
    _T Function(
            Query$GetNotifications$Page$notifications$$ThreadLikeNotification)?
        threadLikeNotification,
    required _T Function() orElse,
  }) {
    switch ($__typename) {
      case "AiringNotification":
        if (airingNotification != null) {
          return airingNotification(this
              as Query$GetNotifications$Page$notifications$$AiringNotification);
        } else {
          return orElse();
        }

      case "RelatedMediaAdditionNotification":
        if (relatedMediaAdditionNotification != null) {
          return relatedMediaAdditionNotification(this
              as Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification);
        } else {
          return orElse();
        }

      case "MediaDataChangeNotification":
        if (mediaDataChangeNotification != null) {
          return mediaDataChangeNotification(this
              as Query$GetNotifications$Page$notifications$$MediaDataChangeNotification);
        } else {
          return orElse();
        }

      case "MediaMergeNotification":
        if (mediaMergeNotification != null) {
          return mediaMergeNotification(this
              as Query$GetNotifications$Page$notifications$$MediaMergeNotification);
        } else {
          return orElse();
        }

      case "MediaDeletionNotification":
        if (mediaDeletionNotification != null) {
          return mediaDeletionNotification(this
              as Query$GetNotifications$Page$notifications$$MediaDeletionNotification);
        } else {
          return orElse();
        }

      case "FollowingNotification":
        if (followingNotification != null) {
          return followingNotification(this
              as Query$GetNotifications$Page$notifications$$FollowingNotification);
        } else {
          return orElse();
        }

      case "ActivityMessageNotification":
        if (activityMessageNotification != null) {
          return activityMessageNotification(this
              as Query$GetNotifications$Page$notifications$$ActivityMessageNotification);
        } else {
          return orElse();
        }

      case "ActivityMentionNotification":
        if (activityMentionNotification != null) {
          return activityMentionNotification(this
              as Query$GetNotifications$Page$notifications$$ActivityMentionNotification);
        } else {
          return orElse();
        }

      case "ActivityReplyNotification":
        if (activityReplyNotification != null) {
          return activityReplyNotification(this
              as Query$GetNotifications$Page$notifications$$ActivityReplyNotification);
        } else {
          return orElse();
        }

      case "ActivityReplySubscribedNotification":
        if (activityReplySubscribedNotification != null) {
          return activityReplySubscribedNotification(this
              as Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification);
        } else {
          return orElse();
        }

      case "ActivityLikeNotification":
        if (activityLikeNotification != null) {
          return activityLikeNotification(this
              as Query$GetNotifications$Page$notifications$$ActivityLikeNotification);
        } else {
          return orElse();
        }

      case "ActivityReplyLikeNotification":
        if (activityReplyLikeNotification != null) {
          return activityReplyLikeNotification(this
              as Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification);
        } else {
          return orElse();
        }

      case "ThreadCommentMentionNotification":
        if (threadCommentMentionNotification != null) {
          return threadCommentMentionNotification(this
              as Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification);
        } else {
          return orElse();
        }

      case "ThreadCommentReplyNotification":
        if (threadCommentReplyNotification != null) {
          return threadCommentReplyNotification(this
              as Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification);
        } else {
          return orElse();
        }

      case "ThreadCommentSubscribedNotification":
        if (threadCommentSubscribedNotification != null) {
          return threadCommentSubscribedNotification(this
              as Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification);
        } else {
          return orElse();
        }

      case "ThreadCommentLikeNotification":
        if (threadCommentLikeNotification != null) {
          return threadCommentLikeNotification(this
              as Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification);
        } else {
          return orElse();
        }

      case "ThreadLikeNotification":
        if (threadLikeNotification != null) {
          return threadLikeNotification(this
              as Query$GetNotifications$Page$notifications$$ThreadLikeNotification);
        } else {
          return orElse();
        }

      default:
        return orElse();
    }
  }
}

abstract class CopyWith$Query$GetNotifications$Page$notifications<TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications(
    Query$GetNotifications$Page$notifications instance,
    TRes Function(Query$GetNotifications$Page$notifications) then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications;

  factory CopyWith$Query$GetNotifications$Page$notifications.stub(TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications<TRes>
    implements CopyWith$Query$GetNotifications$Page$notifications<TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications _instance;

  final TRes Function(Query$GetNotifications$Page$notifications) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Query$GetNotifications$Page$notifications(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications<TRes>
    implements CopyWith$Query$GetNotifications$Page$notifications<TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$AiringNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$AiringNotification({
    required this.id,
    this.type,
    required this.animeId,
    required this.episode,
    this.contexts,
    this.createdAt,
    this.media,
    this.$__typename = 'AiringNotification',
  });

  factory Query$GetNotifications$Page$notifications$$AiringNotification.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$type = json['type'];
    final l$animeId = json['animeId'];
    final l$episode = json['episode'];
    final l$contexts = json['contexts'];
    final l$createdAt = json['createdAt'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$AiringNotification(
      id: (l$id as int),
      type: l$type == null
          ? null
          : fromJson$Enum$NotificationType((l$type as String)),
      animeId: (l$animeId as int),
      episode: (l$episode as int),
      contexts:
          (l$contexts as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      createdAt: (l$createdAt as int?),
      media: l$media == null
          ? null
          : Query$GetNotifications$Page$notifications$$AiringNotification$media
              .fromJson((l$media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$NotificationType? type;

  final int animeId;

  final int episode;

  final List<String?>? contexts;

  final int? createdAt;

  final Query$GetNotifications$Page$notifications$$AiringNotification$media?
      media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$type = type;
    _resultData['type'] =
        l$type == null ? null : toJson$Enum$NotificationType(l$type);
    final l$animeId = animeId;
    _resultData['animeId'] = l$animeId;
    final l$episode = episode;
    _resultData['episode'] = l$episode;
    final l$contexts = contexts;
    _resultData['contexts'] = l$contexts?.map((e) => e).toList();
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
    final l$type = type;
    final l$animeId = animeId;
    final l$episode = episode;
    final l$contexts = contexts;
    final l$createdAt = createdAt;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$type,
      l$animeId,
      l$episode,
      l$contexts == null ? null : Object.hashAll(l$contexts.map((v) => v)),
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
    if (other
            is! Query$GetNotifications$Page$notifications$$AiringNotification ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$animeId = animeId;
    final lOther$animeId = other.animeId;
    if (l$animeId != lOther$animeId) {
      return false;
    }
    final l$episode = episode;
    final lOther$episode = other.episode;
    if (l$episode != lOther$episode) {
      return false;
    }
    final l$contexts = contexts;
    final lOther$contexts = other.contexts;
    if (l$contexts != null && lOther$contexts != null) {
      if (l$contexts.length != lOther$contexts.length) {
        return false;
      }
      for (int i = 0; i < l$contexts.length; i++) {
        final l$contexts$entry = l$contexts[i];
        final lOther$contexts$entry = lOther$contexts[i];
        if (l$contexts$entry != lOther$contexts$entry) {
          return false;
        }
      }
    } else if (l$contexts != lOther$contexts) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$AiringNotification
    on Query$GetNotifications$Page$notifications$$AiringNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification<
          Query$GetNotifications$Page$notifications$$AiringNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification(
    Query$GetNotifications$Page$notifications$$AiringNotification instance,
    TRes Function(Query$GetNotifications$Page$notifications$$AiringNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification;

  TRes call({
    int? id,
    Enum$NotificationType? type,
    int? animeId,
    int? episode,
    List<String?>? contexts,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$AiringNotification$media? media,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
      TRes> get media;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$AiringNotification _instance;

  final TRes Function(
      Query$GetNotifications$Page$notifications$$AiringNotification) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? type = _undefined,
    Object? animeId = _undefined,
    Object? episode = _undefined,
    Object? contexts = _undefined,
    Object? createdAt = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetNotifications$Page$notifications$$AiringNotification(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        type: type == _undefined
            ? _instance.type
            : (type as Enum$NotificationType?),
        animeId: animeId == _undefined || animeId == null
            ? _instance.animeId
            : (animeId as int),
        episode: episode == _undefined || episode == null
            ? _instance.episode
            : (episode as int),
        contexts: contexts == _undefined
            ? _instance.contexts
            : (contexts as List<String?>?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        media: media == _undefined
            ? _instance.media
            : (media
                as Query$GetNotifications$Page$notifications$$AiringNotification$media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
      TRes> get media {
    final local$media = _instance.media;
    return local$media == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media(
            local$media, (e) => call(media: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification(
      this._res);

  TRes _res;

  call({
    int? id,
    Enum$NotificationType? type,
    int? animeId,
    int? episode,
    List<String?>? contexts,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$AiringNotification$media? media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
          TRes>
      get media =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$AiringNotification$media {
  Query$GetNotifications$Page$notifications$$AiringNotification$media({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.episodes,
    this.$__typename = 'Media',
  });

  factory Query$GetNotifications$Page$notifications$$AiringNotification$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$coverImage = json['coverImage'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$episodes = json['episodes'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$AiringNotification$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetNotifications$Page$notifications$$AiringNotification$media$title
              .fromJson((l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage
              .fromJson((l$coverImage as Map<String, dynamic>)),
      type: l$type == null ? null : fromJson$Enum$MediaType((l$type as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      episodes: (l$episodes as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetNotifications$Page$notifications$$AiringNotification$media$title?
      title;

  final Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage?
      coverImage;

  final Enum$MediaType? type;

  final Enum$MediaFormat? format;

  final int? episodes;

  final String $__typename;

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
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$coverImage = coverImage;
    final l$type = type;
    final l$format = format;
    final l$episodes = episodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$coverImage,
      l$type,
      l$format,
      l$episodes,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$AiringNotification$media ||
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
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$AiringNotification$media
    on Query$GetNotifications$Page$notifications$$AiringNotification$media {
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
          Query$GetNotifications$Page$notifications$$AiringNotification$media>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media(
    Query$GetNotifications$Page$notifications$$AiringNotification$media
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$AiringNotification$media)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media;

  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media;

  TRes call({
    int? id,
    Query$GetNotifications$Page$notifications$$AiringNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
      TRes> get title;
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
      TRes> get coverImage;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$AiringNotification$media
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$AiringNotification$media)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImage = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? episodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetNotifications$Page$notifications$$AiringNotification$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Query$GetNotifications$Page$notifications$$AiringNotification$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage?),
        type: type == _undefined ? _instance.type : (type as Enum$MediaType?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
      TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
      TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetNotifications$Page$notifications$$AiringNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
          TRes>
      get title =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title
              .stub(_res);

  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
          TRes>
      get coverImage =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$AiringNotification$media$title {
  Query$GetNotifications$Page$notifications$$AiringNotification$media$title({
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetNotifications$Page$notifications$$AiringNotification$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
      romaji: (l$romaji as String?),
      english: (l$english as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? romaji;

  final String? english;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
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
    final l$romaji = romaji;
    final l$english = english;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
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
            is! Query$GetNotifications$Page$notifications$$AiringNotification$media$title ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$AiringNotification$media$title
    on Query$GetNotifications$Page$notifications$$AiringNotification$media$title {
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
          Query$GetNotifications$Page$notifications$$AiringNotification$media$title>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
    Query$GetNotifications$Page$notifications$$AiringNotification$media$title
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$AiringNotification$media$title)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$title;

  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$title;

  TRes call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$AiringNotification$media$title
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$AiringNotification$media$title)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
        romaji: romaji == _undefined ? _instance.romaji : (romaji as String?),
        english:
            english == _undefined ? _instance.english : (english as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$title<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$title(
      this._res);

  TRes _res;

  call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage {
  Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage({
    this.large,
    this.medium,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$medium = json['medium'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
      large: (l$large as String?),
      medium: (l$medium as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String? medium;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$medium = medium;
    _resultData['medium'] = l$medium;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$medium = medium;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$medium,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
      return false;
    }
    final l$medium = medium;
    final lOther$medium = other.medium;
    if (l$medium != lOther$medium) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage
    on Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage {
  CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
          Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
    Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage;

  factory CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage;

  TRes call({
    String? large,
    String? medium,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? medium = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
        large: large == _undefined ? _instance.large : (large as String?),
        medium: medium == _undefined ? _instance.medium : (medium as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$AiringNotification$media$coverImage(
      this._res);

  TRes _res;

  call({
    String? large,
    String? medium,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification({
    required this.id,
    this.type,
    required this.mediaId,
    this.context,
    this.createdAt,
    this.media,
    this.$__typename = 'RelatedMediaAdditionNotification',
  });

  factory Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$type = json['type'];
    final l$mediaId = json['mediaId'];
    final l$context = json['context'];
    final l$createdAt = json['createdAt'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification(
      id: (l$id as int),
      type: l$type == null
          ? null
          : fromJson$Enum$NotificationType((l$type as String)),
      mediaId: (l$mediaId as int),
      context: (l$context as String?),
      createdAt: (l$createdAt as int?),
      media: l$media == null
          ? null
          : Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media
              .fromJson((l$media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$NotificationType? type;

  final int mediaId;

  final String? context;

  final int? createdAt;

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media?
      media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$type = type;
    _resultData['type'] =
        l$type == null ? null : toJson$Enum$NotificationType(l$type);
    final l$mediaId = mediaId;
    _resultData['mediaId'] = l$mediaId;
    final l$context = context;
    _resultData['context'] = l$context;
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
    final l$type = type;
    final l$mediaId = mediaId;
    final l$context = context;
    final l$createdAt = createdAt;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$type,
      l$mediaId,
      l$context,
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
    if (other
            is! Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$context = context;
    final lOther$context = other.context;
    if (l$context != lOther$context) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification
    on Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification<
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification(
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification;

  TRes call({
    int? id,
    Enum$NotificationType? type,
    int? mediaId,
    String? context,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media?
        media,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
      TRes> get media;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? type = _undefined,
    Object? mediaId = _undefined,
    Object? context = _undefined,
    Object? createdAt = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        type: type == _undefined
            ? _instance.type
            : (type as Enum$NotificationType?),
        mediaId: mediaId == _undefined || mediaId == null
            ? _instance.mediaId
            : (mediaId as int),
        context:
            context == _undefined ? _instance.context : (context as String?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        media: media == _undefined
            ? _instance.media
            : (media
                as Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
      TRes> get media {
    final local$media = _instance.media;
    return local$media == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
            local$media, (e) => call(media: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification(
      this._res);

  TRes _res;

  call({
    int? id,
    Enum$NotificationType? type,
    int? mediaId,
    String? context,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media?
        media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
          TRes>
      get media =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media {
  Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.episodes,
    this.$__typename = 'Media',
  });

  factory Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$coverImage = json['coverImage'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$episodes = json['episodes'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title
              .fromJson((l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage
              .fromJson((l$coverImage as Map<String, dynamic>)),
      type: l$type == null ? null : fromJson$Enum$MediaType((l$type as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      episodes: (l$episodes as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title?
      title;

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage?
      coverImage;

  final Enum$MediaType? type;

  final Enum$MediaFormat? format;

  final int? episodes;

  final String $__typename;

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
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$coverImage = coverImage;
    final l$type = type;
    final l$format = format;
    final l$episodes = episodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$coverImage,
      l$type,
      l$format,
      l$episodes,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media ||
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
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media
    on Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media {
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media;

  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media;

  TRes call({
    int? id,
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
      TRes> get title;
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
      TRes> get coverImage;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImage = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? episodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage?),
        type: type == _undefined ? _instance.type : (type as Enum$MediaType?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
      TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
      TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
          TRes>
      get title =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title
              .stub(_res);

  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
          TRes>
      get coverImage =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title {
  Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title({
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
      romaji: (l$romaji as String?),
      english: (l$english as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? romaji;

  final String? english;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
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
    final l$romaji = romaji;
    final l$english = english;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
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
            is! Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title
    on Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title {
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title;

  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title;

  TRes call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
        romaji: romaji == _undefined ? _instance.romaji : (romaji as String?),
        english:
            english == _undefined ? _instance.english : (english as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$title(
      this._res);

  TRes _res;

  call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage {
  Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage({
    this.large,
    this.medium,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$medium = json['medium'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
      large: (l$large as String?),
      medium: (l$medium as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String? medium;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$medium = medium;
    _resultData['medium'] = l$medium;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$medium = medium;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$medium,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
      return false;
    }
    final l$medium = medium;
    final lOther$medium = other.medium;
    if (l$medium != lOther$medium) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage
    on Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage {
  CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
    Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage;

  factory CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage;

  TRes call({
    String? large,
    String? medium,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? medium = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
        large: large == _undefined ? _instance.large : (large as String?),
        medium: medium == _undefined ? _instance.medium : (medium as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$RelatedMediaAdditionNotification$media$coverImage(
      this._res);

  TRes _res;

  call({
    String? large,
    String? medium,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$MediaDataChangeNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$MediaDataChangeNotification({
    required this.id,
    this.type,
    required this.mediaId,
    this.context,
    this.reason,
    this.createdAt,
    this.media,
    this.$__typename = 'MediaDataChangeNotification',
  });

  factory Query$GetNotifications$Page$notifications$$MediaDataChangeNotification.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$type = json['type'];
    final l$mediaId = json['mediaId'];
    final l$context = json['context'];
    final l$reason = json['reason'];
    final l$createdAt = json['createdAt'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaDataChangeNotification(
      id: (l$id as int),
      type: l$type == null
          ? null
          : fromJson$Enum$NotificationType((l$type as String)),
      mediaId: (l$mediaId as int),
      context: (l$context as String?),
      reason: (l$reason as String?),
      createdAt: (l$createdAt as int?),
      media: l$media == null
          ? null
          : Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media
              .fromJson((l$media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$NotificationType? type;

  final int mediaId;

  final String? context;

  final String? reason;

  final int? createdAt;

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media?
      media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$type = type;
    _resultData['type'] =
        l$type == null ? null : toJson$Enum$NotificationType(l$type);
    final l$mediaId = mediaId;
    _resultData['mediaId'] = l$mediaId;
    final l$context = context;
    _resultData['context'] = l$context;
    final l$reason = reason;
    _resultData['reason'] = l$reason;
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
    final l$type = type;
    final l$mediaId = mediaId;
    final l$context = context;
    final l$reason = reason;
    final l$createdAt = createdAt;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$type,
      l$mediaId,
      l$context,
      l$reason,
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
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaDataChangeNotification ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$context = context;
    final lOther$context = other.context;
    if (l$context != lOther$context) {
      return false;
    }
    final l$reason = reason;
    final lOther$reason = other.reason;
    if (l$reason != lOther$reason) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification
    on Query$GetNotifications$Page$notifications$$MediaDataChangeNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification<
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification(
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaDataChangeNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification;

  TRes call({
    int? id,
    Enum$NotificationType? type,
    int? mediaId,
    String? context,
    String? reason,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media?
        media,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
      TRes> get media;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? type = _undefined,
    Object? mediaId = _undefined,
    Object? context = _undefined,
    Object? reason = _undefined,
    Object? createdAt = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        type: type == _undefined
            ? _instance.type
            : (type as Enum$NotificationType?),
        mediaId: mediaId == _undefined || mediaId == null
            ? _instance.mediaId
            : (mediaId as int),
        context:
            context == _undefined ? _instance.context : (context as String?),
        reason: reason == _undefined ? _instance.reason : (reason as String?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        media: media == _undefined
            ? _instance.media
            : (media
                as Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
      TRes> get media {
    final local$media = _instance.media;
    return local$media == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
            local$media, (e) => call(media: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification(
      this._res);

  TRes _res;

  call({
    int? id,
    Enum$NotificationType? type,
    int? mediaId,
    String? context,
    String? reason,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media?
        media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
          TRes>
      get media =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media {
  Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.episodes,
    this.$__typename = 'Media',
  });

  factory Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$coverImage = json['coverImage'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$episodes = json['episodes'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title
              .fromJson((l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage
              .fromJson((l$coverImage as Map<String, dynamic>)),
      type: l$type == null ? null : fromJson$Enum$MediaType((l$type as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      episodes: (l$episodes as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title?
      title;

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage?
      coverImage;

  final Enum$MediaType? type;

  final Enum$MediaFormat? format;

  final int? episodes;

  final String $__typename;

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
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$coverImage = coverImage;
    final l$type = type;
    final l$format = format;
    final l$episodes = episodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$coverImage,
      l$type,
      l$format,
      l$episodes,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media ||
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
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media
    on Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media;

  TRes call({
    int? id,
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
      TRes> get title;
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
      TRes> get coverImage;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImage = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? episodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage?),
        type: type == _undefined ? _instance.type : (type as Enum$MediaType?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
      TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
      TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
          TRes>
      get title =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title
              .stub(_res);

  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
          TRes>
      get coverImage =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title {
  Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title({
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
      romaji: (l$romaji as String?),
      english: (l$english as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? romaji;

  final String? english;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
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
    final l$romaji = romaji;
    final l$english = english;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
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
            is! Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title
    on Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title;

  TRes call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
        romaji: romaji == _undefined ? _instance.romaji : (romaji as String?),
        english:
            english == _undefined ? _instance.english : (english as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$title(
      this._res);

  TRes _res;

  call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage {
  Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage({
    this.large,
    this.medium,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$medium = json['medium'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
      large: (l$large as String?),
      medium: (l$medium as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String? medium;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$medium = medium;
    _resultData['medium'] = l$medium;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$medium = medium;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$medium,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
      return false;
    }
    final l$medium = medium;
    final lOther$medium = other.medium;
    if (l$medium != lOther$medium) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage
    on Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
    Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage;

  TRes call({
    String? large,
    String? medium,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? medium = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
        large: large == _undefined ? _instance.large : (large as String?),
        medium: medium == _undefined ? _instance.medium : (medium as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDataChangeNotification$media$coverImage(
      this._res);

  TRes _res;

  call({
    String? large,
    String? medium,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$MediaMergeNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$MediaMergeNotification({
    required this.id,
    this.type,
    required this.mediaId,
    this.deletedMediaTitles,
    this.context,
    this.reason,
    this.createdAt,
    this.media,
    this.$__typename = 'MediaMergeNotification',
  });

  factory Query$GetNotifications$Page$notifications$$MediaMergeNotification.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$type = json['type'];
    final l$mediaId = json['mediaId'];
    final l$deletedMediaTitles = json['deletedMediaTitles'];
    final l$context = json['context'];
    final l$reason = json['reason'];
    final l$createdAt = json['createdAt'];
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaMergeNotification(
      id: (l$id as int),
      type: l$type == null
          ? null
          : fromJson$Enum$NotificationType((l$type as String)),
      mediaId: (l$mediaId as int),
      deletedMediaTitles: (l$deletedMediaTitles as List<dynamic>?)
          ?.map((e) => (e as String?))
          .toList(),
      context: (l$context as String?),
      reason: (l$reason as String?),
      createdAt: (l$createdAt as int?),
      media: l$media == null
          ? null
          : Query$GetNotifications$Page$notifications$$MediaMergeNotification$media
              .fromJson((l$media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$NotificationType? type;

  final int mediaId;

  final List<String?>? deletedMediaTitles;

  final String? context;

  final String? reason;

  final int? createdAt;

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification$media?
      media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$type = type;
    _resultData['type'] =
        l$type == null ? null : toJson$Enum$NotificationType(l$type);
    final l$mediaId = mediaId;
    _resultData['mediaId'] = l$mediaId;
    final l$deletedMediaTitles = deletedMediaTitles;
    _resultData['deletedMediaTitles'] =
        l$deletedMediaTitles?.map((e) => e).toList();
    final l$context = context;
    _resultData['context'] = l$context;
    final l$reason = reason;
    _resultData['reason'] = l$reason;
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
    final l$type = type;
    final l$mediaId = mediaId;
    final l$deletedMediaTitles = deletedMediaTitles;
    final l$context = context;
    final l$reason = reason;
    final l$createdAt = createdAt;
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$type,
      l$mediaId,
      l$deletedMediaTitles == null
          ? null
          : Object.hashAll(l$deletedMediaTitles.map((v) => v)),
      l$context,
      l$reason,
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
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaMergeNotification ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$mediaId = mediaId;
    final lOther$mediaId = other.mediaId;
    if (l$mediaId != lOther$mediaId) {
      return false;
    }
    final l$deletedMediaTitles = deletedMediaTitles;
    final lOther$deletedMediaTitles = other.deletedMediaTitles;
    if (l$deletedMediaTitles != null && lOther$deletedMediaTitles != null) {
      if (l$deletedMediaTitles.length != lOther$deletedMediaTitles.length) {
        return false;
      }
      for (int i = 0; i < l$deletedMediaTitles.length; i++) {
        final l$deletedMediaTitles$entry = l$deletedMediaTitles[i];
        final lOther$deletedMediaTitles$entry = lOther$deletedMediaTitles[i];
        if (l$deletedMediaTitles$entry != lOther$deletedMediaTitles$entry) {
          return false;
        }
      }
    } else if (l$deletedMediaTitles != lOther$deletedMediaTitles) {
      return false;
    }
    final l$context = context;
    final lOther$context = other.context;
    if (l$context != lOther$context) {
      return false;
    }
    final l$reason = reason;
    final lOther$reason = other.reason;
    if (l$reason != lOther$reason) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaMergeNotification
    on Query$GetNotifications$Page$notifications$$MediaMergeNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification<
          Query$GetNotifications$Page$notifications$$MediaMergeNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification(
    Query$GetNotifications$Page$notifications$$MediaMergeNotification instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaMergeNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification;

  TRes call({
    int? id,
    Enum$NotificationType? type,
    int? mediaId,
    List<String?>? deletedMediaTitles,
    String? context,
    String? reason,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media?
        media,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
      TRes> get media;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification
      _instance;

  final TRes Function(
      Query$GetNotifications$Page$notifications$$MediaMergeNotification) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? type = _undefined,
    Object? mediaId = _undefined,
    Object? deletedMediaTitles = _undefined,
    Object? context = _undefined,
    Object? reason = _undefined,
    Object? createdAt = _undefined,
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetNotifications$Page$notifications$$MediaMergeNotification(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        type: type == _undefined
            ? _instance.type
            : (type as Enum$NotificationType?),
        mediaId: mediaId == _undefined || mediaId == null
            ? _instance.mediaId
            : (mediaId as int),
        deletedMediaTitles: deletedMediaTitles == _undefined
            ? _instance.deletedMediaTitles
            : (deletedMediaTitles as List<String?>?),
        context:
            context == _undefined ? _instance.context : (context as String?),
        reason: reason == _undefined ? _instance.reason : (reason as String?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        media: media == _undefined
            ? _instance.media
            : (media
                as Query$GetNotifications$Page$notifications$$MediaMergeNotification$media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
      TRes> get media {
    final local$media = _instance.media;
    return local$media == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
            local$media, (e) => call(media: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification(
      this._res);

  TRes _res;

  call({
    int? id,
    Enum$NotificationType? type,
    int? mediaId,
    List<String?>? deletedMediaTitles,
    String? context,
    String? reason,
    int? createdAt,
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media?
        media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
          TRes>
      get media =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$MediaMergeNotification$media {
  Query$GetNotifications$Page$notifications$$MediaMergeNotification$media({
    required this.id,
    this.title,
    this.coverImage,
    this.type,
    this.format,
    this.episodes,
    this.$__typename = 'Media',
  });

  factory Query$GetNotifications$Page$notifications$$MediaMergeNotification$media.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$title = json['title'];
    final l$coverImage = json['coverImage'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$episodes = json['episodes'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title
              .fromJson((l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage
              .fromJson((l$coverImage as Map<String, dynamic>)),
      type: l$type == null ? null : fromJson$Enum$MediaType((l$type as String)),
      format: l$format == null
          ? null
          : fromJson$Enum$MediaFormat((l$format as String)),
      episodes: (l$episodes as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title?
      title;

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage?
      coverImage;

  final Enum$MediaType? type;

  final Enum$MediaFormat? format;

  final int? episodes;

  final String $__typename;

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
    final l$episodes = episodes;
    _resultData['episodes'] = l$episodes;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$title = title;
    final l$coverImage = coverImage;
    final l$type = type;
    final l$format = format;
    final l$episodes = episodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$title,
      l$coverImage,
      l$type,
      l$format,
      l$episodes,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaMergeNotification$media ||
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
    final l$episodes = episodes;
    final lOther$episodes = other.episodes;
    if (l$episodes != lOther$episodes) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media
    on Query$GetNotifications$Page$notifications$$MediaMergeNotification$media {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaMergeNotification$media)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media;

  TRes call({
    int? id,
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  });
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
      TRes> get title;
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
      TRes> get coverImage;
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification$media
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImage = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? episodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title
                as Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage?),
        type: type == _undefined ? _instance.type : (type as Enum$MediaType?),
        format: format == _undefined
            ? _instance.format
            : (format as Enum$MediaFormat?),
        episodes:
            episodes == _undefined ? _instance.episodes : (episodes as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
      TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
      TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage
            .stub(_then(_instance))
        : CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media(
      this._res);

  TRes _res;

  call({
    int? id,
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title?
        title,
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage?
        coverImage,
    Enum$MediaType? type,
    Enum$MediaFormat? format,
    int? episodes,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
          TRes>
      get title =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title
              .stub(_res);

  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
          TRes>
      get coverImage =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage
              .stub(_res);
}

class Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title {
  Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title({
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
      romaji: (l$romaji as String?),
      english: (l$english as String?),
      native: (l$native as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? romaji;

  final String? english;

  final String? native;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
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
    final l$romaji = romaji;
    final l$english = english;
    final l$native = native;
    final l$$__typename = $__typename;
    return Object.hashAll([
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
            is! Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title
    on Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title;

  TRes call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
        romaji: romaji == _undefined ? _instance.romaji : (romaji as String?),
        english:
            english == _undefined ? _instance.english : (english as String?),
        native: native == _undefined ? _instance.native : (native as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$title(
      this._res);

  TRes _res;

  call({
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage {
  Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage({
    this.large,
    this.medium,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$medium = json['medium'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
      large: (l$large as String?),
      medium: (l$medium as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? large;

  final String? medium;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$large = large;
    _resultData['large'] = l$large;
    final l$medium = medium;
    _resultData['medium'] = l$medium;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$large = large;
    final l$medium = medium;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$large,
      l$medium,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$large = large;
    final lOther$large = other.large;
    if (l$large != lOther$large) {
      return false;
    }
    final l$medium = medium;
    final lOther$medium = other.medium;
    if (l$medium != lOther$medium) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage
    on Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
    Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage;

  TRes call({
    String? large,
    String? medium,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? medium = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
        large: large == _undefined ? _instance.large : (large as String?),
        medium: medium == _undefined ? _instance.medium : (medium as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaMergeNotification$media$coverImage(
      this._res);

  TRes _res;

  call({
    String? large,
    String? medium,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$MediaDeletionNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$MediaDeletionNotification({
    required this.id,
    this.type,
    this.deletedMediaTitle,
    this.context,
    this.reason,
    this.createdAt,
    this.$__typename = 'MediaDeletionNotification',
  });

  factory Query$GetNotifications$Page$notifications$$MediaDeletionNotification.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$type = json['type'];
    final l$deletedMediaTitle = json['deletedMediaTitle'];
    final l$context = json['context'];
    final l$reason = json['reason'];
    final l$createdAt = json['createdAt'];
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$MediaDeletionNotification(
      id: (l$id as int),
      type: l$type == null
          ? null
          : fromJson$Enum$NotificationType((l$type as String)),
      deletedMediaTitle: (l$deletedMediaTitle as String?),
      context: (l$context as String?),
      reason: (l$reason as String?),
      createdAt: (l$createdAt as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$NotificationType? type;

  final String? deletedMediaTitle;

  final String? context;

  final String? reason;

  final int? createdAt;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$type = type;
    _resultData['type'] =
        l$type == null ? null : toJson$Enum$NotificationType(l$type);
    final l$deletedMediaTitle = deletedMediaTitle;
    _resultData['deletedMediaTitle'] = l$deletedMediaTitle;
    final l$context = context;
    _resultData['context'] = l$context;
    final l$reason = reason;
    _resultData['reason'] = l$reason;
    final l$createdAt = createdAt;
    _resultData['createdAt'] = l$createdAt;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$type = type;
    final l$deletedMediaTitle = deletedMediaTitle;
    final l$context = context;
    final l$reason = reason;
    final l$createdAt = createdAt;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$type,
      l$deletedMediaTitle,
      l$context,
      l$reason,
      l$createdAt,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$MediaDeletionNotification ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$deletedMediaTitle = deletedMediaTitle;
    final lOther$deletedMediaTitle = other.deletedMediaTitle;
    if (l$deletedMediaTitle != lOther$deletedMediaTitle) {
      return false;
    }
    final l$context = context;
    final lOther$context = other.context;
    if (l$context != lOther$context) {
      return false;
    }
    final l$reason = reason;
    final lOther$reason = other.reason;
    if (l$reason != lOther$reason) {
      return false;
    }
    final l$createdAt = createdAt;
    final lOther$createdAt = other.createdAt;
    if (l$createdAt != lOther$createdAt) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$MediaDeletionNotification
    on Query$GetNotifications$Page$notifications$$MediaDeletionNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification<
          Query$GetNotifications$Page$notifications$$MediaDeletionNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification(
    Query$GetNotifications$Page$notifications$$MediaDeletionNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$MediaDeletionNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDeletionNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDeletionNotification;

  TRes call({
    int? id,
    Enum$NotificationType? type,
    String? deletedMediaTitle,
    String? context,
    String? reason,
    int? createdAt,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDeletionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$MediaDeletionNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$MediaDeletionNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$MediaDeletionNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? type = _undefined,
    Object? deletedMediaTitle = _undefined,
    Object? context = _undefined,
    Object? reason = _undefined,
    Object? createdAt = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(
          Query$GetNotifications$Page$notifications$$MediaDeletionNotification(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        type: type == _undefined
            ? _instance.type
            : (type as Enum$NotificationType?),
        deletedMediaTitle: deletedMediaTitle == _undefined
            ? _instance.deletedMediaTitle
            : (deletedMediaTitle as String?),
        context:
            context == _undefined ? _instance.context : (context as String?),
        reason: reason == _undefined ? _instance.reason : (reason as String?),
        createdAt:
            createdAt == _undefined ? _instance.createdAt : (createdAt as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDeletionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$MediaDeletionNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$MediaDeletionNotification(
      this._res);

  TRes _res;

  call({
    int? id,
    Enum$NotificationType? type,
    String? deletedMediaTitle,
    String? context,
    String? reason,
    int? createdAt,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetNotifications$Page$notifications$$FollowingNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$FollowingNotification(
      {this.$__typename = 'FollowingNotification'});

  factory Query$GetNotifications$Page$notifications$$FollowingNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$FollowingNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$FollowingNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$FollowingNotification
    on Query$GetNotifications$Page$notifications$$FollowingNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification<
          Query$GetNotifications$Page$notifications$$FollowingNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification(
    Query$GetNotifications$Page$notifications$$FollowingNotification instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$FollowingNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$FollowingNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$FollowingNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$FollowingNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$FollowingNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$FollowingNotification
      _instance;

  final TRes Function(
      Query$GetNotifications$Page$notifications$$FollowingNotification) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Query$GetNotifications$Page$notifications$$FollowingNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$FollowingNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$FollowingNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$FollowingNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ActivityMessageNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
      {this.$__typename = 'ActivityMessageNotification'});

  factory Query$GetNotifications$Page$notifications$$ActivityMessageNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ActivityMessageNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ActivityMessageNotification
    on Query$GetNotifications$Page$notifications$$ActivityMessageNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification<
          Query$GetNotifications$Page$notifications$$ActivityMessageNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
    Query$GetNotifications$Page$notifications$$ActivityMessageNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ActivityMessageNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityMessageNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityMessageNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityMessageNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ActivityMessageNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ActivityMessageNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityMessageNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityMessageNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityMessageNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ActivityMentionNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
      {this.$__typename = 'ActivityMentionNotification'});

  factory Query$GetNotifications$Page$notifications$$ActivityMentionNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ActivityMentionNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ActivityMentionNotification
    on Query$GetNotifications$Page$notifications$$ActivityMentionNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification<
          Query$GetNotifications$Page$notifications$$ActivityMentionNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
    Query$GetNotifications$Page$notifications$$ActivityMentionNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ActivityMentionNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityMentionNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityMentionNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityMentionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ActivityMentionNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ActivityMentionNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityMentionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityMentionNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityMentionNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ActivityReplyNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
      {this.$__typename = 'ActivityReplyNotification'});

  factory Query$GetNotifications$Page$notifications$$ActivityReplyNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ActivityReplyNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ActivityReplyNotification
    on Query$GetNotifications$Page$notifications$$ActivityReplyNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification<
          Query$GetNotifications$Page$notifications$$ActivityReplyNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
    Query$GetNotifications$Page$notifications$$ActivityReplyNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ActivityReplyNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplyNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplyNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplyNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ActivityReplyNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ActivityReplyNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplyNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplyNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
      {this.$__typename = 'ActivityReplySubscribedNotification'});

  factory Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification
    on Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification<
          Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
    Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplySubscribedNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ActivityLikeNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
      {this.$__typename = 'ActivityLikeNotification'});

  factory Query$GetNotifications$Page$notifications$$ActivityLikeNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ActivityLikeNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ActivityLikeNotification
    on Query$GetNotifications$Page$notifications$$ActivityLikeNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification<
          Query$GetNotifications$Page$notifications$$ActivityLikeNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
    Query$GetNotifications$Page$notifications$$ActivityLikeNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ActivityLikeNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityLikeNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityLikeNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ActivityLikeNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ActivityLikeNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityLikeNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityLikeNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
      {this.$__typename = 'ActivityReplyLikeNotification'});

  factory Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification
    on Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification<
          Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
    Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ActivityReplyLikeNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
      {this.$__typename = 'ThreadCommentMentionNotification'});

  factory Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification
    on Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification<
          Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
    Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentMentionNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
      {this.$__typename = 'ThreadCommentReplyNotification'});

  factory Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification
    on Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification<
          Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
    Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentReplyNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
      {this.$__typename = 'ThreadCommentSubscribedNotification'});

  factory Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification
    on Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification<
          Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
    Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentSubscribedNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
      {this.$__typename = 'ThreadCommentLikeNotification'});

  factory Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification
    on Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification<
          Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
    Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification
        instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification
      _instance;

  final TRes Function(
          Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(
      Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadCommentLikeNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

class Query$GetNotifications$Page$notifications$$ThreadLikeNotification
    implements Query$GetNotifications$Page$notifications {
  Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
      {this.$__typename = 'ThreadLikeNotification'});

  factory Query$GetNotifications$Page$notifications$$ThreadLikeNotification.fromJson(
      Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
        $__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other
            is! Query$GetNotifications$Page$notifications$$ThreadLikeNotification ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetNotifications$Page$notifications$$ThreadLikeNotification
    on Query$GetNotifications$Page$notifications$$ThreadLikeNotification {
  CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification<
          Query$GetNotifications$Page$notifications$$ThreadLikeNotification>
      get copyWith =>
          CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification<
    TRes> {
  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
    Query$GetNotifications$Page$notifications$$ThreadLikeNotification instance,
    TRes Function(
            Query$GetNotifications$Page$notifications$$ThreadLikeNotification)
        then,
  ) = _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadLikeNotification;

  factory CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadLikeNotification;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification<
            TRes> {
  _CopyWithImpl$Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
    this._instance,
    this._then,
  );

  final Query$GetNotifications$Page$notifications$$ThreadLikeNotification
      _instance;

  final TRes Function(
      Query$GetNotifications$Page$notifications$$ThreadLikeNotification) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) =>
      _then(Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadLikeNotification<
        TRes>
    implements
        CopyWith$Query$GetNotifications$Page$notifications$$ThreadLikeNotification<
            TRes> {
  _CopyWithStubImpl$Query$GetNotifications$Page$notifications$$ThreadLikeNotification(
      this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}
