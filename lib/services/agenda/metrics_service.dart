// [metrics_service.dart]
// 📁 Ubicación: /lib/services/agenda/metrics_service.dart
// 📊 SERVICIO MÉTRICAS EN TIEMPO REAL - DASHBOARD ANALYTICS

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/services/agenda/booking_service.dart';

class MetricsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final BookingService _bookingService = BookingService();

  // ✅ CALCULAR MÉTRICAS PRINCIPALES
  Future<AgendaMetrics> calculateMetrics([DateTime? fecha]) async {
    final targetDate = fecha ?? DateTime.now();

    try {
      final futures = await Future.wait([
        _getCitasHoy(targetDate),
        _getCitasManana(targetDate),
        _getProfesionalesActivos(),
        _getCabinasDisponibles(),
        _getOcupacionPromedio(targetDate),
        _getIngresosDia(targetDate),
        _getTiempoPromedioServicio(targetDate),
      ]);

      return AgendaMetrics(
        citasHoy: futures[0] as int,
        citasManana: futures[1] as int,
        profesionalesActivos: futures[2] as int,
        cabinasDisponibles: futures[3] as int,
        ocupacionPromedio: futures[4] as double,
        ingresosDia: futures[5] as double,
        tiempoPromedioServicio: futures[6] as double,
        fechaCalculada: targetDate,
      );
    } catch (e) {
      debugPrint('❌ Error calculateMetrics: $e');
      throw MetricsException('Error al calcular métricas: $e');
    }
  }

  // ✅ MÉTRICAS EN TIEMPO REAL (STREAM)
  Stream<AgendaMetrics> getMetricsStream([DateTime? fecha]) async* {
    final targetDate = fecha ?? DateTime.now();

    yield* Stream.periodic(const Duration(minutes: 5))
        .asyncMap((_) => calculateMetrics(targetDate))
        .handleError((error) {
      debugPrint('❌ Error en metrics stream: $error');
      return AgendaMetrics.empty();
    });
  }

  // ✅ MÉTRICAS HISTÓRICAS (ÚLTIMOS 30 DÍAS)
  Future<List<DailyMetrics>> getMetricasHistoricas({int dias = 30}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: dias));
      final metrics = <DailyMetrics>[];

      // Obtener citas del rango
      final citasRango =
          await _bookingService.getCitasPorRango(startDate, endDate);

      // Calcular métricas por día
      for (int i = 0; i < dias; i++) {
        final fecha = startDate.add(Duration(days: i));
        final fechaKey = DateTime(fecha.year, fecha.month, fecha.day);
        final citasDia = citasRango[fechaKey] ?? [];

        final dailyMetric = DailyMetrics(
          fecha: fechaKey,
          totalCitas: citasDia.length,
          citasConfirmadas: citasDia
              .where((c) => c.estado?.toLowerCase() == 'confirmada')
              .length,
          citasCanceladas: citasDia
              .where((c) => c.estado?.toLowerCase() == 'cancelada')
              .length,
          ingresosEstimados: _calcularIngresosCitas(citasDia),
          ocupacionPorcentaje: await _calcularOcupacionDia(fecha),
        );

        metrics.add(dailyMetric);
      }

      return metrics;
    } catch (e) {
      debugPrint('❌ Error getMetricasHistoricas: $e');
      throw MetricsException('Error al obtener métricas históricas: $e');
    }
  }

  // ✅ MÉTRICAS POR PROFESIONAL
  Future<List<ProfessionalMetrics>> getMetricasPorProfesional(
      [DateTime? fecha]) async {
    final targetDate = fecha ?? DateTime.now();

    try {
      final profesionales = await _getProfesionalesList();
      final metrics = <ProfessionalMetrics>[];

      for (final profesional in profesionales) {
        final citas = await _bookingService.getCitasPorProfesionalYFecha(
          profesional['id'],
          targetDate,
        );

        final citasConfirmadas = citas
            .where((c) =>
                c.estado?.toLowerCase() == 'confirmada' ||
                c.estado?.toLowerCase() == 'completada')
            .length;

        final ocupacion =
            await _calcularOcupacionProfesional(profesional['id'], targetDate);

        metrics.add(ProfessionalMetrics(
          profesionalId: profesional['id'],
          nombre: profesional['nombre'] ?? '',
          totalCitas: citas.length,
          citasConfirmadas: citasConfirmadas,
          ocupacionPorcentaje: ocupacion,
          ingresosGenerados: _calcularIngresosCitas(citas),
          rating: await _getCalificacionProfesional(profesional['id']),
        ));
      }

      return metrics..sort((a, b) => b.totalCitas.compareTo(a.totalCitas));
    } catch (e) {
      debugPrint('❌ Error getMetricasPorProfesional: $e');
      throw MetricsException('Error al obtener métricas por profesional: $e');
    }
  }

  // ✅ MÉTRICAS POR SERVICIO
  Future<List<ServiceMetrics>> getMetricasPorServicio([DateTime? fecha]) async {
    final targetDate = fecha ?? DateTime.now();

    try {
      final citas = await _bookingService.getCitasPorFecha(targetDate);
      final serviciosMap = <String, List<dynamic>>{};

      // Agrupar citas por servicio
      for (final cita in citas) {
        if (cita.servicioId != null) {
          serviciosMap.putIfAbsent(cita.servicioId!, () => []).add(cita);
        }
      }

      final metrics = <ServiceMetrics>[];

      for (final entry in serviciosMap.entries) {
        final servicioId = entry.key;
        final citasServicio = entry.value;
        final servicioData = await _getServiceData(servicioId);

        metrics.add(ServiceMetrics(
          servicioId: servicioId,
          nombre: servicioData?['name'] ?? 'Sin nombre',
          categoria: servicioData?['category'] ?? 'Sin categoría',
          totalReservaciones: citasServicio.length,
          ingresosGenerados: (servicioData?['price']?.toDouble() ?? 0.0) *
              citasServicio.length,
          duracionPromedio: servicioData?['duration']?.toDouble() ?? 0.0,
          demanda: _calcularDemandaServicio(citasServicio.length),
        ));
      }

      return metrics
        ..sort((a, b) => b.totalReservaciones.compareTo(a.totalReservaciones));
    } catch (e) {
      debugPrint('❌ Error getMetricasPorServicio: $e');
      throw MetricsException('Error al obtener métricas por servicio: $e');
    }
  }

  // ✅ COMPARACIÓN PERÍODO ANTERIOR
  Future<MetricsComparison> compararConPeriodoAnterior(DateTime fecha) async {
    try {
      final metricsActual = await calculateMetrics(fecha);
      final fechaAnterior =
          fecha.subtract(const Duration(days: 7)); // Semana anterior
      final metricsAnterior = await calculateMetrics(fechaAnterior);

      return MetricsComparison(
        actual: metricsActual,
        anterior: metricsAnterior,
        cambioPercentualCitas: _calcularCambioPercentual(
            metricsActual.citasHoy, metricsAnterior.citasHoy),
        cambioPercentualIngresos: _calcularCambioPercentual(
            metricsActual.ingresosDia, metricsAnterior.ingresosDia),
        cambioPercentualOcupacion: _calcularCambioPercentual(
            metricsActual.ocupacionPromedio, metricsAnterior.ocupacionPromedio),
      );
    } catch (e) {
      debugPrint('❌ Error compararConPeriodoAnterior: $e');
      throw MetricsException('Error al comparar períodos: $e');
    }
  }

  // ✅ MÉTRICAS DE RENDIMIENTO
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final citasDelMes = await _bookingService.getCitasPorRango(
          startOfMonth, now.add(const Duration(days: 1)));

      final totalCitasMes = citasDelMes.values.expand((list) => list).length;
      final citasCanceladas = citasDelMes.values
          .expand((list) => list)
          .where((c) => c.estado?.toLowerCase() == 'cancelada')
          .length;

      final tasaCancelacion =
          totalCitasMes > 0 ? (citasCanceladas / totalCitasMes) * 100 : 0.0;

      return PerformanceMetrics(
        totalCitasMes: totalCitasMes,
        citasCanceladas: citasCanceladas,
        tasaCancelacion: tasaCancelacion,
        ingresosMes: await _calcularIngresosMes(citasDelMes),
        crecimientoMensual: await _calcularCrecimientoMensual(),
      );
    } catch (e) {
      debugPrint('❌ Error getPerformanceMetrics: $e');
      throw MetricsException('Error al obtener métricas de rendimiento: $e');
    }
  }

  // ============================================================================
  // MÉTODOS PRIVADOS - CÁLCULOS ESPECÍFICOS
  // ============================================================================

  Future<int> _getCitasHoy(DateTime fecha) async {
    final citas = await _bookingService.getCitasPorFecha(fecha);
    return citas.length;
  }

  Future<int> _getCitasManana(DateTime fecha) async {
    final manana = fecha.add(const Duration(days: 1));
    final citas = await _bookingService.getCitasPorFecha(manana);
    return citas.length;
  }

  Future<int> _getProfesionalesActivos() async {
    try {
      final query = await _db
          .collection('profesionales')
          .where('estado', isEqualTo: true)
          .get();

      return query.docs.length;
    } catch (e) {
      debugPrint('⚠️ Error _getProfesionalesActivos: $e');
      return 0;
    }
  }

  Future<int> _getCabinasDisponibles() async {
    try {
      // Mock data por ahora - puedes conectar con colección real de cabinas
      final query = await _db
          .collection('cabinas')
          .where('estado', isEqualTo: 'disponible')
          .get();

      return query.docs.isNotEmpty ? query.docs.length : 3; // Fallback a 3
    } catch (e) {
      debugPrint('⚠️ Error _getCabinasDisponibles: $e');
      return 3; // Valor por defecto
    }
  }

  Future<double> _getOcupacionPromedio(DateTime fecha) async {
    try {
      final profesionalesActivos = await _getProfesionalesActivos();
      if (profesionalesActivos == 0) return 0.0;

      final citasHoy = await _getCitasHoy(fecha);

      // Cálculo: asumiendo 10 slots por profesional por día (8 horas / 30 min)
      final totalSlots =
          profesionalesActivos * 16; // 8 horas * 2 slots por hora
      final ocupacion = (citasHoy / totalSlots) * 100;

      return ocupacion.clamp(0.0, 100.0);
    } catch (e) {
      debugPrint('⚠️ Error _getOcupacionPromedio: $e');
      return 0.0;
    }
  }

  Future<double> _getIngresosDia(DateTime fecha) async {
    try {
      final citas = await _bookingService.getCitasPorFecha(fecha);
      double ingresos = 0.0;

      for (final cita in citas) {
        if (cita.servicioId != null) {
          final serviceData = await _getServiceData(cita.servicioId!);
          final precio = serviceData?['price']?.toDouble() ?? 0.0;

          // Solo contar citas confirmadas o completadas
          if (cita.estado?.toLowerCase() == 'confirmada' ||
              cita.estado?.toLowerCase() == 'completada') {
            ingresos += precio;
          }
        }
      }

      return ingresos;
    } catch (e) {
      debugPrint('⚠️ Error _getIngresosDia: $e');
      return 0.0;
    }
  }

  Future<double> _getTiempoPromedioServicio(DateTime fecha) async {
    try {
      final citas = await _bookingService.getCitasPorFecha(fecha);
      if (citas.isEmpty) return 0.0;

      double tiempoTotal = 0.0;
      int serviciosConTiempo = 0;

      for (final cita in citas) {
        if (cita.duracion != null && cita.duracion! > 0) {
          tiempoTotal += cita.duracion!.toDouble();
          serviciosConTiempo++;
        }
      }

      return serviciosConTiempo > 0 ? tiempoTotal / serviciosConTiempo : 60.0;
    } catch (e) {
      debugPrint('⚠️ Error _getTiempoPromedioServicio: $e');
      return 60.0; // Valor por defecto
    }
  }

  Future<double> _calcularOcupacionDia(DateTime fecha) async {
    try {
      final profesionalesActivos = await _getProfesionalesActivos();
      if (profesionalesActivos == 0) return 0.0;

      final citas = await _bookingService.getCitasPorFecha(fecha);
      final citasConfirmadas = citas
          .where((c) =>
              c.estado?.toLowerCase() == 'confirmada' ||
              c.estado?.toLowerCase() == 'completada')
          .length;

      final totalSlots = profesionalesActivos * 16;
      return (citasConfirmadas / totalSlots) * 100;
    } catch (e) {
      debugPrint('⚠️ Error _calcularOcupacionDia: $e');
      return 0.0;
    }
  }

  Future<double> _calcularOcupacionProfesional(
      String profesionalId, DateTime fecha) async {
    try {
      final citas = await _bookingService.getCitasPorProfesionalYFecha(
          profesionalId, fecha);
      final citasConfirmadas = citas
          .where((c) =>
              c.estado?.toLowerCase() == 'confirmada' ||
              c.estado?.toLowerCase() == 'completada')
          .length;

      // 16 slots por día por profesional
      final ocupacion = (citasConfirmadas / 16) * 100;
      return ocupacion.clamp(0.0, 100.0);
    } catch (e) {
      debugPrint('⚠️ Error _calcularOcupacionProfesional: $e');
      return 0.0;
    }
  }

  double _calcularIngresosCitas(List<dynamic> citas) {
    // Este método necesita ser implementado según la lógica de precios
    // Por ahora retornamos un estimado
    return citas.length * 800.0; // Promedio estimado por cita
  }

  String _calcularDemandaServicio(int totalReservaciones) {
    if (totalReservaciones >= 10) return 'Alta';
    if (totalReservaciones >= 5) return 'Media';
    if (totalReservaciones >= 1) return 'Baja';
    return 'Sin demanda';
  }

  double _calcularCambioPercentual(num actual, num anterior) {
    if (anterior == 0) return actual > 0 ? 100.0 : 0.0;
    return ((actual - anterior) / anterior) * 100;
  }

  Future<double> _calcularIngresosMes(
      Map<DateTime, List<dynamic>> citasDelMes) async {
    double ingresoTotal = 0.0;

    for (final entry in citasDelMes.entries) {
      for (final cita in entry.value) {
        if (cita.servicioId != null &&
            (cita.estado?.toLowerCase() == 'confirmada' ||
                cita.estado?.toLowerCase() == 'completada')) {
          final serviceData = await _getServiceData(cita.servicioId!);
          ingresoTotal += serviceData?['price']?.toDouble() ?? 0.0;
        }
      }
    }

    return ingresoTotal;
  }

  Future<double> _calcularCrecimientoMensual() async {
    try {
      final now = DateTime.now();
      final mesActual = DateTime(now.year, now.month, 1);
      final mesAnterior = DateTime(now.year, now.month - 1, 1);

      final citasMesActual = await _bookingService.getCitasPorRango(
          mesActual, now.add(const Duration(days: 1)));

      final citasMesAnterior =
          await _bookingService.getCitasPorRango(mesAnterior, mesActual);

      final totalActual = citasMesActual.values.expand((list) => list).length;
      final totalAnterior =
          citasMesAnterior.values.expand((list) => list).length;

      return _calcularCambioPercentual(totalActual, totalAnterior);
    } catch (e) {
      debugPrint('⚠️ Error _calcularCrecimientoMensual: $e');
      return 0.0;
    }
  }

  // ============================================================================
  // MÉTODOS HELPER PARA DATOS
  // ============================================================================

  Future<List<Map<String, dynamic>>> _getProfesionalesList() async {
    try {
      final query = await _db
          .collection('profesionales')
          .where('estado', isEqualTo: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim(),
          'especialidades': data['especialidades'] ?? [],
          'estado': data['estado'] ?? false,
        };
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Error _getProfesionalesList: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getServiceData(String servicioId) async {
    try {
      final doc = await _db.collection('services').doc(servicioId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('⚠️ Error _getServiceData: $e');
      return null;
    }
  }

  Future<double> _getCalificacionProfesional(String profesionalId) async {
    try {
      // Implementar según tu sistema de calificaciones
      // Por ahora retornamos un valor aleatorio entre 4.0 y 5.0
      return 4.5 + (DateTime.now().microsecond % 5) / 10;
    } catch (e) {
      debugPrint('⚠️ Error _getCalificacionProfesional: $e');
      return 4.5;
    }
  }
}

// ============================================================================
// MODELOS DE DATOS
// ============================================================================

class AgendaMetrics {
  final int citasHoy;
  final int citasManana;
  final int profesionalesActivos;
  final int cabinasDisponibles;
  final double ocupacionPromedio;
  final double ingresosDia;
  final double tiempoPromedioServicio;
  final DateTime fechaCalculada;

  AgendaMetrics({
    required this.citasHoy,
    required this.citasManana,
    required this.profesionalesActivos,
    required this.cabinasDisponibles,
    required this.ocupacionPromedio,
    required this.ingresosDia,
    required this.tiempoPromedioServicio,
    required this.fechaCalculada,
  });

  factory AgendaMetrics.empty() {
    return AgendaMetrics(
      citasHoy: 0,
      citasManana: 0,
      profesionalesActivos: 0,
      cabinasDisponibles: 0,
      ocupacionPromedio: 0.0,
      ingresosDia: 0.0,
      tiempoPromedioServicio: 0.0,
      fechaCalculada: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'citasHoy': citasHoy,
      'citasManana': citasManana,
      'profesionalesActivos': profesionalesActivos,
      'cabinasDisponibles': cabinasDisponibles,
      'ocupacionPromedio': ocupacionPromedio,
      'ingresosDia': ingresosDia,
      'tiempoPromedioServicio': tiempoPromedioServicio,
      'fechaCalculada': fechaCalculada.toIso8601String(),
    };
  }

  // ✅ GETTERS ÚTILES
  String get estadoOcupacion {
    if (ocupacionPromedio >= 90) return 'Muy Alta';
    if (ocupacionPromedio >= 70) return 'Alta';
    if (ocupacionPromedio >= 50) return 'Media';
    if (ocupacionPromedio >= 30) return 'Baja';
    return 'Muy Baja';
  }

  Color get colorOcupacion {
    if (ocupacionPromedio >= 90) return const Color(0xFFD32F2F); // Rojo
    if (ocupacionPromedio >= 70) return const Color(0xFFFF9800); // Naranja
    if (ocupacionPromedio >= 50) return const Color(0xFF4CAF50); // Verde
    if (ocupacionPromedio >= 30) return const Color(0xFF2196F3); // Azul
    return const Color(0xFF9E9E9E); // Gris
  }

  bool get esBuenDia {
    return citasHoy >= 5 && ocupacionPromedio >= 60 && ingresosDia >= 3000;
  }

  String get ingresosDiaFormateado =>
      '\$${NumberFormat('#,###.00').format(ingresosDia)}';

  String get tiempoPromedioFormateado {
    final horas = tiempoPromedioServicio ~/ 60;
    final minutos = tiempoPromedioServicio % 60;

    if (horas > 0) {
      return '${horas}h ${minutos.toInt()}m';
    } else {
      return '${minutos.toInt()}m';
    }
  }
}

class DailyMetrics {
  final DateTime fecha;
  final int totalCitas;
  final int citasConfirmadas;
  final int citasCanceladas;
  final double ingresosEstimados;
  final double ocupacionPorcentaje;

  DailyMetrics({
    required this.fecha,
    required this.totalCitas,
    required this.citasConfirmadas,
    required this.citasCanceladas,
    required this.ingresosEstimados,
    required this.ocupacionPorcentaje,
  });

  String get fechaFormateada => DateFormat('dd/MM').format(fecha);

  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha.toIso8601String(),
      'totalCitas': totalCitas,
      'citasConfirmadas': citasConfirmadas,
      'citasCanceladas': citasCanceladas,
      'ingresosEstimados': ingresosEstimados,
      'ocupacionPorcentaje': ocupacionPorcentaje,
    };
  }
}

class ProfessionalMetrics {
  final String profesionalId;
  final String nombre;
  final int totalCitas;
  final int citasConfirmadas;
  final double ocupacionPorcentaje;
  final double ingresosGenerados;
  final double rating;

  ProfessionalMetrics({
    required this.profesionalId,
    required this.nombre,
    required this.totalCitas,
    required this.citasConfirmadas,
    required this.ocupacionPorcentaje,
    required this.ingresosGenerados,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'profesionalId': profesionalId,
      'nombre': nombre,
      'totalCitas': totalCitas,
      'citasConfirmadas': citasConfirmadas,
      'ocupacionPorcentaje': ocupacionPorcentaje,
      'ingresosGenerados': ingresosGenerados,
      'rating': rating,
    };
  }
}

class ServiceMetrics {
  final String servicioId;
  final String nombre;
  final String categoria;
  final int totalReservaciones;
  final double ingresosGenerados;
  final double duracionPromedio;
  final String demanda;

  ServiceMetrics({
    required this.servicioId,
    required this.nombre,
    required this.categoria,
    required this.totalReservaciones,
    required this.ingresosGenerados,
    required this.duracionPromedio,
    required this.demanda,
  });

  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'nombre': nombre,
      'categoria': categoria,
      'totalReservaciones': totalReservaciones,
      'ingresosGenerados': ingresosGenerados,
      'duracionPromedio': duracionPromedio,
      'demanda': demanda,
    };
  }
}

class MetricsComparison {
  final AgendaMetrics actual;
  final AgendaMetrics anterior;
  final double cambioPercentualCitas;
  final double cambioPercentualIngresos;
  final double cambioPercentualOcupacion;

  MetricsComparison({
    required this.actual,
    required this.anterior,
    required this.cambioPercentualCitas,
    required this.cambioPercentualIngresos,
    required this.cambioPercentualOcupacion,
  });

  bool get mejoroEnCitas => cambioPercentualCitas > 0;
  bool get mejoroEnIngresos => cambioPercentualIngresos > 0;
  bool get mejoroEnOcupacion => cambioPercentualOcupacion > 0;
}

class PerformanceMetrics {
  final int totalCitasMes;
  final int citasCanceladas;
  final double tasaCancelacion;
  final double ingresosMes;
  final double crecimientoMensual;

  PerformanceMetrics({
    required this.totalCitasMes,
    required this.citasCanceladas,
    required this.tasaCancelacion,
    required this.ingresosMes,
    required this.crecimientoMensual,
  });

  String get ingresosMesFormateado =>
      '\$${NumberFormat('#,###.00').format(ingresosMes)}';

  String get crecimientoFormateado =>
      '${crecimientoMensual >= 0 ? '+' : ''}${crecimientoMensual.toStringAsFixed(1)}%';

  Map<String, dynamic> toMap() {
    return {
      'totalCitasMes': totalCitasMes,
      'citasCanceladas': citasCanceladas,
      'tasaCancelacion': tasaCancelacion,
      'ingresosMes': ingresosMes,
      'crecimientoMensual': crecimientoMensual,
    };
  }
}

// ============================================================================
// EXCEPCIONES
// ============================================================================

class MetricsException implements Exception {
  final String message;
  final String? code;

  MetricsException(this.message, [this.code]);

  @override
  String toString() =>
      'MetricsException: $message${code != null ? ' (Code: $code)' : ''}';
}
