// [route_badge_widget.dart] - BADGE DE RUTAS EXTRAÍDO
// 📁 Ubicación: /lib/widgets/layout/components/route_badge_widget.dart
// 🎯 WIDGET BADGE PARA RUTAS

import 'package:flutter/material.dart';

class RouteBadgeWidget extends StatelessWidget {
  final String text;
  final Color color;
  
  const RouteBadgeWidget({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}