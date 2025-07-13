// [agenda_event_handlers.dart]
// 📁 Ubicación: /lib/handlers/agenda_event_handlers.dart
// 🔧 EXTRACCIÓN QUIRÚRGICA: Callbacks y manejo de eventos
// ✅ COPY-PASTE EXACTO del archivo original - CERO MODIFICACIONES

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/managers/agenda_state_manager.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/appointment_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/edit_appointment_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/schedule_block_dialog.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/agenda_quick_actions.dart';
import 'package:agenda_fisio_spa_kym/screens/cost_control/cost_dashboard_screen.dart';

class AgendaEventHandlers {
  final BuildContext context;
  final AgendaStateManager stateManager;

  AgendaEventHandlers({
    required this.context,
    required this.stateManager,
  });

  // ========================================================================
  // 🎯 HANDLERS DE CITAS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ HANDLE APPOINTMENT CREATE EXACTO DEL ORIGINAL
  void handleAppointmentCreate(DateTime dateTime, String? resourceId) {
    debugPrint('➕ Creating appointment at $dateTime for resource $resourceId');

    showDialog(
      context: context,
      builder: (context) => AppointmentDialogPremium(
        fechaSeleccionada: dateTime,
        profesionalIdPreseleccionado: resourceId,
        listaClientes: stateManager.listaClientesDoc,
        listaProfesionales: stateManager.listaProfesionalesDoc,
        listaServicios: stateManager.listaServiciosDoc,
      ),
    ).then((result) {
      if (result == true) {
        debugPrint('✅ Nueva cita creada - UI se actualizará automáticamente');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cita creada para ${DateFormat('dd/MM HH:mm').format(dateTime)}',
              ),
              backgroundColor: kAccentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    });
  }

  // ✅ HANDLE APPOINTMENT EDIT EXACTO DEL ORIGINAL
  void handleAppointmentEdit(AppointmentModel appointment) {
    debugPrint('✏️ Editing appointment ${appointment.id}');

    showDialog(
      context: context,
      builder: (context) => EditAppointmentDialogPremium(
        appointment: appointment,
        listaClientes: stateManager.listaClientesDoc,
        listaProfesionales: stateManager.listaProfesionalesDoc,
        listaServicios: stateManager.listaServiciosDoc,
        onAppointmentUpdated: (updatedAppointment) {
          debugPrint('✅ Cita actualizada - UI se actualizará automáticamente');
        },
        onAppointmentDeleted: () {
          debugPrint('✅ Cita eliminada - UI se actualizará automáticamente');
        },
      ),
    ).then((result) {
      if (result == true) {
        debugPrint('✅ Operación completada en diálogo de edición');
      }
    });
  }

  // ========================================================================
  // 🎯 DRAG & DROP HANDLERS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ DRAG & DROP OPTIMIZADO - SIN VALIDACIONES COMPLEJAS EXACTO DEL ORIGINAL
  void handleAppointmentMove(
    AppointmentModel appointment,
    DateTime newDateTime,
    String? newResourceId,
  ) {
    _performDirectUpdate(appointment, newDateTime, newResourceId);
  }

  // ✅ PERFORM DIRECT UPDATE EXACTO DEL ORIGINAL
  Future<void> _performDirectUpdate(
    AppointmentModel appointment,
    DateTime newDateTime,
    String? newResourceId,
  ) async {
    try {
      final Map<String, dynamic> updateData = {
        'fecha': Timestamp.fromDate(newDateTime),
        'fechaModificacion': FieldValue.serverTimestamp(),
      };

      if (newResourceId != null && newResourceId != appointment.profesionalId) {
        updateData['profesionalId'] = newResourceId;
      }

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(appointment.id)
          .update(updateData);

      debugPrint(
          '✅ Cita movida directamente - UI se actualizará automáticamente');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cita movida a ${DateFormat('dd/MM HH:mm').format(newDateTime)}',
            ),
            backgroundColor: kAccentGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error moviendo cita: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moviendo cita: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  // ========================================================================
  // 🎯 HANDLERS DE BLOQUEOS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ HANDLE BLOCK CREATE EXACTO DEL ORIGINAL
  void handleBlockCreate(
      DateTime startTime, DateTime endTime, String resourceId) {
    debugPrint('🚫 Creating block from $startTime to $endTime for $resourceId');

    showScheduleBlockDialogPremium(
      context: context,
      slotStart: startTime,
      profesionalId: resourceId,
      onSaveBlock: ({
        required String profesionalId,
        required DateTime day,
        required int startHour,
        required int startMin,
        required int endHour,
        required int endMin,
        required String blockName,
      }) {
        debugPrint('✅ Bloqueo creado - UI se actualizará automáticamente');
        _refreshBloqueosAfterUpdate();
      },
    );
  }

  // ✅ HANDLE BLOCK UPDATE EXACTO DEL ORIGINAL
  Future<void> handleBlockUpdate(Map<String, dynamic> blockData) async {
    try {
      final blockId = blockData['id'];
      if (blockId == null) {
        throw Exception('ID del bloqueo no encontrado');
      }

      // Mostrar diálogo de edición
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => _buildEditBlockDialog(blockData),
      );

      if (result != null) {
        // Actualizar el bloqueo en Firestore
        await FirebaseFirestore.instance
            .collection('bloqueos')
            .doc(blockId)
            .update({
          ...result,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Bloqueo actualizado exitosamente');
        await _refreshBloqueosAfterUpdate();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bloqueo actualizado exitosamente'),
              backgroundColor: kAccentGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error actualizando bloqueo: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error actualizando bloqueo: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  // ✅ HANDLE BLOCK DELETE EXACTO DEL ORIGINAL
  Future<void> handleBlockDelete(String blockId) async {
    try {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este bloqueo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmar == true) {
        await FirebaseFirestore.instance
            .collection('bloqueos')
            .doc(blockId)
            .delete();

        debugPrint('✅ Bloqueo eliminado exitosamente de Firestore');
        await _refreshBloqueosAfterUpdate();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Bloqueo eliminado exitosamente'),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error eliminando bloqueo: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error eliminando bloqueo: $e'),
            backgroundColor: Colors.red.shade600,
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: () => handleBlockDelete(blockId),
            ),
          ),
        );
      }
    }
  }

  // ✅ HANDLE DAY SELECTED EXACTO DEL ORIGINAL
  void handleDaySelected(DateTime selectedDay) {
    stateManager.selectedDay = selectedDay;
    debugPrint('📅 Día seleccionado: $selectedDay');
  }

  // ========================================================================
  // 🎯 MODALES Y DIÁLOGOS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ SHOW QUICK ACTIONS MODAL EXACTO DEL ORIGINAL
  void showQuickActionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsModal(),
    );
  }

  // ✅ BUILD QUICK ACTIONS MODAL EXACTO DEL ORIGINAL
  Widget _buildQuickActionsModal() {
    return Center(
      child: Container(
        width: 300, // ✅ ANCHO MÁXIMO 300PX
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 600, // ✅ ALTURA MÁXIMA PARA EVITAR OVERFLOW
        ),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AgendaQuickActions(
                onCreateCita: () =>
                    handleAppointmentCreate(stateManager.selectedDay, null),
                onCreateEvento: () =>
                    handleAppointmentCreate(stateManager.selectedDay, null),
                onCreateBloqueo: () => handleBlockCreate(
                    stateManager.selectedDay,
                    stateManager.selectedDay.add(const Duration(hours: 1)),
                    'general'),
                onImportData: () => _refreshAllData(),
              ),

              // ✅ COST CONTROL MENU ITEM - MODIFICACIÓN 8B
              const SizedBox(height: 12),
              _buildCostControlMenuItem(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ COST CONTROL MENU ITEM - PLACEHOLDER TEMPORAL
  Widget _buildCostControlMenuItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CostDashboardScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Control de Costos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Monitoreo automático de gastos',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // 🎯 MÉTODOS HELPER EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ BUILD EDIT BLOCK DIALOG EXACTO DEL ORIGINAL
  Widget _buildEditBlockDialog(Map<String, dynamic> blockData) {
    final motivoController =
        TextEditingController(text: blockData['motivo'] ?? '');
    final tipoController = TextEditingController(text: blockData['tipo'] ?? '');

    return AlertDialog(
      title: const Text('Editar Bloqueo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: tipoController,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'motivo': motivoController.text,
              'tipo': tipoController.text,
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // ✅ REFRESH BLOQUEOS AFTER UPDATE EXACTO DEL ORIGINAL
  Future<void> _refreshBloqueosAfterUpdate() async {
    try {
      // Pequeña pausa para asegurar que Firestore procese el cambio
      await Future.delayed(const Duration(milliseconds: 500));

      // Los listeners en tiempo real deberían actualizar automáticamente
      debugPrint(
          '🔄 Esperando actualización automática de bloqueos via listener');
    } catch (e) {
      debugPrint('❌ Error refrescando bloqueos: $e');
    }
  }

  // ✅ REFRESH ALL DATA EXACTO DEL ORIGINAL
  Future<void> _refreshAllData() async {
    try {
      // Recargar todos los datos
      debugPrint('🔄 Refrescando todos los datos...');
      // Los listeners se encargarán de la actualización automática
    } catch (e) {
      debugPrint('❌ Error refrescando datos: $e');
    }
  }

  // ========================================================================
  // 🎯 VALIDACIONES EXACTAS DEL ORIGINAL
  // ========================================================================

  // ✅ ACTUALIZAR CITA CON VALIDACION EXACTO DEL ORIGINAL
  Future<bool> actualizarCitaConValidacion({
    required String citaId,
    required AppointmentModel citaOriginal,
    required Map<String, dynamic> nuevosDatos,
  }) async {
    try {
      final cambioHorario = nuevosDatos['fecha'] != null;
      final cambioProfesional = nuevosDatos['profesionalId'] != null &&
          nuevosDatos['profesionalId'] != citaOriginal.profesionalId;

      if (cambioHorario || cambioProfesional) {
        final fechaHora = cambioHorario
            ? (nuevosDatos['fecha'] as Timestamp).toDate()
            : citaOriginal.fechaInicio!;
        final profesionalId = cambioProfesional
            ? nuevosDatos['profesionalId']
            : citaOriginal.profesionalId!;
        final duracion = nuevosDatos['duracion'] ?? citaOriginal.duracion ?? 60;

        final hayConflicto = await _verificarConflictoDeHorario(
          fechaHora: fechaHora,
          duracion: duracion,
          profesionalId: profesionalId,
          citaExcluidaId: citaId,
        );

        if (hayConflicto && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Conflicto de horario detectado. No se puede mover la cita.',
              ),
              backgroundColor: Colors.orange.shade700,
              action: SnackBarAction(
                label: 'Entendido',
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ),
          );
          return false;
        }
      }

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(citaId)
          .update({
        ...nuevosDatos,
        'fechaModificacion': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error actualizando cita: $e');
      return false;
    }
  }

  // ✅ VERIFICAR CONFLICTO DE HORARIO EXACTO DEL ORIGINAL
  Future<bool> _verificarConflictoDeHorario({
    required DateTime fechaHora,
    required int duracion,
    required String profesionalId,
    String? citaExcluidaId,
  }) async {
    try {
      final fechaInicio = Timestamp.fromDate(fechaHora);
      final fechaFin = Timestamp.fromDate(
        fechaHora.add(Duration(minutes: duracion)),
      );

      final query = FirebaseFirestore.instance
          .collection('bookings')
          .where('profesionalId', isEqualTo: profesionalId)
          .where('fecha', isGreaterThanOrEqualTo: fechaInicio)
          .where('fecha', isLessThan: fechaFin);

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        if (citaExcluidaId != null && doc.id == citaExcluidaId) {
          continue;
        }

        final data = doc.data();
        final citaFecha = (data['fecha'] as Timestamp).toDate();
        final citaDuracion = data['duracion'] ?? 60;
        final citaFin = citaFecha.add(Duration(minutes: citaDuracion));

        final hayConflicto = fechaHora.isBefore(citaFin) &&
            fechaHora.add(Duration(minutes: duracion)).isAfter(citaFecha);

        if (hayConflicto) {
          debugPrint('⚠️ Conflicto detectado con cita: ${doc.id}');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error verificando conflictos: $e');
      return false;
    }
  }
}
