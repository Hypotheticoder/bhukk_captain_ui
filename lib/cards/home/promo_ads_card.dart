import 'dart:async';
import 'package:bhukkdelivery/models/ad_carousel_item.dart';
import 'package:bhukkdelivery/providers/ads/ads_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// A premium auto-scrolling promotional ads carousel.
/// Fetches dynamic ads from the `/ads/carousel` API and falls back to static banners on failure/empty.
class PromoAdsCard extends ConsumerStatefulWidget {
  const PromoAdsCard({super.key});

  @override
  ConsumerState<PromoAdsCard> createState() => _PromoAdsCardState();
}

class _PromoAdsCardState extends ConsumerState<PromoAdsCard>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _shimmerController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  int _lastCount = 0;

  static const _promos = <_PromoData>[
    _PromoData(
      title: "Earn 2× Today!",
      subtitle: "Complete 10 deliveries and unlock double rewards",
      badge: "LIMITED",
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BF6)],
      icon: Icons.rocket_launch_rounded,
      accentIcon: Icons.star_rounded,
    ),
    _PromoData(
      title: "Refer & Earn ₹500",
      subtitle: "Invite a friend, both of you get ₹500 bonus",
      badge: "NEW",
      gradientColors: [Color(0xFFEC4899), Color(0xFFF472B6), Color(0xFFFBCFE8)],
      icon: Icons.people_alt_rounded,
      accentIcon: Icons.card_giftcard_rounded,
    ),
    _PromoData(
      title: "Peak Hour Bonus",
      subtitle: "₹30 extra per delivery during 12PM – 2PM",
      badge: "LIVE",
      gradientColors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE68A)],
      icon: Icons.access_time_filled_rounded,
      accentIcon: Icons.bolt_rounded,
    ),
    _PromoData(
      title: "Safety First Drive",
      subtitle: "Zero incidents this week? Get ₹200 safety bonus",
      badge: "EARN",
      gradientColors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF6EE7B7)],
      icon: Icons.shield_rounded,
      accentIcon: Icons.verified_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  void _setupAutoScroll(int count) {
    if (_lastCount == count) return;
    _lastCount = count;
    _autoScrollTimer?.cancel();
    if (count <= 1) return;
    _currentPage = 0;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _currentPage = (_currentPage + 1) % count;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleAdTap(String targetUrl) async {
    if (targetUrl.isEmpty) return;
    final uri = Uri.tryParse(targetUrl);
    if (uri != null) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint("[PromoAdsCard] Error launching URL: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);
    final adsAsync = ref.watch(adsCarouselProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header with "Ad" label ──
        Row(
          children: [
            Text(
              "For You",
              style: AppTextStyles.headingSm.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.textTertiary.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Ad",
                style: AppTextStyles.caption.copyWith(
                  color: colors.textTertiary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Carousel ──
        SizedBox(
          height: 158,
          child: adsAsync.hasError
              ? (() {
                  _setupAutoScroll(_promos.length);
                  return _buildStaticCarousel(colors);
                })()
              : adsAsync.when(
                  loading: () => _ShimmerAdPlaceholder(
                    shimmerAnimation: _shimmerController,
                    colors: colors,
                  ),
                  error: (err, stack) {
                    _setupAutoScroll(_promos.length);
                    return _buildStaticCarousel(colors);
                  },
                  data: (ads) {
                    if (ads.isEmpty) {
                      _setupAutoScroll(_promos.length);
                      return _buildStaticCarousel(colors);
                    }
                    _setupAutoScroll(ads.length);
                    return _buildApiCarousel(ads, colors);
                  },
                ),
        ),

        // ── Page indicators ──
        const SizedBox(height: AppSpacing.md),
        adsAsync.hasError
            ? _buildIndicators(
                _promos.length,
                colors,
                (idx) => _promos[idx].gradientColors[0],
              )
            : adsAsync.when(
                loading: () => const SizedBox(height: 6),
                error: (err, stack) => _buildIndicators(
                  _promos.length,
                  colors,
                  (idx) => _promos[idx].gradientColors[0],
                ),
                data: (ads) {
                  final len = ads.isNotEmpty ? ads.length : _promos.length;
                  final fallbackGradients = [
                    const Color(0xFF6366F1),
                    const Color(0xFFEC4899),
                    const Color(0xFFF59E0B),
                    const Color(0xFF10B981),
                  ];
                  return _buildIndicators(
                    len,
                    colors,
                    (idx) => ads.isNotEmpty
                        ? fallbackGradients[idx % fallbackGradients.length]
                        : _promos[idx].gradientColors[0],
                  );
                },
              ),
      ],
    );
  }

  Widget _buildStaticCarousel(C colors) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _promos.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final promo = _promos[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: _PromoSlide(
            promo: promo,
            shimmerAnimation: _shimmerController,
            colors: colors,
          ),
        );
      },
    );
  }

  Widget _buildApiCarousel(List<AdCarouselItem> ads, C colors) {
    return PageView.builder(
      controller: _pageController,
      itemCount: ads.length,
      onPageChanged: (index) => setState(() => _currentPage = index),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final ad = ads[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.92, end: 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: GestureDetector(
            onTap: () => _handleAdTap(ad.targetUrl),
            child: _AdSlide(
              ad: ad,
              shimmerAnimation: _shimmerController,
              colors: colors,
              index: index,
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndicators(
    int length,
    C colors,
    Color Function(int) activeColorBuilder,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? activeColorBuilder(_currentPage % length)
                : colors.textTertiary.withAlpha(50),
          ),
        );
      }),
    );
  }
}

class _ShimmerOverlay extends StatelessWidget {
  final AnimationController shimmerAnimation;

  const _ShimmerOverlay({required this.shimmerAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, _) {
        return Positioned.fill(
          child: ClipRRect(
            borderRadius: AppRadius.xlAll,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white.withAlpha(25),
                    Colors.white.withAlpha(0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment(-2 + 4 * shimmerAnimation.value, -0.3),
                  end: Alignment(-1 + 4 * shimmerAnimation.value, 0.3),
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: Container(color: Colors.white.withAlpha(15)),
            ),
          ),
        );
      },
    );
  }
}

class _PromoSlide extends StatelessWidget {
  final _PromoData promo;
  final AnimationController shimmerAnimation;
  final C colors;

  const _PromoSlide({
    required this.promo,
    required this.shimmerAnimation,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: LinearGradient(
          colors: promo.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: promo.gradientColors[0].withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // ── Background shimmer sweep ──
          _ShimmerOverlay(shimmerAnimation: shimmerAnimation),

          // ── Large background icon (decorative) ──
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              promo.accentIcon,
              size: 120,
              color: Colors.white.withAlpha(18),
            ),
          ),

          // ── Floating accent circles ──
          Positioned(
            right: 50,
            top: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(12),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(45),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          promo.badge,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm + 2),
                      // Title
                      Text(
                        promo.title,
                        style: AppTextStyles.headingSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      // Subtitle
                      Text(
                        promo.subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white.withAlpha(200),
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(40),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    promo.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdSlide extends StatelessWidget {
  final AdCarouselItem ad;
  final AnimationController shimmerAnimation;
  final C colors;
  final int index;

  const _AdSlide({
    required this.ad,
    required this.shimmerAnimation,
    required this.colors,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a background gradient in case the network image is loading or fails
    final fallbackGradients = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      [const Color(0xFF10B981), const Color(0xFF34D399)],
    ];
    final gradient = fallbackGradients[index % fallbackGradients.length];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Stack(
          children: [
            // Faint background accent pattern
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                Icons.star_rounded,
                size: 120,
                color: Colors.white.withAlpha(18),
              ),
            ),

            if (ad.absoluteMediaUrl.isNotEmpty && ad.mediaType.toLowerCase() == 'image')
              Positioned.fill(
                child: Image.network(
                  ad.absoluteMediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    // While loading, show gradient and shimmer sweep
                    return _ShimmerOverlay(shimmerAnimation: shimmerAnimation);
                  },
                ),
              ),

            // Gradient scrim overlay to guarantee text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(180),
                      Colors.black.withAlpha(80),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Badge (Ad)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(45),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withAlpha(50),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "ADVERTISEMENT",
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Title
                  Text(
                    ad.title,
                    style: AppTextStyles.headingSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerAdPlaceholder extends StatelessWidget {
  final AnimationController shimmerAnimation;
  final C colors;

  const _ShimmerAdPlaceholder({
    required this.shimmerAnimation,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Stack(
          children: [
            _ShimmerOverlay(shimmerAnimation: shimmerAnimation),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors.divider.withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 200,
                    height: 22,
                    decoration: BoxDecoration(
                      color: colors.divider.withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors.divider.withAlpha(100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoData {
  final String title;
  final String subtitle;
  final String badge;
  final List<Color> gradientColors;
  final IconData icon;
  final IconData accentIcon;

  const _PromoData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.gradientColors,
    required this.icon,
    required this.accentIcon,
  });
}
