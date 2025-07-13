// [evento_card_state_selector.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_state_selector.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Selector flotante de estados del EventoCard original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'evento_card_utils.dart';

class EventoCardStateSelector extends StatelessWidget {
  final EventoModel evento;
  final Function(String) onEstadoChanged;
  final VoidCallback onClose;

  const EventoCardStateSelector({
    super.key,
    required this.evento,
    required this.onEstadoChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildStateSelector() líneas 1120-1280
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_horiz, color: kBrandPurple, size: 18),
              SizedBox(width: 8),
              Text(
                'Cambiar Estado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ LISTA DE ESTADOS DISPONIBLES
          ...EventoCardUtils.estadosConfig.entries.map((entry) {
            final estado = entry.key;
            final config = entry.value;
            final isCurrentState = evento.estado == estado;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: isCurrentState ? null : () => onEstadoChanged(estado),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentState
                          ? config['color'].withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentState
                            ? config['color'].withValues(alpha: 0.3)
                            : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: config['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            config['icon'],
                            color: config['color'],
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config['label'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrentState
                                      ? config['color']
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                config['description'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCurrentState)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: config['color'],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTUAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          const SizedBox(height: 16),

          // ✅ BOTÓN CERRAR
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}