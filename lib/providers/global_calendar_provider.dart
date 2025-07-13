// [global_calendar_provider.dart]
// 📁 Ubicación: /lib/providers/global_calendar_provider.dart
// 🏗️ STATE MANAGEMENT GLOBAL PROFESIONAL PARA CALENDARIO

import 'package:flutter/foundation.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class GlobalCalendarProvider extends ChangeNotifier {
  // ========================================================================
  // 🎯 ESTADO GLOBAL DEL CALENDARIO
  // ========================================================================
  
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<AppointmentModel>> _appointments = {};
  String _selectedView = 'semana';
  String _selectedResource = 'profesionales';
  bool _isLoading = false;
  
  // ========================================================================
  // 🎯 GETTERS PÚBLICOS
  // ========================================================================
  
  DateTime get selectedDay => _selectedDay;
  Map<DateTime, List<AppointmentModel>> get appointments => _appointments;
  Map<DateTime, List<dynamic>> get appointmentsForSidebar => _convertForSidebar();
  String get selectedView => _selectedView;
  String get selectedResource => _selectedResource;
  bool get isLoading => _isLoading;
  
  // ========================================================================
  // 🎯 MÉTODOS PÚBLICOS PARA ACTUALIZAR ESTADO
  // ========================================================================
  
  /// 📅 Actualizar día seleccionado
  void updateSelectedDay(DateTime newDay) {
    if (_selectedDay != newDay) {
      _selectedDay = newDay;
      notifyListeners();
      debugPrint('🗓️ GlobalCalendar: Día actualizado a $newDay');
    }
  }
  
  /// 📋 Actualizar appointments
  void updateAppointments(Map<DateTime, List<AppointmentModel>> newAppointments) {
    _appointments = Map.from(newAppointments);
    notifyListeners();
    debugPrint('📋 GlobalCalendar: ${_appointments.length} días con citas actualizados');
  }
  
  /// 🔄 Actualizar vista
  void updateView(String newView) {
    if (_selectedView != newView) {
      _selectedView = newView;
      notifyListeners();
      debugPrint('🔄 GlobalCalendar: Vista cambiada a $newView');
    }
  }
  
  /// 🏢 Actualizar recurso
  void updateResource(String newResource) {
    if (_selectedResource != newResource) {
      _selectedResource = newResource;
      notifyListeners();
      debugPrint('🏢 GlobalCalendar: Recurso cambiado a $newResource');
    }
  }
  
  /// ⏳ Actualizar estado de carga
  void updateLoadingState(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  /// 🎯 Sincronizar desde AgendaStateManager
  void syncFromStateManager({
    required DateTime selectedDay,
    required Map<DateTime, List<AppointmentModel>> appointments,
    String? selectedView,
    String? selectedResource,
    bool? isLoading,
  }) {
    bool hasChanges = false;
    
    if (_selectedDay != selectedDay) {
      _selectedDay = selectedDay;
      hasChanges = true;
    }
    
    if (!_mapsEqual(_appointments, appointments)) {
      _appointments = Map.from(appointments);
      hasChanges = true;
    }
    
    if (selectedView != null && _selectedView != selectedView) {
      _selectedView = selectedView;
      hasChanges = true;
    }
    
    if (selectedResource != null && _selectedResource != selectedResource) {
      _selectedResource = selectedResource;
      hasChanges = true;
    }
    
    if (isLoading != null && _isLoading != isLoading) {
      _isLoading = isLoading;
      hasChanges = true;
    }
    
    if (hasChanges) {
      notifyListeners();
      debugPrint('🔄 GlobalCalendar: Sincronizado desde StateManager');
    }
  }
  
  // ========================================================================
  // 🎯 MÉTODOS HELPER PRIVADOS
  // ========================================================================
  
  /// 🔄 Convertir appointments para el sidebar
  Map<DateTime, List<dynamic>> _convertForSidebar() {
    final converted = <DateTime, List<dynamic>>{};
    _appointments.forEach((date, appointmentList) {
      converted[date] = appointmentList.cast<dynamic>();
    });
    return converted;
  }
  
  /// 🔍 Comparar mapas para detectar cambios
  bool _mapsEqual(Map<DateTime, List<AppointmentModel>> a, Map<DateTime, List<AppointmentModel>> b) {
    if (a.length != b.length) return false;
    
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key]!.length != b[key]!.length) return false;
      
      // Comparación simple por IDs
      final aIds = a[key]!.map((apt) => apt.id).toSet();
      final bIds = b[key]!.map((apt) => apt.id).toSet();
      if (!setEquals(aIds, bIds)) return false;
    }
    
    return true;
  }
  
  // ========================================================================
  // 🎯 MÉTODOS DE DEBUG Y DESARROLLO
  // ========================================================================
  
  /// 📊 Obtener estadísticas del estado actual
  Map<String, dynamic> getDebugInfo() {
    return {
      'selectedDay': _selectedDay.toIso8601String(),
      'appointmentDays': _appointments.length,
      'totalAppointments': _appointments.values.fold<int>(0, (sum, list) => sum + list.length),
      'selectedView': _selectedView,
      'selectedResource': _selectedResource,
      'isLoading': _isLoading,
    };
  }
  
  /// 📝 Log del estado actual
  void logCurrentState() {
    final info = getDebugInfo();
    debugPrint('🗓️ GlobalCalendar Estado Actual:');
    info.forEach((key, value) {
      debugPrint('   $key: $value');
    });
  }
}