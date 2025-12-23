import '../schema.graphql.dart';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$AnimeCard {
  Fragment$AnimeCard({
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
  });

  factory Fragment$AnimeCard.fromJson(Map<String, dynamic> json) {
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
    return Fragment$AnimeCard(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Fragment$AnimeCard$title.fromJson(
              (l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Fragment$AnimeCard$coverImage.fromJson(
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
          : Fragment$AnimeCard$nextAiringEpisode.fromJson(
              (l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Fragment$AnimeCard$startDate.fromJson(
              (l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Fragment$AnimeCard$title? title;

  final Fragment$AnimeCard$coverImage? coverImage;

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

  final Fragment$AnimeCard$nextAiringEpisode? nextAiringEpisode;

  final Fragment$AnimeCard$startDate? startDate;

  final List<String?>? genres;

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
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$AnimeCard || runtimeType != other.runtimeType) {
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
    return true;
  }
}

extension UtilityExtension$Fragment$AnimeCard on Fragment$AnimeCard {
  CopyWith$Fragment$AnimeCard<Fragment$AnimeCard> get copyWith =>
      CopyWith$Fragment$AnimeCard(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$AnimeCard<TRes> {
  factory CopyWith$Fragment$AnimeCard(
    Fragment$AnimeCard instance,
    TRes Function(Fragment$AnimeCard) then,
  ) = _CopyWithImpl$Fragment$AnimeCard;

  factory CopyWith$Fragment$AnimeCard.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeCard;

  TRes call({
    int? id,
    Fragment$AnimeCard$title? title,
    Fragment$AnimeCard$coverImage? coverImage,
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
    Fragment$AnimeCard$nextAiringEpisode? nextAiringEpisode,
    Fragment$AnimeCard$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
  });
  CopyWith$Fragment$AnimeCard$title<TRes> get title;
  CopyWith$Fragment$AnimeCard$coverImage<TRes> get coverImage;
  CopyWith$Fragment$AnimeCard$nextAiringEpisode<TRes> get nextAiringEpisode;
  CopyWith$Fragment$AnimeCard$startDate<TRes> get startDate;
}

class _CopyWithImpl$Fragment$AnimeCard<TRes>
    implements CopyWith$Fragment$AnimeCard<TRes> {
  _CopyWithImpl$Fragment$AnimeCard(
    this._instance,
    this._then,
  );

  final Fragment$AnimeCard _instance;

  final TRes Function(Fragment$AnimeCard) _then;

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
  }) =>
      _then(Fragment$AnimeCard(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title as Fragment$AnimeCard$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage as Fragment$AnimeCard$coverImage?),
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
            : (nextAiringEpisode as Fragment$AnimeCard$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate as Fragment$AnimeCard$startDate?),
        genres: genres == _undefined
            ? _instance.genres
            : (genres as List<String?>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$AnimeCard$title<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Fragment$AnimeCard$title.stub(_then(_instance))
        : CopyWith$Fragment$AnimeCard$title(local$title, (e) => call(title: e));
  }

  CopyWith$Fragment$AnimeCard$coverImage<TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Fragment$AnimeCard$coverImage.stub(_then(_instance))
        : CopyWith$Fragment$AnimeCard$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Fragment$AnimeCard$nextAiringEpisode<TRes> get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Fragment$AnimeCard$nextAiringEpisode.stub(_then(_instance))
        : CopyWith$Fragment$AnimeCard$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Fragment$AnimeCard$startDate<TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Fragment$AnimeCard$startDate.stub(_then(_instance))
        : CopyWith$Fragment$AnimeCard$startDate(
            local$startDate, (e) => call(startDate: e));
  }
}

class _CopyWithStubImpl$Fragment$AnimeCard<TRes>
    implements CopyWith$Fragment$AnimeCard<TRes> {
  _CopyWithStubImpl$Fragment$AnimeCard(this._res);

  TRes _res;

  call({
    int? id,
    Fragment$AnimeCard$title? title,
    Fragment$AnimeCard$coverImage? coverImage,
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
    Fragment$AnimeCard$nextAiringEpisode? nextAiringEpisode,
    Fragment$AnimeCard$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$AnimeCard$title<TRes> get title =>
      CopyWith$Fragment$AnimeCard$title.stub(_res);

  CopyWith$Fragment$AnimeCard$coverImage<TRes> get coverImage =>
      CopyWith$Fragment$AnimeCard$coverImage.stub(_res);

  CopyWith$Fragment$AnimeCard$nextAiringEpisode<TRes> get nextAiringEpisode =>
      CopyWith$Fragment$AnimeCard$nextAiringEpisode.stub(_res);

  CopyWith$Fragment$AnimeCard$startDate<TRes> get startDate =>
      CopyWith$Fragment$AnimeCard$startDate.stub(_res);
}

const fragmentDefinitionAnimeCard = FragmentDefinitionNode(
  name: NameNode(value: 'AnimeCard'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Media'),
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
      name: NameNode(value: 'title'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'userPreferred'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
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
          name: NameNode(value: 'extraLarge'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'large'),
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
      name: NameNode(value: 'status'),
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
      name: NameNode(value: 'episodes'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'seasonYear'),
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
      name: NameNode(value: 'averageScore'),
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
      name: NameNode(value: 'popularity'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'isAdult'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'isFavourite'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'nextAiringEpisode'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'airingAt'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'timeUntilAiring'),
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
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    FieldNode(
      name: NameNode(value: 'startDate'),
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
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentAnimeCard = DocumentNode(definitions: [
  fragmentDefinitionAnimeCard,
]);

extension ClientExtension$Fragment$AnimeCard on graphql.GraphQLClient {
  void writeFragment$AnimeCard({
    required Fragment$AnimeCard data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'AnimeCard',
            document: documentNodeFragmentAnimeCard,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$AnimeCard? readFragment$AnimeCard({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'AnimeCard',
          document: documentNodeFragmentAnimeCard,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$AnimeCard.fromJson(result);
  }
}

class Fragment$AnimeCard$title {
  Fragment$AnimeCard$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Fragment$AnimeCard$title.fromJson(Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeCard$title(
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
    if (other is! Fragment$AnimeCard$title ||
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

extension UtilityExtension$Fragment$AnimeCard$title
    on Fragment$AnimeCard$title {
  CopyWith$Fragment$AnimeCard$title<Fragment$AnimeCard$title> get copyWith =>
      CopyWith$Fragment$AnimeCard$title(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$AnimeCard$title<TRes> {
  factory CopyWith$Fragment$AnimeCard$title(
    Fragment$AnimeCard$title instance,
    TRes Function(Fragment$AnimeCard$title) then,
  ) = _CopyWithImpl$Fragment$AnimeCard$title;

  factory CopyWith$Fragment$AnimeCard$title.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeCard$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeCard$title<TRes>
    implements CopyWith$Fragment$AnimeCard$title<TRes> {
  _CopyWithImpl$Fragment$AnimeCard$title(
    this._instance,
    this._then,
  );

  final Fragment$AnimeCard$title _instance;

  final TRes Function(Fragment$AnimeCard$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeCard$title(
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

class _CopyWithStubImpl$Fragment$AnimeCard$title<TRes>
    implements CopyWith$Fragment$AnimeCard$title<TRes> {
  _CopyWithStubImpl$Fragment$AnimeCard$title(this._res);

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

class Fragment$AnimeCard$coverImage {
  Fragment$AnimeCard$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Fragment$AnimeCard$coverImage.fromJson(Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeCard$coverImage(
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
    if (other is! Fragment$AnimeCard$coverImage ||
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

extension UtilityExtension$Fragment$AnimeCard$coverImage
    on Fragment$AnimeCard$coverImage {
  CopyWith$Fragment$AnimeCard$coverImage<Fragment$AnimeCard$coverImage>
      get copyWith => CopyWith$Fragment$AnimeCard$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeCard$coverImage<TRes> {
  factory CopyWith$Fragment$AnimeCard$coverImage(
    Fragment$AnimeCard$coverImage instance,
    TRes Function(Fragment$AnimeCard$coverImage) then,
  ) = _CopyWithImpl$Fragment$AnimeCard$coverImage;

  factory CopyWith$Fragment$AnimeCard$coverImage.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeCard$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeCard$coverImage<TRes>
    implements CopyWith$Fragment$AnimeCard$coverImage<TRes> {
  _CopyWithImpl$Fragment$AnimeCard$coverImage(
    this._instance,
    this._then,
  );

  final Fragment$AnimeCard$coverImage _instance;

  final TRes Function(Fragment$AnimeCard$coverImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeCard$coverImage(
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

class _CopyWithStubImpl$Fragment$AnimeCard$coverImage<TRes>
    implements CopyWith$Fragment$AnimeCard$coverImage<TRes> {
  _CopyWithStubImpl$Fragment$AnimeCard$coverImage(this._res);

  TRes _res;

  call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeCard$nextAiringEpisode {
  Fragment$AnimeCard$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Fragment$AnimeCard$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeCard$nextAiringEpisode(
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
    if (other is! Fragment$AnimeCard$nextAiringEpisode ||
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

extension UtilityExtension$Fragment$AnimeCard$nextAiringEpisode
    on Fragment$AnimeCard$nextAiringEpisode {
  CopyWith$Fragment$AnimeCard$nextAiringEpisode<
          Fragment$AnimeCard$nextAiringEpisode>
      get copyWith => CopyWith$Fragment$AnimeCard$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeCard$nextAiringEpisode<TRes> {
  factory CopyWith$Fragment$AnimeCard$nextAiringEpisode(
    Fragment$AnimeCard$nextAiringEpisode instance,
    TRes Function(Fragment$AnimeCard$nextAiringEpisode) then,
  ) = _CopyWithImpl$Fragment$AnimeCard$nextAiringEpisode;

  factory CopyWith$Fragment$AnimeCard$nextAiringEpisode.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeCard$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeCard$nextAiringEpisode<TRes>
    implements CopyWith$Fragment$AnimeCard$nextAiringEpisode<TRes> {
  _CopyWithImpl$Fragment$AnimeCard$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Fragment$AnimeCard$nextAiringEpisode _instance;

  final TRes Function(Fragment$AnimeCard$nextAiringEpisode) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeCard$nextAiringEpisode(
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

class _CopyWithStubImpl$Fragment$AnimeCard$nextAiringEpisode<TRes>
    implements CopyWith$Fragment$AnimeCard$nextAiringEpisode<TRes> {
  _CopyWithStubImpl$Fragment$AnimeCard$nextAiringEpisode(this._res);

  TRes _res;

  call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeCard$startDate {
  Fragment$AnimeCard$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Fragment$AnimeCard$startDate.fromJson(Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeCard$startDate(
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
    if (other is! Fragment$AnimeCard$startDate ||
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

extension UtilityExtension$Fragment$AnimeCard$startDate
    on Fragment$AnimeCard$startDate {
  CopyWith$Fragment$AnimeCard$startDate<Fragment$AnimeCard$startDate>
      get copyWith => CopyWith$Fragment$AnimeCard$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeCard$startDate<TRes> {
  factory CopyWith$Fragment$AnimeCard$startDate(
    Fragment$AnimeCard$startDate instance,
    TRes Function(Fragment$AnimeCard$startDate) then,
  ) = _CopyWithImpl$Fragment$AnimeCard$startDate;

  factory CopyWith$Fragment$AnimeCard$startDate.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeCard$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeCard$startDate<TRes>
    implements CopyWith$Fragment$AnimeCard$startDate<TRes> {
  _CopyWithImpl$Fragment$AnimeCard$startDate(
    this._instance,
    this._then,
  );

  final Fragment$AnimeCard$startDate _instance;

  final TRes Function(Fragment$AnimeCard$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeCard$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$AnimeCard$startDate<TRes>
    implements CopyWith$Fragment$AnimeCard$startDate<TRes> {
  _CopyWithStubImpl$Fragment$AnimeCard$startDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeOverview implements Fragment$AnimeCard {
  Fragment$AnimeOverview({
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

  factory Fragment$AnimeOverview.fromJson(Map<String, dynamic> json) {
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
    return Fragment$AnimeOverview(
      id: (l$id as int),
      title: l$title == null
          ? null
          : Fragment$AnimeOverview$title.fromJson(
              (l$title as Map<String, dynamic>)),
      coverImage: l$coverImage == null
          ? null
          : Fragment$AnimeOverview$coverImage.fromJson(
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
          : Fragment$AnimeOverview$nextAiringEpisode.fromJson(
              (l$nextAiringEpisode as Map<String, dynamic>)),
      startDate: l$startDate == null
          ? null
          : Fragment$AnimeOverview$startDate.fromJson(
              (l$startDate as Map<String, dynamic>)),
      genres: (l$genres as List<dynamic>?)?.map((e) => (e as String?)).toList(),
      $__typename: (l$$__typename as String),
      bannerImage: (l$bannerImage as String?),
      description: (l$description as String?),
      endDate: l$endDate == null
          ? null
          : Fragment$AnimeOverview$endDate.fromJson(
              (l$endDate as Map<String, dynamic>)),
      trending: (l$trending as int?),
      favourites: (l$favourites as int?),
      updatedAt: (l$updatedAt as int?),
      siteUrl: (l$siteUrl as String?),
      rankings: (l$rankings as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : Fragment$AnimeOverview$rankings.fromJson(
                  (e as Map<String, dynamic>)))
          .toList(),
    );
  }

  final int id;

  final Fragment$AnimeOverview$title? title;

  final Fragment$AnimeOverview$coverImage? coverImage;

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

  final Fragment$AnimeOverview$nextAiringEpisode? nextAiringEpisode;

  final Fragment$AnimeOverview$startDate? startDate;

  final List<String?>? genres;

  final String $__typename;

  final String? bannerImage;

  final String? description;

  final Fragment$AnimeOverview$endDate? endDate;

  final int? trending;

  final int? favourites;

  final int? updatedAt;

  final String? siteUrl;

  final List<Fragment$AnimeOverview$rankings?>? rankings;

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
    if (other is! Fragment$AnimeOverview || runtimeType != other.runtimeType) {
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

extension UtilityExtension$Fragment$AnimeOverview on Fragment$AnimeOverview {
  CopyWith$Fragment$AnimeOverview<Fragment$AnimeOverview> get copyWith =>
      CopyWith$Fragment$AnimeOverview(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$AnimeOverview<TRes> {
  factory CopyWith$Fragment$AnimeOverview(
    Fragment$AnimeOverview instance,
    TRes Function(Fragment$AnimeOverview) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview;

  factory CopyWith$Fragment$AnimeOverview.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview;

  TRes call({
    int? id,
    Fragment$AnimeOverview$title? title,
    Fragment$AnimeOverview$coverImage? coverImage,
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
    Fragment$AnimeOverview$nextAiringEpisode? nextAiringEpisode,
    Fragment$AnimeOverview$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Fragment$AnimeOverview$endDate? endDate,
    int? trending,
    int? favourites,
    int? updatedAt,
    String? siteUrl,
    List<Fragment$AnimeOverview$rankings?>? rankings,
  });
  CopyWith$Fragment$AnimeOverview$title<TRes> get title;
  CopyWith$Fragment$AnimeOverview$coverImage<TRes> get coverImage;
  CopyWith$Fragment$AnimeOverview$nextAiringEpisode<TRes> get nextAiringEpisode;
  CopyWith$Fragment$AnimeOverview$startDate<TRes> get startDate;
  CopyWith$Fragment$AnimeOverview$endDate<TRes> get endDate;
  TRes rankings(
      Iterable<Fragment$AnimeOverview$rankings?>? Function(
              Iterable<
                  CopyWith$Fragment$AnimeOverview$rankings<
                      Fragment$AnimeOverview$rankings>?>?)
          _fn);
}

class _CopyWithImpl$Fragment$AnimeOverview<TRes>
    implements CopyWith$Fragment$AnimeOverview<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview _instance;

  final TRes Function(Fragment$AnimeOverview) _then;

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
      _then(Fragment$AnimeOverview(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        title: title == _undefined
            ? _instance.title
            : (title as Fragment$AnimeOverview$title?),
        coverImage: coverImage == _undefined
            ? _instance.coverImage
            : (coverImage as Fragment$AnimeOverview$coverImage?),
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
            : (nextAiringEpisode as Fragment$AnimeOverview$nextAiringEpisode?),
        startDate: startDate == _undefined
            ? _instance.startDate
            : (startDate as Fragment$AnimeOverview$startDate?),
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
            : (endDate as Fragment$AnimeOverview$endDate?),
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
            : (rankings as List<Fragment$AnimeOverview$rankings?>?),
      ));

  CopyWith$Fragment$AnimeOverview$title<TRes> get title {
    final local$title = _instance.title;
    return local$title == null
        ? CopyWith$Fragment$AnimeOverview$title.stub(_then(_instance))
        : CopyWith$Fragment$AnimeOverview$title(
            local$title, (e) => call(title: e));
  }

  CopyWith$Fragment$AnimeOverview$coverImage<TRes> get coverImage {
    final local$coverImage = _instance.coverImage;
    return local$coverImage == null
        ? CopyWith$Fragment$AnimeOverview$coverImage.stub(_then(_instance))
        : CopyWith$Fragment$AnimeOverview$coverImage(
            local$coverImage, (e) => call(coverImage: e));
  }

  CopyWith$Fragment$AnimeOverview$nextAiringEpisode<TRes>
      get nextAiringEpisode {
    final local$nextAiringEpisode = _instance.nextAiringEpisode;
    return local$nextAiringEpisode == null
        ? CopyWith$Fragment$AnimeOverview$nextAiringEpisode.stub(
            _then(_instance))
        : CopyWith$Fragment$AnimeOverview$nextAiringEpisode(
            local$nextAiringEpisode, (e) => call(nextAiringEpisode: e));
  }

  CopyWith$Fragment$AnimeOverview$startDate<TRes> get startDate {
    final local$startDate = _instance.startDate;
    return local$startDate == null
        ? CopyWith$Fragment$AnimeOverview$startDate.stub(_then(_instance))
        : CopyWith$Fragment$AnimeOverview$startDate(
            local$startDate, (e) => call(startDate: e));
  }

  CopyWith$Fragment$AnimeOverview$endDate<TRes> get endDate {
    final local$endDate = _instance.endDate;
    return local$endDate == null
        ? CopyWith$Fragment$AnimeOverview$endDate.stub(_then(_instance))
        : CopyWith$Fragment$AnimeOverview$endDate(
            local$endDate, (e) => call(endDate: e));
  }

  TRes rankings(
          Iterable<Fragment$AnimeOverview$rankings?>? Function(
                  Iterable<
                      CopyWith$Fragment$AnimeOverview$rankings<
                          Fragment$AnimeOverview$rankings>?>?)
              _fn) =>
      call(
          rankings: _fn(_instance.rankings?.map((e) => e == null
              ? null
              : CopyWith$Fragment$AnimeOverview$rankings(
                  e,
                  (i) => i,
                )))?.toList());
}

class _CopyWithStubImpl$Fragment$AnimeOverview<TRes>
    implements CopyWith$Fragment$AnimeOverview<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview(this._res);

  TRes _res;

  call({
    int? id,
    Fragment$AnimeOverview$title? title,
    Fragment$AnimeOverview$coverImage? coverImage,
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
    Fragment$AnimeOverview$nextAiringEpisode? nextAiringEpisode,
    Fragment$AnimeOverview$startDate? startDate,
    List<String?>? genres,
    String? $__typename,
    String? bannerImage,
    String? description,
    Fragment$AnimeOverview$endDate? endDate,
    int? trending,
    int? favourites,
    int? updatedAt,
    String? siteUrl,
    List<Fragment$AnimeOverview$rankings?>? rankings,
  }) =>
      _res;

  CopyWith$Fragment$AnimeOverview$title<TRes> get title =>
      CopyWith$Fragment$AnimeOverview$title.stub(_res);

  CopyWith$Fragment$AnimeOverview$coverImage<TRes> get coverImage =>
      CopyWith$Fragment$AnimeOverview$coverImage.stub(_res);

  CopyWith$Fragment$AnimeOverview$nextAiringEpisode<TRes>
      get nextAiringEpisode =>
          CopyWith$Fragment$AnimeOverview$nextAiringEpisode.stub(_res);

  CopyWith$Fragment$AnimeOverview$startDate<TRes> get startDate =>
      CopyWith$Fragment$AnimeOverview$startDate.stub(_res);

  CopyWith$Fragment$AnimeOverview$endDate<TRes> get endDate =>
      CopyWith$Fragment$AnimeOverview$endDate.stub(_res);

  rankings(_fn) => _res;
}

const fragmentDefinitionAnimeOverview = FragmentDefinitionNode(
  name: NameNode(value: 'AnimeOverview'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Media'),
    isNonNull: false,
  )),
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
);
const documentNodeFragmentAnimeOverview = DocumentNode(definitions: [
  fragmentDefinitionAnimeOverview,
  fragmentDefinitionAnimeCard,
]);

extension ClientExtension$Fragment$AnimeOverview on graphql.GraphQLClient {
  void writeFragment$AnimeOverview({
    required Fragment$AnimeOverview data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'AnimeOverview',
            document: documentNodeFragmentAnimeOverview,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$AnimeOverview? readFragment$AnimeOverview({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'AnimeOverview',
          document: documentNodeFragmentAnimeOverview,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$AnimeOverview.fromJson(result);
  }
}

class Fragment$AnimeOverview$title implements Fragment$AnimeCard$title {
  Fragment$AnimeOverview$title({
    this.userPreferred,
    this.romaji,
    this.english,
    this.native,
    this.$__typename = 'MediaTitle',
  });

  factory Fragment$AnimeOverview$title.fromJson(Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$romaji = json['romaji'];
    final l$english = json['english'];
    final l$native = json['native'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeOverview$title(
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
    if (other is! Fragment$AnimeOverview$title ||
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

extension UtilityExtension$Fragment$AnimeOverview$title
    on Fragment$AnimeOverview$title {
  CopyWith$Fragment$AnimeOverview$title<Fragment$AnimeOverview$title>
      get copyWith => CopyWith$Fragment$AnimeOverview$title(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeOverview$title<TRes> {
  factory CopyWith$Fragment$AnimeOverview$title(
    Fragment$AnimeOverview$title instance,
    TRes Function(Fragment$AnimeOverview$title) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview$title;

  factory CopyWith$Fragment$AnimeOverview$title.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview$title;

  TRes call({
    String? userPreferred,
    String? romaji,
    String? english,
    String? native,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeOverview$title<TRes>
    implements CopyWith$Fragment$AnimeOverview$title<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview$title(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview$title _instance;

  final TRes Function(Fragment$AnimeOverview$title) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? romaji = _undefined,
    Object? english = _undefined,
    Object? native = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeOverview$title(
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

class _CopyWithStubImpl$Fragment$AnimeOverview$title<TRes>
    implements CopyWith$Fragment$AnimeOverview$title<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview$title(this._res);

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

class Fragment$AnimeOverview$coverImage
    implements Fragment$AnimeCard$coverImage {
  Fragment$AnimeOverview$coverImage({
    this.extraLarge,
    this.large,
    this.color,
    this.$__typename = 'MediaCoverImage',
  });

  factory Fragment$AnimeOverview$coverImage.fromJson(
      Map<String, dynamic> json) {
    final l$extraLarge = json['extraLarge'];
    final l$large = json['large'];
    final l$color = json['color'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeOverview$coverImage(
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
    if (other is! Fragment$AnimeOverview$coverImage ||
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

extension UtilityExtension$Fragment$AnimeOverview$coverImage
    on Fragment$AnimeOverview$coverImage {
  CopyWith$Fragment$AnimeOverview$coverImage<Fragment$AnimeOverview$coverImage>
      get copyWith => CopyWith$Fragment$AnimeOverview$coverImage(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeOverview$coverImage<TRes> {
  factory CopyWith$Fragment$AnimeOverview$coverImage(
    Fragment$AnimeOverview$coverImage instance,
    TRes Function(Fragment$AnimeOverview$coverImage) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview$coverImage;

  factory CopyWith$Fragment$AnimeOverview$coverImage.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview$coverImage;

  TRes call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeOverview$coverImage<TRes>
    implements CopyWith$Fragment$AnimeOverview$coverImage<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview$coverImage(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview$coverImage _instance;

  final TRes Function(Fragment$AnimeOverview$coverImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? extraLarge = _undefined,
    Object? large = _undefined,
    Object? color = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeOverview$coverImage(
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

class _CopyWithStubImpl$Fragment$AnimeOverview$coverImage<TRes>
    implements CopyWith$Fragment$AnimeOverview$coverImage<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview$coverImage(this._res);

  TRes _res;

  call({
    String? extraLarge,
    String? large,
    String? color,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeOverview$nextAiringEpisode
    implements Fragment$AnimeCard$nextAiringEpisode {
  Fragment$AnimeOverview$nextAiringEpisode({
    required this.airingAt,
    required this.timeUntilAiring,
    required this.episode,
    this.$__typename = 'AiringSchedule',
  });

  factory Fragment$AnimeOverview$nextAiringEpisode.fromJson(
      Map<String, dynamic> json) {
    final l$airingAt = json['airingAt'];
    final l$timeUntilAiring = json['timeUntilAiring'];
    final l$episode = json['episode'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeOverview$nextAiringEpisode(
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
    if (other is! Fragment$AnimeOverview$nextAiringEpisode ||
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

extension UtilityExtension$Fragment$AnimeOverview$nextAiringEpisode
    on Fragment$AnimeOverview$nextAiringEpisode {
  CopyWith$Fragment$AnimeOverview$nextAiringEpisode<
          Fragment$AnimeOverview$nextAiringEpisode>
      get copyWith => CopyWith$Fragment$AnimeOverview$nextAiringEpisode(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeOverview$nextAiringEpisode<TRes> {
  factory CopyWith$Fragment$AnimeOverview$nextAiringEpisode(
    Fragment$AnimeOverview$nextAiringEpisode instance,
    TRes Function(Fragment$AnimeOverview$nextAiringEpisode) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview$nextAiringEpisode;

  factory CopyWith$Fragment$AnimeOverview$nextAiringEpisode.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview$nextAiringEpisode;

  TRes call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeOverview$nextAiringEpisode<TRes>
    implements CopyWith$Fragment$AnimeOverview$nextAiringEpisode<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview$nextAiringEpisode(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview$nextAiringEpisode _instance;

  final TRes Function(Fragment$AnimeOverview$nextAiringEpisode) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? airingAt = _undefined,
    Object? timeUntilAiring = _undefined,
    Object? episode = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeOverview$nextAiringEpisode(
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

class _CopyWithStubImpl$Fragment$AnimeOverview$nextAiringEpisode<TRes>
    implements CopyWith$Fragment$AnimeOverview$nextAiringEpisode<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview$nextAiringEpisode(this._res);

  TRes _res;

  call({
    int? airingAt,
    int? timeUntilAiring,
    int? episode,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeOverview$startDate implements Fragment$AnimeCard$startDate {
  Fragment$AnimeOverview$startDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Fragment$AnimeOverview$startDate.fromJson(Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeOverview$startDate(
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
    if (other is! Fragment$AnimeOverview$startDate ||
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

extension UtilityExtension$Fragment$AnimeOverview$startDate
    on Fragment$AnimeOverview$startDate {
  CopyWith$Fragment$AnimeOverview$startDate<Fragment$AnimeOverview$startDate>
      get copyWith => CopyWith$Fragment$AnimeOverview$startDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeOverview$startDate<TRes> {
  factory CopyWith$Fragment$AnimeOverview$startDate(
    Fragment$AnimeOverview$startDate instance,
    TRes Function(Fragment$AnimeOverview$startDate) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview$startDate;

  factory CopyWith$Fragment$AnimeOverview$startDate.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview$startDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeOverview$startDate<TRes>
    implements CopyWith$Fragment$AnimeOverview$startDate<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview$startDate(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview$startDate _instance;

  final TRes Function(Fragment$AnimeOverview$startDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeOverview$startDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$AnimeOverview$startDate<TRes>
    implements CopyWith$Fragment$AnimeOverview$startDate<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview$startDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeOverview$endDate {
  Fragment$AnimeOverview$endDate({
    this.year,
    this.month,
    this.day,
    this.$__typename = 'FuzzyDate',
  });

  factory Fragment$AnimeOverview$endDate.fromJson(Map<String, dynamic> json) {
    final l$year = json['year'];
    final l$month = json['month'];
    final l$day = json['day'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeOverview$endDate(
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
    if (other is! Fragment$AnimeOverview$endDate ||
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

extension UtilityExtension$Fragment$AnimeOverview$endDate
    on Fragment$AnimeOverview$endDate {
  CopyWith$Fragment$AnimeOverview$endDate<Fragment$AnimeOverview$endDate>
      get copyWith => CopyWith$Fragment$AnimeOverview$endDate(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeOverview$endDate<TRes> {
  factory CopyWith$Fragment$AnimeOverview$endDate(
    Fragment$AnimeOverview$endDate instance,
    TRes Function(Fragment$AnimeOverview$endDate) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview$endDate;

  factory CopyWith$Fragment$AnimeOverview$endDate.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview$endDate;

  TRes call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$AnimeOverview$endDate<TRes>
    implements CopyWith$Fragment$AnimeOverview$endDate<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview$endDate(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview$endDate _instance;

  final TRes Function(Fragment$AnimeOverview$endDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? year = _undefined,
    Object? month = _undefined,
    Object? day = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$AnimeOverview$endDate(
        year: year == _undefined ? _instance.year : (year as int?),
        month: month == _undefined ? _instance.month : (month as int?),
        day: day == _undefined ? _instance.day : (day as int?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$AnimeOverview$endDate<TRes>
    implements CopyWith$Fragment$AnimeOverview$endDate<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview$endDate(this._res);

  TRes _res;

  call({
    int? year,
    int? month,
    int? day,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$AnimeOverview$rankings {
  Fragment$AnimeOverview$rankings({
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

  factory Fragment$AnimeOverview$rankings.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$rank = json['rank'];
    final l$type = json['type'];
    final l$format = json['format'];
    final l$year = json['year'];
    final l$season = json['season'];
    final l$allTime = json['allTime'];
    final l$context = json['context'];
    final l$$__typename = json['__typename'];
    return Fragment$AnimeOverview$rankings(
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
    if (other is! Fragment$AnimeOverview$rankings ||
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

extension UtilityExtension$Fragment$AnimeOverview$rankings
    on Fragment$AnimeOverview$rankings {
  CopyWith$Fragment$AnimeOverview$rankings<Fragment$AnimeOverview$rankings>
      get copyWith => CopyWith$Fragment$AnimeOverview$rankings(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$AnimeOverview$rankings<TRes> {
  factory CopyWith$Fragment$AnimeOverview$rankings(
    Fragment$AnimeOverview$rankings instance,
    TRes Function(Fragment$AnimeOverview$rankings) then,
  ) = _CopyWithImpl$Fragment$AnimeOverview$rankings;

  factory CopyWith$Fragment$AnimeOverview$rankings.stub(TRes res) =
      _CopyWithStubImpl$Fragment$AnimeOverview$rankings;

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

class _CopyWithImpl$Fragment$AnimeOverview$rankings<TRes>
    implements CopyWith$Fragment$AnimeOverview$rankings<TRes> {
  _CopyWithImpl$Fragment$AnimeOverview$rankings(
    this._instance,
    this._then,
  );

  final Fragment$AnimeOverview$rankings _instance;

  final TRes Function(Fragment$AnimeOverview$rankings) _then;

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
      _then(Fragment$AnimeOverview$rankings(
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

class _CopyWithStubImpl$Fragment$AnimeOverview$rankings<TRes>
    implements CopyWith$Fragment$AnimeOverview$rankings<TRes> {
  _CopyWithStubImpl$Fragment$AnimeOverview$rankings(this._res);

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

class Fragment$CharacterCard {
  Fragment$CharacterCard({
    required this.id,
    this.name,
    this.image,
    this.$__typename = 'Character',
  });

  factory Fragment$CharacterCard.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image = json['image'];
    final l$$__typename = json['__typename'];
    return Fragment$CharacterCard(
      id: (l$id as int),
      name: l$name == null
          ? null
          : Fragment$CharacterCard$name.fromJson(
              (l$name as Map<String, dynamic>)),
      image: l$image == null
          ? null
          : Fragment$CharacterCard$image.fromJson(
              (l$image as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Fragment$CharacterCard$name? name;

  final Fragment$CharacterCard$image? image;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name?.toJson();
    final l$image = image;
    _resultData['image'] = l$image?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image = image;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$image,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CharacterCard || runtimeType != other.runtimeType) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$CharacterCard on Fragment$CharacterCard {
  CopyWith$Fragment$CharacterCard<Fragment$CharacterCard> get copyWith =>
      CopyWith$Fragment$CharacterCard(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$CharacterCard<TRes> {
  factory CopyWith$Fragment$CharacterCard(
    Fragment$CharacterCard instance,
    TRes Function(Fragment$CharacterCard) then,
  ) = _CopyWithImpl$Fragment$CharacterCard;

  factory CopyWith$Fragment$CharacterCard.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CharacterCard;

  TRes call({
    int? id,
    Fragment$CharacterCard$name? name,
    Fragment$CharacterCard$image? image,
    String? $__typename,
  });
  CopyWith$Fragment$CharacterCard$name<TRes> get name;
  CopyWith$Fragment$CharacterCard$image<TRes> get image;
}

class _CopyWithImpl$Fragment$CharacterCard<TRes>
    implements CopyWith$Fragment$CharacterCard<TRes> {
  _CopyWithImpl$Fragment$CharacterCard(
    this._instance,
    this._then,
  );

  final Fragment$CharacterCard _instance;

  final TRes Function(Fragment$CharacterCard) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CharacterCard(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined
            ? _instance.name
            : (name as Fragment$CharacterCard$name?),
        image: image == _undefined
            ? _instance.image
            : (image as Fragment$CharacterCard$image?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$CharacterCard$name<TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Fragment$CharacterCard$name.stub(_then(_instance))
        : CopyWith$Fragment$CharacterCard$name(
            local$name, (e) => call(name: e));
  }

  CopyWith$Fragment$CharacterCard$image<TRes> get image {
    final local$image = _instance.image;
    return local$image == null
        ? CopyWith$Fragment$CharacterCard$image.stub(_then(_instance))
        : CopyWith$Fragment$CharacterCard$image(
            local$image, (e) => call(image: e));
  }
}

class _CopyWithStubImpl$Fragment$CharacterCard<TRes>
    implements CopyWith$Fragment$CharacterCard<TRes> {
  _CopyWithStubImpl$Fragment$CharacterCard(this._res);

  TRes _res;

  call({
    int? id,
    Fragment$CharacterCard$name? name,
    Fragment$CharacterCard$image? image,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$CharacterCard$name<TRes> get name =>
      CopyWith$Fragment$CharacterCard$name.stub(_res);

  CopyWith$Fragment$CharacterCard$image<TRes> get image =>
      CopyWith$Fragment$CharacterCard$image.stub(_res);
}

const fragmentDefinitionCharacterCard = FragmentDefinitionNode(
  name: NameNode(value: 'CharacterCard'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Character'),
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
      name: NameNode(value: 'name'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'userPreferred'),
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
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentCharacterCard = DocumentNode(definitions: [
  fragmentDefinitionCharacterCard,
]);

extension ClientExtension$Fragment$CharacterCard on graphql.GraphQLClient {
  void writeFragment$CharacterCard({
    required Fragment$CharacterCard data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'CharacterCard',
            document: documentNodeFragmentCharacterCard,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$CharacterCard? readFragment$CharacterCard({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'CharacterCard',
          document: documentNodeFragmentCharacterCard,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$CharacterCard.fromJson(result);
  }
}

class Fragment$CharacterCard$name {
  Fragment$CharacterCard$name({
    this.userPreferred,
    this.$__typename = 'CharacterName',
  });

  factory Fragment$CharacterCard$name.fromJson(Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$$__typename = json['__typename'];
    return Fragment$CharacterCard$name(
      userPreferred: (l$userPreferred as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? userPreferred;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$userPreferred = userPreferred;
    _resultData['userPreferred'] = l$userPreferred;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$userPreferred = userPreferred;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$userPreferred,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$CharacterCard$name ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$userPreferred = userPreferred;
    final lOther$userPreferred = other.userPreferred;
    if (l$userPreferred != lOther$userPreferred) {
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

extension UtilityExtension$Fragment$CharacterCard$name
    on Fragment$CharacterCard$name {
  CopyWith$Fragment$CharacterCard$name<Fragment$CharacterCard$name>
      get copyWith => CopyWith$Fragment$CharacterCard$name(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$CharacterCard$name<TRes> {
  factory CopyWith$Fragment$CharacterCard$name(
    Fragment$CharacterCard$name instance,
    TRes Function(Fragment$CharacterCard$name) then,
  ) = _CopyWithImpl$Fragment$CharacterCard$name;

  factory CopyWith$Fragment$CharacterCard$name.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CharacterCard$name;

  TRes call({
    String? userPreferred,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$CharacterCard$name<TRes>
    implements CopyWith$Fragment$CharacterCard$name<TRes> {
  _CopyWithImpl$Fragment$CharacterCard$name(
    this._instance,
    this._then,
  );

  final Fragment$CharacterCard$name _instance;

  final TRes Function(Fragment$CharacterCard$name) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CharacterCard$name(
        userPreferred: userPreferred == _undefined
            ? _instance.userPreferred
            : (userPreferred as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$CharacterCard$name<TRes>
    implements CopyWith$Fragment$CharacterCard$name<TRes> {
  _CopyWithStubImpl$Fragment$CharacterCard$name(this._res);

  TRes _res;

  call({
    String? userPreferred,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$CharacterCard$image {
  Fragment$CharacterCard$image({
    this.large,
    this.$__typename = 'CharacterImage',
  });

  factory Fragment$CharacterCard$image.fromJson(Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Fragment$CharacterCard$image(
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
    if (other is! Fragment$CharacterCard$image ||
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

extension UtilityExtension$Fragment$CharacterCard$image
    on Fragment$CharacterCard$image {
  CopyWith$Fragment$CharacterCard$image<Fragment$CharacterCard$image>
      get copyWith => CopyWith$Fragment$CharacterCard$image(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$CharacterCard$image<TRes> {
  factory CopyWith$Fragment$CharacterCard$image(
    Fragment$CharacterCard$image instance,
    TRes Function(Fragment$CharacterCard$image) then,
  ) = _CopyWithImpl$Fragment$CharacterCard$image;

  factory CopyWith$Fragment$CharacterCard$image.stub(TRes res) =
      _CopyWithStubImpl$Fragment$CharacterCard$image;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$CharacterCard$image<TRes>
    implements CopyWith$Fragment$CharacterCard$image<TRes> {
  _CopyWithImpl$Fragment$CharacterCard$image(
    this._instance,
    this._then,
  );

  final Fragment$CharacterCard$image _instance;

  final TRes Function(Fragment$CharacterCard$image) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$CharacterCard$image(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$CharacterCard$image<TRes>
    implements CopyWith$Fragment$CharacterCard$image<TRes> {
  _CopyWithStubImpl$Fragment$CharacterCard$image(this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$StaffCard {
  Fragment$StaffCard({
    required this.id,
    this.name,
    this.image,
    this.language,
    this.$__typename = 'Staff',
  });

  factory Fragment$StaffCard.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$image = json['image'];
    final l$language = json['language'];
    final l$$__typename = json['__typename'];
    return Fragment$StaffCard(
      id: (l$id as int),
      name: l$name == null
          ? null
          : Fragment$StaffCard$name.fromJson((l$name as Map<String, dynamic>)),
      image: l$image == null
          ? null
          : Fragment$StaffCard$image.fromJson(
              (l$image as Map<String, dynamic>)),
      language: (l$language as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final Fragment$StaffCard$name? name;

  final Fragment$StaffCard$image? image;

  final String? language;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name?.toJson();
    final l$image = image;
    _resultData['image'] = l$image?.toJson();
    final l$language = language;
    _resultData['language'] = l$language;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$image = image;
    final l$language = language;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$image,
      l$language,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$StaffCard || runtimeType != other.runtimeType) {
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
    final l$language = language;
    final lOther$language = other.language;
    if (l$language != lOther$language) {
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

extension UtilityExtension$Fragment$StaffCard on Fragment$StaffCard {
  CopyWith$Fragment$StaffCard<Fragment$StaffCard> get copyWith =>
      CopyWith$Fragment$StaffCard(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$StaffCard<TRes> {
  factory CopyWith$Fragment$StaffCard(
    Fragment$StaffCard instance,
    TRes Function(Fragment$StaffCard) then,
  ) = _CopyWithImpl$Fragment$StaffCard;

  factory CopyWith$Fragment$StaffCard.stub(TRes res) =
      _CopyWithStubImpl$Fragment$StaffCard;

  TRes call({
    int? id,
    Fragment$StaffCard$name? name,
    Fragment$StaffCard$image? image,
    String? language,
    String? $__typename,
  });
  CopyWith$Fragment$StaffCard$name<TRes> get name;
  CopyWith$Fragment$StaffCard$image<TRes> get image;
}

class _CopyWithImpl$Fragment$StaffCard<TRes>
    implements CopyWith$Fragment$StaffCard<TRes> {
  _CopyWithImpl$Fragment$StaffCard(
    this._instance,
    this._then,
  );

  final Fragment$StaffCard _instance;

  final TRes Function(Fragment$StaffCard) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? image = _undefined,
    Object? language = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$StaffCard(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined
            ? _instance.name
            : (name as Fragment$StaffCard$name?),
        image: image == _undefined
            ? _instance.image
            : (image as Fragment$StaffCard$image?),
        language:
            language == _undefined ? _instance.language : (language as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$StaffCard$name<TRes> get name {
    final local$name = _instance.name;
    return local$name == null
        ? CopyWith$Fragment$StaffCard$name.stub(_then(_instance))
        : CopyWith$Fragment$StaffCard$name(local$name, (e) => call(name: e));
  }

  CopyWith$Fragment$StaffCard$image<TRes> get image {
    final local$image = _instance.image;
    return local$image == null
        ? CopyWith$Fragment$StaffCard$image.stub(_then(_instance))
        : CopyWith$Fragment$StaffCard$image(local$image, (e) => call(image: e));
  }
}

class _CopyWithStubImpl$Fragment$StaffCard<TRes>
    implements CopyWith$Fragment$StaffCard<TRes> {
  _CopyWithStubImpl$Fragment$StaffCard(this._res);

  TRes _res;

  call({
    int? id,
    Fragment$StaffCard$name? name,
    Fragment$StaffCard$image? image,
    String? language,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$StaffCard$name<TRes> get name =>
      CopyWith$Fragment$StaffCard$name.stub(_res);

  CopyWith$Fragment$StaffCard$image<TRes> get image =>
      CopyWith$Fragment$StaffCard$image.stub(_res);
}

const fragmentDefinitionStaffCard = FragmentDefinitionNode(
  name: NameNode(value: 'StaffCard'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Staff'),
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
      name: NameNode(value: 'name'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'userPreferred'),
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
      name: NameNode(value: 'languageV2'),
      alias: NameNode(value: 'language'),
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
);
const documentNodeFragmentStaffCard = DocumentNode(definitions: [
  fragmentDefinitionStaffCard,
]);

extension ClientExtension$Fragment$StaffCard on graphql.GraphQLClient {
  void writeFragment$StaffCard({
    required Fragment$StaffCard data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'StaffCard',
            document: documentNodeFragmentStaffCard,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$StaffCard? readFragment$StaffCard({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'StaffCard',
          document: documentNodeFragmentStaffCard,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$StaffCard.fromJson(result);
  }
}

class Fragment$StaffCard$name {
  Fragment$StaffCard$name({
    this.userPreferred,
    this.$__typename = 'StaffName',
  });

  factory Fragment$StaffCard$name.fromJson(Map<String, dynamic> json) {
    final l$userPreferred = json['userPreferred'];
    final l$$__typename = json['__typename'];
    return Fragment$StaffCard$name(
      userPreferred: (l$userPreferred as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final String? userPreferred;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$userPreferred = userPreferred;
    _resultData['userPreferred'] = l$userPreferred;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$userPreferred = userPreferred;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$userPreferred,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$StaffCard$name || runtimeType != other.runtimeType) {
      return false;
    }
    final l$userPreferred = userPreferred;
    final lOther$userPreferred = other.userPreferred;
    if (l$userPreferred != lOther$userPreferred) {
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

extension UtilityExtension$Fragment$StaffCard$name on Fragment$StaffCard$name {
  CopyWith$Fragment$StaffCard$name<Fragment$StaffCard$name> get copyWith =>
      CopyWith$Fragment$StaffCard$name(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$StaffCard$name<TRes> {
  factory CopyWith$Fragment$StaffCard$name(
    Fragment$StaffCard$name instance,
    TRes Function(Fragment$StaffCard$name) then,
  ) = _CopyWithImpl$Fragment$StaffCard$name;

  factory CopyWith$Fragment$StaffCard$name.stub(TRes res) =
      _CopyWithStubImpl$Fragment$StaffCard$name;

  TRes call({
    String? userPreferred,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$StaffCard$name<TRes>
    implements CopyWith$Fragment$StaffCard$name<TRes> {
  _CopyWithImpl$Fragment$StaffCard$name(
    this._instance,
    this._then,
  );

  final Fragment$StaffCard$name _instance;

  final TRes Function(Fragment$StaffCard$name) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? userPreferred = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$StaffCard$name(
        userPreferred: userPreferred == _undefined
            ? _instance.userPreferred
            : (userPreferred as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$StaffCard$name<TRes>
    implements CopyWith$Fragment$StaffCard$name<TRes> {
  _CopyWithStubImpl$Fragment$StaffCard$name(this._res);

  TRes _res;

  call({
    String? userPreferred,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$StaffCard$image {
  Fragment$StaffCard$image({
    this.large,
    this.$__typename = 'StaffImage',
  });

  factory Fragment$StaffCard$image.fromJson(Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Fragment$StaffCard$image(
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
    if (other is! Fragment$StaffCard$image ||
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

extension UtilityExtension$Fragment$StaffCard$image
    on Fragment$StaffCard$image {
  CopyWith$Fragment$StaffCard$image<Fragment$StaffCard$image> get copyWith =>
      CopyWith$Fragment$StaffCard$image(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$StaffCard$image<TRes> {
  factory CopyWith$Fragment$StaffCard$image(
    Fragment$StaffCard$image instance,
    TRes Function(Fragment$StaffCard$image) then,
  ) = _CopyWithImpl$Fragment$StaffCard$image;

  factory CopyWith$Fragment$StaffCard$image.stub(TRes res) =
      _CopyWithStubImpl$Fragment$StaffCard$image;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$StaffCard$image<TRes>
    implements CopyWith$Fragment$StaffCard$image<TRes> {
  _CopyWithImpl$Fragment$StaffCard$image(
    this._instance,
    this._then,
  );

  final Fragment$StaffCard$image _instance;

  final TRes Function(Fragment$StaffCard$image) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$StaffCard$image(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$StaffCard$image<TRes>
    implements CopyWith$Fragment$StaffCard$image<TRes> {
  _CopyWithStubImpl$Fragment$StaffCard$image(this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$UserAvatar {
  Fragment$UserAvatar({
    required this.id,
    required this.name,
    this.avatar,
    this.donatorTier,
    this.donatorBadge,
    this.$__typename = 'User',
  });

  factory Fragment$UserAvatar.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$avatar = json['avatar'];
    final l$donatorTier = json['donatorTier'];
    final l$donatorBadge = json['donatorBadge'];
    final l$$__typename = json['__typename'];
    return Fragment$UserAvatar(
      id: (l$id as int),
      name: (l$name as String),
      avatar: l$avatar == null
          ? null
          : Fragment$UserAvatar$avatar.fromJson(
              (l$avatar as Map<String, dynamic>)),
      donatorTier: (l$donatorTier as int?),
      donatorBadge: (l$donatorBadge as String?),
      $__typename: (l$$__typename as String),
    );
  }

  final int id;

  final String name;

  final Fragment$UserAvatar$avatar? avatar;

  final int? donatorTier;

  final String? donatorBadge;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$avatar = avatar;
    _resultData['avatar'] = l$avatar?.toJson();
    final l$donatorTier = donatorTier;
    _resultData['donatorTier'] = l$donatorTier;
    final l$donatorBadge = donatorBadge;
    _resultData['donatorBadge'] = l$donatorBadge;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$avatar = avatar;
    final l$donatorTier = donatorTier;
    final l$donatorBadge = donatorBadge;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$avatar,
      l$donatorTier,
      l$donatorBadge,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$UserAvatar || runtimeType != other.runtimeType) {
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$UserAvatar on Fragment$UserAvatar {
  CopyWith$Fragment$UserAvatar<Fragment$UserAvatar> get copyWith =>
      CopyWith$Fragment$UserAvatar(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$UserAvatar<TRes> {
  factory CopyWith$Fragment$UserAvatar(
    Fragment$UserAvatar instance,
    TRes Function(Fragment$UserAvatar) then,
  ) = _CopyWithImpl$Fragment$UserAvatar;

  factory CopyWith$Fragment$UserAvatar.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UserAvatar;

  TRes call({
    int? id,
    String? name,
    Fragment$UserAvatar$avatar? avatar,
    int? donatorTier,
    String? donatorBadge,
    String? $__typename,
  });
  CopyWith$Fragment$UserAvatar$avatar<TRes> get avatar;
}

class _CopyWithImpl$Fragment$UserAvatar<TRes>
    implements CopyWith$Fragment$UserAvatar<TRes> {
  _CopyWithImpl$Fragment$UserAvatar(
    this._instance,
    this._then,
  );

  final Fragment$UserAvatar _instance;

  final TRes Function(Fragment$UserAvatar) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? avatar = _undefined,
    Object? donatorTier = _undefined,
    Object? donatorBadge = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$UserAvatar(
        id: id == _undefined || id == null ? _instance.id : (id as int),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        avatar: avatar == _undefined
            ? _instance.avatar
            : (avatar as Fragment$UserAvatar$avatar?),
        donatorTier: donatorTier == _undefined
            ? _instance.donatorTier
            : (donatorTier as int?),
        donatorBadge: donatorBadge == _undefined
            ? _instance.donatorBadge
            : (donatorBadge as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$UserAvatar$avatar<TRes> get avatar {
    final local$avatar = _instance.avatar;
    return local$avatar == null
        ? CopyWith$Fragment$UserAvatar$avatar.stub(_then(_instance))
        : CopyWith$Fragment$UserAvatar$avatar(
            local$avatar, (e) => call(avatar: e));
  }
}

class _CopyWithStubImpl$Fragment$UserAvatar<TRes>
    implements CopyWith$Fragment$UserAvatar<TRes> {
  _CopyWithStubImpl$Fragment$UserAvatar(this._res);

  TRes _res;

  call({
    int? id,
    String? name,
    Fragment$UserAvatar$avatar? avatar,
    int? donatorTier,
    String? donatorBadge,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$UserAvatar$avatar<TRes> get avatar =>
      CopyWith$Fragment$UserAvatar$avatar.stub(_res);
}

const fragmentDefinitionUserAvatar = FragmentDefinitionNode(
  name: NameNode(value: 'UserAvatar'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'User'),
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
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentUserAvatar = DocumentNode(definitions: [
  fragmentDefinitionUserAvatar,
]);

extension ClientExtension$Fragment$UserAvatar on graphql.GraphQLClient {
  void writeFragment$UserAvatar({
    required Fragment$UserAvatar data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'UserAvatar',
            document: documentNodeFragmentUserAvatar,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$UserAvatar? readFragment$UserAvatar({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'UserAvatar',
          document: documentNodeFragmentUserAvatar,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$UserAvatar.fromJson(result);
  }
}

class Fragment$UserAvatar$avatar {
  Fragment$UserAvatar$avatar({
    this.large,
    this.$__typename = 'UserAvatar',
  });

  factory Fragment$UserAvatar$avatar.fromJson(Map<String, dynamic> json) {
    final l$large = json['large'];
    final l$$__typename = json['__typename'];
    return Fragment$UserAvatar$avatar(
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
    if (other is! Fragment$UserAvatar$avatar ||
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

extension UtilityExtension$Fragment$UserAvatar$avatar
    on Fragment$UserAvatar$avatar {
  CopyWith$Fragment$UserAvatar$avatar<Fragment$UserAvatar$avatar>
      get copyWith => CopyWith$Fragment$UserAvatar$avatar(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$UserAvatar$avatar<TRes> {
  factory CopyWith$Fragment$UserAvatar$avatar(
    Fragment$UserAvatar$avatar instance,
    TRes Function(Fragment$UserAvatar$avatar) then,
  ) = _CopyWithImpl$Fragment$UserAvatar$avatar;

  factory CopyWith$Fragment$UserAvatar$avatar.stub(TRes res) =
      _CopyWithStubImpl$Fragment$UserAvatar$avatar;

  TRes call({
    String? large,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$UserAvatar$avatar<TRes>
    implements CopyWith$Fragment$UserAvatar$avatar<TRes> {
  _CopyWithImpl$Fragment$UserAvatar$avatar(
    this._instance,
    this._then,
  );

  final Fragment$UserAvatar$avatar _instance;

  final TRes Function(Fragment$UserAvatar$avatar) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? large = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$UserAvatar$avatar(
        large: large == _undefined ? _instance.large : (large as String?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$UserAvatar$avatar<TRes>
    implements CopyWith$Fragment$UserAvatar$avatar<TRes> {
  _CopyWithStubImpl$Fragment$UserAvatar$avatar(this._res);

  TRes _res;

  call({
    String? large,
    String? $__typename,
  }) =>
      _res;
}
