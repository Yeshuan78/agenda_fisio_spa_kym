// [evento_form_state.dart] - ESTADO REACTIVO PARA EVENTO CRUD
// 📁 Ubicación: /lib/models/evento_form_state.dart
// 🎯 OBJETIVO: Estado inmutable para formulario de eventos

import 'package:flutter/foundation.dart';

/// 📋 ESTADO PRINCIPAL DEL FORMULARIO DE EVENTOS
class EventoFormState {
  final bool isLoading;
  final bool isValid;
  final Map<String, String> errors;
  final String currentStep;
  final String horarioInicioPorDefecto;
  final String horarioFinPorDefecto;
  final List<EventoAsignacion> asignaciones;
  final bool hasUnsavedChanges;

  const EventoFormState({
    this.isLoading = false,
    this.isValid = false,
    this.errors = const {},
    this.currentStep = 'basic_info',
    this.horarioInicioPorDefecto = '09:00',
    this.horarioFinPorDefecto = '15:00',
    this.asignaciones = const [],
    this.hasUnsavedChanges = false,
  });

  /// 🏭 ESTADO INICIAL
  factory EventoFormState.initial() {
    return const EventoFormState();
  }

  /// 🔄 COPYWIHT PARA IMMUTABILIDAD
  EventoFormState copyWith({
    bool? isLoading,
    bool? isValid,
    Map<String, String>? errors,
    String? currentStep,
    String? horarioInicioPorDefecto,
    String? horarioFinPorDefecto,
    List<EventoAsignacion>? asignaciones,
    bool? hasUnsavedChanges,
  }) {
    return EventoFormState(
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
      currentStep: currentStep ?? this.currentStep,
      horarioInicioPorDefecto: horarioInicioPorDefecto ?? this.horarioInicioPorDefecto,
      horarioFinPorDefecto: horarioFinPorDefecto ?? this.horarioFinPorDefecto,
      asignaciones: asignaciones ?? this.asignaciones,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  /// ✅ MÉTODOS DE VALIDACIÓN
  bool get canProceedToNextStep {
    switch (currentStep) {
      case 'basic_info':
        return !errors.containsKey('nombre') && 
               !errors.containsKey('empresa');
      case 'horarios':
        return horarioInicioPorDefecto.isNotEmpty && 
               horarioFinPorDefecto.isNotEmpty;
      case 'asignaciones':
        return asignaciones.isNotEmpty && 
               asignaciones.every((a) => a.isValid);
      default:
        return true;
    }
  }

  int get currentStepIndex {
    switch (currentStep) {
      case 'basic_info':
        return 0;
      case 'horarios':
        return 1;
      case 'asignaciones':
        return 2;
      case 'review':
        return 3;
      default:
        return 0;
    }
  }

  /// 📊 MÉTODOS DE ANÁLISIS
  bool get hasErrors => errors.isNotEmpty;
  int get totalErrors => errors.length;
  bool get canSave => isValid && asignaciones.isNotEmpty && !hasErrors;

  @override
  String toString() {
    return 'EventoFormState{isLoading: $isLoading, isValid: $isValid, currentStep: $currentStep, asignaciones: ${asignaciones.length}}';
  }
}

/// 📋 MODELO DE ASIGNACIÓN INDIVIDUAL
class EventoAsignacion {
  final String servicioId;
  final String profesionalId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;

  const EventoAsignacion({
    required this.servicioId,
    required this.profesionalId,
    required this.fecha,
    this.horaInicio = '09:00',
    this.horaFin = '15:00',
  });

  /// 🏭 ASIGNACIÓN VACÍA
  factory EventoAsignacion.empty() {
    return EventoAsignacion(
      servicioId: '',
      profesionalId: '',
      fecha: DateTime.now(),
    );
  }

  /// 🔄 COPYWIHT
  EventoAsignacion copyWith({
    String? servicioId,
    String? profesionalId,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
  }) {
    return EventoAsignacion(
      servicioId: servicioId ?? this.servicioId,
      profesionalId: profesionalId ?? this.profesionalId,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
    );
  }

  /// ✅ VALIDACIONES
  bool get isValid {
    return servicioId.isNotEmpty && 
           profesionalId.isNotEmpty &&
           horaInicio.isNotEmpty &&
           horaFin.isNotEmpty;
  }

  bool get hasTimeConflict {
    try {
      final inicioTime = _parseTime(horaInicio);
      final finTime = _parseTime(horaFin);
      return finTime.isBefore(inicioTime) || finTime.isAtSameMomentAs(inicioTime);
    } catch (e) {
      return true; // Error de parsing = conflicto
    }
  }

  Duration get duracion {
    try {
      final inicioTime = _parseTime(horaInicio);
      final finTime = _parseTime(horaFin);
      return finTime.difference(inicioTime);
    } catch (e) {
      return Duration.zero;
    }
  }

  /// 🕐 PARSER DE TIEMPO
  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 📝 CONVERSIÓN A MAP PARA FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'servicioId': servicioId,
      'profesionalId': profesionalId,
      'fecha': fecha.toIso8601String(),
      'horaInicio': horaInicio,
      'horaFin': horaFin,
    };
  }

  @override
  String toString() {
    return 'EventoAsignacion{servicioId: $servicioId, profesionalId: $profesionalId, fecha: $fecha, horario: $horaInicio-$horaFin}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventoAsignacion &&
          runtimeType == other.runtimeType &&
          servicioId == other.servicioId &&
          profesionalId == other.profesionalId &&
          fecha == other.fecha;

  @override
  int get hashCode =>
      servicioId.hashCode ^
      profesionalId.hashCode ^
      fecha.hashCode;
}