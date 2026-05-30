import 'package:bhukkdelivery/providers/help_support/help_support_provider.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportHeroCard extends ConsumerStatefulWidget {
  const SupportHeroCard({super.key});

  @override
  ConsumerState<SupportHeroCard> createState() => _SupportHeroCardState();
}

class _SupportHeroCardState extends ConsumerState<SupportHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.isDark ? AppColors.darkCyan : AppColors.primary,
            colors.isDark
                ? AppColors.primary.withAlpha(200)
                : AppColors.primaryAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Animated ring decorations
          Positioned(
            top: -40,
            right: -30,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.15),
                  child: Opacity(
                    opacity: 0.08 + (_pulseController.value * 0.04),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withAlpha(40), width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -40,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + ((1 - _pulseController.value) * 0.1),
                  child: Opacity(
                    opacity: 0.06 + ((1 - _pulseController.value) * 0.03),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withAlpha(30), width: 1.5),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + AppSpacing.xl,
              bottom: AppSpacing.xxxl,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
            ),
            child: Column(
              children: [
                // Pulsing icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.08),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(30),
                      border: Border.all(
                        color: Colors.white.withAlpha(50),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  "How can we help?",
                  style: AppTextStyles.headingLg.copyWith(
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Search FAQs or contact us directly",
                  style: AppTextStyles.bodySm.copyWith(
                    color: Colors.white.withAlpha(190),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Glassmorphic search bar
                ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: AppRadius.pillAll,
                      border: Border.all(
                        color: Colors.white.withAlpha(40),
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        ref
                            .read(helpSupportProvider.notifier)
                            .updateSearch(value);
                      },
                      style: AppTextStyles.bodySm.copyWith(
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "Search for help...",
                        hintStyle: AppTextStyles.bodySm.copyWith(
                          color: Colors.white.withAlpha(130),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.white.withAlpha(160),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md + 2,
                        ),
                      ),
                    ),
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
