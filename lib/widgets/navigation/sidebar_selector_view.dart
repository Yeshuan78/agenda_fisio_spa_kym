// [sidebar_selector_view.dart]
// 📁 /widgets/navigation/sidebar_selector_view.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class SidebarSelectorView extends StatelessWidget {
  final String vistaActual;
  final Function(String) onVistaChanged;

  const SidebarSelectorView({
    super.key,
    required this.vistaActual,
    required this.onVistaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIcon(Icons.view_sidebar, 'Estándar', 'estándar'),
        _buildIcon(Icons.favorite_border, 'Favoritos', 'favoritos'),
        _buildIcon(Icons.tune, 'Personalizar', 'personalizada'),
      ],
    );
  }

  Widget _buildIcon(IconData icon, String label, String tipo) {
    final bool activo = vistaActual == tipo;
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onVistaChanged(tipo),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activo ? kBrandPurple.withAlpha(25) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 26,
            color: activo ? kBrandPurple : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
