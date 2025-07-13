// [evento_card_refactored.dart]
// 📁 Ubicación: /lib/widgets/eventos/evento_card.dart (REEMPLAZAR ARCHIVO ORIGINAL)
// 🎯 COORDINADOR REFACTORIZADO: Mantiene funcionalidad exacta con arquitectura modular

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/evento_crud_dialog_premium.dart';
import 'components/card/evento_card_animations.dart';
import 'components/card/evento_card_utils.dart';
import 'components/card/evento_card_header.dart';
import 'components/card/evento_card_main_content.dart';
import 'components/card/evento_card_state_selector.dart';

class EventoCard extends StatefulWidget {
  final EventoModel evento;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(EventoModel)? onEventoUpdated;

  const EventoCard({
    super.key,
    required this.evento,
    this.onEdit,
    this.onDelete,
    this.onEventoUpdated,
  });

  @override
  State<EventoCard> createState() => _EventoCardState();
}

class _EventoCardState extends State<EventoCard> with TickerProviderStateMixin {
  // ✅ USAR CLASE EXTERNA PARA ANIMACIONES
  late EventoCardAnimations _animations;

  // ✅ MANTENER: Estados de UI exactos del original
  bool _isHovered = false;
  bool _showStateSelector = false;

  @override
  void initState() {
    super.initState();
    _animations = EventoCardAnimations();
    _animations.initAnimations(this);
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  // ✅ MÉTODO EXACTO PARA ABRIR CRUD PREMIUM
  Future<void> _abrirEdicionPremium() async {
    final resultado = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EventoCrudDialogPremium(evento: widget.evento),
    );

    if (resultado == true && mounted) {
      if (widget.onEdit != null) {
        widget.onEdit!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _animations.hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _animations.hoverController.reverse();
          },
          child: Stack(
            children: [
              // ✅ CARD PRINCIPAL CON ANIMACIONES EXACTAS
              AnimatedBuilder(
                animation: _animations.hoverController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animations.scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        // ✅ FONDO BLANCO ELEGANTE (COMO PULSE CARD)
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        // ✅ BORDE SUTIL (NO AGRESIVO)
                        border: Border.all(
                          color: _isHovered
                              ? EventoCardUtils.getStatusColor(
                                      widget.evento.estado)
                                  .withValues(alpha: 0.1) // Muy sutil
                              : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                          width: 1,
                        ),
                        // ✅ SOMBRAS SUTILES MULTICAPA (ESTILO PULSE CARD)
                        boxShadow: [
                          BoxShadow(
                            color: EventoCardUtils.getStatusColor(
                                    widget.evento.estado)
                                .withValues(alpha: _isHovered ? 0.08 : 0.03),
                            blurRadius:
                                _animations.elevationAnimation.value * 1.5,
                            spreadRadius:
                                _animations.elevationAnimation.value * 0.1,
                            offset: Offset(
                                0, _animations.elevationAnimation.value * 0.5),
                          ),
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: _isHovered ? 0.06 : 0.02),
                            blurRadius: _animations.elevationAnimation.value,
                            spreadRadius:
                                _animations.elevationAnimation.value * 0.05,
                            offset: Offset(
                                0, _animations.elevationAnimation.value * 0.3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            // ✅ USAR COMPONENTE EXTERNO
                            EventoCardHeader(
                              evento: widget.evento,
                              isHovered: _isHovered,
                              onEstadoTap: () {
                                setState(() {
                                  _showStateSelector = !_showStateSelector;
                                });
                                if (_showStateSelector) {
                                  _animations.stateController.forward();
                                } else {
                                  _animations.stateController.reverse();
                                }
                              },
                            ),

                            // ✅ USAR COMPONENTE EXTERNO
                            EventoCardMainContent(
                              evento: widget.evento,
                              copyAnimation: _animations.copyAnimation,
                              onEdit: _abrirEdicionPremium,
                              onDelete: widget.onDelete,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ✅ SELECTOR DE ESTADOS FLOTANTE
              if (_showStateSelector)
                AnimatedBuilder(
                  animation: _animations.stateAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 20,
                      right: 20,
                      child: Transform.scale(
                        scale: _animations.stateAnimation.value,
                        child: Opacity(
                          opacity: _animations.stateAnimation.value,
                          child: EventoCardStateSelector(
                            evento: widget.evento,
                            onEstadoChanged: (nuevoEstado) {
                              EventoCardUtils.cambiarEstado(
                                context,
                                widget.evento,
                                nuevoEstado,
                                widget.onEventoUpdated,
                              );
                              setState(() {
                                _showStateSelector = false;
                              });
                              _animations.stateController.reverse();
                            },
                            onClose: () {
                              setState(() {
                                _showStateSelector = false;
                              });
                              _animations.stateController.reverse();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
