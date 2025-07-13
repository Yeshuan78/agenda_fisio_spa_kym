// [client_audit_model.dart] - SISTEMA DE AUDITORÍA
// 📁 Ubicación: /lib/models/clients/client_audit_model.dart
// 🎯 OBJETIVO: Modelos de auditoría y trazabilidad

import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔍 INFORMACIÓN DE AUDITORÍA
class AuditInfo {
  final String createdBy;
  final String? lastModifiedBy;
  final List<AuditLog> logs;
  final Map<String, dynamic>? metadata;

  const AuditInfo({
    required this.createdBy,
    this.lastModifiedBy,
    this.logs = const [],
    this.metadata,
  });

  factory AuditInfo.fromMap(Map<String, dynamic> data) {
    return AuditInfo(
      createdBy: data['createdBy'] ?? 'system',
      lastModifiedBy: data['lastModifiedBy'],
      logs: _parseAuditLogs(data['logs']),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
      'logs': logs.map((log) => log.toMap()).toList(),
      'metadata': metadata,
    };
  }

  AuditInfo copyWith({
    String? createdBy,
    String? lastModifiedBy,
    List<AuditLog>? logs,
    Map<String, dynamic>? metadata,
  }) {
    return AuditInfo(
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      logs: logs ?? this.logs,
      metadata: metadata ?? this.metadata,
    );
  }

  static List<AuditLog> _parseAuditLogs(dynamic data) {
    if (data is! List) return [];
    return data.map((item) => AuditLog.fromMap(item)).toList();
  }
}

/// 📝 LOG DE AUDITORÍA
class AuditLog {
  final String action;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const AuditLog({
    required this.action,
    required this.userId,
    required this.timestamp,
    this.details,
  });

  factory AuditLog.fromMap(Map<String, dynamic> data) {
    return AuditLog(
      action: data['action'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: _parseDateTime(data['timestamp']) ?? DateTime.now(),
      details: data['details'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'details': details,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}