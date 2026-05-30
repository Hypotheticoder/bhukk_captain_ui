import 'dart:math' as math;
import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full-screen suspension / ban screen.
///
/// Shown when the backend returns 403 due to excessive cancellations
/// or policy violations. The driver can tap "Check Account Status"
/// to ping the server — if the ban has lifted the screen pops to /home.
class SuspendedScreen extends StatefulWidget {
  final String message;
  final String? banType; // 'suspended' or 'banned'

  const SuspendedScreen({
    super.key,
    this.message = 'Your account has been temporarily suspended due to excessive cancellations.',
    this.banType,
  });

  @override
  State<SuspendedScreen> createState() => _SuspendedScreenState();
}

class _SuspendedScreenState extends State<SuspendedScreen>
    with TickerProviderStateMixin {
  bool _isChecking = false;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  bool get _isBanned =>
      widget.banType?.toLowerCase() == 'banned' ||
      widget.message.toLowerCase().contains('banned') ||
      widget.message.toLowerCase().contains('permanently');

  @override
  void initState() {
    super.initState();
    
    // Safety Net: Wipe any lingering active order cache when entering suspended state
    // because the driver cannot fulfill orders while suspended.
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('active_order_id');
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entryFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _checkBanStatus() async {
    setState(() => _isChecking = true);
    HapticFeedback.mediumImpact();

    try {
      // Ping the jobs endpoint — if it returns 200, the ban is lifted.
      // Skip ban redirect to avoid navigation loop from the 403 interceptor.
      await ApiConfig.dio.get(
        '/drivers/jobs/available',
        queryParameters: {'driver_lat': 0, 'driver_lng': 0},
        options: Options(headers: {'X-Skip-Ban-Redirect': 'true'}),
      );

      // Success → ban is lifted!
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account restored! Welcome back.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.go('/home');
      }
    } on DioException catch (e) {
      if (mounted) {
        // Still suspended
        final detail = e.response?.data is Map
            ? e.response!.data['detail']?.toString()
            : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(detail ?? 'Account is still suspended.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isBanned = _isBanned;

    // Color palette — red-toned for suspension, deeper for ban
    final accentColor =
        isBanned ? const Color(0xFFFF3B30) : const Color(0xFFFF6B6B);
    final gradStart =
        isBanned ? const Color(0xFF1A0A0A) : const Color(0xFF0A0E14);
    final gradMid =
        isBanned ? const Color(0xFF2A0E0E) : const Color(0xFF141A22);
    final gradEnd =
        isBanned ? const Color(0xFF120808) : const Color(0xFF0A0E14);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradStart, gradMid, gradEnd],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Floating decorative circles ──
            ..._buildFloatingOrbs(size, accentColor),

            // ── Dot grid pattern ──
            Positioned.fill(
              child: CustomPaint(
                painter: _DotPatternPainter(
                  dotColor: Colors.white.withAlpha(4),
                  spacing: 36,
                ),
              ),
            ),

            // ── Main content ──
            SafeArea(
              child: FadeTransition(
                opacity: _entryFade,
                child: SlideTransition(
                  position: _entrySlide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // ── Icon with pulsing glow ──
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulse = _pulseController.value;
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    accentColor.withAlpha(
                                        (30 + 20 * pulse).toInt()),
                                    accentColor.withAlpha(
                                        (10 + 8 * pulse).toInt()),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor
                                        .withAlpha((40 * pulse).toInt()),
                                    blurRadius: 40 + 20 * pulse,
                                    spreadRadius: 8 * pulse,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withAlpha(25),
                                    border: Border.all(
                                      color: accentColor.withAlpha(60),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    isBanned
                                        ? Icons.gavel_rounded
                                        : Icons.pause_circle_outline_rounded,
                                    color: accentColor,
                                    size: 36,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 36),

                        // ── Title ──
                        Text(
                          isBanned
                              ? 'Account Banned'
                              : 'Account Suspended',
                          style: AppTextStyles.headingLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Message ──
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xl,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(8),
                            ),
                          ),
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: Colors.white.withAlpha(170),
                              height: 1.6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Info chips ──
                        if (!isBanned)
                          Wrap(
                            spacing: 10,
                            children: [
                              _buildInfoChip(
                                icon: Icons.timer_outlined,
                                label: '24h cooldown',
                                color: accentColor,
                              ),
                              _buildInfoChip(
                                icon: Icons.shield_outlined,
                                label: 'Policy violation',
                                color: Colors.white.withAlpha(120),
                              ),
                            ],
                          ),

                        const Spacer(flex: 1),

                        // ── Check Status Button (not for permanent ban) ──
                        if (!isBanned) ...[
                          GestureDetector(
                            onTap: _isChecking ? null : _checkBanStatus,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withAlpha(
                                        _isChecking ? 8 : 18),
                                    Colors.white.withAlpha(
                                        _isChecking ? 4 : 10),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withAlpha(
                                      _isChecking ? 10 : 25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withAlpha(4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isChecking
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white70,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            color:
                                                Colors.white.withAlpha(200),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Check Account Status',
                                            style: AppTextStyles.buttonText
                                                .copyWith(
                                              color: Colors.white
                                                  .withAlpha(220),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // ── Contact Support ──
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Could open a support URL or help screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Please contact support@caby24.com'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: accentColor.withAlpha(50),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.headset_mic_outlined,
                                    color: accentColor.withAlpha(180),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Contact Support',
                                    style: AppTextStyles.buttonText.copyWith(
                                      color: accentColor.withAlpha(180),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),

                        // ── Footer ──
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            isBanned
                                ? 'This action is permanent. Please reach out to support.'
                                : 'Your account will be automatically restored after the cooldown period.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withAlpha(60),
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(Size size, Color accent) {
    return [
      AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final v = _floatController.value;
          return Positioned(
            top: -60 + 25 * math.sin(v * math.pi),
            right: -50 + 15 * math.cos(v * math.pi),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withAlpha(8),
                    accent.withAlpha(3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final v = _floatController.value;
          return Positioned(
            bottom: -30 - 20 * math.sin(v * math.pi),
            left: -40 + 12 * math.cos(v * math.pi),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withAlpha(6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}

/// Dot pattern painter reused from splash screen aesthetic.
class _DotPatternPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  _DotPatternPainter({required this.dotColor, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
