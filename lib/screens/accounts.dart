import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_html_video/flutter_html_video.dart';
import 'package:miruryoiki/enums.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:miruryoiki/functions.dart';
import 'package:miruryoiki/models/anilist/user_data.dart';
import 'package:flexible_wrap/flexible_wrap.dart';
import 'package:miruryoiki/services/navigation/dialogs.dart';
import 'package:miruryoiki/utils/html/extensions/spoiler.dart';
import 'package:miruryoiki/utils/time.dart';
import 'package:miruryoiki/widgets/buttons/switch.dart';
import 'package:miruryoiki/widgets/buttons/wrapper.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:recase/recase.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:url_launcher/url_launcher.dart';
import '../manager.dart';
import '../models/anilist/anime.dart';
import '../services/anilist/provider/anilist_provider.dart';
import 'package:provider/provider.dart';

import '../services/library/library_provider.dart';
import '../services/navigation/shortcuts.dart';
import '../services/navigation/show_info.dart';
import '../utils/color.dart';
import '../utils/html/extensions/code.dart';
import '../utils/html/extensions/iframe.dart';
import '../utils/html/extensions/unsupported.dart';
import '../utils/logging.dart';
import '../utils/screen.dart';
import '../widgets/activity_graph.dart';
import '../widgets/animated_stats_counter.dart';
import '../widgets/buttons/hyperlink.dart';
import '../widgets/buttons/loading_button.dart';
import '../widgets/page/header_widget.dart';
import '../widgets/page/infobar.dart';
import '../widgets/page/page.dart';
import '../widgets/svg.dart';
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
  bool _aboutExpanded = false;

  bool _showHiddenSeries = false;
  bool _showAnilistHiddenSeries = false;

  @override
  void initState() {
    super.initState();
    _showHiddenSeries = Manager.settings.showHiddenSeries;
    _showAnilistHiddenSeries = Manager.settings.showAnilistHiddenSeries;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    if (anilistProvider.isLoggedIn && anilistProvider.currentUser?.userData == null) {
      // Only load if we're logged in but don't have the detailed data yet
      setState(() => isLocalLoading = true);

      try {
        await anilistProvider.refreshUserData();
        await anilistProvider.refreshUserLists();
      } catch (e, stackTrace) {
        // Log the error but don't let it affect the UI
        logErr('Error refreshing user data', e, stackTrace);
        // Show a snackbar to inform the user
        snackBar(
          'Failed to refresh user data. Please try again later.',
          severity: InfoBarSeverity.warning,
        );
      }
    }
    setState(() => isLocalLoading = false);
  }

  HeaderWidget header({required AnilistProvider anilistProvider, required bool isLoggedIn}) {
    return HeaderWidget(
      title: (style, _) => Align(
        alignment: Alignment.centerLeft,
        child: WrappedHyperlinkButton(
          tooltipWaitDuration: const Duration(milliseconds: 600),
          tooltip: 'Copy your Anilist Profile ID',
          onPressed: () {
            copyToClipboard(anilistProvider.currentUser!.id.toString());
            snackBar(
              'Copied Anilist Profile ID: ${anilistProvider.currentUser!.id}',
              severity: InfoBarSeverity.info,
            );
          },
          text: anilistProvider.currentUser?.name.titleCase ?? 'Anilist',
          style: style,
          iconColor: Manager.accentColor.darkest.lerpWith(Colors.white, 0.8),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (anilistProvider.currentUser != null) ...[
                Text(anilistProvider.currentUser!.id.toString()),
                HDiv(8),
              ],
              Icon(
                mat.Icons.copy,
              ),
            ],
          ),
        ),
      ),
      titleLeftAligned: !isLoggedIn,
      image: anilistProvider.currentUser?.bannerImage != null //
          ? CachedNetworkImageProvider(anilistProvider.currentUser!.bannerImage!)
          : null,
      colorFilter: anilistProvider.currentUser?.bannerImage != null //
          ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken)
          : null,
      children: [VDiv(0)], // just to have automatic bottom padding
    );
  }

  MiruRyoikiInfobar infoBar({required AnilistProvider anilistProvider}) {
    return MiruRyoikiInfobar(
      isProfilePicture: true,
      setStateCallback: () => setState(() {}),
      footer: _buildFooter(anilistProvider: anilistProvider),
      footerPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 12),
      content: anilistProvider.isLoggedIn ? _buildSyncSettings(context, anilistProvider) : const Text('Sign in to access Anilist features'),
      poster: ({ImageProvider<Object>? imageProvider, required double width, required double height, required double squareness, required double offset}) {
        return DeferPointer(
          paintOnTop: true,
          child: MouseButtonWrapper(
            tooltip: 'Open your Anilist Profile page',
            tooltipWaitDuration: const Duration(milliseconds: 500),
            child: (isHovering) => Stack(
              children: [
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    image: imageProvider != null //
                        ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                        : null,
                  ),
                ),
                Positioned.fill(
                  child: mat.Material(
                    color: Colors.transparent,
                    child: mat.InkWell(
                      borderRadius: BorderRadius.circular(ScreenUtils.kProfilePictureBorderRadius),
                      hoverColor: Manager.accentColor.lightest.withOpacity(0.2),
                      focusColor: Manager.accentColor.lightest.withOpacity(0.2),
                      onTap: () {
                        launchUrl(Uri.parse('https://anilist.co/user/${anilistProvider.currentUser!.id}'));
                      },
                      child: AnimatedOpacity(
                        opacity: isHovering ? 1.0 : 0.0,
                        duration: shortDuration,
                        child: Icon(
                          mat.Icons.open_in_new,
                          size: 64,
                          color: Manager.accentColor.lightest,
                        ),
                      ),
                    ),
                  ),
                )
              ],
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

    return TooltipTheme(
      data: TooltipThemeData(waitDuration: const Duration(milliseconds: 100)),
      child: DeferredPointerHandler(
        child: MiruRyoikiTemplatePage(
          headerWidget: header(anilistProvider: anilistProvider, isLoggedIn: isLoggedIn),
          infobar: (_) => infoBar(anilistProvider: anilistProvider),
          content: buildMainContent(anilistProvider),
          hideInfoBar: !isLoggedIn,
        ),
      ),
    );
  }

  Widget _buildSyncSettings(BuildContext context, AnilistProvider anilistProvider) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ToggleSwitch(
                checked: true,
                content: Flexible(child: Text('Warn when linking the same File/Folder to an Anilist entry', style: Manager.bodyStyle)),
                onChanged: (value) {
                  // TODO: Implement setting
                },
              ),
            ),
            VDiv(8),
            NormalSwitch(
              ToggleSwitch(
                checked: true,
                content: Flexible(child: Text('Warn when linking the same Anilist entry to a File/Folder', style: Manager.bodyStyle)),
                onChanged: (value) {
                  // TODO: Implement setting
                },
              ),
            ),
            ..._buildPrivacySettings(context, anilistProvider),
          ],
        ),
      );
    });
  }

  List<Widget> _buildPrivacySettings(BuildContext context, AnilistProvider anilistProvider) {
    return [
      Text(
        'Privacy Settings',
        style: Manager.subtitleStyle,
      ),
      VDiv(16),

      // Toggle for showing hidden series
      NormalSwitch(
        ToggleSwitch(
          checked: _showHiddenSeries,
          content: Flexible(
            child: Text('Show hidden series', style: Manager.bodyStyle),
          ),
          onChanged: (value) {
            setState(() {
              _showHiddenSeries = value;
              Manager.settings.showHiddenSeries = value;
            });
          },
        ),
      ),

      // Toggle for showing hidden series
      NormalSwitch(
        ToggleSwitch(
          checked: _showAnilistHiddenSeries,
          content: Flexible(
            child: Text('Show series hidden from status lists', style: Manager.bodyStyle),
          ),
          onChanged: (value) {
            setState(() {
              _showAnilistHiddenSeries = value;
              Manager.settings.showAnilistHiddenSeries = value;
            });
          },
        ),
        tooltip: 'Show series hidden from status lists (these will only be visible in custom lists)',
      ),
    ];
  }

  List<Widget> _buildFooter({required AnilistProvider anilistProvider}) {
    return [
      LoadingButton(
        expand: true,
        isSmall: true,
        isLoading: _seriesLoading,
        tooltip: 'Refresh Series Metadata',
        label: 'Refresh Series Metadata',
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
        isLoading: _userLoading || anilistProvider.isLoading,
        tooltip: 'Refresh User Data',
        label: 'Refresh User Data',
        onPressed: () async {
          if (_userLoading || anilistProvider.isLoading) return;
          setState(() => _userLoading = true);

          await anilistProvider.refreshUserLists();

          setState(() => _userLoading = false);
        },
      ),
      VDiv(8),
      LoadingButton(
        expand: true,
        tooltip: 'Logout from Anilist',
        hoverFillColor: Color.fromARGB(176, 94, 26, 26),
        label: 'Logout',
        isLoading: false,
        isAlreadyBig: true,
        onPressed: () async {
          await showSimpleManagedDialog(
            context: context,
            id: 'anilist-logout',
            title: 'Logout from Anilist',
            body: 'Are you sure you want to logout from Anilist?',
            onPositive: () async {
              await anilistProvider.logout();
              setState(() => isLocalLoading = false);
              logInfo('Logged out of Anilist');
            },
            onNegative: () => logInfo('Cancelled Anilist logout'),
          );
        },
      ),
    ];
  }

// Rename AnilistAccount to buildMainContent and update it
  Widget buildMainContent(AnilistProvider anilistProvider) {
    final bool isButtonDisabled = isLocalLoading || anilistProvider.isLoading || anilistProvider.isLoggedIn;

    return Column(
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
            padding: EdgeInsets.only(left: 24.0, top: 32.0, right: 32.0, bottom: 32.0),
            children: _buildUserProfile(anilistProvider),
          ),
          VDiv(16),
          // Statistics section
          SettingsCard(
            children: _buildStatistics(anilistProvider),
          ),
          VDiv(16),
          // Distributions section
          _buildDistribution(anilistProvider),

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
    );
  }

  List<Widget> _buildUserProfile(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;

    if (userData == null) return [Text('Loading user data...')];

    return [
      if (userData.about != null && userData.about!.isNotEmpty)
        MouseButtonWrapper(
          tooltip: !_aboutExpanded ? 'Click to expand the About section' : 'Click to collapse the About section',
          child: (_) => GestureDetector(
            onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
            child: Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('About', style: Manager.subtitleStyle),
                    mat.InkWell(
                      borderRadius: BorderRadius.circular(20),
                      hoverColor: Manager.accentColor.lightest.withOpacity(0.5),
                      focusColor: Manager.accentColor.lightest.withOpacity(0.5),
                      onTap: () => setState(() => _aboutExpanded = !_aboutExpanded),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: _aboutExpanded ? 0.5 : 0.0,
                        child: SizedBox.square(
                          dimension: 25,
                          child: Icon(mat.Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      else
        Text(
          'About',
          style: Manager.subtitleStyle,
        ),
      VDiv(8),
      Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (userData.about != null && userData.about!.isNotEmpty)
                    AnimatedCrossFade(
                      crossFadeState: _aboutExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 250),
                      reverseDuration: const Duration(milliseconds: 150),
                      firstCurve: Curves.easeOut,
                      secondCurve: Curves.easeIn,
                      sizeCurve: Curves.easeInOut,
                      alignment: Alignment.topLeft,
                      firstChild: AnimatedOpacity(
                        opacity: _aboutExpanded ? 1.0 : 0.0,
                        curve: Curves.easeInQuint,
                        duration: const Duration(milliseconds: 500),
                        child: Card(
                          child: LayoutBuilder(builder: (context, constraints) {
                            return SelectionArea(
                              child: Html(
                                data: _convertMarkupToHtml(userData.about!, constraints.maxWidth),
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(Manager.bodyStyle.fontSize!),
                                    fontFamily: Manager.bodyStyle.fontFamily,
                                    color: Manager.bodyStyle.color,
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  "a": Style(
                                    color: Manager.accentColor,
                                    textDecoration: TextDecoration.none,
                                  ),
                                  "blockquote": Style(
                                    border: Border(left: BorderSide(color: Manager.accentColor.darker, width: 3)),
                                    padding: HtmlPaddings.only(left: 8),
                                    fontStyle: FontStyle.italic,
                                    color: Manager.bodyStyle.color?.withOpacity(0.8),
                                  ),
                                  "img": Style(
                                    margin: Margins.only(top: 4, bottom: 4),
                                  ),
                                  "ul, ol": Style(
                                    margin: Margins.only(left: 16, top: 4, bottom: 4),
                                  ),
                                  "li": Style(
                                    margin: Margins.only(bottom: 2),
                                  ),
                                  "iframe": Style(
                                    width: Width(250),
                                    height: Height(150),
                                  ),
                                },
                                onLinkTap: (url, _, __) {
                                  if (url != null) launchUrl(Uri.parse(url));
                                },
                                extensions: [
                                  WindowsIframeHtmlExtension(),
                                  SpoilerTagExtension(),
                                  CodeBlockExtension(),
                                  VideoHtmlExtension(),
                                  UnsupportedBlockExtension(),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                  VDiv(8),
                  if (userData.siteUrl != null) ...[
                    Row(
                      children: [
                        Text('Profile: ', style: Manager.bodyStrongStyle),
                        MouseButtonWrapper(
                          child: (_) => HyperlinkButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.isDisabled) {
                                  return Manager.accentColor.darker.withOpacity(.2);
                                } else if (states.isPressed) {
                                  return Manager.accentColor.lightest.withOpacity(.2);
                                } else if (states.isHovered) {
                                  return Manager.accentColor.light.withOpacity(.2);
                                } else {
                                  return null;
                                }
                              }),
                            ),
                            child: Text(userData.siteUrl!, style: Manager.bodyStyle),
                            onPressed: () {
                              launchUrl(Uri.parse(userData.siteUrl!));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (userData.options?.profileColor != null) ...[
                    Row(
                      children: [
                        Text('Profile Color: ', style: Manager.bodyStrongStyle),
                        Container(
                          width: 16,
                          height: 16,
                          color: _parseProfileColor(userData.options!.profileColor!),
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(userData.options!.profileColor!, style: Manager.bodyStyle),
                      ],
                    ),
                  ],
                  if (userData.stats != null && userData.stats!.activityHistory.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActivityGraph(
                        activityHistory: userData.stats!.activityHistory,
                        colorScale: [
                          Manager.accentColor.darker.withOpacity(.4), // 0
                          Manager.accentColor.dark,
                          Manager.accentColor,
                          Manager.accentColor.light,
                          Manager.accentColor.lightest, // 4
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildStatistics(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final animeStats = userData?.statistics?.anime;

    if (animeStats == null) return [const Text('No statistics available')];

    return [
      WrappedHyperlinkButton(
        tooltip: 'Open your Anime Statistics Overview page on Anilist',
        url: 'https://anilist.co/user/${anilistProvider.currentUser?.id}/stats/anime/overview',
        text: 'Anime Statistics',
        icon: Icon(
          mat.Icons.open_in_new,
          color: Manager.accentColor.lightest,
        ),
      ),
      VDiv(16),
      LayoutBuilder(
        builder: (context, constraints) {
          const cardNumber = 5;
          const spacing = 16.0;
          final totalSpacing = spacing * (cardNumber - 1);
          final availableWidth = constraints.maxWidth - totalSpacing;
          final cardWidth = availableWidth / cardNumber;
          final clampedCardWidth = cardWidth.clamp(ScreenUtils.kMinStatCardWidth, ScreenUtils.kMaxStatCardWidth);

          List<Widget> statCards = [
            SizedBox(
              width: clampedCardWidth,
              child: _statCard('Anime Watched', animeStats.count ?? 0, icon: const Icon(mat.Icons.subscriptions)),
            ),
            SizedBox(
              width: clampedCardWidth,
              child: _statCard('Episodes Watched', animeStats.episodesWatched ?? 0, icon: const Icon(mat.Icons.visibility)),
            ),
            SizedBox(
              width: clampedCardWidth,
              child: _statCard(
                "${_formatMinutes(animeStats.minutesWatched ?? 0).$1} Watched",
                _formatMinutes(animeStats.minutesWatched ?? 0).$2,
                icon: const Icon(FluentIcons.clock),
                suffix: _formatMinutes(animeStats.minutesWatched ?? 0).$1,
              ),
            ),
            SizedBox(
              width: clampedCardWidth,
              child: _statCard('Mean Score', (animeStats.meanScore ?? 0.0) / 10, icon: Icon(FluentIcons.favorite_star_fill)),
            ),
            SizedBox(
              width: clampedCardWidth,
              child: _statCard(
                "Standard Deviation",
                animeStats.standardDeviation ?? 0.0,
                icon: const Icon(FluentIcons.offline_one_drive_parachute_disabled),
              ),
            ),
          ];

          final totalWidth = (clampedCardWidth * cardNumber) + totalSpacing;

          if (constraints.maxWidth >= totalWidth) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: statCards,
            );
          }
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.spaceBetween,
            children: statCards,
          );
        },
      ),
    ];
  }

  Widget _buildDistribution(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final animeStats = userData?.statistics?.anime;

    int statusTotal = 0;
    int formatTotal = 0;
    final double preferWhiteThreshold = 0.05;
    final double preferBlackThreshold = 0.5;

    if (animeStats == null || animeStats.formats == null || animeStats.formats!.isEmpty) //
      return Text('No distributions available', style: Manager.bodyStyle);

    // Format the data for the pie charts
    Map<String, double> formatDistribution = {};
    if (animeStats.formats != null) {
      for (FormatStatistic format in animeStats.formats!) {
        formatDistribution[format.formatPretty ?? 'Unknown'] = (format.count ?? 0).toDouble();
        formatTotal += format.count ?? 0;
      }
    }

    // For status distribution
    Map<String, double> statusDistribution = {};
    if (animeStats.statuses != null) {
      for (StatusStatistic status in animeStats.statuses!) {
        statusDistribution[status.statusPretty?.titleCase ?? 'Unknown'] = (status.count ?? 0).toDouble();
        statusTotal += status.count ?? 0;
      }
    }

    Widget statusDistributionWidget = Row(
      children: [
        Expanded(
          child: PieChart(
            dataMap: statusDistribution,
            animationDuration: const Duration(milliseconds: 800),
            chartRadius: math.min(MediaQuery.of(context).size.width / 3.5, 150),
            initialAngleInDegree: 0,
            chartType: ChartType.disc,
            ringStrokeWidth: 40,
            colorList: List.generate(
              statusDistribution.length,
              (i) => Manager.accentColor.lightest.shiftHue(i / statusDistribution.length / 2).darken(.125).saturate(-.35),
            ),
            legendOptions: const LegendOptions(showLegends: false),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: false,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final entry in statusDistribution.entries.take(4))
                Builder(builder: (context) {
                  final Color main = Manager.accentColor.lightest.shiftHue(statusDistribution.keys.toList().indexOf(entry.key) / statusDistribution.length / 2);
                  final index = formatDistribution.keys.toList().indexOf(entry.key);
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == 5 ? 0 : 8.0),
                    child: Container(
                      height: 30 * (Manager.fontSizeMultiplier.clamp(0.9, 1.2)),
                      decoration: BoxDecoration(
                        color: main.darken(.125).saturate(-.35),
                        borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              entry.key.titleCase,
                              style: Manager.bodyStyle.copyWith(color: getTextColor(main, preferWhite: preferWhiteThreshold, preferBlack: preferBlackThreshold)),
                            ),
                          ),
                          Container(
                            width: 50,
                            decoration: BoxDecoration(
                              color: main,
                              borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                            ),
                            child: Center(
                              child: Text(
                                '${((entry.value / statusTotal) * 100).round()}%',
                                style: Manager.bodyStrongStyle.copyWith(color: getTextColor(main, preferWhite: preferWhiteThreshold, preferBlack: preferBlackThreshold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
            ],
          ),
        ),
      ],
    );

    Widget formatDistributionWidget = Row(
      children: [
        Expanded(
          child: PieChart(
            dataMap: formatDistribution,
            animationDuration: const Duration(milliseconds: 800),
            chartRadius: math.min(MediaQuery.of(context).size.width / 3.5, 150),
            initialAngleInDegree: 0,
            chartType: ChartType.disc,
            ringStrokeWidth: 40,
            colorList: List.generate(
              formatDistribution.length,
              (i) => Manager.accentColor.lightest.shiftHue(i / formatDistribution.length / 2).darken(.125).saturate(-.35),
            ),
            legendOptions: const LegendOptions(showLegends: false),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: false,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final entry in formatDistribution.entries.take(5))
                Builder(builder: (context) {
                  final Color main = Manager.accentColor.lightest.shiftHue(formatDistribution.keys.toList().indexOf(entry.key) / formatDistribution.length / 2);
                  final index = formatDistribution.keys.toList().indexOf(entry.key);
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == 4 ? 0 : 8.0),
                    child: Container(
                      height: 30 * (Manager.fontSizeMultiplier.clamp(0.9, 1.2)),
                      decoration: BoxDecoration(
                        color: main.darken(.125).saturate(-.35),
                        borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              entry.key,
                              style: Manager.bodyStyle.copyWith(color: getTextColor(main, preferWhite: preferWhiteThreshold, preferBlack: preferBlackThreshold)),
                            ),
                          ),
                          Container(
                            width: 50,
                            decoration: BoxDecoration(
                              color: main,
                              borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
                            ),
                            child: Center(
                              child: Text(
                                '${((entry.value / formatTotal) * 100).round()}%',
                                style: Manager.bodyStrongStyle.copyWith(color: getTextColor(main, preferWhite: preferWhiteThreshold, preferBlack: preferBlackThreshold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final minCardWidth = ScreenUtils.kMinDistrCardWidth;
      final spacing = 16.0 * Manager.fontSizeMultiplier;
      final canFitRow = (constraints.maxWidth.isInfinite ? 10000 : constraints.maxWidth) >= (minCardWidth * 2 + spacing);

      final statusCard = SizedBox(
        height: (200 + 100 * Manager.fontSizeMultiplier.clamp(0.7, 1.5)),
        child: SettingsCard(
          children: [
            Text(
              'Status Distribution',
              style: Manager.subtitleStyle,
            ),
            VDiv(8),
            statusDistributionWidget,
          ],
        ),
      );
      final formatCard = SizedBox(
        height: (200 + 100 * Manager.fontSizeMultiplier.clamp(0.7, 1.5)),
        child: SettingsCard(
          children: [
            Text(
              'Format Distribution',
              style: Manager.subtitleStyle,
            ),
            VDiv(8),
            formatDistributionWidget,
          ],
        ),
      );

      if (canFitRow) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: statusCard),
            SizedBox(width: spacing),
            Expanded(child: formatCard),
          ],
        );
      } else {
        // Use Wrap to display vertically
        return FlexibleWrap(
          spacing: spacing,
          children: [
            SizedBox(
              width: double.infinity,
              child: statusCard,
            ),
            VDiv(16),
            SizedBox(
              width: double.infinity,
              child: formatCard,
            ),
          ],
        );
      }
    });
  }

  List<Widget> _buildGenresOverview(AnilistProvider anilistProvider) {
    final userData = anilistProvider.currentUser?.userData;
    final genres = userData?.statistics?.anime?.genres;

    if (genres == null || genres.isEmpty) return [const Text('No genres available')];

    return [
      SizedBox(
        height: 170 * math.max(Manager.fontSizeMultiplier, .9) + 16,
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
          return Card(
              borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 36.0, top: 36.0),
                    child: WrappedHyperlinkButton(
                      tooltip: 'Open your Genres Statistics page on Anilist',
                      url: 'https://anilist.co/user/${anilistProvider.currentUser?.id}/stats/anime/genres',
                      text: 'Genres Overview',
                      icon: Icon(
                        mat.Icons.open_in_new,
                        color: Manager.accentColor.lightest,
                      ),
                    ),
                  ),
                  VDiv(8),
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
                  VDiv(8),
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
              ));
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

    Widget buildList(FavouriteCollection list) {
      return SizedBox(
        height: 150 * Manager.fontSizeMultiplier,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: true, platform: TargetPlatform.windows, scrollbars: false),
          child: DynMouseScroll(
              stopScroll: KeyboardState.ctrlPressedNotifier,
              scrollSpeed: 1.0,
              enableSmoothScroll: Manager.animationsEnabled,
              durationMS: 350,
              animationCurve: Curves.easeOutQuint,
              builder: (context, controller, physics) {
                return ValueListenableBuilder(
                    valueListenable: KeyboardState.ctrlPressedNotifier,
                    builder: (context, isCtrlPressed, _) {
                      return ListView.builder(
                        physics: isCtrlPressed ? const NeverScrollableScrollPhysics() : null,
                        controller: controller,
                        scrollDirection: Axis.horizontal,
                        itemCount: list.nodes!.length,
                        itemBuilder: (context, index) {
                          final node = list.nodes![index];
                          final isAnime = node is AnilistAnime;
                          final imageUrl = isAnime ? node.posterImage : node.image?.large;
                          final name = isAnime ? node.title.userPreferred : node.name?.full;
                          return MouseButtonWrapper(
                            isButtonDisabled: node.siteUrl == null || node.siteUrl!.isEmpty,
                            tooltip: !isAnime ? name ?? 'Unknown' : '${name ?? 'Unknown'}\n${node.seasonYear ?? ''} ${node.format?.toLowerCase() == "tv" ? "TV" : node.format?.titleCase ?? ''}',
                            child: (_) => Container(
                              width: 100 * Manager.fontSizeMultiplier,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      mat.Ink(
                                        color: Colors.transparent,
                                        child: Container(
                                          height: 120 * Manager.fontSizeMultiplier,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                                            image: imageUrl != null ? DecorationImage(image: CachedNetworkImageProvider(imageUrl), fit: BoxFit.cover) : null,
                                          ),
                                        ),
                                      ),
                                      VDiv(4),
                                      Text(
                                        name ?? 'Unknown',
                                        style: Manager.captionStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  Positioned.fill(
                                    child: mat.Material(
                                      color: Colors.transparent,
                                      child: mat.InkWell(
                                        hoverColor: Manager.accentColor.lightest.withOpacity(.2),
                                        splashColor: Manager.accentColor.light.withOpacity(.2),
                                        onTap: () {
                                          // open link of node.siteUrl if available
                                          if (node.siteUrl != null && node.siteUrl!.isNotEmpty) //
                                            launchUrl(Uri.parse(node.siteUrl!));
                                        },
                                        borderRadius: BorderRadius.circular(ScreenUtils.kEpisodeCardBorderRadius),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    });
              }),
        ),
      );
    }

    return [
      WrappedHyperlinkButton(
        tooltip: 'Open your Favourites page on Anilist',
        url: 'https://anilist.co/user/${anilistProvider.currentUser?.id}/favorites',
        text: 'Favourites',
        icon: Icon(
          mat.Icons.open_in_new,
          color: Manager.accentColor.lightest,
        ),
      ),
      //
      // Favorite Anime section
      if (favorites.anime?.nodes != null && favorites.anime!.nodes!.isNotEmpty) ...[
        VDiv(8),
        Text(
          'Favorite Anime',
          style: Manager.bodyStrongStyle,
        ),
        VDiv(8),
        buildList(favorites.anime!),
      ],
      //
      // Favorite Staff section
      if (favorites.characters?.nodes != null && favorites.characters!.nodes!.isNotEmpty) ...[
        VDiv(8),
        Text(
          'Favorite Characters',
          style: Manager.bodyStrongStyle,
        ),
        VDiv(8),
        buildList(favorites.characters!),
      ],
      if (favorites.staff?.nodes != null && favorites.staff!.nodes!.isNotEmpty) ...[
        VDiv(8),
        Text(
          'Favorite Staff',
          style: Manager.bodyStrongStyle,
        ),
        VDiv(8),
        buildList(favorites.staff!),
      ],
    ];
  }

  //

  Widget _statCard(String title, num value, {Widget? icon, String suffix = ''}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          borderRadius: BorderRadius.circular(ScreenUtils.kStatCardBorderRadius),
          border: Border.all(color: Manager.accentColor.lighter),
        ),
        width: ScreenUtils.kMinStatCardWidth,
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
                  Builder(builder: (context) {
                    return AnimatedStatCounter<num>(
                      targetValue: value,
                      isDouble: value is double,
                      suffix: suffix.startsWith(" ") ? suffix : ' $suffix',
                      textStyle: Manager.bodyLargeStyle,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //

  // Add this method to your AccountsScreenState class

  String _convertMarkupToHtml(String text, double maxwidth) {
    // Replace YouTube links
    text = RegExp(r'youtube\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<iframe width="$maxwidth" height="${maxwidth * 0.5625}" src="https://www.youtube.com/embed/${match.group(1)?.split("/").last}" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>',
          ),
        );

    // Replace images
    text = RegExp(r'img220\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<img src="${match.group(1)}" style="max-width:220px;" />',
          ),
        );

    // Replace markdown links [text](url)
    text = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<a href="${match.group(2)}">${match.group(1)}</a>',
          ),
        );

    // Replace webm videos
    text = RegExp(r'webm\(([^)]+)\)').allMatches(text).fold(
          text,
          (t, match) => t.replaceRange(
            match.start,
            match.end,
            '<unsupported>Unfortunately, webm videos are not supported on Flutter Windows</unsupported>',
          ),
        );

    // Replace code blocks with HTML
    text = text.replaceAllMapped(
      RegExp(r'`([\s\S]*?)`', dotAll: true),
      (match) => match.group(1)!,
    );

    // Bold text
    text = text.replaceAllMapped(
      RegExp(r'__([^_]+)__'),
      (match) => '<b>${match.group(1)}</b>',
    );

    // Italic text
    text = text.replaceAllMapped(
      RegExp(r'_([^_]+)_'),
      (match) => '<i>${match.group(1)}</i>',
    );

    // Strikethrough text
    text = text.replaceAllMapped(
      RegExp(r'~~([^~]+)~~'),
      (match) => '<s>${match.group(1)}</s>',
    );

    // Spoiler text
    text = text.replaceAllMapped(
      RegExp(r'~!([^~]+)!~'),
      (match) => '<spoiler>${match.group(1)}</spoiler>',
    );

    // Code blocks
    final codeBlockPattern = RegExp(r'(^> .+$\n?)+', multiLine: true);
    text = text.replaceAllMapped(codeBlockPattern, (match) {
      final codeContent = match.group(0)!.split('\n').where((line) => line.trim().isNotEmpty).map((line) => line.startsWith('> ') ? line.substring(2) : line).join('<br>'); // Use <br> directly for code block newlines
      return '<code>$codeContent</code>';
    });

    // Preserve newlines (convert to HTML line breaks)
    text = text.replaceAll('\n', '<br>');

    return text;
  }

  (String, int) _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) return (' Days', days);
    if (hours > 0) return (' Hours', hours);
    return (' Minutes', minutes);
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
