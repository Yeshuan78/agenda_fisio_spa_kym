import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PasoHeader extends StatelessWidget {
  final int currentIndex;

  const PasoHeader({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final pasos = [
      _PasoData('Datos personales', Icons.person),
      _PasoData('Servicios', Icons.design_services),
      _PasoData('Horario', Icons.calendar_today),
    ];

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(pasos.length, (i) {
          final esActual = i == currentIndex;
          final esCompletado = i < currentIndex;

          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: esCompletado
                      ? Colors.green
                      : esActual
                          ? kBrandPurple
                          : Colors.grey.shade300,
                  child: Icon(
                    esCompletado ? Icons.check : pasos[i].icon,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pasos[i].label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: esActual ? FontWeight.bold : FontWeight.normal,
                    color: esActual
                        ? kBrandPurple
                        : esCompletado
                            ? Colors.black87
                            : Colors.grey,
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PasoData {
  final String label;
  final IconData icon;
  _PasoData(this.label, this.icon);
}
