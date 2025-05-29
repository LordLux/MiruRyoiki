import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:miruryoiki/services/anilist/provider.dart';
import 'package:provider/provider.dart';

import '../utils/logging.dart';
import '../utils/screen_utils.dart';
import '../widgets/buttons/loading_button.dart';
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
    final bool isButtonDisabled = isLocalLoading || anilistProvider.isLoading || anilistProvider.isLoggedIn;

    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Accounts'),
          ],
        ),
      ),
      content: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
            SizedBox(
              height: 1500,
              child: SettingsCard(children: [
                Expanded(child: AnilistSettingsScreen(
                  onLogout: () async {
                    setState(() {
                      isLocalLoading = false;
                    });
                  },
                )),
              ]),
            )
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
              child: AnilistLogo(),
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

class AnilistLogo extends StatelessWidget {
  const AnilistLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return ScalableImageWidget.fromSISource(
      scale: 1,
      si: ScalableImageSource.fromSvgHttpUrl(
        Uri.parse('https://anilist.co/img/icons/icon.svg'),
      ),
      onError: (p0) => const SizedBox.shrink(),
    );
  }
}
