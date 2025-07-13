// [draggable_block_widget.dart] - VERSIÓN COMPLETA CORREGIDA
// 📁 Ubicación: /lib/widgets/agenda/draggable_block_widget.dart
// 🔧 CORRECCIONES: Métodos completos + Validación + Optimización + Integración calendario

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class DraggableBlockWidget extends StatefulWidget {
  final Map<String, dynamic> blockData;
  final Function(Map<String, dynamic>, DateTime, String?) onMove;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double width;
  final double height;
  final bool isSelected;
  final Function(Map<String, dynamic>)? onSelectionChange;
  final bool isCompactMode; // ✅ NUEVO: Soporte responsivo

  const DraggableBlockWidget({
    super.key,
    required this.blockData,
    required this.onMove,
    required this.onEdit,
    required this.onDelete,
    this.width = 180.0,
    this.height = 60.0,
    this.isSelected = false,
    this.onSelectionChange,
    this.isCompactMode = false, // ✅ NUEVO
  });

  @override
  State<DraggableBlockWidget> createState() => _DraggableBlockWidgetState();
}

class _DraggableBlockWidgetState extends State<DraggableBlockWidget>
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

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // ✅ HOVER ANIMATION - Optimizada
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150), // Optimizado: 200ms → 150ms
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 6.0, // Optimizado: 8.0 → 6.0
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01, // Optimizado: 1.02 → 1.01
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ SELECTION ANIMATION - Más rápida
    _selectController = AnimationController(
      duration: const Duration(milliseconds: 100), // Optimizado: 150ms → 100ms
      vsync: this,
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectController,
      curve: Curves.easeOutCubic,
    );

    // ✅ PULSE ANIMATION - Más sutil
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800), // Optimizado: 1000ms → 800ms
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Optimizado: 1.1 → 1.05
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DraggableBlockWidget oldWidget) {
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

  Color _getBlockColor() {
    final tipo = widget.blockData['tipo']?.toString().toLowerCase();
    switch (tipo) {
      case 'mantenimiento':
        return Colors.orange.shade600;
      case 'almuerzo':
        return kAccentGreen;
      case 'reunion':
        return kAccentBlue;
      case 'capacitacion':
        return kBrandPurple;
      case 'personal':
        return Colors.grey.shade600;
      case 'emergencia':
        return Colors.red.shade600;
      default:
        return Colors.red.shade500;
    }
  }

  IconData _getBlockIcon() {
    final tipo = widget.blockData['tipo']?.toString().toLowerCase();
    switch (tipo) {
      case 'mantenimiento':
        return Icons.build_circle_outlined;
      case 'almuerzo':
        return Icons.restaurant_outlined;
      case 'reunion':
        return Icons.meeting_room_outlined;
      case 'capacitacion':
        return Icons.school_outlined;
      case 'personal':
        return Icons.person_outline;
      case 'emergencia':
        return Icons.emergency_outlined;
      default:
        return Icons.block;
    }
  }

  // ✅ NUEVO: Obtener color basado en estado
  Color _getStateColor(Color blockColor) {
    if (_isDragging) return blockColor.withValues(alpha: 0.07);
    if (_isHovered) return blockColor;
    return blockColor.withValues(alpha: 0.095);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ VALIDACIÓN DE DATOS
    if (widget.blockData.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Error: Datos inválidos',
            style: TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final blockColor = _getBlockColor();
    final stateColor = _getStateColor(blockColor);
    final motivo = widget.blockData['motivo'] ?? 'Bloqueo';
    final horaInicio = widget.blockData['horaInicio'] ?? '';
    final horaFin = widget.blockData['horaFin'] ?? '';
    final tipo = widget.blockData['tipo'] ?? 'manual';

    // ✅ SOPORTE RESPONSIVO
    final effectiveHeight =
        widget.isCompactMode ? widget.height * 0.8 : widget.height;

    return Semantics(
      label: 'Bloqueo: $motivo de $horaInicio a $horaFin',
      hint: 'Toca para editar, arrastra para mover',
      child: MouseRegion(
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
          child: Draggable<Map<String, dynamic>>(
            data: widget.blockData,
            feedback: _buildDragFeedback(blockColor),
            childWhenDragging: _buildDragPlaceholder(),
            onDragStarted: () {
              setState(() => _isDragging = true);
              HapticFeedback.mediumImpact();
            },
            onDragEnd: (details) {
              setState(() => _isDragging = false);

              // ✅ FEEDBACK MEJORADO PARA INTEGRACIÓN CON CALENDARIO
              if (details.wasAccepted) {
                // El drop fue exitoso
                HapticFeedback.lightImpact();
              } else {
                // El drop falló
                HapticFeedback.heavyImpact();
              }
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
                    height: effectiveHeight,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: stateColor,
                      borderRadius: BorderRadius.circular(12),
                      border: widget.isSelected
                          ? Border.all(
                              color: Colors.white,
                              width: 2.5,
                            )
                          : Border.all(
                              color: blockColor.withValues(alpha: 0.03),
                              width: 1,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: blockColor.withValues(alpha: 0.04),
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
                          // ✅ PATRÓN DE FONDO DIAGONAL
                          _buildDiagonalPattern(blockColor),

                          // ✅ CONTENIDO PRINCIPAL
                          _buildMainContent(motivo, horaInicio, horaFin, tipo),

                          // ✅ SELECTION OVERLAY
                          if (widget.isSelected) _buildSelectionOverlay(),

                          // ✅ HOVER ACTIONS
                          if (_isHovered && !_isDragging) _buildHoverActions(),

                          // ✅ TIPO BADGE
                          _buildTipoBadge(tipo),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagonalPattern(Color blockColor) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _DiagonalPatternPainter(
        color: Colors.white.withValues(alpha: 0.01),
      ),
    );
  }

  // ✅ MÉTODO COMPLETO IMPLEMENTADO
  Widget _buildMainContent(
      String motivo, String horaInicio, String horaFin, String tipo) {
    final blockIcon = _getBlockIcon();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                blockIcon,
                color: Colors.white,
                size: widget.isCompactMode ? 12 : 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  motivo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isCompactMode ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (horaInicio.isNotEmpty && horaFin.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '$horaInicio - $horaFin',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.isCompactMode ? 8 : 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ MÉTODO COMPLETO IMPLEMENTADO
  Widget _buildSelectionOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  // ✅ MÉTODO COMPLETO IMPLEMENTADO
  Widget _buildHoverActions() {
    return Positioned(
      top: 4,
      right: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            Icons.edit,
            widget.onEdit,
            'Editar',
            Colors.white,
          ),
          _buildActionButton(
            Icons.delete,
            () => _showDeleteConfirmation(),
            'Eliminar',
            Colors.red.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap,
    String tooltip,
    Color color,
  ) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: () {
          onTap();
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.01),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 12,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTipoBadge(String tipo) {
    return Positioned(
      bottom: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tipo.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDragFeedback(Color blockColor) {
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: blockColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildDiagonalPattern(blockColor),
            _buildMainContent(
              widget.blockData['motivo'] ?? 'Bloqueo',
              widget.blockData['horaInicio'] ?? '',
              widget.blockData['horaFin'] ?? '',
              widget.blockData['tipo'] ?? 'manual',
            ),
            // ✅ INDICADOR DE ARRASTRE
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      color: blockColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MOVIENDO',
                      style: TextStyle(
                        color: blockColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drag_indicator,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              'MOVIENDO...',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ MÉTODO COMPLETO IMPLEMENTADO
  void _handleTap() {
    if (widget.onSelectionChange != null) {
      widget.onSelectionChange!(widget.blockData);
    }
  }

  // ✅ MÉTODO COMPLETO IMPLEMENTADO
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Confirmar eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que quieres eliminar este bloqueo?'),
            const SizedBox(height: 8),
            Text(
              'Bloqueo: ${widget.blockData['motivo'] ?? 'Sin descripción'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ✅ CUSTOM PAINTER COMPLETO IMPLEMENTADO
class _DiagonalPatternPainter extends CustomPainter {
  final Color color;

  _DiagonalPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Dibujar líneas diagonales
    for (double i = -size.height; i < size.width + size.height; i += 8) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
