// [agenda_quick_actions.dart]
// 📁 Ubicación: /lib/widgets/agenda/agenda_quick_actions.dart
// ⚡ PANEL DE ACCIONES RÁPIDAS PARA AGENDA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AgendaQuickActions extends StatefulWidget {
  final VoidCallback onCreateCita;
  final VoidCallback onCreateEvento;
  final VoidCallback onCreateBloqueo;
  final VoidCallback onImportData;

  const AgendaQuickActions({
    super.key,
    required this.onCreateCita,
    required this.onCreateEvento,
    required this.onCreateBloqueo,
    required this.onImportData,
  });

  @override
  State<AgendaQuickActions> createState() => _AgendaQuickActionsState();
}

class _AgendaQuickActionsState extends State<AgendaQuickActions>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() async {
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _bounceController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildActionsList(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandPurple, kAccentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Crea y gestiona tu agenda rápidamente',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsList() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildActionTile(
                  'Nueva Cita Individual',
                  'Agenda una cita para un cliente específico',
                  Icons.person_add,
                  kAccentBlue,
                  () => _handleAction(widget.onCreateCita),
                  delay: 0,
                ),
                const SizedBox(height: 16),
                _buildActionTile(
                  'Evento Corporativo',
                  'Crear evento para múltiples empleados',
                  Icons.business_center,
                  kBrandPurple,
                  () => _handleAction(widget.onCreateEvento),
                  delay: 100,
                ),
                const SizedBox(height: 16),
                _buildActionTile(
                  'Bloqueo de Horario',
                  'Reservar tiempo para mantenimiento o descanso',
                  Icons.block,
                  Colors.orange.shade600,
                  () => _handleAction(widget.onCreateBloqueo),
                  delay: 200,
                ),
                const SizedBox(height: 16),
                _buildActionTile(
                  'Importar Datos',
                  'Cargar citas desde archivo CSV o Excel',
                  Icons.upload_file,
                  kAccentGreen,
                  () => _handleAction(widget.onImportData),
                  delay: 300,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap,
      {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.005),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.02),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // ✅ ICONO CON GRADIENTE
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.08)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ✅ INFORMACIÓN
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ FLECHA
                      Icon(
                        Icons.arrow_forward_ios,
                        color: color,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.keyboard,
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: Usa Ctrl+N para nueva cita, Ctrl+E para evento',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kAccentGreen.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: kAccentGreen.withValues(alpha: 0.03),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  color: kAccentGreen,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  'RÁPIDO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: kAccentGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(VoidCallback action) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    action();
  }
}
