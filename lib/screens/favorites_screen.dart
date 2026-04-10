import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/offer_provider.dart';
import '../widgets/offer_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(offerProvider);
    final notifier = ref.read(offerProvider.notifier);
    final favoriteOffers = notifier.getFavoriteOffers();

    if (favoriteOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tap the heart on offers you like to save them here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 32),
      itemCount: favoriteOffers.length,
      itemBuilder: (context, index) {
        final offer = favoriteOffers[index];
        return OfferCard(
          offer: offer,
          isFavorite: true,
          onPress: () => context.push('/offer/${offer.id}'),
          onToggleFavorite: () => notifier.toggleFavorite(offer.id),
        );
      },
    );
  }
}
