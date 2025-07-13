import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/paquete_model.dart';

class PaqueteCard extends StatelessWidget {
  final PaqueteModel paquete;

  const PaqueteCard({super.key, required this.paquete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          left: BorderSide(
            color: Color(0xFFFFB74D), // Naranja pastel
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
          Icon(Icons.auto_awesome, color: Color(0xFFFFB74D), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paquete.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Duración total: ${paquete.duracionTotal} min",
                    style: const TextStyle(fontSize: 13)),
                Text("Precio: \$${paquete.precioTotal}",
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: paquete.servicios.map((s) {
                    return Chip(
                      label: Text(
                          "Servicio: ${s.nombre ?? s.servicioId} · x${s.cantidadProfesionales}"), // ✅ CORRECTO
                      backgroundColor: const Color(0xFFFFB74D).withOpacity(0.1),
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
