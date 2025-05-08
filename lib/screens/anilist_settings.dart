import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import '../../services/anilist/provider.dart';
import '../manager.dart';
import 'accounts.dart';

class AnilistSettingsScreen extends StatelessWidget {
  final Future<void> Function() onLogout;

  const AnilistSettingsScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final anilistProvider = context.watch<AnilistProvider>();

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const PageHeader(
        title: AnilistCardTitle(),
      ),
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      if (anilistProvider.isLoading)
                        return const Center(child: ProgressRing());
                      else if (anilistProvider.isLoggedIn && anilistProvider.currentUser != null) //
                        return _buildUserInfo(context, anilistProvider);
                      return SizedBox.shrink();
                    })
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (anilistProvider.isLoggedIn) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Settings',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      const SizedBox(height: 16),
                      ToggleSwitch(
                        checked: true,
                        content: const Text('Automatically link local series to Anilist'),
                        onChanged: (value) {
                          // TODO: Implement setting
                        },
                      ),
                      const SizedBox(height: 8),
                      ToggleSwitch(
                        checked: true,
                        content: const Text('Update watch progress on Anilist'),
                        onChanged: (value) {
                          // TODO: Implement setting
                        },
                      ),
                      const SizedBox(height: 8),
                      ToggleSwitch(
                        checked: true,
                        content: const Text('Download metadata (posters, descriptions)'),
                        onChanged: (value) {
                          // TODO: Implement setting
                        },
                      ),
                      const SizedBox(height: 16),
                      Button(
                        child: const Text('Refresh All Metadata'),
                        onPressed: () {
                          // TODO: Implement refresh
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Anilist',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          for (final list in anilistProvider.userLists.entries) _buildListChip(context, list.value),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Button(
                        child: const Text('Refresh Lists'),
                        onPressed: () {
                          anilistProvider.refreshUserLists();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AnilistProvider provider) {
    final user = provider.currentUser!;

    return Container(
      decoration: BoxDecoration(
        image: user.bannerImage != null
            ? DecorationImage(
                image: NetworkImage(user.bannerImage!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (user.avatar != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(user.avatar!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Manager.accentColor,
                  ),
                  child: const Center(
                    child: Icon(FluentIcons.contact, color: Colors.white),
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('Anilist ID: ${user.id}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Button(
            child: const Text('Logout'),
            onPressed: () async {
              await provider.logout();
              onLogout.call();
              print('Logged out of Anilist');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListChip(BuildContext context, dynamic list) {
    return Chip(
      text: Text(list.name),
      trailing: Text(list.entries.length.toString()),
    );
  }
}

Widget Chip({
  required Widget text,
  Widget? trailing,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Manager.accentColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        text,
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    ),
  );
}
