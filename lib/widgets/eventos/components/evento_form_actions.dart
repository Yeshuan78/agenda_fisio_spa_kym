// [evento_form_actions.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/evento_form_actions.dart
// 🎯 OBJETIVO: Acciones del formulario con botones premium y estados de carga

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventoFormActions extends StatefulWidget {
  final bool isLoading;
  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EventoFormActions({
    super.key,
    required this.isLoading,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<EventoFormActions> createState() => _EventoFormActionsState();
}

class _EventoFormActionsState extends State<EventoFormActions>
    with TickerProviderStateMixin {
  late AnimationController _saveController;
  late AnimationController _cancelController;
  late Animation<double> _saveAnimation;
  late Animation<double> _cancelAnimation;

  @override
  void initState() {
    super.initState();
    _saveController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _cancelController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _saveAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_saveController);

    _cancelAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_cancelController);
  }

  @override
  void dispose() {
    _saveController.dispose();
    _cancelController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!widget.canSave || widget.isLoading) return;

    _saveController.forward().then((_) {
      if (mounted) {
        _saveController.reverse();
      }
    });
    widget.onSave();
  }

  void _handleCancel() {
    if (widget.isLoading) return;

    _cancelController.forward().then((_) {
      if (mounted) {
        _cancelController.reverse();
      }
    });
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: kBorderColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Información de estado
          if (widget.isLoading) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kBrandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Guardando evento...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kBrandPurple,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!widget.canSave) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Completa los campos requeridos',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kAccentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: kAccentGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Listo para guardar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kAccentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Botones de acción
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón cancelar
              AnimatedBuilder(
                animation: _cancelAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cancelAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.isLoading ? null : _handleCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 18,
                                  color: widget.isLoading
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isLoading
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
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

              const SizedBox(width: 16),

              // Botón guardar
              AnimatedBuilder(
                animation: _saveAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _saveAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: widget.canSave && !widget.isLoading
                            ? const LinearGradient(
                                colors: [kBrandPurple, kAccentBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.canSave && !widget.isLoading
                            ? null
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: widget.canSave && !widget.isLoading
                            ? [
                                BoxShadow(
                                  color: kBrandPurple.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.canSave && !widget.isLoading
                              ? _handleSave
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.isLoading) ...[
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.save,
                                    size: 18,
                                    color: widget.canSave
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                  ),
                                ],
                                const SizedBox(width: 12),
                                Text(
                                  widget.isLoading
                                      ? 'Guardando...'
                                      : 'Guardar Evento',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: widget.canSave && !widget.isLoading
                                        ? Colors.white
                                        : Colors.grey.shade500,
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
        ],
      ),
    );
  }
}
