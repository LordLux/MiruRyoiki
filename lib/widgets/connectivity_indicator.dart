import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:material_symbols_icons/symbols.dart';

import '../services/connectivity/connectivity_service.dart';

/// A widget that shows an offline indicator when there's no internet connection
class ConnectivityIndicator extends StatelessWidget {
  final Widget? child;
  final bool showWhenOnline;

  const ConnectivityIndicator({
    super.key,
    this.child,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (connectivityService.isOnline && !showWhenOnline) {
          return child ?? const SizedBox.shrink();
        }

        return _buildIndicator(context, connectivityService.isOnline);
      },
      child: child,
    );
  }

  Widget _buildIndicator(BuildContext context, bool isOnline) {
    if (isOnline && !showWhenOnline) {
      return child ?? const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.red.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Symbols.wifi : Symbols.wifi_off,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A banner that appears at the top when offline
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  late final ConnectivityService _connectivityService;
  late bool wasOnline;
  bool _showTransientOnlineBanner = false;

  @override
  void initState() {
    super.initState();
    _connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    wasOnline = _connectivityService.isOnline;
    _connectivityService.isOnlineNotifier.addListener(_handleOnlineChanged);
  }

  void _handleOnlineChanged() {
    final isOnline = _connectivityService.isOnlineNotifier.value;
    final changed = isOnline != wasOnline;
    if (!changed) return;

    wasOnline = isOnline;

    if (isOnline) {
      // show banner for 3s when we just came back online
      setState(() => _showTransientOnlineBanner = true);
      Future.delayed(const Duration(seconds: 3)).then((_) {
        if (!mounted) return;
        setState(() => _showTransientOnlineBanner = false);
      });
    } else {
      // go offline: ensure banner is visible
      setState(() => _showTransientOnlineBanner = false);
    }
  }

  @override
  void dispose() {
    _connectivityService.isOnlineNotifier.removeListener(_handleOnlineChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = _connectivityService;
    return ValueListenableBuilder<bool>(
      valueListenable: connectivityService.isOnlineNotifier,
      builder: (context, isOnline, child) {
        final Widget res = Container(
          width: double.infinity,
          color: isOnline ? Colors.green : Colors.orange.shade600,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Icon(
                isOnline ? Symbols.wifi : Symbols.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isOnline ? "You are back online!" : "You are currently offline. Some features may be limited.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isOnline) Consumer<ConnectivityService>(
                builder: (context, connectivityService, _) {
                  return AnimatedBuilder(
                    animation: connectivityService.isCheckingConnectivity ? const AlwaysStoppedAnimation(0.0) : const AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end: connectivityService.isCheckingConnectivity ? double.infinity : 1.0,
                        ),
                        duration: connectivityService.isCheckingConnectivity ? const Duration(seconds: 1) : const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Transform.rotate(
                            angle: (value % 1.0) * 2 * 3.14159,
                            child: fluent.IconButton(
                              onPressed: connectivityService.isCheckingConnectivity ? null : () => connectivityService.checkConnectivity(),
                              icon: const Icon(
                                fluent.FluentIcons.refresh,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );

        // If online, show the transient banner only when flagged; otherwise hide
        if (isOnline) {
          return _showTransientOnlineBanner ? res : const SizedBox.shrink();
        }

        // If offline, always show the banner
        return res;
      },
    );
  }
}

/// A simple connectivity status badge for use in app bars or status areas
class ConnectivityStatusBadge extends StatelessWidget {
  final bool compact;

  const ConnectivityStatusBadge({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    return ValueListenableBuilder<bool>(
      valueListenable: connectivityService.isOnlineNotifier,
      builder: (context, isOnline, child) {
        return fluent.Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 8,
            vertical: compact ? 2 : 4,
          ),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOnline ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Symbols.wifi : Symbols.wifi_off,
                color: isOnline ? Colors.green : Colors.red,
                size: compact ? 12 : 14,
              ),
              if (!compact) ...[
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
