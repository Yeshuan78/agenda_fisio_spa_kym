import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/servicio_card.dart';

class ServicioGroup extends StatelessWidget {
  final CategoriaModel categoria;
  final List<ServicioModel> servicios;
  final void Function(ServicioModel) onEdit;
  final void Function(ServicioModel) onDelete;

  const ServicioGroup({
    super.key,
    required this.categoria,
    required this.servicios,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: servicios.map((servicio) {
        return ServicioCard(
          servicio: servicio,
          categoria: categoria, // ✅ Pasamos la categoría correspondiente
          onEdit: () => onEdit(servicio),
          onDelete: () => onDelete(servicio),
        );
      }).toList(),
    );
  }
}
