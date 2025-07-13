import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'hover_card_servicio.dart';

class ChipServicioProfesional extends StatefulWidget {
  final Map<String, dynamic> servicio;

  const ChipServicioProfesional({
    super.key,
    required this.servicio,
  });

  @override
  State<ChipServicioProfesional> createState() =>
      _ChipServicioProfesionalState();
}

class _ChipServicioProfesionalState extends State<ChipServicioProfesional> {
  OverlayEntry? _hoverOverlay;

  String get nombre => widget.servicio['name'] ?? '';
  String get categoria => widget.servicio['category'] ?? 'Sin categoría';

  String _formatearNombre(String nombre, String categoria) {
    final nombreLower = nombre.toLowerCase();
    final catLower = categoria.toLowerCase();

    final posiblesPrefijos = [
      catLower,
      catLower.endsWith('s') ? catLower.substring(0, catLower.length - 1) : '',
      catLower.endsWith('es') ? catLower.substring(0, catLower.length - 2) : '',
    ].where((p) => p.isNotEmpty).toList();

    for (final prefijo in posiblesPrefijos) {
      if (nombreLower.startsWith(prefijo)) {
        final sinPrefijo = nombre.substring(prefijo.length).trimLeft();

        if (sinPrefijo.isNotEmpty &&
            sinPrefijo.toLowerCase() != prefijo &&
            !nombreLower.contains('limpieza')) {
          return sinPrefijo;
        }
      }
    }

    return nombre;
  }

  Color _colorPorCategoria(String categoria) {
    final base = categoria.trim().toLowerCase();
    final colores = {
      'masajes': const Color(0xFFE1F5FE),
      'faciales': const Color(0xFFFFF3E0),
      'fisioterapia': const Color(0xFFE8F5E9),
      'podología': const Color(0xFFF3E5F5),
      'cosmetología': const Color(0xFFFFEBEE),
    };
    return (colores[base] ?? kAccentBlue)
        .withValues(alpha: 0.09); // ⚠️ se mantiene
  }

  void _mostrarHover(BuildContext context, Offset offset) {
    _hoverOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 10,
        top: offset.dy + 10,
        child: HoverCardServicio(
          nombre: nombre,
          duracion: widget.servicio['duracion']?.toString(),
          notas: widget.servicio['notas']?.toString(),
        ),
      ),
    );

    Overlay.of(context).insert(_hoverOverlay!);
  }

  void _ocultarHover() {
    _hoverOverlay?.remove();
    _hoverOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final texto = _formatearNombre(nombre, categoria);
    final colorFondo = _colorPorCategoria(categoria);

    return MouseRegion(
      onEnter: (event) => _mostrarHover(context, event.position),
      onExit: (_) => _ocultarHover(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12),
        ),
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ocultarHover();
    super.dispose();
  }
}
