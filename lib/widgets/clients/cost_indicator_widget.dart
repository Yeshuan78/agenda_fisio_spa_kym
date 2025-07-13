// [cost_indicator_widget.dart] - INDICADOR DE CONTROL DE COSTOS
// 📁 Ubicación: /lib/widgets/clients/cost_indicator_widget.dart
// 🎯 OBJETIVO: Widget inteligente que muestra el estado del control de costos

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 💰 WIDGET INDICADOR DE CONTROL DE COSTOS
/// Muestra el estado actual del sistema de control de costos con indicadores visuales
class CostIndicatorWidget extends StatefulWidget {
  final AnalyticsMode mode;
  final DateTime lastUpdated;
  final bool canRefresh;
  final VoidCallback onRefresh;
  final bool showDetails;

  const CostIndicatorWidget({
    super.key,
    required this.mode,
    required this.lastUpdated,
    required this.canRefresh,
    required this.onRefresh,
    this.showDetails = false,
  });

  @override
  State<CostIndicatorWidget> createState() => _CostIndicatorWidgetState();
}

class _CostIndicatorWidgetState extends State<CostIndicatorWidget>
    with SingleTickerProviderStateMixin {
  
  // ✅ CONTROLADOR DE ANIMACIÓN
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ✅ ESTADO DE UI
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animación de pulso si no puede refrescar
    if (!widget.canRefresh) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CostIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Controlar animación de pulso basada en estado
    if (widget.canRefresh != oldWidget.canRefresh) {
      if (!widget.canRefresh) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isHovered ? 1.05 : (_pulseAnimation.value),
            child: InkWell(
              onTap: widget.showDetails ? _showDetailsDialog : null,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: ClientConstants.MICRO_ANIMATION_DURATION,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 1.5,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: _getStatusColor().withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusIcon(),
                    const SizedBox(width: 8),
                    _buildStatusText(),
                    if (widget.canRefresh) ...[
                      const SizedBox(width: 8),
                      _buildRefreshButton(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getStatusIcon(),
        size: 12,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatusText() {
    return Text(
      _getStatusText(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _getStatusColor(),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return InkWell(
      onTap: widget.onRefresh,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(2),
        child: Icon(
          Icons.refresh,
          size: 14,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS DE CONFIGURACIÓN VISUAL
  // ====================================================================

  Color _getStatusColor() {
    switch (widget.mode) {
      case AnalyticsMode.offline:
        return Colors.grey.shade600;
      case AnalyticsMode.lowCost:
        return widget.canRefresh ? kAccentGreen : Colors.orange;
      case AnalyticsMode.standard:
        return widget.canRefresh ? kAccentBlue : Colors.orange;
      case AnalyticsMode.realTime:
        return widget.canRefresh ? kBrandPurple : Colors.red;
    }
  }

  Color _getBackgroundColor() {
    return _getStatusColor().withValues(alpha: 0.1);
  }

  Color _getBorderColor() {
    return _getStatusColor().withValues(alpha: 0.3);
  }

  IconData _getStatusIcon() {
    if (!widget.canRefresh) {
      return Icons.warning;
    }

    switch (widget.mode) {
      case AnalyticsMode.offline:
        return Icons.cloud_off;
      case AnalyticsMode.lowCost:
        return Icons.eco;
      case AnalyticsMode.standard:
        return Icons.speed;
      case AnalyticsMode.realTime:
        return Icons.flash_on;
    }
  }

  String _getStatusText() {
    if (!widget.canRefresh) {
      return 'Límite alcanzado';
    }

    switch (widget.mode) {
      case AnalyticsMode.offline:
        return 'Modo Offline';
      case AnalyticsMode.lowCost:
        return 'Modo Eco';
      case AnalyticsMode.standard:
        return 'Modo Estándar';
      case AnalyticsMode.realTime:
        return 'Tiempo Real';
    }
  }

  String _getModeDescription() {
    switch (widget.mode) {
      case AnalyticsMode.offline:
        return 'Solo datos en cache, sin consultas a Firestore';
      case AnalyticsMode.lowCost:
        return 'Cache de 6 horas + consultas limitadas para optimizar costos';
      case AnalyticsMode.standard:
        return 'Balance entre rendimiento y costos con cache inteligente';
      case AnalyticsMode.realTime:
        return 'Consultas en tiempo real sin restricciones de costo';
    }
  }

  String _getLastUpdatedText() {
    final now = DateTime.now();
    final difference = now.difference(widget.lastUpdated);
    
    if (difference.inMinutes < 1) {
      return 'Actualizado hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Actualizado hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Actualizado hace ${difference.inHours}h';
    } else {
      return 'Actualizado hace ${difference.inDays} días';
    }
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Control de Costos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Modo actual:', _getStatusText()),
              _buildDetailRow('Estado:', widget.canRefresh ? 'Activo' : 'Límite alcanzado'),
              _buildDetailRow('Última actualización:', _getLastUpdatedText()),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor().withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción del modo:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getModeDescription(),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.canRefresh) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Has alcanzado el límite de consultas. Los datos se actualizarán automáticamente cuando se restablezca el límite.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (widget.canRefresh)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onRefresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar Ahora'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 📊 ENUMS PARA MODOS DE ANALYTICS
enum AnalyticsMode {
  offline,    // Solo cache, 0 consultas
  lowCost,    // Cache + 1 consulta/6h  
  standard,   // Cache + consultas moderadas
  realTime,   // Sin restricciones
}