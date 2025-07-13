// [route_helper.dart] - HELPER DE RUTAS EXTRAÍDO
// 📁 Ubicación: /lib/widgets/layout/models/route_helper.dart
// 🎯 HELPER ESTÁTICO PARA MANEJO DE RUTAS

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class RouteHelper {
  static IconData getIcon(String route) {
    switch (route) {
      case '/agenda/premium':
        return Icons.auto_awesome;
      case '/agenda/semanal':
      case '/agenda/diaria':
        return Icons.calendar_today;
      case '/clientes':
      case '/clientes/nuevo':
        return Icons.people;
      case '/profesionales':
      case '/profesionales/nuevo':
        return Icons.medical_services;
      case '/servicios':
        return Icons.spa;
      case '/empresas':
        return Icons.business;
      case '/kympulse':
        return Icons.analytics;
      case '/eventos':
        return Icons.event;
      case '/encuestas':
        return Icons.quiz;
      case '/admin':
        return Icons.settings;
      default:
        return Icons.dashboard;
    }
  }

  static String getTitle(String route) {
    switch (route) {
      case '/agenda/premium':
        return 'Agenda Premium';
      case '/agenda/semanal':
        return 'Agenda Semanal';
      case '/agenda/diaria':
        return 'Agenda Diaria';
      case '/clientes':
        return 'Gestión de Clientes';
      case '/clientes/nuevo':
        return 'Nuevo Cliente';
      case '/profesionales':
        return 'Profesionales';
      case '/profesionales/nuevo':
        return 'Nuevo Profesional';
      case '/servicios':
        return 'Servicios';
      case '/empresas':
        return 'Empresas Corporativas';
      case '/kympulse':
        return 'KYM Pulse Dashboard';
      case '/eventos':
        return 'Eventos Corporativos';
      case '/encuestas':
        return 'Creator de Encuestas';
      case '/admin':
        return 'Configuración del Sistema';
      default:
        return 'Dashboard';
    }
  }

  static List<Color> getGradientColors(String route) {
    switch (route) {
      case '/agenda/premium':
        return [Colors.orange.shade600, Colors.orangeAccent];
      case '/agenda/semanal':
      case '/agenda/diaria':
        return [kBrandPurple, kAccentBlue];
      case '/kympulse':
        return [kAccentGreen, kAccentBlue];
      case '/eventos':
        return [kAccentBlue, kBrandPurple];
      default:
        return [kBrandPurple, kAccentBlue];
    }
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}