import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ProfessionalTabServicios extends StatefulWidget {
  final List<Map<String, dynamic>> servicios;
  final List<String> serviciosSeleccionados;
  final void Function(List<String>) onServiciosSeleccionados;

  const ProfessionalTabServicios({
    super.key,
    required this.servicios,
    required this.serviciosSeleccionados,
    required this.onServiciosSeleccionados,
  });

  @override
  State<ProfessionalTabServicios> createState() =>
      _ProfessionalTabServiciosState();
}

class _ProfessionalTabServiciosState extends State<ProfessionalTabServicios> {
  late Map<String, List<Map<String, dynamic>>> serviciosPorCategoria;
  final Map<String, bool> _expandido = {};

  @override
  void initState() {
    super.initState();
    serviciosPorCategoria = _agruparPorCategoria(widget.servicios);
    for (var cat in serviciosPorCategoria.keys) {
      _expandido[cat] = false;
    }
  }

  @override
  void didUpdateWidget(covariant ProfessionalTabServicios oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.servicios != widget.servicios) {
      setState(() {
        serviciosPorCategoria = _agruparPorCategoria(widget.servicios);
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> _agruparPorCategoria(
      List<Map<String, dynamic>> servicios) {
    final Map<String, List<Map<String, dynamic>>> agrupados = {};
    for (final servicio in servicios) {
      final categoria = servicio['category'] ?? 'Sin categoría';
      agrupados.putIfAbsent(categoria, () => []).add(servicio);
    }
    return agrupados;
  }

  void _toggleServicio(String serviceId) {
    final nuevaLista = widget.serviciosSeleccionados.contains(serviceId)
        ? widget.serviciosSeleccionados.where((id) => id != serviceId).toList()
        : [...widget.serviciosSeleccionados, serviceId];
    widget.onServiciosSeleccionados(nuevaLista);
  }

  void _toggleTodos(String categoria, bool seleccionar) {
    final ids = serviciosPorCategoria[categoria]!
        .map((s) => s['serviceId'] as String?)
        .whereType<String>()
        .toList();

    final nuevaLista = seleccionar
        ? {...widget.serviciosSeleccionados, ...ids}.toList()
        : widget.serviciosSeleccionados
            .where((id) => !ids.contains(id))
            .toList();

    widget.onServiciosSeleccionados(nuevaLista);
  }

  Color _colorFondo(String categoria) {
    final base = categoria.trim().toLowerCase();
    final colores = {
      'masajes': const Color(0xFFE1F5FE),
      'faciales': const Color(0xFFFFF3E0),
      'fisioterapia': const Color(0xFFE8F5E9),
      'podología': const Color(0xFFF3E5F5),
      'cosmetología': const Color(0xFFFFEBEE),
    };
    return colores[base] ?? Colors.grey.shade100;
  }

  Color _colorBorde(String categoria) {
    final base = categoria.trim().toLowerCase();
    final colores = {
      'masajes': const Color(0xFF4FC3F7),
      'faciales': const Color(0xFFFFB74D),
      'fisioterapia': const Color(0xFF81C784),
      'podología': const Color(0xFFBA68C8),
      'cosmetología': const Color(0xFFEF5350),
    };
    return colores[base] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: serviciosPorCategoria.entries.map((entry) {
          final categoria = entry.key;
          final servicios = entry.value;
          final expandido = _expandido[categoria] ?? false;
          final colorFondo = _colorFondo(categoria);
          final colorBorde = _colorBorde(categoria);
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: colorBorde, width: 1.4),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorFondo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        expandido ? Icons.folder_open : Icons.folder,
                        size: 16,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Seleccionar todos',
                        onPressed: () => _toggleTodos(categoria, true),
                        icon:
                            Icon(Icons.select_all, color: colorBorde, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Deseleccionar todos',
                        onPressed: () => _toggleTodos(categoria, false),
                        icon: Icon(Icons.remove_done,
                            color: colorBorde, size: 20),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _expandido[categoria] = !expandido);
                        },
                        icon: Icon(
                          expandido
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: servicios.map((servicio) {
                        final id = servicio['serviceId'] as String?;
                        final nombre = servicio['name'] ?? '';
                        if (id == null) return const SizedBox.shrink();

                        final seleccionado =
                            widget.serviciosSeleccionados.contains(id);

                        return GestureDetector(
                          onTap: () => _toggleServicio(id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorFondo,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    seleccionado ? colorBorde : Colors.black26,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (seleccionado) ...[
                                  Icon(Icons.check,
                                      size: 16, color: colorBorde),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  crossFadeState: expandido
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
