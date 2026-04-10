import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer.dart';
import '../models/order.dart';

String _generatePickupCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}

class OrderState {
  final List<Order> orders;
  final bool isLoading;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
  });

  OrderState copyWith({List<Order>? orders, bool? isLoading}) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState());

  Future<Order> purchaseOffer(Offer offer, String userId) async {
    state = state.copyWith(isLoading: true);
    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1200));

    final order = Order(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      offerId: offer.id,
      offer: offer,
      userId: userId,
      pickupCode: _generatePickupCode(),
      status: OrderStatus.confirmed,
      purchasedAt: DateTime.now(),
    );

    state = OrderState(
      orders: [order, ...state.orders],
      isLoading: false,
    );

    return order;
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return state.orders.where((o) => o.status == status).toList();
  }

  Order? getOrderByPickupCode(String code) {
    try {
      return state.orders
          .firstWhere((o) => o.pickupCode == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  void markAsPickedUp(String orderId) {
    final newOrders = state.orders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(
          status: OrderStatus.pickedUp,
          pickedUpAt: DateTime.now(),
        );
      }
      return o;
    }).toList();
    state = state.copyWith(orders: newOrders);
  }

  void cancelOrder(String orderId) {
    final newOrders = state.orders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: OrderStatus.cancelled);
      }
      return o;
    }).toList();
    state = state.copyWith(orders: newOrders);
  }

  void rateOrder(String orderId, int rating, {String? review}) {
    final newOrders = state.orders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(rating: rating, review: review);
      }
      return o;
    }).toList();
    state = state.copyWith(orders: newOrders);
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});
