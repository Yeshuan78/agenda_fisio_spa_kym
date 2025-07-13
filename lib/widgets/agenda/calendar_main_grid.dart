// [calendar_main_grid.dart] - HOTFIX CRÍTICO PARA BoxConstraints
// 📁 Ubicación: /lib/widgets/agenda/calendar_main_grid.dart
// 🚨 SOLUCIONADO: BoxConstraints infinito + Constraints apropiados

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/agenda/time_slot_widget.dart';

class CalendarMainGrid extends StatelessWidget {
  final List<DateTime> timeSlots;
  final List<Map<String, dynamic>> resources;
  final ScrollController controller;
  final Map<DateTime, List<AppointmentModel>> appointments;
  final Map<DateTime, List<Map<String, dynamic>>> bloqueos;
  final double timeSlotHeight;
  final int timeSlotInterval;
  final int workStartHour;
  final int workEndHour;

  // ✅ CALLBACKS COMPATIBLES CON AGENDA ORIGINAL
  final Function(AppointmentModel, DateTime, String?) onAppointmentMove;
  final Function(AppointmentModel) onAppointmentEdit;
  final Function(DateTime, String?) onAppointmentCreate;
  final Function(Map<String, dynamic>, DateTime, String?) onBlockMove;
  final Function(Map<String, dynamic>) onBlockEdit;
  final Function(Map<String, dynamic>) onBlockDelete;

  const CalendarMainGrid({
    super.key,
    required this.timeSlots,
    required this.resources,
    required this.controller,
    required this.appointments,
    required this.bloqueos,
    required this.timeSlotHeight,
    required this.timeSlotInterval,
    required this.workStartHour,
    required this.workEndHour,
    required this.onAppointmentMove,
    required this.onAppointmentEdit,
    required this.onAppointmentCreate,
    required this.onBlockMove,
    required this.onBlockEdit,
    required this.onBlockDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 🚨 HOTFIX: Wrapper con LayoutBuilder para constraints apropiados
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ListView.builder(
            controller: controller,
            physics: const ClampingScrollPhysics(),
            itemCount: timeSlots.length,
            itemBuilder: (context, timeIndex) =>
                _buildTimeSlotRow(timeSlots[timeIndex], constraints.maxWidth),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotRow(DateTime timeSlot, double availableWidth) {
    return SizedBox(
      height: timeSlotHeight,
      width: availableWidth, // 🚨 HOTFIX: Width explícito
      child: Row(
        children: resources.map((resource) {
          return Expanded(
            child: SizedBox(
              width: availableWidth /
                  resources.length, // 🚨 HOTFIX: Width calculado
              child: _buildTimeSlotWidget(timeSlot, resource),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlotWidget(
      DateTime timeSlot, Map<String, dynamic> resource) {
    final appointments =
        _getAppointmentsForSlot(timeSlot, resource['id'] ?? '');
    final bloqueos = _getBloqueosForSlot(timeSlot, resource['id'] ?? '');
    final isWorkingHours = _isWorkingHours(timeSlot);

    return TimeSlotWidget(
      slotDateTime: timeSlot,
      resourceId: resource['id'] ?? '',
      resourceName: resource['nombre'] ?? '',
      resourceType: resource['tipo'] ?? 'profesional',
      appointments: appointments,
      bloqueos: bloqueos,
      width: double.infinity,
      height: timeSlotHeight,
      intervalMinutes: timeSlotInterval,
      isWorkingHours: isWorkingHours,
      isBlocked: bloqueos.isNotEmpty,
      blockReason: bloqueos.isNotEmpty ? bloqueos.first['motivo'] : null,
      onAppointmentMove: onAppointmentMove,
      onAppointmentEdit: onAppointmentEdit,
      onCreateAppointment: (dateTime, resourceId) =>
          onAppointmentCreate(dateTime, resourceId),
      onCreateBlock: (dateTime, resourceId) {
        final endDateTime = dateTime.add(Duration(minutes: timeSlotInterval));
        // 🚫 NO IMPLEMENTAR CALLBACK DIRECTO - usar los handlers del padre
      },
      onBlockMove: onBlockMove,
      onBlockEdit: onBlockEdit,
      onBlockDelete: onBlockDelete,
      showTimeLabel: false,
      isSelected: false,
    );
  }

  // 📋 OBTENER CITAS PARA UN SLOT ESPECÍFICO
  List<AppointmentModel> _getAppointmentsForSlot(
      DateTime timeSlot, String resourceId) {
    if (resourceId.isEmpty) return [];

    final dayKey = DateTime(timeSlot.year, timeSlot.month, timeSlot.day);
    final dayAppointments = appointments[dayKey] ?? [];

    return dayAppointments.where((appointment) {
      final appointmentTime = appointment.fechaInicio;
      if (appointmentTime == null) return false;

      final timeMatches = appointmentTime.hour == timeSlot.hour &&
          appointmentTime.minute == timeSlot.minute;

      final resourceMatches = appointment.profesionalId == resourceId ||
          appointment.cabinaId == resourceId ||
          appointment.servicioId == resourceId;

      return timeMatches && resourceMatches;
    }).toList();
  }

  // 🚫 OBTENER BLOQUEOS PARA UN SLOT ESPECÍFICO
  List<Map<String, dynamic>> _getBloqueosForSlot(
      DateTime timeSlot, String resourceId) {
    if (resourceId.isEmpty) return [];

    final dayKey = DateTime(timeSlot.year, timeSlot.month, timeSlot.day);
    final dayBloqueos = bloqueos[dayKey] ?? [];

    return dayBloqueos.where((bloqueo) {
      final horaInicio = bloqueo['horaInicio'] as String? ?? '';
      final horaFin = bloqueo['horaFin'] as String? ?? '';

      if (horaInicio.isEmpty || horaFin.isEmpty) return false;

      try {
        final inicio = int.parse(horaInicio.split(':')[0]);
        final fin = int.parse(horaFin.split(':')[0]);
        final slotHour = timeSlot.hour;

        final inTimeRange = slotHour >= inicio && slotHour < fin;

        // ✅ MANTENER LÓGICA DE BLOQUEOS (ES CORRECTO)
        final resourceMatches = bloqueo['profesionalId'] == resourceId ||
            bloqueo['cabinaId'] == resourceId ||
            bloqueo['servicioId'] == resourceId;

        return inTimeRange && resourceMatches;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  bool _isWorkingHours(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= workStartHour && hour <= workEndHour;
  }
}
