// [resource_header_widget.dart] - VERSIÓN CORREGIDA CON OVERFLOW SOLUCIONADO
// 📁 Ubicación: /lib/widgets/agenda/resource_header_widget.dart
// 🔧 CORREGIDO: Overflow de nombres largos + Layout optimizado + Alineación perfecta

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ResourceHeaderWidget extends StatefulWidget {
  final String resourceId;
  final String resourceName;
  final String resourceType; // 'profesional', 'cabina'
  final String? avatarUrl;
  final String status; // 'activo', 'ocupado', 'inactivo', 'mantenimiento'
  final List<String> especialidades;
  final Map<String, dynamic>? metadata;
  final double width;
  final double height;
  final bool isSelected;
  final Function(String)? onResourceTap;
  final Function(String)? onResourceSettings;
  final bool showQuickActions;
  final int appointmentsToday;
  final double occupancyPercentage;

  const ResourceHeaderWidget({
    super.key,
    required this.resourceId,
    required this.resourceName,
    required this.resourceType,
    this.avatarUrl,
    required this.status,
    this.especialidades = const [],
    this.metadata,
    this.width = 200.0,
    this.height = 150.0,
    this.isSelected = false,
    this.onResourceTap,
    this.onResourceSettings,
    this.showQuickActions = true,
    this.appointmentsToday = 0,
    this.occupancyPercentage = 0.0,
  });

  @override
  State<ResourceHeaderWidget> createState() => _ResourceHeaderWidgetState();
}

class _ResourceHeaderWidgetState extends State<ResourceHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _selectionController;
  late AnimationController _statusController;

  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<Color?> _backgroundAnimation;

  bool _isHovered = false;

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
      begin: 1.0,
      end: 4.0,
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
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutCubic,
    );

    // ✅ STATUS INDICATOR ANIMATION
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // ✅ BACKGROUND COLOR ANIMATION - CORREGIDO
    _backgroundAnimation = ColorTween(
      begin: Colors.white,
      end: _getResourceColor().withValues(alpha: 0.05),
    ).animate(_hoverController);

    // ✅ START STATUS ANIMATION IF ACTIVE
    if (widget.status == 'activo' || widget.status == 'ocupado') {
      _statusController.repeat(reverse: true);
    }

    // ✅ HANDLE SELECTION STATE
    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(ResourceHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }

    if (widget.status != oldWidget.status) {
      if (widget.status == 'activo' || widget.status == 'ocupado') {
        _statusController.repeat(reverse: true);
      } else {
        _statusController.stop();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _selectionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Color _getResourceColor() {
    switch (widget.resourceType) {
      case 'profesional':
        return kBrandPurple;
      case 'cabina':
        return kAccentBlue;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusColor() {
    switch (widget.status.toLowerCase()) {
      case 'activo':
        return kAccentGreen;
      case 'ocupado':
        return Colors.orange.shade600;
      case 'inactivo':
        return Colors.grey.shade500;
      case 'mantenimiento':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getResourceIcon() {
    switch (widget.resourceType) {
      case 'profesional':
        return Icons.person;
      case 'cabina':
        return Icons.room;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: () {
          widget.onResourceTap?.call(widget.resourceId);
          HapticFeedback.selectionClick();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _elevationAnimation,
            _scaleAnimation,
            _selectionAnimation,
            _backgroundAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: _backgroundAnimation.value,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isSelected
                        ? _getResourceColor()
                        : kBorderColor.withValues(alpha: 0.3),
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getResourceColor()
                          .withValues(alpha: widget.isSelected ? 0.2 : 0.1),
                      blurRadius: _elevationAnimation.value * 3,
                      offset: Offset(0, _elevationAnimation.value),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // ✅ CONTENIDO PRINCIPAL
                    _buildMainContent(),

                    // ✅ STATUS INDICATOR
                    _buildStatusIndicator(),

                    // ✅ SELECTION OVERLAY
                    if (widget.isSelected) _buildSelectionOverlay(),

                    // ✅ APPOINTMENTS BADGE
                    if (widget.appointmentsToday > 0) _buildAppointmentsBadge(),

                    // ✅ OCCUPANCY BAR
                    if (widget.resourceType == 'profesional' &&
                        widget.occupancyPercentage > 0)
                      _buildOccupancyBar(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🛠️ CONTENIDO PRINCIPAL OPTIMIZADO PARA OVERFLOW
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(12), // ✅ REDUCIDO: 16 → 12
      child: Row(
        children: [
          // ✅ AVATAR COMPACTO
          _buildAvatar(),

          const SizedBox(width: 12), // ✅ REDUCIDO: 16 → 12

          // ✅ INFORMACIÓN DEL RECURSO CON OVERFLOW CONTROL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ NOMBRE CON OVERFLOW SOLUCIONADO
                Text(
                  widget.resourceName,
                  style: TextStyle(
                    fontSize: 14, // ✅ REDUCIDO: 16 → 14
                    fontWeight: FontWeight.w600, // ✅ REDUCIDO: w700 → w600
                    color: widget.isSelected
                        ? _getResourceColor()
                        : Colors.black87,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),

                const SizedBox(height: 2), // ✅ REDUCIDO: 4 → 2

                // ✅ TIPO O ESPECIALIDAD - COMPACTO
                Text(
                  _getSubtitle(),
                  style: TextStyle(
                    fontSize: 11, // ✅ REDUCIDO: 12 → 11
                    fontWeight: FontWeight.w500,
                    color: _getResourceColor().withValues(alpha: 0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // ✅ ASEGURAR LÍNEA ÚNICA
                ),

                // ✅ METADATA ADICIONAL - MÁS COMPACTO
                if (widget.metadata != null && widget.metadata!.isNotEmpty)
                  ..._buildMetadataWidgets(),
              ],
            ),
          ),

          // ✅ QUICK ACTIONS - COMPACTAS
          if (widget.showQuickActions && _isHovered) _buildQuickActions(),
        ],
      ),
    );
  }

  // 🛠️ AVATAR MÁS COMPACTO
  Widget _buildAvatar() {
    return Container(
      width: 44, // ✅ REDUCIDO: 48 → 44
      height: 44, // ✅ REDUCIDO: 48 → 44
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getResourceColor(),
            _getResourceColor().withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12), // ✅ REDUCIDO: 14 → 12
        boxShadow: [
          BoxShadow(
            color: _getResourceColor().withValues(alpha: 0.3),
            blurRadius: 8, // ✅ REDUCIDO: 12 → 8
            offset: const Offset(0, 4), // ✅ REDUCIDO: 6 → 4
          ),
        ],
      ),
      child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarIcon(),
              ),
            )
          : _buildAvatarIcon(),
    );
  }

  Widget _buildAvatarIcon() {
    return Icon(
      _getResourceIcon(),
      color: Colors.white,
      size: 20, // ✅ REDUCIDO: 24 → 20
    );
  }

  Widget _buildStatusIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedBuilder(
        animation: _statusController,
        builder: (context, child) {
          return Container(
            width: 12, // ✅ REDUCIDO: 14 → 12
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: widget.status == 'activo'
                      ? 2 * _statusController.value
                      : 0,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          Icons.settings,
          () => widget.onResourceSettings?.call(widget.resourceId),
          'Configuración',
        ),
        _buildActionButton(
          Icons.schedule,
          () => _showScheduleDialog(),
          'Horarios',
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback? onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: () {
          onTap?.call();
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: 24, // ✅ TAMAÑO COMPACTO
          height: 24,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getResourceColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: _getResourceColor(),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _getResourceColor()
                .withValues(alpha: 0.1 * _selectionAnimation.value),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getResourceColor()
                  .withValues(alpha: _selectionAnimation.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsBadge() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 6, vertical: 3), // ✅ COMPACTO
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getResourceColor(),
              _getResourceColor().withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(10), // ✅ REDUCIDO: 12 → 10
          boxShadow: [
            BoxShadow(
              color: _getResourceColor().withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${widget.appointmentsToday}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10, // ✅ REDUCIDO: 11 → 10
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOccupancyBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: widget.occupancyPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.occupancyPercentage > 80
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : widget.occupancyPercentage > 60
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [
                                kAccentGreen,
                                kAccentGreen.withValues(alpha: 0.8)
                              ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle() {
    if (widget.resourceType == 'profesional') {
      if (widget.especialidades.isNotEmpty) {
        return widget.especialidades.first;
      }
      return 'Profesional';
    } else if (widget.resourceType == 'cabina') {
      final tipo = widget.metadata?['tipo'] ?? 'Cabina';
      return tipo.toString().toUpperCase();
    }
    return widget.resourceType;
  }

  // 🛠️ METADATA MÁS COMPACTA CON OVERFLOW CONTROL
  List<Widget> _buildMetadataWidgets() {
    final widgets = <Widget>[];

    if (widget.resourceType == 'profesional') {
      // ✅ MOSTRAR HORARIO ACTUAL - COMPACTO
      final horario = widget.metadata?['horarioHoy'];
      if (horario != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2), // ✅ REDUCIDO: 3 → 2
            child: Text(
              horario.toString(),
              style: TextStyle(
                fontSize: 9, // ✅ REDUCIDO: 10 → 9
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1, // ✅ ASEGURAR LÍNEA ÚNICA
            ),
          ),
        );
      }
    } else if (widget.resourceType == 'cabina') {
      // ✅ MOSTRAR CAPACIDAD - COMPACTO
      final capacidad = widget.metadata?['capacidad'];
      if (capacidad != null) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 10, // ✅ REDUCIDO: 12 → 10
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 3), // ✅ REDUCIDO: 4 → 3
                Expanded(
                  // ✅ AGREGAR Expanded PARA EVITAR OVERFLOW
                  child: Text(
                    'Hasta $capacidad personas',
                    style: const TextStyle(
                      fontSize: 9, // ✅ REDUCIDO: 10 → 9
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Horarios - ${widget.resourceName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.resourceType == 'profesional') ...[
              _buildScheduleInfo(
                  'Hoy', widget.metadata?['horarioHoy'] ?? 'No configurado'),
              _buildScheduleInfo('Ocupación',
                  '${widget.occupancyPercentage.toStringAsFixed(1)}%'),
              _buildScheduleInfo(
                  'Citas', '${widget.appointmentsToday} programadas'),
            ] else if (widget.resourceType == 'cabina') ...[
              _buildScheduleInfo('Estado', widget.status),
              _buildScheduleInfo('Tipo', widget.metadata?['tipo'] ?? 'N/A'),
              _buildScheduleInfo('Capacidad',
                  '${widget.metadata?['capacidad'] ?? 'N/A'} personas'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
