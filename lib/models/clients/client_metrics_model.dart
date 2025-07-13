// [client_metrics_model.dart] - MÉTRICAS DEL CLIENTE - ✅ CON FIXES
// 📁 Ubicación: /lib/models/clients/client_metrics_model.dart
// 🎯 OBJETIVO: Métricas y KPIs del cliente con defaults seguros

import 'package:cloud_firestore/cloud_firestore.dart';

/// 📊 MÉTRICAS DEL CLIENTE - ✅ FIXES APLICADOS
class ClientMetrics {
  final int appointmentsCount;
  final int attendedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final double totalRevenue;
  final double averageTicket;
  final double satisfactionScore;
  final DateTime? lastAppointment;
  final DateTime? nextAppointment;
  final int loyaltyPoints;

  const ClientMetrics({
    this.appointmentsCount = 0, // ✅ FIX: Default 0
    this.attendedAppointments = 0, // ✅ FIX: Default 0
    this.cancelledAppointments = 0, // ✅ FIX: Default 0
    this.noShowAppointments = 0, // ✅ FIX: Default 0
    this.totalRevenue = 0.0, // ✅ FIX: Default 0.0
    this.averageTicket = 0.0, // ✅ FIX: Default 0.0
    this.satisfactionScore = 0.0, // ✅ FIX: Default 0.0
    this.lastAppointment,
    this.nextAppointment,
    this.loyaltyPoints = 0, // ✅ FIX: Default 0
  });

  /// ✅ FIX: fromMap con fallbacks seguros
  factory ClientMetrics.fromMap(Map<String, dynamic> data) {
    return ClientMetrics(
      appointmentsCount: data['appointmentsCount'] as int? ?? 0, // ✅ FIX: Fallback seguro
      attendedAppointments: data['attendedAppointments'] as int? ?? 0, // ✅ FIX: Fallback seguro
      cancelledAppointments: data['cancelledAppointments'] as int? ?? 0, // ✅ FIX: Fallback seguro
      noShowAppointments: data['noShowAppointments'] as int? ?? 0, // ✅ FIX: Fallback seguro
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0, // ✅ FIX: Fallback seguro
      averageTicket: (data['averageTicket'] as num?)?.toDouble() ?? 0.0, // ✅ FIX: Fallback seguro
      satisfactionScore: (data['satisfactionScore'] as num?)?.toDouble() ?? 0.0, // ✅ FIX: Fallback seguro
      lastAppointment: _parseDateTime(data['lastAppointment']),
      nextAppointment: _parseDateTime(data['nextAppointment']),
      loyaltyPoints: data['loyaltyPoints'] as int? ?? 0, // ✅ FIX: Fallback seguro
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentsCount': appointmentsCount,
      'attendedAppointments': attendedAppointments,
      'cancelledAppointments': cancelledAppointments,
      'noShowAppointments': noShowAppointments,
      'totalRevenue': totalRevenue,
      'averageTicket': averageTicket,
      'satisfactionScore': satisfactionScore,
      'lastAppointment':
          lastAppointment != null ? Timestamp.fromDate(lastAppointment!) : null,
      'nextAppointment':
          nextAppointment != null ? Timestamp.fromDate(nextAppointment!) : null,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  double get attendanceRate {
    if (appointmentsCount == 0) return 0.0;
    return (attendedAppointments / appointmentsCount) * 100;
  }

  double get cancellationRate {
    if (appointmentsCount == 0) return 0.0;
    return (cancelledAppointments / appointmentsCount) * 100;
  }

  double get noShowRate {
    if (appointmentsCount == 0) return 0.0;
    return (noShowAppointments / appointmentsCount) * 100;
  }

  ClientMetrics copyWith({
    int? appointmentsCount,
    int? attendedAppointments,
    int? cancelledAppointments,
    int? noShowAppointments,
    double? totalRevenue,
    double? averageTicket,
    double? satisfactionScore,
    DateTime? lastAppointment,
    DateTime? nextAppointment,
    int? loyaltyPoints,
  }) {
    return ClientMetrics(
      appointmentsCount: appointmentsCount ?? this.appointmentsCount,
      attendedAppointments: attendedAppointments ?? this.attendedAppointments,
      cancelledAppointments:
          cancelledAppointments ?? this.cancelledAppointments,
      noShowAppointments: noShowAppointments ?? this.noShowAppointments,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageTicket: averageTicket ?? this.averageTicket,
      satisfactionScore: satisfactionScore ?? this.satisfactionScore,
      lastAppointment: lastAppointment ?? this.lastAppointment,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}