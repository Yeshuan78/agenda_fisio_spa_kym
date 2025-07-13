// [agenda_drag_drop_service.dart]
// 📁 Ubicación: /lib/services/agenda/agenda_drag_drop_service.dart
// 🎯 SERVICIO COMPLETO DE DRAG & DROP PARA AGENDA PREMIUM - VERSIÓN CORREGIDA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/services/agenda/booking_service.dart';

class AgendaDragDropService {
  static final AgendaDragDropService _instance =
      AgendaDragDropService._internal();
  factory AgendaDragDropService() => _instance;
  AgendaDragDropService._internal();

  // ✅ SERVICIOS DEPENDENCY INJECTION
  final BookingService _bookingService = BookingService();

  // ✅ ESTADO DEL DRAG & DROP
  DragDropState _currentState = DragDropState.idle;
  AppointmentModel? _draggedAppointment;
  final List<AppointmentModel> _selectedAppointments = [];
  DateTime? _targetDateTime;
  String? _targetResourceId;
  ValidationResult? _currentValidation;

  // ✅ CONTROLLERS Y STREAMS
  final StreamController<DragDropEvent> _eventController =
      StreamController<DragDropEvent>.broadcast();
  final StreamController<List<AppointmentModel>> _selectionController =
      StreamController<List<AppointmentModel>>.broadcast();

  Timer? _validationDebouncer;
  Timer? _autoSaveTimer;

  // ✅ CONFIGURACIÓN
  DragDropConfig _config = const DragDropConfig();

  // ✅ GETTERS PÚBLICOS
  Stream<DragDropEvent> get events => _eventController.stream;
  Stream<List<AppointmentModel>> get selectedAppointments =>
      _selectionController.stream;
  DragDropState get currentState => _currentState;
  AppointmentModel? get draggedAppointment => _draggedAppointment;
  List<AppointmentModel> get selectedAppointmentsList =>
      List.unmodifiable(_selectedAppointments);
  ValidationResult? get currentValidation => _currentValidation;

  // ✅ CONFIGURACIÓN
  void updateConfig(DragDropConfig newConfig) {
    _config = newConfig;
    debugPrint('🔧 DragDrop config updated: ${newConfig.toString()}');
  }

  // ========================================================================
  // 🎯 DRAG OPERATIONS - INICIO Y GESTIÓN
  // ========================================================================

  /// Inicia una operación de drag
  Future<void> startDrag(
    AppointmentModel appointment, {
    bool isMultiSelect = false,
    Offset? initialPosition,
  }) async {
    debugPrint('🎯 Starting drag for appointment: ${appointment.id}');

    try {
      // ✅ VALIDAR ESTADO
      if (_currentState != DragDropState.idle) {
        throw DragDropException('Drag operation already in progress');
      }

      // ✅ CONFIGURAR ESTADO INICIAL
      _currentState = DragDropState.dragging;
      _draggedAppointment = appointment;

      // ✅ MANEJAR MULTI-SELECCIÓN
      if (isMultiSelect && _selectedAppointments.contains(appointment)) {
        // Mantener selección actual si la cita ya está seleccionada
        debugPrint(
            '📋 Multi-drag initiated with ${_selectedAppointments.length} appointments');
      } else if (isMultiSelect) {
        // Agregar a selección
        _selectedAppointments.add(appointment);
        _selectionController.add(List.from(_selectedAppointments));
      } else {
        // Drag individual - limpiar selección
        _selectedAppointments.clear();
        _selectedAppointments.add(appointment);
        _selectionController.add(List.from(_selectedAppointments));
      }

      // ✅ HAPTIC FEEDBACK
      HapticFeedback.mediumImpact();

      // ✅ EMITIR EVENTO
      _emitEvent(DragDropEvent(
        type: DragDropEventType.dragStarted,
        appointment: appointment,
        selectedAppointments: List.from(_selectedAppointments),
        position: initialPosition,
        timestamp: DateTime.now(),
      ));

      // ✅ AUTO-SAVE TIMER (backup de seguridad)
      _startAutoSaveTimer();
    } catch (e) {
      debugPrint('❌ Error starting drag: $e');
      await _resetDragState();
      rethrow;
    }
  }

  /// Actualiza la posición del drag y valida destino
  Future<void> updateDragPosition({
    required DateTime targetDateTime,
    required String targetResourceId,
    Offset? currentPosition,
  }) async {
    if (_currentState != DragDropState.dragging || _draggedAppointment == null)
      return;

    try {
      // ✅ ACTUALIZAR POSICIÓN TARGET
      _targetDateTime = targetDateTime;
      _targetResourceId = targetResourceId;

      // ✅ DEBOUNCED VALIDATION (evitar spam de validaciones)
      _validationDebouncer?.cancel();
      _validationDebouncer = Timer(const Duration(milliseconds: 200), () async {
        await _validateCurrentPosition();
      });

      // ✅ EMITIR EVENTO DE POSICIÓN
      _emitEvent(DragDropEvent(
        type: DragDropEventType.dragUpdated,
        appointment: _draggedAppointment!,
        targetDateTime: targetDateTime,
        targetResourceId: targetResourceId,
        position: currentPosition,
        validation: _currentValidation,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('⚠️ Error updating drag position: $e');
    }
  }

  /// Finaliza el drag con drop exitoso
  Future<DropResult> completeDrop() async {
    debugPrint('🎯 Completing drop operation...');

    if (_currentState != DragDropState.dragging ||
        _draggedAppointment == null ||
        _targetDateTime == null ||
        _targetResourceId == null) {
      throw DragDropException('Invalid drop state');
    }

    try {
      _currentState = DragDropState.validating;

      // ✅ VALIDACIÓN FINAL
      final validation = await _validateMove(
        _draggedAppointment!,
        _targetDateTime!,
        _targetResourceId!,
      );

      if (validation.hasConflicts && !_config.allowConflictOverride) {
        return DropResult.conflict(
          conflicts: validation.conflicts,
          suggestedTimes: await _getSuggestedTimes(),
        );
      }

      _currentState = DragDropState.saving;

      // ✅ EJECUTAR MOVIMIENTO(S)
      final results = <AppointmentMoveResult>[];

      if (_selectedAppointments.length == 1) {
        // ✅ SINGLE APPOINTMENT MOVE
        final result = await _executeSingleMove(
          _draggedAppointment!,
          _targetDateTime!,
          _targetResourceId!,
        );
        results.add(result);
      } else {
        // ✅ BATCH MOVE
        final batchResults = await _executeBatchMove();
        results.addAll(batchResults);
      }

      // ✅ HAPTIC SUCCESS
      HapticFeedback.lightImpact();

      // ✅ EMITIR EVENTO DE ÉXITO
      _emitEvent(DragDropEvent(
        type: DragDropEventType.dropCompleted,
        appointment: _draggedAppointment!,
        selectedAppointments: List.from(_selectedAppointments),
        targetDateTime: _targetDateTime,
        targetResourceId: _targetResourceId,
        moveResults: results,
        timestamp: DateTime.now(),
      ));

      await _resetDragState();

      return DropResult.success(
        movedAppointments: results,
        message: _buildSuccessMessage(results),
      );
    } catch (e) {
      debugPrint('❌ Error completing drop: $e');
      await cancelDrag();
      return DropResult.error(
        error: e.toString(),
        originalAppointment: _draggedAppointment!,
      );
    }
  }

  /// Cancela la operación de drag
  Future<void> cancelDrag() async {
    debugPrint('🚫 Cancelling drag operation');

    HapticFeedback.heavyImpact();

    _emitEvent(DragDropEvent(
      type: DragDropEventType.dragCancelled,
      appointment: _draggedAppointment,
      timestamp: DateTime.now(),
    ));

    await _resetDragState();
  }

  // ========================================================================
  // 🎯 MULTI-SELECTION MANAGEMENT
  // ========================================================================

  /// Toggle selección de una cita
  void toggleAppointmentSelection(AppointmentModel appointment) {
    if (_selectedAppointments.contains(appointment)) {
      _selectedAppointments.remove(appointment);
    } else {
      _selectedAppointments.add(appointment);
    }

    _selectionController.add(List.from(_selectedAppointments));

    debugPrint(
        '📋 Selection updated: ${_selectedAppointments.length} appointments');
  }

  /// Seleccionar múltiples citas
  void selectAppointments(List<AppointmentModel> appointments) {
    _selectedAppointments.clear();
    _selectedAppointments.addAll(appointments);
    _selectionController.add(List.from(_selectedAppointments));
  }

  /// Limpiar selección
  void clearSelection() {
    _selectedAppointments.clear();
    _selectionController.add([]);
  }

  /// Seleccionar todas las citas en un rango de tiempo
  Future<void> selectAppointmentsInRange({
    required DateTime startTime,
    required DateTime endTime,
    String? resourceId,
  }) async {
    try {
      final appointments = await _getCitasEnRango(
        startTime: startTime,
        endTime: endTime,
        resourceId: resourceId,
      );

      selectAppointments(appointments);

      debugPrint('📅 Selected ${appointments.length} appointments in range');
    } catch (e) {
      debugPrint('❌ Error selecting appointments in range: $e');
    }
  }

  // ========================================================================
  // 🎯 BATCH OPERATIONS
  // ========================================================================

  /// Mover múltiples citas con distribución inteligente
  Future<BatchMoveResult> moveBatchAppointments({
    required List<AppointmentModel> appointments,
    required DateTime startDateTime,
    required String targetResourceId,
    BatchMoveStrategy strategy = BatchMoveStrategy.sequential,
  }) async {
    debugPrint('🔄 Starting batch move: ${appointments.length} appointments');

    try {
      final results = <AppointmentMoveResult>[];

      switch (strategy) {
        case BatchMoveStrategy.sequential:
          results.addAll(await _executeBatchSequential(
              appointments, startDateTime, targetResourceId));
          break;

        case BatchMoveStrategy.parallel:
          results.addAll(await _executeBatchParallel(
              appointments, startDateTime, targetResourceId));
          break;

        case BatchMoveStrategy.optimized:
          results.addAll(await _executeBatchOptimized(
              appointments, startDateTime, targetResourceId));
          break;
      }

      return BatchMoveResult(
        successCount: results.where((r) => r.success).length,
        failureCount: results.where((r) => !r.success).length,
        results: results,
        conflicts: [],
      );
    } catch (e) {
      debugPrint('❌ Error in batch move: $e');
      return BatchMoveResult.error(e.toString());
    }
  }

  // ========================================================================
  // 🎯 SMART SCHEDULING
  // ========================================================================

  /// Buscar el mejor horario disponible para una cita
  Future<List<TimeSlotSuggestion>> findBestAvailableSlots({
    required AppointmentModel appointment,
    required String targetResourceId,
    required DateTime preferredDate,
    int maxSuggestions = 5,
  }) async {
    try {
      final suggestions = <TimeSlotSuggestion>[];
      final duration = appointment.duracion ?? 60;

      // ✅ GENERAR SLOTS DE EJEMPLO (8 AM - 6 PM, cada 30 min)
      final baseTime = DateTime(
          preferredDate.year, preferredDate.month, preferredDate.day, 8, 0);
      final slots = <DateTime>[];

      for (int i = 0; i < 20; i++) {
        // 10 horas * 2 slots por hora
        slots.add(baseTime.add(Duration(minutes: i * 30)));
      }

      // ✅ EVALUAR CADA SLOT
      for (final slot in slots.take(maxSuggestions * 2)) {
        final validation =
            await _validateMove(appointment, slot, targetResourceId);

        if (!validation.hasConflicts) {
          suggestions.add(TimeSlotSuggestion(
            dateTime: slot,
            resourceId: targetResourceId,
            confidence: _calculateSlotConfidence(slot, appointment),
            reason: _getSlotRecommendationReason(slot, appointment),
          ));
        }
      }

      // ✅ ORDENAR POR CONFIANZA
      suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return suggestions.take(maxSuggestions).toList();
    } catch (e) {
      debugPrint('❌ Error finding available slots: $e');
      return [];
    }
  }

  // ========================================================================
  // 🎯 INTERNAL METHODS
  // ========================================================================

  /// Método helper para obtener citas en un rango de tiempo
  Future<List<AppointmentModel>> _getCitasEnRango({
    required DateTime startTime,
    required DateTime endTime,
    String? resourceId,
  }) async {
    try {
      final appointments = <AppointmentModel>[];

      // Iterar día por día en el rango
      DateTime currentDay =
          DateTime(startTime.year, startTime.month, startTime.day);
      final lastDay = DateTime(endTime.year, endTime.month, endTime.day);

      while (!currentDay.isAfter(lastDay)) {
        List<AppointmentModel> dayAppointments;

        if (resourceId != null) {
          dayAppointments = await _bookingService.getCitasPorProfesionalYFecha(
            resourceId,
            currentDay,
          );
        } else {
          dayAppointments = await _bookingService.getCitasPorFecha(currentDay);
        }

        // Filtrar por horario específico
        final filteredAppointments = dayAppointments.where((appointment) {
          final fechaInicio = appointment.fechaInicio;
          if (fechaInicio == null) return false;

          return !fechaInicio.isBefore(startTime) &&
              fechaInicio.isBefore(endTime);
        }).toList();

        appointments.addAll(filteredAppointments);
        currentDay = currentDay.add(const Duration(days: 1));
      }

      return appointments;
    } catch (e) {
      debugPrint('❌ Error getting appointments in range: $e');
      return [];
    }
  }

  Future<void> _validateCurrentPosition() async {
    if (_draggedAppointment == null ||
        _targetDateTime == null ||
        _targetResourceId == null) {
      return;
    }

    try {
      _currentValidation = await _validateMove(
        _draggedAppointment!,
        _targetDateTime!,
        _targetResourceId!,
      );
    } catch (e) {
      debugPrint('⚠️ Error in position validation: $e');
    }
  }

  Future<ValidationResult> _validateMove(
    AppointmentModel appointment,
    DateTime newDateTime,
    String newResourceId,
  ) async {
    final conflicts = <ConflictInfo>[];

    try {
      // ✅ VERIFICAR CONFLICTOS CON OTRAS CITAS
      final existingAppointments =
          await _bookingService.getCitasPorProfesionalYFecha(
        newResourceId,
        newDateTime,
      );

      for (final existing in existingAppointments) {
        if (existing.id != appointment.id &&
            _bookingService.hasTimeConflict(
                existing, newDateTime, appointment.duracion ?? 60)) {
          conflicts.add(ConflictInfo(
            type: ConflictType.appointmentConflict,
            message: 'Conflicto con cita de ${existing.nombreCliente}',
          ));
        }
      }

      return ValidationResult(
        hasConflicts: conflicts.isNotEmpty,
        conflicts: conflicts,
      );
    } catch (e) {
      debugPrint('❌ Error in validation: $e');
      return ValidationResult(
        hasConflicts: true,
        conflicts: [
          ConflictInfo(
            type: ConflictType.professionalUnavailable,
            message: 'Error validando disponibilidad: $e',
          )
        ],
      );
    }
  }

  Future<AppointmentMoveResult> _executeSingleMove(
    AppointmentModel appointment,
    DateTime newDateTime,
    String newResourceId,
  ) async {
    try {
      await _bookingService.moverCita(
        appointmentId: appointment.id,
        nuevaFecha: newDateTime,
        nuevoProfesionalId: newResourceId,
      );

      return AppointmentMoveResult(
        appointmentId: appointment.id,
        originalDateTime: appointment.fechaInicio!,
        newDateTime: newDateTime,
        originalResourceId: appointment.profesionalId!,
        newResourceId: newResourceId,
        success: true,
      );
    } catch (e) {
      return AppointmentMoveResult(
        appointmentId: appointment.id,
        originalDateTime: appointment.fechaInicio!,
        newDateTime: newDateTime,
        originalResourceId: appointment.profesionalId!,
        newResourceId: newResourceId,
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<List<AppointmentMoveResult>> _executeBatchMove() async {
    final results = <AppointmentMoveResult>[];
    var currentTime = _targetDateTime!;

    for (final appointment in _selectedAppointments) {
      try {
        final result = await _executeSingleMove(
          appointment,
          currentTime,
          _targetResourceId!,
        );
        results.add(result);

        // ✅ INCREMENTAR TIEMPO PARA SIGUIENTE CITA
        if (result.success) {
          currentTime =
              currentTime.add(Duration(minutes: appointment.duracion ?? 60));
        }
      } catch (e) {
        results.add(AppointmentMoveResult(
          appointmentId: appointment.id,
          originalDateTime: appointment.fechaInicio!,
          newDateTime: currentTime,
          originalResourceId: appointment.profesionalId!,
          newResourceId: _targetResourceId!,
          success: false,
          error: e.toString(),
        ));
      }
    }

    return results;
  }

  Future<List<AppointmentMoveResult>> _executeBatchSequential(
    List<AppointmentModel> appointments,
    DateTime startTime,
    String resourceId,
  ) async {
    final results = <AppointmentMoveResult>[];
    var currentTime = startTime;

    for (final appointment in appointments) {
      final result =
          await _executeSingleMove(appointment, currentTime, resourceId);
      results.add(result);

      if (result.success) {
        currentTime =
            currentTime.add(Duration(minutes: appointment.duracion ?? 60));
      }
    }

    return results;
  }

  Future<List<AppointmentMoveResult>> _executeBatchParallel(
    List<AppointmentModel> appointments,
    DateTime startTime,
    String resourceId,
  ) async {
    final futures = appointments.asMap().entries.map((entry) {
      final index = entry.key;
      final appointment = entry.value;
      final appointmentTime = startTime
          .add(Duration(minutes: index * (appointment.duracion ?? 60)));

      return _executeSingleMove(appointment, appointmentTime, resourceId);
    });

    return await Future.wait(futures);
  }

  Future<List<AppointmentMoveResult>> _executeBatchOptimized(
    List<AppointmentModel> appointments,
    DateTime startTime,
    String resourceId,
  ) async {
    // ✅ ORDENAR POR DURACIÓN (MÁS CORTAS PRIMERO)
    final sortedAppointments = List<AppointmentModel>.from(appointments)
      ..sort((a, b) => (a.duracion ?? 60).compareTo(b.duracion ?? 60));

    return await _executeBatchSequential(
        sortedAppointments, startTime, resourceId);
  }

  Future<List<DateTime>> _getSuggestedTimes() async {
    if (_draggedAppointment == null || _targetResourceId == null) return [];

    try {
      final suggestions = await findBestAvailableSlots(
        appointment: _draggedAppointment!,
        targetResourceId: _targetResourceId!,
        preferredDate: _targetDateTime ?? DateTime.now(),
      );

      return suggestions.map((s) => s.dateTime).toList();
    } catch (e) {
      return [];
    }
  }

  double _calculateSlotConfidence(DateTime slot, AppointmentModel appointment) {
    double confidence = 1.0;

    // ✅ PENALIZAR HORARIOS MUY TEMPRANOS O TARDÍOS
    if (slot.hour < 8 || slot.hour > 18) {
      confidence -= 0.3;
    }

    // ✅ PREMIAR HORARIOS EN MÚLTIPLOS DE 30 MIN
    if (slot.minute % 30 == 0) {
      confidence += 0.1;
    }

    // ✅ PENALIZAR HORARIOS DE ALMUERZO
    if (slot.hour >= 13 && slot.hour <= 14) {
      confidence -= 0.2;
    }

    return math.max(0.0, math.min(1.0, confidence));
  }

  String _getSlotRecommendationReason(
      DateTime slot, AppointmentModel appointment) {
    if (slot.hour >= 9 && slot.hour <= 11) {
      return 'Horario matutino óptimo';
    } else if (slot.hour >= 15 && slot.hour <= 17) {
      return 'Horario vespertino ideal';
    } else if (slot.minute % 30 == 0) {
      return 'Horario en punto recomendado';
    } else {
      return 'Horario disponible';
    }
  }

  String _buildSuccessMessage(List<AppointmentMoveResult> results) {
    final successCount = results.where((r) => r.success).length;

    if (results.length == 1) {
      return 'Cita movida exitosamente';
    } else {
      return '$successCount de ${results.length} citas movidas exitosamente';
    }
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 30), () async {
      if (_currentState == DragDropState.dragging) {
        debugPrint('⏰ Auto-save timer triggered - cancelling stale drag');
        await cancelDrag();
      }
    });
  }

  void _emitEvent(DragDropEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  Future<void> _resetDragState() async {
    _currentState = DragDropState.idle;
    _draggedAppointment = null;
    _targetDateTime = null;
    _targetResourceId = null;
    _currentValidation = null;

    _validationDebouncer?.cancel();
    _autoSaveTimer?.cancel();

    debugPrint('🔄 Drag state reset');
  }

  // ✅ CLEANUP
  void dispose() {
    _validationDebouncer?.cancel();
    _autoSaveTimer?.cancel();
    _eventController.close();
    _selectionController.close();
  }
}

// ========================================================================
// 🎯 DATA CLASSES Y ENUMS
// ========================================================================

enum DragDropState { idle, dragging, validating, saving }

enum DragDropEventType {
  dragStarted,
  dragUpdated,
  dropCompleted,
  dragCancelled,
  validationUpdated,
}

enum BatchMoveStrategy { sequential, parallel, optimized }

enum ConflictType {
  unavailableTime,
  appointmentConflict,
  blockedTime,
  professionalUnavailable,
}

class DragDropConfig {
  final bool allowConflictOverride;
  final int validationDebounceMs;
  final double loadBalanceThreshold;
  final bool enableHapticFeedback;
  final int maxBatchSize;

  const DragDropConfig({
    this.allowConflictOverride = false,
    this.validationDebounceMs = 200,
    this.loadBalanceThreshold = 0.25,
    this.enableHapticFeedback = true,
    this.maxBatchSize = 10,
  });

  @override
  String toString() =>
      'DragDropConfig(allowConflictOverride: $allowConflictOverride, validationDebounce: ${validationDebounceMs}ms)';
}

class ValidationResult {
  final bool hasConflicts;
  final List<ConflictInfo> conflicts;

  ValidationResult({required this.hasConflicts, required this.conflicts});
}

class ConflictInfo {
  final ConflictType type;
  final String message;

  ConflictInfo({required this.type, required this.message});
}

class DragDropEvent {
  final DragDropEventType type;
  final AppointmentModel? appointment;
  final List<AppointmentModel> selectedAppointments;
  final DateTime? targetDateTime;
  final String? targetResourceId;
  final Offset? position;
  final ValidationResult? validation;
  final List<AppointmentMoveResult>? moveResults;
  final DateTime timestamp;

  DragDropEvent({
    required this.type,
    this.appointment,
    this.selectedAppointments = const [],
    this.targetDateTime,
    this.targetResourceId,
    this.position,
    this.validation,
    this.moveResults,
    required this.timestamp,
  });
}

class DropResult {
  final bool success;
  final String? message;
  final List<AppointmentMoveResult>? movedAppointments;
  final List<ConflictInfo>? conflicts;
  final List<DateTime>? suggestedTimes;
  final String? error;
  final AppointmentModel? originalAppointment;

  DropResult._({
    required this.success,
    this.message,
    this.movedAppointments,
    this.conflicts,
    this.suggestedTimes,
    this.error,
    this.originalAppointment,
  });

  factory DropResult.success({
    required List<AppointmentMoveResult> movedAppointments,
    required String message,
  }) =>
      DropResult._(
        success: true,
        movedAppointments: movedAppointments,
        message: message,
      );

  factory DropResult.conflict({
    required List<ConflictInfo> conflicts,
    required List<DateTime> suggestedTimes,
  }) =>
      DropResult._(
        success: false,
        conflicts: conflicts,
        suggestedTimes: suggestedTimes,
      );

  factory DropResult.error({
    required String error,
    required AppointmentModel originalAppointment,
  }) =>
      DropResult._(
        success: false,
        error: error,
        originalAppointment: originalAppointment,
      );
}

class AppointmentMoveResult {
  final String appointmentId;
  final DateTime originalDateTime;
  final DateTime newDateTime;
  final String originalResourceId;
  final String newResourceId;
  final bool success;
  final String? error;

  AppointmentMoveResult({
    required this.appointmentId,
    required this.originalDateTime,
    required this.newDateTime,
    required this.originalResourceId,
    required this.newResourceId,
    required this.success,
    this.error,
  });
}

class BatchMoveResult {
  final int successCount;
  final int failureCount;
  final List<AppointmentMoveResult> results;
  final List<ConflictInfo> conflicts;
  final String? error;

  BatchMoveResult({
    required this.successCount,
    required this.failureCount,
    required this.results,
    required this.conflicts,
    this.error,
  });

  factory BatchMoveResult.error(String error) => BatchMoveResult(
        successCount: 0,
        failureCount: 0,
        results: [],
        conflicts: [],
        error: error,
      );

  bool get hasFailures => failureCount > 0;
  double get successRate => successCount / (successCount + failureCount);
}

class TimeSlotSuggestion {
  final DateTime dateTime;
  final String resourceId;
  final double confidence;
  final String reason;

  TimeSlotSuggestion({
    required this.dateTime,
    required this.resourceId,
    required this.confidence,
    required this.reason,
  });
}

class DragDropException implements Exception {
  final String message;
  DragDropException(this.message);

  @override
  String toString() => 'DragDropException: $message';
}
