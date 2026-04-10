import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  final bool compact;
  final VoidCallback? onExpired;

  const CountdownTimer({
    super.key,
    required this.expiresAt,
    this.compact = false,
    this.onExpired,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
      if (_timeLeft.isNegative || _timeLeft == Duration.zero) {
        _timer.cancel();
        widget.onExpired?.call();
      }
    });
  }

  void _updateTimeLeft() {
    setState(() {
      _timeLeft = widget.expiresAt.difference(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative || _timeLeft == Duration.zero) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE0E0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'EXPIRED',
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;
    final isUrgent = _timeLeft.inMinutes < 60;
    final isCritical = _timeLeft.inMinutes < 15;

    if (widget.compact) {
      final text = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m left';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCritical
              ? const Color(0xFFFFEBEE)
              : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCritical
                ? const Color(0xFFD32F2F)
                : const Color(0xFFE65100),
          ),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          'Ends in',
          style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hours > 0) ...[
              _TimeBlock(
                  value: hours,
                  unit: 'h',
                  isUrgent: isUrgent,
                  isCritical: isCritical),
              const SizedBox(width: 6),
            ],
            _TimeBlock(
                value: minutes,
                unit: 'm',
                isUrgent: isUrgent,
                isCritical: isCritical),
            const SizedBox(width: 6),
            _TimeBlock(
                value: seconds,
                unit: 's',
                isUrgent: isUrgent,
                isCritical: isCritical),
          ],
        ),
      ],
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final int value;
  final String unit;
  final bool isUrgent;
  final bool isCritical;

  const _TimeBlock({
    required this.value,
    required this.unit,
    required this.isUrgent,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFF5F5F5);
    Color textColor = const Color(0xFF333333);

    if (isCritical) {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else if (isUrgent) {
      bgColor = const Color(0xFFFFF3E0);
      textColor = const Color(0xFFE65100);
    }

    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
