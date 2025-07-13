// [booking_step_header.dart] - WIDGET HEADER DE PASO EXTRAÍDO
// 📁 Ubicación: /lib/widgets/booking/components/booking_step_header.dart
// 🎯 EXTRAER: _buildStepHeader() de public_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class BookingStepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const BookingStepHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: kTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}