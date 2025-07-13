import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PasoHeader extends StatelessWidget {
  final String titulo;

  const PasoHeader({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    // Determinar paso actual según texto recibido
    final int pasoActual = titulo.contains('Paso 1')
        ? 0
        : titulo.contains('Paso 2')
            ? 1
            : 2;

    final pasos = [
      {'icono': Icons.person, 'texto': 'Datos'},
      {'icono': Icons.design_services, 'texto': 'Servicios'},
      {'icono': Icons.schedule, 'texto': 'Horario'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Row(
        children: List.generate(pasos.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Línea conectora entre pasos
            return Expanded(
              child: Divider(
                thickness: 2,
                color: Colors.grey.shade300,
              ),
            );
          }

          final index = i ~/ 2;
          final activo = index == pasoActual;
          final completado = index < pasoActual;

          return Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: completado
                    ? Colors.green
                    : activo
                        ? kBrandPurple
                        : Colors.grey.shade300,
                child: Icon(
                  pasos[index]['icono'] as IconData,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pasos[index]['texto'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                  color: activo ? kBrandPurple : Colors.black54,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
