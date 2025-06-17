import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/utils/time_utils.dart';
import 'package:recase/recase.dart';
import '../services/anilist/provider/anilist_provider.dart';
import 'package:provider/provider.dart';

import '../utils/logging.dart';
import '../utils/screen_utils.dart';
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
        children: [],
      ),
      infobar: (deferredPointerLink) => MiruRyoikiInfobar(
        isProfilePicture: true,
        content: const Text('test'),
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
      content: AnilistAccount(anilistProvider),
    );
  }

  Widget AnilistAccount(AnilistProvider anilistProvider) {
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
                  // filledColor: Color(0xFF02a9ff),
                  onPressed: () async {
                    if (isLocalLoading) return;

                    isLocalLoading = true;

                    await anilistProvider.login();
                    logInfo('Logging in to Anilist...');
                  },
                ),
              ),
            ])
          ] else
            // Logged in
            ...[
            SettingsCard(children: [
              AnilistSettingsScreen(
                onLogout: () async {
                  setState(() {
                    isLocalLoading = false;
                  });
                },
              ),
            ])
          ]
        ],
      ),
    );
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
