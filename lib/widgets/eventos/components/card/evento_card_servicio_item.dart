// [evento_card_servicio_item.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_servicio_item.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Item individual de servicio del EventoCard original

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/utils/qr_pdf_utils.dart';
import 'evento_card_utils.dart';

class EventoCardServicioItem extends StatelessWidget {
  final Map<String, dynamic> asignacion;
  final int index;
  final EventoModel evento;
  final Animation<double> copyAnimation;

  const EventoCardServicioItem({
    super.key,
    required this.asignacion,
    required this.index,
    required this.evento,
    required this.copyAnimation,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ EXTRACCIÓN EXACTA del método _buildServicioItem() líneas 880-1000
    final profesionalNombre = asignacion['profesionalNombre'] ?? 'Profesional';
    final servicioNombre = asignacion['servicioNombre'] ?? 'Servicio';
    final servicioId = asignacion['servicioId'] ?? '';
    final profesionalId = asignacion['profesionalId'] ?? '';
    final eventoId = evento.eventoId ?? '';
    final qrUrl =
        'https://fisiospakym.com/kym-pulse/?e=$eventoId&p=$profesionalId&s=$servicioId';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kAccentGreen.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAccentGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [kAccentBlue, kAccentGreen]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profesionalNombre,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  servicioNombre,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              // ✅ BOTÓN QR
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () async {
                    if (!context.mounted) return;
                    await QRPdfGenerator.generarQRComoPDF(
                      context: context,
                      url: qrUrl,
                      servicio: servicioNombre,
                      profesional: profesionalNombre,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kBrandPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.qr_code_2,
                        size: 16, color: kBrandPurple),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // ✅ BOTÓN COPIAR URL
              AnimatedBuilder(
                animation: copyAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: copyAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => EventoCardUtils.copiarURL(context, qrUrl, 
                          // Necesitamos pasar el controller desde el padre
                          AnimationController(duration: Duration.zero, vsync: Scaffold.of(context))),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kAccentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.copy,
                              size: 14, color: kAccentGreen),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}