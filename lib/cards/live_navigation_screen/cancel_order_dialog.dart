import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Premium glassmorphic cancel-order confirmation dialog.
///
/// Calls `POST /customer_orders/{id}/cancel` via the notifier
/// and navigates back to home on success.
void showCancelOrderDialog(BuildContext context, WidgetRef ref) {
  final colors = C.of(context);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cancel Order',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, anim, secondaryAnim) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: _CancelDialogBody(ref: ref, colors: colors),
      );
    },
  );
}

class _CancelDialogBody extends StatefulWidget {
  final WidgetRef ref;
  final C colors;

  const _CancelDialogBody({required this.ref, required this.colors});

  @override
  State<_CancelDialogBody> createState() => _CancelDialogBodyState();
}

class _CancelDialogBodyState extends State<_CancelDialogBody> {
  bool _isLoading = false;
  int _cancelCount = 0;
  bool _isCountLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCancelCount();
  }

  Future<void> _loadCancelCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final savedDate = prefs.getString('last_cancel_date');
      if (savedDate == today) {
        _cancelCount = prefs.getInt('cancel_count_today') ?? 0;
      } else {
        _cancelCount = 0;
      }
      if (mounted) setState(() => _isCountLoaded = true);
    } catch (e) {
      if (mounted) setState(() => _isCountLoaded = true);
    }
  }

  Future<void> _executeCancellation() async {
    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    final result =
        await widget.ref.read(activeDeliveryProvider.notifier).cancelDelivery();

    if (!mounted) return;

    if (result.ok) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final today = DateTime.now().toIso8601String().split('T')[0];
        await prefs.setString('last_cancel_date', today);
        await prefs.setInt('cancel_count_today', _cancelCount + 1);
      } catch (e) {
        // ignore error
      }

      // Close dialog, then navigate home
      Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // The ref listener in LiveNavigationScreen will auto-pop
        // when state becomes null, navigating to /home.
      }
    } else {
      Navigator.of(context).pop();
      if (mounted) {
        // Don't show snackbar for 403 — the global interceptor handles it
        if (result.errorMessage != null &&
            !result.errorMessage!.contains('403')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: ${result.errorMessage}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Stack(
      children: [
        // ── Frosted background ──
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withAlpha(80)),
          ),
        ),

        // ── Dialog ──
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: colors.surfaceElevated.withAlpha(230),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: colors.isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.black.withAlpha(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(colors.isDark ? 120 : 40),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: AppColors.error.withAlpha(20),
                  blurRadius: 60,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Warning icon with glow ──
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error.withAlpha(40),
                          AppColors.error.withAlpha(15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withAlpha(30),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Title ──
                  Text(
                    'Cancel Order?',
                    style: AppTextStyles.headingMd.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Cancel Count Warning & Progress ──
                  if (_isCountLoaded) ...[
                    Builder(builder: (context) {
                      final int cancelLimit = 3;
                      final int remainingCancels = cancelLimit - _cancelCount;
                      final double progress = (_cancelCount / cancelLimit).clamp(0.0, 1.0);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.isDark ? AppColors.warning.withAlpha(20) : AppColors.warning.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.warning.withAlpha(80), 
                            width: 1.5
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cancellation Policy',
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.isDark ? AppColors.warning : AppColors.warning.withAlpha(220),
                                  ),
                                ),
                                Text(
                                  '$_cancelCount / $cancelLimit',
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.isDark ? AppColors.warning : AppColors.warning.withAlpha(255),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: AppColors.warning.withAlpha(40),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  remainingCancels <= 1 ? AppColors.error : AppColors.warning,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (remainingCancels > 1)
                              Text(
                                'If you cancel ${remainingCancels - 1} more time(s) within 24 hours, your account will be temporarily suspended.',
                                style: AppTextStyles.caption.copyWith(
                                  color: colors.textSecondary,
                                  height: 1.4,
                                ),
                              )
                            else
                              Text(
                                'WARNING: Canceling this order will result in an immediate 24-hour account suspension!',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    Text(
                      'Are you sure you want to cancel this order? '
                      'Excessive cancellations may result in a temporary account suspension.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── Buttons ──
                  Row(
                    children: [
                      // Keep Order
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: colors.blush, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                'Keep Order',
                                style: AppTextStyles.buttonText.copyWith(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Yes, Cancel
                      Expanded(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _executeCancellation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error.withAlpha(
                                      _isLoading ? 100 : 200),
                                  AppColors.error.withAlpha(
                                      _isLoading ? 60 : 140),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.error.withAlpha(80),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.error.withAlpha(30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Yes, Cancel',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
