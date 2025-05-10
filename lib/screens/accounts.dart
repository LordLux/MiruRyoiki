import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:miruryoiki/services/anilist/provider.dart';
import 'package:provider/provider.dart';

import 'anilist_settings.dart';
import 'settings.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => AccountsScreenState();
}

class AccountsScreenState extends State<AccountsScreen> {
  bool isLocalLoading = false;

  bool showLoggedIn = false;

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
            ToggleSwitch(
                checked: showLoggedIn,
                onChanged: (value) {
                  setState(() {
                    showLoggedIn = value;
                  });
                }),
          ],
        ),
      ),
      content: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!showLoggedIn)
            SettingsCard(children: [
              AnilistCardTitle(),
              const SizedBox(height: 12),
              Text(
                'Connect your Anilist account to sync your media library.',
                style: FluentTheme.of(context).typography.body,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Button(
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: (isLocalLoading || anilistProvider.isLoading) ? 24 : 32,
                      ),
                    ),
                  ),
                  onPressed: isButtonDisabled
                      ? null
                      : () async {
                          if (isLocalLoading) return;

                          isLocalLoading = true;

                          await anilistProvider.login();
                          debugPrint('Logging in to Anilist...');
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Connect Anilist'),
                      if (isLocalLoading || anilistProvider.isLoading) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 25,
                          height: 25,
                          child: ProgressRing(),
                        )
                      ],
                    ],
                  ),
                ),
              ),
            ]),
          if (showLoggedIn)
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
