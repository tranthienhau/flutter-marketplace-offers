import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/offer_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/scarcity_badge.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  @override
  ConsumerState<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  bool _purchasing = false;

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
      default:
        return '\u{1F4E6}';
    }
  }

  Future<void> _handlePurchase() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated || auth.user == null) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign In Required'),
          content: const Text('Please sign in to purchase offers.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
      if (result == true && mounted) {
        context.push('/login');
      }
      return;
    }

    final offerNotifier = ref.read(offerProvider.notifier);
    final offer = offerNotifier.getOfferById(widget.offerId);
    if (offer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
            'Buy "${offer.title}" for \$${offer.discountedPrice.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Buy Now'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _purchasing = true);
    try {
      final order = await ref
          .read(orderProvider.notifier)
          .purchaseOffer(offer, auth.user!.id);
      offerNotifier.decrementQuantity(offer.id);
      if (mounted) context.push('/pickup/${order.pickupCode}');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to complete purchase. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerState = ref.watch(offerProvider);
    final notifier = ref.read(offerProvider.notifier);
    final offer = notifier.getOfferById(widget.offerId);

    if (offer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offer Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('Offer not found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
            ],
          ),
        ),
      );
    }

    final isFavorite = offerState.favorites.contains(offer.id);
    final isSoldOut = offer.remainingQuantity == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF222222),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section
                  SizedBox(
                    height: 240,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFFFF3E0),
                          alignment: Alignment.center,
                          child: Text(
                            _categoryEmoji(offer.category),
                            style: const TextStyle(fontSize: 72),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${offer.discountPercent}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () =>
                                notifier.toggleFavorite(offer.id),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 24,
                                color: isFavorite
                                    ? const Color(0xFFFF6B35)
                                    : const Color(0xFF666666),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Business info
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF0F0F0),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                offer.business.name[0],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.business.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14,
                                          color: Color(0xFFF57F17)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${offer.business.rating} (${offer.business.reviewCount})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('-',
                                          style: TextStyle(
                                              color: Color(0xFFCCCCCC))),
                                      const SizedBox(width: 4),
                                      const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Color(0xFF888888)),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          offer.business.address,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF888888),
                                          ),
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title & description
                        Text(
                          offer.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF222222),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          offer.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Urgency section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              CountdownTimer(expiresAt: offer.expiresAt),
                              const SizedBox(height: 16),
                              ScarcityBadge(
                                remaining: offer.remainingQuantity,
                                total: offer.totalQuantity,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Price section
                        Container(
                          padding: const EdgeInsets.only(bottom: 20),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFFF0F0F0)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Deal Price',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline:
                                        TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '\$${offer.discountedPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFFF6B35),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '\$${offer.originalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFBBBBBB),
                                          decoration: TextDecoration
                                              .lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Save \$${(offer.originalPrice - offer.discountedPrice).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: offer.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Distance
                        if (offer.distanceKm != null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.navigation_outlined,
                                  size: 18, color: Color(0xFFFF6B35)),
                              const SizedBox(width: 8),
                              Text(
                                offer.distanceKm! < 1
                                    ? '${(offer.distanceKm! * 1000).round()}m away'
                                    : '${offer.distanceKm!.toStringAsFixed(1)} km away',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: Color(0xFFF0F0F0)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${offer.discountedPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    Text(
                      '\$${offer.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFBBBBBB),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      (isSoldOut || _purchasing) ? null : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isSoldOut
                        ? 'Sold Out'
                        : _purchasing
                            ? 'Processing...'
                            : 'Grab This Deal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
