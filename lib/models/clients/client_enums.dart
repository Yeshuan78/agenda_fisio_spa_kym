// [client_enums.dart] - ENUMS BÁSICOS DEL SISTEMA DE CLIENTES
// 📁 Ubicación: /lib/models/clients/client_enums.dart
// 🎯 OBJETIVO: Enums fundamentales extraídos de client_model.dart

import 'package:flutter/material.dart';

/// 📋 ESTADOS DEL CLIENTE
enum ClientStatus {
  active('Activo', Colors.green),
  inactive('Inactivo', Colors.orange),
  suspended('Suspendido', Colors.red),
  prospect('Prospecto', Colors.blue),
  vip('VIP', Colors.purple);

  const ClientStatus(this.displayName, this.color);
  final String displayName;
  final Color color;

  bool get isActive => this == ClientStatus.active || this == ClientStatus.vip;
}

/// 🏷️ TIPOS DE ETIQUETAS
enum TagType {
  base('Base'),
  custom('Personalizado'),
  system('Sistema');

  const TagType(this.displayName);
  final String displayName;
}