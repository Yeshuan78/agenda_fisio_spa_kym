// [time_slot_generator_service.dart] - SERVICIO DE GENERACIÓN DE HORARIOS
// 📁 Ubicación: /lib/services/booking/time_slot_generator_service.dart
// 🎯 OBJETIVO: Centralizar lógica de generación de time slots disponibles

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/evento_model.dart';

/// ⏰ SERVICIO DE GENERACIÓN DE TIME SLOTS
/// Centraliza toda la lógica de generación de horarios disponibles
class TimeSlotGeneratorService {
  
  /// 🕐 GENERAR TIME SLOTS PRINCIPALES
  /// Extraído de: public_booking_screen.dart línea ~440-460
  static List<String> generateTimeSlots({
    EventoModel? currentEvento,
    String? selectedServiceId,
    List<Map<String, dynamic>>? serviciosDisponibles,
    DateTime? date,
  }) {
    // Si hay un evento específico y servicio seleccionado
    if (currentEvento != null && 
        selectedServiceId != null && 
        serviciosDisponibles != null) {
      
      final selectedService = serviciosDisponibles.firstWhere(
        (service) => service['id'] == selectedServiceId,
        orElse: () => {},
      );

      if (selectedService.isNotEmpty) {
        final horaInicio = selectedService['horaInicio'] ?? '09:00';
        final horaFin = selectedService['horaFin'] ?? '17:00';
        
        return generateSlotsFromRange(
          horaInicio, 
          horaFin,
          intervalMinutes: 30,
        );
      }
    }

    // Horarios por defecto para servicios particulares
    return generateDefaultTimeSlots();
  }

  /// 🕰️ GENERAR SLOTS DESDE RANGO ESPECÍFICO
  /// Extraído de: public_booking_screen.dart línea ~480-510
  static List<String> generateSlotsFromRange(
    String horaInicio, 
    String horaFin, {
    int intervalMinutes = 30,
    DateTime? baseDate,
  }) {
    final slots = <String>[];
    
    try {
      // Parsear hora de inicio
      final inicioTimeParts = horaInicio.split(':');
      final inicioTime = TimeOfDay(
        hour: int.parse(inicioTimeParts[0]),
        minute: int.parse(inicioTimeParts[1]),
      );

      // Parsear hora de fin
      final finTimeParts = horaFin.split(':');
      final finTime = TimeOfDay(
        hour: int.parse(finTimeParts[0]),
        minute: int.parse(finTimeParts[1]),
      );

      // Crear DateTimes para facilitar cálculos
      final baseDateTime = baseDate ?? DateTime(2024, 1, 1);
      DateTime current = DateTime(
        baseDateTime.year,
        baseDateTime.month,
        baseDateTime.day,
        inicioTime.hour,
        inicioTime.minute,
      );
      
      final endTime = DateTime(
        baseDateTime.year,
        baseDateTime.month,
        baseDateTime.day,
        finTime.hour,
        finTime.minute,
      );

      // Generar slots cada intervalMinutes
      while (current.isBefore(endTime)) {
        slots.add(DateFormat('HH:mm').format(current));
        current = current.add(Duration(minutes: intervalMinutes));
      }

      debugPrint('✅ Generados ${slots.length} slots de $horaInicio a $horaFin');
      
    } catch (e) {
      debugPrint('❌ Error generando slots de rango: $e');
      
      // Fallback a horarios básicos
      return generateBasicWorkingHours();
    }
    
    return slots;
  }

  /// 📅 GENERAR HORARIOS POR DEFECTO
  static List<String> generateDefaultTimeSlots() {
    return [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
      '15:00', '15:30', '16:00', '16:30', '17:00'
    ];
  }

  /// 🕘 GENERAR HORARIOS LABORALES BÁSICOS
  static List<String> generateBasicWorkingHours() {
    return [
      '09:00', '10:00', '11:00', '12:00', '13:00', 
      '14:00', '15:00', '16:00', '17:00'
    ];
  }

  /// ⚡ GENERAR SLOTS CON CONFIGURACIÓN AVANZADA
  static List<String> generateAdvancedTimeSlots({
    required DateTime startTime,
    required DateTime endTime,
    int intervalMinutes = 30,
    List<String>? excludedSlots,
    int? serviceDurationMinutes,
    bool includeBreaks = true,
    List<TimeSlotBreak>? breaks,
  }) {
    final slots = <String>[];
    DateTime current = startTime;

    while (current.isBefore(endTime)) {
      final timeString = DateFormat('HH:mm').format(current);
      
      // Verificar si está excluido
      if (excludedSlots?.contains(timeString) != true) {
        // Verificar si no está en horario de break
        if (!includeBreaks || !_isInBreak(current, breaks)) {
          // Verificar que hay tiempo suficiente para el servicio
          if (serviceDurationMinutes == null || 
              current.add(Duration(minutes: serviceDurationMinutes)).isBefore(endTime)) {
            slots.add(timeString);
          }
        }
      }
      
      current = current.add(Duration(minutes: intervalMinutes));
    }

    return slots;
  }

  /// 🍽️ VERIFICAR SI ESTÁ EN HORARIO DE BREAK
  static bool _isInBreak(DateTime time, List<TimeSlotBreak>? breaks) {
    if (breaks == null || breaks.isEmpty) return false;
    
    for (final breakPeriod in breaks) {
      if (time.isAtSameMomentAs(breakPeriod.startTime) ||
          time.isAtSameMomentAs(breakPeriod.endTime) ||
          (time.isAfter(breakPeriod.startTime) && time.isBefore(breakPeriod.endTime))) {
        return true;
      }
    }
    
    return false;
  }

  /// 📋 GENERAR SLOTS PARA MÚLTIPLES DÍAS
  static Map<DateTime, List<String>> generateMultiDaySlots({
    required DateTime startDate,
    required DateTime endDate,
    String horaInicio = '09:00',
    String horaFin = '17:00',
    int intervalMinutes = 30,
    List<int>? excludedWeekdays, // 1=Monday, 7=Sunday
  }) {
    final multiDaySlots = <DateTime, List<String>>{};
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Verificar si el día está excluido
      if (excludedWeekdays?.contains(currentDate.weekday) != true) {
        final dailySlots = generateSlotsFromRange(
          horaInicio,
          horaFin,
          intervalMinutes: intervalMinutes,
          baseDate: currentDate,
        );
        
        if (dailySlots.isNotEmpty) {
          final dateKey = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
          );
          multiDaySlots[dateKey] = dailySlots;
        }
      }
      
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return multiDaySlots;
  }

  /// 🎯 FILTRAR SLOTS OCUPADOS
  static List<String> filterAvailableSlots({
    required List<String> allSlots,
    required List<String> occupiedSlots,
    int? serviceDurationMinutes,
  }) {
    final availableSlots = <String>[];
    
    for (final slot in allSlots) {
      bool isAvailable = true;
      
      // Verificar si el slot está ocupado
      if (occupiedSlots.contains(slot)) {
        isAvailable = false;
      }
      
      // Si hay duración del servicio, verificar slots posteriores
      if (isAvailable && serviceDurationMinutes != null && serviceDurationMinutes > 30) {
        final slotsNeeded = (serviceDurationMinutes / 30).ceil();
        final currentSlotIndex = allSlots.indexOf(slot);
        
        // Verificar que hay suficientes slots disponibles
        for (int i = 0; i < slotsNeeded; i++) {
          final nextSlotIndex = currentSlotIndex + i;
          if (nextSlotIndex >= allSlots.length || 
              occupiedSlots.contains(allSlots[nextSlotIndex])) {
            isAvailable = false;
            break;
          }
        }
      }
      
      if (isAvailable) {
        availableSlots.add(slot);
      }
    }
    
    return availableSlots;
  }

  /// 🔍 VALIDAR FORMATO DE HORA
  static bool isValidTimeFormat(String timeString) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length != 2) return false;
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  /// ⏰ CONVERTIR STRING A TIMEOFDAY
  static TimeOfDay? parseTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length != 2) return null;
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      debugPrint('❌ Error parseando tiempo: $timeString - $e');
      return null;
    }
  }

  /// 🕐 CONVERTIR TIMEOFDAY A STRING
  static String timeOfDayToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 📊 CALCULAR DURACIÓN ENTRE SLOTS
  static int calculateDurationMinutes(String startTime, String endTime) {
    final start = parseTimeString(startTime);
    final end = parseTimeString(endTime);
    
    if (start == null || end == null) return 0;
    
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    
    return endMinutes - startMinutes;
  }

  /// 🎯 ENCONTRAR SIGUIENTE SLOT DISPONIBLE
  static String? findNextAvailableSlot({
    required List<String> allSlots,
    required List<String> occupiedSlots,
    String? afterTime,
  }) {
    int startIndex = 0;
    
    if (afterTime != null) {
      startIndex = allSlots.indexOf(afterTime) + 1;
      if (startIndex <= 0) startIndex = 0;
    }
    
    for (int i = startIndex; i < allSlots.length; i++) {
      if (!occupiedSlots.contains(allSlots[i])) {
        return allSlots[i];
      }
    }
    
    return null;
  }

  /// 📅 GENERAR SLOTS PARA EVENTO ESPECÍFICO
  static List<String> generateEventTimeSlots(EventoModel evento) {
    try {
      final eventDate = evento.fecha;
      
      // Buscar el primer servicio asignado para obtener horarios
      if (evento.serviciosAsignados.isNotEmpty) {
        final firstService = evento.serviciosAsignados.first;
        final horaInicio = firstService['horaInicio'] ?? '09:00';
        final horaFin = firstService['horaFin'] ?? '17:00';
        
        return generateSlotsFromRange(
          horaInicio,
          horaFin,
          baseDate: eventDate,
        );
      }
      
      // Fallback a horarios por defecto
      return generateDefaultTimeSlots();
      
    } catch (e) {
      debugPrint('❌ Error generando slots para evento: $e');
      return generateDefaultTimeSlots();
    }
  }

  /// 🏢 GENERAR SLOTS PARA EMPRESA
  static List<String> generateCompanyTimeSlots({
    required String companyId,
    DateTime? date,
    Map<String, dynamic>? companySettings,
  }) {
    try {
      // Si hay configuración específica de empresa
      if (companySettings != null) {
        final workingHours = companySettings['workingHours'] as Map<String, dynamic>?;
        if (workingHours != null) {
          final start = workingHours['start'] ?? '09:00';
          final end = workingHours['end'] ?? '17:00';
          final interval = workingHours['interval'] ?? 30;
          
          return generateSlotsFromRange(
            start,
            end,
            intervalMinutes: interval,
            baseDate: date,
          );
        }
      }
      
      // Horarios estándar de empresa
      return generateSlotsFromRange('08:00', '18:00', intervalMinutes: 60);
      
    } catch (e) {
      debugPrint('❌ Error generando slots para empresa: $e');
      return generateDefaultTimeSlots();
    }
  }
}

/// ⏸️ MODELO DE BREAK/PAUSA
class TimeSlotBreak {
  final DateTime startTime;
  final DateTime endTime;
  final String label;
  final bool isRecurring;

  const TimeSlotBreak({
    required this.startTime,
    required this.endTime,
    required this.label,
    this.isRecurring = false,
  });

  /// 🔄 COPIAR CON MODIFICACIONES
  TimeSlotBreak copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? label,
    bool? isRecurring,
  }) {
    return TimeSlotBreak(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      label: label ?? this.label,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  /// 📋 CONVERSIÓN A MAP
  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'label': label,
      'isRecurring': isRecurring,
    };
  }

  /// 🏗️ FACTORY DESDE MAP
  factory TimeSlotBreak.fromMap(Map<String, dynamic> map) {
    return TimeSlotBreak(
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      label: map['label'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
    );
  }

  @override
  String toString() {
    return 'TimeSlotBreak{startTime: $startTime, endTime: $endTime, label: $label}';
  }
}