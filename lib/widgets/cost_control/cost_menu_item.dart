// [cost_menu_item.dart] - ITEM EN EL MENÚ FAB PARA ACCEDER AL DASHBOARD
// 📁 Ubicación: /lib/widgets/cost_control/cost_menu_item.dart
// 🎯 OBJETIVO: Widget para agregar al menú FAB existente sin modificar su estructura

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CostMenuItem {
  /// 🎯 Construir tile para control de costos en menú FAB
  /// Se integra perfectamente con el diseño existente
  static Widget buildCostControlTile({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kAccentGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kAccentGreen.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAccentGreen, kAccentGreen.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.savings, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Control de Costos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ver estadísticas y configurar límites',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: kAccentGreen, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 Construir tile compacto para espacios reducidos
  static Widget buildCompactTile({
    required BuildContext context,
    required VoidCallback onTap,
    String? currentMode,
    double? currentCost,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getModeColor(currentMode).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getModeColor(currentMode).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getModeIcon(currentMode),
                color: _getModeColor(currentMode),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                currentCost != null 
                    ? '\$${currentCost.toStringAsFixed(2)}' 
                    : 'Costos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getModeColor(currentMode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 Construir badge simple para mostrar solo información
  static Widget buildInfoBadge({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Helper methods para colores e iconos
  static Color _getModeColor(String? mode) {
    switch (mode) {
      case 'live':
        return Colors.blue.shade600;
      case 'burst':
        return Colors.orange.shade600;
      case 'manual':
      default:
        return kAccentGreen;
    }
  }

  static IconData _getModeIcon(String? mode) {
    switch (mode) {
      case 'live':
        return Icons.flash_on;
      case 'burst':
        return Icons.speed;
      case 'manual':
      default:
        return Icons.savings;
    }
  }
}