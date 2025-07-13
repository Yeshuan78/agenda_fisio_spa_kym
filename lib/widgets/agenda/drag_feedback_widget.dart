// [drag_feedback_widget.dart]
// 📁 Ubicación: /lib/widgets/agenda/drag_feedback_widget.dart
// 🎯 FEEDBACK VISUAL PREMIUM PARA DRAG & DROP

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class DragFeedbackWidget extends StatefulWidget {
  final AppointmentModel appointment;
  final DateTime? targetDateTime;
  final String? targetResourceId;
  final String? targetResourceName;
  final bool hasConflict;
  final List<String> conflictReasons;
  final double width;
  final double height;

  const DragFeedbackWidget({
    super.key,
    required this.appointment,
    this.targetDateTime,
    this.targetResourceId,
    this.targetResourceName,
    this.hasConflict = false,
    this.conflictReasons = const [],
    this.width = 200.0,
    this.height = 80.0,
  });

  @override
  State<DragFeedbackWidget> createState() => _DragFeedbackWidgetState();
}

class _DragFeedbackWidgetState extends State<DragFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _conflictController;
  late AnimationController _shimmerController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _conflictAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // ✅ PULSE ANIMATION (heartbeat del drag)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // ✅ CONFLICT ANIMATION (shake para errores)
    _conflictController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _conflictAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _conflictController,
      curve: Curves.elasticOut,
    ));

    // ✅ SHIMMER ANIMATION (validando posición)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
    _shimmerController.repeat();

    // ✅ TRIGGER CONFLICT ANIMATION SI HAY CONFLICTOS
    if (widget.hasConflict) {
      _conflictController.forward();
    }
  }

  @override
  void didUpdateWidget(DragFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasConflict != oldWidget.hasConflict) {
      if (widget.hasConflict) {
        _conflictController.forward();
      } else {
        _conflictController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _conflictController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.hasConflict) {
      return Colors.red.shade600;
    } else if (widget.targetDateTime != null) {
      return kAccentGreen;
    } else {
      return kBrandPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _conflictAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.translate(
            offset: widget.hasConflict
                ? Offset(
                    (math.sin(_conflictAnimation.value * math.pi * 8) * 3),
                    0,
                  )
                : Offset.zero,
            child: Material(
              elevation: 16,
              borderRadius: BorderRadius.circular(16),
              shadowColor: statusColor.withValues(alpha: 0.05),
              child: Container(
                width: widget.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      statusColor,
                      statusColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.03),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // ✅ SHIMMER EFFECT
                    if (!widget.hasConflict) _buildShimmerEffect(),

                    // ✅ CONTENIDO PRINCIPAL
                    _buildMainContent(),

                    // ✅ STATUS INDICATOR
                    _buildStatusIndicator(statusColor),

                    // ✅ TARGET INFO OVERLAY
                    if (widget.targetDateTime != null || widget.hasConflict)
                      _buildTargetInfoOverlay(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ✅ ANIMATED SHIMMER LINE
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned(
                  left: -widget.width +
                      (_shimmerAnimation.value * widget.width * 2),
                  top: 0,
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ CLIENTE Y HORA ACTUAL
          Row(
            children: [
              if (widget.appointment.fechaInicio != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(widget.appointment.fechaInicio!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.appointment.nombreCliente ?? 'Sin nombre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ✅ SERVICIO
          if (widget.appointment.servicio.isNotEmpty)
            Text(
              widget.appointment.servicio,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),

          // ✅ TARGET TIME (SI CAMBIA)
          if (widget.targetDateTime != null &&
              widget.targetDateTime != widget.appointment.fechaInicio) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white70,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(widget.targetDateTime!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.targetResourceName != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.targetResourceName!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Color statusColor) {
    IconData icon;
    String tooltip;

    if (widget.hasConflict) {
      icon = Icons.error;
      tooltip = 'Conflicto detectado';
    } else if (widget.targetDateTime != null) {
      icon = Icons.check_circle;
      tooltip = 'Posición válida';
    } else {
      icon = Icons.drag_indicator;
      tooltip = 'Arrastrando...';
    }

    return Positioned(
      top: 8,
      right: 8,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: statusColor,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInfoOverlay() {
    if (widget.hasConflict && widget.conflictReasons.isNotEmpty) {
      return _buildConflictOverlay();
    } else if (widget.targetDateTime != null) {
      return _buildSuccessOverlay();
    }
    return const SizedBox.shrink();
  }

  Widget _buildConflictOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade700.withValues(alpha: 0.09),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'Conflictos detectados:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...widget.conflictReasons.take(2).map((reason) => Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    '• $reason',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                )),
            if (widget.conflictReasons.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '• +${widget.conflictReasons.length - 2} más...',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: kAccentGreen.withValues(alpha: 0.09),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Mover a ${DateFormat('HH:mm - dd/MM').format(widget.targetDateTime!)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ IMPORT MATH PARA SHAKE ANIMATION
