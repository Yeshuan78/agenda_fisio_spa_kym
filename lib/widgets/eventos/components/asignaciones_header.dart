// [asignaciones_header.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/asignaciones_header.dart
// 🎯 OBJETIVO: Header premium para sección de asignaciones con contador animado

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AsignacionesHeader extends StatefulWidget {
  final int count;
  final VoidCallback onAdd;

  const AsignacionesHeader({
    super.key,
    required this.count,
    required this.onAdd,
  });

  @override
  State<AsignacionesHeader> createState() => _AsignacionesHeaderState();
}

class _AsignacionesHeaderState extends State<AsignacionesHeader>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late AnimationController _addButtonController;
  late AnimationController _pulseController;
  late Animation<int> _countAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _addButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _countAnimation = IntTween(
      begin: 0,
      end: widget.count,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_addButtonController);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _previousCount = widget.count;
    _countController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AsignacionesHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _countAnimation = IntTween(
        begin: _previousCount,
        end: widget.count,
      ).animate(CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOutCubic,
      ));
      _previousCount = widget.count;
      _countController.reset();
      _countController.forward();
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _addButtonController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleAddPressed() {
    _addButtonController.forward().then((_) {
      _addButtonController.reverse();
    });
    widget.onAdd();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBrandPurple.withValues(alpha: 0.08),
            kAccentBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Icono principal
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kBrandPurple, kAccentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.assignment_turned_in,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Título y descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asignaciones de Servicios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kBrandPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configura servicios específicos por profesional',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Contador animado
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              return AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kAccentGreen.withValues(
                        alpha: 0.1 + (_pulseAnimation.value * 0.05),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kAccentGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment,
                          color: kAccentGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_countAnimation.value}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kAccentGreen,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Botón agregar
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kAccentGreen, kAccentBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kAccentGreen.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _handleAddPressed,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Agregar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}