// [Archivo: lib/utils/export_evento_pdf.dart] - VERSIÓN SEGURA SIN ERRORES CON DISEÑO PROFESIONAL
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento_model.dart';
import '../models/servicio_realizado_model.dart';

// ✅ COLORES DE MARCA PARA PDF
const PdfColor kBrandPurplePdf = PdfColor.fromInt(0xFF9920A7);
const PdfColor kAccentBluePdf = PdfColor.fromInt(0xFF4DB1E0);
const PdfColor kAccentGreenPdf = PdfColor.fromInt(0xFF8ABF54);
const PdfColor kBrandPurpleLightPdf = PdfColor.fromInt(0xFFEADCF9);

// ✅ FUNCIÓN PRINCIPAL
Future<void> generarPDFConLoaderProfesional(
  BuildContext context,
  EventoModel evento,
) async {
  Uint8List? pdfBytes;

  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (context) => _PDFGenerationDialogMejorado(
      evento: evento,
      onPDFGenerated: (bytes) {
        pdfBytes = bytes;
      },
    ),
  );

  if (pdfBytes != null && context.mounted) {
    await _mostrarOpcionesMejoradas(context, pdfBytes!, evento);
  }
}

// ✅ DIALOG CON HOJAS CAYENDO
class _PDFGenerationDialogMejorado extends StatefulWidget {
  final EventoModel evento;
  final Function(Uint8List) onPDFGenerated;

  const _PDFGenerationDialogMejorado({
    required this.evento,
    required this.onPDFGenerated,
  });

  @override
  State<_PDFGenerationDialogMejorado> createState() =>
      _PDFGenerationDialogMejoradoState();
}

class _PDFGenerationDialogMejoradoState
    extends State<_PDFGenerationDialogMejorado> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _particlesController;

  int _currentStep = 0;
  bool _isCompleted = false;
  String _errorMessage = '';

  final List<_PDFStep> _steps = [
    _PDFStep('Recopilando datos del evento', Icons.event_note),
    _PDFStep('Procesando encuestas y registros', Icons.quiz),
    _PDFStep('Calculando estadísticas', Icons.analytics),
    _PDFStep('Generando documento PDF', Icons.picture_as_pdf),
    _PDFStep('Finalizando reporte', Icons.check_circle),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _startGeneration();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    try {
      for (int i = 0; i < _steps.length; i++) {
        if (!mounted) return;

        setState(() => _currentStep = i);
        await _progressController.animateTo((i + 1) / _steps.length);

        switch (i) {
          case 0:
            await Future.delayed(const Duration(milliseconds: 1200));
            break;
          case 1:
            await Future.delayed(const Duration(milliseconds: 1000));
            break;
          case 2:
            await Future.delayed(const Duration(milliseconds: 800));
            break;
          case 3:
            // ✅ GENERAR PDF CON TIMEOUT
            try {
              final pdfBytes = await _generarPDFOptimizado(widget.evento)
                  .timeout(const Duration(seconds: 30));
              widget.onPDFGenerated(pdfBytes);
            } on TimeoutException {
              throw Exception('Tiempo de espera agotado');
            }
            await Future.delayed(const Duration(milliseconds: 600));
            break;
          case 4:
            await Future.delayed(const Duration(milliseconds: 400));
            break;
        }
      }

      if (!mounted) return;
      setState(() => _isCompleted = true);

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isCompleted = false;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // ✅ HOJAS DE REPORTE CAYENDO
            ...List.generate(
              6,
              (index) => AnimatedBuilder(
                animation: _particlesController,
                builder: (context, child) {
                  final offset =
                      (_particlesController.value + index * 0.2) % 1.0;
                  final horizontalOffset = (index % 2 == 0)
                      ? 50 + (index * 60.0)
                      : 80 + (index * 45.0);
                  return Positioned(
                    left: horizontalOffset,
                    top: 30 + (offset * 320),
                    child: Transform.rotate(
                      angle: offset * 0.5,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.description_outlined,
                          size: 18 + (index * 4.0),
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStepsList(),
                  const SizedBox(height: 28),
                  _buildProgressBar(),
                  const SizedBox(height: 20),
                  if (_isCompleted) _buildCompletionState(),
                  if (_errorMessage.isNotEmpty) _buildErrorState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _particlesController]),
          builder: (context, child) {
            final pulseScale = 0.85 + (_pulseController.value * 0.3);
            final rotation = _particlesController.value * 2 * 3.14159;

            return Transform.rotate(
              angle: rotation * 0.1,
              child: Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red[400]!,
                        Colors.pink[400]!,
                        Colors.red[600]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.04),
                        blurRadius: 15 + (_pulseController.value * 10),
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.02),
                        blurRadius: 25 + (_pulseController.value * 15),
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // ✅ TÍTULO SIMPLIFICADO
        AnimatedBuilder(
          animation: _particlesController,
          builder: (context, child) {
            final opacity = 0.7 + (_particlesController.value * 0.3);
            return Opacity(
              opacity: opacity,
              child: const Text(
                'Generando reporte',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.evento.nombre,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return Column(
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep && !_isCompleted;
        final isPending = index > _currentStep;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green[500]
                      : isCurrent
                          ? Colors.blue[500]
                          : Colors.grey[300],
                  boxShadow: isCompleted || isCurrent
                      ? [
                          BoxShadow(
                            color: (isCompleted ? Colors.green : Colors.blue)
                                .withValues(alpha: 0.03),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    color: isPending ? Colors.grey[500] : Colors.black87,
                  ),
                ),
              ),
              if (isCurrent)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[500]!),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso general',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Text(
                  '${(_progressController.value * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[400]!, Colors.pink[400]!],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green[600],
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Reporte generado exitosamente!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige cómo quieres visualizarlo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_rounded,
            color: Colors.red[600],
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error al generar el reporte',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage.length > 60
                      ? '${_errorMessage.substring(0, 60)}...'
                      : _errorMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PDFStep {
  final String label;
  final IconData icon;
  _PDFStep(this.label, this.icon);
}

// ✅ GENERAR PDF OPTIMIZADO CON DISEÑO PROFESIONAL Y COLORES DE MARCA
Future<Uint8List> _generarPDFOptimizado(EventoModel evento) async {
  final doc = pw.Document();

  // Cargar logo
  final ByteData logoData =
      await rootBundle.load('assets/images/logo_kym_black.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();

  // Cargar datos con yields
  await Future.delayed(const Duration(milliseconds: 50));
  // ✅ LIMPIEZA PREVENTIVA TEMPRANA (ANTES DE PROCESAR)
  await Future.delayed(const Duration(milliseconds: 50));

  // Limpiar TODOS los textos de entrada desde el inicio
  final eventoLimpio = EventoModel(
    id: evento.id,
    eventoId: evento.eventoId,
    nombre: _limpiarTextoParaPDF(evento.nombre),
    empresa: _limpiarTextoParaPDF(evento.empresa),
    empresaId: evento.empresaId,
    ubicacion: _limpiarTextoParaPDF(evento.ubicacion),
    fecha: evento.fecha,
    estado: evento.estado,
    observaciones: _limpiarTextoParaPDF(evento.observaciones),
    serviciosAsignados: evento.serviciosAsignados
        .map((s) => {
              'servicioId': s['servicioId'],
              'profesionalId': s['profesionalId'],
              'servicioNombre': _limpiarTextoParaPDF(s['servicioNombre'] ?? ''),
              'profesionalNombre':
                  _limpiarTextoParaPDF(s['profesionalNombre'] ?? ''),
              'fechaAsignada': s['fechaAsignada'],
              'horaInicio': s['horaInicio'],
              'horaFin': s['horaFin'],
              'ubicacion': _limpiarTextoParaPDF(s['ubicacion'] ?? ''),
            })
        .toList(),
    fechaCreacion: evento.fechaCreacion,
  );

  final snap = await FirebaseFirestore.instance
      .collection('eventos')
      .doc(eventoLimpio.id)
      .collection('registros')
      .get();

  // ✅ LIMPIAR REGISTROS INMEDIATAMENTE AL CARGARLOS
  final registros = snap.docs.map((e) {
    final data = e.data();
    // Limpiar datos del registro antes de crear el modelo
    final dataLimpia = <String, dynamic>{};
    for (var key in data.keys) {
      if (data[key] is String) {
        dataLimpia[key] = _limpiarTextoParaPDF(data[key]);
      } else if (key == 'encuesta' && data[key] is Map) {
        final encuestaLimpia = <String, dynamic>{};
        final encuesta = data[key] as Map<String, dynamic>;
        for (var encKey in encuesta.keys) {
          if (encuesta[encKey] is String) {
            encuestaLimpia[encKey] = _limpiarTextoParaPDF(encuesta[encKey]);
          } else {
            encuestaLimpia[encKey] = encuesta[encKey];
          }
        }
        dataLimpia[key] = encuestaLimpia;
      } else {
        dataLimpia[key] = data[key];
      }
    }
    return ServicioRealizadoModel.fromMap(dataLimpia, e.id);
  }).toList();

  await Future.delayed(const Duration(milliseconds: 50));
  final snapServicios =
      await FirebaseFirestore.instance.collection('services').get();
  final snapProfesionales =
      await FirebaseFirestore.instance.collection('profesionales').get();
  final snapEncuestas =
      await FirebaseFirestore.instance.collection('encuestas').get();

  // ✅ LIMPIAR NOMBRES DE SERVICIOS Y PROFESIONALES INMEDIATAMENTE
  final serviciosNombres = <String, String>{};
  for (var doc in snapServicios.docs) {
    serviciosNombres[doc.id] =
        _limpiarTextoParaPDF(doc.data()['name']?.toString() ?? doc.id);
  }

  final profesionalesNombres = <String, String>{};
  for (var doc in snapProfesionales.docs) {
    profesionalesNombres[doc.id] =
        _limpiarTextoParaPDF(doc.data()['nombre']?.toString() ?? doc.id);
  }

  await Future.delayed(const Duration(milliseconds: 50));
  final Map<String, String> preguntasTexto = {};
  final Set<String> preguntasDisponibles = {};

  for (var doc in snapEncuestas.docs) {
    final data = doc.data();
    if (data.containsKey('preguntas') && data['preguntas'] is List) {
      final preguntas = data['preguntas'] as List<dynamic>;
      for (int index = 0; index < preguntas.length; index++) {
        final preguntaData = preguntas[index];
        if (preguntaData != null && preguntaData is Map) {
          final preguntaMap = preguntaData as Map<String, dynamic>;
          final texto = preguntaMap['texto']?.toString();
          if (texto != null && texto.isNotEmpty) {
            final pregKey = 'preg$index';
            preguntasTexto[pregKey] =
                _limpiarTextoParaPDF(texto); // ✅ Limpiar inmediatamente
            preguntasDisponibles.add(pregKey);
          }
        }
      }
    }
  }

  if (preguntasDisponibles.isEmpty) {
    final snap = await FirebaseFirestore.instance
        .collection('eventos')
        .doc(evento.id)
        .collection('registros')
        .limit(10)
        .get();

    for (var docRegistro in snap.docs) {
      final data = docRegistro.data();
      final encuesta = data['encuesta'];
      if (encuesta != null && encuesta is Map) {
        for (final key in encuesta.keys) {
          if (key.startsWith('preg') && key != 'comentario') {
            preguntasDisponibles.add(key);
            preguntasTexto[key] = key.replaceAll('preg', 'Pregunta ');
          }
        }
      }
    }
  }

  await Future.delayed(const Duration(milliseconds: 50));
  final servicios = <String, int>{};
  final profesionales = <String, int>{};
  final comentarios = <String>[];
  final Map<String, Map<int, int>> distribucionNotas = {};
  final Map<String, List<double>> notasPorPregunta = {};

  for (var key in preguntasDisponibles) {
    distribucionNotas[key] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    notasPorPregunta[key] = <double>[];
  }

  // Procesar registros en lotes pequeños
  for (int i = 0; i < registros.length; i += 25) {
    await Future.delayed(const Duration(milliseconds: 30));

    final lote = registros.skip(i).take(25);
    for (var r in lote) {
      servicios[r.servicioId] = (servicios[r.servicioId] ?? 0) + 1;
      profesionales[r.profesionalId] =
          (profesionales[r.profesionalId] ?? 0) + 1;

      if (r.encuesta != null) {
        for (var key in r.encuesta!.keys) {
          if (key.startsWith('preg') && key != 'comentario') {
            if (!preguntasDisponibles.contains(key)) {
              preguntasDisponibles.add(key);
              preguntasTexto[key] = key.replaceAll('preg', 'Pregunta ');
              distribucionNotas[key] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
              notasPorPregunta[key] = <double>[];
            }

            final val = r.encuesta![key];
            if (val != null) {
              double nota = 0.0;
              if (val is String) {
                nota = _parseEstrellas(val);
              } else if (val is int) {
                nota = val.toDouble();
              } else if (val is double) {
                nota = val;
              }

              if (nota > 0 && nota <= 5) {
                distribucionNotas[key]![nota.toInt()] =
                    (distribucionNotas[key]![nota.toInt()] ?? 0) + 1;
                notasPorPregunta[key]!.add(nota);
              }
            }
          }
        }

        final coment = r.encuesta?['comentario'];
        if (coment != null && (coment as String).trim().isNotEmpty) {
          // ✅ COMENTARIO YA FUE LIMPIADO AL CARGAR LOS REGISTROS
          final comentarioLimpio = coment.trim();
          if (comentarioLimpio.isNotEmpty && comentarioLimpio.length > 3) {
            // Solo comentarios de 3+ caracteres
            comentarios.add(comentarioLimpio);
          }
        }
      }
    }
  }

  await Future.delayed(const Duration(milliseconds: 50));
  final Map<String, String> mapaServicios = {};
  final Map<String, String> mapaProfesionales = {};
  for (var asignado in eventoLimpio.serviciosAsignados) {
    // ✅ Usar evento ya limpio
    final sid = asignado['servicioId'];
    final pid = asignado['profesionalId'];
    final sNombre = asignado['servicioNombre']; // Ya limpio
    final pNombre = asignado['profesionalNombre']; // Ya limpio
    if (sid != null) mapaServicios[sid] = sNombre ?? '';
    if (pid != null) mapaProfesionales[pid] = pNombre ?? '';
  }

  // 🎨 GENERAR PRIMERA PÁGINA CON DISEÑO PROFESIONAL Y COLORES DE MARCA
  await Future.delayed(const Duration(milliseconds: 50));
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32), // ✅ Márgenes más generosos
    build: (_) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // 🎨 HEADER CON MORADO DE MARCA Y LOGO CENTRADO
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: kBrandPurpleLightPdf, // ✅ Morado fondo
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: kBrandPurplePdf),
            ),
            child: pw.Column(
              children: [
                pw.Center(
                    child: pw.Image(pw.MemoryImage(logoBytes), height: 60)),
                pw.SizedBox(height: 16),
                pw.Text(
                  'REPORTE DE EVENTO',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: kBrandPurplePdf,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // 🎨 INFORMACIÓN DEL EVENTO EN TARJETA
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: kBrandPurpleLightPdf, // ✅ Morado pastel suave
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: kBrandPurplePdf),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INFORMACIÓN DEL EVENTO',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: kBrandPurplePdf,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Evento: ${eventoLimpio.nombre}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text('Empresa: ${eventoLimpio.empresa}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text('Ubicación: ${eventoLimpio.ubicacion}',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Fecha: ${eventoLimpio.fecha.day.toString().padLeft(2, '0')}/${eventoLimpio.fecha.month.toString().padLeft(2, '0')}/${eventoLimpio.fecha.year}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // 🎨 ESTADÍSTICAS EN TARJETAS COLORIDAS CON COLORES DE MARCA
          pw.Row(
            children: [
              // Tarjeta Verde - Registros
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: kBrandPurpleLightPdf,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: kAccentGreenPdf),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '${registros.length}',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: kAccentGreenPdf,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Registros escaneados',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Tarjeta Azul - Servicios
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: kBrandPurpleLightPdf,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: kAccentBluePdf),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '${servicios.length}',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: kAccentBluePdf,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Servicios involucrados',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Tarjeta Morada - Profesionales
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: kBrandPurpleLightPdf,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: kBrandPurplePdf),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        '${profesionales.length}',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: kBrandPurplePdf,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Profesionales asignados',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 24),

          // 📊 TABLA DE ENCUESTAS SUPER PROFESIONAL CON MORADO
          pw.Text(
            'RESULTADOS DE ENCUESTA',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: kBrandPurplePdf,
            ),
          ),
          pw.SizedBox(height: 12),

          if (preguntasDisponibles.isNotEmpty)
            pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: kBrandPurplePdf),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(
                      3), // ✅ Columnas balanceadas 3:1.5
                  1: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header morado con texto blanco
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: kBrandPurplePdf, // ✅ Header morado de marca
                      borderRadius: const pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(8),
                        topRight: pw.Radius.circular(8),
                      ),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8, // ✅ Más padding vertical
                          horizontal: 10, // ✅ Más padding horizontal
                        ),
                        child: pw.Text(
                          'Pregunta',
                          style: pw.TextStyle(
                            fontSize: 11, // ✅ Texto más grande
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white, // ✅ Texto blanco
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        child: pw.Text(
                          'Promedio',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                          textAlign:
                              pw.TextAlign.center, // ✅ Calificaciones centradas
                        ),
                      ),
                    ],
                  ),
                  // Filas de datos
                  ...(() {
                    final sortedKeys = preguntasDisponibles.toList()..sort();
                    return sortedKeys.asMap().entries.map((entry) {
                      final index = entry.key;
                      final key = entry.value;
                      final notas = notasPorPregunta[key] ?? [];
                      final preguntaTexto = preguntasTexto[key] ?? key;
                      final isEven = index % 2 == 0;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color:
                              isEven ? kBrandPurpleLightPdf : PdfColors.white,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            child: pw.Text(
                              preguntaTexto,
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                            child: pw.Text(
                              notas.isEmpty
                                  ? 'Sin respuestas'
                                  : () {
                                      final promedio =
                                          notas.reduce((a, b) => a + b) /
                                              notas.length;
                                      return '${promedio.toStringAsFixed(1)} de 5.0 estrellas'; // ✅ Texto mejorado
                                    }(),
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: notas.isEmpty
                                    ? PdfColors.grey
                                    : PdfColors.black,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  })(),
                ],
              ),
            )
          else
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: kBrandPurpleLightPdf,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: kBrandPurplePdf),
              ),
              child: pw.Text(
                'No hay preguntas configuradas en la encuesta',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey,
                ),
              ),
            ),

          pw.SizedBox(height: 24),

          // 💬 COMENTARIOS REDISEÑADOS CON AZUL DE MARCA
          if (comentarios.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'COMENTARIOS RECIBIDOS', // ✅ Título destacado
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: kAccentBluePdf, // ✅ En azul de marca
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: kBrandPurpleLightPdf, // ✅ Fondo morado claro
                    borderRadius: pw.BorderRadius.circular(8),
                    border:
                        pw.Border.all(color: kAccentBluePdf), // ✅ Borde azul
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // ✅ Máximo 6 comentarios para evitar saturación
                      ...comentarios.take(6).map((c) => pw.Padding(
                            padding: const pw.EdgeInsets.only(
                                bottom: 8), // ✅ Mejor espaciado
                            child: pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 4,
                                  height: 4,
                                  margin: const pw.EdgeInsets.only(
                                      top: 6, right: 8),
                                  decoration: pw.BoxDecoration(
                                    color:
                                        kAccentBluePdf, // ✅ Bullets azules de marca
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    c,
                                    style: const pw.TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      // ✅ Contador si hay más comentarios
                      if (comentarios.length > 6)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 8),
                          child: pw.Text(
                            '... y ${comentarios.length - 6} comentarios más',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontStyle: pw.FontStyle.italic,
                              color: kAccentBluePdf,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      );
    },
  ));

  // Segunda página (manteniendo la funcionalidad existente)
  await Future.delayed(const Duration(milliseconds: 50));
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        pw.Header(level: 0, text: 'Registros de servicios realizados'),
        pw.TableHelper.fromTextArray(
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding:
              const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          cellStyle: pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white),
          headerDecoration: pw.BoxDecoration(color: kBrandPurplePdf),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.5),
            1: const pw.FlexColumnWidth(2.0),
            2: const pw.FlexColumnWidth(2.0),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(2.5),
          },
          headers: [
            'Empleado',
            'Servicio',
            'Profesional',
            'Fecha y Hora',
            'Encuesta'
          ],
          data: registros.map((registro) {
            final fechaHora = registro.timestamp
                .toLocal()
                .toString()
                .substring(0, 16)
                .replaceAll('T', ' ');
            final encuestaTexto = registro.encuesta != null
                ? () {
                    final respuestas = <String>[];
                    for (final preg in preguntasDisponibles) {
                      final valor = registro.encuesta![preg];
                      if (valor != null) {
                        final preguntaTexto =
                            preguntasTexto[preg] ?? preg; // ✅ Ya limpio
                        final valorLimpio =
                            valor.toString(); // ✅ Ya limpio al cargar registros
                        respuestas.add('$preguntaTexto: $valorLimpio');
                      }
                    }
                    final comentario = registro.encuesta!['comentario'];
                    if (comentario != null &&
                        comentario.toString().trim().isNotEmpty) {
                      final comentarioLimpio =
                          comentario.toString().trim(); // ✅ Ya limpio
                      if (comentarioLimpio.isNotEmpty) {
                        respuestas.add('comentario: $comentarioLimpio');
                      }
                    }
                    return respuestas.join('\n');
                  }()
                : 'Sin respuestas';

            final servicioNombre =
                mapaServicios[registro.servicioId] ?? '-'; // ✅ Ya limpio
            final profesionalNombre =
                mapaProfesionales[registro.profesionalId] ?? '-'; // ✅ Ya limpio
            final numeroEmpleadoLimpio = registro.numeroEmpleado.isNotEmpty
                ? registro.numeroEmpleado
                : '-'; // ✅ Ya limpio

            return [
              numeroEmpleadoLimpio,
              servicioNombre,
              profesionalNombre,
              fechaHora,
              encuestaTexto
            ];
          }).toList(),
        ),
      ],
    ),
  );

  return await doc.save();
}

// ✅ FUNCIÓN SUPER AGRESIVA PARA LIMPIAR TEXTO (PREVIENE TRABADO)
String _limpiarTextoParaPDF(String texto) {
  if (texto.isEmpty) return texto;

  // ✅ LIMPIEZA SÚPER AGRESIVA - SOLO CARACTERES BÁSICOS
  return texto
      // Primero reemplazar emojis comunes específicamente
      .replaceAll('☺', ':)')
      .replaceAll('☺️', ':)')
      .replaceAll('😊', ':)')
      .replaceAll('😃', ':D')
      .replaceAll('👍', '(ok)')
      .replaceAll('❤️', '(corazon)')
      .replaceAll('❤', '(corazon)')
      .replaceAll('💪', '(fuerte)')
      .replaceAll('🙏', '(gracias)')
      .replaceAll('✨', '(brillo)')
      .replaceAll('🎉', '(celebracion)')
      .replaceAll('💯', '(excelente)')
      .replaceAll('🔥', '(genial)')
      .replaceAll('⭐', '*')
      .replaceAll('★', '*')
      .replaceAll('✓', 'v')
      .replaceAll('✔', 'v')
      .replaceAll('⚡', '(rapido)')
      .replaceAll('🚀', '(rapido)')
      .replaceAll('💼', '(trabajo)')
      .replaceAll('🏆', '(premio)')
      .replaceAll('📈', '(mejora)')
      .replaceAll('📊', '(datos)')
      .replaceAll('📋', '(lista)')
      .replaceAll('📝', '(nota)')
      .replaceAll('📄', '(documento)')
      .replaceAll('📁', '(archivo)')
      .replaceAll('💻', '(computadora)')
      .replaceAll('📱', '(celular)')
      .replaceAll('🔴', '(rojo)')
      .replaceAll('🟢', '(verde)')
      .replaceAll('🔵', '(azul)')
      .replaceAll('⚪', '(blanco)')
      .replaceAll('⚫', '(negro)')
      .replaceAll('🟡', '(amarillo)')
      .replaceAll('🟠', '(naranja)')
      .replaceAll('🟣', '(morado)')
      // Remover TODOS los caracteres que NO sean ASCII básico + acentos
      .replaceAll(RegExp(r'[^\x20-\x7E\u00C0-\u00FF]'),
          '') // Solo ASCII + acentos básicos
      // Limpiar espacios múltiples
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

double _parseEstrellas(String estrella) {
  final trimmed = estrella.trim();

  switch (trimmed) {
    case '⭐':
    case '1':
      return 1.0;
    case '⭐⭐':
    case '2':
      return 2.0;
    case '⭐⭐⭐':
    case '3':
      return 3.0;
    case '⭐⭐⭐⭐':
    case '4':
      return 4.0;
    case '⭐⭐⭐⭐⭐':
    case '5':
      return 5.0;
    default:
      final numero = double.tryParse(trimmed);
      if (numero != null && numero >= 1 && numero <= 5) {
        return numero;
      }
      return 0.0;
  }
}

// ✅ OPCIONES MEJORADAS
Future<void> _mostrarOpcionesMejoradas(
  BuildContext context,
  Uint8List pdfBytes,
  EventoModel evento,
) async {
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.green[400]!, Colors.teal[400]!]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 20),
            const Text('Reporte listo',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text('¿Cómo quieres visualizar tu reporte?',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            _OpcionButton(
              icon: Icons.open_in_new_rounded,
              titulo: 'Abrir en nueva ventana',
              descripcion: 'Abrir PDF en nueva pestaña del navegador',
              color: Colors.blue,
              onTap: () async {
                Navigator.pop(context);
                await _abrirPDFEnNuevaVentana(pdfBytes, evento);
              },
            ),
            const SizedBox(height: 12),
            _OpcionButton(
              icon: Icons.print_rounded,
              titulo: 'Imprimir',
              descripcion: 'Abrir diálogo de impresión del sistema',
              color: Colors.orange,
              onTap: () async {
                Navigator.pop(context);
                await _abrirPDFParaImprimir(pdfBytes);
              },
            ),
            const SizedBox(height: 12),
            _OpcionButton(
              icon: Icons.download_rounded,
              titulo: 'Descargar',
              descripcion: 'Guardar PDF en tu dispositivo',
              color: Colors.green,
              onTap: () async {
                Navigator.pop(context);
                await _descargarPDF(pdfBytes, evento);
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OpcionButton extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _OpcionButton({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(descripcion,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}

// ✅ FUNCIONES DE APERTURA
Future<void> _abrirPDFEnNuevaVentana(
    Uint8List pdfBytes, EventoModel evento) async {
  try {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(
        const Duration(seconds: 5), () => html.Url.revokeObjectUrl(url));
  } catch (e) {
    debugPrint('Error abriendo PDF: $e');
  }
}

Future<void> _descargarPDF(Uint8List pdfBytes, EventoModel evento) async {
  try {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final fileName =
        'reporte_${evento.nombre.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '')}.pdf';
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    debugPrint('Error descargando PDF: $e');
  }
}

Future<void> _abrirPDFParaImprimir(Uint8List pdfBytes) async {
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
}

// ✅ FUNCIÓN ORIGINAL INTACTA
Future<void> exportarEventoComoPDF(EventoModel evento) async {
  final pdfBytes = await _generarPDFOptimizado(evento);
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
}
