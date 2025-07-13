import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class PulseCardEncuestas extends StatelessWidget {
  final int totalEncuestas;
  final double promedioGlobal;
  final List<String> mostrarComentarios;
  final int restantes;
  final List<String> comentariosPlanos;
  final int totalRegistros;

  const PulseCardEncuestas({
    super.key,
    required this.totalEncuestas,
    required this.promedioGlobal,
    required this.mostrarComentarios,
    required this.restantes,
    required this.comentariosPlanos,
    required this.totalRegistros,
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
          color: kAccentGreen.withValues(alpha: 0.25),
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
            color: kAccentGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ✅ CRISTAL TRANSPARENTE
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: kAccentGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentGreen.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.poll, color: kAccentGreen, size: 16),
              ),
              const SizedBox(width: 12),
              const Text(
                'Encuestas', // ✅ CAMBIO: texto más corto
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: kAccentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (totalEncuestas > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ✅ CRISTAL TRANSPARENTE
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  // ✅ SOMBRA CRISTAL DORADA
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.15),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 10,
                    spreadRadius: -2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ✅ CRISTAL TRANSPARENTE DORADO
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: -1,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.star,
                        color: Colors.amber,
                        size: 20), // ✅ CAMBIO: icono ámbar para cristal
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        promedioGlobal > 0
                            ? promedioGlobal.toStringAsFixed(1)
                            : '0.0',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kBrandPurple,
                        ),
                      ),
                      const Text(
                        '/ 5.0',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Promedio general ($totalEncuestas respuestas)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (comentariosPlanos.isNotEmpty) ...[
              ...mostrarComentarios.take(3).map((coment) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ✅ CRISTAL TRANSPARENTE
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        // ✅ SOMBRA CRISTAL AZUL
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.12),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: -1,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Text(
                      '"$coment"',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              if (restantes > 0)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('💬 Todos los comentarios'),
                        content: SizedBox(
                          width: 500,
                          height: 400,
                          child: ListView.builder(
                            itemCount: comentariosPlanos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: kAccentGreen.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: kAccentGreen.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  comentariosPlanos[index],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          )
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_horiz,
                      size: 16, color: kAccentGreen),
                  label: Text(
                    'Ver $restantes más',
                    style: const TextStyle(fontSize: 11, color: kAccentGreen),
                  ),
                ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // ✅ CRISTAL TRANSPARENTE GRIS
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  // ✅ SOMBRA CRISTAL GRIS
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Sin respuestas de encuesta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Los registros aún no tienen encuestas respondidas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registros totales: $totalRegistros',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
