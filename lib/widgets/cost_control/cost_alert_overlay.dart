// [cost_alert_overlay.dart] - OVERLAY PARA ALERTAS CRÍTICAS DE COSTOS
// 📁 Ubicación: /lib/widgets/cost_control/cost_alert_overlay.dart
// 🎯 OBJETIVO: Overlay no intrusivo para alertas críticas que requieren atención

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CostAlertOverlay {
  /// 🚨 Mostrar alerta crítica de costos
  static void showCriticalAlert(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onDismiss,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.red.withValues(alpha: 0.1),
      builder: (context) => _CostAlertDialog(
        title: title,
        message: message,
        type: 'critical',
        onDismiss: onDismiss,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// ⚠️ Mostrar alerta de advertencia
  static void showWarningAlert(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onDismiss,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.orange.withValues(alpha: 0.1),
      builder: (context) => _CostAlertDialog(
        title: title,
        message: message,
        type: 'warning',
        onDismiss: onDismiss,
        onAction: onAction,
        actionLabel: actionLabel,
      ),
    );
  }

  /// ℹ️ Mostrar notificación informativa
  static void showInfoSnackbar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: kAccentBlue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 💾 Mostrar overlay de auto-guardado
  static void showAutoSaveOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AutoSaveOverlay(
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _CostAlertDialog extends StatefulWidget {
  final String title;
  final String message;
  final String type;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _CostAlertDialog({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  State<_CostAlertDialog> createState() => _CostAlertDialogState();
}

class _CostAlertDialogState extends State<_CostAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onDismiss();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text('Entendido'),
                        ),
                      ),
                      if (widget.onAction != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onAction!();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getTypeColor(),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(widget.actionLabel ?? 'Acción'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case 'critical':
        return Colors.red.shade600;
      case 'warning':
        return Colors.orange.shade600;
      default:
        return kAccentBlue;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }
}

class _AutoSaveOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _AutoSaveOverlay({required this.onComplete});

  @override
  State<_AutoSaveOverlay> createState() => _AutoSaveOverlayState();
}

class _AutoSaveOverlayState extends State<_AutoSaveOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_slideAnimation.value, 0),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kAccentGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentGreen.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Guardado automáticamente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}