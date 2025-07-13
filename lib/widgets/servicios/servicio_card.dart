import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/iconos_categoria_servicio.dart';

class ServicioCard extends StatelessWidget {
  final ServicioModel servicio;
  final CategoriaModel categoria;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServicioCard({
    super.key,
    required this.servicio,
    required this.categoria,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIconoCategoria(String nombreIcono) {
    return iconosCategoriaServicio[nombreIcono] ?? Icons.folder;
  }

  String _getEnergiaLabel(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'baja':
        return '🔋 Relajante';
      case 'media':
        return '⚡ Moderado';
      case 'alta':
        return '🔥 Intenso';
      default:
        return nivel;
    }
  }

  Widget _buildTipoChip() {
    String label;
    IconData icon;

    switch (servicio.tipo.toLowerCase()) {
      case 'domicilio':
        label = 'Domicilio';
        icon = Icons.home;
        break;
      case 'presencial':
        label = 'Presencial';
        icon = Icons.location_city;
        break;
      case 'híbrido':
        label = 'Híbrido';
        icon = Icons.swap_horiz;
        break;
      default:
        label = servicio.tipo;
        icon = Icons.help_outline;
    }

    return Tooltip(
      message: "Forma en que se ofrece este servicio",
      child: Chip(
        label: Text(label),
        backgroundColor: kBrandPurple.withOpacity(0.1),
        avatar: Icon(icon, size: 16, color: kBrandPurple),
        labelStyle: const TextStyle(color: kBrandPurple, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildEstadoTag() {
    final activo = servicio.activo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: activo ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        activo ? "Activo" : "Inactivo",
        style: TextStyle(
          color: activo ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescripcionChip() {
    if (servicio.description.isEmpty) return const SizedBox.shrink();

    return Tooltip(
      message: servicio.description,
      child: Chip(
        avatar: const Icon(Icons.chat_bubble_outline,
            size: 16, color: Colors.black54),
        label: const Text('Ver descripción'),
        labelStyle: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
        backgroundColor: Colors.grey[100], // ✅ gris suave
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      hex = hex.replaceAll("#", "");
      if (hex.length == 6) hex = "FF$hex";
      return Color(int.parse("0x$hex"));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorCategoria = _parseColor(categoria.colorHex);
    final icono = _getIconoCategoria(categoria.icono);
    final tiempoTotal = servicio.duration + (servicio.bufferMin ?? 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
              color: colorCategoria, width: 4), // ✅ solo borde izquierdo
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorCategoria, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Línea 1: Nombre + Estado
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        servicio.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _buildEstadoTag(),
                  ],
                ),
                const SizedBox(height: 6),

                /// Línea 2: Metadata alineada horizontal
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Tooltip(
                      message: "Duración total incluyendo tiempo real y buffer",
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 16),
                          const SizedBox(width: 4),
                          Text('$tiempoTotal min',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: "Precio final del servicio",
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_money, size: 16),
                          Text('\$${servicio.price}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Tooltip(
                      message:
                          "Cantidad máxima de personas que pueden recibir este servicio",
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.groups, size: 16),
                          const SizedBox(width: 4),
                          Text('x${servicio.capacidad}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    Tooltip(
                      message:
                          "Nivel de esfuerzo físico o concentración requerido",
                      child: Text(
                        _getEnergiaLabel(servicio.nivelEnergia),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    _buildTipoChip(),
                  ],
                ),
                const SizedBox(height: 6),

                /// Línea 3: Descripción como chip visual
                _buildDescripcionChip(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: kBrandPurple),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
