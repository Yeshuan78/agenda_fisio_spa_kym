// [booking_navigation_bar.dart] - BARRA NAVEGACIÓN EXTRAÍDA
// 📁 Ubicación: /lib/widgets/booking/components/booking_navigation_bar.dart
// 🎯 EXTRAER: _buildNavigationButton() de public_booking_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class BookingNavigationBar extends StatelessWidget {
  final bool canGoBack;
  final VoidCallback? onBackPressed;

  const BookingNavigationBar({
    super.key,
    required this.canGoBack,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!canGoBack) return const SizedBox.shrink();

    return Center(
      child: TextButton(
        onPressed: onBackPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 20, color: kTextSecondary),
            const SizedBox(width: 8),
            Text(
              'Volver al paso anterior',
              style: TextStyle(
                fontSize: 16,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}