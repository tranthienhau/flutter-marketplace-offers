import 'package:flutter/material.dart';

class ScarcityBadge extends StatelessWidget {
  final int remaining;
  final int total;
  final bool compact;

  const ScarcityBadge({
    super.key,
    required this.remaining,
    required this.total,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (remaining / total) * 100 : 0.0;

    String level;
    if (remaining == 0) {
      level = 'sold_out';
    } else if (percentage <= 15) {
      level = 'low';
    } else if (percentage <= 40) {
      level = 'medium';
    } else {
      level = 'high';
    }

    final configs = {
      'sold_out': (
        bg: const Color(0xFFE0E0E0),
        text: const Color(0xFF666666),
        label: 'Sold Out',
        icon: '',
      ),
      'low': (
        bg: const Color(0xFFFFEBEE),
        text: const Color(0xFFD32F2F),
        label: 'Only $remaining left!',
        icon: '\u{1F525}',
      ),
      'medium': (
        bg: const Color(0xFFFFF8E1),
        text: const Color(0xFFF57F17),
        label: '$remaining remaining',
        icon: '',
      ),
      'high': (
        bg: const Color(0xFFE8F5E9),
        text: const Color(0xFF2E7D32),
        label: '$remaining available',
        icon: '',
      ),
    };

    final config = configs[level]!;

    if (compact) {
      final compactText = config.icon.isNotEmpty
          ? '${config.icon} $remaining'
          : '$remaining left';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: config.bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          compactText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: config.text,
          ),
        ),
      );
    }

    Color barColor;
    if (level == 'low') {
      barColor = const Color(0xFFD32F2F);
    } else if (level == 'medium') {
      barColor = const Color(0xFFF57F17);
    } else {
      barColor = const Color(0xFF2E7D32);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: config.bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${config.icon} ${config.label}'.trim(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: config.text,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }
}
