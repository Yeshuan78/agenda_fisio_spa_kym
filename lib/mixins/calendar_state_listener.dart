// [calendar_state_listener.dart] - Mixin para Componentes de Calendario
// 📁 Ubicación: /lib/mixins/calendar_state_listener.dart
// 🎭 MIXIN ENTERPRISE: Facilita integración con estado global en cualquier widget

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:agenda_fisio_spa_kym/services/calendar_state/global_calendar_state.dart';
import 'package:agenda_fisio_spa_kym/services/calendar_state/calendar_state_models.dart';

/// 🎭 Mixin para escuchar el estado global del calendario
/// Facilita la integración en cualquier widget
mixin CalendarStateListener<T extends StatefulWidget> on State<T> {
  late final GlobalCalendarState _globalState;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _globalState = GlobalCalendarState();
    _setupCalendarListeners();
  }

  /// Override este método para configurar listeners específicos
  void _setupCalendarListeners() {
    // Listener básico para cualquier cambio
    _subscriptions.add(
      _globalState.eventBus.stream.listen(onCalendarEvent),
    );

    // Listeners específicos
    _subscriptions.add(
      _globalState.eventBus.onDateChanged(onDateChanged),
    );

    _subscriptions.add(
      _globalState.eventBus.onAppointmentsChanged(onAppointmentsChanged),
    );

    _subscriptions.add(
      _globalState.eventBus.onViewModeChanged(onViewModeChanged),
    );
  }

  /// Métodos que pueden ser sobrescritos por los widgets
  void onCalendarEvent(CalendarEvent event) {
    // Override para manejar cualquier evento
  }

  void onDateChanged(CalendarEventDateChanged event) {
    // Override para manejar cambios de fecha
  }

  void onAppointmentsChanged(CalendarEventAppointmentsChanged event) {
    // Override para manejar cambios de appointments
  }

  void onViewModeChanged(CalendarEventViewModeChanged event) {
    // Override para manejar cambios de modo de vista
  }

  /// Acceso directo al estado global
  GlobalCalendarState get calendarState => _globalState;

  /// Métodos helper para actualizaciones
  void updateSelectedDate(DateTime date) {
    _globalState.setSelectedDate(date, source: widget.runtimeType.toString());
  }

  void updateAppointments(Map<DateTime, List<dynamic>> appointments) {
    // Convertir appointments si es necesario
    // TODO: Implementar conversión correcta
    _globalState.setAppointments({}, source: widget.runtimeType.toString());
  }

  void updateViewMode(CalendarViewMode mode) {
    _globalState.setViewMode(mode, source: widget.runtimeType.toString());
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}