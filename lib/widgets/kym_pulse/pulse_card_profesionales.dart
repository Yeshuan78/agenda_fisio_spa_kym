import 'package:flutter/material.dart';
import '../../../models/evento_model.dart';
import '../../../models/servicio_realizado_model.dart';
import '../../../theme/theme.dart';

class PulseCardProfesionales extends StatelessWidget {
  final EventoModel evento;
  final List<ServicioRealizadoModel> registros;
  final Map<String, String> servicios;
  final Map<String, String> profesionales;

  const PulseCardProfesionales({
    super.key,
    required this.evento,
    required this.registros,
    required this.servicios,
    required this.profesionales,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ✅ GLASSMORPHISM CRISTAL - SIN FONDO COLOR
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          // ✅ SOMBRA CRISTAL PROFUNDA
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          // ✅ SOMBRA CRISTAL INTERNA
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 15,
            spreadRadius: -3,
            offset: const Offset(0, -3),
          ),
          // ✅ SOMBRA CRISTAL LATERAL
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(4, 0),
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
                  // ✅ CRISTAL TRANSPARENTE
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kBrandPurple.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.group, color: kBrandPurple, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'Profesionales', // ✅ CAMBIO: texto más corto
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...evento.serviciosAsignados.map((e) {
            final pid = e['profesionalId'] ?? '';
            final sid = e['servicioId'] ?? '';
            final nombreProf = profesionales[pid] ?? pid;
            final nombreServ = servicios[sid] ?? sid;
            final conteo = registros
                .where((r) => r.profesionalId == pid && r.servicioId == sid)
                .length;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ✅ CRISTAL TRANSPARENTE
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kBrandPurple.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  // ✅ SOMBRA CRISTAL INDIVIDUAL
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      // ✅ CRISTAL TRANSPARENTE MORADO PUNTO
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: kBrandPurple.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandPurple.withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreProf,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          nombreServ,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      // ✅ CRISTAL TRANSPARENTE VERDE
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kAccentGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kAccentGreen.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 4,
                          spreadRadius: -1,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Text(
                      '×$conteo',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            kAccentGreen, // ✅ CAMBIO: texto verde para cristal
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
