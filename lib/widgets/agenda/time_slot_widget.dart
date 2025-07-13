// [time_slot_widget.dart] - CORRECCIÓN COMPLETA
// 📁 Ubicación: /lib/widgets/agenda/time_slot_widget.dart
// 🔧 SOLUCIONADO: Drag & Drop + Hover Effects + Click Menú

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/appointment_card_draggable.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/draggable_block_widget.dart'; // ✅ AGREGADO PARA DRAG & DROP DE BLOQUEOS
import 'package:agenda_fisio_spa_kym/widgets/agenda/slot_options_menu.dart';

class TimeSlotWidget extends StatefulWidget {
  final DateTime slotDateTime;
  final String resourceId;
  final String resourceName;
  final String resourceType;
  final List<AppointmentModel> appointments;
  final List<Map<String, dynamic>> bloqueos;
  final double width;
  final double height;
  final int intervalMinutes;
  final bool isWorkingHours;
  final bool isBlocked;
  final String? blockReason;
  final Function(AppointmentModel, DateTime, String?) onAppointmentMove;
  final Function(AppointmentModel) onAppointmentEdit;
  final Function(DateTime, String) onCreateAppointment;
  final Function(DateTime, String)? onCreateBlock;
  final Function(Map<String, dynamic>, DateTime, String?)? onBlockMove;
  final Function(Map<String, dynamic>)? onBlockEdit;
  final Function(Map<String, dynamic>)? onBlockDelete;
  final bool showTimeLabel;
  final bool isSelected;

  const TimeSlotWidget({
    super.key,
    required this.slotDateTime,
    required this.resourceId,
    required this.resourceName,
    required this.resourceType,
    required this.appointments,
    this.bloqueos = const [],
    this.width = 200.0,
    this.height = 60.0,
    this.intervalMinutes = 30,
    this.isWorkingHours = true,
    this.isBlocked = false,
    this.blockReason,
    required this.onAppointmentMove,
    required this.onAppointmentEdit,
    required this.onCreateAppointment,
    this.onCreateBlock,
    this.onBlockMove,
    this.onBlockEdit,
    this.onBlockDelete,
    this.showTimeLabel = false,
    this.isSelected = false,
  });

  @override
  State<TimeSlotWidget> createState() => _TimeSlotWidgetState();
}

class _TimeSlotWidgetState extends State<TimeSlotWidget>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _dropController;
  late AnimationController _pulseController;

  late Animation<double> _hoverAnimation;
  late Animation<double> _dropAnimation;
  late Animation<Color?> _backgroundAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;
  bool _isDragOver = false;
  bool _hasConflict = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );

    _dropController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dropAnimation = CurvedAnimation(
      parent: _dropController,
      curve: Curves.elasticOut,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(_hoverController);

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: kAccentBlue.withValues(alpha: 0.1),
    ).animate(_dropController);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _dropController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // 🔄 MANEJADORES DE EVENTOS DE MOUSE
  void _handleMouseEnter() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleMouseExit() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  // 🔄 MANEJADORES DE DRAG & DROP
  bool _handleWillAccept(Object? data) {
    if (data == null) return false;

    // 🚨 HOTFIX: Aceptar tanto AppointmentModel como Map
    if (data is AppointmentModel) return true;
    if (data is Map<String, dynamic>) {
      return data.containsKey('appointmentId') || data.containsKey('blockId');
    }

    return false;
  }

  void _handleAccept(Object data) {
    setState(() {
      _isDragOver = false;
      _hasConflict = false;
    });
    _dropController.reverse();
    _pulseController.stop();

    // 🚨 HOTFIX: Manejar ambos tipos de data
    if (data is AppointmentModel) {
      _handleAppointmentModelDrop(data);
    } else if (data is Map<String, dynamic>) {
      if (data.containsKey('appointmentId')) {
        _handleAppointmentDrop(data);
      } else if (data.containsKey('blockId')) {
        _handleBlockDrop(data);
      }
    }
  }

  void _handleDragMove(DragTargetDetails<Object> details) {
    if (!_isDragOver) {
      setState(() => _isDragOver = true);
      _dropController.forward();
      _pulseController.repeat(reverse: true);
    }
  }

  void _handleDragLeave() {
    setState(() {
      _isDragOver = false;
      _hasConflict = false;
    });
    _dropController.reverse();
    _pulseController.stop();
  }

  // 🔄 MANEJADORES ESPECÍFICOS
  void _handleAppointmentModelDrop(AppointmentModel appointment) {
    try {
      widget.onAppointmentMove(
          appointment, widget.slotDateTime, widget.resourceId);
      debugPrint(
          '✅ Appointment moved: ${appointment.id} to ${widget.slotDateTime}');
    } catch (e) {
      debugPrint('❌ Error moving appointment: $e');
    }
  }

  void _handleAppointmentDrop(Map<String, dynamic> data) {
    try {
      final appointment = AppointmentModel(
        id: data['appointmentId'] ?? data['id'] ?? '',
        clienteId: data['clienteId'],
        nombreCliente: data['nombreCliente'] ?? data['clienteNombre'],
        clientEmail: data['clientEmail'],
        clientPhone: data['clientPhone'],
        profesionalId: data['profesionalId'],
        profesionalNombre: data['profesionalNombre'],
        cabinaId: data['cabinaId'],
        cabinaNombre: data['cabinaNombre'],
        servicioId: data['servicioId'],
        servicioNombre: data['servicioNombre'],
        equipoId: data['equipoId'],
        equipoNombre: data['equipoNombre'],
        estado: data['estado'] ?? 'confirmada',
        comentarios: data['comentarios'] ?? data['notas'] ?? '',
        fechaInicio: data['fechaInicio'] != null
            ? (data['fechaInicio'] is DateTime
                ? data['fechaInicio']
                : DateTime.parse(data['fechaInicio']))
            : widget.slotDateTime,
        fechaFin: data['fechaFin'] != null
            ? (data['fechaFin'] is DateTime
                ? data['fechaFin']
                : DateTime.parse(data['fechaFin']))
            : widget.slotDateTime
                .add(Duration(minutes: widget.intervalMinutes)),
        duracion: data['duracion'] ?? widget.intervalMinutes,
      );

      widget.onAppointmentMove(
          appointment, widget.slotDateTime, widget.resourceId);
    } catch (e) {
      debugPrint('Error handling appointment drop: $e');
    }
  }

  void _handleBlockDrop(Map<String, dynamic> data) {
    try {
      widget.onBlockMove?.call(data, widget.slotDateTime, widget.resourceId);
    } catch (e) {
      debugPrint('Error handling block drop: $e');
    }
  }

  void _handleSlotTap() {
    HapticFeedback.selectionClick();

    if (widget.appointments.isNotEmpty) {
      widget.onAppointmentEdit(widget.appointments.first);
    } else if (widget.bloqueos.isNotEmpty) {
      widget.onBlockEdit?.call(widget.bloqueos.first);
    } else if (!widget.isBlocked) {
      // 🚨 HOTFIX: Mostrar menú de opciones para crear cita o bloqueo
      _showSlotOptionsMenu();
    }
  }

  void _handleSlotLongPress() {
    HapticFeedback.heavyImpact();

    if (!widget.isBlocked && widget.appointments.isEmpty) {
      widget.onCreateBlock?.call(widget.slotDateTime, widget.resourceId);
    }
  }

  // 🎭 MOSTRAR MENÚ DE OPCIONES
  void _showSlotOptionsMenu() {
    SlotOptionsMenu.show(
      context,
      timeSlot: widget.slotDateTime,
      resourceId: widget.resourceId,
      onCreateAppointment: (dateTime, resourceId) =>
          widget.onCreateAppointment(dateTime, resourceId),
      onCreateBlock: (startTime, endTime, resourceId) =>
          widget.onCreateBlock?.call(startTime, resourceId),
      intervalMinutes: widget.intervalMinutes,
    );
  }

  // 🎨 MÉTODOS DE ESTILO
  Color _getBackgroundColor() {
    if (_isDragOver) {
      return _backgroundAnimation.value ?? Colors.transparent;
    }

    if (widget.isBlocked) {
      return Colors.red.withValues(alpha: 0.1);
    }

    if (widget.appointments.isNotEmpty) {
      return kAccentGreen.withValues(alpha: 0.1);
    }

    if (!widget.isWorkingHours) {
      return Colors.grey.withValues(alpha: 0.05);
    }

    if (_isHovered) {
      return kBrandPurple.withValues(alpha: 0.08);
    }

    return Colors.transparent;
  }

  Color _getBorderColor() {
    if (_isDragOver) {
      return _hasConflict ? Colors.red : kAccentBlue;
    }

    if (widget.isSelected) {
      return kBrandPurple;
    }

    if (widget.appointments.isNotEmpty) {
      return kAccentGreen.withValues(alpha: 0.3);
    }

    if (_isHovered) {
      return kBrandPurple.withValues(alpha: 0.4);
    }

    return Colors.grey.withValues(alpha: 0.2);
  }

  double _getBorderWidth() {
    if (_isDragOver || widget.isSelected) {
      return 2.0;
    }
    if (_isHovered) {
      return 1.5;
    }
    return 1.0;
  }

  List<BoxShadow> _buildShadows() {
    if (_isHovered || _isDragOver) {
      return [
        BoxShadow(
          color: kBrandPurple.withValues(alpha: 0.15),
          blurRadius: _isHovered ? 12 : 8,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [];
  }

  // 🏗️ MÉTODOS DE CONSTRUCCIÓN DE WIDGETS
  Widget _buildTimeLabel() {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: kBrandPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          DateFormat('HH:mm').format(widget.slotDateTime),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: kBrandPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedIndicator() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, color: Colors.red.shade600, size: 20),
          const SizedBox(height: 4),
          if (widget.blockReason != null)
            Flexible(
              child: Text(
                widget.blockReason!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ MÉTODO CORREGIDO: AHORA USA DraggableBlockWidget PARA DRAG & DROP
  Widget _buildBloqueosStack() {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Stack(
          children: widget.bloqueos.asMap().entries.map((entry) {
            final index = entry.key;
            final bloqueo = entry.value;

            return Positioned(
              top: index * 2.0,
              left: index * 2.0,
              right: 0,
              bottom: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return DraggableBlockWidget(
                    blockData: bloqueo,
                    onMove: (block, newDateTime, newResourceId) {
                      widget.onBlockMove
                          ?.call(block, newDateTime, newResourceId);
                    },
                    onEdit: () {
                      widget.onBlockEdit?.call(bloqueo);
                    },
                    onDelete: () {
                      widget.onBlockDelete?.call(bloqueo);
                    },
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    isSelected: false,
                    isCompactMode: true, // Para vista de calendario
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentsStack() {
    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Stack(
          children: widget.appointments.asMap().entries.map((entry) {
            final index = entry.key;
            final appointment = entry.value;

            return Positioned(
              top: index * 2.0,
              left: index * 2.0,
              right: 0,
              bottom: 0,
              child: AppointmentCardDraggable(
                appointment: appointment,
                onEdit: () => widget.onAppointmentEdit(appointment),
                onMove: (appt, newDateTime, newResourceId) =>
                    widget.onAppointmentMove(appt, newDateTime, newResourceId),
                isSelected: widget.isSelected,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptySlotActions() {
    return AnimatedOpacity(
      opacity: _hoverAnimation.value,
      duration: const Duration(milliseconds: 200),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kBrandPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: kBrandPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, color: kBrandPurple, size: 16),
              const SizedBox(width: 6),
              Text(
                'Crear',
                style: TextStyle(
                  color: kBrandPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragOverIndicator() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: kAccentBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kAccentBlue, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.move_to_inbox, color: kAccentBlue, size: 20),
            const SizedBox(height: 2),
            Text(
              'Soltar aquí',
              style: TextStyle(
                color: kAccentBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictIndicator() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 20),
            const SizedBox(height: 2),
            Text(
              'Conflicto',
              style: TextStyle(
                color: Colors.red,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNonWorkingIndicator() {
    return Positioned(
      top: 2,
      right: 2,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(
          Icons.schedule,
          color: Colors.white,
          size: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleMouseEnter(),
      onExit: (_) => _handleMouseExit(),
      child: DragTarget<Object>(
        onWillAcceptWithDetails: (details) => _handleWillAccept(details.data),
        onAcceptWithDetails: (details) => _handleAccept(details.data),
        onMove: (details) => _handleDragMove(details),
        onLeave: (_) => _handleDragLeave(),
        builder: (context, candidateData, rejectedData) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              _hoverAnimation,
              _dropAnimation,
              _pulseAnimation,
              _scaleAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _isHovered && !_isDragOver
                    ? _scaleAnimation.value
                    : _isDragOver
                        ? _pulseAnimation.value
                        : 1.0,
                child: GestureDetector(
                  onTap: () => _handleSlotTap(),
                  onLongPress: () => _handleSlotLongPress(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final actualWidth = widget.width == double.infinity
                          ? constraints.maxWidth
                          : widget.width.clamp(0.0, constraints.maxWidth);

                      return Container(
                        width: actualWidth,
                        height: widget.height,
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                          minWidth: 0,
                          maxHeight: widget.height,
                          minHeight: widget.height,
                        ),
                        decoration: BoxDecoration(
                          color: _getBackgroundColor(),
                          border: Border.all(
                            color: _getBorderColor(),
                            width: _getBorderWidth(),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _buildShadows(),
                        ),
                        child: Stack(
                          children: [
                            if (widget.showTimeLabel) _buildTimeLabel(),
                            if (widget.isBlocked) _buildBlockedIndicator(),
                            if (widget.bloqueos.isNotEmpty)
                              _buildBloqueosStack(),
                            if (widget.appointments.isNotEmpty)
                              _buildAppointmentsStack(),
                            if (widget.appointments.isEmpty &&
                                widget.bloqueos.isEmpty &&
                                _isHovered &&
                                !widget.isBlocked)
                              _buildEmptySlotActions(),
                            if (_isDragOver) _buildDragOverIndicator(),
                            if (_hasConflict && _isDragOver)
                              _buildConflictIndicator(),
                            if (!widget.isWorkingHours)
                              _buildNonWorkingIndicator(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
