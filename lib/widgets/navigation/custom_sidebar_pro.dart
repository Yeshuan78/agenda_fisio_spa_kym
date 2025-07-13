// [custom_sidebar_pro.dart]
// 📁 Ubicación: /widgets/navigation/custom_sidebar_pro.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_selector_view.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_group_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_drag_container.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_firestore_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CustomSidebarPro extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const CustomSidebarPro({
    Key? key,
    required this.currentRoute,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<CustomSidebarPro> createState() => _CustomSidebarProState();
}

class _CustomSidebarProState extends State<CustomSidebarPro> {
  String vista = 'estándar';
  List<String> favoritos = [];
  List<String> ordenPersonalizado = [];

  @override
  void initState() {
    super.initState();

    SidebarFirestoreService.cargarPreferencias().then((prefs) {
      setState(() {
        vista = prefs['vista'] ?? 'estándar';
        favoritos = List<String>.from(prefs['favoritos'] ?? []);
        ordenPersonalizado =
            List<String>.from(prefs['ordenPersonalizado'] ?? []);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        // ✅ CONECTADO AL THEME - En lugar de kWhite hardcoded
        color: Theme.of(context).colorScheme.surface,

        // ✅ SOMBRA PREMIUM DEL THEME
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.15),
            offset: const Offset(2, 0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          SidebarSelectorView(
            vistaActual: vista,
            onVistaChanged: (nuevaVista) {
              setState(() => vista = nuevaVista);
              SidebarFirestoreService.guardarVista(nuevaVista);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Builder(
              builder: (context) {
                if (vista == 'personalizada') {
                  return SidebarDragContainer(
                    orden: ordenPersonalizado,
                    onReordenar: (nuevoOrden) {
                      setState(() => ordenPersonalizado = nuevoOrden);
                      SidebarFirestoreService.guardarOrden(nuevoOrden);
                    },
                    currentRoute: widget.currentRoute,
                    onNavigate: widget.onNavigate,
                  );
                }
                return SidebarGroupSection(
                  vista: vista,
                  favoritos: favoritos,
                  currentRoute: widget.currentRoute,
                  onNavigate: widget.onNavigate,
                  onFavoritosChanged: (nuevos) {
                    SidebarFirestoreService.guardarFavoritos(nuevos);
                    setState(() => favoritos = nuevos);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
