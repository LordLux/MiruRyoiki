import 'package:fluent_ui/fluent_ui.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:miruryoiki/services/anilist/provider.dart';
import 'package:provider/provider.dart';

import 'anilist_settings.dart';
import 'settings.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  Widget build(BuildContext context) {
    final anilistProvider = Provider.of<AnilistProvider>(context, listen: false);
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Accounts'),
      ),
      content: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!anilistProvider.isLoggedIn)
            SettingsCard(children: [
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Transform.scale(
                        scale: 1.25,
                        child: ScalableImageWidget.fromSISource(
                          scale: 1,
                          si: ScalableImageSource.fromSvgHttpUrl(
                            Uri.parse('https://anilist.co/img/icons/icon.svg'),
                          ),
                          onError: (p0) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Anilist',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Connect your Anilist account to sync your media library.',
                style: FluentTheme.of(context).typography.body,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Button(
                  onPressed: () {},
                  child: const Text('Connect Anilist'),
                ),
              ),
            ]),
          if (!anilistProvider.isLoggedIn)
            SizedBox(
              height: 500,
              child: SettingsCard(children: [
                Expanded(child: AnilistSettingsScreen()),
              ]),
            )
        ],
      ),
    );
  }
}
