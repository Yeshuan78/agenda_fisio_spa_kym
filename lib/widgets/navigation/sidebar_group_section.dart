// [sidebar_group_section.dart]
// 📁 /widgets/navigation/sidebar_group_section.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_item_tile.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_firestore_service.dart';

class SidebarGroupSection extends StatefulWidget {
  final String vista;
  final List<String> favoritos;
  final String currentRoute;
  final Function(String) onNavigate;
  final Function(List<String>) onFavoritosChanged;

  const SidebarGroupSection({
    super.key,
    required this.vista,
    required this.favoritos,
    required this.currentRoute,
    required this.onNavigate,
    required this.onFavoritosChanged,
  });

  @override
  State<SidebarGroupSection> createState() => _SidebarGroupSectionState();
}

class _SidebarGroupSectionState extends State<SidebarGroupSection> {
  final Map<String, bool> _estadoGrupos = {};

  @override
  void initState() {
    super.initState();
    _cargarEstadoGrupos();
  }

  void _cargarEstadoGrupos() async {
    final data = await SidebarFirestoreService.cargarPreferencias();
    setState(() => _estadoGrupos
        .addAll(Map<String, bool>.from(data['estadoGrupos'] ?? {})));
  }

  void _toggleGrupo(String grupo, bool nuevoEstado) {
    setState(() {
      _estadoGrupos[grupo] = nuevoEstado;
    });
    SidebarFirestoreService.guardarEstadoGrupo(grupo, nuevoEstado);
  }

  @override
  Widget build(BuildContext context) {
    final todos = sidebarOptions;
    final opciones = (widget.vista == 'favoritos')
        ? todos.where((opt) => widget.favoritos.contains(opt.route)).toList()
        : todos;

    final grupos = opciones.map((e) => e.group).toSet().toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        for (var grupo in grupos)
          ExpansionTile(
            key: PageStorageKey(grupo),
            title: Text(
              grupo.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            initiallyExpanded: _estadoGrupos[grupo] ?? false,
            onExpansionChanged: (isExpanded) => _toggleGrupo(grupo, isExpanded),
            children: opciones
                .where((opt) => opt.group == grupo)
                .map(
                  (opt) => SidebarItemTile(
                    option: opt,
                    isActive: widget.currentRoute == opt.route,
                    onTap: () => widget.onNavigate(opt.route),
                    esVistaEstandar: widget.vista == 'estándar',
                    favoritos: widget.favoritos,
                    onFavoritosChanged: widget.onFavoritosChanged,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
