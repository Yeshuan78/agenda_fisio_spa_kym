import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class FloatingMenuSpeedDial extends StatelessWidget {
  final VoidCallback onNuevoServicio;
  final VoidCallback onNuevaCategoria;
  final VoidCallback onNuevoPaquete;
  final VoidCallback onNuevoTratamiento;

  const FloatingMenuSpeedDial({
    super.key,
    required this.onNuevoServicio,
    required this.onNuevaCategoria,
    required this.onNuevoPaquete,
    required this.onNuevoTratamiento,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: kBrandPurple,
      overlayOpacity: 0.1,
      spacing: 12,
      spaceBetweenChildren: 8,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.medical_services),
          label: 'Nuevo servicio',
          backgroundColor: Colors.white,
          foregroundColor: kBrandPurple,
          onTap: onNuevoServicio,
        ),
        SpeedDialChild(
          child: const Icon(Icons.category),
          label: 'Nueva categoría',
          backgroundColor: Colors.white,
          foregroundColor: kBrandPurple,
          onTap: onNuevaCategoria,
        ),
        SpeedDialChild(
          child: const Icon(Icons.all_inclusive),
          label: 'Nuevo paquete',
          backgroundColor: Colors.white,
          foregroundColor: kBrandPurple,
          onTap: onNuevoPaquete,
        ),
        SpeedDialChild(
          child: const Icon(Icons.healing),
          label: 'Nuevo tratamiento',
          backgroundColor: Colors.white,
          foregroundColor: kBrandPurple,
          onTap: onNuevoTratamiento,
        ),
      ],
    );
  }
}
