// [clients_fab_section.dart] - FLOATING ACTION BUTTON
// 📁 Ubicación: /lib/screens/clients/widgets/clients_fab_section.dart
// 🎯 OBJETIVO: Widget para FAB animado

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

/// ➕ FLOATING ACTION BUTTON - EXTRAÍDO DEL SCREEN PRINCIPAL
class ClientsFabSection extends StatelessWidget {
  final VoidCallback onPressed;
  final Animation<double> fabAnimation;

  const ClientsFabSection({
    super.key,
    required this.onPressed,
    required this.fabAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: fabAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: kBrandPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(Icons.person_add, size: 24),
              label: const Text(
                'Nuevo Cliente',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}