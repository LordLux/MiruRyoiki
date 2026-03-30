import 'package:fluent_ui/fluent_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../manager.dart';
import '../services/anilist/anilist_availability.dart';
import '../services/connectivity/connectivity_service.dart';
import 'buttons/hyperlink.dart';

/// A reusable banner widget for AniList service unavailability or offline state.
///
/// Shows a centered icon, title, description, a "Try Again" button, and
/// optionally a link to AniList's Discord status channel.
class ServiceUnavailableBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServiceUnavailableBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final connectivity = ConnectivityService();

    return ValueListenableBuilder<bool>(
      valueListenable: connectivity.isOnlineNotifier,
      builder: (context, isOnline, _) {
        if (!isOnline) return _OfflineBannerContent(onRetry: onRetry);

        return ValueListenableBuilder<bool>(
          valueListenable: AnilistAvailabilityService().unavailableNotifier,
          builder: (context, isUnavailable, _) {
            if (isUnavailable) return _AnilistUnavailableBannerContent(onRetry: onRetry);
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _AnilistUnavailableBannerContent extends StatelessWidget {
  final VoidCallback? onRetry;
  const _AnilistUnavailableBannerContent({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _BannerLayout(
      icon: Symbols.cloud_off,
      iconColor: Manager.currentDominantColor ?? Manager.accentColor,
      title: 'AniList Service Unavailable',
      description: 'The AniList API has been temporarily disabled due to stability issues. This is an external factor and not a bug in the app.',
      onRetry: () {
        AnilistAvailabilityService().reset();
        onRetry?.call();
      },
      footer: Transform.translate(
        offset: Offset(25, 0),
        child: WrappedHyperlinkButton(
          url: '', // URL is handled in the onPressed to attempt the app link
          onPressed: () async {
            final Uri appUri = Uri.parse('discord://-/channels/210521487378087947/457951807046549525'); // Discord deep link to AniList status channel
            final Uri webUri = Uri.parse('https://discord.gg/anilist'); // Fallback web URL for the AniList Discord server
            try {
              // Try launching the custom app URI
              final bool launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);

              // Launch the web fallback if Discord isn't installed
              if (!launched) await launchDiscordAnilistWeb(webUri);
            } catch (e) {
              await launchDiscordAnilistWeb(webUri);
            }
          },
          icon: Icon(Symbols.forum, size: 18, color: Manager.accentColor),
          text: '    Check AniList Discord Status',
          style: TextStyle(color: Manager.accentColor, fontSize: 13),
        ),
      ),
    );
  }

  Future<bool> launchDiscordAnilistWeb(Uri webUri) {
    return launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
  }
}

class _OfflineBannerContent extends StatelessWidget {
  final VoidCallback? onRetry;
  const _OfflineBannerContent({this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _BannerLayout(
      icon: Symbols.wifi_off,
      iconColor: Colors.orange,
      title: 'You Are Offline',
      description: 'Please check your internet connection. Online features such as browsing and searching require an active connection.',
      onRetry: () {
        ConnectivityService().checkConnectivity();
        onRetry?.call();
      },
    );
  }
}

class _BannerLayout extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onRetry;
  final Widget? footer;

  const _BannerLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.onRetry,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: iconColor),
            const SizedBox(height: 20),
            Text(
              title,
              style: Manager.subtitleStyle.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onRetry,
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(vertical: 12)),
                    backgroundColor: WidgetStatePropertyAll(Manager.accentColor),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  child: Text('Try Again', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
