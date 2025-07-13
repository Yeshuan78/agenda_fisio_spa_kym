import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/tratamiento_model.dart';

class TratamientoCard extends StatelessWidget {
  final TratamientoModel tratamiento;

  const TratamientoCard({super.key, required this.tratamiento});

  @override
  Widget build(BuildContext context) {
    final cantidadTotal = tratamiento.sesiones.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          left: BorderSide(
            color: Color(0xFF81C784), // Verde pastel
            width: 5,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.spa, color: Color(0xFF81C784), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tratamiento.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Total sesiones: $cantidadTotal",
                    style: const TextStyle(fontSize: 13)),
                Text("Precio: \$${tratamiento.precioTotal}",
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tratamiento.sesiones.map((s) {
                    return Chip(
                      label: Text("Sesión ${s.numero} · ${s.servicioId}"),
                      backgroundColor:
                          const Color(0xFF81C784).withValues(alpha: 0.01),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
