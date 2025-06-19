import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/models/anilist/user_data.dart';
import 'package:miruryoiki/widgets/buttons/switch.dart';
import 'package:recase/recase.dart';
import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import 'package:provider/provider.dart';

import '../services/library/library_provider.dart';
import '../utils/logging.dart';
import '../utils/screen_utils.dart';
import '../utils/time_utils.dart';
import '../widgets/buttons/button.dart';
import '../widgets/buttons/loading_button.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page.dart';
import '../widgets/svg.dart';
import 'anilist_settings.dart';
import 'settings.dart';

class AccountsScreen extends StatefulWidget {
  final ScrollController scrollController;

  const AccountsScreen({super.key, required this.scrollController});

  @override
  State<AccountsScreen> createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> {
  bool isLocalLoading = false;
  bool _seriesLoading = false;
  bool _userLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    if (anilistProvider.isLoggedIn && anilistProvider.currentUser?.userData == null) {
      // Only load if we're logged in but don't have the detailed data yet
      setState(() {
        isLocalLoading = true;
      });

      await anilistProvider.refreshUserData();

      setState(() {
        isLocalLoading = false;
      });
    }
  }

  HeaderWidget header({required AnilistProvider anilistProvider, required bool isLoggedIn}) {
    return HeaderWidget(
      title: (style) => Row(
        children: [
          Text(
            !isLoggedIn ? 'Account' : anilistProvider.currentUser?.name.titleCase ?? 'Anilist',
            style: style,
          ),
          Text(
            anilistProvider.currentUser?.id.toString() ?? '',
            key: ValueKey(anilistProvider.currentUser?.id),
            style: style.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
      image: anilistProvider.currentUser?.bannerImage != null //
          ? CachedNetworkImageProvider(anilistProvider.currentUser!.bannerImage!)
          : null,
      colorFilter: anilistProvider.currentUser?.bannerImage != null //
          ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
          : null,
    );
  }

  MiruRyoikiInfobar infoBar({required AnilistProvider anilistProvider}) {
    return MiruRyoikiInfobar(
      isProfilePicture: true,
      content: anilistProvider.isLoggedIn ? _buildSyncSettings(context, anilistProvider) : const Text('Sign in to access Anilist features'),
      poster: ({ImageProvider<Object>? imageProvider, required double width, required double height, required double squareness, required double offset}) {
        return DeferPointer(
          paintOnTop: true,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: imageProvider != null //
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
          ),
        );
      },
      getPosterImage: (anilistProvider.currentUser?.avatar != null) //
          ? Future.value(CachedNetworkImageProvider(anilistProvider.currentUser!.avatar!))
          : Future.value(null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: true);
    final isLoggedIn = anilistProvider.isLoggedIn;

    return DeferredPointerHandler(
      child: MiruRyoikiHeaderInfoBarPage(
        headerWidget: header(anilistProvider: anilistProvider, isLoggedIn: isLoggedIn),
        infobar: infoBar(anilistProvider: anilistProvider),
        content: buildMainContent(anilistProvider),
        hideInfoBar: !isLoggedIn,
      ),
    );
  }

  // Add this method to the AccountsScreen class
  Widget _buildSyncSettings(BuildContext context, AnilistProvider anilistProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link Settings',
          style: Manager.subtitleStyle,
        ),
        VDiv(16),
        ToggleSwitch(
          checked: true,
          content: Flexible(child: Text('Update automatically watch progress on Anilist', style: Manager.bodyStyle)),
          onChanged: (value) {
            // TODO: Implement setting
          },
        ),
        VDiv(8),
        NormalSwitch(
          toggleSwitch: ToggleSwitch(
            checked: true,
            content: Flexible(child: Text('Warn when linking the same File/Folder to an Anilist entry', style: Manager.bodyStyle)),
            onChanged: (value) {
              // TODO: Implement setting
            },
          ),
        ),
        VDiv(8),
        NormalSwitch(
          toggleSwitch: ToggleSwitch(
            checked: true,
            content: Flexible(child: Text('Warn when linking the same Anilist entry to a File/Folder', style: Manager.bodyStyle)),
            onChanged: (value) {
              // TODO: Implement setting
            },
          ),
        ),
        VDiv(16),
        LoadingButton(
          expand: true,
          isSmall: true,
          isLoading: _seriesLoading,
          tooltip: 'Refresh all Anilist metadata',
          label: 'Refresh All Metadata',
          onPressed: () async {
            if (_seriesLoading || anilistProvider.isLoading) return;
            setState(() {
              _seriesLoading = true;
            });

            final library = Provider.of<Library>(context, listen: false);
            await library.refreshAllMetadata();

            setState(() {
              _seriesLoading = false;
            });
          },
        ),
        VDiv(8),
        LoadingButton(
          expand: true,
          isSmall: true,
          isLoading: _userLoading && anilistProvider.isLoading,
          tooltip: 'Refresh User Metadata',
          label: 'Refresh User Metadata',
          onPressed: () async {
            if (_userLoading || anilistProvider.isLoading) return;
            setState(() {
              _userLoading = true;
            });

            await anilistProvider.refreshUserLists();

            setState(() {
              _userLoading = false;
            });
          },
        ),
        VDiv(8),
        LoadingButton(
          expand: true,
          tooltip: 'Logout from Anilist',
          hoverFillColor: Colors.red.toAccentColor().darkest,
          label: 'Logout',
          isLoading: false,
          isAlreadyBig: true,
          onPressed: () async {
            await anilistProvider.logout();
            setState(() {
              isLocalLoading = false;
            });
            logInfo('Logged out of Anilist');
          },
        ),
      ],
    );
  }

// Rename AnilistAccount to buildMainContent and update it
  Widget buildMainContent(AnilistProvider anilistProvider) {
    final bool isButtonDisabled = isLocalLoading || anilistProvider.isLoading || anilistProvider.isLoggedIn;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Not logged in
          if (!anilistProvider.isLoggedIn) ...[
            SettingsCard(children: [
              AnilistCardTitle(),
              VDiv(12),
              Text(
                'Connect your Anilist account to sync your media library.',
                style: Manager.bodyStyle,
              ),
              Align(
                alignment: Alignment.topRight,
                child: LoadingButton(
                  isLoading: isButtonDisabled || isLocalLoading || anilistProvider.isLoading,
                  label: 'Connect Anilist',
                  isAlreadyBig: true,
                  isFilled: true,
                  onPressed: () async {
                    if (isLocalLoading) return;
                    isLocalLoading = true;
                    await anilistProvider.login();
                    logInfo('Logging in to Anilist...');
                  },
                ),
              ),
            ])
          ] else ...[
            // User profile section
            SettingsCard(
              children: _buildUserProfile(anilistProvider),
            ),
            VDiv(16),
            // Statistics section
            SettingsCard(
              children: _buildStatistics(anilistProvider),
            ),
            VDiv(16),
            // Genres overview section
            ..._buildGenresOverview(anilistProvider),
            VDiv(16),
            // Favorites section
            SettingsCard(
              children: _buildFavorites(anilistProvider),
            ),
          ]
        ],
      ),
    );
  }

  List<Widget> _buildUserProfile(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;

    return [
      Text(
        'Profile',
        style: Manager.subtitleStyle,
      ),
      VDiv(16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userData?.about != null && userData!.about!.isNotEmpty) ...[
                  VDiv(8),
                  Text(
                    'About',
                    style: Manager.bodyStrongStyle,
                  ),
                  Text(
                    userData.about!,
                    style: Manager.bodyStyle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                VDiv(8),
                if (userData?.siteUrl != null) ...[
                  Row(
                    children: [
                      Text('Profile: ', style: Manager.bodyStrongStyle),
                      HyperlinkButton(
                        child: Text(userData!.siteUrl!, style: Manager.bodyStyle),
                        onPressed: () {
                          // Open URL
                        },
                      ),
                    ],
                  ),
                ],
                if (userData?.options?.profileColor != null) ...[
                  Row(
                    children: [
                      Text('Profile Color: ', style: Manager.bodyStrongStyle),
                      Container(
                        width: 16,
                        height: 16,
                        color: _parseProfileColor(userData!.options!.profileColor!),
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      Text(userData.options!.profileColor!, style: Manager.bodyStyle),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildStatistics(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final animeStats = userData?.statistics?.anime;

    if (animeStats == null) return [const Text('No statistics available')];

    return [
      Text(
        'Anime Statistics',
        style: Manager.subtitleStyle,
      ),
      VDiv(16),
      LayoutBuilder(
        builder: (context, constraints) {
          // Calculate the minimum width needed for all 4 stat cards with spacing
          const cardNumber = 5;
          const spacing = 16.0;
          final totalWidth = (ScreenUtils.kDefaultStatCardWidth * cardNumber) + (spacing * (cardNumber - 1));

          List<Widget> _statCards = [
            _statCard('Anime Watched', '${animeStats.count ?? 0}', icon: const Icon(mat.Icons.subscriptions)),
            _statCard('Episodes Watched', '${animeStats.episodesWatched ?? 0}', icon: const Icon(mat.Icons.visibility)),
            _statCard("${_formatMinutes(animeStats.minutesWatched ?? 0).$1} Watched", _formatMinutes(animeStats.minutesWatched ?? 0).$2, icon: const Icon(FluentIcons.clock)),
            _statCard('Mean Score', animeStats.meanScore?.toStringAsFixed(1) ?? "N/A", icon: Icon(FluentIcons.favorite_star_fill)),
            _statCard('Mean Score', animeStats.meanScore?.toStringAsFixed(1) ?? "N/A", icon: Icon(FluentIcons.favorite_star_fill)),
          ];

          // If enough space, use a Row with spaceBetween, else fall back to Wrap
          if (constraints.maxWidth >= totalWidth)
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _statCards,
            );
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.spaceBetween,
            children: _statCards,
          );
        },
      ),
      if (animeStats.formats != null && animeStats.formats!.isNotEmpty) ...[
        VDiv(16),
        Text(
          'Format Distribution',
          style: Manager.bodyStrongStyle,
        ),
        VDiv(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: animeStats.formats!
              .take(5)
              .map((format) => Chip(
                    backgroundColor: Manager.accentColor.lighter,
                    text: Text(_formatValue(format.format)),
                    trailing: Text('${format.count}'),
                  ))
              .toList(),
        ),
      ],
    ];
  }

  List<Widget> _buildGenresOverview(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final genres = userData?.statistics?.anime?.genres;

    if (genres == null || genres.isEmpty) return [const Text('No genres available')];

    return [
      SizedBox(
        height: 170 * math.max(Manager.fontSizeMultiplier, .9),
        width: double.infinity,
        child: LayoutBuilder(builder: (context, constraints) {
          final topGenres = genres.take(math.min(constraints.maxWidth ~/ 150, 6)).toList();
          final int totalCount = topGenres.fold<int>(0, (sum, genre) => sum + (genre.count ?? 0));

          final List<Color> colors = [
            Color(0xFF68d639),
            Color(0xFF02a9ff),
            Color(0xFF9256f3),
            Color(0xFFf779a4),
            Color(0xFFe85d75),
            Color(0xFFf79a63),
          ];
          return TooltipTheme(
            data: TooltipThemeData(waitDuration: const Duration(milliseconds: 100)),
            child: Card(
                borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 36.0, top: 36.0),
                      child: Text(
                        'Genres Overview',
                        style: Manager.subtitleStyle,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: topGenres.map((genre) {
                              return Expanded(
                                child: Tooltip(
                                  message: '${genre.genre!.titleCase} (${(genre.count! / totalCount * 100).toStringAsFixed(1)}%)',
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: colors[topGenres.indexOf(genre) % colors.length],
                                          borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                                        ),
                                        child: Text(
                                          genre.genre!.titleCase,
                                          style: Manager.bodyStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      VDiv(4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(text: genre.count?.toString() ?? '0', style: Manager.bodyStrongStyle.copyWith(color: colors[topGenres.indexOf(genre) % colors.length])),
                                            TextSpan(text: ' Entries', style: Manager.bodyStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(ScreenUtils.kStatCardBorderRadius), bottomLeft: Radius.circular(ScreenUtils.kStatCardBorderRadius)),
                      child: SizedBox(
                        height: 12,
                        child: Builder(builder: (context) {
                          final List<Widget> genreWidgets = [];
                          topGenres.forEachIndexed((index, genre) {
                            genreWidgets.add(
                              Expanded(
                                flex: (genre.count ?? 1),
                                child: Tooltip(
                                  message: '${genre.genre} (${(genre.count! / totalCount * 100).toStringAsFixed(1)}%)',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colors[index % colors.length],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                          return Row(children: genreWidgets);
                        }),
                      ),
                    ),
                  ],
                )),
          );
        }),
      ),
    ];
  }

  List<Widget> _buildFavorites(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final favorites = userData?.favourites;

    if (favorites == null ||
        (favorites.anime?.nodes == null || favorites.anime!.nodes!.isEmpty) && //
            (favorites.characters?.nodes == null || favorites.characters!.nodes!.isEmpty) && //
            (favorites.staff?.nodes == null || favorites.staff!.nodes!.isEmpty) && //
            (favorites.studios?.nodes == null || favorites.studios!.nodes!.isEmpty)) //
      return [const Text('No favorites found')];

    return [
      Text(
        'Favorites',
        style: Manager.subtitleStyle,
      ),
      VDiv(16),
      if (favorites.anime?.nodes != null && favorites.anime!.nodes!.isNotEmpty) ...[
        Text(
          'Favorite Anime',
          style: Manager.bodyStrongStyle,
        ),
        VDiv(8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.anime!.nodes!.length,
            itemBuilder: (context, index) {
              final anime = favorites.anime!.nodes![index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                        image: anime.posterImage != null //
                            ? DecorationImage(image: CachedNetworkImageProvider(anime.posterImage!), fit: BoxFit.cover)
                            : null,
                      ),
                    ),
                    VDiv(4),
                    Text(
                      anime.title.userPreferred ?? anime.title.english ?? anime.title.romaji ?? 'Unknown',
                      style: Manager.captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
      if (favorites.characters?.nodes != null && favorites.characters!.nodes!.isNotEmpty) ...[
        VDiv(16),
        Text(
          'Favorite Characters',
          style: Manager.bodyStrongStyle,
        ),
        VDiv(8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: favorites.characters!.nodes!.length,
            itemBuilder: (context, index) {
              final character = favorites.characters!.nodes![index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                        image: character.image?.large != null //
                            ? DecorationImage(image: CachedNetworkImageProvider(character.image!.large!), fit: BoxFit.cover)
                            : null,
                      ),
                    ),
                    VDiv(4),
                    Text(
                      character.name?.full ?? 'Unknown',
                      style: Manager.captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ];
  }

  //

  Widget _statCard(String title, String value, {Widget? icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
          border: Border.all(color: Manager.accentColor.lighter),
        ),
        width: ScreenUtils.kDefaultStatCardWidth,
        child: Stack(
          children: [
            if (icon != null) ...[
              Positioned(
                bottom: 6,
                right: 6,
                child: Transform.rotate(
                  angle: -math.pi / 15,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Manager.accentColor.lightest,
                      BlendMode.srcATop,
                    ),
                    child: Transform.scale(
                      scale: 3.5,
                      child: Opacity(
                        opacity: 0.25,
                        child: icon,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Manager.captionStyle,
                  ),
                  Text(
                    value,
                    style: Manager.bodyLargeStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //

  (String, String) _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) return ('Days', '$days days');
    if (hours > 0) return ('Hours', '$hours hours');
    return ('Minutes', '$minutes minutes');
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'Unknown';
    return value.toString().replaceAll('_', ' ');
  }

  Color _parseProfileColor(String color) {
    switch (color.toLowerCase()) {
      case 'blue':
        return mat.Colors.blue;
      case 'purple':
        return mat.Colors.purple;
      case 'pink':
        return mat.Colors.pink;
      case 'orange':
        return mat.Colors.orange;
      case 'red':
        return mat.Colors.red;
      case 'green':
        return mat.Colors.green;
      case 'gray':
      case 'grey':
        return mat.Colors.grey;
      default:
        return Manager.accentColor.lighter; // Fallback to accent color if unknown
    }
  }
}

class AnilistCardTitle extends StatelessWidget {
  const AnilistCardTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            height: 20,
            child: Transform.scale(
              scale: 3,
              child: anilistLogo,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Anilist',
            style: Manager.subtitleStyle,
          ),
        ],
      ),
    );
  }
}
