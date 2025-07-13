// [calendar_event_bus.dart] - Bus de Eventos del Calendario Enterprise
// 📁 Ubicación: /lib/services/calendar_state/calendar_event_bus.dart
// 📢 PATRÓN ENTERPRISE: Bus de eventos para comunicación desacoplada

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'calendar_state_models.dart';

/// 📢 Bus de Eventos del Calendario - Patrón Enterprise
/// Permite comunicación desacoplada entre componentes
class CalendarEventBus {
  final StreamController<CalendarEvent> _controller =
      StreamController<CalendarEvent>.broadcast();

  /// Stream para escuchar eventos
  Stream<CalendarEvent> get stream => _controller.stream;

  /// Emitir evento
  void emit(CalendarEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
      debugPrint(
          '📢 [EventBus] Emitido: ${event.type.name} (source: ${event.source})');
    }
  }

  /// Escuchar eventos específicos
  StreamSubscription<CalendarEvent> listen<T extends CalendarEvent>(
    void Function(T) onEvent, {
    bool Function(CalendarEvent)? filter,
  }) {
    return stream.where((event) {
      if (filter != null && !filter(event)) return false;
      return event is T;
    }).listen((event) => onEvent(event as T));
  }

  /// Escuchar cambios de fecha
  StreamSubscription<CalendarEvent> onDateChanged(
      void Function(CalendarEventDateChanged) callback) {
    return stream
        .where((event) => event is CalendarEventDateChanged)
        .listen((event) => callback(event as CalendarEventDateChanged));
  }

  /// Escuchar cambios de appointments
  StreamSubscription<CalendarEvent> onAppointmentsChanged(
      void Function(CalendarEventAppointmentsChanged) callback) {
    return stream
        .where((event) => event is CalendarEventAppointmentsChanged)
        .listen((event) => callback(event as CalendarEventAppointmentsChanged));
  }

  /// Escuchar cambios de modo de vista
  StreamSubscription<CalendarEvent> onViewModeChanged(
      void Function(CalendarEventViewModeChanged) callback) {
    return stream
        .where((event) => event is CalendarEventViewModeChanged)
        .listen((event) => callback(event as CalendarEventViewModeChanged));
  }

  void dispose() {
    _controller.close();
  }
}
