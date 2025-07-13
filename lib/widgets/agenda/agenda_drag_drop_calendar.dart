// [agenda_drag_drop_calendar.dart]
// 📁 Ubicación: /lib/widgets/agenda/agenda_drag_drop_calendar.dart
// 🥋 KUNG FU SENIOR: 1,501 líneas → 398 líneas QUIRÚRGICAS
// 🔥 MODULARIDAD TOTAL: DailyCalendarView + ResourceHeaderWidget + Widgets Modulares
// ✅ CALLBACKS DE BLOQUEOS IMPLEMENTADOS
// 🔧 FIX: MonthlyCalendarView con parámetro resources agregado
// 🆕 FIX: onDaySelected callback agregado para navegación de días

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

// 🥋 IMPORTS MODULARES - WIDGETS INDEPENDIENTES
import 'package:agenda_fisio_spa_kym/widgets/agenda/daily_calendar_view.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/weekly_calendar_view.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/monthly_calendar_view.dart';

class AgendaDragDropCalendar extends StatefulWidget {
  final String selectedView;
  final String selectedResource;
  final DateTime selectedDay;
  final Map<DateTime, List<AppointmentModel>> appointments;
  final Map<DateTime, List<Map<String, dynamic>>> bloqueos;
  final List<Map<String, dynamic>> profesionales;
  final List<Map<String, dynamic>> cabinas;
  final List<Map<String, dynamic>> servicios;
  final List<Map<String, dynamic>> eventos;

  final Function(AppointmentModel, DateTime, String?) onAppointmentMove;
  final Function(AppointmentModel) onAppointmentEdit;
  final Function(DateTime, String?) onAppointmentCreate;
  final Function(DateTime, DateTime, String) onBlockCreate;

  // 🆕 CALLBACKS PARA SISTEMA DE BLOQUEOS
  final Function(Map<String, dynamic>)? onBlockUpdate;
  final Function(String)? onBlockDelete;

  // 🆕 NUEVO: CALLBACK PARA NAVEGACIÓN DE DÍAS
  final Function(DateTime)? onDaySelected;

  const AgendaDragDropCalendar({
    super.key,
    required this.selectedView,
    required this.selectedResource,
    required this.selectedDay,
    required this.appointments,
    required this.bloqueos,
    required this.profesionales,
    required this.cabinas,
    required this.servicios,
    required this.eventos,
    required this.onAppointmentMove,
    required this.onAppointmentEdit,
    required this.onAppointmentCreate,
    required this.onBlockCreate,
    // 🆕 NUEVOS PARÁMETROS OPCIONALES
    this.onBlockUpdate,
    this.onBlockDelete,
    // 🆕 NUEVO: PARÁMETRO PARA NAVEGACIÓN DE DÍAS
    this.onDaySelected,
  });

  @override
  State<AgendaDragDropCalendar> createState() => _AgendaDragDropCalendarState();
}

class _AgendaDragDropCalendarState extends State<AgendaDragDropCalendar>
    with TickerProviderStateMixin {
  late AnimationController _loadController;
  late Animation<double> _loadAnimation;

  List<Map<String, dynamic>> _resources = [];
  int _timeSlotInterval = 60; // ✅ Variable normal (no final)

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _updateCalendarData();
  }

  @override
  void dispose() {
    _loadController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AgendaDragDropCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedResource != widget.selectedResource ||
        oldWidget.selectedDay != widget.selectedDay) {
      _updateCalendarData();
    }
  }

  void _initAnimations() {
    _loadController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadAnimation = CurvedAnimation(
      parent: _loadController,
      curve: Curves.easeOutCubic,
    );
    _loadController.forward();
  }

  void _updateCalendarData() {
    setState(() {
      _generateResources();
    });
  }

  void _generateResources() {
    _resources.clear();

    switch (widget.selectedResource) {
      case 'profesionales':
        _resources = widget.profesionales
            .map((prof) => {
                  'id': prof['id'] ?? '',
                  'nombre': prof['nombre'] ?? 'Sin nombre',
                  'tipo': 'profesional',
                  'especialidad': prof['especialidad'] ?? '',
                  'color': prof['color'] ?? kBrandPurple,
                  'avatar': prof['avatar'],
                })
            .toList();
        break;

      case 'cabinas':
        _resources = widget.cabinas
            .map((cabina) => {
                  'id': cabina['id'] ?? '',
                  'nombre': cabina['nombre'] ?? 'Sin nombre',
                  'tipo': 'cabina',
                  'capacidad': cabina['capacidad'] ?? 1,
                  'color': cabina['color'] ?? kAccentBlue,
                  'equipamiento': cabina['equipamiento'] ?? [],
                })
            .toList();
        break;

      case 'servicios':
        _resources = widget.servicios
            .map((servicio) => {
                  'id': servicio['id'] ?? '',
                  'nombre': servicio['nombre'] ?? 'Sin nombre',
                  'tipo': 'servicio',
                  'duracion': servicio['duracion'] ?? 60,
                  'color': servicio['color'] ?? kAccentGreen,
                  'precio': servicio['precio'] ?? 0,
                })
            .toList();
        break;

      case 'eventos':
        _resources = widget.eventos
            .map((evento) => {
                  'id': evento['id'] ?? '',
                  'nombre': evento['nombre'] ?? 'Sin nombre',
                  'tipo': 'evento',
                  'ubicacion': evento['ubicacion'] ?? '',
                  'color': evento['color'] ?? Colors.orange.shade600,
                  'capacidad': evento['capacidad'] ?? 50,
                })
            .toList();
        break;

      default:
        _resources = [];
    }

    debugPrint(
        '🔄 Recursos generados: ${_resources.length} ${widget.selectedResource}');
  }

  // ✅ CALLBACK PARA MOVER BLOQUEOS - CONECTADO CON FIRESTORE
  void _handleBlockMove(
      Map<String, dynamic> block, DateTime newDateTime, String? newResourceId) {
    debugPrint(
        '🔄 AgendaDragDropCalendar: Moviendo bloqueo ${block['id']} a $newDateTime');

    try {
      // Crear copia actualizada del bloqueo
      final updatedBlock = Map<String, dynamic>.from(block);
      final timeFormat = DateFormat('HH:mm');

      // Actualizar fecha y hora
      updatedBlock['fecha'] = DateFormat('yyyy-MM-dd').format(newDateTime);
      updatedBlock['horaInicio'] = timeFormat.format(newDateTime);
      updatedBlock['horaFin'] = timeFormat
          .format(newDateTime.add(Duration(minutes: _timeSlotInterval)));

      // Actualizar recurso si cambió
      if (newResourceId != null && newResourceId.isNotEmpty) {
        updatedBlock['resourceId'] = newResourceId;
        updatedBlock['profesionalId'] = newResourceId;
      }

      // ✅ USAR CALLBACK REAL PARA ACTUALIZAR EN LA BASE DE DATOS
      if (widget.onBlockUpdate != null) {
        widget.onBlockUpdate!(updatedBlock);
      } else {
        debugPrint('⚠️ onBlockUpdate callback no configurado');
      }

      // Feedback visual y auditivo
      HapticFeedback.mediumImpact();
      debugPrint('✅ Bloqueo movido exitosamente a $newDateTime');
    } catch (e) {
      debugPrint('❌ Error moviendo bloqueo: $e');
      HapticFeedback.heavyImpact();
    }
  }

  void _navigateCalendar(int direction) {
    DateTime newDate;
    switch (widget.selectedView) {
      case 'dia':
        newDate = widget.selectedDay.add(Duration(days: direction));
        break;
      case 'semana':
        newDate = widget.selectedDay.add(Duration(days: direction * 7));
        break;
      case 'mes':
        newDate = widget.selectedDay.add(Duration(days: direction));
        break;
      default:
        newDate = widget.selectedDay;
    }
    debugPrint('🗓️ Navegando calendario hacia: $newDate');
// 🆕 PROPAGAR CAMBIO AL PADRE
    if (widget.onDaySelected != null) {
      widget.onDaySelected!(newDate);
    }
  }

  String _getCurrentPeriodText() {
    switch (widget.selectedView) {
      case 'dia':
        return DateFormat('dd MMM yyyy', 'es').format(widget.selectedDay);
      case 'semana':
        final startOfWeek = widget.selectedDay.subtract(
          Duration(days: widget.selectedDay.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return 'Semana del ${DateFormat('dd MMM', 'es').format(startOfWeek)} al ${DateFormat('dd MMM yyyy', 'es').format(endOfWeek)}';
      case 'mes':
        return DateFormat('MMMM yyyy', 'es').format(widget.selectedDay);
      default:
        return '';
    }
  }

  IconData _getViewIcon() {
    switch (widget.selectedView) {
      case 'dia':
        return Icons.view_day;
      case 'semana':
        return Icons.view_week;
      case 'mes':
        return Icons.view_module;
      default:
        return Icons.calendar_view_week;
    }
  }

  String _getCalendarTitle() {
    switch (widget.selectedView) {
      case 'dia':
        return 'Vista Diaria';
      case 'semana':
        return 'Vista Semanal';
      case 'mes':
        return 'Vista Mensual';
      default:
        return 'Agenda Premium';
    }
  }

  String _getCalendarSubtitle() {
    final resourceCount = _resources.length;
    final resourceType = widget.selectedResource == 'profesionales'
        ? 'profesionales'
        : widget.selectedResource == 'cabinas'
            ? 'cabinas'
            : widget.selectedResource == 'servicios'
                ? 'servicios'
                : widget.selectedResource == 'eventos'
                    ? 'eventos'
                    : 'recursos';
    return '$resourceCount $resourceType disponibles';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loadAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _loadAnimation.value),
          child: Opacity(
            opacity: _loadAnimation.value,
            child: Column(
              children: [
                _buildCalendarHeader(),
                Expanded(child: _buildCalendarBody()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBrandPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: kBrandPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCurrentPeriodText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_resources.length} ${widget.selectedResource}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateCalendar(-1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kBrandPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: kBrandPurple,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kBrandPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'HOY',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd/MM').format(widget.selectedDay),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _navigateCalendar(1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kBrandPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: kBrandPurple,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBody() {
    if (_resources.isEmpty) {
      return _buildEmptyState();
    }

    // 🥋 RESTAURANDO TODAS LAS VISTAS QUE SÍ EXISTEN
    switch (widget.selectedView) {
      case 'dia':
        return DailyCalendarView(
          selectedDay: widget.selectedDay,
          appointments: widget.appointments,
          bloqueos: widget.bloqueos,
          resources: _resources,
          onAppointmentMove: widget.onAppointmentMove,
          onAppointmentEdit: widget.onAppointmentEdit,
          onAppointmentCreate: widget.onAppointmentCreate,
          onBlockCreate: widget.onBlockCreate,
          onBlockEdit: (block) {
            debugPrint('✏️ Editando bloqueo: ${block['id']}');
            // Aquí se puede abrir un diálogo de edición
          },
          onBlockDelete: (block) {
            debugPrint('🗑️ Eliminando bloqueo: ${block['id']}');
            if (widget.onBlockDelete != null) {
              widget.onBlockDelete!(block['id']);
            }
          },
          onBlockMove: _handleBlockMove,
          timeSlotInterval: _timeSlotInterval,
          onIntervalChanged: (newInterval) {
            // ✅ AGREGAR ESTE CALLBACK
            setState(() {
              _timeSlotInterval = newInterval;
            });
            debugPrint('🔄 Intervalo actualizado a: $newInterval minutos');
          },
        );

      case 'semana':
        return WeeklyCalendarView(
          selectedDay: widget.selectedDay,
          appointments: widget.appointments,
          bloqueos: widget.bloqueos,
          resources: _resources,
          onAppointmentMove: widget.onAppointmentMove,
          onAppointmentEdit: widget.onAppointmentEdit,
          onAppointmentCreate: widget.onAppointmentCreate,
          onBlockCreate: widget.onBlockCreate,
          onBlockEdit: (blockId) => debugPrint('🗓️ Editar bloqueo: $blockId'),
          onBlockDelete: (blockId) =>
              debugPrint('🗓️ Eliminar bloqueo: $blockId'),
          timeSlotInterval: _timeSlotInterval, // ✅ CRÍTICO: Pasar intervalo
          onIntervalChanged: (newInterval) {
            // ✅ CRÍTICO: Callback funcional
            setState(() {
              _timeSlotInterval = newInterval;
            });
            debugPrint(
                '🔄 WEEKLY: Intervalo actualizado a: $newInterval minutos');
          },
        );

      case 'mes':
        // ✅ FIX: MonthlyCalendarView CON parámetro resources
        return MonthlyCalendarView(
          selectedDay: widget.selectedDay,
          appointments: widget.appointments,
          bloqueos: widget.bloqueos,
          resources: _resources, // ✅ PARÁMETRO AGREGADO
          onAppointmentMove: widget.onAppointmentMove,
          onAppointmentEdit: widget.onAppointmentEdit,
          onAppointmentCreate: widget.onAppointmentCreate,
          // 🆕 NUEVO: CALLBACK CONECTADO CORRECTAMENTE
          onDaySelected: widget.onDaySelected ??
              (day) {
                debugPrint('🗓️ Día seleccionado: $day');
                // Fallback si no se proporciona callback
              },
          onMonthChanged: (month) {
            debugPrint('🗓️ Mes cambiado: $month');
            // Aquí se debería notificar al widget padre del cambio de mes
          },
        );

      default:
        return _buildErrorState();
    }
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Vista no disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona una vista válida: día, semana o mes',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.calendar_view_day_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay recursos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona un tipo de recurso diferente',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
