// [global_calendar_state.dart] - Estado Global del Calendario Enterprise
// 📁 Ubicación: /lib/services/calendar_state/global_calendar_state.dart
// 🏢 PATRÓN ENTERPRISE: Singleton centralizado inspirado en Notion, Salesforce, HubSpot

import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'calendar_event_bus.dart';
import 'calendar_state_models.dart';

/// 🏢 Estado Global del Calendario - Patrón Enterprise
/// Singleton que mantiene el estado centralizado del calendario
/// Inspirado en arquitecturas de Notion, Salesforce, HubSpot
class GlobalCalendarState extends ChangeNotifier {
  // 🎯 SINGLETON PATTERN
  static final GlobalCalendarState _instance = GlobalCalendarState._internal();
  factory GlobalCalendarState() => _instance;
  GlobalCalendarState._internal() {
    _initializeState();
  }

  // 📊 ESTADO CENTRALIZADO
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<AppointmentModel>> _appointments = {};
  CalendarViewMode _viewMode = CalendarViewMode.week;
  bool _isLoading = false;
  CalendarFilters _filters = CalendarFilters.empty();
  
  // 📢 EVENT BUS
  final CalendarEventBus _eventBus = CalendarEventBus();
  
  // 🔒 GETTERS INMUTABLES
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, List<AppointmentModel>> get appointments => Map.unmodifiable(_appointments);
  CalendarViewMode get viewMode => _viewMode;
  bool get isLoading => _isLoading;
  CalendarFilters get filters => _filters;
  CalendarEventBus get eventBus => _eventBus;

  /// 🎯 MÉTODOS PÚBLICOS PARA ACTUALIZACIONES
  
  /// Cambiar fecha seleccionada con validación enterprise
  void setSelectedDate(DateTime newDate, {String? source}) {
    if (_isSameDay(_selectedDate, newDate)) return;
    
    final oldDate = _selectedDate;
    _selectedDate = _normalizeDate(newDate);
    
    // 📢 Emitir evento antes de notificar
    _eventBus.emit(CalendarEvent.dateChanged(
      oldDate: oldDate,
      newDate: _selectedDate,
      source: source ?? 'unknown',
    ));
    
    notifyListeners();
    _logStateChange('selectedDate', oldDate.toString(), _selectedDate.toString(), source);
  }

  /// Actualizar appointments con diff inteligente
  void setAppointments(Map<DateTime, List<AppointmentModel>> newAppointments, {String? source}) {
    if (_areAppointmentsEqual(_appointments, newAppointments)) return;
    
    final oldCount = _appointments.length;
    _appointments = Map.from(newAppointments);
    
    // 📢 Emitir evento
    _eventBus.emit(CalendarEvent.appointmentsChanged(
      oldCount: oldCount,
      newCount: _appointments.length,
      source: source ?? 'unknown',
    ));
    
    notifyListeners();
    _logStateChange('appointments', '$oldCount días', '${_appointments.length} días', source);
  }

  /// Cambiar modo de vista con validación
  void setViewMode(CalendarViewMode newMode, {String? source}) {
    if (_viewMode == newMode) return;
    
    final oldMode = _viewMode;
    _viewMode = newMode;
    
    _eventBus.emit(CalendarEvent.viewModeChanged(
      oldMode: oldMode,
      newMode: newMode,
      source: source ?? 'unknown',
    ));
    
    notifyListeners();
    _logStateChange('viewMode', oldMode.name, newMode.name, source);
  }

  /// Estado de carga centralizado
  void setLoading(bool loading, {String? source}) {
    if (_isLoading == loading) return;
    
    _isLoading = loading;
    notifyListeners();
    _logStateChange('isLoading', (!loading).toString(), loading.toString(), source);
  }

  /// Actualizar filtros con validación
  void setFilters(CalendarFilters newFilters, {String? source}) {
    if (_filters == newFilters) return;
    
    _filters = newFilters;
    notifyListeners();
    _logStateChange('filters', 'updated', 'applied', source);
  }

  // 🔧 MÉTODOS HELPER PRIVADOS
  
  void _initializeState() {
    debugPrint('🏢 GlobalCalendarState inicializado - Patrón Enterprise');
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _areAppointmentsEqual(Map<DateTime, List<AppointmentModel>> a, Map<DateTime, List<AppointmentModel>> b) {
    if (a.length != b.length) return false;
    
    for (final entry in a.entries) {
      final bList = b[entry.key];
      if (bList == null || bList.length != entry.value.length) return false;
    }
    return true;
  }

  void _logStateChange(String property, String oldValue, String newValue, String? source) {
    debugPrint('🔄 [GlobalCalendarState] $property: $oldValue → $newValue (source: ${source ?? 'unknown'})');
  }

  /// 🧹 Limpiar estado (para testing)
  void reset() {
    _selectedDate = DateTime.now();
    _appointments.clear();
    _viewMode = CalendarViewMode.week;
    _isLoading = false;
    _filters = CalendarFilters.empty();
    notifyListeners();
    debugPrint('🧹 GlobalCalendarState reseteado');
  }

  @override
  void dispose() {
    _eventBus.dispose();
    super.dispose();
  }
}