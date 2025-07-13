// [weekly_calendar_view.dart] - VISTA SEMANAL CON TIMESLOTWIDGET COMPLETO
// 📁 Ubicación: /lib/widgets/agenda/weekly_calendar_view.dart
// 📅 WIDGET SEMANAL CON DRAG & DROP IGUAL AL DAILY VIEW
// ✅ USANDO TimeSlotWidget COMPLETO - FUNCIONALIDAD IDÉNTICA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/appointment_card_draggable.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/draggable_block_widget.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/calendar_time_column.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/interval_selector_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/time_slot_widget.dart'; // ✅ WIDGET COMPLETO

class WeeklyCalendarView extends StatefulWidget {
  final DateTime selectedDay;
  final Map<DateTime, List<AppointmentModel>> appointments;
  final Map<DateTime, List<Map<String, dynamic>>> bloqueos;
  final List<Map<String, dynamic>> resources;
  final Function(AppointmentModel, DateTime, String?) onAppointmentMove;
  final Function(AppointmentModel) onAppointmentEdit;
  final Function(DateTime, String?) onAppointmentCreate;
  final Function(DateTime, DateTime, String) onBlockCreate;
  final Function(String) onBlockEdit;
  final Function(String) onBlockDelete;
  final Function(int)? onIntervalChanged;
  final int timeSlotInterval;

  const WeeklyCalendarView({
    super.key,
    required this.selectedDay,
    required this.appointments,
    required this.bloqueos,
    required this.resources,
    required this.onAppointmentMove,
    required this.onAppointmentEdit,
    required this.onAppointmentCreate,
    required this.onBlockCreate,
    required this.onBlockEdit,
    required this.onBlockDelete,
    this.onIntervalChanged,
    this.timeSlotInterval = 60,
  });

  @override
  State<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends State<WeeklyCalendarView> {
  late ScrollController _mainScrollController;
  late ScrollController _timeScrollController;
  bool _isScrollingSynced = false;

  // 🎯 CONSTANTES OPTIMIZADAS
  static const double _timeSlotHeight = 85.0;
  static const double _timeColumnWidth = 120.0;
  static const int _workStartHour = 8;
  static const int _workEndHour = 18;
  static const int _calendarStartHour = 6;
  static const int _calendarEndHour = 22;

  final List<DateTime> _timeSlots = [];
  final List<DateTime> _weekDays = [];
  final List<int> _availableIntervals = [60, 30, 25, 20, 15, 10, 5];

  @override
  void initState() {
    super.initState();
    _initScrollControllers();
    _generateWeekData();
    _autoScrollTo8AM();
  }

  @override
  void didUpdateWidget(WeeklyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.timeSlotInterval != widget.timeSlotInterval ||
        _isDifferentWeek(oldWidget.selectedDay, widget.selectedDay)) {
      _generateWeekData();
    }
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _timeScrollController.dispose();
    super.dispose();
  }

  // 🔄 INICIALIZACIÓN DE CONTROLADORES SINCRONIZADOS
  void _initScrollControllers() {
    _mainScrollController = ScrollController();
    _timeScrollController = ScrollController();

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

  // 📅 GENERACIÓN DE DATOS DE LA SEMANA
  void _generateWeekData() {
    _generateTimeSlots();
    _generateWeekDays();
  }

  // ⏰ GENERACIÓN DE SLOTS DE TIEMPO CON DEBUG
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
  }

  // 📆 GENERACIÓN DE DÍAS DE LA SEMANA
  void _generateWeekDays() {
    _weekDays.clear();

    final startOfWeek = widget.selectedDay.subtract(
      Duration(days: widget.selectedDay.weekday - 1),
    );

    for (int i = 0; i < 7; i++) {
      _weekDays.add(startOfWeek.add(Duration(days: i)));
    }
  }

  // 📍 AUTO-SCROLL A LAS 8AM
  void _autoScrollTo8AM() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mainScrollController.hasClients &&
          _timeScrollController.hasClients) {
        final eightAMIndex = _timeSlots.indexWhere(
          (slot) => slot.hour == _workStartHour && slot.minute == 0,
        );

        if (eightAMIndex != -1) {
          final targetOffset = eightAMIndex * _timeSlotHeight;

          _mainScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  // 🎛️ MOSTRAR SELECTOR DE INTERVALO
  void _showIntervalSelector() {
    IntervalSelectorDialog.show(
      context,
      currentInterval: widget.timeSlotInterval,
      availableIntervals: _availableIntervals,
      onIntervalChanged: (interval) {
        if (widget.onIntervalChanged != null) {
          widget.onIntervalChanged!(interval);
        } else {}
      },
    );
  }

  // 🔍 HELPER METHODS
  bool _isDifferentWeek(DateTime date1, DateTime date2) {
    final week1Start = date1.subtract(Duration(days: date1.weekday - 1));
    final week2Start = date2.subtract(Duration(days: date2.weekday - 1));
    return !_isSameDay(week1Start, week2Start);
  }

  bool _isWorkingHours(DateTime timeSlot) {
    final hour = timeSlot.hour;
    return hour >= _workStartHour && hour <= _workEndHour;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekHeaderOptimized(),
        Expanded(
          child: Row(
            children: [
              _buildTimeColumnOptimized(),
              Expanded(child: _buildWeekGridOptimized()),
            ],
          ),
        ),
      ],
    );
  }

  // 📋 HEADER SEMANAL OPTIMIZADO
  Widget _buildWeekHeaderOptimized() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: _timeColumnWidth,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_view_week,
                        color: kBrandPurple, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Semanal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kBrandPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showIntervalSelector,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kBrandPurple.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kBrandPurple.withAlpha(60), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, color: kBrandPurple, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.timeSlotInterval}min',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kBrandPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._weekDays
              .map((day) => Expanded(child: _buildDayHeaderOptimized(day))),
        ],
      ),
    );
  }

  // 📅 HEADER DE DÍA OPTIMIZADO
  Widget _buildDayHeaderOptimized(DateTime day) {
    final isToday = _isSameDay(day, DateTime.now());
    final isSelected = _isSameDay(day, widget.selectedDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? kBrandPurple.withAlpha(25)
            : isToday
                ? kAccentGreen.withAlpha(13)
                : Colors.transparent,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('EEE', 'es').format(day).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? kBrandPurple
                  : isToday
                      ? kAccentGreen
                      : Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected
                  ? kBrandPurple
                  : isToday
                      ? kAccentGreen
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                DateFormat('d').format(day),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected || isToday ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🕐 COLUMNA DE TIEMPO OPTIMIZADA
  Widget _buildTimeColumnOptimized() {
    return CalendarTimeColumn(
      timeSlots: _timeSlots,
      controller: _timeScrollController,
      height: _timeSlotHeight,
      width: _timeColumnWidth,
      workStartHour: _workStartHour,
      workEndHour: _workEndHour,
    );
  }

  // 📅 GRID SEMANAL CON TIMESLOTWIDGET COMPLETO
  Widget _buildWeekGridOptimized() {
    return ListView.builder(
      controller: _mainScrollController,
      itemCount: _timeSlots.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, timeIndex) {
        final timeSlot = _timeSlots[timeIndex];
        return SizedBox(
          height: _timeSlotHeight,
          child: Row(
            children: _weekDays.map((day) {
              final cellDateTime = DateTime(
                day.year,
                day.month,
                day.day,
                timeSlot.hour,
                timeSlot.minute,
              );
              return Expanded(
                child: _buildTimeSlotCellForWeekly(cellDateTime, day),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // 🎯 CELDA DE SLOT CON TIMESLOTWIDGET COMPLETO (IGUAL QUE DAILY)
  Widget _buildTimeSlotCellForWeekly(DateTime cellDateTime, DateTime day) {
    final weeklyAppointments = _getWeeklyAppointments();
    final weeklyBlocks = _getWeeklyBlocks();

    final appointments = weeklyAppointments[cellDateTime] ?? [];
    final bloqueos = weeklyBlocks[cellDateTime] ?? [];
    final isBlocked = bloqueos.isNotEmpty;
    final isWorkingHours = _isWorkingHours(cellDateTime);

    if (appointments.isNotEmpty) {}
    if (bloqueos.isNotEmpty) {}

    // ✅ USAR TIMESLOTWIDGET COMPLETO - IGUAL QUE EN DAILY VIEW
    return TimeSlotWidget(
      slotDateTime: cellDateTime,
      resourceId: 'day_${day.day}_${day.month}_${day.year}',
      resourceName: DateFormat('EEE d', 'es').format(day),
      resourceType: 'day',
      appointments: appointments,
      bloqueos: bloqueos,
      width: double.infinity,
      height: _timeSlotHeight,
      intervalMinutes: widget.timeSlotInterval,
      isWorkingHours: isWorkingHours,
      isBlocked: isBlocked,
      blockReason: isBlocked ? bloqueos.first['motivo'] : null,
      onAppointmentMove: widget.onAppointmentMove,
      onAppointmentEdit: widget.onAppointmentEdit,
      onCreateAppointment: (dateTime, resourceId) =>
          widget.onAppointmentCreate(dateTime, null),
      onCreateBlock: (dateTime, resourceId) => widget.onBlockCreate(
        dateTime,
        dateTime.add(Duration(minutes: widget.timeSlotInterval)),
        'general',
      ),
      onBlockMove: _handleBlockMove,
      onBlockEdit: _handleBlockEdit,
      onBlockDelete: _handleBlockDelete,
      showTimeLabel: false,
      isSelected: false,
    );
  }

  // 📋 ADAPTAR CITAS PARA VISTA SEMANAL
  Map<DateTime, List<AppointmentModel>> _getWeeklyAppointments() {
    final weeklyAppointments = <DateTime, List<AppointmentModel>>{};

    for (final day in _weekDays) {
      final dayKey = DateTime(day.year, day.month, day.day);
      final dayAppointments = widget.appointments[dayKey] ?? [];

      for (final appointment in dayAppointments) {
        if (appointment.fechaInicio != null) {
          final appointmentHour = appointment.fechaInicio!.hour;
          final appointmentMinute = appointment.fechaInicio!.minute;

          final slotMinute = (appointmentMinute ~/ widget.timeSlotInterval) *
              widget.timeSlotInterval;

          final slotKey = DateTime(
            day.year,
            day.month,
            day.day,
            appointmentHour,
            slotMinute,
          );

          if (!weeklyAppointments.containsKey(slotKey)) {
            weeklyAppointments[slotKey] = [];
          }
          weeklyAppointments[slotKey]!.add(appointment);
        }
      }
    }

    return weeklyAppointments;
  }

  // 🚫 ADAPTAR BLOQUEOS PARA VISTA SEMANAL
  Map<DateTime, List<Map<String, dynamic>>> _getWeeklyBlocks() {
    final weeklyBlocks = <DateTime, List<Map<String, dynamic>>>{};

    for (final day in _weekDays) {
      final dayKey = DateTime(day.year, day.month, day.day);
      final dayBlocks = widget.bloqueos[dayKey] ?? [];

      for (final block in dayBlocks) {
        final startTime = block['horaInicio'] as String?;
        if (startTime != null && startTime.isNotEmpty) {
          try {
            final parts = startTime.split(':');
            final hour = int.parse(parts[0]);
            final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

            final slotMinute =
                (minute ~/ widget.timeSlotInterval) * widget.timeSlotInterval;

            final slotKey =
                DateTime(day.year, day.month, day.day, hour, slotMinute);

            if (!weeklyBlocks.containsKey(slotKey)) {
              weeklyBlocks[slotKey] = [];
            }
            weeklyBlocks[slotKey]!.add(block);
          } catch (e) {}
        }
      }
    }

    return weeklyBlocks;
  }

  // 🔄 MANEJADORES SIMPLIFICADOS PARA TIMESLOTWIDGET
  void _handleBlockMove(
      Map<String, dynamic> block, DateTime newDateTime, String? newResourceId) {
    widget.onBlockEdit(block['id'] ?? '');
  }

  void _handleBlockEdit(Map<String, dynamic> block) {
    widget.onBlockEdit(block['id'] ?? '');
  }

  void _handleBlockDelete(Map<String, dynamic> block) {
    widget.onBlockDelete(block['id'] ?? '');
  }
}
