// [client_filter_model.dart] - CRITERIOS DE FILTRADO
// 📁 Ubicación: /lib/models/clients/client_filter_model.dart
// 🎯 OBJETIVO: Modelos para filtrado y búsqueda de clientes

import 'package:flutter/material.dart';
import 'client_enums.dart';

/// 📋 CRITERIOS DE FILTRO
class ClientFilterCriteria {
  final List<ClientStatus> statuses;
  final List<String> tags;
  final DateTimeRange? dateRange;
  final List<String> alcaldias;
  final int? minAppointments;
  final double? minRevenue;
  final double? minSatisfaction;

  const ClientFilterCriteria({
    this.statuses = const [],
    this.tags = const [],
    this.dateRange,
    this.alcaldias = const [],
    this.minAppointments,
    this.minRevenue,
    this.minSatisfaction,
  });

  bool get isEmpty {
    return statuses.isEmpty &&
        tags.isEmpty &&
        dateRange == null &&
        alcaldias.isEmpty &&
        minAppointments == null &&
        minRevenue == null &&
        minSatisfaction == null;
  }

  ClientFilterCriteria copyWith({
    List<ClientStatus>? statuses,
    List<String>? tags,
    DateTimeRange? dateRange,
    List<String>? alcaldias,
    int? minAppointments,
    double? minRevenue,
    double? minSatisfaction,
  }) {
    return ClientFilterCriteria(
      statuses: statuses ?? this.statuses,
      tags: tags ?? this.tags,
      dateRange: dateRange ?? this.dateRange,
      alcaldias: alcaldias ?? this.alcaldias,
      minAppointments: minAppointments ?? this.minAppointments,
      minRevenue: minRevenue ?? this.minRevenue,
      minSatisfaction: minSatisfaction ?? this.minSatisfaction,
    );
  }
}