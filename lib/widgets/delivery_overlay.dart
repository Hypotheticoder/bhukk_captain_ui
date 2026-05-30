import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Floating draggable bubble that appears when a delivery is active.
/// Lives in [MainShell] and persists across all tab screens.
class DeliveryOverlay extends ConsumerStatefulWidget {
  const DeliveryOverlay({super.key});

  @override
  ConsumerState<DeliveryOverlay> createState() => _DeliveryOverlayState();
}

class _DeliveryOverlayState extends ConsumerState<DeliveryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Draggable position
  double _dx = 16;
  double _dy = 120;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = ref.watch(activeDeliveryProvider);

    if (delivery == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      right: _dx,
      top: _dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _dx = (_dx - details.delta.dx).clamp(0, screenWidth - 72);
            _dy = (_dy + details.delta.dy).clamp(
              MediaQuery.of(context).padding.top + 10,
              screenHeight - 200,
            );
          });
        },
        onTap: () {
          final currentPath = GoRouterState.of(context).uri.path;
          if (!currentPath.startsWith('/home/live_navigation')) {
            context.push('/home/live_navigation');
          }
        },
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(
                      (120 * _pulseAnim.value).toInt(),
                    ),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow ring
                  Container(
                    width: 60 + (6 * _pulseAnim.value),
                    height: 60 + (6 * _pulseAnim.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(
                          (40 * _pulseAnim.value).toInt(),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                  // Bike icon
                  const Icon(
                    Icons.delivery_dining_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  // Status dot
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _statusColor(delivery.status),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _statusColor(delivery.status).withAlpha(100),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.headingToStore:
        return AppColors.warning;
      case DeliveryStatus.arrivedAtStore:
        return AppColors.warning;
      case DeliveryStatus.pickedUp:
        return AppColors.info;
      case DeliveryStatus.enRoute:
        return AppColors.info;
      case DeliveryStatus.arriving:
        return AppColors.success;
      case DeliveryStatus.delivered:
        return AppColors.success;
    }
  }
}
