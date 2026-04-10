import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_marketplace_offers/main.dart';

void main() {
  testWidgets('App renders discover screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MarketplaceApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsWidgets);
  });
}
