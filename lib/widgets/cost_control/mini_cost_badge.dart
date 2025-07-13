// [mini_cost_badge.dart] - BADGE DISCRETO DE COSTOS (APARECE SOLO CUANDO NECESARIO)
// 📁 Ubicación: /lib/widgets/cost_control/mini_cost_badge.dart
// 🎯 OBJETIVO: Widget flotante no invasivo que aparece solo en esquina superior derecha

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import '../../services/cost_control/cost_data_models.dart';

class MiniCostBadge extends StatefulWidget {
  final UsageStats stats;
  final bool visible;
  final VoidCallback onTap;

  const MiniCostBadge({
    super.key,
    required this.stats,
    required this.visible,
    required this.onTap,
  });

  @override
  State<MiniCostBadge> createState() => _MiniCostBadgeState();
}

class _MiniCostBadgeState extends State<MiniCostBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.visible) {
      _animationController.forward();
      if (widget.stats.isInCriticalZone) {
        _animationController.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(MiniCostBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _animationController.forward();
        if (widget.stats.isInCriticalZone) {
          _animationController.repeat(reverse: true);
        }
      } else {
        _animationController.reverse();
      }
    }

    // Actualizar animación según el estado crítico
    if (widget.visible &&
        widget.stats.isInCriticalZone != oldWidget.stats.isInCriticalZone) {
      if (widget.stats.isInCriticalZone) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value *
              (widget.stats.isInCriticalZone ? _pulseAnimation.value : 1.0),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getBadgeColor(),
                    _getBadgeColor().withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _getBadgeColor().withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getBadgeIcon(),
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getBadgeText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBadgeColor() {
    if (widget.stats.isInCriticalZone) {
      return Colors.red.shade600;
    } else if (widget.stats.isInWarningZone) {
      return Colors.orange.shade600;
    } else if (widget.stats.currentMode == 'live') {
      return Colors.blue.shade600;
    } else {
      return kAccentGreen;
    }
  }

  IconData _getBadgeIcon() {
    if (widget.stats.isInCriticalZone) {
      return Icons.warning;
    } else if (widget.stats.currentMode == 'live') {
      return Icons.flash_on;
    } else {
      return Icons.savings;
    }
  }

  String _getBadgeText() {
    if (widget.stats.isInCriticalZone) {
      return 'LÍMITE';
    } else if (widget.stats.currentMode == 'live') {
      return 'LIVE';
    } else {
      return '${widget.stats.dailyReadCount} (\$${widget.stats.estimatedDailyCost.toStringAsFixed(2)})';
    }
  }
}
