import 'package:flutter/material.dart';
import '../../../models/evento_model.dart';
import '../../../theme/theme.dart';

class PulseCardEstadoSelector extends StatelessWidget {
  final EventoModel evento;
  final Map<String, Map<String, dynamic>> estadosConfig;
  final Function(String) onEstadoChanged;
  final VoidCallback onClose;

  const PulseCardEstadoSelector({
    super.key,
    required this.evento,
    required this.estadosConfig,
    required this.onEstadoChanged,
    required this.onClose,
  });

  Color _getStatusColor() =>
      estadosConfig[evento.estado]?['color'] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 15,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kBrandPurple.withValues(alpha: 0.2),
                      kBrandPurple.withValues(alpha: 0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.swap_horiz, color: kBrandPurple, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cambiar Estado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ✅ LISTA DE ESTADOS IDÉNTICA A EVENTO CARD
          ...estadosConfig.entries.map((entry) {
            final estado = entry.key;
            final config = entry.value;
            final isCurrentState = evento.estado == estado;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isCurrentState ? null : () => onEstadoChanged(estado),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isCurrentState
                          ? LinearGradient(
                              colors: [
                                config['color'].withValues(alpha: 0.15),
                                config['color'].withValues(alpha: 0.08),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white.withValues(alpha: 0.4),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentState
                            ? config['color'].withValues(alpha: 0.4)
                            : Colors.grey.withValues(alpha: 0.2),
                        width: isCurrentState ? 2 : 1,
                      ),
                      boxShadow: isCurrentState
                          ? [
                              BoxShadow(
                                color: config['color'].withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                config['color'].withValues(alpha: 0.2),
                                config['color'].withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: config['color'].withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            config['icon'],
                            color: config['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                config['label'],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
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
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  config['color'],
                                  config['color'].withValues(alpha: 0.8)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: config['color'].withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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

          const SizedBox(height: 20),

          // ✅ BOTÓN CERRAR
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.3),
                      width: 1,
                    ),
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
          ),
        ],
      ),
    );
  }
}