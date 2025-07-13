import 'package:flutter/material.dart';
import '../../../models/evento_model.dart';
import '../../../theme/theme.dart';
import '../../../utils/export_evento_excel.dart';
import '../../../utils/export_evento_pdf.dart';
import '../../widgets/encuestas/encuesta_creator_premium.dart';

class PulseCardAcciones extends StatelessWidget {
  final EventoModel evento;
  final Map<String, int> serviciosCount;
  final Map<String, String> servicios;
  final bool isRefreshing;
  final Animation<double> refreshAnimation;
  final VoidCallback onRefresh;

  const PulseCardAcciones({
    super.key,
    required this.evento,
    required this.serviciosCount,
    required this.servicios,
    required this.isRefreshing,
    required this.refreshAnimation,
    required this.onRefresh,
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
          color: kAccentBlue.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          // ✅ SOMBRA CRISTAL PROFUNDA AZUL
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          // ✅ SOMBRA CRISTAL INTERNA
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
          // ✅ SOMBRA CRISTAL LATERAL AZUL
          BoxShadow(
            color: kAccentBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Header de Acciones GLASSMORPHISM
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ✅ CRISTAL TRANSPARENTE MORADO
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kBrandPurple.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                // ✅ SOMBRA CRISTAL MORADA
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.flash_on, color: kBrandPurple, size: 18),
                SizedBox(width: 12),
                Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kBrandPurple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ BOTÓN ENCUESTAS GLASSMORPHISM
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kAccentBlue.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EncuestaCreatorPremium(),
                  ),
                );
              },
              icon: const Icon(Icons.quiz, size: 18),
              label: const Text(
                'Editar Encuestas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ BOTÓN ACTUALIZAR PROFESIONAL
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: refreshAnimation,
              builder: (context, child) {
                return ElevatedButton.icon(
                  onPressed: isRefreshing ? null : onRefresh,
                  icon: Transform.rotate(
                    angle: refreshAnimation.value * 2 * 3.14159,
                    child: const Icon(Icons.refresh, size: 18),
                  ),
                  label: Text(
                    isRefreshing ? 'Actualizando...' : 'Actualizar',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ✅ BOTÓN EXCEL
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kAccentGreen.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => exportarResumenEventoPremium(context, evento),
              icon: const Icon(Icons.table_chart, size: 18),
              label: const Text(
                'Excel Premium',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ BOTÓN PDF
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => generarPDFConLoaderProfesional(context, evento),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text(
                'PDF',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ✅ Separador GLASSMORPHISM
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Header de Servicios
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ✅ CRISTAL TRANSPARENTE AZUL-VERDE
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kAccentBlue.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                // ✅ SOMBRA CRISTAL AZUL-VERDE
                BoxShadow(
                  color: kAccentBlue.withValues(alpha: 0.15),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.medical_services, color: kAccentBlue, size: 18),
                SizedBox(width: 12),
                Text(
                  'Servicios realizados',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kAccentBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ✅ LISTA DE SERVICIOS CON ALTURA FIJA
          Container(
            height: 200,
            decoration: BoxDecoration(
              // ✅ CRISTAL TRANSPARENTE LISTA
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                // ✅ SOMBRA CRISTAL INTERNA
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 8,
                  spreadRadius: -3,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: serviciosCount.isNotEmpty
                ? ListView(
                    padding: const EdgeInsets.all(12),
                    children: serviciosCount.entries.map((e) {
                      final servicioId = e.key;
                      final cantidad = e.value;
                      final nombreServicio =
                          servicios[servicioId] ?? servicioId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          // ✅ CRISTAL TRANSPARENTE ITEM
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: kAccentBlue.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            // ✅ SOMBRA CRISTAL AZUL ITEM
                            BoxShadow(
                              color: kAccentBlue.withValues(alpha: 0.12),
                              blurRadius: 8,
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
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                // ✅ CRISTAL TRANSPARENTE AZUL PUNTO
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: kAccentBlue.withValues(alpha: 0.6),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kAccentBlue.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                nombreServicio,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                // ✅ CRISTAL TRANSPARENTE AZUL
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: kAccentBlue.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kAccentBlue.withValues(alpha: 0.2),
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
                                '×$cantidad',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      kAccentBlue, // ✅ CAMBIO: texto azul para cristal
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sin servicios registrados',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
