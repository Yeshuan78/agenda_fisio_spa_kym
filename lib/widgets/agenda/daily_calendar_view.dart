// [daily_calendar_view.dart]
// 📁 Ubicación: /lib/widgets/agenda/daily_calendar_view.dart
// 🎯 VISTA DIARIA REFACTORIZADA CON WIDGETS MODULARES - OPTIMIZADA
// ✅ DRAG & DROP IMPLEMENTADO: Citas y Bloqueos funcionando

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/resource_header_widget.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/calendar_time_column.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/calendar_main_grid.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/interval_selector_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/slot_options_menu.dart';

class DailyCalendarView extends StatefulWidget {
  final DateTime selectedDay;
  final Map<DateTime, List<AppointmentModel>> appointments;
  final Map<DateTime, List<Map<String, dynamic>>> bloqueos;
  final List<Map<String, dynamic>> resources;
  final Function(AppointmentModel, DateTime, String?) onAppointmentMove;
  final Function(AppointmentModel) onAppointmentEdit;
  final Function(DateTime, String?) onAppointmentCreate;
  final Function(DateTime, DateTime, String) onBlockCreate;
  final Function(Map<String, dynamic>)? onBlockEdit;
  final Function(Map<String, dynamic>)? onBlockDelete;
  final Function(Map<String, dynamic>, DateTime, String?)? onBlockMove;
  final Function(int)? onIntervalChanged; // ✅ AGREGADO CALLBACK
  final int timeSlotInterval;

  const DailyCalendarView({
    super.key,
    required this.selectedDay,
    required this.appointments,
    required this.bloqueos,
    required this.resources,
    required this.onAppointmentMove,
    required this.onAppointmentEdit,
    required this.onAppointmentCreate,
    required this.onBlockCreate,
    this.onBlockEdit,
    this.onBlockDelete,
    this.onBlockMove,
    this.onIntervalChanged, // ✅ AGREGADO CALLBACK
    this.timeSlotInterval = 60,
  });

  @override
  State<DailyCalendarView> createState() => _DailyCalendarViewState();
}

class _DailyCalendarViewState extends State<DailyCalendarView> {
  late ScrollController _mainScrollController;
  late ScrollController _timeScrollController;
  bool _isScrollingSynced = false;

  // 🎯 CONSTANTES OPTIMIZADAS
  static const double _timeSlotHeight = 85.0;
  static const double _timeColumnWidth = 140.0;
  static const int _workStartHour = 8;
  static const int _workEndHour = 18;
  static const int _calendarStartHour = 6;
  static const int _calendarEndHour = 22;

  final List<DateTime> _timeSlots = [];
  final List<int> _availableIntervals = [
    60,
    30,
    25,
    20,
    15,
    10,
    5
  ]; // ✅ NUEVOS INTERVALOS

  @override
  void initState() {
    super.initState();
    _initScrollControllers();
    _generateTimeSlots();
    _autoScrollTo8AM();
  }

  @override
  void didUpdateWidget(DailyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Regenerar slots si cambia el intervalo o el día
    if (oldWidget.timeSlotInterval != widget.timeSlotInterval ||
        oldWidget.selectedDay != widget.selectedDay) {
      _generateTimeSlots();
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _timeScrollController.dispose();
    super.dispose();
  }

  // 🔄 INICIALIZACIÓN DE CONTROLADORES DE SCROLL SINCRONIZADOS
  void _initScrollControllers() {
    _mainScrollController = ScrollController();
    _timeScrollController = ScrollController();

    // Sincronización bidireccional mejorada
    _mainScrollController.addListener(() {
      if (!_isScrollingSynced && _timeScrollController.hasClients) {
        _isScrollingSynced = true;
        _timeScrollController.jumpTo(_mainScrollController.offset);
        Future.microtask(() => _isScrollingSynced = false);
      }
    });

    _timeScrollController.addListener(() {
      if (!_isScrollingSynced && _mainScrollController.hasClients) {
        _isScrollingSynced = true;
        _mainScrollController.jumpTo(_timeScrollController.offset);
        Future.microtask(() => _isScrollingSynced = false);
      }
    });
  }

  // ⏰ GENERACIÓN OPTIMIZADA DE SLOTS DE TIEMPO
  void _generateTimeSlots() {
    _timeSlots.clear();

    for (int hour = _calendarStartHour; hour <= _calendarEndHour; hour++) {
      for (int minute = 0; minute < 60; minute += widget.timeSlotInterval) {
        _timeSlots.add(DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          widget.selectedDay.day,
          hour,
          minute,
        ));
      }
    }

    debugPrint(
        '📅 DailyCalendarView: Generados ${_timeSlots.length} slots de tiempo con intervalo ${widget.timeSlotInterval}min');
  }

  // 📍 AUTO-SCROLL MEJORADO A LAS 8AM
  void _autoScrollTo8AM() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mainScrollController.hasClients &&
          _timeScrollController.hasClients) {
        final eightAMIndex = _timeSlots.indexWhere(
          (slot) => slot.hour == _workStartHour && slot.minute == 0,
        );

        if (eightAMIndex != -1) {
          final targetOffset = eightAMIndex * _timeSlotHeight;

          // Scroll sincronizado
          _mainScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );

          debugPrint(
              '🎯 DailyCalendarView: Auto-scroll a las 8:00 AM (índice: $eightAMIndex)');
        }
      }
    });
  }

  // 🎛️ MOSTRAR SELECTOR DE INTERVALO - CALLBACK FUNCIONAL
  void _showIntervalSelector() {
    IntervalSelectorDialog.show(
      context,
      currentInterval: widget.timeSlotInterval,
      availableIntervals: _availableIntervals,
      onIntervalChanged: (interval) {
        debugPrint(
            '📊 DailyCalendarView: Cambiar intervalo a $interval minutos');

        // ✅ LLAMAR AL CALLBACK DEL PADRE PARA ACTUALIZAR EL ESTADO
        if (widget.onIntervalChanged != null) {
          widget.onIntervalChanged!(interval);
          debugPrint('✅ Callback enviado al padre: $interval minutos');
        } else {
          debugPrint('❌ onIntervalChanged callback no está configurado');
        }
      },
    );
  }

  // 📋 MOSTRAR MENÚ DE OPCIONES DEL SLOT
  void _showSlotOptionsMenu(DateTime timeSlot, String resourceId) {
    SlotOptionsMenu.show(
      context,
      timeSlot: timeSlot,
      resourceId: resourceId,
      onCreateAppointment: widget.onAppointmentCreate,
      onCreateBlock: widget.onBlockCreate,
      intervalMinutes: widget.timeSlotInterval,
    );
  }

  // ℹ️ MOSTRAR INFORMACIÓN DEL RECURSO
  void _showResourceInfo(Map<String, dynamic> resource) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: kBrandPurple),
            const SizedBox(width: 8),
            Text(resource['nombre'] ?? 'Recurso'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tipo', resource['tipo'] ?? 'N/A'),
            _buildInfoRow('ID', resource['id'] ?? 'N/A'),
            if (resource['especialidad'] != null)
              _buildInfoRow('Especialidad', resource['especialidad']),
            if (resource['capacidad'] != null)
              _buildInfoRow('Capacidad', resource['capacidad'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: kBrandPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // 🔄 MANEJADORES DE EVENTOS DE BLOQUEOS
  void _handleBlockMove(
      Map<String, dynamic> block, DateTime newDateTime, String? newResourceId) {
    debugPrint(
        '🔄 DailyCalendarView: Mover bloqueo ${block['id']} a $newDateTime en recurso $newResourceId');

    // ✅ SIEMPRE usar el callback de move específico
    if (widget.onBlockMove != null) {
      // Crear bloqueo actualizado
      final updatedBlock = Map<String, dynamic>.from(block);
      final timeFormat = DateFormat('HH:mm');
      updatedBlock['fecha'] = DateFormat('yyyy-MM-dd').format(newDateTime);
      updatedBlock['horaInicio'] = timeFormat.format(newDateTime);
      updatedBlock['horaFin'] = timeFormat
          .format(newDateTime.add(Duration(minutes: widget.timeSlotInterval)));

      if (newResourceId != null && newResourceId.isNotEmpty) {
        updatedBlock['profesionalId'] = newResourceId;
      }

      // ✅ LLAMAR AL CALLBACK CORRECTO
      widget.onBlockMove!(updatedBlock, newDateTime, newResourceId);
    } else {
      debugPrint('❌ onBlockMove callback no está configurado');
    }
  }

  void _handleBlockEdit(Map<String, dynamic> block) {
    debugPrint('✏️ DailyCalendarView: Editar bloqueo ${block['id']}');
    widget.onBlockEdit?.call(block);
  }

  void _handleBlockDelete(Map<String, dynamic> block) {
    debugPrint('🗑️ DailyCalendarView: Eliminar bloqueo ${block['id']}');
    widget.onBlockDelete?.call(block);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildResourcesHeaderFixed(),
        Expanded(
          child: Row(
            children: [
              // 🕐 COLUMNA DE TIEMPO MODULAR Y OPTIMIZADA
              _buildTimeColumnOptimized(),
              // 📅 GRID PRINCIPAL DE CITAS
              Expanded(
                child: _buildMainGridRobust(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 📋 HEADER FIJO DE RECURSOS MEJORADO - ÍCONO CLICKEABLE
  Widget _buildResourcesHeaderFixed() {
    return Container(
      height: 110, // ✅ ALTURA AUMENTADA
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Columna de tiempo - espacio para mantener alineación
          Container(
            width: _timeColumnWidth,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ ÍCONO CLICKEABLE PARA ABRIR SELECTOR DE INTERVALOS
                GestureDetector(
                  onTap: _showIntervalSelector, // ✅ CONECTADO AL MÉTODO
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kBrandPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kBrandPurple.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: kBrandPurple,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vista Diaria',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kBrandPurple,
                  ),
                ),
                Text(
                  '${widget.timeSlotInterval}min', // ✅ DINÁMICO: 60min, 30min, etc.
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Headers de recursos
          Expanded(
            child: Row(
              children: widget.resources.map((resource) {
                return Expanded(
                  child: ResourceHeaderWidget(
                    resourceId: resource['id'] ?? '',
                    resourceName: resource['nombre'] ?? '',
                    resourceType: resource['tipo'] ?? 'profesional',
                    status: 'activo',
                    width: double.infinity,
                    height: 90, // ✅ ALTURA AUMENTADA
                    onResourceTap: (id) => _showResourceInfo(resource),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 🕐 COLUMNA DE TIEMPO OPTIMIZADA CON WIDGET MODULAR
  Widget _buildTimeColumnOptimized() {
    return CalendarTimeColumn(
      timeSlots: _timeSlots, // Usar la lista completa generada
      controller: _timeScrollController,
      height: _timeSlotHeight,
      width: _timeColumnWidth,
      workStartHour: _workStartHour,
      workEndHour: _workEndHour,
    );
  }

  // 📅 GRID PRINCIPAL CON WIDGET MODULAR
  // ✅ DRAG & DROP DE BLOQUEOS YA INTEGRADO VÍA CalendarMainGrid → TimeSlotWidget → DraggableBlockWidget
  Widget _buildMainGridRobust() {
    return CalendarMainGrid(
      timeSlots: _timeSlots,
      resources: widget.resources,
      controller: _mainScrollController,
      appointments: widget.appointments,
      bloqueos: widget.bloqueos,
      timeSlotHeight: _timeSlotHeight,
      timeSlotInterval: widget.timeSlotInterval,
      workStartHour: _workStartHour,
      workEndHour: _workEndHour,
      onAppointmentMove: widget.onAppointmentMove,
      onAppointmentEdit: widget.onAppointmentEdit,
      onAppointmentCreate: widget.onAppointmentCreate,
      onBlockMove: _handleBlockMove,
      onBlockEdit: _handleBlockEdit,
      onBlockDelete: _handleBlockDelete,
    );
  }
}
