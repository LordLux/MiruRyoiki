import '../common/fragments.graphql.dart';
import '../schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Variables$Query$GetAnimeOverview {
  factory Variables$Query$GetAnimeOverview({required int id}) =>
      Variables$Query$GetAnimeOverview._({
        r'id': id,
      });

  Variables$Query$GetAnimeOverview._(this._$data);

  factory Variables$Query$GetAnimeOverview.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Query$GetAnimeOverview._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetAnimeOverview<Variables$Query$GetAnimeOverview>
      get copyWith => CopyWith$Variables$Query$GetAnimeOverview(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetAnimeOverview ||
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

abstract class CopyWith$Variables$Query$GetAnimeOverview<TRes> {
  factory CopyWith$Variables$Query$GetAnimeOverview(
    Variables$Query$GetAnimeOverview instance,
    TRes Function(Variables$Query$GetAnimeOverview) then,
  ) = _CopyWithImpl$Variables$Query$GetAnimeOverview;

  factory CopyWith$Variables$Query$GetAnimeOverview.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetAnimeOverview;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Query$GetAnimeOverview<TRes>
    implements CopyWith$Variables$Query$GetAnimeOverview<TRes> {
  _CopyWithImpl$Variables$Query$GetAnimeOverview(
    this._instance,
    this._then,
  );

  final Variables$Query$GetAnimeOverview _instance;

  final TRes Function(Variables$Query$GetAnimeOverview) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Query$GetAnimeOverview._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetAnimeOverview<TRes>
    implements CopyWith$Variables$Query$GetAnimeOverview<TRes> {
  _CopyWithStubImpl$Variables$Query$GetAnimeOverview(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Query$GetAnimeOverview {
  Query$GetAnimeOverview({
    this.Media,
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetAnimeOverview.fromJson(Map<String, dynamic> json) {
    final l$Media = json['Media'];
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview(
      Media: l$Media == null
          ? null
          : Query$GetAnimeOverview$Media.fromJson(
              (l$Media as Map<String, dynamic>)),
      Page: l$Page == null
          ? null
          : Query$GetAnimeOverview$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeOverview$Media? Media;

  final Query$GetAnimeOverview$Page? Page;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Media = Media;
    _resultData['Media'] = l$Media?.toJson();
    final l$Page = Page;
    _resultData['Page'] = l$Page?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Media = Media;
    final l$Page = Page;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Media,
      l$Page,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Media = Media;
    final lOther$Media = other.Media;
    if (l$Media != lOther$Media) {
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

extension UtilityExtension$Query$GetAnimeOverview on Query$GetAnimeOverview {
  CopyWith$Query$GetAnimeOverview<Query$GetAnimeOverview> get copyWith =>
      CopyWith$Query$GetAnimeOverview(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeOverview<TRes> {
  factory CopyWith$Query$GetAnimeOverview(
    Query$GetAnimeOverview instance,
    TRes Function(Query$GetAnimeOverview) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview;

  factory CopyWith$Query$GetAnimeOverview.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview;

  TRes call({
    Query$GetAnimeOverview$Media? Media,
    Query$GetAnimeOverview$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeOverview$Media<TRes> get Media;
  CopyWith$Query$GetAnimeOverview$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetAnimeOverview<TRes>
    implements CopyWith$Query$GetAnimeOverview<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview _instance;

  final TRes Function(Query$GetAnimeOverview) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Media = _undefined,
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview(
        Media: Media == _undefined
            ? _instance.Media
            : (Media as Query$GetAnimeOverview$Media?),
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetAnimeOverview$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeOverview$Media<TRes> get Media {
    final local$Media = _instance.Media;
    return local$Media == null
        ? CopyWith$Query$GetAnimeOverview$Media.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media(
            local$Media, (e) => call(Media: e));
  }

  CopyWith$Query$GetAnimeOverview$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetAnimeOverview$Page.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Page(
            local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview<TRes>
    implements CopyWith$Query$GetAnimeOverview<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview(this._res);

  TRes _res;

  call({
    Query$GetAnimeOverview$Media? Media,
    Query$GetAnimeOverview$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Media<TRes> get Media =>
      CopyWith$Query$GetAnimeOverview$Media.stub(_res);

  CopyWith$Query$GetAnimeOverview$Page<TRes> get Page =>
      CopyWith$Query$GetAnimeOverview$Page.stub(_res);
}

const documentNodeQueryGetAnimeOverview = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetAnimeOverview'),
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
        name: NameNode(value: 'Media'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          ),
          ArgumentNode(
            name: NameNode(value: 'type'),
            value: EnumValueNode(name: NameNode(value: 'ANIME')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'AnimeOverview'),
            directives: [],
          ),
          FieldNode(
            name: NameNode(value: 'stats'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'statusDistribution'),
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
                    name: NameNode(value: 'amount'),
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
                name: NameNode(value: 'scoreDistribution'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'score'),
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
            name: NameNode(value: 'relations'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'edges'),
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
                    name: NameNode(value: 'relationType'),
                    alias: null,
                    arguments: [
                      ArgumentNode(
                        name: NameNode(value: 'version'),
                        value: IntValueNode(value: '2'),
                      )
                    ],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'node'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'AnimeCard'),
                        directives: [],
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
            name: NameNode(value: 'characters'),
            alias: NameNode(value: 'characterPreview'),
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'perPage'),
                value: IntValueNode(value: '6'),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'ROLE')),
                  EnumValueNode(name: NameNode(value: 'RELEVANCE')),
                  EnumValueNode(name: NameNode(value: 'ID')),
                ]),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'edges'),
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
                    name: NameNode(value: 'role'),
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
                    name: NameNode(value: 'voiceActors'),
                    alias: null,
                    arguments: [
                      ArgumentNode(
                        name: NameNode(value: 'language'),
                        value: EnumValueNode(name: NameNode(value: 'JAPANESE')),
                      ),
                      ArgumentNode(
                        name: NameNode(value: 'sort'),
                        value: ListValueNode(values: [
                          EnumValueNode(name: NameNode(value: 'RELEVANCE')),
                          EnumValueNode(name: NameNode(value: 'ID')),
                        ]),
                      ),
                    ],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'StaffCard'),
                        directives: [],
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
                    name: NameNode(value: 'node'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'CharacterCard'),
                        directives: [],
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
            name: NameNode(value: 'staff'),
            alias: NameNode(value: 'staffPreview'),
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'perPage'),
                value: IntValueNode(value: '4'),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'RELEVANCE')),
                  EnumValueNode(name: NameNode(value: 'ID')),
                ]),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'edges'),
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
                    name: NameNode(value: 'role'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'node'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'StaffCard'),
                        directives: [],
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
            name: NameNode(value: 'studios'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'edges'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'isMain'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'node'),
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
            name: NameNode(value: 'recommendations'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'perPage'),
                value: IntValueNode(value: '7'),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'RATING_DESC')),
                  EnumValueNode(name: NameNode(value: 'ID')),
                ]),
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
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
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
                    name: NameNode(value: 'rating'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'userRating'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'mediaRecommendation'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'AnimeCard'),
                        directives: [],
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
                      FragmentSpreadNode(
                        name: NameNode(value: 'UserAvatar'),
                        directives: [],
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
            name: NameNode(value: 'externalLinks'),
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
                name: NameNode(value: 'site'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'url'),
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
                name: NameNode(value: 'language'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'color'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'icon'),
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
                name: NameNode(value: 'isDisabled'),
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
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: IntValueNode(value: '8'),
          )
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
                name: NameNode(value: 'perPage'),
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
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: 'mediaList'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'mediaId'),
                value: VariableNode(name: NameNode(value: 'id')),
              ),
              ArgumentNode(
                name: NameNode(value: 'isFollowing'),
                value: BooleanValueNode(value: true),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'UPDATED_TIME_DESC'))
                ]),
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
                name: NameNode(value: 'score'),
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
                    name: NameNode(value: 'mediaListOptions'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FieldNode(
                        name: NameNode(value: 'scoreFormat'),
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
  fragmentDefinitionAnimeOverview,
  fragmentDefinitionAnimeCard,
  fragmentDefinitionStaffCard,
  fragmentDefinitionCharacterCard,
  fragmentDefinitionUserAvatar,
]);
Query$GetAnimeOverview _parserFn$Query$GetAnimeOverview(
        Map<String, dynamic> data) =>
    Query$GetAnimeOverview.fromJson(data);
typedef OnQueryComplete$Query$GetAnimeOverview = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetAnimeOverview?,
);

class Options$Query$GetAnimeOverview
    extends graphql.QueryOptions<Query$GetAnimeOverview> {
  Options$Query$GetAnimeOverview({
    String? operationName,
    required Variables$Query$GetAnimeOverview variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeOverview? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetAnimeOverview? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                        : _parserFn$Query$GetAnimeOverview(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetAnimeOverview,
          parserFn: _parserFn$Query$GetAnimeOverview,
        );

  final OnQueryComplete$Query$GetAnimeOverview? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetAnimeOverview
    extends graphql.WatchQueryOptions<Query$GetAnimeOverview> {
  WatchOptions$Query$GetAnimeOverview({
    String? operationName,
    required Variables$Query$GetAnimeOverview variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeOverview? typedOptimisticResult,
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
          document: documentNodeQueryGetAnimeOverview,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetAnimeOverview,
        );
}

class FetchMoreOptions$Query$GetAnimeOverview extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetAnimeOverview({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetAnimeOverview variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetAnimeOverview,
        );
}

extension ClientExtension$Query$GetAnimeOverview on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetAnimeOverview>> query$GetAnimeOverview(
          Options$Query$GetAnimeOverview options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetAnimeOverview> watchQuery$GetAnimeOverview(
          WatchOptions$Query$GetAnimeOverview options) =>
      this.watchQuery(options);
  void writeQuery$GetAnimeOverview({
    required Query$GetAnimeOverview data,
    required Variables$Query$GetAnimeOverview variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetAnimeOverview),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetAnimeOverview? readQuery$GetAnimeOverview({
    required Variables$Query$GetAnimeOverview variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetAnimeOverview),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetAnimeOverview.fromJson(result);
  }
}

class Query$GetAnimeOverview$Media
    implements Fragment$AnimeOverview, Fragment$AnimeCard {
  Query$GetAnimeOverview$Media({
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
    this.bannerImage,
    this.description,
    this.endDate,
    this.trending,
    this.favourites,
    this.updatedAt,
    this.siteUrl,
    this.duration,
    this.hashtag,
    this.synonyms,
    this.source,
    this.isLocked,
    required this.isFavouriteBlocked,
    this.countryOfOrigin,
    this.isLicensed,
    this.isRecommendationBlocked,
    this.isReviewBlocked,
    this.streamingEpisodes,
    this.trailer,
    this.rankings,
    this.tags,
    this.mediaListEntry,
    this.stats,
    this.relations,
    this.characterPreview,
    this.staffPreview,
    this.studios,
    this.recommendations,
    this.externalLinks,
  });

  factory Query$GetAnimeOverview$Media.fromJson(Map<String, dynamic> json) {
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
    final l$bannerImage = json['bannerImage'];
    final l$description = json['description'];
    final l$endDate = json['endDate'];
    final l$trending = json['trending'];
    final l$favourites = json['favourites'];
    final l$updatedAt = json['updatedAt'];
    final l$siteUrl = json['siteUrl'];
    final l$duration = json['duration'];
    final l$hashtag = json['hashtag'];
    final l$synonyms = json['synonyms'];
    final l$source = json['source'];
    final l$isLocked = json['isLocked'];
    final l$isFavouriteBlocked = json['isFavouriteBlocked'];
    final l$countryOfOrigin = json['countryOfOrigin'];
    final l$isLicensed = json['isLicensed'];
    final l$isRecommendationBlocked = json['isRecommendationBlocked'];
    final l$isReviewBlocked = json['isReviewBlocked'];
    final l$streamingEpisodes = json['streamingEpisodes'];
    final l$trailer = json['trailer'];
    final l$rankings = json['rankings'];
    final l$tags = json['tags'];
    final l$mediaListEntry = json['mediaListEntry'];
    final l$stats = json['stats'];
    final l$relations = json['relations'];
    final l$characterPreview = json['characterPreview'];
    final l$staffPreview = json['staffPreview'];
    final l$studios = json['studios'];
    final l$recommendations = json['recommendations'];
    final l$externalLinks = json['externalLinks'];
    return Query$GetAnimeOverview$Media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetAnimeOverview$Media$title.fromJson(
              (l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetAnimeOverview$Media$coverImage.fromJson(
              (l$coverImage as Map<String, dynamic>)),
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
          : Query$GetAnimeOverview$Media$nextAiringEpisode.fromJson(
              (l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Query$GetAnimeOverview$Media$startDate.fromJson(
              (l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      bannerImage: (l$bannerImage as String?),
      description: (l$description as String?),
      endDate: l$endDate == null
          ? null
          : Query$GetAnimeOverview$Media$endDate.fromJson(
              (l$endDate as Map<String, dynamic>)),
      trending: (l$trending as int?),
      favourites: (l$favourites as int?),
      updatedAt: (l$updatedAt as int?),
      siteUrl: (l$siteUrl as String?),
      duration: (l$duration as int?),
      hashtag: (l$hashtag as String?),
      synonyms:
          (l$synonyms as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      source: l$source == null
          ? null
          : fromJson$Enum$MediaSource((l$source as String)),
      isLocked: (l$isLocked as bool?),
      isFavouriteBlocked: (l$isFavouriteBlocked as bool),
      countryOfOrigin: (l$countryOfOrigin as String?),
      isLicensed: (l$isLicensed as bool?),
      isRecommendationBlocked: (l$isRecommendationBlocked as bool?),
      isReviewBlocked: (l$isReviewBlocked as bool?),
      streamingEpisodes: (l$streamingEpisodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$streamingEpisodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      trailer: l$trailer == null
          ? null
          : Query$GetAnimeOverview$Media$trailer.fromJson(
              (l$trailer as Map<String, dynamic>)),
      rankings: (l$rankings as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$rankings.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      tags: (l$tags as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$tags.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      mediaListEntry: l$mediaListEntry == null
          ? null
          : Query$GetAnimeOverview$Media$mediaListEntry.fromJson(
              (l$mediaListEntry as Map<String, dynamic>)),
      stats: l$stats == null
          ? null
          : Query$GetAnimeOverview$Media$stats.fromJson(
              (l$stats as Map<String, dynamic>)),
      relations: l$relations == null
          ? null
          : Query$GetAnimeOverview$Media$relations.fromJson(
              (l$relations as Map<String, dynamic>)),
      characterPreview: l$characterPreview == null
          ? null
          : Query$GetAnimeOverview$Media$characterPreview.fromJson(
              (l$characterPreview as Map<String, dynamic>)),
      staffPreview: l$staffPreview == null
          ? null
          : Query$GetAnimeOverview$Media$staffPreview.fromJson(
              (l$staffPreview as Map<String, dynamic>)),
      studios: l$studios == null
          ? null
          : Query$GetAnimeOverview$Media$studios.fromJson(
              (l$studios as Map<String, dynamic>)),
      recommendations: l$recommendations == null
          ? null
          : Query$GetAnimeOverview$Media$recommendations.fromJson(
              (l$recommendations as Map<String, dynamic>)),
      externalLinks: (l$externalLinks as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$externalLinks.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
    );
  }

  final int id;

  final Query$GetAnimeOverview$Media$title? title;

  final Query$GetAnimeOverview$Media$coverImage? coverImage;

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

  final Query$GetAnimeOverview$Media$nextAiringEpisode? nextAiringEpisode;

  final Query$GetAnimeOverview$Media$startDate? startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? bannerImage;

  final String? description;

  final Query$GetAnimeOverview$Media$endDate? endDate;

  final int? trending;

  final int? favourites;

  final int? updatedAt;

  final String? siteUrl;

  final int? duration;

  final String? hashtag;

  final List<String?>? synonyms;

  final Enum$MediaSource? source;

  final bool? isLocked;

  final bool isFavouriteBlocked;

  final String? countryOfOrigin;

  final bool? isLicensed;

  final bool? isRecommendationBlocked;

  final bool? isReviewBlocked;

  final List<Query$GetAnimeOverview$Media$streamingEpisodes?>?
      streamingEpisodes;

  final Query$GetAnimeOverview$Media$trailer? trailer;

  final List<Query$GetAnimeOverview$Media$rankings?>? rankings;

  final List<Query$GetAnimeOverview$Media$tags?>? tags;

  final Query$GetAnimeOverview$Media$mediaListEntry? mediaListEntry;

  final Query$GetAnimeOverview$Media$stats? stats;

  final Query$GetAnimeOverview$Media$relations? relations;

  final Query$GetAnimeOverview$Media$characterPreview? characterPreview;

  final Query$GetAnimeOverview$Media$staffPreview? staffPreview;

  final Query$GetAnimeOverview$Media$studios? studios;

  final Query$GetAnimeOverview$Media$recommendations? recommendations;

  final List<Query$GetAnimeOverview$Media$externalLinks?>? externalLinks;

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
    final l$bannerImage = bannerImage;
    _resultData['bannerImage'] = l$bannerImage;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$endDate = endDate;
    _resultData['endDate'] = l$endDate?.toJson();
    final l$trending = trending;
    _resultData['trending'] = l$trending;
    final l$favourites = favourites;
    _resultData['favourites'] = l$favourites;
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$duration = duration;
    _resultData['duration'] = l$duration;
    final l$hashtag = hashtag;
    _resultData['hashtag'] = l$hashtag;
    final l$synonyms = synonyms;
    _resultData['synonyms'] = l$synonyms?.map((e) => e).toList();
    final l$source = source;
    _resultData['source'] =
        l$source == null ? null : toJson$Enum$MediaSource(l$source);
    final l$isLocked = isLocked;
    _resultData['isLocked'] = l$isLocked;
    final l$isFavouriteBlocked = isFavouriteBlocked;
    _resultData['isFavouriteBlocked'] = l$isFavouriteBlocked;
    final l$countryOfOrigin = countryOfOrigin;
    _resultData['countryOfOrigin'] = l$countryOfOrigin;
    final l$isLicensed = isLicensed;
    _resultData['isLicensed'] = l$isLicensed;
    final l$isRecommendationBlocked = isRecommendationBlocked;
    _resultData['isRecommendationBlocked'] = l$isRecommendationBlocked;
    final l$isReviewBlocked = isReviewBlocked;
    _resultData['isReviewBlocked'] = l$isReviewBlocked;
    final l$streamingEpisodes = streamingEpisodes;
    _resultData['streamingEpisodes'] =
        l$streamingEpisodes?.map((e) => e?.toJson()).toList();
    final l$trailer = trailer;
    _resultData['trailer'] = l$trailer?.toJson();
    final l$rankings = rankings;
    _resultData['rankings'] = l$rankings?.map((e) => e?.toJson()).toList();
    final l$tags = tags;
    _resultData['tags'] = l$tags?.map((e) => e?.toJson()).toList();
    final l$mediaListEntry = mediaListEntry;
    _resultData['mediaListEntry'] = l$mediaListEntry?.toJson();
    final l$stats = stats;
    _resultData['stats'] = l$stats?.toJson();
    final l$relations = relations;
    _resultData['relations'] = l$relations?.toJson();
    final l$characterPreview = characterPreview;
    _resultData['characterPreview'] = l$characterPreview?.toJson();
    final l$staffPreview = staffPreview;
    _resultData['staffPreview'] = l$staffPreview?.toJson();
    final l$studios = studios;
    _resultData['studios'] = l$studios?.toJson();
    final l$recommendations = recommendations;
    _resultData['recommendations'] = l$recommendations?.toJson();
    final l$externalLinks = externalLinks;
    _resultData['externalLinks'] =
        l$externalLinks?.map((e) => e?.toJson()).toList();
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
    final l$bannerImage = bannerImage;
    final l$description = description;
    final l$endDate = endDate;
    final l$trending = trending;
    final l$favourites = favourites;
    final l$updatedAt = updatedAt;
    final l$siteUrl = siteUrl;
    final l$duration = duration;
    final l$hashtag = hashtag;
    final l$synonyms = synonyms;
    final l$source = source;
    final l$isLocked = isLocked;
    final l$isFavouriteBlocked = isFavouriteBlocked;
    final l$countryOfOrigin = countryOfOrigin;
    final l$isLicensed = isLicensed;
    final l$isRecommendationBlocked = isRecommendationBlocked;
    final l$isReviewBlocked = isReviewBlocked;
    final l$streamingEpisodes = streamingEpisodes;
    final l$trailer = trailer;
    final l$rankings = rankings;
    final l$tags = tags;
    final l$mediaListEntry = mediaListEntry;
    final l$stats = stats;
    final l$relations = relations;
    final l$characterPreview = characterPreview;
    final l$staffPreview = staffPreview;
    final l$studios = studios;
    final l$recommendations = recommendations;
    final l$externalLinks = externalLinks;
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
      l$bannerImage,
      l$description,
      l$endDate,
      l$trending,
      l$favourites,
      l$updatedAt,
      l$siteUrl,
      l$duration,
      l$hashtag,
      l$synonyms == null ? null : Object.hashAll(l$synonyms.map((v) => v)),
      l$source,
      l$isLocked,
      l$isFavouriteBlocked,
      l$countryOfOrigin,
      l$isLicensed,
      l$isRecommendationBlocked,
      l$isReviewBlocked,
      l$streamingEpisodes == null
          ? null
          : Object.hashAll(l$streamingEpisodes.map((v) => v)),
      l$trailer,
      l$rankings == null ? null : Object.hashAll(l$rankings.map((v) => v)),
      l$tags == null ? null : Object.hashAll(l$tags.map((v) => v)),
      l$mediaListEntry,
      l$stats,
      l$relations,
      l$characterPreview,
      l$staffPreview,
      l$studios,
      l$recommendations,
      l$externalLinks == null
          ? null
          : Object.hashAll(l$externalLinks.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media ||
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
    final l$bannerImage = bannerImage;
    final lOther$bannerImage = other.bannerImage;
    if (l$bannerImage != lOther$bannerImage) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$endDate = endDate;
    final lOther$endDate = other.endDate;
    if (l$endDate != lOther$endDate) {
      return false;
    }
    final l$trending = trending;
    final lOther$trending = other.trending;
    if (l$trending != lOther$trending) {
      return false;
    }
    final l$favourites = favourites;
    final lOther$favourites = other.favourites;
    if (l$favourites != lOther$favourites) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
      return false;
    }
    final l$duration = duration;
    final lOther$duration = other.duration;
    if (l$duration != lOther$duration) {
      return false;
    }
    final l$hashtag = hashtag;
    final lOther$hashtag = other.hashtag;
    if (l$hashtag != lOther$hashtag) {
      return false;
    }
    final l$synonyms = synonyms;
    final lOther$synonyms = other.synonyms;
    if (l$synonyms != null && lOther$synonyms != null) {
      if (l$synonyms.length != lOther$synonyms.length) {
        return false;
      }
      for (int i = 0; i < l$synonyms.length; i++) {
        final l$synonyms$entry = l$synonyms[i];
        final lOther$synonyms$entry = lOther$synonyms[i];
        if (l$synonyms$entry != lOther$synonyms$entry) {
          return false;
        }
      }
    } else if (l$synonyms != lOther$synonyms) {
      return false;
    }
    final l$source = source;
    final lOther$source = other.source;
    if (l$source != lOther$source) {
      return false;
    }
    final l$isLocked = isLocked;
    final lOther$isLocked = other.isLocked;
    if (l$isLocked != lOther$isLocked) {
      return false;
    }
    final l$isFavouriteBlocked = isFavouriteBlocked;
    final lOther$isFavouriteBlocked = other.isFavouriteBlocked;
    if (l$isFavouriteBlocked != lOther$isFavouriteBlocked) {
      return false;
    }
    final l$countryOfOrigin = countryOfOrigin;
    final lOther$countryOfOrigin = other.countryOfOrigin;
    if (l$countryOfOrigin != lOther$countryOfOrigin) {
      return false;
    }
    final l$isLicensed = isLicensed;
    final lOther$isLicensed = other.isLicensed;
    if (l$isLicensed != lOther$isLicensed) {
      return false;
    }
    final l$isRecommendationBlocked = isRecommendationBlocked;
    final lOther$isRecommendationBlocked = other.isRecommendationBlocked;
    if (l$isRecommendationBlocked != lOther$isRecommendationBlocked) {
      return false;
    }
    final l$isReviewBlocked = isReviewBlocked;
    final lOther$isReviewBlocked = other.isReviewBlocked;
    if (l$isReviewBlocked != lOther$isReviewBlocked) {
      return false;
    }
    final l$streamingEpisodes = streamingEpisodes;
    final lOther$streamingEpisodes = other.streamingEpisodes;
    if (l$streamingEpisodes != null && lOther$streamingEpisodes != null) {
      if (l$streamingEpisodes.length != lOther$streamingEpisodes.length) {
        return false;
      }
      for (int i = 0; i < l$streamingEpisodes.length; i++) {
        final l$streamingEpisodes$entry = l$streamingEpisodes[i];
        final lOther$streamingEpisodes$entry = lOther$streamingEpisodes[i];
        if (l$streamingEpisodes$entry != lOther$streamingEpisodes$entry) {
          return false;
        }
      }
    } else if (l$streamingEpisodes != lOther$streamingEpisodes) {
      return false;
    }
    final l$trailer = trailer;
    final lOther$trailer = other.trailer;
    if (l$trailer != lOther$trailer) {
      return false;
    }
    final l$rankings = rankings;
    final lOther$rankings = other.rankings;
    if (l$rankings != null && lOther$rankings != null) {
      if (l$rankings.length != lOther$rankings.length) {
        return false;
      }
      for (int i = 0; i < l$rankings.length; i++) {
        final l$rankings$entry = l$rankings[i];
        final lOther$rankings$entry = lOther$rankings[i];
        if (l$rankings$entry != lOther$rankings$entry) {
          return false;
        }
      }
    } else if (l$rankings != lOther$rankings) {
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
    final l$mediaListEntry = mediaListEntry;
    final lOther$mediaListEntry = other.mediaListEntry;
    if (l$mediaListEntry != lOther$mediaListEntry) {
      return false;
    }
    final l$stats = stats;
    final lOther$stats = other.stats;
    if (l$stats != lOther$stats) {
      return false;
    }
    final l$relations = relations;
    final lOther$relations = other.relations;
    if (l$relations != lOther$relations) {
      return false;
    }
    final l$characterPreview = characterPreview;
    final lOther$characterPreview = other.characterPreview;
    if (l$characterPreview != lOther$characterPreview) {
      return false;
    }
    final l$staffPreview = staffPreview;
    final lOther$staffPreview = other.staffPreview;
    if (l$staffPreview != lOther$staffPreview) {
      return false;
    }
    final l$studios = studios;
    final lOther$studios = other.studios;
    if (l$studios != lOther$studios) {
      return false;
    }
    final l$recommendations = recommendations;
    final lOther$recommendations = other.recommendations;
    if (l$recommendations != lOther$recommendations) {
      return false;
    }
    final l$externalLinks = externalLinks;
    final lOther$externalLinks = other.externalLinks;
    if (l$externalLinks != null && lOther$externalLinks != null) {
      if (l$externalLinks.length != lOther$externalLinks.length) {
        return false;
      }
      for (int i = 0; i < l$externalLinks.length; i++) {
        final l$externalLinks$entry = l$externalLinks[i];
        final lOther$externalLinks$entry = lOther$externalLinks[i];
        if (l$externalLinks$entry != lOther$externalLinks$entry) {
          return false;
        }
      }
    } else if (l$externalLinks != lOther$externalLinks) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetAnimeOverview$Media
    on Query$GetAnimeOverview$Media {
  CopyWith$Query$GetAnimeOverview$Media<Query$GetAnimeOverview$Media>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media(
    Query$GetAnimeOverview$Media instance,
    TRes Function(Query$GetAnimeOverview$Media) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media;

  factory CopyWith$Query$GetAnimeOverview$Media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media;

  TRes call({
    int? id,
    Query$GetAnimeOverview$Media$title? title,
    Query$GetAnimeOverview$Media$coverImage? coverImage,
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
    Query$GetAnimeOverview$Media$nextAiringEpisode? nextAiringEpisode,
    Query$GetAnimeOverview$Media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Query$GetAnimeOverview$Media$endDate? endDate,
    int? trending,
    int? favourites,
    int? updatedAt,
    String? siteUrl,
    int? duration,
    String? hashtag,
    List<String?>? synonyms,
    Enum$MediaSource? source,
    bool? isLocked,
    bool? isFavouriteBlocked,
    String? countryOfOrigin,
    bool? isLicensed,
    bool? isRecommendationBlocked,
    bool? isReviewBlocked,
    List<Query$GetAnimeOverview$Media$streamingEpisodes?>? streamingEpisodes,
    Query$GetAnimeOverview$Media$trailer? trailer,
    List<Query$GetAnimeOverview$Media$rankings?>? rankings,
    List<Query$GetAnimeOverview$Media$tags?>? tags,
    Query$GetAnimeOverview$Media$mediaListEntry? mediaListEntry,
    Query$GetAnimeOverview$Media$stats? stats,
    Query$GetAnimeOverview$Media$relations? relations,
    Query$GetAnimeOverview$Media$characterPreview? characterPreview,
    Query$GetAnimeOverview$Media$staffPreview? staffPreview,
    Query$GetAnimeOverview$Media$studios? studios,
    Query$GetAnimeOverview$Media$recommendations? recommendations,
    List<Query$GetAnimeOverview$Media$externalLinks?>? externalLinks,
  });
  CopyWith$Query$GetAnimeOverview$Media$title<TRes> get title;
  CopyWith$Query$GetAnimeOverview$Media$coverImage<TRes> get coverImage;
  CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes>
      get nextAiringEpisode;
  CopyWith$Query$GetAnimeOverview$Media$startDate<TRes> get startDate;
  CopyWith$Query$GetAnimeOverview$Media$endDate<TRes> get endDate;
  TRes streamingEpisodes(
      Iterable<Query$GetAnimeOverview$Media$streamingEpisodes?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes<
                      Query$GetAnimeOverview$Media$streamingEpisodes>?>?)
          _fn);
  CopyWith$Query$GetAnimeOverview$Media$trailer<TRes> get trailer;
  TRes rankings(
      Iterable<Query$GetAnimeOverview$Media$rankings?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$rankings<
                      Query$GetAnimeOverview$Media$rankings>?>?)
          _fn);
  TRes tags(
      Iterable<Query$GetAnimeOverview$Media$tags?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$tags<
                      Query$GetAnimeOverview$Media$tags>?>?)
          _fn);
  CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<TRes> get mediaListEntry;
  CopyWith$Query$GetAnimeOverview$Media$stats<TRes> get stats;
  CopyWith$Query$GetAnimeOverview$Media$relations<TRes> get relations;
  CopyWith$Query$GetAnimeOverview$Media$characterPreview<TRes>
      get characterPreview;
  CopyWith$Query$GetAnimeOverview$Media$staffPreview<TRes> get staffPreview;
  CopyWith$Query$GetAnimeOverview$Media$studios<TRes> get studios;
  CopyWith$Query$GetAnimeOverview$Media$recommendations<TRes>
      get recommendations;
  TRes externalLinks(
      Iterable<Query$GetAnimeOverview$Media$externalLinks?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$externalLinks<
                      Query$GetAnimeOverview$Media$externalLinks>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media _instance;

  final TRes Function(Query$GetAnimeOverview$Media) _then;

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
    Object? bannerImage = _undefined,
    Object? description = _undefined,
    Object? endDate = _undefined,
    Object? trending = _undefined,
    Object? favourites = _undefined,
    Object? updatedAt = _undefined,
    Object? siteUrl = _undefined,
    Object? duration = _undefined,
    Object? hashtag = _undefined,
    Object? synonyms = _undefined,
    Object? source = _undefined,
    Object? isLocked = _undefined,
    Object? isFavouriteBlocked = _undefined,
    Object? countryOfOrigin = _undefined,
    Object? isLicensed = _undefined,
    Object? isRecommendationBlocked = _undefined,
    Object? isReviewBlocked = _undefined,
    Object? streamingEpisodes = _undefined,
    Object? trailer = _undefined,
    Object? rankings = _undefined,
    Object? tags = _undefined,
    Object? mediaListEntry = _undefined,
    Object? stats = _undefined,
    Object? relations = _undefined,
    Object? characterPreview = _undefined,
    Object? staffPreview = _undefined,
    Object? studios = _undefined,
    Object? recommendations = _undefined,
    Object? externalLinks = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title as Query$GetAnimeOverview$Media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage as Query$GetAnimeOverview$Media$coverImage?),
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
                as Query$GetAnimeOverview$Media$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate as Query$GetAnimeOverview$Media$startDate?),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        bannerImage: bannerImage == _undefined
            ? _instance.bannerImage
            : (bannerImage as String?),
        description: description == _undefined
            ? _instance.description
            : (description as String?),
        endDate: endDate == _undefined
            ? _instance.endDate
            : (endDate as Query$GetAnimeOverview$Media$endDate?),
        trending:
            trending == _undefined ? _instance.trending : (trending as int?),
        favourites: favourites == _undefined
            ? _instance.favourites
            : (favourites as int?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        duration:
            duration == _undefined ? _instance.duration : (duration as int?),
        hashtag:
            hashtag == _undefined ? _instance.hashtag : (hashtag as String?),
        synonyms: synonyms == _undefined
            ? _instance.synonyms
            : (synonyms as List<String?>?),
        source: source == _undefined
            ? _instance.source
            : (source as Enum$MediaSource?),
        isLocked:
            isLocked == _undefined ? _instance.isLocked : (isLocked as bool?),
        isFavouriteBlocked:
            isFavouriteBlocked == _undefined || isFavouriteBlocked == null
                ? _instance.isFavouriteBlocked
                : (isFavouriteBlocked as bool),
        countryOfOrigin: countryOfOrigin == _undefined
            ? _instance.countryOfOrigin
            : (countryOfOrigin as String?),
        isLicensed: isLicensed == _undefined
            ? _instance.isLicensed
            : (isLicensed as bool?),
        isRecommendationBlocked: isRecommendationBlocked == _undefined
            ? _instance.isRecommendationBlocked
            : (isRecommendationBlocked as bool?),
        isReviewBlocked: isReviewBlocked == _undefined
            ? _instance.isReviewBlocked
            : (isReviewBlocked as bool?),
        streamingEpisodes: streamingEpisodes == _undefined
            ? _instance.streamingEpisodes
            : (streamingEpisodes
                as List<Query$GetAnimeOverview$Media$streamingEpisodes?>?),
        trailer: trailer == _undefined
            ? _instance.trailer
            : (trailer as Query$GetAnimeOverview$Media$trailer?),
        rankings: rankings == _undefined
            ? _instance.rankings
            : (rankings as List<Query$GetAnimeOverview$Media$rankings?>?),
        tags: tags == _undefined
            ? _instance.tags
            : (tags as List<Query$GetAnimeOverview$Media$tags?>?),
        mediaListEntry: mediaListEntry == _undefined
            ? _instance.mediaListEntry
            : (mediaListEntry as Query$GetAnimeOverview$Media$mediaListEntry?),
        stats: stats == _undefined
            ? _instance.stats
            : (stats as Query$GetAnimeOverview$Media$stats?),
        relations: relations == _undefined
            ? _instance.relations
            : (relations as Query$GetAnimeOverview$Media$relations?),
        characterPreview: characterPreview == _undefined
            ? _instance.characterPreview
            : (characterPreview
                as Query$GetAnimeOverview$Media$characterPreview?),
        staffPreview: staffPreview == _undefined
            ? _instance.staffPreview
            : (staffPreview as Query$GetAnimeOverview$Media$staffPreview?),
        studios: studios == _undefined
            ? _instance.studios
            : (studios as Query$GetAnimeOverview$Media$studios?),
        recommendations: recommendations == _undefined
            ? _instance.recommendations
            : (recommendations
                as Query$GetAnimeOverview$Media$recommendations?),
        externalLinks: externalLinks == _undefined
            ? _instance.externalLinks
            : (externalLinks
                as List<Query$GetAnimeOverview$Media$externalLinks?>?),
      ));

  CopyWith$Query$GetAnimeOverview$Media$title<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetAnimeOverview$Media$title.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$coverImage<TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetAnimeOverview$Media$coverImage.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes>
      get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$startDate<TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Query$GetAnimeOverview$Media$startDate.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$startDate(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$endDate<TRes> get endDate {
    final local$endDate = _instance.endDate;
    return local$endDate == null
        ? CopyWith$Query$GetAnimeOverview$Media$endDate.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$endDate(
            local$endDate, (e) => call(endDate: e));
  }

  TRes streamingEpisodes(
          Iterable<Query$GetAnimeOverview$Media$streamingEpisodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes<
                          Query$GetAnimeOverview$Media$streamingEpisodes>?>?)
              _fn) =>
      call(
          streamingEpisodes:
              _fn(_instance.streamingEpisodes?.map((e) => e == null
                  ? null
                  : CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes(
                      e,
                      (i) => i,
                    )))?.toList());

  CopyWith$Query$GetAnimeOverview$Media$trailer<TRes> get trailer {
    final local$trailer = _instance.trailer;
    return local$trailer == null
        ? CopyWith$Query$GetAnimeOverview$Media$trailer.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$trailer(
            local$trailer, (e) => call(trailer: e));
  }

  TRes rankings(
          Iterable<Query$GetAnimeOverview$Media$rankings?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$rankings<
                          Query$GetAnimeOverview$Media$rankings>?>?)
              _fn) =>
      call(
          rankings: _fn(_instance.rankings?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$rankings(
                  e,
                  (i) => i,
                )))?.toList());

  TRes tags(
          Iterable<Query$GetAnimeOverview$Media$tags?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$tags<
                          Query$GetAnimeOverview$Media$tags>?>?)
              _fn) =>
      call(
          tags: _fn(_instance.tags?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$tags(
                  e,
                  (i) => i,
                )))?.toList());

  CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<TRes>
      get mediaListEntry {
    final local$mediaListEntry = _instance.mediaListEntry;
    return local$mediaListEntry == null
        ? CopyWith$Query$GetAnimeOverview$Media$mediaListEntry.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$mediaListEntry(
            local$mediaListEntry, (e) => call(mediaListEntry: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$stats<TRes> get stats {
    final local$stats = _instance.stats;
    return local$stats == null
        ? CopyWith$Query$GetAnimeOverview$Media$stats.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$stats(
            local$stats, (e) => call(stats: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$relations<TRes> get relations {
    final local$relations = _instance.relations;
    return local$relations == null
        ? CopyWith$Query$GetAnimeOverview$Media$relations.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$relations(
            local$relations, (e) => call(relations: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$characterPreview<TRes>
      get characterPreview {
    final local$characterPreview = _instance.characterPreview;
    return local$characterPreview == null
        ? CopyWith$Query$GetAnimeOverview$Media$characterPreview.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$characterPreview(
            local$characterPreview, (e) => call(characterPreview: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$staffPreview<TRes> get staffPreview {
    final local$staffPreview = _instance.staffPreview;
    return local$staffPreview == null
        ? CopyWith$Query$GetAnimeOverview$Media$staffPreview.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$staffPreview(
            local$staffPreview, (e) => call(staffPreview: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$studios<TRes> get studios {
    final local$studios = _instance.studios;
    return local$studios == null
        ? CopyWith$Query$GetAnimeOverview$Media$studios.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$studios(
            local$studios, (e) => call(studios: e));
  }

  CopyWith$Query$GetAnimeOverview$Media$recommendations<TRes>
      get recommendations {
    final local$recommendations = _instance.recommendations;
    return local$recommendations == null
        ? CopyWith$Query$GetAnimeOverview$Media$recommendations.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$recommendations(
            local$recommendations, (e) => call(recommendations: e));
  }

  TRes externalLinks(
          Iterable<Query$GetAnimeOverview$Media$externalLinks?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$externalLinks<
                          Query$GetAnimeOverview$Media$externalLinks>?>?)
              _fn) =>
      call(
          externalLinks: _fn(_instance.externalLinks?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$externalLinks(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media(this._res);

  TRes _res;

  call({
    int? id,
    Query$GetAnimeOverview$Media$title? title,
    Query$GetAnimeOverview$Media$coverImage? coverImage,
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
    Query$GetAnimeOverview$Media$nextAiringEpisode? nextAiringEpisode,
    Query$GetAnimeOverview$Media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Query$GetAnimeOverview$Media$endDate? endDate,
    int? trending,
    int? favourites,
    int? updatedAt,
    String? siteUrl,
    int? duration,
    String? hashtag,
    List<String?>? synonyms,
    Enum$MediaSource? source,
    bool? isLocked,
    bool? isFavouriteBlocked,
    String? countryOfOrigin,
    bool? isLicensed,
    bool? isRecommendationBlocked,
    bool? isReviewBlocked,
    List<Query$GetAnimeOverview$Media$streamingEpisodes?>? streamingEpisodes,
    Query$GetAnimeOverview$Media$trailer? trailer,
    List<Query$GetAnimeOverview$Media$rankings?>? rankings,
    List<Query$GetAnimeOverview$Media$tags?>? tags,
    Query$GetAnimeOverview$Media$mediaListEntry? mediaListEntry,
    Query$GetAnimeOverview$Media$stats? stats,
    Query$GetAnimeOverview$Media$relations? relations,
    Query$GetAnimeOverview$Media$characterPreview? characterPreview,
    Query$GetAnimeOverview$Media$staffPreview? staffPreview,
    Query$GetAnimeOverview$Media$studios? studios,
    Query$GetAnimeOverview$Media$recommendations? recommendations,
    List<Query$GetAnimeOverview$Media$externalLinks?>? externalLinks,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Media$title<TRes> get title =>
      CopyWith$Query$GetAnimeOverview$Media$title.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$coverImage<TRes> get coverImage =>
      CopyWith$Query$GetAnimeOverview$Media$coverImage.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes>
      get nextAiringEpisode =>
          CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$startDate<TRes> get startDate =>
      CopyWith$Query$GetAnimeOverview$Media$startDate.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$endDate<TRes> get endDate =>
      CopyWith$Query$GetAnimeOverview$Media$endDate.stub(_res);

  streamingEpisodes(_fn) => _res;

  CopyWith$Query$GetAnimeOverview$Media$trailer<TRes> get trailer =>
      CopyWith$Query$GetAnimeOverview$Media$trailer.stub(_res);

  rankings(_fn) => _res;

  tags(_fn) => _res;

  CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<TRes>
      get mediaListEntry =>
          CopyWith$Query$GetAnimeOverview$Media$mediaListEntry.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$stats<TRes> get stats =>
      CopyWith$Query$GetAnimeOverview$Media$stats.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$relations<TRes> get relations =>
      CopyWith$Query$GetAnimeOverview$Media$relations.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$characterPreview<TRes>
      get characterPreview =>
          CopyWith$Query$GetAnimeOverview$Media$characterPreview.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$staffPreview<TRes> get staffPreview =>
      CopyWith$Query$GetAnimeOverview$Media$staffPreview.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$studios<TRes> get studios =>
      CopyWith$Query$GetAnimeOverview$Media$studios.stub(_res);

  CopyWith$Query$GetAnimeOverview$Media$recommendations<TRes>
      get recommendations =>
          CopyWith$Query$GetAnimeOverview$Media$recommendations.stub(_res);

  externalLinks(_fn) => _res;
}

class Query$GetAnimeOverview$Media$title
    implements Fragment$AnimeOverview$title, Fragment$AnimeCard$title {
  Query$GetAnimeOverview$Media$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetAnimeOverview$Media$title.fromJson(
      Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$title(
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
    if (other is! Query$GetAnimeOverview$Media$title ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$title
    on Query$GetAnimeOverview$Media$title {
  CopyWith$Query$GetAnimeOverview$Media$title<
          Query$GetAnimeOverview$Media$title>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$title<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$title(
    Query$GetAnimeOverview$Media$title instance,
    TRes Function(Query$GetAnimeOverview$Media$title) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$title;

  factory CopyWith$Query$GetAnimeOverview$Media$title.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$title<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$title<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$title(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$title _instance;

  final TRes Function(Query$GetAnimeOverview$Media$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$title(
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

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$title<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$title<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$title(this._res);

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

class Query$GetAnimeOverview$Media$coverImage
    implements
        Fragment$AnimeOverview$coverImage,
        Fragment$AnimeCard$coverImage {
  Query$GetAnimeOverview$Media$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetAnimeOverview$Media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$coverImage(
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
    if (other is! Query$GetAnimeOverview$Media$coverImage ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$coverImage
    on Query$GetAnimeOverview$Media$coverImage {
  CopyWith$Query$GetAnimeOverview$Media$coverImage<
          Query$GetAnimeOverview$Media$coverImage>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$coverImage<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$coverImage(
    Query$GetAnimeOverview$Media$coverImage instance,
    TRes Function(Query$GetAnimeOverview$Media$coverImage) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$coverImage;

  factory CopyWith$Query$GetAnimeOverview$Media$coverImage.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$coverImage<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$coverImage<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$coverImage _instance;

  final TRes Function(Query$GetAnimeOverview$Media$coverImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$coverImage(
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

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$coverImage<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$coverImage<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$coverImage(this._res);

  TRes _res;

  call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$nextAiringEpisode
    implements
        Fragment$AnimeOverview$nextAiringEpisode,
        Fragment$AnimeCard$nextAiringEpisode {
  Query$GetAnimeOverview$Media$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Query$GetAnimeOverview$Media$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$nextAiringEpisode(
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
    if (other is! Query$GetAnimeOverview$Media$nextAiringEpisode ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$nextAiringEpisode
    on Query$GetAnimeOverview$Media$nextAiringEpisode {
  CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<
          Query$GetAnimeOverview$Media$nextAiringEpisode>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode(
    Query$GetAnimeOverview$Media$nextAiringEpisode instance,
    TRes Function(Query$GetAnimeOverview$Media$nextAiringEpisode) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$nextAiringEpisode;

  factory CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$nextAiringEpisode _instance;

  final TRes Function(Query$GetAnimeOverview$Media$nextAiringEpisode) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$nextAiringEpisode(
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

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$nextAiringEpisode<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$nextAiringEpisode(this._res);

  TRes _res;

  call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$startDate
    implements Fragment$AnimeOverview$startDate, Fragment$AnimeCard$startDate {
  Query$GetAnimeOverview$Media$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetAnimeOverview$Media$startDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$startDate(
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
    if (other is! Query$GetAnimeOverview$Media$startDate ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$startDate
    on Query$GetAnimeOverview$Media$startDate {
  CopyWith$Query$GetAnimeOverview$Media$startDate<
          Query$GetAnimeOverview$Media$startDate>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$startDate<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$startDate(
    Query$GetAnimeOverview$Media$startDate instance,
    TRes Function(Query$GetAnimeOverview$Media$startDate) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$startDate;

  factory CopyWith$Query$GetAnimeOverview$Media$startDate.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$startDate<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$startDate<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$startDate(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$startDate _instance;

  final TRes Function(Query$GetAnimeOverview$Media$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$startDate<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$startDate<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$startDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$endDate
    implements Fragment$AnimeOverview$endDate {
  Query$GetAnimeOverview$Media$endDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetAnimeOverview$Media$endDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$endDate(
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
    if (other is! Query$GetAnimeOverview$Media$endDate ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$endDate
    on Query$GetAnimeOverview$Media$endDate {
  CopyWith$Query$GetAnimeOverview$Media$endDate<
          Query$GetAnimeOverview$Media$endDate>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$endDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$endDate<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$endDate(
    Query$GetAnimeOverview$Media$endDate instance,
    TRes Function(Query$GetAnimeOverview$Media$endDate) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$endDate;

  factory CopyWith$Query$GetAnimeOverview$Media$endDate.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$endDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$endDate<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$endDate<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$endDate(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$endDate _instance;

  final TRes Function(Query$GetAnimeOverview$Media$endDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$endDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$endDate<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$endDate<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$endDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$streamingEpisodes
    implements Fragment$AnimeOverview$streamingEpisodes {
  Query$GetAnimeOverview$Media$streamingEpisodes({
    this.site,
    this.title,
    this.thumbnail,
    this.url,
    this.$__typename = 'MediaStreamingEpisode',
  });

  factory Query$GetAnimeOverview$Media$streamingEpisodes.fromJson(
      Map<String, dynamic> json) {
    final l$site = json['site'];
    final l$title = json['title'];
    final l$thumbnail = json['thumbnail'];
    final l$url = json['url'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$streamingEpisodes(
      site: (l$site as String?),
      title: (l$title as String?),
      thumbnail: (l$thumbnail as String?),
      url: (l$url as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? site;

  final String? title;

  final String? thumbnail;

  final String? url;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$site = site;
    _resultData['site'] = l$site;
    final l$title = title;
    _resultData['title'] = l$title;
    final l$thumbnail = thumbnail;
    _resultData['thumbnail'] = l$thumbnail;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$site = site;
    final l$title = title;
    final l$thumbnail = thumbnail;
    final l$url = url;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$site,
      l$title,
      l$thumbnail,
      l$url,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$streamingEpisodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$site = site;
    final lOther$site = other.site;
    if (l$site != lOther$site) {
      return false;
    }
    final l$title = title;
    final lOther$title = other.title;
    if (l$title != lOther$title) {
      return false;
    }
    final l$thumbnail = thumbnail;
    final lOther$thumbnail = other.thumbnail;
    if (l$thumbnail != lOther$thumbnail) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$streamingEpisodes
    on Query$GetAnimeOverview$Media$streamingEpisodes {
  CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes<
          Query$GetAnimeOverview$Media$streamingEpisodes>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes(
    Query$GetAnimeOverview$Media$streamingEpisodes instance,
    TRes Function(Query$GetAnimeOverview$Media$streamingEpisodes) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$streamingEpisodes;

  factory CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$streamingEpisodes;

  TRes call({
    String? site,
    String? title,
    String? thumbnail,
    String? url,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$streamingEpisodes<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$streamingEpisodes(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$streamingEpisodes _instance;

  final TRes Function(Query$GetAnimeOverview$Media$streamingEpisodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? site = _undefined,
    Object? title = _undefined,
    Object? thumbnail = _undefined,
    Object? url = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$streamingEpisodes(
        site: site == _undefined ? _instance.site : (site as String?),
        title: title == _undefined ? _instance.title : (title as String?),
        thumbnail: thumbnail == _undefined
            ? _instance.thumbnail
            : (thumbnail as String?),
        url: url == _undefined ? _instance.url : (url as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$streamingEpisodes<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$streamingEpisodes<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$streamingEpisodes(this._res);

  TRes _res;

  call({
    String? site,
    String? title,
    String? thumbnail,
    String? url,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$trailer
    implements Fragment$AnimeOverview$trailer {
  Query$GetAnimeOverview$Media$trailer({
    this.id,
    this.site,
    this.$__typename = 'MediaTrailer',
  });

  factory Query$GetAnimeOverview$Media$trailer.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$site = json['site'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$trailer(
      id: (l$id as String?),
      site: (l$site as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? id;

  final String? site;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$site = site;
    _resultData['site'] = l$site;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$site = site;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$site,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$trailer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$site = site;
    final lOther$site = other.site;
    if (l$site != lOther$site) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$trailer
    on Query$GetAnimeOverview$Media$trailer {
  CopyWith$Query$GetAnimeOverview$Media$trailer<
          Query$GetAnimeOverview$Media$trailer>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$trailer(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$trailer<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$trailer(
    Query$GetAnimeOverview$Media$trailer instance,
    TRes Function(Query$GetAnimeOverview$Media$trailer) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$trailer;

  factory CopyWith$Query$GetAnimeOverview$Media$trailer.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$trailer;

  TRes call({
    String? id,
    String? site,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$trailer<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$trailer<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$trailer(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$trailer _instance;

  final TRes Function(Query$GetAnimeOverview$Media$trailer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? site = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$trailer(
        id: id == _undefined ? _instance.id : (id as String?),
        site: site == _undefined ? _instance.site : (site as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$trailer<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$trailer<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$trailer(this._res);

  TRes _res;

  call({
    String? id,
    String? site,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$rankings
    implements Fragment$AnimeOverview$rankings {
  Query$GetAnimeOverview$Media$rankings({
    required this.id,
    required this.rank,
    required this.type,
    required this.format,
    this.year,
    this.season,
    this.allTime,
    required this.context,
    this.$__typename = 'MediaRank',
  });

  factory Query$GetAnimeOverview$Media$rankings.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$rank = json['rank'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$year = json['year'];
    final l$season = json['season'];
    final l$allTime = json['allTime'];
    final l$context = json['context'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$rankings(
      id: (l$id as int),
      rank: (l$rank as int),
      type: fromJson$Enum$MediaRankType((l$type as String)),
      format: fromJson$Enum$MediaFormat((l$format as String)),
      year: (l$year as int?),
      season: l$season == null
          ? null
          : fromJson$Enum$MediaSeason((l$season as String)),
      allTime: (l$allTime as bool?),
      context: (l$context as String),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int rank;

  final Enum$MediaRankType type;

  final Enum$MediaFormat format;

  final int? year;

  final Enum$MediaSeason? season;

  final bool? allTime;

  final String context;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$rank = rank;
    _resultData['rank'] = l$rank;
    final l$type = type;
    _resultData['type'] = toJson$Enum$MediaRankType(l$type);
    final l$format = format;
    _resultData['format'] = toJson$Enum$MediaFormat(l$format);
    final l$year = year;
    _resultData['year'] = l$year;
    final l$season = season;
    _resultData['season'] =
        l$season == null ? null : toJson$Enum$MediaSeason(l$season);
    final l$allTime = allTime;
    _resultData['allTime'] = l$allTime;
    final l$context = context;
    _resultData['context'] = l$context;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$rank = rank;
    final l$type = type;
    final l$format = format;
    final l$year = year;
    final l$season = season;
    final l$allTime = allTime;
    final l$context = context;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$rank,
      l$type,
      l$format,
      l$year,
      l$season,
      l$allTime,
      l$context,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$rankings ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$rank = rank;
    final lOther$rank = other.rank;
    if (l$rank != lOther$rank) {
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
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$season = season;
    final lOther$season = other.season;
    if (l$season != lOther$season) {
      return false;
    }
    final l$allTime = allTime;
    final lOther$allTime = other.allTime;
    if (l$allTime != lOther$allTime) {
      return false;
    }
    final l$context = context;
    final lOther$context = other.context;
    if (l$context != lOther$context) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$rankings
    on Query$GetAnimeOverview$Media$rankings {
  CopyWith$Query$GetAnimeOverview$Media$rankings<
          Query$GetAnimeOverview$Media$rankings>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$rankings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$rankings<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$rankings(
    Query$GetAnimeOverview$Media$rankings instance,
    TRes Function(Query$GetAnimeOverview$Media$rankings) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$rankings;

  factory CopyWith$Query$GetAnimeOverview$Media$rankings.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$rankings;

  TRes call({
    int? id,
    int? rank,
    Enum$MediaRankType? type,
    Enum$MediaFormat? format,
    int? year,
    Enum$MediaSeason? season,
    bool? allTime,
    String? context,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$rankings<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$rankings<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$rankings(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$rankings _instance;

  final TRes Function(Query$GetAnimeOverview$Media$rankings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? rank = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? year = _undefined,
    Object? season = _undefined,
    Object? allTime = _undefined,
    Object? context = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$rankings(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        rank:
            rank == _undefined || rank == null ? _instance.rank : (rank as int),
        type: type == _undefined || type == null
            ? _instance.type
            : (type as Enum$MediaRankType),
        format: format == _undefined || format == null
            ? _instance.format
            : (format as Enum$MediaFormat),
        year: year == _undefined ? _instance.year : (year as int?),
        season: season == _undefined
            ? _instance.season
            : (season as Enum$MediaSeason?),
        allTime: allTime == _undefined ? _instance.allTime : (allTime as bool?),
        context: context == _undefined || context == null
            ? _instance.context
            : (context as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$rankings<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$rankings<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$rankings(this._res);

  TRes _res;

  call({
    int? id,
    int? rank,
    Enum$MediaRankType? type,
    Enum$MediaFormat? format,
    int? year,
    Enum$MediaSeason? season,
    bool? allTime,
    String? context,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$tags implements Fragment$AnimeOverview$tags {
  Query$GetAnimeOverview$Media$tags({
    required this.id,
    required this.name,
    this.description,
    this.rank,
    this.isMediaSpoiler,
    this.isGeneralSpoiler,
    this.userId,
    this.$__typename = 'MediaTag',
  });

  factory Query$GetAnimeOverview$Media$tags.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$description = json['description'];
    final l$rank = json['rank'];
    final l$isMediaSpoiler = json['isMediaSpoiler'];
    final l$isGeneralSpoiler = json['isGeneralSpoiler'];
    final l$userId = json['userId'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$tags(
      id: (l$id as int),
      name: (l$name as String),
      description: (l$description as String?),
      rank: (l$rank as int?),
      isMediaSpoiler: (l$isMediaSpoiler as bool?),
      isGeneralSpoiler: (l$isGeneralSpoiler as bool?),
      userId: (l$userId as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final String? description;

  final int? rank;

  final bool? isMediaSpoiler;

  final bool? isGeneralSpoiler;

  final int? userId;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$rank = rank;
    _resultData['rank'] = l$rank;
    final l$isMediaSpoiler = isMediaSpoiler;
    _resultData['isMediaSpoiler'] = l$isMediaSpoiler;
    final l$isGeneralSpoiler = isGeneralSpoiler;
    _resultData['isGeneralSpoiler'] = l$isGeneralSpoiler;
    final l$userId = userId;
    _resultData['userId'] = l$userId;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$description = description;
    final l$rank = rank;
    final l$isMediaSpoiler = isMediaSpoiler;
    final l$isGeneralSpoiler = isGeneralSpoiler;
    final l$userId = userId;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$description,
      l$rank,
      l$isMediaSpoiler,
      l$isGeneralSpoiler,
      l$userId,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$tags ||
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
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$rank = rank;
    final lOther$rank = other.rank;
    if (l$rank != lOther$rank) {
      return false;
    }
    final l$isMediaSpoiler = isMediaSpoiler;
    final lOther$isMediaSpoiler = other.isMediaSpoiler;
    if (l$isMediaSpoiler != lOther$isMediaSpoiler) {
      return false;
    }
    final l$isGeneralSpoiler = isGeneralSpoiler;
    final lOther$isGeneralSpoiler = other.isGeneralSpoiler;
    if (l$isGeneralSpoiler != lOther$isGeneralSpoiler) {
      return false;
    }
    final l$userId = userId;
    final lOther$userId = other.userId;
    if (l$userId != lOther$userId) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$tags
    on Query$GetAnimeOverview$Media$tags {
  CopyWith$Query$GetAnimeOverview$Media$tags<Query$GetAnimeOverview$Media$tags>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$tags(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$tags<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$tags(
    Query$GetAnimeOverview$Media$tags instance,
    TRes Function(Query$GetAnimeOverview$Media$tags) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$tags;

  factory CopyWith$Query$GetAnimeOverview$Media$tags.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$tags;

  TRes call({
    int? id,
    String? name,
    String? description,
    int? rank,
    bool? isMediaSpoiler,
    bool? isGeneralSpoiler,
    int? userId,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$tags<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$tags<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$tags(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$tags _instance;

  final TRes Function(Query$GetAnimeOverview$Media$tags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? description = _undefined,
    Object? rank = _undefined,
    Object? isMediaSpoiler = _undefined,
    Object? isGeneralSpoiler = _undefined,
    Object? userId = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$tags(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        description: description == _undefined
            ? _instance.description
            : (description as String?),
        rank: rank == _undefined ? _instance.rank : (rank as int?),
        isMediaSpoiler: isMediaSpoiler == _undefined
            ? _instance.isMediaSpoiler
            : (isMediaSpoiler as bool?),
        isGeneralSpoiler: isGeneralSpoiler == _undefined
            ? _instance.isGeneralSpoiler
            : (isGeneralSpoiler as bool?),
        userId: userId == _undefined ? _instance.userId : (userId as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$tags<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$tags<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$tags(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    String? description,
    int? rank,
    bool? isMediaSpoiler,
    bool? isGeneralSpoiler,
    int? userId,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$mediaListEntry
    implements Fragment$AnimeOverview$mediaListEntry {
  Query$GetAnimeOverview$Media$mediaListEntry({
    required this.id,
    this.status,
    this.score,
    this.$__typename = 'MediaList',
  });

  factory Query$GetAnimeOverview$Media$mediaListEntry.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$status = json['status'];
    final l$score = json['score'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$mediaListEntry(
      id: (l$id as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      score: (l$score as num?)?.toDouble(),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$MediaListStatus? status;

  final double? score;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$score = score;
    _resultData['score'] = l$score;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$status = status;
    final l$score = score;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$status,
      l$score,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$mediaListEntry ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$mediaListEntry
    on Query$GetAnimeOverview$Media$mediaListEntry {
  CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<
          Query$GetAnimeOverview$Media$mediaListEntry>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$mediaListEntry(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$mediaListEntry(
    Query$GetAnimeOverview$Media$mediaListEntry instance,
    TRes Function(Query$GetAnimeOverview$Media$mediaListEntry) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$mediaListEntry;

  factory CopyWith$Query$GetAnimeOverview$Media$mediaListEntry.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$mediaListEntry;

  TRes call({
    int? id,
    Enum$MediaListStatus? status,
    double? score,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$mediaListEntry<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$mediaListEntry(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$mediaListEntry _instance;

  final TRes Function(Query$GetAnimeOverview$Media$mediaListEntry) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? status = _undefined,
    Object? score = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$mediaListEntry(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        score: score == _undefined ? _instance.score : (score as double?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$mediaListEntry<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$mediaListEntry<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$mediaListEntry(this._res);

  TRes _res;

  call({
    int? id,
    Enum$MediaListStatus? status,
    double? score,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$stats {
  Query$GetAnimeOverview$Media$stats({
    this.statusDistribution,
    this.scoreDistribution,
    this.$__typename = 'MediaStats',
  });

  factory Query$GetAnimeOverview$Media$stats.fromJson(
      Map<String, dynamic> json) {
    final l$statusDistribution = json['statusDistribution'];
    final l$scoreDistribution = json['scoreDistribution'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$stats(
      statusDistribution: (l$statusDistribution as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$stats$statusDistribution.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      scoreDistribution: (l$scoreDistribution as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$stats$scoreDistribution.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeOverview$Media$stats$statusDistribution?>?
      statusDistribution;

  final List<Query$GetAnimeOverview$Media$stats$scoreDistribution?>?
      scoreDistribution;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$statusDistribution = statusDistribution;
    _resultData['statusDistribution'] =
        l$statusDistribution?.map((e) => e?.toJson()).toList();
    final l$scoreDistribution = scoreDistribution;
    _resultData['scoreDistribution'] =
        l$scoreDistribution?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$statusDistribution = statusDistribution;
    final l$scoreDistribution = scoreDistribution;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$statusDistribution == null
          ? null
          : Object.hashAll(l$statusDistribution.map((v) => v)),
      l$scoreDistribution == null
          ? null
          : Object.hashAll(l$scoreDistribution.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$stats ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$statusDistribution = statusDistribution;
    final lOther$statusDistribution = other.statusDistribution;
    if (l$statusDistribution != null && lOther$statusDistribution != null) {
      if (l$statusDistribution.length != lOther$statusDistribution.length) {
        return false;
      }
      for (int i = 0; i < l$statusDistribution.length; i++) {
        final l$statusDistribution$entry = l$statusDistribution[i];
        final lOther$statusDistribution$entry = lOther$statusDistribution[i];
        if (l$statusDistribution$entry != lOther$statusDistribution$entry) {
          return false;
        }
      }
    } else if (l$statusDistribution != lOther$statusDistribution) {
      return false;
    }
    final l$scoreDistribution = scoreDistribution;
    final lOther$scoreDistribution = other.scoreDistribution;
    if (l$scoreDistribution != null && lOther$scoreDistribution != null) {
      if (l$scoreDistribution.length != lOther$scoreDistribution.length) {
        return false;
      }
      for (int i = 0; i < l$scoreDistribution.length; i++) {
        final l$scoreDistribution$entry = l$scoreDistribution[i];
        final lOther$scoreDistribution$entry = lOther$scoreDistribution[i];
        if (l$scoreDistribution$entry != lOther$scoreDistribution$entry) {
          return false;
        }
      }
    } else if (l$scoreDistribution != lOther$scoreDistribution) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$stats
    on Query$GetAnimeOverview$Media$stats {
  CopyWith$Query$GetAnimeOverview$Media$stats<
          Query$GetAnimeOverview$Media$stats>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$stats(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$stats<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$stats(
    Query$GetAnimeOverview$Media$stats instance,
    TRes Function(Query$GetAnimeOverview$Media$stats) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$stats;

  factory CopyWith$Query$GetAnimeOverview$Media$stats.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats;

  TRes call({
    List<Query$GetAnimeOverview$Media$stats$statusDistribution?>?
        statusDistribution,
    List<Query$GetAnimeOverview$Media$stats$scoreDistribution?>?
        scoreDistribution,
    String? $__typename,
  });
  TRes statusDistribution(
      Iterable<Query$GetAnimeOverview$Media$stats$statusDistribution?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution<
                      Query$GetAnimeOverview$Media$stats$statusDistribution>?>?)
          _fn);
  TRes scoreDistribution(
      Iterable<Query$GetAnimeOverview$Media$stats$scoreDistribution?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution<
                      Query$GetAnimeOverview$Media$stats$scoreDistribution>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$stats<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$stats<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$stats(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$stats _instance;

  final TRes Function(Query$GetAnimeOverview$Media$stats) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? statusDistribution = _undefined,
    Object? scoreDistribution = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$stats(
        statusDistribution: statusDistribution == _undefined
            ? _instance.statusDistribution
            : (statusDistribution as List<
                Query$GetAnimeOverview$Media$stats$statusDistribution?>?),
        scoreDistribution: scoreDistribution == _undefined
            ? _instance.scoreDistribution
            : (scoreDistribution as List<
                Query$GetAnimeOverview$Media$stats$scoreDistribution?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes statusDistribution(
          Iterable<Query$GetAnimeOverview$Media$stats$statusDistribution?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution<
                          Query$GetAnimeOverview$Media$stats$statusDistribution>?>?)
              _fn) =>
      call(
          statusDistribution: _fn(_instance.statusDistribution?.map((e) => e ==
                  null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution(
                  e,
                  (i) => i,
                )))?.toList());

  TRes scoreDistribution(
          Iterable<Query$GetAnimeOverview$Media$stats$scoreDistribution?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution<
                          Query$GetAnimeOverview$Media$stats$scoreDistribution>?>?)
              _fn) =>
      call(
          scoreDistribution: _fn(_instance.scoreDistribution?.map((e) => e ==
                  null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$stats<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeOverview$Media$stats$statusDistribution?>?
        statusDistribution,
    List<Query$GetAnimeOverview$Media$stats$scoreDistribution?>?
        scoreDistribution,
    String? $__typename,
  }) =>
      _res;

  statusDistribution(_fn) => _res;

  scoreDistribution(_fn) => _res;
}

class Query$GetAnimeOverview$Media$stats$statusDistribution {
  Query$GetAnimeOverview$Media$stats$statusDistribution({
    this.status,
    this.amount,
    this.$__typename = 'StatusDistribution',
  });

  factory Query$GetAnimeOverview$Media$stats$statusDistribution.fromJson(
      Map<String, dynamic> json) {
    final l$status = json['status'];
    final l$amount = json['amount'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$stats$statusDistribution(
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      amount: (l$amount as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$MediaListStatus? status;

  final int? amount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$amount = amount;
    _resultData['amount'] = l$amount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$status = status;
    final l$amount = amount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$status,
      l$amount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$stats$statusDistribution ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$amount = amount;
    final lOther$amount = other.amount;
    if (l$amount != lOther$amount) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$stats$statusDistribution
    on Query$GetAnimeOverview$Media$stats$statusDistribution {
  CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution<
          Query$GetAnimeOverview$Media$stats$statusDistribution>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution(
    Query$GetAnimeOverview$Media$stats$statusDistribution instance,
    TRes Function(Query$GetAnimeOverview$Media$stats$statusDistribution) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$stats$statusDistribution;

  factory CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats$statusDistribution;

  TRes call({
    Enum$MediaListStatus? status,
    int? amount,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$stats$statusDistribution<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$stats$statusDistribution(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$stats$statusDistribution _instance;

  final TRes Function(Query$GetAnimeOverview$Media$stats$statusDistribution)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? status = _undefined,
    Object? amount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$stats$statusDistribution(
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        amount: amount == _undefined ? _instance.amount : (amount as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats$statusDistribution<
        TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$stats$statusDistribution<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats$statusDistribution(
      this._res);

  TRes _res;

  call({
    Enum$MediaListStatus? status,
    int? amount,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$stats$scoreDistribution {
  Query$GetAnimeOverview$Media$stats$scoreDistribution({
    this.score,
    this.amount,
    this.$__typename = 'ScoreDistribution',
  });

  factory Query$GetAnimeOverview$Media$stats$scoreDistribution.fromJson(
      Map<String, dynamic> json) {
    final l$score = json['score'];
    final l$amount = json['amount'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$stats$scoreDistribution(
      score: (l$score as int?),
      amount: (l$amount as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? score;

  final int? amount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$score = score;
    _resultData['score'] = l$score;
    final l$amount = amount;
    _resultData['amount'] = l$amount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$score = score;
    final l$amount = amount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$score,
      l$amount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$stats$scoreDistribution ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
      return false;
    }
    final l$amount = amount;
    final lOther$amount = other.amount;
    if (l$amount != lOther$amount) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$stats$scoreDistribution
    on Query$GetAnimeOverview$Media$stats$scoreDistribution {
  CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution<
          Query$GetAnimeOverview$Media$stats$scoreDistribution>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution(
    Query$GetAnimeOverview$Media$stats$scoreDistribution instance,
    TRes Function(Query$GetAnimeOverview$Media$stats$scoreDistribution) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$stats$scoreDistribution;

  factory CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats$scoreDistribution;

  TRes call({
    int? score,
    int? amount,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$stats$scoreDistribution<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$stats$scoreDistribution(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$stats$scoreDistribution _instance;

  final TRes Function(Query$GetAnimeOverview$Media$stats$scoreDistribution)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? score = _undefined,
    Object? amount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$stats$scoreDistribution(
        score: score == _undefined ? _instance.score : (score as int?),
        amount: amount == _undefined ? _instance.amount : (amount as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats$scoreDistribution<
        TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$stats$scoreDistribution<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$stats$scoreDistribution(
      this._res);

  TRes _res;

  call({
    int? score,
    int? amount,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$relations {
  Query$GetAnimeOverview$Media$relations({
    this.edges,
    this.$__typename = 'MediaConnection',
  });

  factory Query$GetAnimeOverview$Media$relations.fromJson(
      Map<String, dynamic> json) {
    final l$edges = json['edges'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$relations(
      edges: (l$edges as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$relations$edges.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeOverview$Media$relations$edges?>? edges;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$edges = edges;
    _resultData['edges'] = l$edges?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$edges = edges;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$edges == null ? null : Object.hashAll(l$edges.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$relations ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$edges = edges;
    final lOther$edges = other.edges;
    if (l$edges != null && lOther$edges != null) {
      if (l$edges.length != lOther$edges.length) {
        return false;
      }
      for (int i = 0; i < l$edges.length; i++) {
        final l$edges$entry = l$edges[i];
        final lOther$edges$entry = lOther$edges[i];
        if (l$edges$entry != lOther$edges$entry) {
          return false;
        }
      }
    } else if (l$edges != lOther$edges) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$relations
    on Query$GetAnimeOverview$Media$relations {
  CopyWith$Query$GetAnimeOverview$Media$relations<
          Query$GetAnimeOverview$Media$relations>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$relations(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$relations<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$relations(
    Query$GetAnimeOverview$Media$relations instance,
    TRes Function(Query$GetAnimeOverview$Media$relations) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$relations;

  factory CopyWith$Query$GetAnimeOverview$Media$relations.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$relations;

  TRes call({
    List<Query$GetAnimeOverview$Media$relations$edges?>? edges,
    String? $__typename,
  });
  TRes edges(
      Iterable<Query$GetAnimeOverview$Media$relations$edges?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$relations$edges<
                      Query$GetAnimeOverview$Media$relations$edges>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$relations<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$relations<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$relations(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$relations _instance;

  final TRes Function(Query$GetAnimeOverview$Media$relations) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? edges = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$relations(
        edges: edges == _undefined
            ? _instance.edges
            : (edges as List<Query$GetAnimeOverview$Media$relations$edges?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes edges(
          Iterable<Query$GetAnimeOverview$Media$relations$edges?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$relations$edges<
                          Query$GetAnimeOverview$Media$relations$edges>?>?)
              _fn) =>
      call(
          edges: _fn(_instance.edges?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$relations$edges(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$relations<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$relations<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$relations(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeOverview$Media$relations$edges?>? edges,
    String? $__typename,
  }) =>
      _res;

  edges(_fn) => _res;
}

class Query$GetAnimeOverview$Media$relations$edges {
  Query$GetAnimeOverview$Media$relations$edges({
    this.id,
    this.relationType,
    this.node,
    this.$__typename = 'MediaEdge',
  });

  factory Query$GetAnimeOverview$Media$relations$edges.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$relationType = json['relationType'];
    final l$node = json['node'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$relations$edges(
      id: (l$id as int?),
      relationType: l$relationType == null
          ? null
          : fromJson$Enum$MediaRelation((l$relationType as String)),
      node: l$node == null
          ? null
          : Fragment$AnimeCard.fromJson((l$node as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int? id;

  final Enum$MediaRelation? relationType;

  final Fragment$AnimeCard? node;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$relationType = relationType;
    _resultData['relationType'] = l$relationType == null
        ? null
        : toJson$Enum$MediaRelation(l$relationType);
    final l$node = node;
    _resultData['node'] = l$node?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$relationType = relationType;
    final l$node = node;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$relationType,
      l$node,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$relations$edges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$relationType = relationType;
    final lOther$relationType = other.relationType;
    if (l$relationType != lOther$relationType) {
      return false;
    }
    final l$node = node;
    final lOther$node = other.node;
    if (l$node != lOther$node) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$relations$edges
    on Query$GetAnimeOverview$Media$relations$edges {
  CopyWith$Query$GetAnimeOverview$Media$relations$edges<
          Query$GetAnimeOverview$Media$relations$edges>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$relations$edges(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$relations$edges<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$relations$edges(
    Query$GetAnimeOverview$Media$relations$edges instance,
    TRes Function(Query$GetAnimeOverview$Media$relations$edges) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$relations$edges;

  factory CopyWith$Query$GetAnimeOverview$Media$relations$edges.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$relations$edges;

  TRes call({
    int? id,
    Enum$MediaRelation? relationType,
    Fragment$AnimeCard? node,
    String? $__typename,
  });
  CopyWith$Fragment$AnimeCard<TRes> get node;
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$relations$edges<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$relations$edges<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$relations$edges(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$relations$edges _instance;

  final TRes Function(Query$GetAnimeOverview$Media$relations$edges) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? relationType = _undefined,
    Object? node = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$relations$edges(
        id: id == _undefined ? _instance.id : (id as int?),
        relationType: relationType == _undefined
            ? _instance.relationType
            : (relationType as Enum$MediaRelation?),
        node:
            node == _undefined ? _instance.node : (node as Fragment$AnimeCard?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$AnimeCard<TRes> get node {
    final local$node = _instance.node;
    return local$node == null
        ? CopyWith$Fragment$AnimeCard.stub(_then(_instance))
        : CopyWith$Fragment$AnimeCard(local$node, (e) => call(node: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$relations$edges<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$relations$edges<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$relations$edges(this._res);

  TRes _res;

  call({
    int? id,
    Enum$MediaRelation? relationType,
    Fragment$AnimeCard? node,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$AnimeCard<TRes> get node =>
      CopyWith$Fragment$AnimeCard.stub(_res);
}

class Query$GetAnimeOverview$Media$characterPreview {
  Query$GetAnimeOverview$Media$characterPreview({
    this.edges,
    this.$__typename = 'CharacterConnection',
  });

  factory Query$GetAnimeOverview$Media$characterPreview.fromJson(
      Map<String, dynamic> json) {
    final l$edges = json['edges'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$characterPreview(
      edges: (l$edges as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$characterPreview$edges.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeOverview$Media$characterPreview$edges?>? edges;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$edges = edges;
    _resultData['edges'] = l$edges?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$edges = edges;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$edges == null ? null : Object.hashAll(l$edges.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$characterPreview ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$edges = edges;
    final lOther$edges = other.edges;
    if (l$edges != null && lOther$edges != null) {
      if (l$edges.length != lOther$edges.length) {
        return false;
      }
      for (int i = 0; i < l$edges.length; i++) {
        final l$edges$entry = l$edges[i];
        final lOther$edges$entry = lOther$edges[i];
        if (l$edges$entry != lOther$edges$entry) {
          return false;
        }
      }
    } else if (l$edges != lOther$edges) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$characterPreview
    on Query$GetAnimeOverview$Media$characterPreview {
  CopyWith$Query$GetAnimeOverview$Media$characterPreview<
          Query$GetAnimeOverview$Media$characterPreview>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$characterPreview(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$characterPreview<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$characterPreview(
    Query$GetAnimeOverview$Media$characterPreview instance,
    TRes Function(Query$GetAnimeOverview$Media$characterPreview) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$characterPreview;

  factory CopyWith$Query$GetAnimeOverview$Media$characterPreview.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$characterPreview;

  TRes call({
    List<Query$GetAnimeOverview$Media$characterPreview$edges?>? edges,
    String? $__typename,
  });
  TRes edges(
      Iterable<Query$GetAnimeOverview$Media$characterPreview$edges?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges<
                      Query$GetAnimeOverview$Media$characterPreview$edges>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$characterPreview<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$characterPreview<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$characterPreview(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$characterPreview _instance;

  final TRes Function(Query$GetAnimeOverview$Media$characterPreview) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? edges = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$characterPreview(
        edges: edges == _undefined
            ? _instance.edges
            : (edges
                as List<Query$GetAnimeOverview$Media$characterPreview$edges?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes edges(
          Iterable<Query$GetAnimeOverview$Media$characterPreview$edges?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges<
                          Query$GetAnimeOverview$Media$characterPreview$edges>?>?)
              _fn) =>
      call(
          edges: _fn(_instance.edges?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$characterPreview<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$characterPreview<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$characterPreview(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeOverview$Media$characterPreview$edges?>? edges,
    String? $__typename,
  }) =>
      _res;

  edges(_fn) => _res;
}

class Query$GetAnimeOverview$Media$characterPreview$edges {
  Query$GetAnimeOverview$Media$characterPreview$edges({
    this.id,
    this.role,
    this.name,
    this.voiceActors,
    this.node,
    this.$__typename = 'CharacterEdge',
  });

  factory Query$GetAnimeOverview$Media$characterPreview$edges.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$role = json['role'];
    final l$name = json['name'];
    final l$voiceActors = json['voiceActors'];
    final l$node = json['node'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$characterPreview$edges(
      id: (l$id as int?),
      role: l$role == null
          ? null
          : fromJson$Enum$CharacterRole((l$role as String)),
      name: (l$name as String?),
      voiceActors: (l$voiceActors as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Fragment$StaffCard.fromJson((e as Map<String, dynamic>)))
          .toList(),
      node: l$node == null
          ? null
          : Fragment$CharacterCard.fromJson((l$node as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int? id;

  final Enum$CharacterRole? role;

  final String? name;

  final List<Fragment$StaffCard?>? voiceActors;

  final Fragment$CharacterCard? node;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$role = role;
    _resultData['role'] =
        l$role == null ? null : toJson$Enum$CharacterRole(l$role);
    final l$name = name;
    _resultData['name'] = l$name;
    final l$voiceActors = voiceActors;
    _resultData['voiceActors'] =
        l$voiceActors?.map((e) => e?.toJson()).toList();
    final l$node = node;
    _resultData['node'] = l$node?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$role = role;
    final l$name = name;
    final l$voiceActors = voiceActors;
    final l$node = node;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$role,
      l$name,
      l$voiceActors == null
          ? null
          : Object.hashAll(l$voiceActors.map((v) => v)),
      l$node,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$characterPreview$edges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$role = role;
    final lOther$role = other.role;
    if (l$role != lOther$role) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$voiceActors = voiceActors;
    final lOther$voiceActors = other.voiceActors;
    if (l$voiceActors != null && lOther$voiceActors != null) {
      if (l$voiceActors.length != lOther$voiceActors.length) {
        return false;
      }
      for (int i = 0; i < l$voiceActors.length; i++) {
        final l$voiceActors$entry = l$voiceActors[i];
        final lOther$voiceActors$entry = lOther$voiceActors[i];
        if (l$voiceActors$entry != lOther$voiceActors$entry) {
          return false;
        }
      }
    } else if (l$voiceActors != lOther$voiceActors) {
      return false;
    }
    final l$node = node;
    final lOther$node = other.node;
    if (l$node != lOther$node) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$characterPreview$edges
    on Query$GetAnimeOverview$Media$characterPreview$edges {
  CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges<
          Query$GetAnimeOverview$Media$characterPreview$edges>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges(
    Query$GetAnimeOverview$Media$characterPreview$edges instance,
    TRes Function(Query$GetAnimeOverview$Media$characterPreview$edges) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$characterPreview$edges;

  factory CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$characterPreview$edges;

  TRes call({
    int? id,
    Enum$CharacterRole? role,
    String? name,
    List<Fragment$StaffCard?>? voiceActors,
    Fragment$CharacterCard? node,
    String? $__typename,
  });
  TRes voiceActors(
      Iterable<Fragment$StaffCard?>? Function(
              Iterable<CopyWith$Fragment$StaffCard<Fragment$StaffCard>?>?)
          _fn);
  CopyWith$Fragment$CharacterCard<TRes> get node;
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$characterPreview$edges<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$characterPreview$edges(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$characterPreview$edges _instance;

  final TRes Function(Query$GetAnimeOverview$Media$characterPreview$edges)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? role = _undefined,
    Object? name = _undefined,
    Object? voiceActors = _undefined,
    Object? node = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$characterPreview$edges(
        id: id == _undefined ? _instance.id : (id as int?),
        role:
            role == _undefined ? _instance.role : (role as Enum$CharacterRole?),
        name: name == _undefined ? _instance.name : (name as String?),
        voiceActors: voiceActors == _undefined
            ? _instance.voiceActors
            : (voiceActors as List<Fragment$StaffCard?>?),
        node: node == _undefined
            ? _instance.node
            : (node as Fragment$CharacterCard?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes voiceActors(
          Iterable<Fragment$StaffCard?>? Function(
                  Iterable<CopyWith$Fragment$StaffCard<Fragment$StaffCard>?>?)
              _fn) =>
      call(
          voiceActors: _fn(_instance.voiceActors?.map((e) => e == null
              ? null
              : CopyWith$Fragment$StaffCard(
                  e,
                  (i) => i,
                )))?.toList());

  CopyWith$Fragment$CharacterCard<TRes> get node {
    final local$node = _instance.node;
    return local$node == null
        ? CopyWith$Fragment$CharacterCard.stub(_then(_instance))
        : CopyWith$Fragment$CharacterCard(local$node, (e) => call(node: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$characterPreview$edges<
        TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$characterPreview$edges<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$characterPreview$edges(
      this._res);

  TRes _res;

  call({
    int? id,
    Enum$CharacterRole? role,
    String? name,
    List<Fragment$StaffCard?>? voiceActors,
    Fragment$CharacterCard? node,
    String? $__typename,
  }) =>
      _res;

  voiceActors(_fn) => _res;

  CopyWith$Fragment$CharacterCard<TRes> get node =>
      CopyWith$Fragment$CharacterCard.stub(_res);
}

class Query$GetAnimeOverview$Media$staffPreview {
  Query$GetAnimeOverview$Media$staffPreview({
    this.edges,
    this.$__typename = 'StaffConnection',
  });

  factory Query$GetAnimeOverview$Media$staffPreview.fromJson(
      Map<String, dynamic> json) {
    final l$edges = json['edges'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$staffPreview(
      edges: (l$edges as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$staffPreview$edges.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeOverview$Media$staffPreview$edges?>? edges;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$edges = edges;
    _resultData['edges'] = l$edges?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$edges = edges;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$edges == null ? null : Object.hashAll(l$edges.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$staffPreview ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$edges = edges;
    final lOther$edges = other.edges;
    if (l$edges != null && lOther$edges != null) {
      if (l$edges.length != lOther$edges.length) {
        return false;
      }
      for (int i = 0; i < l$edges.length; i++) {
        final l$edges$entry = l$edges[i];
        final lOther$edges$entry = lOther$edges[i];
        if (l$edges$entry != lOther$edges$entry) {
          return false;
        }
      }
    } else if (l$edges != lOther$edges) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$staffPreview
    on Query$GetAnimeOverview$Media$staffPreview {
  CopyWith$Query$GetAnimeOverview$Media$staffPreview<
          Query$GetAnimeOverview$Media$staffPreview>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$staffPreview(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$staffPreview<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$staffPreview(
    Query$GetAnimeOverview$Media$staffPreview instance,
    TRes Function(Query$GetAnimeOverview$Media$staffPreview) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$staffPreview;

  factory CopyWith$Query$GetAnimeOverview$Media$staffPreview.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$staffPreview;

  TRes call({
    List<Query$GetAnimeOverview$Media$staffPreview$edges?>? edges,
    String? $__typename,
  });
  TRes edges(
      Iterable<Query$GetAnimeOverview$Media$staffPreview$edges?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges<
                      Query$GetAnimeOverview$Media$staffPreview$edges>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$staffPreview<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$staffPreview<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$staffPreview(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$staffPreview _instance;

  final TRes Function(Query$GetAnimeOverview$Media$staffPreview) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? edges = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$staffPreview(
        edges: edges == _undefined
            ? _instance.edges
            : (edges
                as List<Query$GetAnimeOverview$Media$staffPreview$edges?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes edges(
          Iterable<Query$GetAnimeOverview$Media$staffPreview$edges?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges<
                          Query$GetAnimeOverview$Media$staffPreview$edges>?>?)
              _fn) =>
      call(
          edges: _fn(_instance.edges?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$staffPreview<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$staffPreview<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$staffPreview(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeOverview$Media$staffPreview$edges?>? edges,
    String? $__typename,
  }) =>
      _res;

  edges(_fn) => _res;
}

class Query$GetAnimeOverview$Media$staffPreview$edges {
  Query$GetAnimeOverview$Media$staffPreview$edges({
    this.id,
    this.role,
    this.node,
    this.$__typename = 'StaffEdge',
  });

  factory Query$GetAnimeOverview$Media$staffPreview$edges.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$role = json['role'];
    final l$node = json['node'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$staffPreview$edges(
      id: (l$id as int?),
      role: (l$role as String?),
      node: l$node == null
          ? null
          : Fragment$StaffCard.fromJson((l$node as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int? id;

  final String? role;

  final Fragment$StaffCard? node;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$role = role;
    _resultData['role'] = l$role;
    final l$node = node;
    _resultData['node'] = l$node?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$role = role;
    final l$node = node;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$role,
      l$node,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$staffPreview$edges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$role = role;
    final lOther$role = other.role;
    if (l$role != lOther$role) {
      return false;
    }
    final l$node = node;
    final lOther$node = other.node;
    if (l$node != lOther$node) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$staffPreview$edges
    on Query$GetAnimeOverview$Media$staffPreview$edges {
  CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges<
          Query$GetAnimeOverview$Media$staffPreview$edges>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges(
    Query$GetAnimeOverview$Media$staffPreview$edges instance,
    TRes Function(Query$GetAnimeOverview$Media$staffPreview$edges) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$staffPreview$edges;

  factory CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$staffPreview$edges;

  TRes call({
    int? id,
    String? role,
    Fragment$StaffCard? node,
    String? $__typename,
  });
  CopyWith$Fragment$StaffCard<TRes> get node;
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$staffPreview$edges<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$staffPreview$edges(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$staffPreview$edges _instance;

  final TRes Function(Query$GetAnimeOverview$Media$staffPreview$edges) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? role = _undefined,
    Object? node = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$staffPreview$edges(
        id: id == _undefined ? _instance.id : (id as int?),
        role: role == _undefined ? _instance.role : (role as String?),
        node:
            node == _undefined ? _instance.node : (node as Fragment$StaffCard?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$StaffCard<TRes> get node {
    final local$node = _instance.node;
    return local$node == null
        ? CopyWith$Fragment$StaffCard.stub(_then(_instance))
        : CopyWith$Fragment$StaffCard(local$node, (e) => call(node: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$staffPreview$edges<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$staffPreview$edges<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$staffPreview$edges(this._res);

  TRes _res;

  call({
    int? id,
    String? role,
    Fragment$StaffCard? node,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$StaffCard<TRes> get node =>
      CopyWith$Fragment$StaffCard.stub(_res);
}

class Query$GetAnimeOverview$Media$studios {
  Query$GetAnimeOverview$Media$studios({
    this.edges,
    this.$__typename = 'StudioConnection',
  });

  factory Query$GetAnimeOverview$Media$studios.fromJson(
      Map<String, dynamic> json) {
    final l$edges = json['edges'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$studios(
      edges: (l$edges as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$studios$edges.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeOverview$Media$studios$edges?>? edges;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$edges = edges;
    _resultData['edges'] = l$edges?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$edges = edges;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$edges == null ? null : Object.hashAll(l$edges.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$studios ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$edges = edges;
    final lOther$edges = other.edges;
    if (l$edges != null && lOther$edges != null) {
      if (l$edges.length != lOther$edges.length) {
        return false;
      }
      for (int i = 0; i < l$edges.length; i++) {
        final l$edges$entry = l$edges[i];
        final lOther$edges$entry = lOther$edges[i];
        if (l$edges$entry != lOther$edges$entry) {
          return false;
        }
      }
    } else if (l$edges != lOther$edges) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$studios
    on Query$GetAnimeOverview$Media$studios {
  CopyWith$Query$GetAnimeOverview$Media$studios<
          Query$GetAnimeOverview$Media$studios>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$studios(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$studios<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$studios(
    Query$GetAnimeOverview$Media$studios instance,
    TRes Function(Query$GetAnimeOverview$Media$studios) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$studios;

  factory CopyWith$Query$GetAnimeOverview$Media$studios.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios;

  TRes call({
    List<Query$GetAnimeOverview$Media$studios$edges?>? edges,
    String? $__typename,
  });
  TRes edges(
      Iterable<Query$GetAnimeOverview$Media$studios$edges?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$studios$edges<
                      Query$GetAnimeOverview$Media$studios$edges>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$studios<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$studios<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$studios(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$studios _instance;

  final TRes Function(Query$GetAnimeOverview$Media$studios) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? edges = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$studios(
        edges: edges == _undefined
            ? _instance.edges
            : (edges as List<Query$GetAnimeOverview$Media$studios$edges?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes edges(
          Iterable<Query$GetAnimeOverview$Media$studios$edges?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$studios$edges<
                          Query$GetAnimeOverview$Media$studios$edges>?>?)
              _fn) =>
      call(
          edges: _fn(_instance.edges?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$studios$edges(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$studios<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeOverview$Media$studios$edges?>? edges,
    String? $__typename,
  }) =>
      _res;

  edges(_fn) => _res;
}

class Query$GetAnimeOverview$Media$studios$edges {
  Query$GetAnimeOverview$Media$studios$edges({
    required this.isMain,
    this.node,
    this.$__typename = 'StudioEdge',
  });

  factory Query$GetAnimeOverview$Media$studios$edges.fromJson(
      Map<String, dynamic> json) {
    final l$isMain = json['isMain'];
    final l$node = json['node'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$studios$edges(
      isMain: (l$isMain as bool),
      node: l$node == null
          ? null
          : Query$GetAnimeOverview$Media$studios$edges$node.fromJson(
              (l$node as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final bool isMain;

  final Query$GetAnimeOverview$Media$studios$edges$node? node;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$isMain = isMain;
    _resultData['isMain'] = l$isMain;
    final l$node = node;
    _resultData['node'] = l$node?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$isMain = isMain;
    final l$node = node;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$isMain,
      l$node,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$studios$edges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$isMain = isMain;
    final lOther$isMain = other.isMain;
    if (l$isMain != lOther$isMain) {
      return false;
    }
    final l$node = node;
    final lOther$node = other.node;
    if (l$node != lOther$node) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$studios$edges
    on Query$GetAnimeOverview$Media$studios$edges {
  CopyWith$Query$GetAnimeOverview$Media$studios$edges<
          Query$GetAnimeOverview$Media$studios$edges>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$studios$edges(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$studios$edges<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$studios$edges(
    Query$GetAnimeOverview$Media$studios$edges instance,
    TRes Function(Query$GetAnimeOverview$Media$studios$edges) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$studios$edges;

  factory CopyWith$Query$GetAnimeOverview$Media$studios$edges.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios$edges;

  TRes call({
    bool? isMain,
    Query$GetAnimeOverview$Media$studios$edges$node? node,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<TRes> get node;
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$studios$edges<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$studios$edges<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$studios$edges(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$studios$edges _instance;

  final TRes Function(Query$GetAnimeOverview$Media$studios$edges) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? isMain = _undefined,
    Object? node = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$studios$edges(
        isMain: isMain == _undefined || isMain == null
            ? _instance.isMain
            : (isMain as bool),
        node: node == _undefined
            ? _instance.node
            : (node as Query$GetAnimeOverview$Media$studios$edges$node?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<TRes> get node {
    final local$node = _instance.node;
    return local$node == null
        ? CopyWith$Query$GetAnimeOverview$Media$studios$edges$node.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$studios$edges$node(
            local$node, (e) => call(node: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios$edges<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$studios$edges<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios$edges(this._res);

  TRes _res;

  call({
    bool? isMain,
    Query$GetAnimeOverview$Media$studios$edges$node? node,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<TRes> get node =>
      CopyWith$Query$GetAnimeOverview$Media$studios$edges$node.stub(_res);
}

class Query$GetAnimeOverview$Media$studios$edges$node {
  Query$GetAnimeOverview$Media$studios$edges$node({
    required this.id,
    required this.name,
    this.$__typename = 'Studio',
  });

  factory Query$GetAnimeOverview$Media$studios$edges$node.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$studios$edges$node(
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
    if (other is! Query$GetAnimeOverview$Media$studios$edges$node ||
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

extension UtilityExtension$Query$GetAnimeOverview$Media$studios$edges$node
    on Query$GetAnimeOverview$Media$studios$edges$node {
  CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<
          Query$GetAnimeOverview$Media$studios$edges$node>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$studios$edges$node(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$studios$edges$node(
    Query$GetAnimeOverview$Media$studios$edges$node instance,
    TRes Function(Query$GetAnimeOverview$Media$studios$edges$node) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$studios$edges$node;

  factory CopyWith$Query$GetAnimeOverview$Media$studios$edges$node.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios$edges$node;

  TRes call({
    int? id,
    String? name,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$studios$edges$node<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$studios$edges$node(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$studios$edges$node _instance;

  final TRes Function(Query$GetAnimeOverview$Media$studios$edges$node) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$studios$edges$node(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios$edges$node<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$studios$edges$node<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$studios$edges$node(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$recommendations {
  Query$GetAnimeOverview$Media$recommendations({
    this.pageInfo,
    this.nodes,
    this.$__typename = 'RecommendationConnection',
  });

  factory Query$GetAnimeOverview$Media$recommendations.fromJson(
      Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$recommendations(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetAnimeOverview$Media$recommendations$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Media$recommendations$nodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeOverview$Media$recommendations$pageInfo? pageInfo;

  final List<Query$GetAnimeOverview$Media$recommendations$nodes?>? nodes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$nodes = nodes;
    _resultData['nodes'] = l$nodes?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$nodes = nodes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$nodes == null ? null : Object.hashAll(l$nodes.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$recommendations ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$recommendations
    on Query$GetAnimeOverview$Media$recommendations {
  CopyWith$Query$GetAnimeOverview$Media$recommendations<
          Query$GetAnimeOverview$Media$recommendations>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$recommendations(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$recommendations<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$recommendations(
    Query$GetAnimeOverview$Media$recommendations instance,
    TRes Function(Query$GetAnimeOverview$Media$recommendations) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations;

  factory CopyWith$Query$GetAnimeOverview$Media$recommendations.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations;

  TRes call({
    Query$GetAnimeOverview$Media$recommendations$pageInfo? pageInfo,
    List<Query$GetAnimeOverview$Media$recommendations$nodes?>? nodes,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<TRes>
      get pageInfo;
  TRes nodes(
      Iterable<Query$GetAnimeOverview$Media$recommendations$nodes?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes<
                      Query$GetAnimeOverview$Media$recommendations$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$recommendations<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$recommendations _instance;

  final TRes Function(Query$GetAnimeOverview$Media$recommendations) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$recommendations(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo
                as Query$GetAnimeOverview$Media$recommendations$pageInfo?),
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes
                as List<Query$GetAnimeOverview$Media$recommendations$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<TRes>
      get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes nodes(
          Iterable<Query$GetAnimeOverview$Media$recommendations$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes<
                          Query$GetAnimeOverview$Media$recommendations$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$recommendations<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations(this._res);

  TRes _res;

  call({
    Query$GetAnimeOverview$Media$recommendations$pageInfo? pageInfo,
    List<Query$GetAnimeOverview$Media$recommendations$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<TRes>
      get pageInfo =>
          CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo.stub(
              _res);

  nodes(_fn) => _res;
}

class Query$GetAnimeOverview$Media$recommendations$pageInfo {
  Query$GetAnimeOverview$Media$recommendations$pageInfo({
    this.total,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetAnimeOverview$Media$recommendations$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$recommendations$pageInfo(
      total: (l$total as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$recommendations$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$recommendations$pageInfo
    on Query$GetAnimeOverview$Media$recommendations$pageInfo {
  CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<
          Query$GetAnimeOverview$Media$recommendations$pageInfo>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo(
    Query$GetAnimeOverview$Media$recommendations$pageInfo instance,
    TRes Function(Query$GetAnimeOverview$Media$recommendations$pageInfo) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations$pageInfo;

  factory CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations$pageInfo;

  TRes call({
    int? total,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations$pageInfo<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$recommendations$pageInfo _instance;

  final TRes Function(Query$GetAnimeOverview$Media$recommendations$pageInfo)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$recommendations$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations$pageInfo<
        TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$recommendations$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations$pageInfo(
      this._res);

  TRes _res;

  call({
    int? total,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Media$recommendations$nodes {
  Query$GetAnimeOverview$Media$recommendations$nodes({
    required this.id,
    this.rating,
    this.userRating,
    this.mediaRecommendation,
    this.user,
    this.$__typename = 'Recommendation',
  });

  factory Query$GetAnimeOverview$Media$recommendations$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$rating = json['rating'];
    final l$userRating = json['userRating'];
    final l$mediaRecommendation = json['mediaRecommendation'];
    final l$user = json['user'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$recommendations$nodes(
      id: (l$id as int),
      rating: (l$rating as int?),
      userRating: l$userRating == null
          ? null
          : fromJson$Enum$RecommendationRating((l$userRating as String)),
      mediaRecommendation: l$mediaRecommendation == null
          ? null
          : Fragment$AnimeCard.fromJson(
              (l$mediaRecommendation as Map<String, dynamic>)),
      user: l$user == null
          ? null
          : Fragment$UserAvatar.fromJson((l$user as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int? rating;

  final Enum$RecommendationRating? userRating;

  final Fragment$AnimeCard? mediaRecommendation;

  final Fragment$UserAvatar? user;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$rating = rating;
    _resultData['rating'] = l$rating;
    final l$userRating = userRating;
    _resultData['userRating'] = l$userRating == null
        ? null
        : toJson$Enum$RecommendationRating(l$userRating);
    final l$mediaRecommendation = mediaRecommendation;
    _resultData['mediaRecommendation'] = l$mediaRecommendation?.toJson();
    final l$user = user;
    _resultData['user'] = l$user?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$rating = rating;
    final l$userRating = userRating;
    final l$mediaRecommendation = mediaRecommendation;
    final l$user = user;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$rating,
      l$userRating,
      l$mediaRecommendation,
      l$user,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$recommendations$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$rating = rating;
    final lOther$rating = other.rating;
    if (l$rating != lOther$rating) {
      return false;
    }
    final l$userRating = userRating;
    final lOther$userRating = other.userRating;
    if (l$userRating != lOther$userRating) {
      return false;
    }
    final l$mediaRecommendation = mediaRecommendation;
    final lOther$mediaRecommendation = other.mediaRecommendation;
    if (l$mediaRecommendation != lOther$mediaRecommendation) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$recommendations$nodes
    on Query$GetAnimeOverview$Media$recommendations$nodes {
  CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes<
          Query$GetAnimeOverview$Media$recommendations$nodes>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes(
    Query$GetAnimeOverview$Media$recommendations$nodes instance,
    TRes Function(Query$GetAnimeOverview$Media$recommendations$nodes) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations$nodes;

  factory CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations$nodes;

  TRes call({
    int? id,
    int? rating,
    Enum$RecommendationRating? userRating,
    Fragment$AnimeCard? mediaRecommendation,
    Fragment$UserAvatar? user,
    String? $__typename,
  });
  CopyWith$Fragment$AnimeCard<TRes> get mediaRecommendation;
  CopyWith$Fragment$UserAvatar<TRes> get user;
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations$nodes<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$recommendations$nodes(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$recommendations$nodes _instance;

  final TRes Function(Query$GetAnimeOverview$Media$recommendations$nodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? rating = _undefined,
    Object? userRating = _undefined,
    Object? mediaRecommendation = _undefined,
    Object? user = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$recommendations$nodes(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        rating: rating == _undefined ? _instance.rating : (rating as int?),
        userRating: userRating == _undefined
            ? _instance.userRating
            : (userRating as Enum$RecommendationRating?),
        mediaRecommendation: mediaRecommendation == _undefined
            ? _instance.mediaRecommendation
            : (mediaRecommendation as Fragment$AnimeCard?),
        user: user == _undefined
            ? _instance.user
            : (user as Fragment$UserAvatar?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$AnimeCard<TRes> get mediaRecommendation {
    final local$mediaRecommendation = _instance.mediaRecommendation;
    return local$mediaRecommendation == null
        ? CopyWith$Fragment$AnimeCard.stub(_then(_instance))
        : CopyWith$Fragment$AnimeCard(
            local$mediaRecommendation, (e) => call(mediaRecommendation: e));
  }

  CopyWith$Fragment$UserAvatar<TRes> get user {
    final local$user = _instance.user;
    return local$user == null
        ? CopyWith$Fragment$UserAvatar.stub(_then(_instance))
        : CopyWith$Fragment$UserAvatar(local$user, (e) => call(user: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations$nodes<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Media$recommendations$nodes<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$recommendations$nodes(
      this._res);

  TRes _res;

  call({
    int? id,
    int? rating,
    Enum$RecommendationRating? userRating,
    Fragment$AnimeCard? mediaRecommendation,
    Fragment$UserAvatar? user,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$AnimeCard<TRes> get mediaRecommendation =>
      CopyWith$Fragment$AnimeCard.stub(_res);

  CopyWith$Fragment$UserAvatar<TRes> get user =>
      CopyWith$Fragment$UserAvatar.stub(_res);
}

class Query$GetAnimeOverview$Media$externalLinks {
  Query$GetAnimeOverview$Media$externalLinks({
    required this.id,
    required this.site,
    this.url,
    this.type,
    this.language,
    this.color,
    this.icon,
    this.notes,
    this.isDisabled,
    this.$__typename = 'MediaExternalLink',
  });

  factory Query$GetAnimeOverview$Media$externalLinks.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$site = json['site'];
    final l$url = json['url'];
    final l$type = json['type'];
    final l$language = json['language'];
    final l$color = json['color'];
    final l$icon = json['icon'];
    final l$notes = json['notes'];
    final l$isDisabled = json['isDisabled'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Media$externalLinks(
      id: (l$id as int),
      site: (l$site as String),
      url: (l$url as String?),
      type: l$type == null
          ? null
          : fromJson$Enum$ExternalLinkType((l$type as String)),
      language: (l$language as String?),
      color: (l$color as String?),
      icon: (l$icon as String?),
      notes: (l$notes as String?),
      isDisabled: (l$isDisabled as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String site;

  final String? url;

  final Enum$ExternalLinkType? type;

  final String? language;

  final String? color;

  final String? icon;

  final String? notes;

  final bool? isDisabled;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$site = site;
    _resultData['site'] = l$site;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$type = type;
    _resultData['type'] =
        l$type == null ? null : toJson$Enum$ExternalLinkType(l$type);
    final l$language = language;
    _resultData['language'] = l$language;
    final l$color = color;
    _resultData['color'] = l$color;
    final l$icon = icon;
    _resultData['icon'] = l$icon;
    final l$notes = notes;
    _resultData['notes'] = l$notes;
    final l$isDisabled = isDisabled;
    _resultData['isDisabled'] = l$isDisabled;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$site = site;
    final l$url = url;
    final l$type = type;
    final l$language = language;
    final l$color = color;
    final l$icon = icon;
    final l$notes = notes;
    final l$isDisabled = isDisabled;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$site,
      l$url,
      l$type,
      l$language,
      l$color,
      l$icon,
      l$notes,
      l$isDisabled,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Media$externalLinks ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$site = site;
    final lOther$site = other.site;
    if (l$site != lOther$site) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (l$type != lOther$type) {
      return false;
    }
    final l$language = language;
    final lOther$language = other.language;
    if (l$language != lOther$language) {
      return false;
    }
    final l$color = color;
    final lOther$color = other.color;
    if (l$color != lOther$color) {
      return false;
    }
    final l$icon = icon;
    final lOther$icon = other.icon;
    if (l$icon != lOther$icon) {
      return false;
    }
    final l$notes = notes;
    final lOther$notes = other.notes;
    if (l$notes != lOther$notes) {
      return false;
    }
    final l$isDisabled = isDisabled;
    final lOther$isDisabled = other.isDisabled;
    if (l$isDisabled != lOther$isDisabled) {
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

extension UtilityExtension$Query$GetAnimeOverview$Media$externalLinks
    on Query$GetAnimeOverview$Media$externalLinks {
  CopyWith$Query$GetAnimeOverview$Media$externalLinks<
          Query$GetAnimeOverview$Media$externalLinks>
      get copyWith => CopyWith$Query$GetAnimeOverview$Media$externalLinks(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Media$externalLinks<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Media$externalLinks(
    Query$GetAnimeOverview$Media$externalLinks instance,
    TRes Function(Query$GetAnimeOverview$Media$externalLinks) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Media$externalLinks;

  factory CopyWith$Query$GetAnimeOverview$Media$externalLinks.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Media$externalLinks;

  TRes call({
    int? id,
    String? site,
    String? url,
    Enum$ExternalLinkType? type,
    String? language,
    String? color,
    String? icon,
    String? notes,
    bool? isDisabled,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Media$externalLinks<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$externalLinks<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Media$externalLinks(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Media$externalLinks _instance;

  final TRes Function(Query$GetAnimeOverview$Media$externalLinks) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? site = _undefined,
    Object? url = _undefined,
    Object? type = _undefined,
    Object? language = _undefined,
    Object? color = _undefined,
    Object? icon = _undefined,
    Object? notes = _undefined,
    Object? isDisabled = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Media$externalLinks(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        site: site == _undefined || site == null
            ? _instance.site
            : (site as String),
        url: url == _undefined ? _instance.url : (url as String?),
        type: type == _undefined
            ? _instance.type
            : (type as Enum$ExternalLinkType?),
        language:
            language == _undefined ? _instance.language : (language as String?),
        color: color == _undefined ? _instance.color : (color as String?),
        icon: icon == _undefined ? _instance.icon : (icon as String?),
        notes: notes == _undefined ? _instance.notes : (notes as String?),
        isDisabled: isDisabled == _undefined
            ? _instance.isDisabled
            : (isDisabled as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Media$externalLinks<TRes>
    implements CopyWith$Query$GetAnimeOverview$Media$externalLinks<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Media$externalLinks(this._res);

  TRes _res;

  call({
    int? id,
    String? site,
    String? url,
    Enum$ExternalLinkType? type,
    String? language,
    String? color,
    String? icon,
    String? notes,
    bool? isDisabled,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Page {
  Query$GetAnimeOverview$Page({
    this.pageInfo,
    this.mediaList,
    this.$__typename = 'Page',
  });

  factory Query$GetAnimeOverview$Page.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$mediaList = json['mediaList'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Page(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetAnimeOverview$Page$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      mediaList: (l$mediaList as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeOverview$Page$mediaList.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeOverview$Page$pageInfo? pageInfo;

  final List<Query$GetAnimeOverview$Page$mediaList?>? mediaList;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$mediaList = mediaList;
    _resultData['mediaList'] = l$mediaList?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$mediaList = mediaList;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$mediaList == null ? null : Object.hashAll(l$mediaList.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$mediaList = mediaList;
    final lOther$mediaList = other.mediaList;
    if (l$mediaList != null && lOther$mediaList != null) {
      if (l$mediaList.length != lOther$mediaList.length) {
        return false;
      }
      for (int i = 0; i < l$mediaList.length; i++) {
        final l$mediaList$entry = l$mediaList[i];
        final lOther$mediaList$entry = lOther$mediaList[i];
        if (l$mediaList$entry != lOther$mediaList$entry) {
          return false;
        }
      }
    } else if (l$mediaList != lOther$mediaList) {
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

extension UtilityExtension$Query$GetAnimeOverview$Page
    on Query$GetAnimeOverview$Page {
  CopyWith$Query$GetAnimeOverview$Page<Query$GetAnimeOverview$Page>
      get copyWith => CopyWith$Query$GetAnimeOverview$Page(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Page<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Page(
    Query$GetAnimeOverview$Page instance,
    TRes Function(Query$GetAnimeOverview$Page) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Page;

  factory CopyWith$Query$GetAnimeOverview$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Page;

  TRes call({
    Query$GetAnimeOverview$Page$pageInfo? pageInfo,
    List<Query$GetAnimeOverview$Page$mediaList?>? mediaList,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeOverview$Page$pageInfo<TRes> get pageInfo;
  TRes mediaList(
      Iterable<Query$GetAnimeOverview$Page$mediaList?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeOverview$Page$mediaList<
                      Query$GetAnimeOverview$Page$mediaList>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeOverview$Page<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Page(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Page _instance;

  final TRes Function(Query$GetAnimeOverview$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? mediaList = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Page(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$GetAnimeOverview$Page$pageInfo?),
        mediaList: mediaList == _undefined
            ? _instance.mediaList
            : (mediaList as List<Query$GetAnimeOverview$Page$mediaList?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeOverview$Page$pageInfo<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetAnimeOverview$Page$pageInfo.stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Page$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes mediaList(
          Iterable<Query$GetAnimeOverview$Page$mediaList?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeOverview$Page$mediaList<
                          Query$GetAnimeOverview$Page$mediaList>?>?)
              _fn) =>
      call(
          mediaList: _fn(_instance.mediaList?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeOverview$Page$mediaList(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Page<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Page(this._res);

  TRes _res;

  call({
    Query$GetAnimeOverview$Page$pageInfo? pageInfo,
    List<Query$GetAnimeOverview$Page$mediaList?>? mediaList,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Page$pageInfo<TRes> get pageInfo =>
      CopyWith$Query$GetAnimeOverview$Page$pageInfo.stub(_res);

  mediaList(_fn) => _res;
}

class Query$GetAnimeOverview$Page$pageInfo {
  Query$GetAnimeOverview$Page$pageInfo({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetAnimeOverview$Page$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$perPage = json['perPage'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Page$pageInfo(
      total: (l$total as int?),
      perPage: (l$perPage as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? perPage;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$perPage = perPage;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$perPage,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Page$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetAnimeOverview$Page$pageInfo
    on Query$GetAnimeOverview$Page$pageInfo {
  CopyWith$Query$GetAnimeOverview$Page$pageInfo<
          Query$GetAnimeOverview$Page$pageInfo>
      get copyWith => CopyWith$Query$GetAnimeOverview$Page$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Page$pageInfo<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Page$pageInfo(
    Query$GetAnimeOverview$Page$pageInfo instance,
    TRes Function(Query$GetAnimeOverview$Page$pageInfo) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Page$pageInfo;

  factory CopyWith$Query$GetAnimeOverview$Page$pageInfo.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Page$pageInfo;

  TRes call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Page$pageInfo<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page$pageInfo<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Page$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Page$pageInfo _instance;

  final TRes Function(Query$GetAnimeOverview$Page$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? perPage = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Page$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Page$pageInfo<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Page$pageInfo(this._res);

  TRes _res;

  call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Page$mediaList {
  Query$GetAnimeOverview$Page$mediaList({
    required this.id,
    this.status,
    this.score,
    this.progress,
    this.user,
    this.$__typename = 'MediaList',
  });

  factory Query$GetAnimeOverview$Page$mediaList.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$status = json['status'];
    final l$score = json['score'];
    final l$progress = json['progress'];
    final l$user = json['user'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Page$mediaList(
      id: (l$id as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      score: (l$score as num?)?.toDouble(),
      progress: (l$progress as int?),
      user: l$user == null
          ? null
          : Query$GetAnimeOverview$Page$mediaList$user.fromJson(
              (l$user as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$MediaListStatus? status;

  final double? score;

  final int? progress;

  final Query$GetAnimeOverview$Page$mediaList$user? user;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$score = score;
    _resultData['score'] = l$score;
    final l$progress = progress;
    _resultData['progress'] = l$progress;
    final l$user = user;
    _resultData['user'] = l$user?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$status = status;
    final l$score = score;
    final l$progress = progress;
    final l$user = user;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$status,
      l$score,
      l$progress,
      l$user,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Page$mediaList ||
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

extension UtilityExtension$Query$GetAnimeOverview$Page$mediaList
    on Query$GetAnimeOverview$Page$mediaList {
  CopyWith$Query$GetAnimeOverview$Page$mediaList<
          Query$GetAnimeOverview$Page$mediaList>
      get copyWith => CopyWith$Query$GetAnimeOverview$Page$mediaList(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Page$mediaList<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Page$mediaList(
    Query$GetAnimeOverview$Page$mediaList instance,
    TRes Function(Query$GetAnimeOverview$Page$mediaList) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList;

  factory CopyWith$Query$GetAnimeOverview$Page$mediaList.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList;

  TRes call({
    int? id,
    Enum$MediaListStatus? status,
    double? score,
    int? progress,
    Query$GetAnimeOverview$Page$mediaList$user? user,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeOverview$Page$mediaList$user<TRes> get user;
}

class _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page$mediaList<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Page$mediaList _instance;

  final TRes Function(Query$GetAnimeOverview$Page$mediaList) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? status = _undefined,
    Object? score = _undefined,
    Object? progress = _undefined,
    Object? user = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Page$mediaList(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        score: score == _undefined ? _instance.score : (score as double?),
        progress:
            progress == _undefined ? _instance.progress : (progress as int?),
        user: user == _undefined
            ? _instance.user
            : (user as Query$GetAnimeOverview$Page$mediaList$user?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeOverview$Page$mediaList$user<TRes> get user {
    final local$user = _instance.user;
    return local$user == null
        ? CopyWith$Query$GetAnimeOverview$Page$mediaList$user.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Page$mediaList$user(
            local$user, (e) => call(user: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page$mediaList<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList(this._res);

  TRes _res;

  call({
    int? id,
    Enum$MediaListStatus? status,
    double? score,
    int? progress,
    Query$GetAnimeOverview$Page$mediaList$user? user,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Page$mediaList$user<TRes> get user =>
      CopyWith$Query$GetAnimeOverview$Page$mediaList$user.stub(_res);
}

class Query$GetAnimeOverview$Page$mediaList$user {
  Query$GetAnimeOverview$Page$mediaList$user({
    required this.id,
    required this.name,
    this.avatar,
    this.mediaListOptions,
    this.$__typename = 'User',
  });

  factory Query$GetAnimeOverview$Page$mediaList$user.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$avatar = json['avatar'];
    final l$mediaListOptions = json['mediaListOptions'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Page$mediaList$user(
      id: (l$id as int),
      name: (l$name as String),
      avatar: l$avatar == null
          ? null
          : Query$GetAnimeOverview$Page$mediaList$user$avatar.fromJson(
              (l$avatar as Map<String, dynamic>)),
      mediaListOptions: l$mediaListOptions == null
          ? null
          : Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions
              .fromJson((l$mediaListOptions as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final Query$GetAnimeOverview$Page$mediaList$user$avatar? avatar;

  final Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions?
      mediaListOptions;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$avatar = avatar;
    _resultData['avatar'] = l$avatar?.toJson();
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
    final l$avatar = avatar;
    final l$mediaListOptions = mediaListOptions;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$avatar,
      l$mediaListOptions,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Page$mediaList$user ||
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

extension UtilityExtension$Query$GetAnimeOverview$Page$mediaList$user
    on Query$GetAnimeOverview$Page$mediaList$user {
  CopyWith$Query$GetAnimeOverview$Page$mediaList$user<
          Query$GetAnimeOverview$Page$mediaList$user>
      get copyWith => CopyWith$Query$GetAnimeOverview$Page$mediaList$user(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Page$mediaList$user<TRes> {
  factory CopyWith$Query$GetAnimeOverview$Page$mediaList$user(
    Query$GetAnimeOverview$Page$mediaList$user instance,
    TRes Function(Query$GetAnimeOverview$Page$mediaList$user) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user;

  factory CopyWith$Query$GetAnimeOverview$Page$mediaList$user.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user;

  TRes call({
    int? id,
    String? name,
    Query$GetAnimeOverview$Page$mediaList$user$avatar? avatar,
    Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions?
        mediaListOptions,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes> get avatar;
  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<TRes>
      get mediaListOptions;
}

class _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page$mediaList$user<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Page$mediaList$user _instance;

  final TRes Function(Query$GetAnimeOverview$Page$mediaList$user) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? avatar = _undefined,
    Object? mediaListOptions = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Page$mediaList$user(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        avatar: avatar == _undefined
            ? _instance.avatar
            : (avatar as Query$GetAnimeOverview$Page$mediaList$user$avatar?),
        mediaListOptions: mediaListOptions == _undefined
            ? _instance.mediaListOptions
            : (mediaListOptions
                as Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes> get avatar {
    final local$avatar = _instance.avatar;
    return local$avatar == null
        ? CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar(
            local$avatar, (e) => call(avatar: e));
  }

  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<TRes>
      get mediaListOptions {
    final local$mediaListOptions = _instance.mediaListOptions;
    return local$mediaListOptions == null
        ? CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions
            .stub(_then(_instance))
        : CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
            local$mediaListOptions, (e) => call(mediaListOptions: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user<TRes>
    implements CopyWith$Query$GetAnimeOverview$Page$mediaList$user<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    Query$GetAnimeOverview$Page$mediaList$user$avatar? avatar,
    Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions?
        mediaListOptions,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes> get avatar =>
      CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar.stub(_res);

  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<TRes>
      get mediaListOptions =>
          CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions
              .stub(_res);
}

class Query$GetAnimeOverview$Page$mediaList$user$avatar {
  Query$GetAnimeOverview$Page$mediaList$user$avatar({
    this.large,
    this.$__typename = 'UserAvatar',
  });

  factory Query$GetAnimeOverview$Page$mediaList$user$avatar.fromJson(
      Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Page$mediaList$user$avatar(
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
    if (other is! Query$GetAnimeOverview$Page$mediaList$user$avatar ||
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

extension UtilityExtension$Query$GetAnimeOverview$Page$mediaList$user$avatar
    on Query$GetAnimeOverview$Page$mediaList$user$avatar {
  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<
          Query$GetAnimeOverview$Page$mediaList$user$avatar>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar(
    Query$GetAnimeOverview$Page$mediaList$user$avatar instance,
    TRes Function(Query$GetAnimeOverview$Page$mediaList$user$avatar) then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user$avatar;

  factory CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user$avatar;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user$avatar(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Page$mediaList$user$avatar _instance;

  final TRes Function(Query$GetAnimeOverview$Page$mediaList$user$avatar) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Page$mediaList$user$avatar(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Page$mediaList$user$avatar<TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user$avatar(
      this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions {
  Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions({
    this.scoreFormat,
    this.$__typename = 'MediaListOptions',
  });

  factory Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions.fromJson(
      Map<String, dynamic> json) {
    final l$scoreFormat = json['scoreFormat'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
      scoreFormat: l$scoreFormat == null
          ? null
          : fromJson$Enum$ScoreFormat((l$scoreFormat as String)),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$ScoreFormat? scoreFormat;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$scoreFormat = scoreFormat;
    _resultData['scoreFormat'] =
        l$scoreFormat == null ? null : toJson$Enum$ScoreFormat(l$scoreFormat);
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$scoreFormat = scoreFormat;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$scoreFormat,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$scoreFormat = scoreFormat;
    final lOther$scoreFormat = other.scoreFormat;
    if (l$scoreFormat != lOther$scoreFormat) {
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

extension UtilityExtension$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions
    on Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions {
  CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<
          Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions>
      get copyWith =>
          CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<
    TRes> {
  factory CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
    Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions instance,
    TRes Function(Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions)
        then,
  ) = _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions;

  factory CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions;

  TRes call({
    Enum$ScoreFormat? scoreFormat,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<
        TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<
            TRes> {
  _CopyWithImpl$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
    this._instance,
    this._then,
  );

  final Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions _instance;

  final TRes Function(
      Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? scoreFormat = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
        scoreFormat: scoreFormat == _undefined
            ? _instance.scoreFormat
            : (scoreFormat as Enum$ScoreFormat?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<
        TRes>
    implements
        CopyWith$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions<
            TRes> {
  _CopyWithStubImpl$Query$GetAnimeOverview$Page$mediaList$user$mediaListOptions(
      this._res);

  TRes _res;

  call({
    Enum$ScoreFormat? scoreFormat,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Query$GetMultipleAnimeDetails {
  factory Variables$Query$GetMultipleAnimeDetails({List<int?>? ids}) =>
      Variables$Query$GetMultipleAnimeDetails._({
        if (ids != null) r'ids': ids,
      });

  Variables$Query$GetMultipleAnimeDetails._(this._$data);

  factory Variables$Query$GetMultipleAnimeDetails.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('ids')) {
      final l$ids = data['ids'];
      result$data['ids'] =
          (l$ids as List<dynamic>?)?.map((e) => (e as int?)).toList();
    }
    return Variables$Query$GetMultipleAnimeDetails._(result$data);
  }

  Map<String, dynamic> _$data;

  List<int?>? get ids => (_$data['ids'] as List<int?>?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('ids')) {
      final l$ids = ids;
      result$data['ids'] = l$ids?.map((e) => e).toList();
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetMultipleAnimeDetails<
          Variables$Query$GetMultipleAnimeDetails>
      get copyWith => CopyWith$Variables$Query$GetMultipleAnimeDetails(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetMultipleAnimeDetails ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$ids = ids;
    final lOther$ids = other.ids;
    if (_$data.containsKey('ids') != other._$data.containsKey('ids')) {
      return false;
    }
    if (l$ids != null && lOther$ids != null) {
      if (l$ids.length != lOther$ids.length) {
        return false;
      }
      for (int i = 0; i < l$ids.length; i++) {
        final l$ids$entry = l$ids[i];
        final lOther$ids$entry = lOther$ids[i];
        if (l$ids$entry != lOther$ids$entry) {
          return false;
        }
      }
    } else if (l$ids != lOther$ids) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$ids = ids;
    return Object.hashAll([
      _$data.containsKey('ids')
          ? l$ids == null
              ? null
              : Object.hashAll(l$ids.map((v) => v))
          : const {}
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetMultipleAnimeDetails<TRes> {
  factory CopyWith$Variables$Query$GetMultipleAnimeDetails(
    Variables$Query$GetMultipleAnimeDetails instance,
    TRes Function(Variables$Query$GetMultipleAnimeDetails) then,
  ) = _CopyWithImpl$Variables$Query$GetMultipleAnimeDetails;

  factory CopyWith$Variables$Query$GetMultipleAnimeDetails.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetMultipleAnimeDetails;

  TRes call({List<int?>? ids});
}

class _CopyWithImpl$Variables$Query$GetMultipleAnimeDetails<TRes>
    implements CopyWith$Variables$Query$GetMultipleAnimeDetails<TRes> {
  _CopyWithImpl$Variables$Query$GetMultipleAnimeDetails(
    this._instance,
    this._then,
  );

  final Variables$Query$GetMultipleAnimeDetails _instance;

  final TRes Function(Variables$Query$GetMultipleAnimeDetails) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? ids = _undefined}) =>
      _then(Variables$Query$GetMultipleAnimeDetails._({
        ..._instance._$data,
        if (ids != _undefined) 'ids': (ids as List<int?>?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetMultipleAnimeDetails<TRes>
    implements CopyWith$Variables$Query$GetMultipleAnimeDetails<TRes> {
  _CopyWithStubImpl$Variables$Query$GetMultipleAnimeDetails(this._res);

  TRes _res;

  call({List<int?>? ids}) => _res;
}

class Query$GetMultipleAnimeDetails {
  Query$GetMultipleAnimeDetails({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetMultipleAnimeDetails.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails(
      Page: l$Page == null
          ? null
          : Query$GetMultipleAnimeDetails$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetMultipleAnimeDetails$Page? Page;

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
    if (other is! Query$GetMultipleAnimeDetails ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetMultipleAnimeDetails
    on Query$GetMultipleAnimeDetails {
  CopyWith$Query$GetMultipleAnimeDetails<Query$GetMultipleAnimeDetails>
      get copyWith => CopyWith$Query$GetMultipleAnimeDetails(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails<TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails(
    Query$GetMultipleAnimeDetails instance,
    TRes Function(Query$GetMultipleAnimeDetails) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails;

  factory CopyWith$Query$GetMultipleAnimeDetails.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails;

  TRes call({
    Query$GetMultipleAnimeDetails$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetMultipleAnimeDetails$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails _instance;

  final TRes Function(Query$GetMultipleAnimeDetails) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetMultipleAnimeDetails$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetMultipleAnimeDetails$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetMultipleAnimeDetails$Page.stub(_then(_instance))
        : CopyWith$Query$GetMultipleAnimeDetails$Page(
            local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails(this._res);

  TRes _res;

  call({
    Query$GetMultipleAnimeDetails$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetMultipleAnimeDetails$Page<TRes> get Page =>
      CopyWith$Query$GetMultipleAnimeDetails$Page.stub(_res);
}

const documentNodeQueryGetMultipleAnimeDetails = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetMultipleAnimeDetails'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'ids')),
        type: ListTypeNode(
          type: NamedTypeNode(
            name: NameNode(value: 'Int'),
            isNonNull: false,
          ),
          isNonNull: false,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: IntValueNode(value: '50'),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FieldNode(
            name: NameNode(value: 'media'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'id_in'),
                value: VariableNode(name: NameNode(value: 'ids')),
              ),
              ArgumentNode(
                name: NameNode(value: 'type'),
                value: EnumValueNode(name: NameNode(value: 'ANIME')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FragmentSpreadNode(
                name: NameNode(value: 'AnimeCard'),
                directives: [],
              ),
              FieldNode(
                name: NameNode(value: 'bannerImage'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'description'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'endDate'),
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
                name: NameNode(value: 'genres'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'trending'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'favourites'),
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
                name: NameNode(value: 'siteUrl'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'rankings'),
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
                    name: NameNode(value: 'rank'),
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
                    name: NameNode(value: 'format'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'year'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'season'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'allTime'),
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
Query$GetMultipleAnimeDetails _parserFn$Query$GetMultipleAnimeDetails(
        Map<String, dynamic> data) =>
    Query$GetMultipleAnimeDetails.fromJson(data);
typedef OnQueryComplete$Query$GetMultipleAnimeDetails = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetMultipleAnimeDetails?,
);

class Options$Query$GetMultipleAnimeDetails
    extends graphql.QueryOptions<Query$GetMultipleAnimeDetails> {
  Options$Query$GetMultipleAnimeDetails({
    String? operationName,
    Variables$Query$GetMultipleAnimeDetails? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMultipleAnimeDetails? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetMultipleAnimeDetails? onComplete,
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
                        : _parserFn$Query$GetMultipleAnimeDetails(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetMultipleAnimeDetails,
          parserFn: _parserFn$Query$GetMultipleAnimeDetails,
        );

  final OnQueryComplete$Query$GetMultipleAnimeDetails? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetMultipleAnimeDetails
    extends graphql.WatchQueryOptions<Query$GetMultipleAnimeDetails> {
  WatchOptions$Query$GetMultipleAnimeDetails({
    String? operationName,
    Variables$Query$GetMultipleAnimeDetails? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMultipleAnimeDetails? typedOptimisticResult,
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
          document: documentNodeQueryGetMultipleAnimeDetails,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetMultipleAnimeDetails,
        );
}

class FetchMoreOptions$Query$GetMultipleAnimeDetails
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetMultipleAnimeDetails({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$GetMultipleAnimeDetails? variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables?.toJson() ?? {},
          document: documentNodeQueryGetMultipleAnimeDetails,
        );
}

extension ClientExtension$Query$GetMultipleAnimeDetails
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetMultipleAnimeDetails>>
      query$GetMultipleAnimeDetails(
              [Options$Query$GetMultipleAnimeDetails? options]) async =>
          await this.query(options ?? Options$Query$GetMultipleAnimeDetails());
  graphql.ObservableQuery<
      Query$GetMultipleAnimeDetails> watchQuery$GetMultipleAnimeDetails(
          [WatchOptions$Query$GetMultipleAnimeDetails? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetMultipleAnimeDetails());
  void writeQuery$GetMultipleAnimeDetails({
    required Query$GetMultipleAnimeDetails data,
    Variables$Query$GetMultipleAnimeDetails? variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(
              document: documentNodeQueryGetMultipleAnimeDetails),
          variables: variables?.toJson() ?? const {},
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetMultipleAnimeDetails? readQuery$GetMultipleAnimeDetails({
    Variables$Query$GetMultipleAnimeDetails? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(
            document: documentNodeQueryGetMultipleAnimeDetails),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null
        ? null
        : Query$GetMultipleAnimeDetails.fromJson(result);
  }
}

class Query$GetMultipleAnimeDetails$Page {
  Query$GetMultipleAnimeDetails$Page({
    this.media,
    this.$__typename = 'Page',
  });

  factory Query$GetMultipleAnimeDetails$Page.fromJson(
      Map<String, dynamic> json) {
    final l$media = json['media'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page(
      media: (l$media as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetMultipleAnimeDetails$Page$media.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetMultipleAnimeDetails$Page$media?>? media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$media = media;
    _resultData['media'] = l$media?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$media = media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$media == null ? null : Object.hashAll(l$media.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetMultipleAnimeDetails$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$media = media;
    final lOther$media = other.media;
    if (l$media != null && lOther$media != null) {
      if (l$media.length != lOther$media.length) {
        return false;
      }
      for (int i = 0; i < l$media.length; i++) {
        final l$media$entry = l$media[i];
        final lOther$media$entry = lOther$media[i];
        if (l$media$entry != lOther$media$entry) {
          return false;
        }
      }
    } else if (l$media != lOther$media) {
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page
    on Query$GetMultipleAnimeDetails$Page {
  CopyWith$Query$GetMultipleAnimeDetails$Page<
          Query$GetMultipleAnimeDetails$Page>
      get copyWith => CopyWith$Query$GetMultipleAnimeDetails$Page(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page<TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page(
    Query$GetMultipleAnimeDetails$Page instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page;

  TRes call({
    List<Query$GetMultipleAnimeDetails$Page$media?>? media,
    String? $__typename,
  });
  TRes media(
      Iterable<Query$GetMultipleAnimeDetails$Page$media?>? Function(
              Iterable<
                  CopyWith$Query$GetMultipleAnimeDetails$Page$media<
                      Query$GetMultipleAnimeDetails$Page$media>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page(
        media: media == _undefined
            ? _instance.media
            : (media as List<Query$GetMultipleAnimeDetails$Page$media?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes media(
          Iterable<Query$GetMultipleAnimeDetails$Page$media?>? Function(
                  Iterable<
                      CopyWith$Query$GetMultipleAnimeDetails$Page$media<
                          Query$GetMultipleAnimeDetails$Page$media>?>?)
              _fn) =>
      call(
          media: _fn(_instance.media?.map((e) => e == null
              ? null
              : CopyWith$Query$GetMultipleAnimeDetails$Page$media(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page(this._res);

  TRes _res;

  call({
    List<Query$GetMultipleAnimeDetails$Page$media?>? media,
    String? $__typename,
  }) =>
      _res;

  media(_fn) => _res;
}

class Query$GetMultipleAnimeDetails$Page$media implements Fragment$AnimeCard {
  Query$GetMultipleAnimeDetails$Page$media({
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
    this.bannerImage,
    this.description,
    this.endDate,
    this.trending,
    this.favourites,
    this.updatedAt,
    this.siteUrl,
    this.rankings,
  });

  factory Query$GetMultipleAnimeDetails$Page$media.fromJson(
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
    final l$bannerImage = json['bannerImage'];
    final l$description = json['description'];
    final l$endDate = json['endDate'];
    final l$trending = json['trending'];
    final l$favourites = json['favourites'];
    final l$updatedAt = json['updatedAt'];
    final l$siteUrl = json['siteUrl'];
    final l$rankings = json['rankings'];
    return Query$GetMultipleAnimeDetails$Page$media(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Query$GetMultipleAnimeDetails$Page$media$title.fromJson(
              (l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Query$GetMultipleAnimeDetails$Page$media$coverImage.fromJson(
              (l$coverImage as Map<String, dynamic>)),
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
          : Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode.fromJson(
              (l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Query$GetMultipleAnimeDetails$Page$media$startDate.fromJson(
              (l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      bannerImage: (l$bannerImage as String?),
      description: (l$description as String?),
      endDate: l$endDate == null
          ? null
          : Query$GetMultipleAnimeDetails$Page$media$endDate.fromJson(
              (l$endDate as Map<String, dynamic>)),
      trending: (l$trending as int?),
      favourites: (l$favourites as int?),
      updatedAt: (l$updatedAt as int?),
      siteUrl: (l$siteUrl as String?),
      rankings: (l$rankings as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetMultipleAnimeDetails$Page$media$rankings.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
    );
  }

  final int id;

  final Query$GetMultipleAnimeDetails$Page$media$title? title;

  final Query$GetMultipleAnimeDetails$Page$media$coverImage? coverImage;

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

  final Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode?
      nextAiringEpisode;

  final Query$GetMultipleAnimeDetails$Page$media$startDate? startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? bannerImage;

  final String? description;

  final Query$GetMultipleAnimeDetails$Page$media$endDate? endDate;

  final int? trending;

  final int? favourites;

  final int? updatedAt;

  final String? siteUrl;

  final List<Query$GetMultipleAnimeDetails$Page$media$rankings?>? rankings;

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
    final l$bannerImage = bannerImage;
    _resultData['bannerImage'] = l$bannerImage;
    final l$description = description;
    _resultData['description'] = l$description;
    final l$endDate = endDate;
    _resultData['endDate'] = l$endDate?.toJson();
    final l$trending = trending;
    _resultData['trending'] = l$trending;
    final l$favourites = favourites;
    _resultData['favourites'] = l$favourites;
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$siteUrl = siteUrl;
    _resultData['siteUrl'] = l$siteUrl;
    final l$rankings = rankings;
    _resultData['rankings'] = l$rankings?.map((e) => e?.toJson()).toList();
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
    final l$bannerImage = bannerImage;
    final l$description = description;
    final l$endDate = endDate;
    final l$trending = trending;
    final l$favourites = favourites;
    final l$updatedAt = updatedAt;
    final l$siteUrl = siteUrl;
    final l$rankings = rankings;
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
      l$bannerImage,
      l$description,
      l$endDate,
      l$trending,
      l$favourites,
      l$updatedAt,
      l$siteUrl,
      l$rankings == null ? null : Object.hashAll(l$rankings.map((v) => v)),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetMultipleAnimeDetails$Page$media ||
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
    final l$bannerImage = bannerImage;
    final lOther$bannerImage = other.bannerImage;
    if (l$bannerImage != lOther$bannerImage) {
      return false;
    }
    final l$description = description;
    final lOther$description = other.description;
    if (l$description != lOther$description) {
      return false;
    }
    final l$endDate = endDate;
    final lOther$endDate = other.endDate;
    if (l$endDate != lOther$endDate) {
      return false;
    }
    final l$trending = trending;
    final lOther$trending = other.trending;
    if (l$trending != lOther$trending) {
      return false;
    }
    final l$favourites = favourites;
    final lOther$favourites = other.favourites;
    if (l$favourites != lOther$favourites) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
      return false;
    }
    final l$siteUrl = siteUrl;
    final lOther$siteUrl = other.siteUrl;
    if (l$siteUrl != lOther$siteUrl) {
      return false;
    }
    final l$rankings = rankings;
    final lOther$rankings = other.rankings;
    if (l$rankings != null && lOther$rankings != null) {
      if (l$rankings.length != lOther$rankings.length) {
        return false;
      }
      for (int i = 0; i < l$rankings.length; i++) {
        final l$rankings$entry = l$rankings[i];
        final lOther$rankings$entry = lOther$rankings[i];
        if (l$rankings$entry != lOther$rankings$entry) {
          return false;
        }
      }
    } else if (l$rankings != lOther$rankings) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media
    on Query$GetMultipleAnimeDetails$Page$media {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media<
          Query$GetMultipleAnimeDetails$Page$media>
      get copyWith => CopyWith$Query$GetMultipleAnimeDetails$Page$media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media<TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media(
    Query$GetMultipleAnimeDetails$Page$media instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media;

  TRes call({
    int? id,
    Query$GetMultipleAnimeDetails$Page$media$title? title,
    Query$GetMultipleAnimeDetails$Page$media$coverImage? coverImage,
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
    Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode?
        nextAiringEpisode,
    Query$GetMultipleAnimeDetails$Page$media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Query$GetMultipleAnimeDetails$Page$media$endDate? endDate,
    int? trending,
    int? favourites,
    int? updatedAt,
    String? siteUrl,
    List<Query$GetMultipleAnimeDetails$Page$media$rankings?>? rankings,
  });
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<TRes> get title;
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<TRes>
      get coverImage;
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode;
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes>
      get startDate;
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes> get endDate;
  TRes rankings(
      Iterable<Query$GetMultipleAnimeDetails$Page$media$rankings?>? Function(
              Iterable<
                  CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings<
                      Query$GetMultipleAnimeDetails$Page$media$rankings>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page$media<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page$media) _then;

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
    Object? bannerImage = _undefined,
    Object? description = _undefined,
    Object? endDate = _undefined,
    Object? trending = _undefined,
    Object? favourites = _undefined,
    Object? updatedAt = _undefined,
    Object? siteUrl = _undefined,
    Object? rankings = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title as Query$GetMultipleAnimeDetails$Page$media$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage
                as Query$GetMultipleAnimeDetails$Page$media$coverImage?),
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
                as Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate
                as Query$GetMultipleAnimeDetails$Page$media$startDate?),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
        bannerImage: bannerImage == _undefined
            ? _instance.bannerImage
            : (bannerImage as String?),
        description: description == _undefined
            ? _instance.description
            : (description as String?),
        endDate: endDate == _undefined
            ? _instance.endDate
            : (endDate as Query$GetMultipleAnimeDetails$Page$media$endDate?),
        trending:
            trending == _undefined ? _instance.trending : (trending as int?),
        favourites: favourites == _undefined
            ? _instance.favourites
            : (favourites as int?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        siteUrl:
            siteUrl == _undefined ? _instance.siteUrl : (siteUrl as String?),
        rankings: rankings == _undefined
            ? _instance.rankings
            : (rankings
                as List<Query$GetMultipleAnimeDetails$Page$media$rankings?>?),
      ));

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Query$GetMultipleAnimeDetails$Page$media$title.stub(
            _then(_instance))
        : CopyWith$Query$GetMultipleAnimeDetails$Page$media$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<TRes>
      get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage.stub(
            _then(_instance))
        : CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode
            .stub(_then(_instance))
        : CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes>
      get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate.stub(
            _then(_instance))
        : CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes> get endDate {
    final local$endDate = _instance.endDate;
    return local$endDate == null
        ? CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate.stub(
            _then(_instance))
        : CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate(
            local$endDate, (e) => call(endDate: e));
  }

  TRes rankings(
          Iterable<Query$GetMultipleAnimeDetails$Page$media$rankings?>? Function(
                  Iterable<
                      CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings<
                          Query$GetMultipleAnimeDetails$Page$media$rankings>?>?)
              _fn) =>
      call(
          rankings: _fn(_instance.rankings?.map((e) => e == null
              ? null
              : CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page$media<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media(this._res);

  TRes _res;

  call({
    int? id,
    Query$GetMultipleAnimeDetails$Page$media$title? title,
    Query$GetMultipleAnimeDetails$Page$media$coverImage? coverImage,
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
    Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode?
        nextAiringEpisode,
    Query$GetMultipleAnimeDetails$Page$media$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Query$GetMultipleAnimeDetails$Page$media$endDate? endDate,
    int? trending,
    int? favourites,
    int? updatedAt,
    String? siteUrl,
    List<Query$GetMultipleAnimeDetails$Page$media$rankings?>? rankings,
  }) =>
      _res;

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<TRes> get title =>
      CopyWith$Query$GetMultipleAnimeDetails$Page$media$title.stub(_res);

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<TRes>
      get coverImage =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage.stub(
              _res);

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<TRes>
      get nextAiringEpisode =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode
              .stub(_res);

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes>
      get startDate =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate.stub(
              _res);

  CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes> get endDate =>
      CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate.stub(_res);

  rankings(_fn) => _res;
}

class Query$GetMultipleAnimeDetails$Page$media$title
    implements Fragment$AnimeCard$title {
  Query$GetMultipleAnimeDetails$Page$media$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Query$GetMultipleAnimeDetails$Page$media$title.fromJson(
      Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page$media$title(
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
    if (other is! Query$GetMultipleAnimeDetails$Page$media$title ||
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media$title
    on Query$GetMultipleAnimeDetails$Page$media$title {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<
          Query$GetMultipleAnimeDetails$Page$media$title>
      get copyWith => CopyWith$Query$GetMultipleAnimeDetails$Page$media$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$title(
    Query$GetMultipleAnimeDetails$Page$media$title instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media$title) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$title;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$title.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$title<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$title(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media$title _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page$media$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media$title(
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

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$title<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page$media$title<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$title(this._res);

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

class Query$GetMultipleAnimeDetails$Page$media$coverImage
    implements Fragment$AnimeCard$coverImage {
  Query$GetMultipleAnimeDetails$Page$media$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Query$GetMultipleAnimeDetails$Page$media$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page$media$coverImage(
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
    if (other is! Query$GetMultipleAnimeDetails$Page$media$coverImage ||
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media$coverImage
    on Query$GetMultipleAnimeDetails$Page$media$coverImage {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<
          Query$GetMultipleAnimeDetails$Page$media$coverImage>
      get copyWith =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<
    TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage(
    Query$GetMultipleAnimeDetails$Page$media$coverImage instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media$coverImage) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$coverImage;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$coverImage<TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$coverImage(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media$coverImage _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page$media$coverImage)
      _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media$coverImage(
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

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$coverImage<
        TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$coverImage<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$coverImage(
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

class Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode
    implements Fragment$AnimeCard$nextAiringEpisode {
  Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
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
    if (other is! Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode ||
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode
    on Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<
          Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode>
      get copyWith =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<
    TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
    Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode)
        then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<
            TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode _instance;

  final TRes Function(
      Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
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

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<
        TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode<
            TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$nextAiringEpisode(
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

class Query$GetMultipleAnimeDetails$Page$media$startDate
    implements Fragment$AnimeCard$startDate {
  Query$GetMultipleAnimeDetails$Page$media$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetMultipleAnimeDetails$Page$media$startDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page$media$startDate(
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
    if (other is! Query$GetMultipleAnimeDetails$Page$media$startDate ||
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media$startDate
    on Query$GetMultipleAnimeDetails$Page$media$startDate {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<
          Query$GetMultipleAnimeDetails$Page$media$startDate>
      get copyWith =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<
    TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate(
    Query$GetMultipleAnimeDetails$Page$media$startDate instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media$startDate) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$startDate;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$startDate(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media$startDate _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page$media$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$startDate<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$startDate(
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

class Query$GetMultipleAnimeDetails$Page$media$endDate {
  Query$GetMultipleAnimeDetails$Page$media$endDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Query$GetMultipleAnimeDetails$Page$media$endDate.fromJson(
      Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page$media$endDate(
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
    if (other is! Query$GetMultipleAnimeDetails$Page$media$endDate ||
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media$endDate
    on Query$GetMultipleAnimeDetails$Page$media$endDate {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<
          Query$GetMultipleAnimeDetails$Page$media$endDate>
      get copyWith => CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate(
    Query$GetMultipleAnimeDetails$Page$media$endDate instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media$endDate) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$endDate;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$endDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$endDate(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media$endDate _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page$media$endDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media$endDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes>
    implements CopyWith$Query$GetMultipleAnimeDetails$Page$media$endDate<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$endDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetMultipleAnimeDetails$Page$media$rankings {
  Query$GetMultipleAnimeDetails$Page$media$rankings({
    required this.id,
    required this.rank,
    required this.type,
    required this.format,
    this.year,
    this.season,
    this.allTime,
    required this.context,
    this.$__typename = 'MediaRank',
  });

  factory Query$GetMultipleAnimeDetails$Page$media$rankings.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$rank = json['rank'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$year = json['year'];
    final l$season = json['season'];
    final l$allTime = json['allTime'];
    final l$context = json['context'];
    final l$$__typename = json['__typename'];
    return Query$GetMultipleAnimeDetails$Page$media$rankings(
      id: (l$id as int),
      rank: (l$rank as int),
      type: fromJson$Enum$MediaRankType((l$type as String)),
      format: fromJson$Enum$MediaFormat((l$format as String)),
      year: (l$year as int?),
      season: l$season == null
          ? null
          : fromJson$Enum$MediaSeason((l$season as String)),
      allTime: (l$allTime as bool?),
      context: (l$context as String),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final int rank;

  final Enum$MediaRankType type;

  final Enum$MediaFormat format;

  final int? year;

  final Enum$MediaSeason? season;

  final bool? allTime;

  final String context;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$rank = rank;
    _resultData['rank'] = l$rank;
    final l$type = type;
    _resultData['type'] = toJson$Enum$MediaRankType(l$type);
    final l$format = format;
    _resultData['format'] = toJson$Enum$MediaFormat(l$format);
    final l$year = year;
    _resultData['year'] = l$year;
    final l$season = season;
    _resultData['season'] =
        l$season == null ? null : toJson$Enum$MediaSeason(l$season);
    final l$allTime = allTime;
    _resultData['allTime'] = l$allTime;
    final l$context = context;
    _resultData['context'] = l$context;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$rank = rank;
    final l$type = type;
    final l$format = format;
    final l$year = year;
    final l$season = season;
    final l$allTime = allTime;
    final l$context = context;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$rank,
      l$type,
      l$format,
      l$year,
      l$season,
      l$allTime,
      l$context,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetMultipleAnimeDetails$Page$media$rankings ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$rank = rank;
    final lOther$rank = other.rank;
    if (l$rank != lOther$rank) {
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
    final l$year = year;
    final lOther$year = other.year;
    if (l$year != lOther$year) {
      return false;
    }
    final l$season = season;
    final lOther$season = other.season;
    if (l$season != lOther$season) {
      return false;
    }
    final l$allTime = allTime;
    final lOther$allTime = other.allTime;
    if (l$allTime != lOther$allTime) {
      return false;
    }
    final l$context = context;
    final lOther$context = other.context;
    if (l$context != lOther$context) {
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

extension UtilityExtension$Query$GetMultipleAnimeDetails$Page$media$rankings
    on Query$GetMultipleAnimeDetails$Page$media$rankings {
  CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings<
          Query$GetMultipleAnimeDetails$Page$media$rankings>
      get copyWith =>
          CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings<
    TRes> {
  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings(
    Query$GetMultipleAnimeDetails$Page$media$rankings instance,
    TRes Function(Query$GetMultipleAnimeDetails$Page$media$rankings) then,
  ) = _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$rankings;

  factory CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$rankings;

  TRes call({
    int? id,
    int? rank,
    Enum$MediaRankType? type,
    Enum$MediaFormat? format,
    int? year,
    Enum$MediaSeason? season,
    bool? allTime,
    String? context,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$rankings<TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings<TRes> {
  _CopyWithImpl$Query$GetMultipleAnimeDetails$Page$media$rankings(
    this._instance,
    this._then,
  );

  final Query$GetMultipleAnimeDetails$Page$media$rankings _instance;

  final TRes Function(Query$GetMultipleAnimeDetails$Page$media$rankings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? rank = _undefined,
    Object? type = _undefined,
    Object? format = _undefined,
    Object? year = _undefined,
    Object? season = _undefined,
    Object? allTime = _undefined,
    Object? context = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMultipleAnimeDetails$Page$media$rankings(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        rank:
            rank == _undefined || rank == null ? _instance.rank : (rank as int),
        type: type == _undefined || type == null
            ? _instance.type
            : (type as Enum$MediaRankType),
        format: format == _undefined || format == null
            ? _instance.format
            : (format as Enum$MediaFormat),
        year: year == _undefined ? _instance.year : (year as int?),
        season: season == _undefined
            ? _instance.season
            : (season as Enum$MediaSeason?),
        allTime: allTime == _undefined ? _instance.allTime : (allTime as bool?),
        context: context == _undefined || context == null
            ? _instance.context
            : (context as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$rankings<TRes>
    implements
        CopyWith$Query$GetMultipleAnimeDetails$Page$media$rankings<TRes> {
  _CopyWithStubImpl$Query$GetMultipleAnimeDetails$Page$media$rankings(
      this._res);

  TRes _res;

  call({
    int? id,
    int? rank,
    Enum$MediaRankType? type,
    Enum$MediaFormat? format,
    int? year,
    Enum$MediaSeason? season,
    bool? allTime,
    String? context,
    String? $__typename,
  }) =>
      _res;
}

class Variables$Query$GetAnimeCharacters {
  factory Variables$Query$GetAnimeCharacters({
    required int id,
    int? page,
  }) =>
      Variables$Query$GetAnimeCharacters._({
        r'id': id,
        if (page != null) r'page': page,
      });

  Variables$Query$GetAnimeCharacters._(this._$data);

  factory Variables$Query$GetAnimeCharacters.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    if (data.containsKey('page')) {
      final l$page = data['page'];
      result$data['page'] = (l$page as int?);
    }
    return Variables$Query$GetAnimeCharacters._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  int? get page => (_$data['page'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    if (_$data.containsKey('page')) {
      final l$page = page;
      result$data['page'] = l$page;
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetAnimeCharacters<
          Variables$Query$GetAnimeCharacters>
      get copyWith => CopyWith$Variables$Query$GetAnimeCharacters(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetAnimeCharacters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$page = page;
    return Object.hashAll([
      l$id,
      _$data.containsKey('page') ? l$page : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetAnimeCharacters<TRes> {
  factory CopyWith$Variables$Query$GetAnimeCharacters(
    Variables$Query$GetAnimeCharacters instance,
    TRes Function(Variables$Query$GetAnimeCharacters) then,
  ) = _CopyWithImpl$Variables$Query$GetAnimeCharacters;

  factory CopyWith$Variables$Query$GetAnimeCharacters.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetAnimeCharacters;

  TRes call({
    int? id,
    int? page,
  });
}

class _CopyWithImpl$Variables$Query$GetAnimeCharacters<TRes>
    implements CopyWith$Variables$Query$GetAnimeCharacters<TRes> {
  _CopyWithImpl$Variables$Query$GetAnimeCharacters(
    this._instance,
    this._then,
  );

  final Variables$Query$GetAnimeCharacters _instance;

  final TRes Function(Variables$Query$GetAnimeCharacters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? page = _undefined,
  }) =>
      _then(Variables$Query$GetAnimeCharacters._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
        if (page != _undefined) 'page': (page as int?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetAnimeCharacters<TRes>
    implements CopyWith$Variables$Query$GetAnimeCharacters<TRes> {
  _CopyWithStubImpl$Variables$Query$GetAnimeCharacters(this._res);

  TRes _res;

  call({
    int? id,
    int? page,
  }) =>
      _res;
}

class Query$GetAnimeCharacters {
  Query$GetAnimeCharacters({
    this.Media,
    this.$__typename = 'Query',
  });

  factory Query$GetAnimeCharacters.fromJson(Map<String, dynamic> json) {
    final l$Media = json['Media'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeCharacters(
      Media: l$Media == null
          ? null
          : Query$GetAnimeCharacters$Media.fromJson(
              (l$Media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeCharacters$Media? Media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Media = Media;
    _resultData['Media'] = l$Media?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Media = Media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Media,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeCharacters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$Media = Media;
    final lOther$Media = other.Media;
    if (l$Media != lOther$Media) {
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

extension UtilityExtension$Query$GetAnimeCharacters
    on Query$GetAnimeCharacters {
  CopyWith$Query$GetAnimeCharacters<Query$GetAnimeCharacters> get copyWith =>
      CopyWith$Query$GetAnimeCharacters(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeCharacters<TRes> {
  factory CopyWith$Query$GetAnimeCharacters(
    Query$GetAnimeCharacters instance,
    TRes Function(Query$GetAnimeCharacters) then,
  ) = _CopyWithImpl$Query$GetAnimeCharacters;

  factory CopyWith$Query$GetAnimeCharacters.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeCharacters;

  TRes call({
    Query$GetAnimeCharacters$Media? Media,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeCharacters$Media<TRes> get Media;
}

class _CopyWithImpl$Query$GetAnimeCharacters<TRes>
    implements CopyWith$Query$GetAnimeCharacters<TRes> {
  _CopyWithImpl$Query$GetAnimeCharacters(
    this._instance,
    this._then,
  );

  final Query$GetAnimeCharacters _instance;

  final TRes Function(Query$GetAnimeCharacters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeCharacters(
        Media: Media == _undefined
            ? _instance.Media
            : (Media as Query$GetAnimeCharacters$Media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeCharacters$Media<TRes> get Media {
    final local$Media = _instance.Media;
    return local$Media == null
        ? CopyWith$Query$GetAnimeCharacters$Media.stub(_then(_instance))
        : CopyWith$Query$GetAnimeCharacters$Media(
            local$Media, (e) => call(Media: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeCharacters<TRes>
    implements CopyWith$Query$GetAnimeCharacters<TRes> {
  _CopyWithStubImpl$Query$GetAnimeCharacters(this._res);

  TRes _res;

  call({
    Query$GetAnimeCharacters$Media? Media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeCharacters$Media<TRes> get Media =>
      CopyWith$Query$GetAnimeCharacters$Media.stub(_res);
}

const documentNodeQueryGetAnimeCharacters = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetAnimeCharacters'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'page')),
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
        name: NameNode(value: 'Media'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          ),
          ArgumentNode(
            name: NameNode(value: 'type'),
            value: EnumValueNode(name: NameNode(value: 'ANIME')),
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
            name: NameNode(value: 'characters'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'page'),
                value: VariableNode(name: NameNode(value: 'page')),
              ),
              ArgumentNode(
                name: NameNode(value: 'perPage'),
                value: IntValueNode(value: '25'),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'ROLE')),
                  EnumValueNode(name: NameNode(value: 'RELEVANCE')),
                  EnumValueNode(name: NameNode(value: 'ID')),
                ]),
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
                    name: NameNode(value: 'perPage'),
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
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: 'edges'),
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
                    name: NameNode(value: 'role'),
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
                    name: NameNode(value: 'node'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'CharacterCard'),
                        directives: [],
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
                    name: NameNode(value: 'voiceActors'),
                    alias: null,
                    arguments: [
                      ArgumentNode(
                        name: NameNode(value: 'language'),
                        value: EnumValueNode(name: NameNode(value: 'JAPANESE')),
                      ),
                      ArgumentNode(
                        name: NameNode(value: 'sort'),
                        value: ListValueNode(values: [
                          EnumValueNode(name: NameNode(value: 'RELEVANCE')),
                          EnumValueNode(name: NameNode(value: 'ID')),
                        ]),
                      ),
                    ],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'StaffCard'),
                        directives: [],
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
  fragmentDefinitionCharacterCard,
  fragmentDefinitionStaffCard,
]);
Query$GetAnimeCharacters _parserFn$Query$GetAnimeCharacters(
        Map<String, dynamic> data) =>
    Query$GetAnimeCharacters.fromJson(data);
typedef OnQueryComplete$Query$GetAnimeCharacters = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetAnimeCharacters?,
);

class Options$Query$GetAnimeCharacters
    extends graphql.QueryOptions<Query$GetAnimeCharacters> {
  Options$Query$GetAnimeCharacters({
    String? operationName,
    required Variables$Query$GetAnimeCharacters variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeCharacters? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetAnimeCharacters? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                        : _parserFn$Query$GetAnimeCharacters(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetAnimeCharacters,
          parserFn: _parserFn$Query$GetAnimeCharacters,
        );

  final OnQueryComplete$Query$GetAnimeCharacters? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetAnimeCharacters
    extends graphql.WatchQueryOptions<Query$GetAnimeCharacters> {
  WatchOptions$Query$GetAnimeCharacters({
    String? operationName,
    required Variables$Query$GetAnimeCharacters variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeCharacters? typedOptimisticResult,
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
          document: documentNodeQueryGetAnimeCharacters,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetAnimeCharacters,
        );
}

class FetchMoreOptions$Query$GetAnimeCharacters
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetAnimeCharacters({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetAnimeCharacters variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetAnimeCharacters,
        );
}

extension ClientExtension$Query$GetAnimeCharacters on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetAnimeCharacters>>
      query$GetAnimeCharacters(
              Options$Query$GetAnimeCharacters options) async =>
          await this.query(options);
  graphql.ObservableQuery<Query$GetAnimeCharacters>
      watchQuery$GetAnimeCharacters(
              WatchOptions$Query$GetAnimeCharacters options) =>
          this.watchQuery(options);
  void writeQuery$GetAnimeCharacters({
    required Query$GetAnimeCharacters data,
    required Variables$Query$GetAnimeCharacters variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetAnimeCharacters),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetAnimeCharacters? readQuery$GetAnimeCharacters({
    required Variables$Query$GetAnimeCharacters variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetAnimeCharacters),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetAnimeCharacters.fromJson(result);
  }
}

class Query$GetAnimeCharacters$Media {
  Query$GetAnimeCharacters$Media({
    required this.id,
    this.characters,
    this.$__typename = 'Media',
  });

  factory Query$GetAnimeCharacters$Media.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$characters = json['characters'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeCharacters$Media(
      id: (l$id as int),
      characters: l$characters == null
          ? null
          : Query$GetAnimeCharacters$Media$characters.fromJson(
              (l$characters as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetAnimeCharacters$Media$characters? characters;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$characters = characters;
    _resultData['characters'] = l$characters?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$characters = characters;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$characters,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeCharacters$Media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$characters = characters;
    final lOther$characters = other.characters;
    if (l$characters != lOther$characters) {
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

extension UtilityExtension$Query$GetAnimeCharacters$Media
    on Query$GetAnimeCharacters$Media {
  CopyWith$Query$GetAnimeCharacters$Media<Query$GetAnimeCharacters$Media>
      get copyWith => CopyWith$Query$GetAnimeCharacters$Media(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeCharacters$Media<TRes> {
  factory CopyWith$Query$GetAnimeCharacters$Media(
    Query$GetAnimeCharacters$Media instance,
    TRes Function(Query$GetAnimeCharacters$Media) then,
  ) = _CopyWithImpl$Query$GetAnimeCharacters$Media;

  factory CopyWith$Query$GetAnimeCharacters$Media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeCharacters$Media;

  TRes call({
    int? id,
    Query$GetAnimeCharacters$Media$characters? characters,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeCharacters$Media$characters<TRes> get characters;
}

class _CopyWithImpl$Query$GetAnimeCharacters$Media<TRes>
    implements CopyWith$Query$GetAnimeCharacters$Media<TRes> {
  _CopyWithImpl$Query$GetAnimeCharacters$Media(
    this._instance,
    this._then,
  );

  final Query$GetAnimeCharacters$Media _instance;

  final TRes Function(Query$GetAnimeCharacters$Media) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? characters = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeCharacters$Media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        characters: characters == _undefined
            ? _instance.characters
            : (characters as Query$GetAnimeCharacters$Media$characters?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeCharacters$Media$characters<TRes> get characters {
    final local$characters = _instance.characters;
    return local$characters == null
        ? CopyWith$Query$GetAnimeCharacters$Media$characters.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeCharacters$Media$characters(
            local$characters, (e) => call(characters: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeCharacters$Media<TRes>
    implements CopyWith$Query$GetAnimeCharacters$Media<TRes> {
  _CopyWithStubImpl$Query$GetAnimeCharacters$Media(this._res);

  TRes _res;

  call({
    int? id,
    Query$GetAnimeCharacters$Media$characters? characters,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeCharacters$Media$characters<TRes> get characters =>
      CopyWith$Query$GetAnimeCharacters$Media$characters.stub(_res);
}

class Query$GetAnimeCharacters$Media$characters {
  Query$GetAnimeCharacters$Media$characters({
    this.pageInfo,
    this.edges,
    this.$__typename = 'CharacterConnection',
  });

  factory Query$GetAnimeCharacters$Media$characters.fromJson(
      Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$edges = json['edges'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeCharacters$Media$characters(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetAnimeCharacters$Media$characters$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      edges: (l$edges as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeCharacters$Media$characters$edges.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeCharacters$Media$characters$pageInfo? pageInfo;

  final List<Query$GetAnimeCharacters$Media$characters$edges?>? edges;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$edges = edges;
    _resultData['edges'] = l$edges?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$edges = edges;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$edges == null ? null : Object.hashAll(l$edges.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeCharacters$Media$characters ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$edges = edges;
    final lOther$edges = other.edges;
    if (l$edges != null && lOther$edges != null) {
      if (l$edges.length != lOther$edges.length) {
        return false;
      }
      for (int i = 0; i < l$edges.length; i++) {
        final l$edges$entry = l$edges[i];
        final lOther$edges$entry = lOther$edges[i];
        if (l$edges$entry != lOther$edges$entry) {
          return false;
        }
      }
    } else if (l$edges != lOther$edges) {
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

extension UtilityExtension$Query$GetAnimeCharacters$Media$characters
    on Query$GetAnimeCharacters$Media$characters {
  CopyWith$Query$GetAnimeCharacters$Media$characters<
          Query$GetAnimeCharacters$Media$characters>
      get copyWith => CopyWith$Query$GetAnimeCharacters$Media$characters(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeCharacters$Media$characters<TRes> {
  factory CopyWith$Query$GetAnimeCharacters$Media$characters(
    Query$GetAnimeCharacters$Media$characters instance,
    TRes Function(Query$GetAnimeCharacters$Media$characters) then,
  ) = _CopyWithImpl$Query$GetAnimeCharacters$Media$characters;

  factory CopyWith$Query$GetAnimeCharacters$Media$characters.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters;

  TRes call({
    Query$GetAnimeCharacters$Media$characters$pageInfo? pageInfo,
    List<Query$GetAnimeCharacters$Media$characters$edges?>? edges,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes>
      get pageInfo;
  TRes edges(
      Iterable<Query$GetAnimeCharacters$Media$characters$edges?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeCharacters$Media$characters$edges<
                      Query$GetAnimeCharacters$Media$characters$edges>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeCharacters$Media$characters<TRes>
    implements CopyWith$Query$GetAnimeCharacters$Media$characters<TRes> {
  _CopyWithImpl$Query$GetAnimeCharacters$Media$characters(
    this._instance,
    this._then,
  );

  final Query$GetAnimeCharacters$Media$characters _instance;

  final TRes Function(Query$GetAnimeCharacters$Media$characters) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? edges = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeCharacters$Media$characters(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$GetAnimeCharacters$Media$characters$pageInfo?),
        edges: edges == _undefined
            ? _instance.edges
            : (edges
                as List<Query$GetAnimeCharacters$Media$characters$edges?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes>
      get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes edges(
          Iterable<Query$GetAnimeCharacters$Media$characters$edges?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeCharacters$Media$characters$edges<
                          Query$GetAnimeCharacters$Media$characters$edges>?>?)
              _fn) =>
      call(
          edges: _fn(_instance.edges?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeCharacters$Media$characters$edges(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters<TRes>
    implements CopyWith$Query$GetAnimeCharacters$Media$characters<TRes> {
  _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters(this._res);

  TRes _res;

  call({
    Query$GetAnimeCharacters$Media$characters$pageInfo? pageInfo,
    List<Query$GetAnimeCharacters$Media$characters$edges?>? edges,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes>
      get pageInfo =>
          CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo.stub(
              _res);

  edges(_fn) => _res;
}

class Query$GetAnimeCharacters$Media$characters$pageInfo {
  Query$GetAnimeCharacters$Media$characters$pageInfo({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetAnimeCharacters$Media$characters$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$perPage = json['perPage'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeCharacters$Media$characters$pageInfo(
      total: (l$total as int?),
      perPage: (l$perPage as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? perPage;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$perPage = perPage;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$perPage,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeCharacters$Media$characters$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetAnimeCharacters$Media$characters$pageInfo
    on Query$GetAnimeCharacters$Media$characters$pageInfo {
  CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<
          Query$GetAnimeCharacters$Media$characters$pageInfo>
      get copyWith =>
          CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<
    TRes> {
  factory CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo(
    Query$GetAnimeCharacters$Media$characters$pageInfo instance,
    TRes Function(Query$GetAnimeCharacters$Media$characters$pageInfo) then,
  ) = _CopyWithImpl$Query$GetAnimeCharacters$Media$characters$pageInfo;

  factory CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters$pageInfo;

  TRes call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes>
    implements
        CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes> {
  _CopyWithImpl$Query$GetAnimeCharacters$Media$characters$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetAnimeCharacters$Media$characters$pageInfo _instance;

  final TRes Function(Query$GetAnimeCharacters$Media$characters$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? perPage = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeCharacters$Media$characters$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes>
    implements
        CopyWith$Query$GetAnimeCharacters$Media$characters$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters$pageInfo(
      this._res);

  TRes _res;

  call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeCharacters$Media$characters$edges {
  Query$GetAnimeCharacters$Media$characters$edges({
    this.id,
    this.role,
    this.name,
    this.node,
    this.voiceActors,
    this.$__typename = 'CharacterEdge',
  });

  factory Query$GetAnimeCharacters$Media$characters$edges.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$role = json['role'];
    final l$name = json['name'];
    final l$node = json['node'];
    final l$voiceActors = json['voiceActors'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeCharacters$Media$characters$edges(
      id: (l$id as int?),
      role: l$role == null
          ? null
          : fromJson$Enum$CharacterRole((l$role as String)),
      name: (l$name as String?),
      node: l$node == null
          ? null
          : Fragment$CharacterCard.fromJson((l$node as Map<String, dynamic>)),
      voiceActors: (l$voiceActors as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Fragment$StaffCard.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int? id;

  final Enum$CharacterRole? role;

  final String? name;

  final Fragment$CharacterCard? node;

  final List<Fragment$StaffCard?>? voiceActors;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$role = role;
    _resultData['role'] =
        l$role == null ? null : toJson$Enum$CharacterRole(l$role);
    final l$name = name;
    _resultData['name'] = l$name;
    final l$node = node;
    _resultData['node'] = l$node?.toJson();
    final l$voiceActors = voiceActors;
    _resultData['voiceActors'] =
        l$voiceActors?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$role = role;
    final l$name = name;
    final l$node = node;
    final l$voiceActors = voiceActors;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$role,
      l$name,
      l$node,
      l$voiceActors == null
          ? null
          : Object.hashAll(l$voiceActors.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeCharacters$Media$characters$edges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$role = role;
    final lOther$role = other.role;
    if (l$role != lOther$role) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$node = node;
    final lOther$node = other.node;
    if (l$node != lOther$node) {
      return false;
    }
    final l$voiceActors = voiceActors;
    final lOther$voiceActors = other.voiceActors;
    if (l$voiceActors != null && lOther$voiceActors != null) {
      if (l$voiceActors.length != lOther$voiceActors.length) {
        return false;
      }
      for (int i = 0; i < l$voiceActors.length; i++) {
        final l$voiceActors$entry = l$voiceActors[i];
        final lOther$voiceActors$entry = lOther$voiceActors[i];
        if (l$voiceActors$entry != lOther$voiceActors$entry) {
          return false;
        }
      }
    } else if (l$voiceActors != lOther$voiceActors) {
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

extension UtilityExtension$Query$GetAnimeCharacters$Media$characters$edges
    on Query$GetAnimeCharacters$Media$characters$edges {
  CopyWith$Query$GetAnimeCharacters$Media$characters$edges<
          Query$GetAnimeCharacters$Media$characters$edges>
      get copyWith => CopyWith$Query$GetAnimeCharacters$Media$characters$edges(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeCharacters$Media$characters$edges<TRes> {
  factory CopyWith$Query$GetAnimeCharacters$Media$characters$edges(
    Query$GetAnimeCharacters$Media$characters$edges instance,
    TRes Function(Query$GetAnimeCharacters$Media$characters$edges) then,
  ) = _CopyWithImpl$Query$GetAnimeCharacters$Media$characters$edges;

  factory CopyWith$Query$GetAnimeCharacters$Media$characters$edges.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters$edges;

  TRes call({
    int? id,
    Enum$CharacterRole? role,
    String? name,
    Fragment$CharacterCard? node,
    List<Fragment$StaffCard?>? voiceActors,
    String? $__typename,
  });
  CopyWith$Fragment$CharacterCard<TRes> get node;
  TRes voiceActors(
      Iterable<Fragment$StaffCard?>? Function(
              Iterable<CopyWith$Fragment$StaffCard<Fragment$StaffCard>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeCharacters$Media$characters$edges<TRes>
    implements CopyWith$Query$GetAnimeCharacters$Media$characters$edges<TRes> {
  _CopyWithImpl$Query$GetAnimeCharacters$Media$characters$edges(
    this._instance,
    this._then,
  );

  final Query$GetAnimeCharacters$Media$characters$edges _instance;

  final TRes Function(Query$GetAnimeCharacters$Media$characters$edges) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? role = _undefined,
    Object? name = _undefined,
    Object? node = _undefined,
    Object? voiceActors = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeCharacters$Media$characters$edges(
        id: id == _undefined ? _instance.id : (id as int?),
        role:
            role == _undefined ? _instance.role : (role as Enum$CharacterRole?),
        name: name == _undefined ? _instance.name : (name as String?),
        node: node == _undefined
            ? _instance.node
            : (node as Fragment$CharacterCard?),
        voiceActors: voiceActors == _undefined
            ? _instance.voiceActors
            : (voiceActors as List<Fragment$StaffCard?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$CharacterCard<TRes> get node {
    final local$node = _instance.node;
    return local$node == null
        ? CopyWith$Fragment$CharacterCard.stub(_then(_instance))
        : CopyWith$Fragment$CharacterCard(local$node, (e) => call(node: e));
  }

  TRes voiceActors(
          Iterable<Fragment$StaffCard?>? Function(
                  Iterable<CopyWith$Fragment$StaffCard<Fragment$StaffCard>?>?)
              _fn) =>
      call(
          voiceActors: _fn(_instance.voiceActors?.map((e) => e == null
              ? null
              : CopyWith$Fragment$StaffCard(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters$edges<TRes>
    implements CopyWith$Query$GetAnimeCharacters$Media$characters$edges<TRes> {
  _CopyWithStubImpl$Query$GetAnimeCharacters$Media$characters$edges(this._res);

  TRes _res;

  call({
    int? id,
    Enum$CharacterRole? role,
    String? name,
    Fragment$CharacterCard? node,
    List<Fragment$StaffCard?>? voiceActors,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$CharacterCard<TRes> get node =>
      CopyWith$Fragment$CharacterCard.stub(_res);

  voiceActors(_fn) => _res;
}

class Variables$Query$GetAnimeStaff {
  factory Variables$Query$GetAnimeStaff({
    required int id,
    int? page,
  }) =>
      Variables$Query$GetAnimeStaff._({
        r'id': id,
        if (page != null) r'page': page,
      });

  Variables$Query$GetAnimeStaff._(this._$data);

  factory Variables$Query$GetAnimeStaff.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    if (data.containsKey('page')) {
      final l$page = data['page'];
      result$data['page'] = (l$page as int?);
    }
    return Variables$Query$GetAnimeStaff._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  int? get page => (_$data['page'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    if (_$data.containsKey('page')) {
      final l$page = page;
      result$data['page'] = l$page;
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetAnimeStaff<Variables$Query$GetAnimeStaff>
      get copyWith => CopyWith$Variables$Query$GetAnimeStaff(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetAnimeStaff ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$page = page;
    return Object.hashAll([
      l$id,
      _$data.containsKey('page') ? l$page : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetAnimeStaff<TRes> {
  factory CopyWith$Variables$Query$GetAnimeStaff(
    Variables$Query$GetAnimeStaff instance,
    TRes Function(Variables$Query$GetAnimeStaff) then,
  ) = _CopyWithImpl$Variables$Query$GetAnimeStaff;

  factory CopyWith$Variables$Query$GetAnimeStaff.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetAnimeStaff;

  TRes call({
    int? id,
    int? page,
  });
}

class _CopyWithImpl$Variables$Query$GetAnimeStaff<TRes>
    implements CopyWith$Variables$Query$GetAnimeStaff<TRes> {
  _CopyWithImpl$Variables$Query$GetAnimeStaff(
    this._instance,
    this._then,
  );

  final Variables$Query$GetAnimeStaff _instance;

  final TRes Function(Variables$Query$GetAnimeStaff) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? page = _undefined,
  }) =>
      _then(Variables$Query$GetAnimeStaff._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
        if (page != _undefined) 'page': (page as int?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetAnimeStaff<TRes>
    implements CopyWith$Variables$Query$GetAnimeStaff<TRes> {
  _CopyWithStubImpl$Variables$Query$GetAnimeStaff(this._res);

  TRes _res;

  call({
    int? id,
    int? page,
  }) =>
      _res;
}

class Query$GetAnimeStaff {
  Query$GetAnimeStaff({
    this.Media,
    this.$__typename = 'Query',
  });

  factory Query$GetAnimeStaff.fromJson(Map<String, dynamic> json) {
    final l$Media = json['Media'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStaff(
      Media: l$Media == null
          ? null
          : Query$GetAnimeStaff$Media.fromJson(
              (l$Media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeStaff$Media? Media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Media = Media;
    _resultData['Media'] = l$Media?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Media = Media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Media,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStaff || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Media = Media;
    final lOther$Media = other.Media;
    if (l$Media != lOther$Media) {
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

extension UtilityExtension$Query$GetAnimeStaff on Query$GetAnimeStaff {
  CopyWith$Query$GetAnimeStaff<Query$GetAnimeStaff> get copyWith =>
      CopyWith$Query$GetAnimeStaff(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeStaff<TRes> {
  factory CopyWith$Query$GetAnimeStaff(
    Query$GetAnimeStaff instance,
    TRes Function(Query$GetAnimeStaff) then,
  ) = _CopyWithImpl$Query$GetAnimeStaff;

  factory CopyWith$Query$GetAnimeStaff.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStaff;

  TRes call({
    Query$GetAnimeStaff$Media? Media,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeStaff$Media<TRes> get Media;
}

class _CopyWithImpl$Query$GetAnimeStaff<TRes>
    implements CopyWith$Query$GetAnimeStaff<TRes> {
  _CopyWithImpl$Query$GetAnimeStaff(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStaff _instance;

  final TRes Function(Query$GetAnimeStaff) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStaff(
        Media: Media == _undefined
            ? _instance.Media
            : (Media as Query$GetAnimeStaff$Media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeStaff$Media<TRes> get Media {
    final local$Media = _instance.Media;
    return local$Media == null
        ? CopyWith$Query$GetAnimeStaff$Media.stub(_then(_instance))
        : CopyWith$Query$GetAnimeStaff$Media(
            local$Media, (e) => call(Media: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeStaff<TRes>
    implements CopyWith$Query$GetAnimeStaff<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStaff(this._res);

  TRes _res;

  call({
    Query$GetAnimeStaff$Media? Media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeStaff$Media<TRes> get Media =>
      CopyWith$Query$GetAnimeStaff$Media.stub(_res);
}

const documentNodeQueryGetAnimeStaff = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetAnimeStaff'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'page')),
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
        name: NameNode(value: 'Media'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          ),
          ArgumentNode(
            name: NameNode(value: 'type'),
            value: EnumValueNode(name: NameNode(value: 'ANIME')),
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
            name: NameNode(value: 'staff'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'page'),
                value: VariableNode(name: NameNode(value: 'page')),
              ),
              ArgumentNode(
                name: NameNode(value: 'perPage'),
                value: IntValueNode(value: '25'),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'RELEVANCE')),
                  EnumValueNode(name: NameNode(value: 'ID')),
                ]),
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
                    name: NameNode(value: 'perPage'),
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
                    name: NameNode(value: '__typename'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                ]),
              ),
              FieldNode(
                name: NameNode(value: 'edges'),
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
                    name: NameNode(value: 'role'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'node'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: SelectionSetNode(selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'StaffCard'),
                        directives: [],
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
  fragmentDefinitionStaffCard,
]);
Query$GetAnimeStaff _parserFn$Query$GetAnimeStaff(Map<String, dynamic> data) =>
    Query$GetAnimeStaff.fromJson(data);
typedef OnQueryComplete$Query$GetAnimeStaff = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetAnimeStaff?,
);

class Options$Query$GetAnimeStaff
    extends graphql.QueryOptions<Query$GetAnimeStaff> {
  Options$Query$GetAnimeStaff({
    String? operationName,
    required Variables$Query$GetAnimeStaff variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeStaff? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetAnimeStaff? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                    data == null ? null : _parserFn$Query$GetAnimeStaff(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetAnimeStaff,
          parserFn: _parserFn$Query$GetAnimeStaff,
        );

  final OnQueryComplete$Query$GetAnimeStaff? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetAnimeStaff
    extends graphql.WatchQueryOptions<Query$GetAnimeStaff> {
  WatchOptions$Query$GetAnimeStaff({
    String? operationName,
    required Variables$Query$GetAnimeStaff variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeStaff? typedOptimisticResult,
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
          document: documentNodeQueryGetAnimeStaff,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetAnimeStaff,
        );
}

class FetchMoreOptions$Query$GetAnimeStaff extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetAnimeStaff({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetAnimeStaff variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetAnimeStaff,
        );
}

extension ClientExtension$Query$GetAnimeStaff on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetAnimeStaff>> query$GetAnimeStaff(
          Options$Query$GetAnimeStaff options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetAnimeStaff> watchQuery$GetAnimeStaff(
          WatchOptions$Query$GetAnimeStaff options) =>
      this.watchQuery(options);
  void writeQuery$GetAnimeStaff({
    required Query$GetAnimeStaff data,
    required Variables$Query$GetAnimeStaff variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetAnimeStaff),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetAnimeStaff? readQuery$GetAnimeStaff({
    required Variables$Query$GetAnimeStaff variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetAnimeStaff),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetAnimeStaff.fromJson(result);
  }
}

class Query$GetAnimeStaff$Media {
  Query$GetAnimeStaff$Media({
    required this.id,
    this.staff,
    this.$__typename = 'Media',
  });

  factory Query$GetAnimeStaff$Media.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$staff = json['staff'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStaff$Media(
      id: (l$id as int),
      staff: l$staff == null
          ? null
          : Query$GetAnimeStaff$Media$staff.fromJson(
              (l$staff as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetAnimeStaff$Media$staff? staff;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$staff = staff;
    _resultData['staff'] = l$staff?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$staff = staff;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$staff,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStaff$Media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$staff = staff;
    final lOther$staff = other.staff;
    if (l$staff != lOther$staff) {
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

extension UtilityExtension$Query$GetAnimeStaff$Media
    on Query$GetAnimeStaff$Media {
  CopyWith$Query$GetAnimeStaff$Media<Query$GetAnimeStaff$Media> get copyWith =>
      CopyWith$Query$GetAnimeStaff$Media(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeStaff$Media<TRes> {
  factory CopyWith$Query$GetAnimeStaff$Media(
    Query$GetAnimeStaff$Media instance,
    TRes Function(Query$GetAnimeStaff$Media) then,
  ) = _CopyWithImpl$Query$GetAnimeStaff$Media;

  factory CopyWith$Query$GetAnimeStaff$Media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStaff$Media;

  TRes call({
    int? id,
    Query$GetAnimeStaff$Media$staff? staff,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeStaff$Media$staff<TRes> get staff;
}

class _CopyWithImpl$Query$GetAnimeStaff$Media<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media<TRes> {
  _CopyWithImpl$Query$GetAnimeStaff$Media(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStaff$Media _instance;

  final TRes Function(Query$GetAnimeStaff$Media) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? staff = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStaff$Media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        staff: staff == _undefined
            ? _instance.staff
            : (staff as Query$GetAnimeStaff$Media$staff?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeStaff$Media$staff<TRes> get staff {
    final local$staff = _instance.staff;
    return local$staff == null
        ? CopyWith$Query$GetAnimeStaff$Media$staff.stub(_then(_instance))
        : CopyWith$Query$GetAnimeStaff$Media$staff(
            local$staff, (e) => call(staff: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeStaff$Media<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStaff$Media(this._res);

  TRes _res;

  call({
    int? id,
    Query$GetAnimeStaff$Media$staff? staff,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeStaff$Media$staff<TRes> get staff =>
      CopyWith$Query$GetAnimeStaff$Media$staff.stub(_res);
}

class Query$GetAnimeStaff$Media$staff {
  Query$GetAnimeStaff$Media$staff({
    this.pageInfo,
    this.edges,
    this.$__typename = 'StaffConnection',
  });

  factory Query$GetAnimeStaff$Media$staff.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$edges = json['edges'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStaff$Media$staff(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetAnimeStaff$Media$staff$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      edges: (l$edges as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeStaff$Media$staff$edges.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeStaff$Media$staff$pageInfo? pageInfo;

  final List<Query$GetAnimeStaff$Media$staff$edges?>? edges;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$edges = edges;
    _resultData['edges'] = l$edges?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$edges = edges;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$edges == null ? null : Object.hashAll(l$edges.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStaff$Media$staff ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$edges = edges;
    final lOther$edges = other.edges;
    if (l$edges != null && lOther$edges != null) {
      if (l$edges.length != lOther$edges.length) {
        return false;
      }
      for (int i = 0; i < l$edges.length; i++) {
        final l$edges$entry = l$edges[i];
        final lOther$edges$entry = lOther$edges[i];
        if (l$edges$entry != lOther$edges$entry) {
          return false;
        }
      }
    } else if (l$edges != lOther$edges) {
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

extension UtilityExtension$Query$GetAnimeStaff$Media$staff
    on Query$GetAnimeStaff$Media$staff {
  CopyWith$Query$GetAnimeStaff$Media$staff<Query$GetAnimeStaff$Media$staff>
      get copyWith => CopyWith$Query$GetAnimeStaff$Media$staff(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStaff$Media$staff<TRes> {
  factory CopyWith$Query$GetAnimeStaff$Media$staff(
    Query$GetAnimeStaff$Media$staff instance,
    TRes Function(Query$GetAnimeStaff$Media$staff) then,
  ) = _CopyWithImpl$Query$GetAnimeStaff$Media$staff;

  factory CopyWith$Query$GetAnimeStaff$Media$staff.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff;

  TRes call({
    Query$GetAnimeStaff$Media$staff$pageInfo? pageInfo,
    List<Query$GetAnimeStaff$Media$staff$edges?>? edges,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<TRes> get pageInfo;
  TRes edges(
      Iterable<Query$GetAnimeStaff$Media$staff$edges?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeStaff$Media$staff$edges<
                      Query$GetAnimeStaff$Media$staff$edges>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeStaff$Media$staff<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media$staff<TRes> {
  _CopyWithImpl$Query$GetAnimeStaff$Media$staff(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStaff$Media$staff _instance;

  final TRes Function(Query$GetAnimeStaff$Media$staff) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? edges = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStaff$Media$staff(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$GetAnimeStaff$Media$staff$pageInfo?),
        edges: edges == _undefined
            ? _instance.edges
            : (edges as List<Query$GetAnimeStaff$Media$staff$edges?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo.stub(
            _then(_instance))
        : CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes edges(
          Iterable<Query$GetAnimeStaff$Media$staff$edges?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeStaff$Media$staff$edges<
                          Query$GetAnimeStaff$Media$staff$edges>?>?)
              _fn) =>
      call(
          edges: _fn(_instance.edges?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeStaff$Media$staff$edges(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media$staff<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff(this._res);

  TRes _res;

  call({
    Query$GetAnimeStaff$Media$staff$pageInfo? pageInfo,
    List<Query$GetAnimeStaff$Media$staff$edges?>? edges,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<TRes> get pageInfo =>
      CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo.stub(_res);

  edges(_fn) => _res;
}

class Query$GetAnimeStaff$Media$staff$pageInfo {
  Query$GetAnimeStaff$Media$staff$pageInfo({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetAnimeStaff$Media$staff$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$perPage = json['perPage'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStaff$Media$staff$pageInfo(
      total: (l$total as int?),
      perPage: (l$perPage as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? perPage;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$perPage = perPage;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$perPage,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStaff$Media$staff$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetAnimeStaff$Media$staff$pageInfo
    on Query$GetAnimeStaff$Media$staff$pageInfo {
  CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<
          Query$GetAnimeStaff$Media$staff$pageInfo>
      get copyWith => CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<TRes> {
  factory CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo(
    Query$GetAnimeStaff$Media$staff$pageInfo instance,
    TRes Function(Query$GetAnimeStaff$Media$staff$pageInfo) then,
  ) = _CopyWithImpl$Query$GetAnimeStaff$Media$staff$pageInfo;

  factory CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff$pageInfo;

  TRes call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeStaff$Media$staff$pageInfo<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<TRes> {
  _CopyWithImpl$Query$GetAnimeStaff$Media$staff$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStaff$Media$staff$pageInfo _instance;

  final TRes Function(Query$GetAnimeStaff$Media$staff$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? perPage = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStaff$Media$staff$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff$pageInfo<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media$staff$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff$pageInfo(this._res);

  TRes _res;

  call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeStaff$Media$staff$edges {
  Query$GetAnimeStaff$Media$staff$edges({
    this.id,
    this.role,
    this.node,
    this.$__typename = 'StaffEdge',
  });

  factory Query$GetAnimeStaff$Media$staff$edges.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$role = json['role'];
    final l$node = json['node'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStaff$Media$staff$edges(
      id: (l$id as int?),
      role: (l$role as String?),
      node: l$node == null
          ? null
          : Fragment$StaffCard.fromJson((l$node as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int? id;

  final String? role;

  final Fragment$StaffCard? node;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$role = role;
    _resultData['role'] = l$role;
    final l$node = node;
    _resultData['node'] = l$node?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$role = role;
    final l$node = node;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$role,
      l$node,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStaff$Media$staff$edges ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$role = role;
    final lOther$role = other.role;
    if (l$role != lOther$role) {
      return false;
    }
    final l$node = node;
    final lOther$node = other.node;
    if (l$node != lOther$node) {
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

extension UtilityExtension$Query$GetAnimeStaff$Media$staff$edges
    on Query$GetAnimeStaff$Media$staff$edges {
  CopyWith$Query$GetAnimeStaff$Media$staff$edges<
          Query$GetAnimeStaff$Media$staff$edges>
      get copyWith => CopyWith$Query$GetAnimeStaff$Media$staff$edges(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStaff$Media$staff$edges<TRes> {
  factory CopyWith$Query$GetAnimeStaff$Media$staff$edges(
    Query$GetAnimeStaff$Media$staff$edges instance,
    TRes Function(Query$GetAnimeStaff$Media$staff$edges) then,
  ) = _CopyWithImpl$Query$GetAnimeStaff$Media$staff$edges;

  factory CopyWith$Query$GetAnimeStaff$Media$staff$edges.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff$edges;

  TRes call({
    int? id,
    String? role,
    Fragment$StaffCard? node,
    String? $__typename,
  });
  CopyWith$Fragment$StaffCard<TRes> get node;
}

class _CopyWithImpl$Query$GetAnimeStaff$Media$staff$edges<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media$staff$edges<TRes> {
  _CopyWithImpl$Query$GetAnimeStaff$Media$staff$edges(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStaff$Media$staff$edges _instance;

  final TRes Function(Query$GetAnimeStaff$Media$staff$edges) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? role = _undefined,
    Object? node = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStaff$Media$staff$edges(
        id: id == _undefined ? _instance.id : (id as int?),
        role: role == _undefined ? _instance.role : (role as String?),
        node:
            node == _undefined ? _instance.node : (node as Fragment$StaffCard?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$StaffCard<TRes> get node {
    final local$node = _instance.node;
    return local$node == null
        ? CopyWith$Fragment$StaffCard.stub(_then(_instance))
        : CopyWith$Fragment$StaffCard(local$node, (e) => call(node: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff$edges<TRes>
    implements CopyWith$Query$GetAnimeStaff$Media$staff$edges<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStaff$Media$staff$edges(this._res);

  TRes _res;

  call({
    int? id,
    String? role,
    Fragment$StaffCard? node,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$StaffCard<TRes> get node =>
      CopyWith$Fragment$StaffCard.stub(_res);
}

class Variables$Query$GetAnimeSocial {
  factory Variables$Query$GetAnimeSocial({
    required int id,
    int? page,
  }) =>
      Variables$Query$GetAnimeSocial._({
        r'id': id,
        if (page != null) r'page': page,
      });

  Variables$Query$GetAnimeSocial._(this._$data);

  factory Variables$Query$GetAnimeSocial.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    if (data.containsKey('page')) {
      final l$page = data['page'];
      result$data['page'] = (l$page as int?);
    }
    return Variables$Query$GetAnimeSocial._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  int? get page => (_$data['page'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    if (_$data.containsKey('page')) {
      final l$page = page;
      result$data['page'] = l$page;
    }
    return result$data;
  }

  CopyWith$Variables$Query$GetAnimeSocial<Variables$Query$GetAnimeSocial>
      get copyWith => CopyWith$Variables$Query$GetAnimeSocial(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetAnimeSocial ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
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
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$page = page;
    return Object.hashAll([
      l$id,
      _$data.containsKey('page') ? l$page : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetAnimeSocial<TRes> {
  factory CopyWith$Variables$Query$GetAnimeSocial(
    Variables$Query$GetAnimeSocial instance,
    TRes Function(Variables$Query$GetAnimeSocial) then,
  ) = _CopyWithImpl$Variables$Query$GetAnimeSocial;

  factory CopyWith$Variables$Query$GetAnimeSocial.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetAnimeSocial;

  TRes call({
    int? id,
    int? page,
  });
}

class _CopyWithImpl$Variables$Query$GetAnimeSocial<TRes>
    implements CopyWith$Variables$Query$GetAnimeSocial<TRes> {
  _CopyWithImpl$Variables$Query$GetAnimeSocial(
    this._instance,
    this._then,
  );

  final Variables$Query$GetAnimeSocial _instance;

  final TRes Function(Variables$Query$GetAnimeSocial) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? page = _undefined,
  }) =>
      _then(Variables$Query$GetAnimeSocial._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
        if (page != _undefined) 'page': (page as int?),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetAnimeSocial<TRes>
    implements CopyWith$Variables$Query$GetAnimeSocial<TRes> {
  _CopyWithStubImpl$Variables$Query$GetAnimeSocial(this._res);

  TRes _res;

  call({
    int? id,
    int? page,
  }) =>
      _res;
}

class Query$GetAnimeSocial {
  Query$GetAnimeSocial({
    this.Page,
    this.$__typename = 'Query',
  });

  factory Query$GetAnimeSocial.fromJson(Map<String, dynamic> json) {
    final l$Page = json['Page'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeSocial(
      Page: l$Page == null
          ? null
          : Query$GetAnimeSocial$Page.fromJson(
              (l$Page as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeSocial$Page? Page;

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
    if (other is! Query$GetAnimeSocial || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetAnimeSocial on Query$GetAnimeSocial {
  CopyWith$Query$GetAnimeSocial<Query$GetAnimeSocial> get copyWith =>
      CopyWith$Query$GetAnimeSocial(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeSocial<TRes> {
  factory CopyWith$Query$GetAnimeSocial(
    Query$GetAnimeSocial instance,
    TRes Function(Query$GetAnimeSocial) then,
  ) = _CopyWithImpl$Query$GetAnimeSocial;

  factory CopyWith$Query$GetAnimeSocial.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeSocial;

  TRes call({
    Query$GetAnimeSocial$Page? Page,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeSocial$Page<TRes> get Page;
}

class _CopyWithImpl$Query$GetAnimeSocial<TRes>
    implements CopyWith$Query$GetAnimeSocial<TRes> {
  _CopyWithImpl$Query$GetAnimeSocial(
    this._instance,
    this._then,
  );

  final Query$GetAnimeSocial _instance;

  final TRes Function(Query$GetAnimeSocial) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Page = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeSocial(
        Page: Page == _undefined
            ? _instance.Page
            : (Page as Query$GetAnimeSocial$Page?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeSocial$Page<TRes> get Page {
    final local$Page = _instance.Page;
    return local$Page == null
        ? CopyWith$Query$GetAnimeSocial$Page.stub(_then(_instance))
        : CopyWith$Query$GetAnimeSocial$Page(local$Page, (e) => call(Page: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeSocial<TRes>
    implements CopyWith$Query$GetAnimeSocial<TRes> {
  _CopyWithStubImpl$Query$GetAnimeSocial(this._res);

  TRes _res;

  call({
    Query$GetAnimeSocial$Page? Page,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeSocial$Page<TRes> get Page =>
      CopyWith$Query$GetAnimeSocial$Page.stub(_res);
}

const documentNodeQueryGetAnimeSocial = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetAnimeSocial'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'id')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'page')),
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
        name: NameNode(value: 'Page'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'page'),
            value: VariableNode(name: NameNode(value: 'page')),
          ),
          ArgumentNode(
            name: NameNode(value: 'perPage'),
            value: IntValueNode(value: '25'),
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
                name: NameNode(value: 'perPage'),
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
                name: NameNode(value: '__typename'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
            ]),
          ),
          FieldNode(
            name: NameNode(value: 'mediaList'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'mediaId'),
                value: VariableNode(name: NameNode(value: 'id')),
              ),
              ArgumentNode(
                name: NameNode(value: 'isFollowing'),
                value: BooleanValueNode(value: true),
              ),
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: ListValueNode(values: [
                  EnumValueNode(name: NameNode(value: 'UPDATED_TIME_DESC'))
                ]),
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
                name: NameNode(value: 'updatedAt'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: null,
              ),
              FieldNode(
                name: NameNode(value: 'user'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FragmentSpreadNode(
                    name: NameNode(value: 'UserAvatar'),
                    directives: [],
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
  fragmentDefinitionUserAvatar,
]);
Query$GetAnimeSocial _parserFn$Query$GetAnimeSocial(
        Map<String, dynamic> data) =>
    Query$GetAnimeSocial.fromJson(data);
typedef OnQueryComplete$Query$GetAnimeSocial = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetAnimeSocial?,
);

class Options$Query$GetAnimeSocial
    extends graphql.QueryOptions<Query$GetAnimeSocial> {
  Options$Query$GetAnimeSocial({
    String? operationName,
    required Variables$Query$GetAnimeSocial variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeSocial? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetAnimeSocial? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                    data == null ? null : _parserFn$Query$GetAnimeSocial(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetAnimeSocial,
          parserFn: _parserFn$Query$GetAnimeSocial,
        );

  final OnQueryComplete$Query$GetAnimeSocial? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetAnimeSocial
    extends graphql.WatchQueryOptions<Query$GetAnimeSocial> {
  WatchOptions$Query$GetAnimeSocial({
    String? operationName,
    required Variables$Query$GetAnimeSocial variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeSocial? typedOptimisticResult,
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
          document: documentNodeQueryGetAnimeSocial,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetAnimeSocial,
        );
}

class FetchMoreOptions$Query$GetAnimeSocial extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetAnimeSocial({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetAnimeSocial variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetAnimeSocial,
        );
}

extension ClientExtension$Query$GetAnimeSocial on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetAnimeSocial>> query$GetAnimeSocial(
          Options$Query$GetAnimeSocial options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetAnimeSocial> watchQuery$GetAnimeSocial(
          WatchOptions$Query$GetAnimeSocial options) =>
      this.watchQuery(options);
  void writeQuery$GetAnimeSocial({
    required Query$GetAnimeSocial data,
    required Variables$Query$GetAnimeSocial variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetAnimeSocial),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetAnimeSocial? readQuery$GetAnimeSocial({
    required Variables$Query$GetAnimeSocial variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetAnimeSocial),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetAnimeSocial.fromJson(result);
  }
}

class Query$GetAnimeSocial$Page {
  Query$GetAnimeSocial$Page({
    this.pageInfo,
    this.mediaList,
    this.$__typename = 'Page',
  });

  factory Query$GetAnimeSocial$Page.fromJson(Map<String, dynamic> json) {
    final l$pageInfo = json['pageInfo'];
    final l$mediaList = json['mediaList'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeSocial$Page(
      pageInfo: l$pageInfo == null
          ? null
          : Query$GetAnimeSocial$Page$pageInfo.fromJson(
              (l$pageInfo as Map<String, dynamic>)),
      mediaList: (l$mediaList as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeSocial$Page$mediaList.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeSocial$Page$pageInfo? pageInfo;

  final List<Query$GetAnimeSocial$Page$mediaList?>? mediaList;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$pageInfo = pageInfo;
    _resultData['pageInfo'] = l$pageInfo?.toJson();
    final l$mediaList = mediaList;
    _resultData['mediaList'] = l$mediaList?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$pageInfo = pageInfo;
    final l$mediaList = mediaList;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$pageInfo,
      l$mediaList == null ? null : Object.hashAll(l$mediaList.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeSocial$Page ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$pageInfo = pageInfo;
    final lOther$pageInfo = other.pageInfo;
    if (l$pageInfo != lOther$pageInfo) {
      return false;
    }
    final l$mediaList = mediaList;
    final lOther$mediaList = other.mediaList;
    if (l$mediaList != null && lOther$mediaList != null) {
      if (l$mediaList.length != lOther$mediaList.length) {
        return false;
      }
      for (int i = 0; i < l$mediaList.length; i++) {
        final l$mediaList$entry = l$mediaList[i];
        final lOther$mediaList$entry = lOther$mediaList[i];
        if (l$mediaList$entry != lOther$mediaList$entry) {
          return false;
        }
      }
    } else if (l$mediaList != lOther$mediaList) {
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

extension UtilityExtension$Query$GetAnimeSocial$Page
    on Query$GetAnimeSocial$Page {
  CopyWith$Query$GetAnimeSocial$Page<Query$GetAnimeSocial$Page> get copyWith =>
      CopyWith$Query$GetAnimeSocial$Page(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeSocial$Page<TRes> {
  factory CopyWith$Query$GetAnimeSocial$Page(
    Query$GetAnimeSocial$Page instance,
    TRes Function(Query$GetAnimeSocial$Page) then,
  ) = _CopyWithImpl$Query$GetAnimeSocial$Page;

  factory CopyWith$Query$GetAnimeSocial$Page.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeSocial$Page;

  TRes call({
    Query$GetAnimeSocial$Page$pageInfo? pageInfo,
    List<Query$GetAnimeSocial$Page$mediaList?>? mediaList,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeSocial$Page$pageInfo<TRes> get pageInfo;
  TRes mediaList(
      Iterable<Query$GetAnimeSocial$Page$mediaList?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeSocial$Page$mediaList<
                      Query$GetAnimeSocial$Page$mediaList>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeSocial$Page<TRes>
    implements CopyWith$Query$GetAnimeSocial$Page<TRes> {
  _CopyWithImpl$Query$GetAnimeSocial$Page(
    this._instance,
    this._then,
  );

  final Query$GetAnimeSocial$Page _instance;

  final TRes Function(Query$GetAnimeSocial$Page) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? pageInfo = _undefined,
    Object? mediaList = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeSocial$Page(
        pageInfo: pageInfo == _undefined
            ? _instance.pageInfo
            : (pageInfo as Query$GetAnimeSocial$Page$pageInfo?),
        mediaList: mediaList == _undefined
            ? _instance.mediaList
            : (mediaList as List<Query$GetAnimeSocial$Page$mediaList?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeSocial$Page$pageInfo<TRes> get pageInfo {
    final local$pageInfo = _instance.pageInfo;
    return local$pageInfo == null
        ? CopyWith$Query$GetAnimeSocial$Page$pageInfo.stub(_then(_instance))
        : CopyWith$Query$GetAnimeSocial$Page$pageInfo(
            local$pageInfo, (e) => call(pageInfo: e));
  }

  TRes mediaList(
          Iterable<Query$GetAnimeSocial$Page$mediaList?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeSocial$Page$mediaList<
                          Query$GetAnimeSocial$Page$mediaList>?>?)
              _fn) =>
      call(
          mediaList: _fn(_instance.mediaList?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeSocial$Page$mediaList(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeSocial$Page<TRes>
    implements CopyWith$Query$GetAnimeSocial$Page<TRes> {
  _CopyWithStubImpl$Query$GetAnimeSocial$Page(this._res);

  TRes _res;

  call({
    Query$GetAnimeSocial$Page$pageInfo? pageInfo,
    List<Query$GetAnimeSocial$Page$mediaList?>? mediaList,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeSocial$Page$pageInfo<TRes> get pageInfo =>
      CopyWith$Query$GetAnimeSocial$Page$pageInfo.stub(_res);

  mediaList(_fn) => _res;
}

class Query$GetAnimeSocial$Page$pageInfo {
  Query$GetAnimeSocial$Page$pageInfo({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.hasNextPage,
    this.$__typename = 'PageInfo',
  });

  factory Query$GetAnimeSocial$Page$pageInfo.fromJson(
      Map<String, dynamic> json) {
    final l$total = json['total'];
    final l$perPage = json['perPage'];
    final l$currentPage = json['currentPage'];
    final l$lastPage = json['lastPage'];
    final l$hasNextPage = json['hasNextPage'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeSocial$Page$pageInfo(
      total: (l$total as int?),
      perPage: (l$perPage as int?),
      currentPage: (l$currentPage as int?),
      lastPage: (l$lastPage as int?),
      hasNextPage: (l$hasNextPage as bool?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? total;

  final int? perPage;

  final int? currentPage;

  final int? lastPage;

  final bool? hasNextPage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$total = total;
    _resultData['total'] = l$total;
    final l$perPage = perPage;
    _resultData['perPage'] = l$perPage;
    final l$currentPage = currentPage;
    _resultData['currentPage'] = l$currentPage;
    final l$lastPage = lastPage;
    _resultData['lastPage'] = l$lastPage;
    final l$hasNextPage = hasNextPage;
    _resultData['hasNextPage'] = l$hasNextPage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$total = total;
    final l$perPage = perPage;
    final l$currentPage = currentPage;
    final l$lastPage = lastPage;
    final l$hasNextPage = hasNextPage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$total,
      l$perPage,
      l$currentPage,
      l$lastPage,
      l$hasNextPage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeSocial$Page$pageInfo ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$total = total;
    final lOther$total = other.total;
    if (l$total != lOther$total) {
      return false;
    }
    final l$perPage = perPage;
    final lOther$perPage = other.perPage;
    if (l$perPage != lOther$perPage) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetAnimeSocial$Page$pageInfo
    on Query$GetAnimeSocial$Page$pageInfo {
  CopyWith$Query$GetAnimeSocial$Page$pageInfo<
          Query$GetAnimeSocial$Page$pageInfo>
      get copyWith => CopyWith$Query$GetAnimeSocial$Page$pageInfo(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeSocial$Page$pageInfo<TRes> {
  factory CopyWith$Query$GetAnimeSocial$Page$pageInfo(
    Query$GetAnimeSocial$Page$pageInfo instance,
    TRes Function(Query$GetAnimeSocial$Page$pageInfo) then,
  ) = _CopyWithImpl$Query$GetAnimeSocial$Page$pageInfo;

  factory CopyWith$Query$GetAnimeSocial$Page$pageInfo.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeSocial$Page$pageInfo;

  TRes call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeSocial$Page$pageInfo<TRes>
    implements CopyWith$Query$GetAnimeSocial$Page$pageInfo<TRes> {
  _CopyWithImpl$Query$GetAnimeSocial$Page$pageInfo(
    this._instance,
    this._then,
  );

  final Query$GetAnimeSocial$Page$pageInfo _instance;

  final TRes Function(Query$GetAnimeSocial$Page$pageInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? total = _undefined,
    Object? perPage = _undefined,
    Object? currentPage = _undefined,
    Object? lastPage = _undefined,
    Object? hasNextPage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeSocial$Page$pageInfo(
        total: total == _undefined ? _instance.total : (total as int?),
        perPage: perPage == _undefined ? _instance.perPage : (perPage as int?),
        currentPage: currentPage == _undefined
            ? _instance.currentPage
            : (currentPage as int?),
        lastPage:
            lastPage == _undefined ? _instance.lastPage : (lastPage as int?),
        hasNextPage: hasNextPage == _undefined
            ? _instance.hasNextPage
            : (hasNextPage as bool?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeSocial$Page$pageInfo<TRes>
    implements CopyWith$Query$GetAnimeSocial$Page$pageInfo<TRes> {
  _CopyWithStubImpl$Query$GetAnimeSocial$Page$pageInfo(this._res);

  TRes _res;

  call({
    int? total,
    int? perPage,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeSocial$Page$mediaList {
  Query$GetAnimeSocial$Page$mediaList({
    required this.id,
    this.status,
    this.score,
    this.updatedAt,
    this.user,
    this.$__typename = 'MediaList',
  });

  factory Query$GetAnimeSocial$Page$mediaList.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$status = json['status'];
    final l$score = json['score'];
    final l$updatedAt = json['updatedAt'];
    final l$user = json['user'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeSocial$Page$mediaList(
      id: (l$id as int),
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      score: (l$score as num?)?.toDouble(),
      updatedAt: (l$updatedAt as int?),
      user: l$user == null
          ? null
          : Fragment$UserAvatar.fromJson((l$user as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Enum$MediaListStatus? status;

  final double? score;

  final int? updatedAt;

  final Fragment$UserAvatar? user;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$score = score;
    _resultData['score'] = l$score;
    final l$updatedAt = updatedAt;
    _resultData['updatedAt'] = l$updatedAt;
    final l$user = user;
    _resultData['user'] = l$user?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$status = status;
    final l$score = score;
    final l$updatedAt = updatedAt;
    final l$user = user;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$status,
      l$score,
      l$updatedAt,
      l$user,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeSocial$Page$mediaList ||
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
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
      return false;
    }
    final l$updatedAt = updatedAt;
    final lOther$updatedAt = other.updatedAt;
    if (l$updatedAt != lOther$updatedAt) {
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

extension UtilityExtension$Query$GetAnimeSocial$Page$mediaList
    on Query$GetAnimeSocial$Page$mediaList {
  CopyWith$Query$GetAnimeSocial$Page$mediaList<
          Query$GetAnimeSocial$Page$mediaList>
      get copyWith => CopyWith$Query$GetAnimeSocial$Page$mediaList(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeSocial$Page$mediaList<TRes> {
  factory CopyWith$Query$GetAnimeSocial$Page$mediaList(
    Query$GetAnimeSocial$Page$mediaList instance,
    TRes Function(Query$GetAnimeSocial$Page$mediaList) then,
  ) = _CopyWithImpl$Query$GetAnimeSocial$Page$mediaList;

  factory CopyWith$Query$GetAnimeSocial$Page$mediaList.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeSocial$Page$mediaList;

  TRes call({
    int? id,
    Enum$MediaListStatus? status,
    double? score,
    int? updatedAt,
    Fragment$UserAvatar? user,
    String? $__typename,
  });
  CopyWith$Fragment$UserAvatar<TRes> get user;
}

class _CopyWithImpl$Query$GetAnimeSocial$Page$mediaList<TRes>
    implements CopyWith$Query$GetAnimeSocial$Page$mediaList<TRes> {
  _CopyWithImpl$Query$GetAnimeSocial$Page$mediaList(
    this._instance,
    this._then,
  );

  final Query$GetAnimeSocial$Page$mediaList _instance;

  final TRes Function(Query$GetAnimeSocial$Page$mediaList) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? status = _undefined,
    Object? score = _undefined,
    Object? updatedAt = _undefined,
    Object? user = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeSocial$Page$mediaList(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        score: score == _undefined ? _instance.score : (score as double?),
        updatedAt:
            updatedAt == _undefined ? _instance.updatedAt : (updatedAt as int?),
        user: user == _undefined
            ? _instance.user
            : (user as Fragment$UserAvatar?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$UserAvatar<TRes> get user {
    final local$user = _instance.user;
    return local$user == null
        ? CopyWith$Fragment$UserAvatar.stub(_then(_instance))
        : CopyWith$Fragment$UserAvatar(local$user, (e) => call(user: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeSocial$Page$mediaList<TRes>
    implements CopyWith$Query$GetAnimeSocial$Page$mediaList<TRes> {
  _CopyWithStubImpl$Query$GetAnimeSocial$Page$mediaList(this._res);

  TRes _res;

  call({
    int? id,
    Enum$MediaListStatus? status,
    double? score,
    int? updatedAt,
    Fragment$UserAvatar? user,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$UserAvatar<TRes> get user =>
      CopyWith$Fragment$UserAvatar.stub(_res);
}

class Variables$Query$GetAnimeStats {
  factory Variables$Query$GetAnimeStats({required int id}) =>
      Variables$Query$GetAnimeStats._({
        r'id': id,
      });

  Variables$Query$GetAnimeStats._(this._$data);

  factory Variables$Query$GetAnimeStats.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as int);
    return Variables$Query$GetAnimeStats._(result$data);
  }

  Map<String, dynamic> _$data;

  int get id => (_$data['id'] as int);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$GetAnimeStats<Variables$Query$GetAnimeStats>
      get copyWith => CopyWith$Variables$Query$GetAnimeStats(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$GetAnimeStats ||
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

abstract class CopyWith$Variables$Query$GetAnimeStats<TRes> {
  factory CopyWith$Variables$Query$GetAnimeStats(
    Variables$Query$GetAnimeStats instance,
    TRes Function(Variables$Query$GetAnimeStats) then,
  ) = _CopyWithImpl$Variables$Query$GetAnimeStats;

  factory CopyWith$Variables$Query$GetAnimeStats.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetAnimeStats;

  TRes call({int? id});
}

class _CopyWithImpl$Variables$Query$GetAnimeStats<TRes>
    implements CopyWith$Variables$Query$GetAnimeStats<TRes> {
  _CopyWithImpl$Variables$Query$GetAnimeStats(
    this._instance,
    this._then,
  );

  final Variables$Query$GetAnimeStats _instance;

  final TRes Function(Variables$Query$GetAnimeStats) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) =>
      _then(Variables$Query$GetAnimeStats._({
        ..._instance._$data,
        if (id != _undefined && id != null) 'id': (id as int),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetAnimeStats<TRes>
    implements CopyWith$Variables$Query$GetAnimeStats<TRes> {
  _CopyWithStubImpl$Variables$Query$GetAnimeStats(this._res);

  TRes _res;

  call({int? id}) => _res;
}

class Query$GetAnimeStats {
  Query$GetAnimeStats({
    this.Media,
    this.$__typename = 'Query',
  });

  factory Query$GetAnimeStats.fromJson(Map<String, dynamic> json) {
    final l$Media = json['Media'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats(
      Media: l$Media == null
          ? null
          : Query$GetAnimeStats$Media.fromJson(
              (l$Media as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$GetAnimeStats$Media? Media;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$Media = Media;
    _resultData['Media'] = l$Media?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$Media = Media;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$Media,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStats || runtimeType != other.runtimeType) {
      return false;
    }
    final l$Media = Media;
    final lOther$Media = other.Media;
    if (l$Media != lOther$Media) {
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

extension UtilityExtension$Query$GetAnimeStats on Query$GetAnimeStats {
  CopyWith$Query$GetAnimeStats<Query$GetAnimeStats> get copyWith =>
      CopyWith$Query$GetAnimeStats(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeStats<TRes> {
  factory CopyWith$Query$GetAnimeStats(
    Query$GetAnimeStats instance,
    TRes Function(Query$GetAnimeStats) then,
  ) = _CopyWithImpl$Query$GetAnimeStats;

  factory CopyWith$Query$GetAnimeStats.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats;

  TRes call({
    Query$GetAnimeStats$Media? Media,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeStats$Media<TRes> get Media;
}

class _CopyWithImpl$Query$GetAnimeStats<TRes>
    implements CopyWith$Query$GetAnimeStats<TRes> {
  _CopyWithImpl$Query$GetAnimeStats(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats _instance;

  final TRes Function(Query$GetAnimeStats) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? Media = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats(
        Media: Media == _undefined
            ? _instance.Media
            : (Media as Query$GetAnimeStats$Media?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeStats$Media<TRes> get Media {
    final local$Media = _instance.Media;
    return local$Media == null
        ? CopyWith$Query$GetAnimeStats$Media.stub(_then(_instance))
        : CopyWith$Query$GetAnimeStats$Media(
            local$Media, (e) => call(Media: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeStats<TRes>
    implements CopyWith$Query$GetAnimeStats<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats(this._res);

  TRes _res;

  call({
    Query$GetAnimeStats$Media? Media,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeStats$Media<TRes> get Media =>
      CopyWith$Query$GetAnimeStats$Media.stub(_res);
}

const documentNodeQueryGetAnimeStats = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetAnimeStats'),
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
        name: NameNode(value: 'Media'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'id'),
            value: VariableNode(name: NameNode(value: 'id')),
          ),
          ArgumentNode(
            name: NameNode(value: 'type'),
            value: EnumValueNode(name: NameNode(value: 'ANIME')),
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
            name: NameNode(value: 'stats'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'statusDistribution'),
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
                    name: NameNode(value: 'amount'),
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
                name: NameNode(value: 'scoreDistribution'),
                alias: null,
                arguments: [],
                directives: [],
                selectionSet: SelectionSetNode(selections: [
                  FieldNode(
                    name: NameNode(value: 'score'),
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
            name: NameNode(value: 'trends'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'sort'),
                value: EnumValueNode(name: NameNode(value: 'EPISODE_DESC')),
              ),
              ArgumentNode(
                name: NameNode(value: 'perPage'),
                value: IntValueNode(value: '25'),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(selections: [
              FieldNode(
                name: NameNode(value: 'nodes'),
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
                    name: NameNode(value: 'episode'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'averageScore'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'inProgress'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'trending'),
                    alias: null,
                    arguments: [],
                    directives: [],
                    selectionSet: null,
                  ),
                  FieldNode(
                    name: NameNode(value: 'popularity'),
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
Query$GetAnimeStats _parserFn$Query$GetAnimeStats(Map<String, dynamic> data) =>
    Query$GetAnimeStats.fromJson(data);
typedef OnQueryComplete$Query$GetAnimeStats = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetAnimeStats?,
);

class Options$Query$GetAnimeStats
    extends graphql.QueryOptions<Query$GetAnimeStats> {
  Options$Query$GetAnimeStats({
    String? operationName,
    required Variables$Query$GetAnimeStats variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeStats? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetAnimeStats? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                    data == null ? null : _parserFn$Query$GetAnimeStats(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetAnimeStats,
          parserFn: _parserFn$Query$GetAnimeStats,
        );

  final OnQueryComplete$Query$GetAnimeStats? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetAnimeStats
    extends graphql.WatchQueryOptions<Query$GetAnimeStats> {
  WatchOptions$Query$GetAnimeStats({
    String? operationName,
    required Variables$Query$GetAnimeStats variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetAnimeStats? typedOptimisticResult,
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
          document: documentNodeQueryGetAnimeStats,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetAnimeStats,
        );
}

class FetchMoreOptions$Query$GetAnimeStats extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetAnimeStats({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetAnimeStats variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetAnimeStats,
        );
}

extension ClientExtension$Query$GetAnimeStats on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetAnimeStats>> query$GetAnimeStats(
          Options$Query$GetAnimeStats options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetAnimeStats> watchQuery$GetAnimeStats(
          WatchOptions$Query$GetAnimeStats options) =>
      this.watchQuery(options);
  void writeQuery$GetAnimeStats({
    required Query$GetAnimeStats data,
    required Variables$Query$GetAnimeStats variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetAnimeStats),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetAnimeStats? readQuery$GetAnimeStats({
    required Variables$Query$GetAnimeStats variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetAnimeStats),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetAnimeStats.fromJson(result);
  }
}

class Query$GetAnimeStats$Media {
  Query$GetAnimeStats$Media({
    required this.id,
    this.stats,
    this.trends,
    this.$__typename = 'Media',
  });

  factory Query$GetAnimeStats$Media.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$stats = json['stats'];
    final l$trends = json['trends'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats$Media(
      id: (l$id as int),
      stats: l$stats == null
          ? null
          : Query$GetAnimeStats$Media$stats.fromJson(
              (l$stats as Map<String, dynamic>)),
      trends: l$trends == null
          ? null
          : Query$GetAnimeStats$Media$trends.fromJson(
              (l$trends as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Query$GetAnimeStats$Media$stats? stats;

  final Query$GetAnimeStats$Media$trends? trends;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$stats = stats;
    _resultData['stats'] = l$stats?.toJson();
    final l$trends = trends;
    _resultData['trends'] = l$trends?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$stats = stats;
    final l$trends = trends;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$stats,
      l$trends,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStats$Media ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$stats = stats;
    final lOther$stats = other.stats;
    if (l$stats != lOther$stats) {
      return false;
    }
    final l$trends = trends;
    final lOther$trends = other.trends;
    if (l$trends != lOther$trends) {
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

extension UtilityExtension$Query$GetAnimeStats$Media
    on Query$GetAnimeStats$Media {
  CopyWith$Query$GetAnimeStats$Media<Query$GetAnimeStats$Media> get copyWith =>
      CopyWith$Query$GetAnimeStats$Media(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetAnimeStats$Media<TRes> {
  factory CopyWith$Query$GetAnimeStats$Media(
    Query$GetAnimeStats$Media instance,
    TRes Function(Query$GetAnimeStats$Media) then,
  ) = _CopyWithImpl$Query$GetAnimeStats$Media;

  factory CopyWith$Query$GetAnimeStats$Media.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats$Media;

  TRes call({
    int? id,
    Query$GetAnimeStats$Media$stats? stats,
    Query$GetAnimeStats$Media$trends? trends,
    String? $__typename,
  });
  CopyWith$Query$GetAnimeStats$Media$stats<TRes> get stats;
  CopyWith$Query$GetAnimeStats$Media$trends<TRes> get trends;
}

class _CopyWithImpl$Query$GetAnimeStats$Media<TRes>
    implements CopyWith$Query$GetAnimeStats$Media<TRes> {
  _CopyWithImpl$Query$GetAnimeStats$Media(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats$Media _instance;

  final TRes Function(Query$GetAnimeStats$Media) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? stats = _undefined,
    Object? trends = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats$Media(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        stats: stats == _undefined
            ? _instance.stats
            : (stats as Query$GetAnimeStats$Media$stats?),
        trends: trends == _undefined
            ? _instance.trends
            : (trends as Query$GetAnimeStats$Media$trends?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Query$GetAnimeStats$Media$stats<TRes> get stats {
    final local$stats = _instance.stats;
    return local$stats == null
        ? CopyWith$Query$GetAnimeStats$Media$stats.stub(_then(_instance))
        : CopyWith$Query$GetAnimeStats$Media$stats(
            local$stats, (e) => call(stats: e));
  }

  CopyWith$Query$GetAnimeStats$Media$trends<TRes> get trends {
    final local$trends = _instance.trends;
    return local$trends == null
        ? CopyWith$Query$GetAnimeStats$Media$trends.stub(_then(_instance))
        : CopyWith$Query$GetAnimeStats$Media$trends(
            local$trends, (e) => call(trends: e));
  }
}

class _CopyWithStubImpl$Query$GetAnimeStats$Media<TRes>
    implements CopyWith$Query$GetAnimeStats$Media<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats$Media(this._res);

  TRes _res;

  call({
    int? id,
    Query$GetAnimeStats$Media$stats? stats,
    Query$GetAnimeStats$Media$trends? trends,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Query$GetAnimeStats$Media$stats<TRes> get stats =>
      CopyWith$Query$GetAnimeStats$Media$stats.stub(_res);

  CopyWith$Query$GetAnimeStats$Media$trends<TRes> get trends =>
      CopyWith$Query$GetAnimeStats$Media$trends.stub(_res);
}

class Query$GetAnimeStats$Media$stats {
  Query$GetAnimeStats$Media$stats({
    this.statusDistribution,
    this.scoreDistribution,
    this.$__typename = 'MediaStats',
  });

  factory Query$GetAnimeStats$Media$stats.fromJson(Map<String, dynamic> json) {
    final l$statusDistribution = json['statusDistribution'];
    final l$scoreDistribution = json['scoreDistribution'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats$Media$stats(
      statusDistribution: (l$statusDistribution as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeStats$Media$stats$statusDistribution.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      scoreDistribution: (l$scoreDistribution as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeStats$Media$stats$scoreDistribution.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeStats$Media$stats$statusDistribution?>?
      statusDistribution;

  final List<Query$GetAnimeStats$Media$stats$scoreDistribution?>?
      scoreDistribution;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$statusDistribution = statusDistribution;
    _resultData['statusDistribution'] =
        l$statusDistribution?.map((e) => e?.toJson()).toList();
    final l$scoreDistribution = scoreDistribution;
    _resultData['scoreDistribution'] =
        l$scoreDistribution?.map((e) => e?.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$statusDistribution = statusDistribution;
    final l$scoreDistribution = scoreDistribution;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$statusDistribution == null
          ? null
          : Object.hashAll(l$statusDistribution.map((v) => v)),
      l$scoreDistribution == null
          ? null
          : Object.hashAll(l$scoreDistribution.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStats$Media$stats ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$statusDistribution = statusDistribution;
    final lOther$statusDistribution = other.statusDistribution;
    if (l$statusDistribution != null && lOther$statusDistribution != null) {
      if (l$statusDistribution.length != lOther$statusDistribution.length) {
        return false;
      }
      for (int i = 0; i < l$statusDistribution.length; i++) {
        final l$statusDistribution$entry = l$statusDistribution[i];
        final lOther$statusDistribution$entry = lOther$statusDistribution[i];
        if (l$statusDistribution$entry != lOther$statusDistribution$entry) {
          return false;
        }
      }
    } else if (l$statusDistribution != lOther$statusDistribution) {
      return false;
    }
    final l$scoreDistribution = scoreDistribution;
    final lOther$scoreDistribution = other.scoreDistribution;
    if (l$scoreDistribution != null && lOther$scoreDistribution != null) {
      if (l$scoreDistribution.length != lOther$scoreDistribution.length) {
        return false;
      }
      for (int i = 0; i < l$scoreDistribution.length; i++) {
        final l$scoreDistribution$entry = l$scoreDistribution[i];
        final lOther$scoreDistribution$entry = lOther$scoreDistribution[i];
        if (l$scoreDistribution$entry != lOther$scoreDistribution$entry) {
          return false;
        }
      }
    } else if (l$scoreDistribution != lOther$scoreDistribution) {
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

extension UtilityExtension$Query$GetAnimeStats$Media$stats
    on Query$GetAnimeStats$Media$stats {
  CopyWith$Query$GetAnimeStats$Media$stats<Query$GetAnimeStats$Media$stats>
      get copyWith => CopyWith$Query$GetAnimeStats$Media$stats(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStats$Media$stats<TRes> {
  factory CopyWith$Query$GetAnimeStats$Media$stats(
    Query$GetAnimeStats$Media$stats instance,
    TRes Function(Query$GetAnimeStats$Media$stats) then,
  ) = _CopyWithImpl$Query$GetAnimeStats$Media$stats;

  factory CopyWith$Query$GetAnimeStats$Media$stats.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats$Media$stats;

  TRes call({
    List<Query$GetAnimeStats$Media$stats$statusDistribution?>?
        statusDistribution,
    List<Query$GetAnimeStats$Media$stats$scoreDistribution?>? scoreDistribution,
    String? $__typename,
  });
  TRes statusDistribution(
      Iterable<Query$GetAnimeStats$Media$stats$statusDistribution?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution<
                      Query$GetAnimeStats$Media$stats$statusDistribution>?>?)
          _fn);
  TRes scoreDistribution(
      Iterable<Query$GetAnimeStats$Media$stats$scoreDistribution?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution<
                      Query$GetAnimeStats$Media$stats$scoreDistribution>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeStats$Media$stats<TRes>
    implements CopyWith$Query$GetAnimeStats$Media$stats<TRes> {
  _CopyWithImpl$Query$GetAnimeStats$Media$stats(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats$Media$stats _instance;

  final TRes Function(Query$GetAnimeStats$Media$stats) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? statusDistribution = _undefined,
    Object? scoreDistribution = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats$Media$stats(
        statusDistribution: statusDistribution == _undefined
            ? _instance.statusDistribution
            : (statusDistribution
                as List<Query$GetAnimeStats$Media$stats$statusDistribution?>?),
        scoreDistribution: scoreDistribution == _undefined
            ? _instance.scoreDistribution
            : (scoreDistribution
                as List<Query$GetAnimeStats$Media$stats$scoreDistribution?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes statusDistribution(
          Iterable<Query$GetAnimeStats$Media$stats$statusDistribution?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution<
                          Query$GetAnimeStats$Media$stats$statusDistribution>?>?)
              _fn) =>
      call(
          statusDistribution:
              _fn(_instance.statusDistribution?.map((e) => e == null
                  ? null
                  : CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution(
                      e,
                      (i) => i,
                    )))?.toList());

  TRes scoreDistribution(
          Iterable<Query$GetAnimeStats$Media$stats$scoreDistribution?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution<
                          Query$GetAnimeStats$Media$stats$scoreDistribution>?>?)
              _fn) =>
      call(
          scoreDistribution:
              _fn(_instance.scoreDistribution?.map((e) => e == null
                  ? null
                  : CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution(
                      e,
                      (i) => i,
                    )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeStats$Media$stats<TRes>
    implements CopyWith$Query$GetAnimeStats$Media$stats<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats$Media$stats(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeStats$Media$stats$statusDistribution?>?
        statusDistribution,
    List<Query$GetAnimeStats$Media$stats$scoreDistribution?>? scoreDistribution,
    String? $__typename,
  }) =>
      _res;

  statusDistribution(_fn) => _res;

  scoreDistribution(_fn) => _res;
}

class Query$GetAnimeStats$Media$stats$statusDistribution {
  Query$GetAnimeStats$Media$stats$statusDistribution({
    this.status,
    this.amount,
    this.$__typename = 'StatusDistribution',
  });

  factory Query$GetAnimeStats$Media$stats$statusDistribution.fromJson(
      Map<String, dynamic> json) {
    final l$status = json['status'];
    final l$amount = json['amount'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats$Media$stats$statusDistribution(
      status: l$status == null
          ? null
          : fromJson$Enum$MediaListStatus((l$status as String)),
      amount: (l$amount as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final Enum$MediaListStatus? status;

  final int? amount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$status = status;
    _resultData['status'] =
        l$status == null ? null : toJson$Enum$MediaListStatus(l$status);
    final l$amount = amount;
    _resultData['amount'] = l$amount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$status = status;
    final l$amount = amount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$status,
      l$amount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStats$Media$stats$statusDistribution ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$status = status;
    final lOther$status = other.status;
    if (l$status != lOther$status) {
      return false;
    }
    final l$amount = amount;
    final lOther$amount = other.amount;
    if (l$amount != lOther$amount) {
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

extension UtilityExtension$Query$GetAnimeStats$Media$stats$statusDistribution
    on Query$GetAnimeStats$Media$stats$statusDistribution {
  CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution<
          Query$GetAnimeStats$Media$stats$statusDistribution>
      get copyWith =>
          CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution<
    TRes> {
  factory CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution(
    Query$GetAnimeStats$Media$stats$statusDistribution instance,
    TRes Function(Query$GetAnimeStats$Media$stats$statusDistribution) then,
  ) = _CopyWithImpl$Query$GetAnimeStats$Media$stats$statusDistribution;

  factory CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats$Media$stats$statusDistribution;

  TRes call({
    Enum$MediaListStatus? status,
    int? amount,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeStats$Media$stats$statusDistribution<TRes>
    implements
        CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution<TRes> {
  _CopyWithImpl$Query$GetAnimeStats$Media$stats$statusDistribution(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats$Media$stats$statusDistribution _instance;

  final TRes Function(Query$GetAnimeStats$Media$stats$statusDistribution) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? status = _undefined,
    Object? amount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats$Media$stats$statusDistribution(
        status: status == _undefined
            ? _instance.status
            : (status as Enum$MediaListStatus?),
        amount: amount == _undefined ? _instance.amount : (amount as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeStats$Media$stats$statusDistribution<TRes>
    implements
        CopyWith$Query$GetAnimeStats$Media$stats$statusDistribution<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats$Media$stats$statusDistribution(
      this._res);

  TRes _res;

  call({
    Enum$MediaListStatus? status,
    int? amount,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeStats$Media$stats$scoreDistribution {
  Query$GetAnimeStats$Media$stats$scoreDistribution({
    this.score,
    this.amount,
    this.$__typename = 'ScoreDistribution',
  });

  factory Query$GetAnimeStats$Media$stats$scoreDistribution.fromJson(
      Map<String, dynamic> json) {
    final l$score = json['score'];
    final l$amount = json['amount'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats$Media$stats$scoreDistribution(
      score: (l$score as int?),
      amount: (l$amount as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int? score;

  final int? amount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$score = score;
    _resultData['score'] = l$score;
    final l$amount = amount;
    _resultData['amount'] = l$amount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$score = score;
    final l$amount = amount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$score,
      l$amount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStats$Media$stats$scoreDistribution ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$score = score;
    final lOther$score = other.score;
    if (l$score != lOther$score) {
      return false;
    }
    final l$amount = amount;
    final lOther$amount = other.amount;
    if (l$amount != lOther$amount) {
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

extension UtilityExtension$Query$GetAnimeStats$Media$stats$scoreDistribution
    on Query$GetAnimeStats$Media$stats$scoreDistribution {
  CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution<
          Query$GetAnimeStats$Media$stats$scoreDistribution>
      get copyWith =>
          CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution<
    TRes> {
  factory CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution(
    Query$GetAnimeStats$Media$stats$scoreDistribution instance,
    TRes Function(Query$GetAnimeStats$Media$stats$scoreDistribution) then,
  ) = _CopyWithImpl$Query$GetAnimeStats$Media$stats$scoreDistribution;

  factory CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats$Media$stats$scoreDistribution;

  TRes call({
    int? score,
    int? amount,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeStats$Media$stats$scoreDistribution<TRes>
    implements
        CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution<TRes> {
  _CopyWithImpl$Query$GetAnimeStats$Media$stats$scoreDistribution(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats$Media$stats$scoreDistribution _instance;

  final TRes Function(Query$GetAnimeStats$Media$stats$scoreDistribution) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? score = _undefined,
    Object? amount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats$Media$stats$scoreDistribution(
        score: score == _undefined ? _instance.score : (score as int?),
        amount: amount == _undefined ? _instance.amount : (amount as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeStats$Media$stats$scoreDistribution<TRes>
    implements
        CopyWith$Query$GetAnimeStats$Media$stats$scoreDistribution<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats$Media$stats$scoreDistribution(
      this._res);

  TRes _res;

  call({
    int? score,
    int? amount,
    String? $__typename,
  }) =>
      _res;
}

class Query$GetAnimeStats$Media$trends {
  Query$GetAnimeStats$Media$trends({
    this.nodes,
    this.$__typename = 'MediaTrendConnection',
  });

  factory Query$GetAnimeStats$Media$trends.fromJson(Map<String, dynamic> json) {
    final l$nodes = json['nodes'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats$Media$trends(
      nodes: (l$nodes as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Query$GetAnimeStats$Media$trends$nodes.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetAnimeStats$Media$trends$nodes?>? nodes;

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
    if (other is! Query$GetAnimeStats$Media$trends ||
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

extension UtilityExtension$Query$GetAnimeStats$Media$trends
    on Query$GetAnimeStats$Media$trends {
  CopyWith$Query$GetAnimeStats$Media$trends<Query$GetAnimeStats$Media$trends>
      get copyWith => CopyWith$Query$GetAnimeStats$Media$trends(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStats$Media$trends<TRes> {
  factory CopyWith$Query$GetAnimeStats$Media$trends(
    Query$GetAnimeStats$Media$trends instance,
    TRes Function(Query$GetAnimeStats$Media$trends) then,
  ) = _CopyWithImpl$Query$GetAnimeStats$Media$trends;

  factory CopyWith$Query$GetAnimeStats$Media$trends.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats$Media$trends;

  TRes call({
    List<Query$GetAnimeStats$Media$trends$nodes?>? nodes,
    String? $__typename,
  });
  TRes nodes(
      Iterable<Query$GetAnimeStats$Media$trends$nodes?>? Function(
              Iterable<
                  CopyWith$Query$GetAnimeStats$Media$trends$nodes<
                      Query$GetAnimeStats$Media$trends$nodes>?>?)
          _fn);
}

class _CopyWithImpl$Query$GetAnimeStats$Media$trends<TRes>
    implements CopyWith$Query$GetAnimeStats$Media$trends<TRes> {
  _CopyWithImpl$Query$GetAnimeStats$Media$trends(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats$Media$trends _instance;

  final TRes Function(Query$GetAnimeStats$Media$trends) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? nodes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats$Media$trends(
        nodes: nodes == _undefined
            ? _instance.nodes
            : (nodes as List<Query$GetAnimeStats$Media$trends$nodes?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes nodes(
          Iterable<Query$GetAnimeStats$Media$trends$nodes?>? Function(
                  Iterable<
                      CopyWith$Query$GetAnimeStats$Media$trends$nodes<
                          Query$GetAnimeStats$Media$trends$nodes>?>?)
              _fn) =>
      call(
          nodes: _fn(_instance.nodes?.map((e) => e == null
              ? null
              : CopyWith$Query$GetAnimeStats$Media$trends$nodes(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Query$GetAnimeStats$Media$trends<TRes>
    implements CopyWith$Query$GetAnimeStats$Media$trends<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats$Media$trends(this._res);

  TRes _res;

  call({
    List<Query$GetAnimeStats$Media$trends$nodes?>? nodes,
    String? $__typename,
  }) =>
      _res;

  nodes(_fn) => _res;
}

class Query$GetAnimeStats$Media$trends$nodes {
  Query$GetAnimeStats$Media$trends$nodes({
    required this.date,
    this.episode,
    this.averageScore,
    this.inProgress,
    required this.trending,
    this.popularity,
    this.$__typename = 'MediaTrend',
  });

  factory Query$GetAnimeStats$Media$trends$nodes.fromJson(
      Map<String, dynamic> json) {
    final l$date = json['date'];
    final l$episode = json['episode'];
    final l$averageScore = json['averageScore'];
    final l$inProgress = json['inProgress'];
    final l$trending = json['trending'];
    final l$popularity = json['popularity'];
    final l$$__typename = json['__typename'];
    return Query$GetAnimeStats$Media$trends$nodes(
      date: (l$date as int),
      episode: (l$episode as int?),
      averageScore: (l$averageScore as int?),
      inProgress: (l$inProgress as int?),
      trending: (l$trending as int),
      popularity: (l$popularity as int?),
      $__typename: (l$$__typename as String),
    );
  }

  final int date;

  final int? episode;

  final int? averageScore;

  final int? inProgress;

  final int trending;

  final int? popularity;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$date = date;
    _resultData['date'] = l$date;
    final l$episode = episode;
    _resultData['episode'] = l$episode;
    final l$averageScore = averageScore;
    _resultData['averageScore'] = l$averageScore;
    final l$inProgress = inProgress;
    _resultData['inProgress'] = l$inProgress;
    final l$trending = trending;
    _resultData['trending'] = l$trending;
    final l$popularity = popularity;
    _resultData['popularity'] = l$popularity;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$date = date;
    final l$episode = episode;
    final l$averageScore = averageScore;
    final l$inProgress = inProgress;
    final l$trending = trending;
    final l$popularity = popularity;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$date,
      l$episode,
      l$averageScore,
      l$inProgress,
      l$trending,
      l$popularity,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$GetAnimeStats$Media$trends$nodes ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    final l$episode = episode;
    final lOther$episode = other.episode;
    if (l$episode != lOther$episode) {
      return false;
    }
    final l$averageScore = averageScore;
    final lOther$averageScore = other.averageScore;
    if (l$averageScore != lOther$averageScore) {
      return false;
    }
    final l$inProgress = inProgress;
    final lOther$inProgress = other.inProgress;
    if (l$inProgress != lOther$inProgress) {
      return false;
    }
    final l$trending = trending;
    final lOther$trending = other.trending;
    if (l$trending != lOther$trending) {
      return false;
    }
    final l$popularity = popularity;
    final lOther$popularity = other.popularity;
    if (l$popularity != lOther$popularity) {
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

extension UtilityExtension$Query$GetAnimeStats$Media$trends$nodes
    on Query$GetAnimeStats$Media$trends$nodes {
  CopyWith$Query$GetAnimeStats$Media$trends$nodes<
          Query$GetAnimeStats$Media$trends$nodes>
      get copyWith => CopyWith$Query$GetAnimeStats$Media$trends$nodes(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetAnimeStats$Media$trends$nodes<TRes> {
  factory CopyWith$Query$GetAnimeStats$Media$trends$nodes(
    Query$GetAnimeStats$Media$trends$nodes instance,
    TRes Function(Query$GetAnimeStats$Media$trends$nodes) then,
  ) = _CopyWithImpl$Query$GetAnimeStats$Media$trends$nodes;

  factory CopyWith$Query$GetAnimeStats$Media$trends$nodes.stub(TRes res) =
      _CopyWithStubImpl$Query$GetAnimeStats$Media$trends$nodes;

  TRes call({
    int? date,
    int? episode,
    int? averageScore,
    int? inProgress,
    int? trending,
    int? popularity,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetAnimeStats$Media$trends$nodes<TRes>
    implements CopyWith$Query$GetAnimeStats$Media$trends$nodes<TRes> {
  _CopyWithImpl$Query$GetAnimeStats$Media$trends$nodes(
    this._instance,
    this._then,
  );

  final Query$GetAnimeStats$Media$trends$nodes _instance;

  final TRes Function(Query$GetAnimeStats$Media$trends$nodes) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? date = _undefined,
    Object? episode = _undefined,
    Object? averageScore = _undefined,
    Object? inProgress = _undefined,
    Object? trending = _undefined,
    Object? popularity = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetAnimeStats$Media$trends$nodes(
        date:
            date == _undefined || date == null ? _instance.date : (date as int),
        episode: episode == _undefined ? _instance.episode : (episode as int?),
        averageScore: averageScore == _undefined
            ? _instance.averageScore
            : (averageScore as int?),
        inProgress: inProgress == _undefined
            ? _instance.inProgress
            : (inProgress as int?),
        trending: trending == _undefined || trending == null
            ? _instance.trending
            : (trending as int),
        popularity: popularity == _undefined
            ? _instance.popularity
            : (popularity as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetAnimeStats$Media$trends$nodes<TRes>
    implements CopyWith$Query$GetAnimeStats$Media$trends$nodes<TRes> {
  _CopyWithStubImpl$Query$GetAnimeStats$Media$trends$nodes(this._res);

  TRes _res;

  call({
    int? date,
    int? episode,
    int? averageScore,
    int? inProgress,
    int? trending,
    int? popularity,
    String? $__typename,
  }) =>
      _res;
}
