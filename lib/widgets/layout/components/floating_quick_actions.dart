// [floating_quick_actions_widget.dart] - ACCIONES FLOTANTES EXTRAÍDAS
// 📁 Ubicación: /lib/widgets/layout/components/floating_quick_actions_widget.dart
// 🎯 WIDGET ACCIONES RÁPIDAS FLOTANTES

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/quick_actions_row.dart';

class FloatingQuickActionsWidget extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSettingsPressed;
  
  const FloatingQuickActionsWidget({
    super.key,
    required this.onSearchPressed,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.095),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.015),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.01),
          width: 1,
        ),
      ),
      child: QuickActionsRow(
        onSearchPressed: onSearchPressed,
        onNotificationsPressed: onNotificationsPressed,
        onSettingsPressed: onSettingsPressed,
      ),
    );
  }
}