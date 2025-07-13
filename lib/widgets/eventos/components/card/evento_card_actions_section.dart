// [evento_card_actions_section.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_actions_section.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Sección de acciones del EventoCard original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventoCardActionsSection extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventoCardActionsSection({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildAcciones() líneas 1020-1100
    return Column(
      children: [
        // ✅ CORRECCIÓN: Usar función premium de edición
        _buildActionButton(
          icon: Icons.edit_rounded,
          label: 'Editar',
          color: kAccentBlue,
          onPressed: onEdit,
        ),
        const SizedBox(height: 12),
        if (onDelete != null)
          _buildActionButton(
            icon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            color: const Color(0xFFF44336),
            onPressed: onDelete!,
          ),
      ],
    );
  }

  // ✅ EXTRACCIÓN EXACTA del método _buildActionButton()
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  color.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}