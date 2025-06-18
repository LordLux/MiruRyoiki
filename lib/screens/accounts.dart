import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/switch.dart';
import 'package:recase/recase.dart';
import '../manager.dart';
import '../services/anilist/provider/anilist_provider.dart';
import 'package:provider/provider.dart';

import '../services/library/library_provider.dart';
import '../utils/logging.dart';
import '../utils/screen_utils.dart';
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

  @override
  Widget build(BuildContext context) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: true);
    final isLoggedIn = anilistProvider.isLoggedIn;

    return MiruRyoikiHeaderInfoBarPage(
      headerWidget: HeaderWidget(
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
      ),
      infobar: (deferredPointerLink) => MiruRyoikiInfobar(
        isProfilePicture: true,
        content: anilistProvider.isLoggedIn ? _buildSyncSettings(context, anilistProvider) : const Text('Sign in to access Anilist features'),
        poster: ({ImageProvider<Object>? imageProvider, required double width, required double height, required double squareness, required double offset}) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: imageProvider != null //
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
          );
        },
        getPosterImage: (anilistProvider.currentUser?.avatar != null) //
            ? Future.value(CachedNetworkImageProvider(anilistProvider.currentUser!.avatar!))
            : Future.value(null),
      ),
      hideInfoBar: !isLoggedIn,
      content: buildMainContent(anilistProvider),
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
          content: Flexible(child: const Text('Update automatically watch progress on Anilist')),
          onChanged: (value) {
            // TODO: Implement setting
          },
        ),
        VDiv(8),
        NormalSwitch(
          toggleSwitch: ToggleSwitch(
            checked: true,
            content: Flexible(child: const Text('Warn when linking the same File/Folder to an Anilist entry')),
            onChanged: (value) {
              // TODO: Implement setting
            },
          ),
        ),
        VDiv(8),
        NormalSwitch(
          toggleSwitch: ToggleSwitch(
            checked: true,
            content: Flexible(child: const Text('Warn when linking the same Anilist entry to a File/Folder')),
            onChanged: (value) {
              // TODO: Implement setting
            },
          ),
        ),
        VDiv(16),
        NormalButton(
          expand: true,
          tooltip: 'Refresh all Anilist metadata',
          label: 'Refresh All Metadata',
          onPressed: () {
            final library = Provider.of<Library>(context, listen: false);
            library.refreshAllMetadata();
            logInfo('Refreshing all Anilist metadata');
          },
        ),
        VDiv(8),
        NormalButton(
          expand: true,
          tooltip: 'Refresh User Metadata',
          label: 'Refresh User Metadata',
          onPressed: () {
            anilistProvider.refreshUserLists();
            logInfo('Refreshing user metadata');
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
        children: [
          // Not logged in
          if (!anilistProvider.isLoggedIn) ...[
            SettingsCard(children: [
              AnilistCardTitle(),
              VDiv(12),
              Text(
                'Connect your Anilist account to sync your media library.',
                style: FluentTheme.of(context).typography.body,
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
            SettingsCard(children: [
              _buildUserProfile(anilistProvider),
            ]),
            VDiv(16),
            // Statistics section
            SettingsCard(children: [
              _buildStatistics(anilistProvider),
            ]),
            VDiv(16),
            // Favorites section
            SettingsCard(children: [
              _buildFavorites(anilistProvider),
            ]),
          ]
        ],
      ),
    );
  }

  // Add these methods to AccountsScreen class

  Widget _buildUserProfile(AnilistProvider anilistProvider) {
    final user = anilistProvider.currentUser;
    final userData = anilistProvider.currentUser?.userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        VDiv(16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user?.avatar != null)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(user!.avatar!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FluentTheme.of(context).accentColor,
                ),
                child: const Center(child: Icon(FluentIcons.contact, size: 40, color: Colors.white)),
              ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Unknown User',
                    style: FluentTheme.of(context).typography.title,
                  ),
                  if (userData?.about != null && userData!.about!.isNotEmpty) ...[
                    VDiv(8),
                    Text(
                      'About',
                      style: FluentTheme.of(context).typography.bodyStrong,
                    ),
                    Text(
                      userData.about!,
                      style: FluentTheme.of(context).typography.body,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  VDiv(8),
                  if (userData?.siteUrl != null) ...[
                    Row(
                      children: [
                        Text('Profile: ', style: FluentTheme.of(context).typography.bodyStrong),
                        HyperlinkButton(
                          child: Text(userData!.siteUrl!),
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
                        Text('Profile Color: ', style: FluentTheme.of(context).typography.bodyStrong),
                        Container(
                          width: 16,
                          height: 16,
                          color: Color(int.parse('FF${userData!.options!.profileColor!.replaceAll("#", "")}', radix: 16)),
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(userData.options!.profileColor!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatistics(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final animeStats = userData?.statistics?.anime;

    if (animeStats == null) {
      return const Text('No statistics available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anime Statistics',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        VDiv(16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _statCard('Anime Watched', '${animeStats.count ?? 0}'),
            _statCard('Episodes Watched', '${animeStats.episodesWatched ?? 0}'),
            _statCard('Minutes Watched', _formatMinutes(animeStats.minutesWatched ?? 0)),
            _statCard('Mean Score', animeStats.meanScore?.toStringAsFixed(1) ?? "N/A"),
          ],
        ),
        VDiv(16),
        if (animeStats.genres != null && animeStats.genres!.isNotEmpty) ...[
          Text(
            'Top Genres',
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
          VDiv(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: animeStats.genres!
                .take(5)
                .map((genre) => Chip(
                      text: Text(genre.genre ?? 'Unknown'),
                      trailing: Text('${genre.count}'),
                    ))
                .toList(),
          ),
        ],
        if (animeStats.formats != null && animeStats.formats!.isNotEmpty) ...[
          VDiv(16),
          Text(
            'Format Distribution',
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
          VDiv(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: animeStats.formats!
                .take(5)
                .map((format) => Chip(
                      text: Text(_formatValue(format.format)),
                      trailing: Text('${format.count}'),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFavorites(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final favorites = userData?.favourites;

    if (favorites == null || (favorites.anime?.nodes == null || favorites.anime!.nodes!.isEmpty) && (favorites.characters?.nodes == null || favorites.characters!.nodes!.isEmpty) && (favorites.staff?.nodes == null || favorites.staff!.nodes!.isEmpty) && (favorites.studios?.nodes == null || favorites.studios!.nodes!.isEmpty)) {
      return const Text('No favorites found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorites',
          style: FluentTheme.of(context).typography.subtitle,
        ),
        VDiv(16),
        if (favorites.anime?.nodes != null && favorites.anime!.nodes!.isNotEmpty) ...[
          Text(
            'Favorite Anime',
            style: FluentTheme.of(context).typography.bodyStrong,
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
                          borderRadius: BorderRadius.circular(8),
                          image: anime.posterImage != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(anime.posterImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      VDiv(4),
                      Text(
                        anime.title.userPreferred ?? anime.title.english ?? anime.title.romaji ?? 'Unknown',
                        style: FluentTheme.of(context).typography.caption,
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
            style: FluentTheme.of(context).typography.bodyStrong,
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
                          borderRadius: BorderRadius.circular(8),
                          image: character.image?.large != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(character.image!.large!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      VDiv(4),
                      Text(
                        character.name?.full ?? 'Unknown',
                        style: FluentTheme.of(context).typography.caption,
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
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Manager.accentColor),
      ),
      width: 150,
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
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) return '$days days';
    return '$hours hours';
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'Unknown';
    return value.toString().replaceAll('_', ' ');
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
            style: FluentTheme.of(context).typography.subtitle,
          ),
        ],
      ),
    );
  }
}
