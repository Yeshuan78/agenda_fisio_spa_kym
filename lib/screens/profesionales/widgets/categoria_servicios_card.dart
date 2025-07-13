import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'chip_servicio.dart';

class CategoriaServiciosCard extends StatefulWidget {
  final String categoria;
  final List<Map<String, dynamic>> servicios;
  final bool expandido;
  final Function(bool) onToggleExpand;

  const CategoriaServiciosCard({
    super.key,
    required this.categoria,
    required this.servicios,
    required this.expandido,
    required this.onToggleExpand,
  });

  @override
  State<CategoriaServiciosCard> createState() => _CategoriaServiciosCardState();
}

class _CategoriaServiciosCardState extends State<CategoriaServiciosCard>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  Color _colorFondoPorCategoria(String categoria) {
    final base = categoria.trim().toLowerCase();
    final colores = {
      'masajes': const Color(0xFFE1F5FE),
      'faciales': const Color(0xFFFFF3E0),
      'fisioterapia': const Color(0xFFE8F5E9),
      'podología': const Color(0xFFF3E5F5),
      'cosmetología': const Color(0xFFFFEBEE),
    };
    return colores[base] ?? kAccentBlue.withValues(alpha: 0.09);
  }

  Color _colorBordePorCategoria(String categoria) {
    final base = categoria.trim().toLowerCase();
    final colores = {
      'masajes': const Color(0xFF4FC3F7),
      'faciales': const Color(0xFFFFB74D),
      'fisioterapia': const Color(0xFF81C784),
      'podología': const Color(0xFFBA68C8),
      'cosmetología': const Color(0xFFEF5350),
    };
    return colores[base] ?? kAccentBlue;
  }

  @override
  Widget build(BuildContext context) {
    final tieneServicios = widget.servicios.isNotEmpty;
    final colorFondo = _colorFondoPorCategoria(widget.categoria);
    final colorBorde = _colorBordePorCategoria(widget.categoria);

    return GestureDetector(
      onTap: tieneServicios
          ? () => widget.onToggleExpand(!widget.expandido)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorBorde, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.003),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header refinado con tooltip condicional
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 36),
              decoration: BoxDecoration(
                color: colorFondo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 6),
                  Icon(
                    widget.expandido ? Icons.folder_open : Icons.folder,
                    size: 16,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Tooltip(
                      message: tieneServicios
                          ? 'Ver servicios de ${widget.categoria}'
                          : 'Sin servicios asignados',
                      child: Text(
                        widget.categoria,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          letterSpacing: 0.3,
                          color: Colors.black87,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: Colors.black87),
                  const SizedBox(width: 6),
                ],
              ),
            ),

            const SizedBox(height: 6),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: widget.expandido
                  ? Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.only(right: 4),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        radius: const Radius.circular(8),
                        thickness: 4,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: widget.servicios.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 16, left: 6),
                                  child: Text(
                                    '(Sin servicios asignados)',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: widget.servicios
                                      .map(
                                        (servicio) => ChipServicioProfesional(
                                            servicio: servicio),
                                      )
                                      .toList(),
                                ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
