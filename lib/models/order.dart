import 'offer.dart';

enum OrderStatus { pending, confirmed, pickedUp, expired, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.pickedUp:
        return 'PICKED UP';
      case OrderStatus.expired:
        return 'EXPIRED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

class Order {
  final String id;
  final String offerId;
  final Offer offer;
  final String userId;
  final String pickupCode;
  final OrderStatus status;
  final DateTime purchasedAt;
  final DateTime? pickedUpAt;
  final int? rating;
  final String? review;

  const Order({
    required this.id,
    required this.offerId,
    required this.offer,
    required this.userId,
    required this.pickupCode,
    required this.status,
    required this.purchasedAt,
    this.pickedUpAt,
    this.rating,
    this.review,
  });

  Order copyWith({
    OrderStatus? status,
    DateTime? pickedUpAt,
    int? rating,
    String? review,
  }) {
    return Order(
      id: id,
      offerId: offerId,
      offer: offer,
      userId: userId,
      pickupCode: pickupCode,
      status: status ?? this.status,
      purchasedAt: purchasedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}
