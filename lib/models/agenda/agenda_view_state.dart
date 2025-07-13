import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../appointment_model.dart';
import 'agenda_resource_model.dart';

/// 📊 ESTADO PRINCIPAL DE LA VISTA DE AGENDA
/// Maneja toda la configuración, filtros y estado de la UI
class AgendaViewState {
  // ✅ CONFIGURACIÓN DE VISTA
  final AgendaViewType viewType;
  final AgendaLayoutMode layoutMode;
  final DateTime selectedDate;
  final DateTime focusedDate;
  final int timeSlotInterval; // En minutos: 15, 30, 45, 60
  final TimeOfDay workDayStart;
  final TimeOfDay workDayEnd;

  // ✅ FILTROS ACTIVOS
  final AgendaFilters filters;
  final String searchQuery;
  final List<String> selectedResourceIds;
  final DateRange? dateRange;

  // ✅ SELECCIONES Y DRAG & DROP
  final Set<String> selectedAppointmentIds;
  final bool isMultiSelectMode;
  final DragDropState dragDropState;

  // ✅ CONFIGURACIONES DE USUARIO
  final AgendaUserPreferences userPreferences;
  final Map<String, dynamic> customSettings;

  // ✅ ESTADO DE CARGA Y ERRORES
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final DateTime? lastUpdated;

  AgendaViewState({
    this.viewType = AgendaViewType.week,
    this.layoutMode = AgendaLayoutMode.grid,
    DateTime? selectedDate,
    DateTime? focusedDate,
    this.timeSlotInterval = 30,
    this.workDayStart = const TimeOfDay(hour: 8, minute: 0),
    this.workDayEnd = const TimeOfDay(hour: 20, minute: 0),
    AgendaFilters? filters,
    this.searchQuery = '',
    this.selectedResourceIds = const [],
    this.dateRange,
    this.selectedAppointmentIds = const {},
    this.isMultiSelectMode = false,
    DragDropState? dragDropState,
    AgendaUserPreferences? userPreferences,
    this.customSettings = const {},
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastUpdated,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        focusedDate = focusedDate ?? DateTime.now(),
        filters = filters ?? AgendaFilters(),
        dragDropState = dragDropState ?? DragDropState(),
        userPreferences = userPreferences ?? AgendaUserPreferences();

  /// 🔄 COPYWIHT PARA IMMUTABILIDAD
  AgendaViewState copyWith({
    AgendaViewType? viewType,
    AgendaLayoutMode? layoutMode,
    DateTime? selectedDate,
    DateTime? focusedDate,
    int? timeSlotInterval,
    TimeOfDay? workDayStart,
    TimeOfDay? workDayEnd,
    AgendaFilters? filters,
    String? searchQuery,
    List<String>? selectedResourceIds,
    DateRange? dateRange,
    Set<String>? selectedAppointmentIds,
    bool? isMultiSelectMode,
    DragDropState? dragDropState,
    AgendaUserPreferences? userPreferences,
    Map<String, dynamic>? customSettings,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return AgendaViewState(
      viewType: viewType ?? this.viewType,
      layoutMode: layoutMode ?? this.layoutMode,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      timeSlotInterval: timeSlotInterval ?? this.timeSlotInterval,
      workDayStart: workDayStart ?? this.workDayStart,
      workDayEnd: workDayEnd ?? this.workDayEnd,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedResourceIds: selectedResourceIds ?? this.selectedResourceIds,
      dateRange: dateRange ?? this.dateRange,
      selectedAppointmentIds:
          selectedAppointmentIds ?? this.selectedAppointmentIds,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      dragDropState: dragDropState ?? this.dragDropState,
      userPreferences: userPreferences ?? this.userPreferences,
      customSettings: customSettings ?? this.customSettings,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// 📅 GETTERS DE CONVENIENCIA
  bool get hasActiveFilters =>
      filters.hasActiveFilters || searchQuery.isNotEmpty;

  bool get hasSelection =>
      selectedAppointmentIds.isNotEmpty || selectedResourceIds.isNotEmpty;

  bool get isDragging => dragDropState.isDragging;

  String get viewTypeDisplayName => viewType.displayName;

  String get selectedDateFormatted =>
      DateFormat('dd/MM/yyyy').format(selectedDate);

  DateRange get visibleDateRange {
    switch (viewType) {
      case AgendaViewType.day:
        return DateRange(selectedDate, selectedDate);
      case AgendaViewType.week:
        final startOfWeek =
            selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return DateRange(startOfWeek, endOfWeek);
      case AgendaViewType.month:
        final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
        final endOfMonth =
            DateTime(selectedDate.year, selectedDate.month + 1, 0);
        return DateRange(startOfMonth, endOfMonth);
    }
  }

  List<DateTime> get visibleDays {
    final range = visibleDateRange;
    final days = <DateTime>[];
    DateTime current = range.start;

    while (!current.isAfter(range.end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  /// 🎯 MÉTODOS DE NAVEGACIÓN
  AgendaViewState navigateToDate(DateTime date) {
    return copyWith(
      selectedDate: date,
      focusedDate: date,
    );
  }

  AgendaViewState navigatePrevious() {
    switch (viewType) {
      case AgendaViewType.day:
        return navigateToDate(selectedDate.subtract(const Duration(days: 1)));
      case AgendaViewType.week:
        return navigateToDate(selectedDate.subtract(const Duration(days: 7)));
      case AgendaViewType.month:
        return navigateToDate(DateTime(
            selectedDate.year, selectedDate.month - 1, selectedDate.day));
    }
  }

  AgendaViewState navigateNext() {
    switch (viewType) {
      case AgendaViewType.day:
        return navigateToDate(selectedDate.add(const Duration(days: 1)));
      case AgendaViewType.week:
        return navigateToDate(selectedDate.add(const Duration(days: 7)));
      case AgendaViewType.month:
        return navigateToDate(DateTime(
            selectedDate.year, selectedDate.month + 1, selectedDate.day));
    }
  }

  AgendaViewState navigateToToday() {
    final today = DateTime.now();
    return navigateToDate(DateTime(today.year, today.month, today.day));
  }

  /// 🔍 MÉTODOS DE FILTROS
  AgendaViewState updateSearch(String query) {
    return copyWith(searchQuery: query);
  }

  AgendaViewState updateFilters(AgendaFilters newFilters) {
    return copyWith(filters: newFilters);
  }

  AgendaViewState toggleResourceSelection(String resourceId) {
    final newSelection = List<String>.from(selectedResourceIds);
    if (newSelection.contains(resourceId)) {
      newSelection.remove(resourceId);
    } else {
      newSelection.add(resourceId);
    }
    return copyWith(selectedResourceIds: newSelection);
  }

  AgendaViewState clearFilters() {
    return copyWith(
      filters: AgendaFilters(),
      searchQuery: '',
      selectedResourceIds: [],
    );
  }

  /// 🎯 MÉTODOS DE SELECCIÓN
  AgendaViewState toggleAppointmentSelection(String appointmentId) {
    final newSelection = Set<String>.from(selectedAppointmentIds);
    if (newSelection.contains(appointmentId)) {
      newSelection.remove(appointmentId);
    } else {
      newSelection.add(appointmentId);
    }
    return copyWith(selectedAppointmentIds: newSelection);
  }

  AgendaViewState selectAllVisibleAppointments(
      List<AppointmentModel> appointments) {
    final visibleIds = appointments.map((a) => a.id).toSet();
    return copyWith(selectedAppointmentIds: visibleIds);
  }

  AgendaViewState clearSelection() {
    return copyWith(
      selectedAppointmentIds: const {},
      isMultiSelectMode: false,
    );
  }

  AgendaViewState toggleMultiSelectMode() {
    return copyWith(
      isMultiSelectMode: !isMultiSelectMode,
      selectedAppointmentIds:
          isMultiSelectMode ? const {} : selectedAppointmentIds,
    );
  }

  /// 🎨 MÉTODOS DE VISTA
  AgendaViewState changeViewType(AgendaViewType newType) {
    return copyWith(viewType: newType);
  }

  AgendaViewState changeLayoutMode(AgendaLayoutMode newMode) {
    return copyWith(layoutMode: newMode);
  }

  AgendaViewState changeTimeInterval(int intervalMinutes) {
    return copyWith(timeSlotInterval: intervalMinutes);
  }

  /// 🚚 MÉTODOS DE DRAG & DROP
  AgendaViewState startDragging(AppointmentModel appointment) {
    return copyWith(
      dragDropState: dragDropState.startDragging(appointment),
    );
  }

  AgendaViewState updateDragPosition(Offset position) {
    return copyWith(
      dragDropState: dragDropState.updatePosition(position),
    );
  }

  AgendaViewState updateDragTarget({
    DateTime? targetDateTime,
    String? targetResourceId,
    bool hasConflict = false,
    List<String> conflictReasons = const [],
  }) {
    return copyWith(
      dragDropState: dragDropState.updateTarget(
        targetDateTime: targetDateTime,
        targetResourceId: targetResourceId,
        hasConflict: hasConflict,
        conflictReasons: conflictReasons,
      ),
    );
  }

  AgendaViewState endDragging() {
    return copyWith(
      dragDropState: DragDropState(),
    );
  }

  /// 🔄 MÉTODOS DE ESTADO
  AgendaViewState setLoading(bool loading) {
    return copyWith(isLoading: loading, clearError: loading);
  }

  AgendaViewState setRefreshing(bool refreshing) {
    return copyWith(isRefreshing: refreshing);
  }

  AgendaViewState setError(String error) {
    return copyWith(errorMessage: error, isLoading: false, isRefreshing: false);
  }

  AgendaViewState setUpdated() {
    return copyWith(lastUpdated: DateTime.now(), clearError: true);
  }

  /// 💾 MÉTODOS DE PERSISTENCIA
  Map<String, dynamic> toJson() {
    return {
      'viewType': viewType.name,
      'layoutMode': layoutMode.name,
      'timeSlotInterval': timeSlotInterval,
      'workDayStart': {
        'hour': workDayStart.hour,
        'minute': workDayStart.minute
      },
      'workDayEnd': {'hour': workDayEnd.hour, 'minute': workDayEnd.minute},
      'filters': filters.toJson(),
      'userPreferences': userPreferences.toJson(),
      'customSettings': customSettings,
    };
  }

  factory AgendaViewState.fromJson(Map<String, dynamic> json) {
    return AgendaViewState(
      viewType: AgendaViewType.values.firstWhere(
        (e) => e.name == json['viewType'],
        orElse: () => AgendaViewType.week,
      ),
      layoutMode: AgendaLayoutMode.values.firstWhere(
        (e) => e.name == json['layoutMode'],
        orElse: () => AgendaLayoutMode.grid,
      ),
      timeSlotInterval: json['timeSlotInterval'] ?? 30,
      workDayStart: json['workDayStart'] != null
          ? TimeOfDay(
              hour: json['workDayStart']['hour'] ?? 8,
              minute: json['workDayStart']['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 8, minute: 0),
      workDayEnd: json['workDayEnd'] != null
          ? TimeOfDay(
              hour: json['workDayEnd']['hour'] ?? 20,
              minute: json['workDayEnd']['minute'] ?? 0,
            )
          : const TimeOfDay(hour: 20, minute: 0),
      filters: json['filters'] != null
          ? AgendaFilters.fromJson(json['filters'])
          : AgendaFilters(),
      userPreferences: json['userPreferences'] != null
          ? AgendaUserPreferences.fromJson(json['userPreferences'])
          : AgendaUserPreferences(),
      customSettings: json['customSettings'] ?? {},
    );
  }
}

/// 🔍 FILTROS DE AGENDA
class AgendaFilters {
  final List<ResourceType> resourceTypes;
  final List<ResourceStatus> resourceStatuses;
  final List<String> appointmentStatuses;
  final List<String> especialidades;
  final List<String> servicios;
  final bool showPastAppointments;
  final bool showCancelledAppointments;
  final bool showBlockedSlots;
  final DateRange? customDateRange;

  AgendaFilters({
    this.resourceTypes = const [],
    this.resourceStatuses = const [],
    this.appointmentStatuses = const [],
    this.especialidades = const [],
    this.servicios = const [],
    this.showPastAppointments = false,
    this.showCancelledAppointments = false,
    this.showBlockedSlots = true,
    this.customDateRange,
  });

  bool get hasActiveFilters {
    return resourceTypes.isNotEmpty ||
        resourceStatuses.isNotEmpty ||
        appointmentStatuses.isNotEmpty ||
        especialidades.isNotEmpty ||
        servicios.isNotEmpty ||
        !showPastAppointments ||
        !showCancelledAppointments ||
        customDateRange != null;
  }

  AgendaFilters copyWith({
    List<ResourceType>? resourceTypes,
    List<ResourceStatus>? resourceStatuses,
    List<String>? appointmentStatuses,
    List<String>? especialidades,
    List<String>? servicios,
    bool? showPastAppointments,
    bool? showCancelledAppointments,
    bool? showBlockedSlots,
    DateRange? customDateRange,
  }) {
    return AgendaFilters(
      resourceTypes: resourceTypes ?? this.resourceTypes,
      resourceStatuses: resourceStatuses ?? this.resourceStatuses,
      appointmentStatuses: appointmentStatuses ?? this.appointmentStatuses,
      especialidades: especialidades ?? this.especialidades,
      servicios: servicios ?? this.servicios,
      showPastAppointments: showPastAppointments ?? this.showPastAppointments,
      showCancelledAppointments:
          showCancelledAppointments ?? this.showCancelledAppointments,
      showBlockedSlots: showBlockedSlots ?? this.showBlockedSlots,
      customDateRange: customDateRange ?? this.customDateRange,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceTypes': resourceTypes.map((e) => e.name).toList(),
      'resourceStatuses': resourceStatuses.map((e) => e.name).toList(),
      'appointmentStatuses': appointmentStatuses,
      'especialidades': especialidades,
      'servicios': servicios,
      'showPastAppointments': showPastAppointments,
      'showCancelledAppointments': showCancelledAppointments,
      'showBlockedSlots': showBlockedSlots,
    };
  }

  factory AgendaFilters.fromJson(Map<String, dynamic> json) {
    return AgendaFilters(
      resourceTypes: (json['resourceTypes'] as List<dynamic>?)
              ?.map((e) => ResourceType.values.firstWhere((v) => v.name == e))
              .toList() ??
          [],
      resourceStatuses: (json['resourceStatuses'] as List<dynamic>?)
              ?.map((e) => ResourceStatus.values.firstWhere((v) => v.name == e))
              .toList() ??
          [],
      appointmentStatuses: List<String>.from(json['appointmentStatuses'] ?? []),
      especialidades: List<String>.from(json['especialidades'] ?? []),
      servicios: List<String>.from(json['servicios'] ?? []),
      showPastAppointments: json['showPastAppointments'] ?? false,
      showCancelledAppointments: json['showCancelledAppointments'] ?? false,
      showBlockedSlots: json['showBlockedSlots'] ?? true,
    );
  }
}

/// 🚚 ESTADO DE DRAG & DROP
class DragDropState {
  final bool isDragging;
  final AppointmentModel? draggedAppointment;
  final Offset? currentPosition;
  final DateTime? targetDateTime;
  final String? targetResourceId;
  final bool hasConflict;
  final List<String> conflictReasons;

  DragDropState({
    this.isDragging = false,
    this.draggedAppointment,
    this.currentPosition,
    this.targetDateTime,
    this.targetResourceId,
    this.hasConflict = false,
    this.conflictReasons = const [],
  });

  DragDropState startDragging(AppointmentModel appointment) {
    return DragDropState(
      isDragging: true,
      draggedAppointment: appointment,
    );
  }

  DragDropState updatePosition(Offset position) {
    return DragDropState(
      isDragging: isDragging,
      draggedAppointment: draggedAppointment,
      currentPosition: position,
      targetDateTime: targetDateTime,
      targetResourceId: targetResourceId,
      hasConflict: hasConflict,
      conflictReasons: conflictReasons,
    );
  }

  DragDropState updateTarget({
    DateTime? targetDateTime,
    String? targetResourceId,
    bool hasConflict = false,
    List<String> conflictReasons = const [],
  }) {
    return DragDropState(
      isDragging: isDragging,
      draggedAppointment: draggedAppointment,
      currentPosition: currentPosition,
      targetDateTime: targetDateTime,
      targetResourceId: targetResourceId,
      hasConflict: hasConflict,
      conflictReasons: conflictReasons,
    );
  }
}

/// ⚙️ PREFERENCIAS DEL USUARIO
class AgendaUserPreferences {
  final String defaultView; // 'day', 'week', 'month'
  final int defaultTimeInterval;
  final bool showWeekends;
  final bool showResourcePhotos;
  final bool enableSounds;
  final bool autoRefresh;
  final int autoRefreshInterval; // En segundos
  final String dateFormat; // 'dd/MM/yyyy', 'MM/dd/yyyy', etc.
  final String timeFormat; // '24h', '12h'
  final String theme; // 'light', 'dark', 'auto'

  AgendaUserPreferences({
    this.defaultView = 'week',
    this.defaultTimeInterval = 30,
    this.showWeekends = true,
    this.showResourcePhotos = true,
    this.enableSounds = false,
    this.autoRefresh = true,
    this.autoRefreshInterval = 300, // 5 minutos
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = '24h',
    this.theme = 'auto',
  });

  AgendaUserPreferences copyWith({
    String? defaultView,
    int? defaultTimeInterval,
    bool? showWeekends,
    bool? showResourcePhotos,
    bool? enableSounds,
    bool? autoRefresh,
    int? autoRefreshInterval,
    String? dateFormat,
    String? timeFormat,
    String? theme,
  }) {
    return AgendaUserPreferences(
      defaultView: defaultView ?? this.defaultView,
      defaultTimeInterval: defaultTimeInterval ?? this.defaultTimeInterval,
      showWeekends: showWeekends ?? this.showWeekends,
      showResourcePhotos: showResourcePhotos ?? this.showResourcePhotos,
      enableSounds: enableSounds ?? this.enableSounds,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      autoRefreshInterval: autoRefreshInterval ?? this.autoRefreshInterval,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultView': defaultView,
      'defaultTimeInterval': defaultTimeInterval,
      'showWeekends': showWeekends,
      'showResourcePhotos': showResourcePhotos,
      'enableSounds': enableSounds,
      'autoRefresh': autoRefresh,
      'autoRefreshInterval': autoRefreshInterval,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'theme': theme,
    };
  }

  factory AgendaUserPreferences.fromJson(Map<String, dynamic> json) {
    return AgendaUserPreferences(
      defaultView: json['defaultView'] ?? 'week',
      defaultTimeInterval: json['defaultTimeInterval'] ?? 30,
      showWeekends: json['showWeekends'] ?? true,
      showResourcePhotos: json['showResourcePhotos'] ?? true,
      enableSounds: json['enableSounds'] ?? false,
      autoRefresh: json['autoRefresh'] ?? true,
      autoRefreshInterval: json['autoRefreshInterval'] ?? 300,
      dateFormat: json['dateFormat'] ?? 'dd/MM/yyyy',
      timeFormat: json['timeFormat'] ?? '24h',
      theme: json['theme'] ?? 'auto',
    );
  }
}

/// 📅 RANGO DE FECHAS
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  Duration get duration => end.difference(start);

  int get days => duration.inDays + 1;

  List<DateTime> get dates {
    final dates = <DateTime>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  String toString() {
    return '${DateFormat('dd/MM/yyyy').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';
  }
}

/// 📋 ENUMS
enum AgendaViewType {
  day('Día'),
  week('Semana'),
  month('Mes');

  const AgendaViewType(this.displayName);
  final String displayName;
}

enum AgendaLayoutMode {
  grid('Cuadrícula'),
  list('Lista'),
  timeline('Timeline');

  const AgendaLayoutMode(this.displayName);
  final String displayName;
}
