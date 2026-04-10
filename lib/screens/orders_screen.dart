import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderProvider);

    if (state.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your purchased offers will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 32),
      itemCount: state.orders.length,
      itemBuilder: (context, index) {
        final order = state.orders[index];
        return _OrderItem(
          order: order,
          onPress: () {
            if (order.status == OrderStatus.confirmed) {
              context.push('/pickup/${order.pickupCode}');
            }
          },
        );
      },
    );
  }
}

class _OrderItem extends StatelessWidget {
  final Order order;
  final VoidCallback onPress;

  const _OrderItem({required this.order, required this.onPress});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(order.status);
    final date = order.purchasedAt;

    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.offer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.offer.business.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: config.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(config.icon, size: 14, color: config.color),
                      const SizedBox(width: 4),
                      Text(
                        order.status.displayName.toLowerCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: config.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Details
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F0F0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailColumn(
                    label: 'Code',
                    value: order.pickupCode,
                    valueColor: const Color(0xFFFF6B35),
                    bold: true,
                  ),
                  _DetailColumn(
                    label: 'Paid',
                    value:
                        '\$${order.offer.discountedPrice.toStringAsFixed(2)}',
                  ),
                  _DetailColumn(
                    label: 'Date',
                    value:
                        '${date.month}/${date.day}/${date.year}',
                  ),
                ],
              ),
            ),

            // Pickup hint
            if (order.status == OrderStatus.confirmed)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 16, color: Color(0xFFFF6B35)),
                    SizedBox(width: 6),
                    Text(
                      'Tap to view pickup code',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Rate hint
            if (order.status == OrderStatus.pickedUp && order.rating == null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border,
                        size: 16, color: Color(0xFFF57F17)),
                    SizedBox(width: 6),
                    Text(
                      'Rate your experience',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFF57F17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return _StatusConfig(
          color: const Color(0xFF2E7D32),
          bg: const Color(0xFFE8F5E9),
          icon: Icons.check_circle,
        );
      case OrderStatus.pending:
        return _StatusConfig(
          color: const Color(0xFFF57F17),
          bg: const Color(0xFFFFF8E1),
          icon: Icons.access_time,
        );
      case OrderStatus.pickedUp:
        return _StatusConfig(
          color: const Color(0xFF1565C0),
          bg: const Color(0xFFE3F2FD),
          icon: Icons.shopping_bag,
        );
      case OrderStatus.expired:
        return _StatusConfig(
          color: const Color(0xFF999999),
          bg: const Color(0xFFF5F5F5),
          icon: Icons.error,
        );
      case OrderStatus.cancelled:
        return _StatusConfig(
          color: const Color(0xFFD32F2F),
          bg: const Color(0xFFFFEBEE),
          icon: Icons.cancel,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final Color bg;
  final IconData icon;

  const _StatusConfig({
    required this.color,
    required this.bg,
    required this.icon,
  });
}

class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _DetailColumn({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF333333),
            letterSpacing: bold ? 1 : 0,
          ),
        ),
      ],
    );
  }
}
