// [Archivo CORREGIDO: lib/utils/export_evento_excel.dart]
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:file_saver/file_saver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evento_model.dart';
import '../models/servicio_realizado_model.dart';
import '../theme/theme.dart';

// ✅ COLORES PARA EXCEL (RGB Strings)
const String kBrandPurpleHex = '9920A7';
const String kAccentBlueHex = '4DB1E0';
const String kAccentGreenHex = '8ABF54';
const String kPurpleLightHex = 'EADCF9';
const String kBackgroundGrayHex = 'F5F5F9';

/// 🚀 FUNCIÓN PRINCIPAL CON LOADER PREMIUM
Future<void> exportarResumenEventoPremium(
  BuildContext context,
  EventoModel evento,
) async {
  Uint8List? excelBytes;

  await showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (context) => _ExcelGenerationDialogPremium(
      evento: evento,
      onExcelGenerated: (bytes) {
        excelBytes = bytes;
      },
    ),
  );

  if (excelBytes != null && context.mounted) {
    await _mostrarOpcionesExcel(context, excelBytes!, evento);
  }
}

/// 🎨 DIALOG PREMIUM PARA GENERACIÓN
class _ExcelGenerationDialogPremium extends StatefulWidget {
  final EventoModel evento;
  final Function(Uint8List) onExcelGenerated;

  const _ExcelGenerationDialogPremium({
    required this.evento,
    required this.onExcelGenerated,
  });

  @override
  State<_ExcelGenerationDialogPremium> createState() =>
      _ExcelGenerationDialogPremiumState();
}

class _ExcelGenerationDialogPremiumState
    extends State<_ExcelGenerationDialogPremium> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _chartsController;

  int _currentStep = 0;
  bool _isCompleted = false;
  String _errorMessage = '';

  final List<_ExcelStep> _steps = [
    _ExcelStep(
        'Recopilando datos del evento', Icons.event_note, kAccentBlueHex),
    _ExcelStep(
        'Procesando registros QR', Icons.qr_code_scanner, kAccentGreenHex),
    _ExcelStep('Analizando encuestas', Icons.quiz, kBrandPurpleHex),
    _ExcelStep('Creando hojas de cálculo', Icons.table_chart, kAccentBlueHex),
    _ExcelStep('Aplicando formato premium', Icons.palette, kBrandPurpleHex),
    _ExcelStep(
        'Generando Excel ejecutivo', Icons.insert_chart, kAccentGreenHex),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startGeneration();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _chartsController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _chartsController.dispose();
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
            await Future.delayed(const Duration(milliseconds: 1000));
            break;
          case 1:
            await Future.delayed(const Duration(milliseconds: 800));
            break;
          case 2:
            await Future.delayed(const Duration(milliseconds: 1200));
            break;
          case 3:
            await Future.delayed(const Duration(milliseconds: 1500));
            break;
          case 4:
            await Future.delayed(const Duration(milliseconds: 1000));
            break;
          case 5:
            // ✅ GENERAR EXCEL PREMIUM
            final excelBytes = await _generarExcelPremium(widget.evento);
            widget.onExcelGenerated(excelBytes);
            await Future.delayed(const Duration(milliseconds: 600));
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
        width: 450,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: kBrandPurple.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // ✅ ICONOS DE EXCEL FLOTANDO
            ...List.generate(
                8,
                (index) => AnimatedBuilder(
                      animation: _chartsController,
                      builder: (context, child) {
                        final offset =
                            (_chartsController.value + index * 0.15) % 1.0;
                        final horizontalOffset = 60 + (index * 45.0);
                        return Positioned(
                          left: horizontalOffset,
                          top: 40 + (offset * 280),
                          child: Transform.rotate(
                            angle: offset * 0.3,
                            child: Opacity(
                              opacity: 0.12,
                              child: Icon(
                                [
                                  Icons.table_chart,
                                  Icons.bar_chart,
                                  Icons.pie_chart,
                                  Icons.show_chart
                                ][index % 4],
                                size: 20 + (index * 3.0),
                                color: [
                                  kBrandPurple,
                                  kAccentBlue,
                                  kAccentGreen
                                ][index % 3],
                              ),
                            ),
                          ),
                        );
                      },
                    )),

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
          animation: _pulseController,
          builder: (context, child) {
            final pulseScale = 0.9 + (_pulseController.value * 0.2);
            return Transform.scale(
              scale: pulseScale,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAccentGreen, kAccentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.table_chart_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Generando Excel Premium',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kBrandPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBrandPurple.withValues(alpha: 0.3)),
          ),
          child: Text(
            widget.evento.nombre,
            style: const TextStyle(
              fontSize: 14,
              color: kBrandPurple,
              fontWeight: FontWeight.w600,
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? kAccentGreen
                      : isCurrent
                          ? _getStepColor(step.color)
                          : Colors.grey[300],
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    color: isPending ? Colors.grey[500] : Colors.black87,
                  ),
                ),
              ),
              if (isCurrent)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getStepColor(step.color)),
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
              'Progreso de generación',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Text(
                  '${(_progressController.value * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kBrandPurple,
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kAccentGreen, kBrandPurple],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
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
        color: kAccentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentGreen.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: kAccentGreen,
            size: 28,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Excel generado exitosamente!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kAccentGreen,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Reporte ejecutivo listo para descargar',
                  style: TextStyle(
                    fontSize: 13,
                    color: kAccentGreen,
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
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
            child: Text(
              'Error: ${_errorMessage.length > 50 ? '${_errorMessage.substring(0, 50)}...' : _errorMessage}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(String colorHex) {
    switch (colorHex) {
      case kBrandPurpleHex:
        return kBrandPurple;
      case kAccentBlueHex:
        return kAccentBlue;
      case kAccentGreenHex:
        return kAccentGreen;
      default:
        return kBrandPurple;
    }
  }
}

class _ExcelStep {
  final String label;
  final IconData icon;
  final String color;
  _ExcelStep(this.label, this.icon, this.color);
}

/// 🎯 GENERACIÓN DE EXCEL PREMIUM CON MÚLTIPLES HOJAS
Future<Uint8List> _generarExcelPremium(EventoModel evento) async {
  // ✅ CARGAR TODOS LOS DATOS
  final registrosSnap = await FirebaseFirestore.instance
      .collection('eventos')
      .doc(evento.id)
      .collection('registros')
      .get();

  final registros = registrosSnap.docs
      .map((e) => ServicioRealizadoModel.fromMap(e.data(), e.id))
      .toList();

  final snapServicios =
      await FirebaseFirestore.instance.collection('services').get();
  final snapProfesionales =
      await FirebaseFirestore.instance.collection('profesionales').get();
  final snapEncuestas =
      await FirebaseFirestore.instance.collection('encuestas').get();

  // ✅ MAPAS DE NOMBRES
  final serviciosNombres = <String, String>{};
  for (var doc in snapServicios.docs) {
    serviciosNombres[doc.id] = doc.data()['name']?.toString() ?? doc.id;
  }

  final profesionalesNombres = <String, String>{};
  for (var doc in snapProfesionales.docs) {
    profesionalesNombres[doc.id] = doc.data()['nombre']?.toString() ?? doc.id;
  }

  // ✅ PROCESAR ENCUESTAS
  final Map<String, String> preguntasTexto = {};
  final Set<String> preguntasDisponibles = {};

  for (var doc in snapEncuestas.docs) {
    final data = doc.data();
    if (data.containsKey('preguntas') && data['preguntas'] is List) {
      final preguntas = data['preguntas'] as List<dynamic>;
      for (int index = 0; index < preguntas.length; index++) {
        final pregunta = preguntas[index];
        if (pregunta != null && pregunta is Map) {
          final texto = pregunta['texto']?.toString();
          if (texto != null && texto.isNotEmpty) {
            final pregKey = 'preg$index';
            preguntasTexto[pregKey] = texto;
            preguntasDisponibles.add(pregKey);
          }
        }
      }
    }
  }

  // ✅ ANALIZAR DATOS
  final Map<String, int> serviciosCount = {};
  final Map<String, int> profesionalesCount = {};
  final List<String> comentarios = [];
  final Map<String, List<double>> notasPorPregunta = {};

  for (var key in preguntasDisponibles) {
    notasPorPregunta[key] = <double>[];
  }

  for (var r in registros) {
    serviciosCount[r.servicioId] = (serviciosCount[r.servicioId] ?? 0) + 1;
    profesionalesCount[r.profesionalId] =
        (profesionalesCount[r.profesionalId] ?? 0) + 1;

    if (r.encuesta != null) {
      for (var key in r.encuesta!.keys) {
        if (key.startsWith('preg') && key != 'comentario') {
          if (!preguntasDisponibles.contains(key)) {
            preguntasDisponibles.add(key);
            preguntasTexto[key] = key.replaceAll('preg', 'Pregunta ');
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
              notasPorPregunta[key]!.add(nota);
            }
          }
        }
      }

      final coment = r.encuesta?['comentario'];
      if (coment != null && (coment as String).trim().isNotEmpty) {
        comentarios.add(coment.trim());
      }
    }
  }

  // ✅ CREAR EXCEL CON MÚLTIPLES HOJAS
  final excel = excel_lib.Excel.createExcel();

  // ✅ ELIMINAR TODAS LAS HOJAS POR DEFECTO
  final sheetsToDelete = excel.sheets.keys.toList();
  for (String sheetName in sheetsToDelete) {
    excel.delete(sheetName);
  }

  // ✅ CREAR HOJAS PREMIUM
  await _crearHojaResumenEjecutivo(
      excel,
      evento,
      registros,
      serviciosCount,
      profesionalesCount,
      notasPorPregunta,
      preguntasTexto,
      serviciosNombres,
      profesionalesNombres);
  await _crearHojaRegistrosDetallados(
      excel, registros, serviciosNombres, profesionalesNombres);
  await _crearHojaAnalisisEncuestas(
      excel, notasPorPregunta, preguntasTexto, comentarios);
  await _crearHojaEstadisticas(excel, serviciosCount, profesionalesCount,
      serviciosNombres, profesionalesNombres);

  if (comentarios.isNotEmpty) {
    await _crearHojaComentarios(excel, comentarios);
  }

  final List<int>? fileBytes = excel.save();
  if (fileBytes == null) throw Exception('Error generando archivo Excel');

  return Uint8List.fromList(fileBytes);
}

/// 📊 HOJA 1: RESUMEN EJECUTIVO
Future<void> _crearHojaResumenEjecutivo(
  excel_lib.Excel excel,
  EventoModel evento,
  List<ServicioRealizadoModel> registros,
  Map<String, int> serviciosCount,
  Map<String, int> profesionalesCount,
  Map<String, List<double>> notasPorPregunta,
  Map<String, String> preguntasTexto,
  Map<String, String> serviciosNombres,
  Map<String, String> profesionalesNombres,
) async {
  final sheet = excel['📊 Resumen Ejecutivo'];

  // ✅ TÍTULO PRINCIPAL
  _mergeAndSetCell(
      sheet, 'A1', 'F1', 'REPORTE EJECUTIVO - ${evento.nombre.toUpperCase()}');
  _setCellStyle(sheet, 'A1',
      fontSize: 18, bold: true, textColor: kBrandPurpleHex, centered: true);

  int row = 3;

  // ✅ INFORMACIÓN DEL EVENTO
  _mergeAndSetCell(sheet, 'A$row', 'F$row', 'INFORMACIÓN DEL EVENTO');
  _setCellStyle(sheet, 'A$row',
      fontSize: 12,
      bold: true,
      textColor: kBrandPurpleHex,
      bgColor: kPurpleLightHex);
  row++;

  final infoEvento = [
    ['Nombre del Evento:', evento.nombre],
    ['Empresa:', evento.empresa],
    ['Ubicación:', evento.ubicacion],
    [
      'Fecha:',
      '${evento.fecha.day}/${evento.fecha.month}/${evento.fecha.year}'
    ],
    ['Estado:', evento.estado],
  ];

  for (var info in infoEvento) {
    _setCell(sheet, 'A$row', info[0]);
    _setCellStyle(sheet, 'A$row', bold: true, textColor: kBrandPurpleHex);
    _setCell(sheet, 'B$row', info[1]);
    row++;
  }

  row += 2;

  // ✅ MÉTRICAS CLAVE
  _mergeAndSetCell(sheet, 'A$row', 'F$row', 'MÉTRICAS CLAVE');
  _setCellStyle(sheet, 'A$row',
      fontSize: 12,
      bold: true,
      textColor: kBrandPurpleHex,
      bgColor: kPurpleLightHex);
  row++;

  // ✅ TABLA DE MÉTRICAS
  final metricas = [
    ['Métrica', 'Valor', 'Descripción'],
    ['Total Registros', '${registros.length}', 'Escaneos QR realizados'],
    [
      'Servicios Únicos',
      '${serviciosCount.length}',
      'Tipos de servicio utilizados'
    ],
    [
      'Profesionales',
      '${profesionalesCount.length}',
      'Terapeutas participantes'
    ],
    [
      'Tasa Encuestas',
      '${((registros.where((r) => r.encuesta != null).length / registros.length) * 100).toStringAsFixed(1)}%',
      'Porcentaje de encuestas completadas'
    ],
  ];

  for (int i = 0; i < metricas.length; i++) {
    for (int j = 0; j < metricas[i].length; j++) {
      final cellAddress = _getCellAddress(j, row - 1);
      _setCell(sheet, cellAddress, metricas[i][j]);

      if (i == 0) {
        _setCellStyle(sheet, cellAddress,
            bold: true,
            textColor: 'FFFFFF',
            bgColor: kBrandPurpleHex,
            centered: true);
      } else {
        _setCellStyle(sheet, cellAddress,
            bgColor: i % 2 == 0 ? kBackgroundGrayHex : null);
      }
    }
    row++;
  }

  row += 2;

  // ✅ TOP 5 SERVICIOS MÁS UTILIZADOS
  _mergeAndSetCell(sheet, 'A$row', 'C$row', 'TOP 5 SERVICIOS MÁS UTILIZADOS');
  _setCellStyle(sheet, 'A$row',
      fontSize: 12,
      bold: true,
      textColor: kBrandPurpleHex,
      bgColor: kPurpleLightHex);
  row++;

  final topServicios = serviciosCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  _setCell(sheet, 'A$row', 'Servicio');
  _setCellStyle(sheet, 'A$row',
      bold: true,
      textColor: 'FFFFFF',
      bgColor: kBrandPurpleHex,
      centered: true);
  _setCell(sheet, 'B$row', 'Registros');
  _setCellStyle(sheet, 'B$row',
      bold: true,
      textColor: 'FFFFFF',
      bgColor: kBrandPurpleHex,
      centered: true);
  _setCell(sheet, 'C$row', 'Porcentaje');
  _setCellStyle(sheet, 'C$row',
      bold: true,
      textColor: 'FFFFFF',
      bgColor: kBrandPurpleHex,
      centered: true);
  row++;

  for (int i = 0; i < topServicios.take(5).length; i++) {
    final servicio = topServicios[i];
    final nombreServicio = serviciosNombres[servicio.key] ?? servicio.key;
    final porcentaje =
        ((servicio.value / registros.length) * 100).toStringAsFixed(1);

    _setCell(sheet, 'A$row', nombreServicio);
    _setCell(sheet, 'B$row', servicio.value);
    _setCell(sheet, 'C$row', '$porcentaje%');

    // ✅ COLORES ALTERNADOS
    final bgColor = i % 2 == 0 ? kBackgroundGrayHex : null;
    for (int col = 0; col < 3; col++) {
      final cellAddress = _getCellAddress(col, row - 1);
      _setCellStyle(sheet, cellAddress, bgColor: bgColor);
    }
    row++;
  }
}

/// 📋 HOJA 2: REGISTROS DETALLADOS
Future<void> _crearHojaRegistrosDetallados(
  excel_lib.Excel excel,
  List<ServicioRealizadoModel> registros,
  Map<String, String> serviciosNombres,
  Map<String, String> profesionalesNombres,
) async {
  final sheet = excel['📋 Registros Detallados'];

  // ✅ HEADERS
  final headers = [
    'ID Registro',
    'Empleado',
    'Servicio',
    'Profesional',
    'Fecha Registro',
    'Hora Registro',
    'Completado',
    'Plataforma',
    'Calificación Promedio'
  ];

  int row = 1;

  for (int i = 0; i < headers.length; i++) {
    final cellAddress = _getCellAddress(i, row - 1);
    _setCell(sheet, cellAddress, headers[i]);
    _setCellStyle(sheet, cellAddress,
        bold: true,
        textColor: 'FFFFFF',
        bgColor: kAccentBlueHex,
        centered: true);
  }
  row++;

  // ✅ DATOS DE REGISTROS
  for (int i = 0; i < registros.length; i++) {
    final registro = registros[i];
    final servicioNombre =
        serviciosNombres[registro.servicioId] ?? registro.servicioId;
    final profesionalNombre =
        profesionalesNombres[registro.profesionalId] ?? registro.profesionalId;

    // ✅ CALCULAR PROMEDIO DE ENCUESTA
    double promedioEncuesta = 0.0;
    if (registro.encuesta != null) {
      final notas = <double>[];
      for (var key in registro.encuesta!.keys) {
        if (key.startsWith('preg') && key != 'comentario') {
          final val = registro.encuesta![key];
          if (val is String) {
            notas.add(_parseEstrellas(val));
          } else if (val is int) {
            notas.add(val.toDouble());
          } else if (val is double) {
            notas.add(val);
          }
        }
      }
      if (notas.isNotEmpty) {
        promedioEncuesta = notas.reduce((a, b) => a + b) / notas.length;
      }
    }

    final data = [
      registro.id.substring(0, 8),
      registro.numeroEmpleado,
      servicioNombre,
      profesionalNombre,
      '${registro.timestamp.day}/${registro.timestamp.month}/${registro.timestamp.year}',
      '${registro.timestamp.hour.toString().padLeft(2, '0')}:${registro.timestamp.minute.toString().padLeft(2, '0')}',
      registro.encuesta != null ? 'Sí' : 'No',
      registro.plataforma ?? 'N/A',
      promedioEncuesta > 0 ? promedioEncuesta.toStringAsFixed(1) : 'N/A',
    ];

    for (int j = 0; j < data.length; j++) {
      final cellAddress = _getCellAddress(j, row - 1);
      _setCell(sheet, cellAddress, data[j]);

      // ✅ COLORES ALTERNADOS
      _setCellStyle(sheet, cellAddress,
          bgColor: i % 2 == 0 ? kBackgroundGrayHex : null);
    }
    row++;
  }
}

/// 📊 HOJA 3: ANÁLISIS DE ENCUESTAS
Future<void> _crearHojaAnalisisEncuestas(
  excel_lib.Excel excel,
  Map<String, List<double>> notasPorPregunta,
  Map<String, String> preguntasTexto,
  List<String> comentarios,
) async {
  final sheet = excel['📊 Análisis Encuestas'];

  int row = 1;

  // ✅ TÍTULO
  _mergeAndSetCell(sheet, 'A$row', 'G$row', 'ANÁLISIS DETALLADO DE ENCUESTAS');
  _setCellStyle(sheet, 'A$row',
      fontSize: 14, bold: true, textColor: kBrandPurpleHex);
  row += 2;

  // ✅ TABLA DE RESULTADOS POR PREGUNTA
  final headersEncuesta = [
    'Pregunta',
    'Promedio',
    'Total Respuestas',
    '5 Estrellas',
    '4 Estrellas',
    '3 Estrellas',
    '2-1 Estrellas'
  ];

  for (int i = 0; i < headersEncuesta.length; i++) {
    final cellAddress = _getCellAddress(i, row - 1);
    _setCell(sheet, cellAddress, headersEncuesta[i]);
    _setCellStyle(sheet, cellAddress,
        bold: true,
        textColor: 'FFFFFF',
        bgColor: kAccentGreenHex,
        centered: true);
  }
  row++;

  // ✅ DATOS POR PREGUNTA
  final sortedPreguntas = notasPorPregunta.keys.toList()..sort();

  for (int i = 0; i < sortedPreguntas.length; i++) {
    final key = sortedPreguntas[i];
    final notas = notasPorPregunta[key] ?? [];
    final preguntaTexto = preguntasTexto[key] ?? key;

    if (notas.isEmpty) {
      continue;
    }

    final promedio = notas.reduce((a, b) => a + b) / notas.length;
    final total = notas.length;
    final cinco = notas.where((n) => n >= 4.5).length;
    final cuatro = notas.where((n) => n >= 3.5 && n < 4.5).length;
    final tres = notas.where((n) => n >= 2.5 && n < 3.5).length;
    final dosUno = notas.where((n) => n < 2.5).length;

    final data = [
      preguntaTexto,
      promedio.toStringAsFixed(2),
      total.toString(),
      cinco.toString(),
      cuatro.toString(),
      tres.toString(),
      dosUno.toString(),
    ];

    for (int j = 0; j < data.length; j++) {
      final cellAddress = _getCellAddress(j, row - 1);
      _setCell(sheet, cellAddress, data[j]);

      // ✅ COLOR SEGÚN PROMEDIO
      String? bgColor;
      if (j == 1) {
        // Columna de promedio
        if (promedio >= 4.5) {
          bgColor = kAccentGreenHex;
        } else if (promedio >= 3.5) {
          bgColor = kAccentBlueHex;
        } else if (promedio >= 2.5) {
          bgColor = 'FFB400';
        } else {
          bgColor = 'FF6B6B';
        }
      }

      _setCellStyle(sheet, cellAddress,
          bgColor: bgColor ?? (i % 2 == 0 ? kBackgroundGrayHex : null),
          textColor: bgColor != null ? 'FFFFFF' : null);
    }
    row++;
  }

  row += 3;

  // ✅ RESUMEN DE COMENTARIOS
  if (comentarios.isNotEmpty) {
    _mergeAndSetCell(sheet, 'A$row', 'G$row',
        'COMENTARIOS RECIBIDOS (${comentarios.length} total)');
    _setCellStyle(sheet, 'A$row',
        fontSize: 14, bold: true, textColor: kBrandPurpleHex);
    row += 2;

    // ✅ MOSTRAR PRIMEROS 20 COMENTARIOS EN UNA SOLA COLUMNA
    for (int i = 0; i < comentarios.take(20).length; i++) {
      _setCell(
          sheet, 'A$row', '${i + 1}. ${comentarios[i]}'); // ✅ TODO EN UNA CELDA
      _setCellStyle(sheet, 'A$row',
          bgColor: i % 2 == 0 ? kPurpleLightHex : null);
      row++;
    }

    if (comentarios.length > 20) {
      row++;
      _setCell(sheet, 'A$row',
          '... y ${comentarios.length - 20} comentarios adicionales (ver hoja Comentarios)'); // ✅ UNA SOLA COLUMNA
      _setCellStyle(sheet, 'A$row', textColor: '666666');
    }
  }
}

/// 📈 HOJA 4: ESTADÍSTICAS
Future<void> _crearHojaEstadisticas(
  excel_lib.Excel excel,
  Map<String, int> serviciosCount,
  Map<String, int> profesionalesCount,
  Map<String, String> serviciosNombres,
  Map<String, String> profesionalesNombres,
) async {
  final sheet = excel['📈 Estadísticas'];

  int row = 1;

  // ✅ RANKING DE SERVICIOS
  _mergeAndSetCell(sheet, 'A$row', 'D$row', 'RANKING DE SERVICIOS POR DEMANDA');
  _setCellStyle(sheet, 'A$row',
      fontSize: 14, bold: true, textColor: kBrandPurpleHex);
  row += 2;

  final headersServicios = [
    'Posición',
    'Servicio',
    'Registros',
    'Porcentaje del Total'
  ];
  for (int i = 0; i < headersServicios.length; i++) {
    final cellAddress = _getCellAddress(i, row - 1);
    _setCell(sheet, cellAddress, headersServicios[i]);
    _setCellStyle(sheet, cellAddress,
        bold: true,
        textColor: 'FFFFFF',
        bgColor: kBrandPurpleHex,
        centered: true);
  }
  row++;

  final sortedServicios = serviciosCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final totalRegistros = serviciosCount.values.fold(0, (a, b) => a + b);

  for (int i = 0; i < sortedServicios.length; i++) {
    final servicio = sortedServicios[i];
    final nombreServicio = serviciosNombres[servicio.key] ?? servicio.key;
    final porcentaje =
        ((servicio.value / totalRegistros) * 100).toStringAsFixed(1);

    // ✅ MEDALLA PARA TOP 3
    String posicion = '${i + 1}';
    if (i == 0)
      posicion = '🥇 1';
    else if (i == 1)
      posicion = '🥈 2';
    else if (i == 2) posicion = '🥉 3';

    final data = [
      posicion,
      nombreServicio,
      servicio.value.toString(),
      '$porcentaje%'
    ];

    for (int j = 0; j < data.length; j++) {
      final cellAddress = _getCellAddress(j, row - 1);
      _setCell(sheet, cellAddress, data[j]);

      // ✅ DESTACAR TOP 3
      String? bgColor;
      if (i < 3) {
        bgColor = i == 0
            ? 'FFD700'
            : // Oro
            i == 1
                ? 'C0C0C0'
                : // Plata
                'CD7F32'; // Bronce
      }

      _setCellStyle(sheet, cellAddress,
          bgColor: bgColor ?? (i % 2 == 0 ? kBackgroundGrayHex : null),
          bold: i < 3);
    }
    row++;
  }

  row += 3;

  // ✅ RANKING DE PROFESIONALES
  _mergeAndSetCell(
      sheet, 'A$row', 'D$row', 'RANKING DE PROFESIONALES POR ACTIVIDAD');
  _setCellStyle(sheet, 'A$row',
      fontSize: 14, bold: true, textColor: kBrandPurpleHex);
  row += 2;

  final headersProfesionales = [
    'Posición',
    'Profesional',
    'Atenciones',
    'Porcentaje del Total'
  ];
  for (int i = 0; i < headersProfesionales.length; i++) {
    final cellAddress = _getCellAddress(i, row - 1);
    _setCell(sheet, cellAddress, headersProfesionales[i]);
    _setCellStyle(sheet, cellAddress,
        bold: true,
        textColor: 'FFFFFF',
        bgColor: kBrandPurpleHex,
        centered: true);
  }
  row++;

  final sortedProfesionales = profesionalesCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (int i = 0; i < sortedProfesionales.length; i++) {
    final profesional = sortedProfesionales[i];
    final nombreProfesional =
        profesionalesNombres[profesional.key] ?? profesional.key;
    final porcentaje =
        ((profesional.value / totalRegistros) * 100).toStringAsFixed(1);

    String posicion = '${i + 1}';
    if (i == 0)
      posicion = '🥇 1';
    else if (i == 1)
      posicion = '🥈 2';
    else if (i == 2) posicion = '🥉 3';

    final data = [
      posicion,
      nombreProfesional,
      profesional.value.toString(),
      '$porcentaje%'
    ];

    for (int j = 0; j < data.length; j++) {
      final cellAddress = _getCellAddress(j, row - 1);
      _setCell(sheet, cellAddress, data[j]);

      String? bgColor;
      if (i < 3) {
        bgColor = i == 0
            ? 'FFD700'
            : i == 1
                ? 'C0C0C0'
                : 'CD7F32';
      }

      _setCellStyle(sheet, cellAddress,
          bgColor: bgColor ?? (i % 2 == 0 ? kBackgroundGrayHex : null),
          bold: i < 3);
    }
    row++;
  }
}

/// 💬 HOJA 5: COMENTARIOS COMPLETOS
Future<void> _crearHojaComentarios(
  excel_lib.Excel excel,
  List<String> comentarios,
) async {
  final sheet = excel['💬 Comentarios'];

  int row = 1;

  // ✅ TÍTULO
  _mergeAndSetCell(sheet, 'A$row', 'B$row',
      'TODOS LOS COMENTARIOS RECIBIDOS (${comentarios.length} total)'); // ✅ SOLO 2 COLUMNAS
  _setCellStyle(sheet, 'A$row',
      fontSize: 16, bold: true, textColor: kBrandPurpleHex, centered: true);
  row += 2;

  // ✅ HEADERS SIN LONGITUD
  final headers = ['#', 'Comentario']; // ✅ ELIMINÉ 'Longitud'
  for (int i = 0; i < headers.length; i++) {
    final cellAddress = _getCellAddress(i, row - 1);
    _setCell(sheet, cellAddress, headers[i]);
    _setCellStyle(sheet, cellAddress,
        bold: true,
        textColor: 'FFFFFF',
        bgColor: kAccentBlueHex,
        centered: true);
  }
  row++;

  // ✅ TODOS LOS COMENTARIOS SIN COLUMNA DE LONGITUD
  for (int i = 0; i < comentarios.length; i++) {
    final comentario = comentarios[i];

    _setCell(sheet, 'A$row', i + 1);
    _setCell(sheet, 'B$row', comentario);
    // ✅ ELIMINÉ: _setCell(sheet, 'C$row', comentario.length);

    // ✅ COLORES ALTERNADOS SOLO PARA 2 COLUMNAS
    for (int j = 0; j < 2; j++) {
      // ✅ CAMBIÉ DE 3 A 2
      final cellAddress = _getCellAddress(j, row - 1);
      _setCellStyle(sheet, cellAddress,
          bgColor: i % 2 == 0 ? kPurpleLightHex : null);
    }
    row++;
  }
}

/// 🎯 FUNCIÓN HELPER PARA PARSING DE ESTRELLAS
double _parseEstrellas(String estrella) {
  switch (estrella.trim()) {
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
      final numero = double.tryParse(estrella);
      if (numero != null && numero >= 1 && numero <= 5) {
        return numero;
      }
      return 0.0;
  }
}

/// 📤 OPCIONES DE DESCARGA PREMIUM
Future<void> _mostrarOpcionesExcel(
  BuildContext context,
  Uint8List excelBytes,
  EventoModel evento,
) async {
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kAccentGreen, kAccentBlue],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.table_chart_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '¡Excel Ejecutivo Generado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Reporte completo con ${excelBytes.length > 1024 ? '${(excelBytes.length / 1024).toStringAsFixed(1)} KB' : '${excelBytes.length} bytes'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // ✅ BOTÓN DESCARGAR PREMIUM
            Container(
              width: double.infinity,
              height: 56,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kAccentGreen, kAccentBlue],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    Navigator.pop(context);
                    await _descargarExcel(excelBytes, evento);
                  },
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Descargar Excel Ejecutivo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 💾 FUNCIÓN DE DESCARGA
Future<void> _descargarExcel(Uint8List excelBytes, EventoModel evento) async {
  try {
    final fileName =
        'KYM_Reporte_Ejecutivo_${evento.nombre.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    // ✅ DESCARGA PARA WEB
    final blob = html.Blob([excelBytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    debugPrint('✅ Excel descargado: $fileName');
  } catch (e) {
    debugPrint('❌ Error descargando Excel: $e');

    // ✅ FALLBACK CON FILE_SAVER
    try {
      await FileSaver.instance.saveFile(
        name: 'KYM_Reporte_Ejecutivo_${evento.nombre.replaceAll(' ', '_')}',
        bytes: excelBytes,
        ext: 'xlsx',
      );
    } catch (fallbackError) {
      debugPrint('❌ Error en fallback: $fallbackError');
    }
  }
}

/// 🚀 FUNCIÓN WRAPPER PARA RETROCOMPATIBILIDAD
Future<void> exportarResumenEvento(EventoModel evento) async {
  // ✅ GENERAR EXCEL BÁSICO PARA COMPATIBILIDAD
  final excel = excel_lib.Excel.createExcel();
  final sheet = excel['Resumen'];

  // ✅ TU LÓGICA ORIGINAL SIMPLIFICADA
  final registrosSnap = await FirebaseFirestore.instance
      .collection('eventos')
      .doc(evento.id)
      .collection('registros')
      .get();

  final registros = registrosSnap.docs
      .map((e) => ServicioRealizadoModel.fromMap(e.data(), e.id))
      .toList();

  // Headers básicos
  sheet.appendRow(['Evento:', evento.nombre]);
  sheet.appendRow(['Empresa:', evento.empresa]);
  sheet.appendRow(['Total registros:', registros.length.toString()]);

  final List<int>? fileBytes = excel.save();
  if (fileBytes == null) return;

  final bytes = Uint8List.fromList(fileBytes);
  await FileSaver.instance.saveFile(
    name: 'resumen_evento_${evento.id}',
    bytes: bytes,
    ext: 'xlsx',
  );
}

// ✅ FUNCIONES HELPER PARA EXCEL - TOTALMENTE CORREGIDAS
String _getCellAddress(int col, int row) {
  String colName = '';
  int temp = col;
  while (temp >= 0) {
    colName = String.fromCharCode(65 + (temp % 26)) + colName;
    temp = (temp ~/ 26) - 1;
    if (temp < 0) break;
  }
  return '$colName${row + 1}';
}

void _setCell(excel_lib.Sheet sheet, String address, dynamic value) {
  final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));

  // ✅ USAR LA API CORRECTA - SIN TextCellValue, IntCellValue, etc.
  if (value is String) {
    cell.value = value;
  } else if (value is int) {
    cell.value = value;
  } else if (value is double) {
    cell.value = value;
  } else {
    cell.value = value.toString();
  }
}

void _mergeAndSetCell(excel_lib.Sheet sheet, String startAddress,
    String endAddress, String value) {
  sheet.merge(excel_lib.CellIndex.indexByString(startAddress),
      excel_lib.CellIndex.indexByString(endAddress));
  _setCell(sheet, startAddress, value);
}

void _setCellStyle(
  excel_lib.Sheet sheet,
  String address, {
  int? fontSize,
  bool? bold,
  String? textColor,
  String? bgColor,
  bool? centered,
}) {
  final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));

  // ✅ CREAR ESTILO SOLO CON PROPIEDADES VÁLIDAS
  final style = excel_lib.CellStyle(
    fontSize: fontSize ?? 11,
    bold: bold ?? false,
    fontColorHex: textColor != null ? 'FF$textColor' : 'FF000000',
  );

  // ✅ APLICAR backgroundColorHex SOLO SI NO ES NULL
  if (bgColor != null) {
    final styledCell = excel_lib.CellStyle(
      fontSize: fontSize ?? 11,
      bold: bold ?? false,
      fontColorHex: textColor != null ? 'FF$textColor' : 'FF000000',
      backgroundColorHex: 'FF$bgColor',
    );
    cell.cellStyle = styledCell;
  } else {
    cell.cellStyle = style;
  }
}
