import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer.dart';

final _mockBusinesses = [
  const Business(
    id: 'biz-1',
    name: 'Sunrise Bakery',
    address: '123 Main St',
    coordinates: Coordinates(latitude: 37.7849, longitude: -122.4094),
    logoUrl: '',
    rating: 4.7,
    reviewCount: 128,
    category: 'food',
  ),
  const Business(
    id: 'biz-2',
    name: 'Green Smoothie Bar',
    address: '456 Oak Ave',
    coordinates: Coordinates(latitude: 37.7859, longitude: -122.4074),
    logoUrl: '',
    rating: 4.5,
    reviewCount: 89,
    category: 'drinks',
  ),
  const Business(
    id: 'biz-3',
    name: 'Urban Spa Retreat',
    address: '789 Elm Blvd',
    coordinates: Coordinates(latitude: 37.7839, longitude: -122.4114),
    logoUrl: '',
    rating: 4.8,
    reviewCount: 203,
    category: 'wellness',
  ),
  const Business(
    id: 'biz-4',
    name: 'Pixel Electronics',
    address: '321 Tech Dr',
    coordinates: Coordinates(latitude: 37.7869, longitude: -122.4054),
    logoUrl: '',
    rating: 4.3,
    reviewCount: 67,
    category: 'shopping',
  ),
  const Business(
    id: 'biz-5',
    name: 'Taco Fiesta',
    address: '555 Spice Ln',
    coordinates: Coordinates(latitude: 37.7829, longitude: -122.4134),
    logoUrl: '',
    rating: 4.6,
    reviewCount: 156,
    category: 'food',
  ),
];

List<Offer> _createMockOffers() {
  final now = DateTime.now();
  return [
    Offer(
      id: 'offer-1',
      businessId: 'biz-1',
      business: _mockBusinesses[0],
      title: 'Fresh Croissants Box (6pc)',
      description:
          'Freshly baked butter croissants, perfect for breakfast. Limited batch made this morning.',
      originalPrice: 18.0,
      discountedPrice: 9.99,
      discountPercent: 45,
      imageUrl: '',
      category: 'food',
      totalQuantity: 20,
      remainingQuantity: 3,
      expiresAt: now.add(const Duration(hours: 2)),
      createdAt: now,
      isActive: true,
      distanceKm: 0.3,
      tags: ['bakery', 'breakfast', 'pastry'],
    ),
    Offer(
      id: 'offer-2',
      businessId: 'biz-2',
      business: _mockBusinesses[1],
      title: 'Detox Smoothie Bundle',
      description:
          'Three large detox smoothies - green, berry, and tropical. Cold-pressed, organic ingredients.',
      originalPrice: 24.0,
      discountedPrice: 14.99,
      discountPercent: 38,
      imageUrl: '',
      category: 'drinks',
      totalQuantity: 15,
      remainingQuantity: 7,
      expiresAt: now.add(const Duration(hours: 4)),
      createdAt: now,
      isActive: true,
      distanceKm: 0.5,
      tags: ['smoothie', 'healthy', 'organic'],
    ),
    Offer(
      id: 'offer-3',
      businessId: 'biz-3',
      business: _mockBusinesses[2],
      title: '60-Min Deep Tissue Massage',
      description:
          'Professional deep tissue massage at half price. Last-minute cancellation slots available.',
      originalPrice: 90.0,
      discountedPrice: 45.0,
      discountPercent: 50,
      imageUrl: '',
      category: 'wellness',
      totalQuantity: 5,
      remainingQuantity: 1,
      expiresAt: now.add(const Duration(hours: 1)),
      createdAt: now,
      isActive: true,
      distanceKm: 0.8,
      tags: ['spa', 'massage', 'relaxation'],
    ),
    Offer(
      id: 'offer-4',
      businessId: 'biz-4',
      business: _mockBusinesses[3],
      title: 'Wireless Earbuds Pro',
      description:
          'Noise-cancelling wireless earbuds. Overstock clearance - while supplies last.',
      originalPrice: 79.99,
      discountedPrice: 39.99,
      discountPercent: 50,
      imageUrl: '',
      category: 'shopping',
      totalQuantity: 10,
      remainingQuantity: 4,
      expiresAt: now.add(const Duration(hours: 6)),
      createdAt: now,
      isActive: true,
      distanceKm: 1.2,
      tags: ['electronics', 'audio', 'clearance'],
    ),
    Offer(
      id: 'offer-5',
      businessId: 'biz-5',
      business: _mockBusinesses[4],
      title: 'Taco Platter for Two',
      description:
          '8 gourmet tacos with sides and drinks. End-of-day special, fresh ingredients.',
      originalPrice: 32.0,
      discountedPrice: 17.99,
      discountPercent: 44,
      imageUrl: '',
      category: 'food',
      totalQuantity: 12,
      remainingQuantity: 5,
      expiresAt: now.add(const Duration(hours: 3)),
      createdAt: now,
      isActive: true,
      distanceKm: 1.0,
      tags: ['mexican', 'dinner', 'deal'],
    ),
  ];
}

class OfferState {
  final List<Offer> offers;
  final Set<String> favorites;
  final FilterOptions filters;
  final Coordinates? userLocation;
  final double searchRadius;
  final bool isLoading;
  final String? selectedCategory;

  const OfferState({
    this.offers = const [],
    this.favorites = const {},
    this.filters = const FilterOptions(),
    this.userLocation,
    this.searchRadius = 5.0,
    this.isLoading = false,
    this.selectedCategory,
  });

  OfferState copyWith({
    List<Offer>? offers,
    Set<String>? favorites,
    FilterOptions? filters,
    Coordinates? userLocation,
    double? searchRadius,
    bool? isLoading,
    String? Function()? selectedCategory,
  }) {
    return OfferState(
      offers: offers ?? this.offers,
      favorites: favorites ?? this.favorites,
      filters: filters ?? this.filters,
      userLocation: userLocation ?? this.userLocation,
      searchRadius: searchRadius ?? this.searchRadius,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
    );
  }
}

class OfferNotifier extends StateNotifier<OfferState> {
  OfferNotifier() : super(const OfferState());

  Future<void> fetchOffers() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(offers: _createMockOffers(), isLoading: false);
  }

  void toggleFavorite(String offerId) {
    final newFavorites = Set<String>.from(state.favorites);
    if (newFavorites.contains(offerId)) {
      newFavorites.remove(offerId);
    } else {
      newFavorites.add(offerId);
    }
    state = state.copyWith(favorites: newFavorites);
  }

  void setFilters(FilterOptions filters) {
    state = state.copyWith(filters: filters);
  }

  void setSearchRadius(double radius) {
    state = state.copyWith(searchRadius: radius);
  }

  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: () => category);
  }

  Offer? getOfferById(String id) {
    try {
      return state.offers.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Offer> getFavoriteOffers() {
    return state.offers
        .where((o) => state.favorites.contains(o.id))
        .toList();
  }

  List<Offer> getFilteredOffers() {
    var filtered = state.offers.where((o) => o.isActive).toList();

    if (state.selectedCategory != null) {
      filtered =
          filtered.where((o) => o.category == state.selectedCategory).toList();
    }
    if (state.filters.category != null) {
      filtered =
          filtered.where((o) => o.category == state.filters.category).toList();
    }
    if (state.filters.maxDistance != null) {
      filtered = filtered
          .where((o) => (o.distanceKm ?? 0) <= state.filters.maxDistance!)
          .toList();
    } else {
      filtered = filtered
          .where((o) => (o.distanceKm ?? 0) <= state.searchRadius)
          .toList();
    }
    if (state.filters.minDiscount != null) {
      filtered = filtered
          .where((o) => o.discountPercent >= state.filters.minDiscount!)
          .toList();
    }

    if (state.filters.sortBy == 'distance') {
      filtered.sort(
          (a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    } else if (state.filters.sortBy == 'discount') {
      filtered.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    } else {
      // Default: sort by expiring soon
      filtered.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    }

    return filtered;
  }

  void decrementQuantity(String offerId) {
    final newOffers = state.offers.map((o) {
      if (o.id == offerId && o.remainingQuantity > 0) {
        return o.copyWith(remainingQuantity: o.remainingQuantity - 1);
      }
      return o;
    }).toList();
    state = state.copyWith(offers: newOffers);
  }
}

final offerProvider =
    StateNotifierProvider<OfferNotifier, OfferState>((ref) {
  return OfferNotifier();
});
