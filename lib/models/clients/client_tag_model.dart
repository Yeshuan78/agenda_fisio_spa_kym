// [client_tag_model.dart] - SISTEMA DE ETIQUETAS
// 📁 Ubicación: /lib/models/clients/client_tag_model.dart
// 🎯 OBJETIVO: Modelo de etiquetas de cliente

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'client_enums.dart';

/// 🏷️ ETIQUETA DE CLIENTE
class ClientTag {
  final String label;
  final String? color;
  final TagType type;
  final DateTime createdAt;
  final String? createdBy;

  const ClientTag({
    required this.label,
    this.color,
    required this.type,
    required this.createdAt,
    this.createdBy,
  });

  factory ClientTag.fromMap(Map<String, dynamic> data) {
    return ClientTag(
      label: data['label'] ?? '',
      color: data['color'],
      type: TagType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => TagType.custom,
      ),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      createdBy: data['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'color': color,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  Color get displayColor {
    if (color != null) {
      return Color(int.parse(color!.replaceFirst('#', '0xFF')));
    }
    return _getDefaultColorForType();
  }

  Color _getDefaultColorForType() {
    switch (type) {
      case TagType.base:
        return _getBaseTagColor(label);
      case TagType.custom:
        return Colors.purple.shade300;
      case TagType.system:
        return Colors.blue.shade300;
    }
  }

  Color _getBaseTagColor(String label) {
    switch (label.toLowerCase()) {
      case 'vip':
        return Colors.purple.shade600;
      case 'corporativo':
        return Colors.blue.shade600;
      case 'nuevo':
        return Colors.green.shade600;
      case 'recurrente':
        return Colors.amber.shade600;
      case 'promoción':
        return Colors.orange.shade600;
      case 'consentido':
        return Colors.pink.shade600;
      case 'especial':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  ClientTag copyWith({
    String? label,
    String? color,
    TagType? type,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return ClientTag(
      label: label ?? this.label,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
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