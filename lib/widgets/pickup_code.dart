import 'package:flutter/material.dart';

class PickupCodeWidget extends StatelessWidget {
  final String code;
  final String status;
  final String businessName;

  const PickupCodeWidget({
    super.key,
    required this.code,
    required this.status,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'CONFIRMED';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFFFF6B35) : const Color(0xFFE0E0E0),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pickup Code',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF999999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Code boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((char) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 44,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFF3E0)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFFFE0B2)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    char,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? const Color(0xFFFF6B35)
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Text(
            businessName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),

          if (isActive) ...[
            const SizedBox(height: 8),
            const Text(
              'Show this code to the merchant when picking up your order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
