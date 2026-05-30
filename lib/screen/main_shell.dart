import 'package:bhukkdelivery/providers/delivery/fullscreen_nav_provider.dart';
import 'package:bhukkdelivery/widgets/bottom_nav_bar.dart';
import 'package:bhukkdelivery/widgets/delivery_overlay.dart';
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:bhukkdelivery/services/driver_notification_service.dart';
import 'package:bhukkdelivery/services/background_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  DateTime? _lastBackPressTime;
  static const MethodChannel _appLifecycleChannel =
      MethodChannel('com.bhukk.delivery/app_lifecyle');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DriverNotificationService.instance.syncToken(ApiConfig.dio);
      BackgroundNotificationService.instance.requestPermissionsAndCreateChannel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFullscreenNav = ref.watch(fullscreenNavProvider);

    return PopScope(
      canPop: false, // Shell locks native popping completely
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. Inspect the active branch's sub-navigator state to see if it can pop natively.
        final activeBranch = widget.navigationShell.route.branches[widget.navigationShell.currentIndex];
        final currentNavigatorState = activeBranch.navigatorKey.currentState;
        
        if (currentNavigatorState != null && currentNavigatorState.canPop()) {
          currentNavigatorState.pop(); // Safely pop sub-views natively
          return;
        }

        // 2. If no sub-pages are open, check if we are on a secondary tab root (e.g., Profile).
        // If yes, smoothly shift the user back to the Home Dashboard.
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          return;
        }

        // 3. If we are on the Home Tab Root, execute the Double-Tap to Exit / Minimize logic.
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Press back again to exit',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                backgroundColor: Colors.black.withAlpha(200),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 100, left: 80, right: 80),
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }
          return;
        }

        // 4. Minimize App natively
        try {
          await _appLifecycleChannel.invokeMethod('minimizeApp');
        } catch (e) {
          debugPrint("Failed to minimize app: $e");
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            widget.navigationShell,
            const DeliveryOverlay(),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: isFullscreenNav
            ? null
            : FloatingBottomNavBar(
                currentIndex: widget.navigationShell.currentIndex,
                onTap: (index) {
                  widget.navigationShell.goBranch(
                    index,
                    initialLocation: index == widget.navigationShell.currentIndex,
                  );
                },
              ),
      ),
    );
  }
}
