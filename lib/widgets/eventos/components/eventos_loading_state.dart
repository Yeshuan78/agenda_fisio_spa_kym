// [eventos_loading_state.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_loading_state.dart
// 🎯 COPY-PASTE EXACTO de líneas 600-650 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventosLoadingState extends StatelessWidget {
  const EventosLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kBrandPurple.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cargando eventos...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}