import 'package:bhukkdelivery/providers/home/rider_provider.dart';
import 'package:bhukkdelivery/cards/home/new_order_popup_helper.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusCard extends ConsumerStatefulWidget {
  final String serviceType;

  const StatusCard({super.key, this.serviceType = 'food'});

  @override
  ConsumerState<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends ConsumerState<StatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(riderStatusProvider);
    final colors = C.of(context);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: isOnline ? AppColors.primary : colors.surfaceElevated,
            borderRadius: AppRadius.xlAll,
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? AppColors.primary.withAlpha(
                        (60 + 60 * _glowAnim.value).toInt(),
                      )
                    : colors.cardShadow(0.04),
                blurRadius: isOnline ? 30 : 15,
                offset: const Offset(0, 10),
                spreadRadius: isOnline ? 4 : 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline
                          ? Colors.white.withAlpha(30)
                          : colors.blush.withAlpha(colors.isDark ? 60 : 140),
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? AppColors.online
                              : AppColors.offline,
                          boxShadow: isOnline
                              ? [
                                  BoxShadow(
                                    color: AppColors.online.withAlpha(
                                      (100 * _glowAnim.value).toInt(),
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? "You are Online" : "You are Offline",
                        style: AppTextStyles.headingSm.copyWith(
                          color: isOnline
                              ? AppColors.textOnPrimary
                              : colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isOnline
                            ? "Accepting orders..."
                            : "Toggle to go online",
                        style: AppTextStyles.bodySm.copyWith(
                          color: isOnline
                              ? Colors.white70
                              : colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  final wasOffline = !ref.read(riderStatusProvider);
                  ref.read(riderStatusProvider.notifier).toggle();

                  // When going online → simulate incoming orders after a delay
                  if (wasOffline) {
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (!context.mounted) return;
                      showNewOrderPopup(context, ref, widget.serviceType);
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: 62,
                  height: 36,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.pillAll,
                    color: isOnline ? Colors.white.withAlpha(40) : colors.blush,
                    border: Border.all(
                      color: isOnline
                          ? Colors.white.withAlpha(60)
                          : colors.blush,
                      width: 1,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutBack,
                    alignment: isOnline
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline ? colors.surface : AppColors.offline,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isOnline ? Icons.power_settings_new : Icons.close,
                          size: 16,
                          color: isOnline ? AppColors.primary : colors.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
