import 'package:bhukkdelivery/cards/help_support_screen/contact_options_card.dart';
import 'package:bhukkdelivery/cards/help_support_screen/emergency_sos_card.dart';
import 'package:bhukkdelivery/cards/help_support_screen/faq_accordion_card.dart';
import 'package:bhukkdelivery/cards/help_support_screen/quick_help_topics_card.dart';
import 'package:bhukkdelivery/cards/help_support_screen/support_hero_card.dart';
import 'package:bhukkdelivery/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _staggeredFade(int index) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _staggeredSlide(int index) {
    final start = (index * 0.1).clamp(0.0, 0.7);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = C.of(context);

    final sections = <Widget>[
      // Section 1: Contact Us
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Contact Us", colors),
          const SizedBox(height: AppSpacing.md),
          const ContactOptionsCard(),
        ],
      ),
      // Section 2: Quick Help Topics (category chips)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Browse Topics", colors),
          const SizedBox(height: AppSpacing.md),
          const QuickHelpTopicsCard(),
        ],
      ),
      // Section 3: FAQs
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Frequently Asked", colors),
          const SizedBox(height: AppSpacing.md),
          const FaqAccordionCard(),
        ],
      ),
      // Section 4: Emergency SOS
      const EmergencySosCard(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom SliverAppBar with hero
          SliverToBoxAdapter(
            child: Stack(
              children: [
                const SupportHeroCard(),
                // Back button overlay
                Positioned(
                  top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm + 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(30),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Staggered body content
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _staggerController,
              builder: (context, _) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < sections.length; i++) ...[
                        SlideTransition(
                          position: _staggeredSlide(i),
                          child: FadeTransition(
                            opacity: _staggeredFade(i),
                            child: sections[i],
                          ),
                        ),
                        if (i < sections.length - 1)
                          const SizedBox(height: AppSpacing.xxl),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, C colors) {
    return Text(
      title,
      style: AppTextStyles.headingSm.copyWith(
        color: colors.textPrimary,
      ),
    );
  }
}
