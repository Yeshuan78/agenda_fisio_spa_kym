// [evento_card_utils.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_utils.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Utilidades y lógica de negocio del EventoCard original

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/evento_model.dart';
import 'package:agenda_fisio_spa_kym/services/evento_service.dart';

class EventoCardUtils {
  // ✅ CONFIGURACIÓN DE ESTADOS EXACTA EXTRAÍDA DE evento_card.dart líneas 130-170
  static Map<String, Map<String, dynamic>> get estadosConfig => {
        'activo': {
          'color': const Color(0xFF4CAF50), // Verde
          'icon': Icons.play_circle_filled,
          'label': 'Activo',
          'description': 'Evento en curso',
        },
        'completado': {
          'color': kBrandPurple, // Morado
          'icon': Icons.check_circle,
          'label': 'Completado',
          'description': 'Evento finalizado',
        },
        'programado': {
          'color': const Color(0xFF2196F3), // Azul
          'icon': Icons.schedule,
          'label': 'Programado',
          'description': 'Evento planificado',
        },
        'cancelado': {
          'color': const Color(0xFFF44336), // Rojo
          'icon': Icons.cancel,
          'label': 'Cancelado',
          'description': 'Evento cancelado',
        },
        'reagendado': {
          'color': const Color(0xFFFF9800), // Naranja
          'icon': Icons.update,
          'label': 'Reagendado',
          'description': 'Evento reprogramado',
        },
        'pausado': {
          'color': const Color(0xFFFFEB3B), // Amarillo
          'icon': Icons.pause_circle,
          'label': 'Pausado',
          'description': 'Evento suspendido',
        },
      };

  // ✅ EXTRACCIÓN EXACTA de getters del evento_card.dart
  static Color getStatusColor(String estado) =>
      estadosConfig[estado]?['color'] ?? Colors.grey;
  
  static IconData getStatusIcon(String estado) =>
      estadosConfig[estado]?['icon'] ?? Icons.event;
  
  static String getStatusLabel(String estado) =>
      estadosConfig[estado]?['label'] ?? estado;

  // ✅ EXTRACCIÓN EXACTA del método _copiarURL() del evento_card.dart líneas 180-230
  static Future<void> copiarURL(BuildContext context, String url, 
      AnimationController copyController) async {
    try {
      await Clipboard.setData(ClipboardData(text: url));

      copyController.forward().then((_) {
        copyController.reverse();
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✅ URL copiada exitosamente',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('Puedes pegarla en cualquier navegador',
                          style:
                              TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al copiar: $e'),
            backgroundColor: const Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ✅ EXTRACCIÓN EXACTA del método _cambiarEstado() del evento_card.dart líneas 240-300
  static Future<void> cambiarEstado(BuildContext context, EventoModel evento, 
      String nuevoEstado, Function(EventoModel)? onEventoUpdated) async {
    try {
      // ✅ CREAR EVENTO ACTUALIZADO
      final eventoActualizado = EventoModel(
        id: evento.id,
        eventoId: evento.eventoId,
        nombre: evento.nombre,
        empresa: evento.empresa,
        empresaId: evento.empresaId,
        ubicacion: evento.ubicacion,
        fecha: evento.fecha,
        estado: nuevoEstado, // ✅ NUEVO ESTADO
        observaciones: evento.observaciones,
        serviciosAsignados: evento.serviciosAsignados,
        fechaCreacion: evento.fechaCreacion,
      );

      // ✅ ACTUALIZAR EN FIRESTORE
      await EventoService().updateEvento(eventoActualizado);

      // ✅ NOTIFICAR AL PADRE INMEDIATAMENTE
      if (onEventoUpdated != null) {
        onEventoUpdated(eventoActualizado);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Estado cambiado a: ${estadosConfig[nuevoEstado]?['label']}'),
            backgroundColor: estadosConfig[nuevoEstado]?['color'],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2), // ✅ REDUCIDO: 2 segundos
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error actualizando estado: $e'),
            backgroundColor: const Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}