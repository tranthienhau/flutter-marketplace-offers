import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/offer_provider.dart';
import '../widgets/offer_card.dart';

const _categories = [
  (key: null, label: 'All', icon: '\u2728'),
  (key: 'food', label: 'Food', icon: '\u{1F37D}'),
  (key: 'drinks', label: 'Drinks', icon: '\u{1F964}'),
  (key: 'wellness', label: 'Wellness', icon: '\u{1F486}'),
  (key: 'shopping', label: 'Shopping', icon: '\u{1F6CD}'),
  (key: 'entertainment', label: 'Fun', icon: '\u{1F3AD}'),
  (key: 'services', label: 'Services', icon: '\u{1F527}'),
];

const _radiusOptions = [1.0, 2.0, 5.0, 10.0, 25.0];

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  bool _showRadiusPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offerProvider.notifier).fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offerProvider);
    final notifier = ref.read(offerProvider.notifier);
    final offers = notifier.getFilteredOffers();

    return Column(
      children: [
        // Header with location and radius
        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                  .copyWith(bottom: 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 18, color: Color(0xFFFF6B35)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'San Francisco',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(
                        () => _showRadiusPicker = !_showRadiusPicker),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${state.searchRadius.toInt()} km',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 14, color: Color(0xFFFF6B35)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showRadiusPicker) ...[
                const SizedBox(height: 10),
                Row(
                  children: _radiusOptions.map((r) {
                    final isActive = r == state.searchRadius;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          notifier.setSearchRadius(r);
                          setState(() => _showRadiusPicker = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${r.toInt()} km',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF666666),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),

        // Category chips
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isActive = state.selectedCategory == cat.key;
              return GestureDetector(
                onTap: () => notifier.setSelectedCategory(cat.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFF6B35)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFFE8E8E8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Offers list
        Expanded(
          child: offers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text(
                        'No offers nearby',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try increasing your search radius or check back later',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFF6B35),
                  onRefresh: () => notifier.fetchOffers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16)
                        .copyWith(bottom: 32),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return OfferCard(
                        offer: offer,
                        isFavorite:
                            state.favorites.contains(offer.id),
                        onPress: () =>
                            context.push('/offer/${offer.id}'),
                        onToggleFavorite: () =>
                            notifier.toggleFavorite(offer.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
