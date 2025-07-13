// [eventos_list_builder.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_list_builder.dart
// 🎯 COPY-PASTE EXACTO de líneas 650-750 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/evento_card.dart';

class EventosListBuilder extends StatelessWidget {
  final List<EventoModel> eventosFiltrados;
  final Animation<double> cardsAnimation;
  final Function(EventoModel) onEdit;
  final Function(EventoModel) onDelete;
  final Function(EventoModel) onEventoUpdated;

  const EventosListBuilder({
    super.key,
    required this.eventosFiltrados,
    required this.cardsAnimation,
    required this.onEdit,
    required this.onDelete,
    required this.onEventoUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimatedBuilder(
              animation: cardsAnimation,
              builder: (context, child) {
                final delay = index * 0.1;
                final animationValue = Curves.easeOutCubic.transform(
                    (((cardsAnimation.value - delay).clamp(0.0, 1.0)) /
                            (1.0 - delay))
                        .clamp(0.0, 1.0));

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: EventoCard(
                      evento: eventosFiltrados[index],
                      onEdit: () => onEdit(eventosFiltrados[index]),
                      onDelete: () => onDelete(eventosFiltrados[index]),
                      onEventoUpdated: onEventoUpdated,
                    ),
                  ),
                );
              },
            );
          },
          childCount: eventosFiltrados.length,
        ),
      ),
    );
  }
}