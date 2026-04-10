class Coordinates {
  final double latitude;
  final double longitude;

  const Coordinates({required this.latitude, required this.longitude});
}

class Business {
  final String id;
  final String name;
  final String address;
  final Coordinates coordinates;
  final String logoUrl;
  final double rating;
  final int reviewCount;
  final String category;

  const Business({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.logoUrl,
    required this.rating,
    required this.reviewCount,
    required this.category,
  });
}

class Offer {
  final String id;
  final String businessId;
  final Business business;
  final String title;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final String imageUrl;
  final String category;
  final int totalQuantity;
  final int remainingQuantity;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isActive;
  final double? distanceKm;
  final List<String> tags;

  const Offer({
    required this.id,
    required this.businessId,
    required this.business,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.imageUrl,
    required this.category,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.expiresAt,
    required this.createdAt,
    required this.isActive,
    this.distanceKm,
    required this.tags,
  });

  Offer copyWith({int? remainingQuantity}) {
    return Offer(
      id: id,
      businessId: businessId,
      business: business,
      title: title,
      description: description,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      discountPercent: discountPercent,
      imageUrl: imageUrl,
      category: category,
      totalQuantity: totalQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      expiresAt: expiresAt,
      createdAt: createdAt,
      isActive: isActive,
      distanceKm: distanceKm,
      tags: tags,
    );
  }
}

typedef OfferCategory = String;

class FilterOptions {
  final String? category;
  final double? maxDistance;
  final int? minDiscount;
  final String? sortBy; // 'distance', 'discount', 'expiring_soon', 'popularity'

  const FilterOptions({
    this.category,
    this.maxDistance,
    this.minDiscount,
    this.sortBy,
  });
}
