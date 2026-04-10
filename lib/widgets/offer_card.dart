import 'package:flutter/material.dart';
import '../models/offer.dart';
import 'countdown_timer.dart';
import 'scarcity_badge.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;
  final bool isFavorite;
  final VoidCallback onPress;
  final VoidCallback onToggleFavorite;

  const OfferCard({
    super.key,
    required this.offer,
    required this.isFavorite,
    required this.onPress,
    required this.onToggleFavorite,
  });

  String _categoryEmoji(String category) {
    switch (category) {
      case 'food':
        return '\u{1F37D}';
      case 'drinks':
        return '\u{1F964}';
      case 'wellness':
        return '\u{1F486}';
      case 'shopping':
        return '\u{1F6CD}';
      case 'entertainment':
        return '\u{1F3AD}';
      case 'services':
        return '\u{1F527}';
      default:
        return '\u{1F4E6}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            SizedBox(
              height: 160,
              child: Stack(
                children: [
                  // Placeholder
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFF3E0),
                    alignment: Alignment.center,
                    child: Text(
                      _categoryEmoji(offer.category),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  // Discount badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${offer.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22,
                          color: isFavorite
                              ? const Color(0xFFFF6B35)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Timer overlay
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CountdownTimer(
                      expiresAt: offer.expiresAt,
                      compact: true,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.business.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${offer.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${offer.originalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFBBBBBB),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ScarcityBadge(
                        remaining: offer.remainingQuantity,
                        total: offer.totalQuantity,
                        compact: true,
                      ),
                      if (offer.distanceKm != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              offer.distanceKm! < 1
                                  ? '${(offer.distanceKm! * 1000).round()}m'
                                  : '${offer.distanceKm!.toStringAsFixed(1)}km',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                    ],
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
