// [appointment_card_draggable.dart] - VERSIÓN COMPLETA CON OVERFLOW CORREGIDO
// 📁 Ubicación: /lib/widgets/agenda/appointment_card_draggable.dart
// 🎯 CARD DE CITA DRAGGABLE PREMIUM CON LAYOUT OPTIMIZADO SIN OVERFLOW

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class AppointmentCardDraggable extends StatefulWidget {
  final AppointmentModel appointment;
  final Function(AppointmentModel, DateTime, String?) onMove;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final Function(AppointmentModel, int)? onDurationChange;
  final bool isSelected;
  final Function(AppointmentModel)? onSelectionChange;
  final double width;
  final double height;
  final bool isMultiSelectMode;
  final bool showResizeHandles;

  const AppointmentCardDraggable({
    super.key,
    required this.appointment,
    required this.onMove,
    required this.onEdit,
    this.onDelete,
    this.onDurationChange,
    this.isSelected = false,
    this.onSelectionChange,
    this.width = 180.0,
    this.height = 60.0,
    this.isMultiSelectMode = false,
    this.showResizeHandles = true,
  });

  @override
  State<AppointmentCardDraggable> createState() =>
      _AppointmentCardDraggableState();
}

class _AppointmentCardDraggableState extends State<AppointmentCardDraggable>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _selectController;
  late AnimationController _pulseController;

  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _pulseAnimation;

  bool _isHovered = false;
  bool _isDragging = false;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // ✅ HOVER ANIMATION
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ SELECTION ANIMATION
    _selectController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectController,
      curve: Curves.easeOutCubic,
    );

    // ✅ PULSE ANIMATION (para conflictos)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AppointmentCardDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectController.forward();
      } else {
        _selectController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _selectController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getAppointmentColor() {
    switch (widget.appointment.estado?.toLowerCase()) {
      case 'confirmado':
      case 'confirmada':
        return kAccentGreen;
      case 'reservado':
      case 'reservada':
      case 'pendiente':
        return Colors.orange.shade600;
      case 'cancelado':
      case 'cancelada':
        return Colors.red.shade600;
      case 'en camino':
        return kAccentBlue;
      case 'realizada':
      case 'completada':
        return kBrandPurple;
      default:
        return Colors.grey.shade600;
    }
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _pulseController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentColor = _getAppointmentColor();
    final startTime = widget.appointment.fechaInicio;
    final clientName = widget.appointment.nombreCliente ?? 'Sin nombre';
    final serviceName = widget.appointment.servicio;
    final professionalName = widget.appointment.nombreProfesional ?? '';

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: () => _handleTap(),
        child: Draggable<AppointmentModel>(
          data: widget.appointment,
          feedback: _buildDragFeedback(appointmentColor),
          childWhenDragging: _buildDragPlaceholder(),
          onDragStarted: () {
            setState(() => _isDragging = true);
            HapticFeedback.mediumImpact();
          },
          onDragEnd: (details) {
            setState(() => _isDragging = false);
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _elevationAnimation,
              _scaleAnimation,
              _selectionAnimation,
              _pulseAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value * _pulseAnimation.value,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appointmentColor,
                        appointmentColor.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: widget.isSelected
                        ? Border.all(
                            color: Colors.white,
                            width: 2,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: appointmentColor.withValues(alpha: 0.03),
                        blurRadius: _elevationAnimation.value * 2,
                        offset: Offset(0, _elevationAnimation.value),
                        spreadRadius: _elevationAnimation.value * 0.2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // ✅ CONTENIDO PRINCIPAL OPTIMIZADO
                        _buildMainContent(startTime, clientName, serviceName,
                            professionalName),

                        // ✅ SELECTION OVERLAY
                        if (widget.isSelected) _buildSelectionOverlay(),

                        // ✅ HOVER ACTIONS
                        if (_isHovered && !_isDragging) _buildHoverActions(),

                        // ✅ RESIZE HANDLES
                        if (widget.showResizeHandles && _isHovered)
                          _buildResizeHandles(),

                        // ✅ MULTI-SELECT INDICATOR
                        if (widget.isMultiSelectMode)
                          _buildMultiSelectIndicator(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO PRINCIPAL OPTIMIZADO PARA EVITAR OVERFLOW
  Widget _buildMainContent(DateTime? startTime, String clientName,
      String serviceName, String professionalName) {
    // ✅ DETECTAR SI ES UN CARD PEQUEÑO PARA CALENDARIO
    final isCompactMode = widget.height < 60;
    final isVeryCompact = widget.height < 50;

    return Padding(
      padding: EdgeInsets.all(isVeryCompact ? 4 : (isCompactMode ? 6 : 8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ PRIMERA FILA: HORA Y CLIENTE (SIEMPRE VISIBLE)
          Flexible(
            flex: isCompactMode ? 1 : 2,
            child: Row(
              children: [
                if (startTime != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isVeryCompact ? 3 : (isCompactMode ? 4 : 6),
                      vertical: isVeryCompact ? 1 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.025),
                      borderRadius:
                          BorderRadius.circular(isVeryCompact ? 3 : 4),
                    ),
                    child: Text(
                      DateFormat('HH:mm').format(startTime),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isVeryCompact ? 8 : (isCompactMode ? 9 : 10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: isVeryCompact ? 3 : (isCompactMode ? 4 : 6)),
                ],
                Expanded(
                  child: Text(
                    clientName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isVeryCompact ? 9 : (isCompactMode ? 10 : 12),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          // ✅ SEGUNDA FILA: SERVICIO (SOLO SI HAY ESPACIO)
          if (serviceName.isNotEmpty && !isVeryCompact)
            Flexible(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(top: isCompactMode ? 1 : 2),
                child: Text(
                  serviceName,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isCompactMode ? 8 : 9,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),

          // ✅ TERCERA FILA: PROFESIONAL (SOLO EN CARDS GRANDES)
          if (professionalName.isNotEmpty &&
              !isCompactMode &&
              !isVeryCompact &&
              widget.height > 65)
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  professionalName,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 8,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white
                .withValues(alpha: 0.02 * _selectionAnimation.value),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(_selectionAnimation.value),
              width: 2,
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: _selectionAnimation.value,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: kBrandPurple,
                  size: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHoverActions() {
    return Positioned(
      top: 4,
      right: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            Icons.edit,
            () => widget.onEdit(),
            'Editar',
          ),
          const SizedBox(width: 4),
          if (widget.onDelete != null)
            _buildActionButton(
              Icons.delete,
              () => widget.onDelete!(),
              'Eliminar',
              color: Colors.red.shade400,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, String tooltip,
      {Color? color}) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 12,
            color: color ?? Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandles() {
    if (widget.onDurationChange == null) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ TOP RESIZE HANDLE
        _buildResizeHandle(
          alignment: Alignment.topCenter,
          cursor: SystemMouseCursors.resizeUpDown,
          onPanUpdate: (details) => _handleTopResize(details),
        ),
        // ✅ BOTTOM RESIZE HANDLE
        _buildResizeHandle(
          alignment: Alignment.bottomCenter,
          cursor: SystemMouseCursors.resizeUpDown,
          onPanUpdate: (details) => _handleBottomResize(details),
        ),
      ],
    );
  }

  Widget _buildResizeHandle({
    required Alignment alignment,
    required SystemMouseCursor cursor,
    required Function(DragUpdateDetails) onPanUpdate,
  }) {
    return Align(
      alignment: alignment,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: (_) {
            setState(() => _isResizing = true);
            HapticFeedback.selectionClick();
          },
          onPanUpdate: onPanUpdate,
          onPanEnd: (_) => setState(() => _isResizing = false),
          child: Container(
            width: widget.width - 16,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectIndicator() {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.03),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: widget.isSelected
            ? const Icon(
                Icons.check,
                color: kBrandPurple,
                size: 12,
              )
            : null,
      ),
    );
  }

  Widget _buildDragFeedback(Color appointmentColor) {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appointmentColor,
              appointmentColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: appointmentColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildMainContent(
          widget.appointment.fechaInicio,
          widget.appointment.nombreCliente ?? 'Sin nombre',
          widget.appointment.servicio,
          widget.appointment.nombreProfesional ?? '',
        ),
      ),
    );
  }

  Widget _buildDragPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.05),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.drag_indicator,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  void _handleTap() {
    if (widget.isMultiSelectMode && widget.onSelectionChange != null) {
      widget.onSelectionChange!(widget.appointment);
      HapticFeedback.selectionClick();
    } else {
      widget.onEdit();
    }
  }

  void _handleTopResize(DragUpdateDetails details) {
    // TODO: Implementar lógica de resize por arriba
    // Cambiar hora de inicio manteniendo hora de fin
    if (widget.onDurationChange != null) {
      final deltaMinutes =
          (details.delta.dy / 2).round() * -15; // 15 min increments
      if (deltaMinutes != 0) {
        widget.onDurationChange!(widget.appointment, deltaMinutes);
      }
    }
  }

  void _handleBottomResize(DragUpdateDetails details) {
    // TODO: Implementar lógica de resize por abajo
    // Cambiar hora de fin manteniendo hora de inicio
    if (widget.onDurationChange != null) {
      final deltaMinutes =
          (details.delta.dy / 2).round() * 15; // 15 min increments
      if (deltaMinutes != 0) {
        widget.onDurationChange!(widget.appointment, deltaMinutes);
      }
    }
  }
}
