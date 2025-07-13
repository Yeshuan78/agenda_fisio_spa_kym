// [calendar_utils.dart]
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CalendarUtils {
  static Color getSlotBackgroundColor({
    required bool isBlocked,
    required bool hasAppointments,
    required bool isWorkingHours,
    required bool isHovered,
    required bool isDragOver,
  }) {
    if (isBlocked) {
      return Colors.red.shade50.withValues(alpha: 0.8);
    }

    if (isDragOver) {
      return hasAppointments
          ? Colors.orange.shade50.withValues(alpha: 0.9)
          : kAccentGreen.withValues(alpha: 0.1);
    }

    if (hasAppointments) {
      return kBrandPurple.withValues(alpha: 0.05);
    }

    if (!isWorkingHours) {
      return Colors.grey.shade50.withValues(alpha: 0.5);
    }

    if (isHovered) {
      return kAccentBlue.withValues(alpha: 0.05);
    }

    return Colors.white;
  }

  static Color getSlotBorderColor(bool isBlocked, bool isDragOver) {
    if (isBlocked) return Colors.red.shade300;
    if (isDragOver) return kAccentGreen;
    return kBorderColor.withValues(alpha: 0.2);
  }

  static double getSlotBorderWidth(bool isBlocked, bool isDragOver) {
    if (isBlocked || isDragOver) return 1.5;
    return 0.5;
  }

  static String getResourceSubtitle(Map<String, dynamic> resource) {
    final tipo = resource['tipo'] ?? '';

    switch (tipo) {
      case 'profesional':
        return resource['especialidad'] ?? 'Profesional';
      case 'cabina':
        return 'Capacidad: ${resource['capacidad'] ?? 1}';
      case 'servicio':
        return '${resource['duracion'] ?? 60} min';
      case 'evento':
        return resource['ubicacion'] ?? 'Evento';
      default:
        return '';
    }
  }
}
