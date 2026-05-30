import 'dart:async';
import 'package:bhukkdelivery/cards/home/promo_ads_card.dart';
import 'package:bhukkdelivery/models/ad_carousel_item.dart';
import 'package:bhukkdelivery/providers/ads/ads_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromoAdsCard Widget Tests', () {
    testWidgets('PromoAdsCard shows shimmer during loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Return a future that never completes during the pump to keep it in loading state
            adsCarouselProvider.overrideWith((ref) => const ConstantReaderFuture<List<AdCarouselItem>>().future),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PromoAdsCard(),
            ),
          ),
        ),
      );

      // Verify widget renders
      expect(find.byType(PromoAdsCard), findsOneWidget);
    });

    testWidgets('PromoAdsCard falls back to static promos on empty list', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adsCarouselProvider.overrideWith((ref) => Future.value(<AdCarouselItem>[])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PromoAdsCard(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should show the fallback static promos, like "Earn 2× Today!"
      expect(find.text("Earn 2× Today!"), findsOneWidget);
    });

    testWidgets('PromoAdsCard falls back to static promos on error', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adsCarouselProvider.overrideWith((ref) => Future.error("Network Error", StackTrace.empty)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PromoAdsCard(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Should show the fallback static promos
      expect(find.text("Earn 2× Today!"), findsOneWidget);
    });

    testWidgets('PromoAdsCard renders dynamic ads when API succeeds', (WidgetTester tester) async {
      final mockAds = [
        AdCarouselItem(
          title: "Earn Double Bonus",
          mediaType: "image",
          targetUrl: "https://example.com/promo1",
          isActive: true,
          displayOrder: 1,
          id: "ad-1",
          mediaUrl: "https://example.com/img1.png",
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adsCarouselProvider.overrideWith((ref) => Future.value(mockAds)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: PromoAdsCard(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the dynamic title is visible
      expect(find.text("Earn Double Bonus"), findsOneWidget);
    });
  });
}

// Helper to keep future in pending state
class ConstantReaderFuture<T> {
  const ConstantReaderFuture();
  Future<T> get future => Completer<T>().future;
}
