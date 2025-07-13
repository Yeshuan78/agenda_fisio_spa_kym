// [sidebar_option.dart] - ACTUALIZADO CON CLIENTES PREMIUM
// 📁 Ubicación: /lib/widgets/navigation/sidebar_option.dart
// 🚀 OPCIONES DEL SIDEBAR CON NUEVA PANTALLA CLIENTES PREMIUM

import 'package:flutter/material.dart';

class SidebarOption {
  final String route;
  final String label;
  final IconData icon;
  final String group;
  final int? badge;
  final bool isNew;
  final bool isPremium;

  const SidebarOption({
    required this.route,
    required this.label,
    required this.icon,
    required this.group,
    this.badge,
    this.isNew = false,
    this.isPremium = false,
  });
}

// ✅ LISTA ACTUALIZADA DE OPCIONES DEL SIDEBAR
final List<SidebarOption> sidebarOptions = [
  // 🚀 NUEVA OPCIÓN - AGENDA PREMIUM
  const SidebarOption(
    route: '/agenda/premium',
    label: 'Agenda Premium',
    icon: Icons.calendar_view_week,
    group: 'Agenda',
    isNew: true,
    isPremium: true,
    badge: 1, // Badge "NEW" para destacar
  ),
  const SidebarOption(
    route: '/agenda/diaria',
    label: 'Vista Diaria',
    icon: Icons.view_day,
    group: 'Agenda',
  ),

  // 👥 CLIENTES -
  // 🚀 NUEVA OPCIÓN - CLIENTES PREMIUM
  const SidebarOption(
    route: '/clientes/premium',
    label: 'Clientes Premium',
    icon: Icons.people_outline,
    group: 'Clientes',
    isNew: true,
    isPremium: true,
    badge: 1, // Badge "NEW" para destacar
  ),
  const SidebarOption(
    route: '/clientes/nuevo',
    label: 'Nuevo Cliente',
    icon: Icons.person_add,
    group: 'Clientes',
  ),

  // 👨‍⚕️ PROFESIONALES
  const SidebarOption(
    route: '/profesionales',
    label: 'Profesionales',
    icon: Icons.medical_services,
    group: 'Profesionales',
  ),
  const SidebarOption(
    route: '/profesionales/nuevo',
    label: 'Nuevo Profesional',
    icon: Icons.person_add_alt,
    group: 'Profesionales',
  ),

  // 🧰 SERVICIOS
  const SidebarOption(
    route: '/servicios',
    label: 'Catálogo de Servicios',
    icon: Icons.spa,
    group: 'Servicios',
  ),

  // 🔔 RECORDATORIOS
  const SidebarOption(
    route: '/recordatorios',
    label: 'Recordatorios',
    icon: Icons.notifications,
    group: 'Recordatorios',
  ),

  // 🏢 CORPORATIVO
  const SidebarOption(
    route: '/empresas',
    label: 'Empresas',
    icon: Icons.business,
    group: 'Corporativo',
  ),
  const SidebarOption(
    route: '/contratos',
    label: 'Contratos',
    icon: Icons.description,
    group: 'Corporativo',
  ),
  const SidebarOption(
    route: '/facturacion',
    label: 'Facturación',
    icon: Icons.receipt_long,
    group: 'Corporativo',
  ),
  const SidebarOption(
    route: '/micrositio/demo',
    label: 'Micrositio Demo',
    icon: Icons.qr_code,
    group: 'Corporativo',
  ),

  // ❤️ KYM PULSE
  const SidebarOption(
    route: '/kympulse',
    label: 'KYM Pulse Dashboard',
    icon: Icons.analytics,
    group: 'KYM Pulse',
  ),
  const SidebarOption(
    route: '/eventos',
    label: 'Eventos Corporativos',
    icon: Icons.event,
    group: 'KYM Pulse',
  ),
  const SidebarOption(
    route: '/encuestas',
    label: 'Encuestas',
    icon: Icons.poll,
    group: 'KYM Pulse',
  ),

  // 💵 VENTAS
  const SidebarOption(
    route: '/ventas',
    label: 'Panel de Ventas',
    icon: Icons.trending_up,
    group: 'Ventas',
  ),
  const SidebarOption(
    route: '/campanas',
    label: 'Campañas',
    icon: Icons.campaign,
    group: 'Ventas',
  ),
  const SidebarOption(
    route: '/cotizaciones',
    label: 'Cotizaciones',
    icon: Icons.request_quote,
    group: 'Ventas',
  ),

  // 📊 REPORTES
  const SidebarOption(
    route: '/reportes/pdf',
    label: 'Reportes PDF',
    icon: Icons.picture_as_pdf,
    group: 'Reportes',
  ),
  const SidebarOption(
    route: '/reportes/csv',
    label: 'Exportación CSV',
    icon: Icons.table_chart,
    group: 'Reportes',
  ),

  // 🟣 ADMIN
  const SidebarOption(
    route: '/admin',
    label: 'Herramientas Admin',
    icon: Icons.settings,
    group: 'Admin',
  ),
  const SidebarOption(
    route: '/admin/cost-control',
    label: 'Control de Costos',
    icon: Icons.savings,
    group: 'Admin',
  ),
  const SidebarOption(
    route: '/dev/widgets',
    label: 'Widget Testing',
    icon: Icons.biotech, // Icono de laboratorio
    group: 'Dev Tools',
  ),
];
