import 'dart:async';
import 'package:bhukkdelivery/cards/live_navigation_screen/customer_info_card.dart'; // ContactInfoCard
import 'package:bhukkdelivery/cards/live_navigation_screen/delivery_timeline_card.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/live_stats_bar_card.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/map_hero_card.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/navigation_actions_card.dart';
import 'package:bhukkdelivery/cards/live_navigation_screen/route_details_card.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/providers/delivery/fullscreen_nav_provider.dart';
import 'package:bhukkdelivery/services/live_tracking_service.dart';
import 'package:bhukkdelivery/services/background_notification_service.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/widgets/support_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LiveNavigationScreen extends ConsumerStatefulWidget {
  const LiveNavigationScreen({super.key});

  @override
  ConsumerState<LiveNavigationScreen> createState() =>
      _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends ConsumerState<LiveNavigationScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late AnimationController _bikeController;
  late AnimationController _entryController;
  late Animation<double> _pulseAnim;
  late Animation<double> _bikeProgress;

  bool _isFullscreenMap = false;

  void _toggleFullscreen() {
    setState(() => _isFullscreenMap = !_isFullscreenMap);
    // Toggle the global provider so MainShell hides/shows bottom nav
    ref.read(fullscreenNavProvider.notifier).set(_isFullscreenMap);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bikeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _bikeProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bikeController, curve: Curves.easeInOut),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    // Listen for customer cancellation to show a SnackBar
    _listenToCancellation();
  }

  StreamSubscription? _cancelSub;
  void _listenToCancellation() {
    _cancelSub = LiveTrackingService.instance.eventStream.listen((data) {
      if (!mounted) return;
      if (data['event'] == 'CUSTOMER_CANCELLED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'The customer cancelled this order. Returning to map.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSub?.cancel();
    _pulseController.dispose();
    _bikeController.dispose();
    _entryController.dispose();
    super.dispose();
  }



  Animation<double> _stagger(int index) {
    final start = (index * 0.12).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _fadeSlide(int index, Widget child) {
    final anim = _stagger(index);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final delivery = ref.watch(activeDeliveryProvider);

    // Auto-navigate away when delivery completes — disposes the map
    // and all its timers/interpolation immediately to save map API calls.
    ref.listen(activeDeliveryProvider, (prev, next) {
      if (prev != null && next == null && mounted) {
        // Delivery just completed — pop back to home after a brief tick
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/home');
        });
      } else if (next != null) {
        BackgroundNotificationService.instance.updateNotification(
          statusLabel: next.statusLabel,
          actionLabel: next.actionButtonLabel,
          storeName: next.storeName,
          isPickup: next.isPickupPhase,
          address: next.isPickupPhase ? next.storeAddress : next.customerAddress,
        );
      }
    });

    if (delivery == null) {
      // Fallback: still show completion UI if navigated here directly
      // but auto-pop will fire on the next frame.
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "Order Completed!",
                style: AppTextStyles.headingLg.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: AppButtonStyles.primaryButton,
                  child: const Text(
                    "Return to Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bool hideMap = delivery.status == DeliveryStatus.arriving ||
        delivery.status == DeliveryStatus.delivered;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // ── Map + content column ───────────────────────────
          // The MapHeroCard is ALWAYS at the same tree position
          // so Flutter preserves its State across fullscreen toggles.
          Column(
            children: [
              // 1a. Map or Arrived banner
              if (!hideMap)
                Expanded(
                  flex: _isFullscreenMap ? 1 : 0,
                  child: MapHeroCard(
                    pulseAnim: _pulseAnim,
                    bikeProgress: _bikeProgress,
                    isFullscreen: _isFullscreenMap,
                    onToggleFullscreen: _toggleFullscreen,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + AppSpacing.xl,
                    bottom: AppSpacing.xl,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.where_to_vote_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "Arrived at Destination",
                        style: AppTextStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Please complete the handover process.",
                        style: AppTextStyles.bodySm.copyWith(
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),

              // 1b. Scrollable content (hidden in fullscreen mode)
              if (!_isFullscreenMap)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _entryController,
                    builder: (context, _) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.xxl),
                              _fadeSlide(0, const LiveStatsBarCard()),
                              const SizedBox(height: AppSpacing.xxl),
                              _fadeSlide(
                                1,
                                DeliveryTimelineCard(pulseAnim: _pulseAnim),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              _fadeSlide(2, const RouteDetailsCard()),
                              const SizedBox(height: AppSpacing.xxl),
                              _fadeSlide(3, const ContactInfoCard()),
                              const SizedBox(height: AppSpacing.xxl),
                              _fadeSlide(4, const NavigationActionsCard()),
                              const SizedBox(height: 140),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          // Floating back button (hidden in fullscreen)
          if (!_isFullscreenMap)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.isDark ? AppColors.darkCyan : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          // ── Floating support button (bottom-right) ──
          if (!_isFullscreenMap)
            Positioned(
              bottom: 100,
              right: 16,
              child: SupportFab(),
            ),
        ],
      ),
    );
  }
}
