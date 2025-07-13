// [sidebar_drag_container.dart]
// 📁 /widgets/navigation/sidebar_drag_container.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_item_tile.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class SidebarDragContainer extends StatefulWidget {
  final List<String> orden;
  final Function(List<String>) onReordenar;
  final String currentRoute;
  final Function(String) onNavigate;

  const SidebarDragContainer({
    super.key,
    required this.orden,
    required this.onReordenar,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<SidebarDragContainer> createState() => _SidebarDragContainerState();
}

class _SidebarDragContainerState extends State<SidebarDragContainer> {
  late List<String> ordenActual;

  @override
  void initState() {
    super.initState();
    ordenActual = List.from(widget.orden);
    if (ordenActual.isEmpty) {
      ordenActual = sidebarOptions.map((e) => e.route).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final opciones = sidebarOptions
        .where((opt) => ordenActual.contains(opt.route))
        .toList()
      ..sort((a, b) =>
          ordenActual.indexOf(a.route).compareTo(ordenActual.indexOf(b.route)));

    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 4,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: child,
        );
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = ordenActual.removeAt(oldIndex);
          ordenActual.insert(newIndex, item);
        });
        widget.onReordenar(ordenActual);
      },
      children: [
        for (final opt in opciones)
          Container(
            key: ValueKey(opt.route),
            child: SidebarItemTile(
              option: opt,
              isActive: widget.currentRoute == opt.route,
              onTap: () => widget.onNavigate(opt.route),
              esVistaEstandar: false,
              favoritos: const [],
              onFavoritosChanged: (_) {},
            ),
          ),
      ],
    );
  }
}
