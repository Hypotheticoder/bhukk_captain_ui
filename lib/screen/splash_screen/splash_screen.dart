import 'dart:math' as math;
import 'package:bhukkdelivery/providers/splash/splash_provider.dart';
import 'package:bhukkdelivery/screen/splash_screen/widgets/splash_logo.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──
  late AnimationController _bgController; // Background gradient shift
  late AnimationController _logoController; // Logo entrance
  late AnimationController _scooterController; // Scooter travel
  late AnimationController _pulseController; // Logo pulse glow
  late AnimationController _textController; // Text fade-in
  late AnimationController _shimmerController; // Loading shimmer

  // ── Animations ──
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _scooterPosition;
  late Animation<double> _scooterBounce;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // Background slow gradient shift
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Logo scale + fade (enters at 0.3s)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Scooter travels across screen (starts at 0.5s)
    _scooterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _scooterPosition = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _scooterController, curve: Curves.easeInOutCubic),
    );
    // Subtle bounce while moving
    _scooterBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scooterController, curve: Curves.linear),
    );

    // Logo pulse glow (starts after logo lands)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Text slide-up + fade
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    // Shimmer loading bar
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmer = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Step 1: Scooter enters from left
    await Future.delayed(const Duration(milliseconds: 300));
    _scooterController.forward();

    // Step 2: Logo fades in + scales while scooter is midway
    await Future.delayed(const Duration(milliseconds: 600));
    _logoController.forward();

    // Step 3: Text appears after logo lands
    await Future.delayed(const Duration(milliseconds: 900));
    _textController.forward();

    // Step 4: Pulse begins + shimmer loading
    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _scooterController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashStatus = ref.watch(splashProvider);
    final size = MediaQuery.of(context).size;

    // Navigate on auth state change
    ref.listen(splashProvider, (previous, next) {
      if (next == SplashStatus.authenticated) {
        context.go('/home');
      } else if (next == SplashStatus.authenticatedWithActiveOrder) {
        context.go('/home/live_navigation');
      } else if (next == SplashStatus.authenticatedWithPayment) {
        final delivery = ref.read(activeDeliveryProvider);
        if (delivery != null) {
          // Go to home, then push payment page over it, or just push payment directly?
          // If we use GoRouter, going directly to payment is best. But the stack might need /home.
          // Let's just go directly to payment with parameters.
          context.go(Uri(
            path: '/payment',
            queryParameters: {
              'serviceType': delivery.serviceType,
              'amount': delivery.orderAmount.toString(),
              'orderId': delivery.orderId,
            },
          ).toString());
        } else {
          context.go('/home');
        }
      } else if (next == SplashStatus.unauthenticated) {
        context.go('/login');
      }
    });

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    AppColors.secondaryCyan,
                    AppColors.darkCyan,
                    _bgController.value,
                  )!,
                  Color.lerp(
                    AppColors.darkCyan,
                    const Color(0xFF003B46),
                    _bgController.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF00181C),
                    const Color(0xFF0A0E14),
                    _bgController.value,
                  )!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // ── Decorative floating circles ──
                ..._buildFloatingCircles(size),

                // ── Subtle diagonal lines pattern ──
                _buildPatternOverlay(size),

                // ── Scooter trail (dashed line) ──
                _buildScooterTrail(size),

                // ── Scooter animation ──
                _buildScooter(size),

                // ── Center: Brand ──
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand image with pulse glow
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _logoController,
                          _pulseController,
                        ]),
                        builder: (context, _) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoFade.value.clamp(0.0, 1.0),
                              child: const SplashLogo(logoSize: 80),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Tagline
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Text(
                            "D E L I V E R Y   P A R T N E R",
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withAlpha(170),
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Loading shimmer bar ──
                if (splashStatus == SplashStatus.loading)
                  Positioned(
                    bottom: 60,
                    left: size.width * 0.3,
                    right: size.width * 0.3,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        return Column(
                          children: [
                            // Shimmer bar
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.pillAll,
                                color: Colors.white.withAlpha(20),
                              ),
                              child: ClipRRect(
                                borderRadius: AppRadius.pillAll,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left:
                                          _shimmer.value *
                                          size.width *
                                          0.4 /
                                          1.5,
                                      child: Container(
                                        width: size.width * 0.12,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withAlpha(0),
                                              Colors.white.withAlpha(120),
                                              Colors.white.withAlpha(0),
                                            ],
                                          ),
                                          borderRadius: AppRadius.pillAll,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              "Getting things ready...",
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withAlpha(100),
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                // ── Version at very bottom ──
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      "v1.0.0",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.overline.copyWith(
                        color: Colors.white.withAlpha(50),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Floating decorative circles ──
  List<Widget> _buildFloatingCircles(Size size) {
    return [
      // Top-right large circle
      AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Positioned(
            top: -80 + 20 * math.sin(_bgController.value * math.pi),
            right: -60 + 15 * math.cos(_bgController.value * math.pi),
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha(10),
                    Colors.white.withAlpha(3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Bottom-left medium circle
      AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Positioned(
            bottom: -40 - 15 * math.sin(_bgController.value * math.pi),
            left: -30 + 10 * math.cos(_bgController.value * math.pi),
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withAlpha(8),
                    Colors.white.withAlpha(2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
      // Mid-right small accent
      AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Positioned(
            top:
                size.height * 0.35 +
                10 * math.sin(_bgController.value * math.pi * 2),
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryAccent.withAlpha(12),
              ),
            ),
          );
        },
      ),
    ];
  }

  // ── Subtle dot pattern overlay ──
  Widget _buildPatternOverlay(Size size) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DotPatternPainter(
          dotColor: Colors.white.withAlpha(6),
          spacing: 40,
        ),
      ),
    );
  }

  // ── Scooter trail (dashed path) ──
  Widget _buildScooterTrail(Size size) {
    return AnimatedBuilder(
      animation: _scooterController,
      builder: (context, _) {
        final progress = _scooterPosition.value.clamp(0.0, 1.0);
        if (progress <= 0) return const SizedBox.shrink();

        return Positioned(
          top: size.height * 0.62,
          left: 0,
          right: size.width * (1 - progress),
          child: Opacity(
            opacity: (progress < 0.1)
                ? progress * 10
                : (progress > 0.9)
                ? (1 - progress) * 10
                : 0.6,
            child: CustomPaint(
              size: Size(size.width * progress, 2),
              painter: _DashedLinePainter(
                color: Colors.white.withAlpha(50),
                dashWidth: 8,
                dashGap: 6,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Animated scooter ──
  Widget _buildScooter(Size size) {
    return AnimatedBuilder(
      animation: _scooterController,
      builder: (context, _) {
        final pos = _scooterPosition.value;
        final x = size.width * pos - 20;
        final yBase = size.height * 0.58;
        // Subtle bounce: sine wave as it moves
        final bounce = math.sin(_scooterBounce.value * math.pi * 8) * 3;
        // Slight tilt based on speed (acceleration at start/end)
        final speedFactor = _scooterController.velocity;
        final tilt = (speedFactor * 0.01).clamp(-0.08, 0.08);

        // Fade in/out at edges
        final opacity = (pos < 0)
            ? ((pos + 0.2) / 0.2).clamp(0.0, 1.0)
            : (pos > 1.0)
            ? ((1.2 - pos) / 0.2).clamp(0.0, 1.0)
            : 1.0;

        return Positioned(
          left: x,
          top: yBase + bounce,
          child: Opacity(
            opacity: opacity,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateZ(tilt),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Scooter icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withAlpha(15),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.delivery_dining_rounded,
                      color: Colors.white.withAlpha(230),
                      size: 28,
                    ),
                  ),
                  // Speed lines trailing
                  if (pos > 0 && pos < 1)
                    Transform.translate(
                      offset: const Offset(-12, -8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          return Container(
                            width: 6 + i * 4.0,
                            height: 1.5,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40 - i * 12),
                              borderRadius: AppRadius.pillAll,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Custom painter: dot grid pattern ──
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
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Custom painter: dashed line ──
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
