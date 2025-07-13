import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/professional_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'professional_card_header.dart';
import 'categoria_servicios_card.dart';

class ProfessionalCard extends StatefulWidget {
  final ProfessionalModel profesional;
  final List<String> categoriasDisponibles;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const ProfessionalCard({
    super.key,
    required this.profesional,
    required this.categoriasDisponibles,
    required this.onEdit,
    required this.onDeleted,
  });

  @override
  State<ProfessionalCard> createState() => _ProfessionalCardState();
}

class _ProfessionalCardState extends State<ProfessionalCard> {
  final Map<String, bool> categoriasExpandido = {};
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            transform: _hovering
                ? Matrix4.translationValues(0, -2, 0)
                : Matrix4.translationValues(0, 0, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovering ? 0.1 : 0.06),
                  blurRadius: _hovering ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: kBrandPurple.withValues(alpha: 0.03),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfessionalCardHeader(
                    profesional: widget.profesional,
                    onEdit: widget.onEdit,
                    onDeleted: widget.onDeleted,
                  ),
                  const SizedBox(height: 20),
                  _buildCategorias(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorias() {
    final Map<String, List<Map<String, dynamic>>> serviciosPorCategoria = {};

    for (final servicio in widget.profesional.servicios) {
      final categoria = servicio['category'] ?? 'Sin categoría';
      final nombre = servicio['name'] ?? '';
      if (nombre.isEmpty) continue;

      serviciosPorCategoria.putIfAbsent(categoria, () => []).add(servicio);
    }

    final categorias = widget.categoriasDisponibles.toSet().toList()..sort();

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing * 3) / 4;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categorias.map((categoria) {
            final servicios = serviciosPorCategoria[categoria] ?? [];
            final expandido = categoriasExpandido[categoria] ?? false;

            return SizedBox(
              width: itemWidth,
              child: CategoriaServiciosCard(
                categoria: categoria,
                servicios: servicios,
                expandido: expandido,
                onToggleExpand: (nuevoValor) {
                  setState(() {
                    categoriasExpandido[categoria] = nuevoValor;
                  });
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
