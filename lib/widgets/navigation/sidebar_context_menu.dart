// [sidebar_context_menu.dart]
// 📁 /widgets/navigation/sidebar_context_menu.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';

void showSidebarContextMenu(
    BuildContext context, Offset position, SidebarOption option) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    items: [
      const PopupMenuItem(
        value: 'nuevo',
        child: Row(
          children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text('Nuevo'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'ver_ultimos',
        child: Row(
          children: [
            Icon(Icons.history, size: 18),
            SizedBox(width: 8),
            Text('Ver últimos'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'exportar',
        child: Row(
          children: [
            Icon(Icons.download, size: 18),
            SizedBox(width: 8),
            Text('Exportar'),
          ],
        ),
      ),
    ],
  ).then((value) {
    if (value == null || !context.mounted)
      return; // ✅ Protección contra async gap

    String mensaje = '';
    switch (value) {
      case 'nuevo':
        mensaje = 'Acción: Nuevo en "${option.label}"';
        break;
      case 'ver_ultimos':
        mensaje = 'Acción: Ver últimos en "${option.label}"';
        break;
      case 'exportar':
        mensaje = 'Acción: Exportar "${option.label}"';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      ),
    );
  });
}
