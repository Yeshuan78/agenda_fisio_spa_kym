// [Archivo: widgets/eventos/evento_paso_resumen.dart]
import 'package:flutter/material.dart';

class EventoPasoResumen extends StatelessWidget {
  final String nombre;
  final String empresa;
  final DateTime fecha;
  final List<Map<String, String>> serviciosAsignados;
  final List<Map<String, dynamic>> serviciosDisponibles;
  final List<Map<String, dynamic>> profesionales;

  const EventoPasoResumen({
    super.key,
    required this.nombre,
    required this.empresa,
    required this.fecha,
    required this.serviciosAsignados,
    required this.serviciosDisponibles,
    required this.profesionales,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evento: $nombre'),
        Text('Empresa: $empresa'),
        Text('Fecha: ${fecha.toLocal().toString().substring(0, 10)}'),
        const Divider(),
        ...serviciosAsignados.map((asignacion) {
          final servicioNombre = serviciosDisponibles.firstWhere(
                  (s) => s['id'] == asignacion['servicioId'],
                  orElse: () => {'nombre': 'N/A'})['nombre'] ??
              'N/A';
          final profesionalNombre = profesionales.firstWhere(
                  (p) => p['id'] == asignacion['profesionalId'],
                  orElse: () => {'nombre': 'N/A'})['nombre'] ??
              'N/A';
          return Text('• $servicioNombre → $profesionalNombre');
        }).toList(),
      ],
    );
  }
}
