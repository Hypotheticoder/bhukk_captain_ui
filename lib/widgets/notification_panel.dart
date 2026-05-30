import 'package:bhukkdelivery/models/app_notification.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Notifier ──
class NotificationNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => const [
    AppNotification(
      id: '1',
      title: 'New order nearby!',
      body: 'Biryani Blues on FC Road has a ₹195 order waiting.',
      time: '2 min ago',
      type: NotificationType.order,
    ),
    AppNotification(
      id: '2',
      title: 'Weekly payout processed',
      body: 'Your ₹8,070 earnings have been transferred to your bank.',
      time: '1 hr ago',
      type: NotificationType.earnings,
      isRead: true,
    ),
    AppNotification(
      id: '3',
      title: '🎉 Weekend Bonus Active',
      body: 'Complete 10 deliveries this weekend to earn an extra ₹500!',
      time: '3 hrs ago',
      type: NotificationType.promo,
    ),
    AppNotification(
      id: '4',
      title: 'Profile verified',
      body: 'Your documents have been approved. You\'re all set!',
      time: 'Yesterday',
      type: NotificationType.system,
      isRead: true,
    ),
    AppNotification(
      id: '5',
      title: 'Surge zone alert',
      body: 'High demand in Koregaon Park area. Head there for extra earnings!',
      time: 'Yesterday',
      type: NotificationType.promo,
    ),
  ];

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<AppNotification>>(
      NotificationNotifier.new,
    );

// ── Top-slide notification panel ──
class NotificationPanel extends ConsumerStatefulWidget {
  const NotificationPanel({super.key});

  /// Opens the notification panel as a full-screen overlay that slides from top
  static void show(BuildContext context) {
    Navigator.of(
      context,
    ).push(_TopSlideRoute(builder: (_) => const NotificationPanel()));
  }

  @override
  ConsumerState<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends ConsumerState<NotificationPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final notifications = ref.watch(notificationProvider);
    final unreadCount = ref.watch(notificationProvider.notifier).unreadCount;
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Scrim
            GestureDetector(
              onTap: _close,
              child: Container(
                color: Colors.black.withAlpha((_fadeAnim.value * 120).toInt()),
              ),
            ),

            // Panel sliding from top
            SlideTransition(
              position: _slideAnim,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          topPadding > 0 ? AppSpacing.sm : AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    "Notifications",
                                    style: AppTextStyles.headingSm.copyWith(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  if (unreadCount > 0) ...[
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm + 2,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: AppRadius.pillAll,
                                      ),
                                      child: Text(
                                        '$unreadCount new',
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (unreadCount > 0)
                              GestureDetector(
                                onTap: () => ref
                                    .read(notificationProvider.notifier)
                                    .markAllAsRead(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    "Read all",
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: AppSpacing.xs),
                            // Close button
                            GestureDetector(
                              onTap: _close,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: colors.blush.withAlpha(
                                    colors.isDark ? 50 : 120,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: colors.divider, height: 1),

                      // Notification list
                      Flexible(
                        child: notifications.isEmpty
                            ? _buildEmpty(colors)
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                  bottom: AppSpacing.xxl,
                                ),
                                itemCount: notifications.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.divider,
                                  height: 1,
                                  indent: AppSpacing.xl + 44,
                                ),
                                itemBuilder: (context, index) {
                                  return _AnimatedNotificationTile(
                                    notification: notifications[index],
                                    index: index,
                                  );
                                },
                              ),
                      ),

                      // Drag handle at bottom
                      GestureDetector(
                        onVerticalDragUpdate: (details) {
                          if (details.primaryDelta != null &&
                              details.primaryDelta! < -5) {
                            _close();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: colors.blush,
                                borderRadius: AppRadius.pillAll,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(C colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, v, child) =>
                Transform.scale(scale: v, child: child),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: colors.textTertiary.withAlpha(100),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "All caught up!",
            style: AppTextStyles.bodyMd.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ── Staggered tile with slide-in animation ──
class _AnimatedNotificationTile extends StatelessWidget {
  final AppNotification notification;
  final int index;

  const _AnimatedNotificationTile({
    required this.notification,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: _NotificationTile(notification: notification),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = C.of(context);
    final n = notification;

    final (IconData icon, Color color) = switch (n.type) {
      NotificationType.order => (
        Icons.delivery_dining_rounded,
        AppColors.warning,
      ),
      NotificationType.earnings => (
        Icons.account_balance_wallet_rounded,
        AppColors.success,
      ),
      NotificationType.promo => (
        Icons.local_offer_rounded,
        AppColors.primaryAccent,
      ),
      NotificationType.system => (Icons.info_outline_rounded, AppColors.info),
    };

    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationProvider.notifier).dismiss(n.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        color: AppColors.error.withAlpha(30),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 22,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (!n.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(n.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: n.isRead
              ? Colors.transparent
              : (colors.isDark
                    ? AppColors.primary.withAlpha(10)
                    : AppColors.primary.withAlpha(6)),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(colors.isDark ? 30 : 15),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: AppTextStyles.bodySm.copyWith(
                              color: colors.textPrimary,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, v, child) =>
                                Transform.scale(scale: v, child: child),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(80),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textTertiary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.time,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textTertiary.withAlpha(150),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom route that slides from top ──
class _TopSlideRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;

  _TopSlideRoute({required this.builder});

  @override
  Color? get barrierColor => null; // We handle the scrim ourselves
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'Dismiss notifications';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }
}
