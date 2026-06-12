import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_marketplace_offers/main.dart';
import 'package:flutter_marketplace_offers/widgets/offer_card.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shoot(WidgetTester tester, String name) async {
    await binding.convertFlutterSurfaceToImage();
    // Countdown timers animate every second, so pumpAndSettle would hang.
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot(name);
  }

  testWidgets('capture marketplace offers flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MarketplaceApp()));

    // Discover screen auto-fetches mock offers after a short delay.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 400));
    await shoot(tester, '01-discover');

    // Favorite a couple of offers so the Favorites tab is populated.
    final hearts = find.byIcon(Icons.favorite_border);
    if (hearts.evaluate().isNotEmpty) {
      await tester.tap(hearts.first);
      await tester.pump(const Duration(milliseconds: 300));
    }
    final hearts2 = find.byIcon(Icons.favorite_border);
    if (hearts2.evaluate().length > 1) {
      await tester.tap(hearts2.at(1));
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Open the first offer's detail page.
    final cards = find.byType(OfferCard);
    expect(cards, findsWidgets);
    await tester.tap(cards.first);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));
    await shoot(tester, '02-offer-detail');

    // Back to Discover.
    final backBtn = find.byTooltip('Back');
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn.first);
      await tester.pump(const Duration(milliseconds: 600));
    }

    // Go to the Favorites tab (shows the offers we hearted).
    final favTab = find.text('Favorites');
    if (favTab.evaluate().isNotEmpty) {
      await tester.tap(favTab.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 400));
      await shoot(tester, '03-favorites');
    }

    // Profile tab.
    final profileTab = find.text('Profile');
    if (profileTab.evaluate().isNotEmpty) {
      await tester.tap(profileTab.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 400));
      await shoot(tester, '04-profile');
    }
  });
}
