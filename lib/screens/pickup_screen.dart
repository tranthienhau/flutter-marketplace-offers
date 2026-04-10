import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../widgets/pickup_code.dart';

class PickupScreen extends ConsumerStatefulWidget {
  final String code;

  const PickupScreen({super.key, required this.code});

  @override
  ConsumerState<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends ConsumerState<PickupScreen> {
  int _rating = 0;

  void _handleMarkPickedUp(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text(
            'Has the merchant verified your code and given you the item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not Yet'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Picked Up'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(orderProvider.notifier).markAsPickedUp(order.id);
    }
  }

  void _handleRate(Order order) {
    if (_rating == 0) return;
    ref.read(orderProvider.notifier).rateOrder(order.id, _rating);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your rating has been submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(orderProvider);
    final notifier = ref.read(orderProvider.notifier);
    final order = notifier.getOrderByPickupCode(widget.code);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pickup')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('Order not found',
                  style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Go Back',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF222222),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Pickup code card
            PickupCodeWidget(
              code: order.pickupCode,
              status: order.status.displayName,
              businessName: order.offer.business.name,
            ),
            const SizedBox(height: 20),

            // Order details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(label: 'Item', value: order.offer.title),
                  const SizedBox(height: 14),
                  _DetailRow(
                      label: 'Business',
                      value: order.offer.business.name),
                  const SizedBox(height: 14),
                  _DetailRow(
                      label: 'Address',
                      value: order.offer.business.address),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Paid',
                    value:
                        '\$${order.offer.discountedPrice.toStringAsFixed(2)}',
                    valueColor: const Color(0xFFFF6B35),
                    bold: true,
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Saved',
                    value:
                        '\$${(order.offer.originalPrice - order.offer.discountedPrice).toStringAsFixed(2)}',
                    valueColor: const Color(0xFF2E7D32),
                    bold: true,
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Purchased',
                    value:
                        '${order.purchasedAt.month}/${order.purchasedAt.day}/${order.purchasedAt.year} ${order.purchasedAt.hour}:${order.purchasedAt.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mark as picked up
            if (order.status == OrderStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMarkPickedUp(order),
                  icon: const Icon(Icons.shopping_bag,
                      size: 20, color: Colors.white),
                  label: const Text(
                    'Mark as Picked Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

            // Rating
            if (order.status == OrderStatus.pickedUp &&
                order.rating == null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Rate Your Experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final star = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => _rating = star),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              star <= _rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 36,
                              color: star <= _rating
                                  ? const Color(0xFFF57F17)
                                  : const Color(0xFFDDDDDD),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _rating == 0 ? null : () => _handleRate(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF57F17),
                          disabledBackgroundColor:
                              const Color(0xFFF57F17).withValues(alpha: 0.4),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit Rating',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Already rated
            if (order.rating != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 24, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text(
                      'You rated this ${order.rating}/5 stars',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Get directions
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Navigate to ${order.offer.business.address}')),
                  );
                },
                icon: const Icon(Icons.navigation_outlined,
                    size: 18, color: Color(0xFFFF6B35)),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFF6B35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF888888),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? const Color(0xFF333333),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
