// [export_filters_section.dart] - SECCIÓN DE FILTROS ULTRA COMPACTA
// 📁 Ubicación: /lib/widgets/clients/export/export_filters_section.dart
// 🎯 OBJETIVO: Widget compacto con 2 columnas para filtros de exportación

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';
import 'package:intl/intl.dart';

/// 🔍 SECCIÓN DE FILTROS ULTRA COMPACTA
class ExportFiltersSection extends StatelessWidget {
  final Set<ClientStatus> statusFilter;
  final Set<String> tagsFilter;
  final DateTimeRange? dateRange;
  final List<String> availableTags;
  final bool includePersonalInfo;
  final bool includeAddressInfo;
  final bool includeMetrics;
  final bool includeUtf8BOM;
  final bool includeFilterSuffix;
  final Function(Set<ClientStatus>) onStatusFilterChanged;
  final Function(Set<String>) onTagsFilterChanged;
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(bool) onPersonalInfoChanged;
  final Function(bool) onAddressInfoChanged;
  final Function(bool) onMetricsChanged;
  final Function(bool) onUtf8BOMChanged;
  final Function(bool) onFilterSuffixChanged;

  const ExportFiltersSection({
    super.key,
    required this.statusFilter,
    required this.tagsFilter,
    required this.dateRange,
    required this.availableTags,
    required this.includePersonalInfo,
    required this.includeAddressInfo,
    required this.includeMetrics,
    required this.includeUtf8BOM,
    required this.includeFilterSuffix,
    required this.onStatusFilterChanged,
    required this.onTagsFilterChanged,
    required this.onDateRangeChanged,
    required this.onPersonalInfoChanged,
    required this.onAddressInfoChanged,
    required this.onMetricsChanged,
    required this.onUtf8BOMChanged,
    required this.onFilterSuffixChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros de exportación (opcional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aplica filtros para exportar solo los clientes que necesites',
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 20), // ✅ REDUCIDO DE 24 A 20
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ LAYOUT REORGANIZADO EN 2 COLUMNAS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ COLUMNA IZQUIERDA: Estado + Etiquetas + Fecha
                      Expanded(
                        flex: 3, // ✅ MÁS ANCHO PARA MÁS CONTENIDO
                        child: Column(
                          children: [
                            _buildStatusFilters(context),
                            const SizedBox(height: 16),
                            _buildTagsFilters(),
                            const SizedBox(height: 16),
                            _buildDateRangeFilter(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16), // ✅ ESPACIADO ENTRE COLUMNAS

                      // ✅ COLUMNA DERECHA: Solo Opciones Avanzadas
                      Expanded(
                        flex: 2, // ✅ MÁS ESTRECHO PARA OPCIONES
                        child: _buildAdvancedOptions(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING COMPACTO
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // ✅ MENOS REDONDEADO
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: kAccentBlue, size: 16), // ✅ ICONO PEQUEÑO
              const SizedBox(width: 6),
              const Text(
                'Estado',
                style: TextStyle(
                  fontSize: 14, // ✅ TÍTULO COMPACTO
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // ✅ ESPACIADO REDUCIDO
          Wrap(
            spacing: 6, // ✅ ESPACIADO MÍNIMO
            runSpacing: 4,
            children: ClientStatus.values.map((status) {
              final isSelected = statusFilter.contains(status);
              return _buildCompactChip(
                label: status.displayName,
                isSelected: isSelected,
                color: status.color,
                onTap: () {
                  final newFilter = Set<ClientStatus>.from(statusFilter);
                  if (isSelected) {
                    newFilter.remove(status);
                  } else {
                    newFilter.add(status);
                  }
                  onStatusFilterChanged(newFilter);
                  HapticFeedback.lightImpact();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsFilters() {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING COMPACTO
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label,
                  color: kAccentGreen, size: 16), // ✅ ICONO PEQUEÑO
              const SizedBox(width: 6),
              const Text(
                'Etiquetas',
                style: TextStyle(
                  fontSize: 14, // ✅ TÍTULO COMPACTO
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // ✅ ESPACIADO REDUCIDO
          if (availableTags.isNotEmpty)
            Wrap(
              spacing: 6, // ✅ ESPACIADO MÍNIMO
              runSpacing: 4,
              children: availableTags.take(8).map((tag) {
                // ✅ MÁXIMO 8 TAGS
                final isSelected = tagsFilter.contains(tag);
                return _buildCompactChip(
                  label: tag,
                  isSelected: isSelected,
                  color: kAccentGreen,
                  onTap: () {
                    final newFilter = Set<String>.from(tagsFilter);
                    if (isSelected) {
                      newFilter.remove(tag);
                    } else {
                      newFilter.add(tag);
                    }
                    onTagsFilterChanged(newFilter);
                    HapticFeedback.lightImpact();
                  },
                );
              }).toList(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No hay etiquetas disponibles',
                style: TextStyle(
                  fontSize: 12, // ✅ TEXTO PEQUEÑO
                  color: kTextMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING COMPACTO
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range,
                  color: kBrandPurple, size: 16), // ✅ ICONO PEQUEÑO
              const SizedBox(width: 6),
              const Text(
                'Fecha de registro',
                style: TextStyle(
                  fontSize: 14, // ✅ TÍTULO COMPACTO
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // ✅ ESPACIADO REDUCIDO
          InkWell(
            onTap: () => _selectDateRange(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(10), // ✅ PADDING INTERNO COMPACTO
              decoration: BoxDecoration(
                border: Border.all(color: kBorderSoft),
                borderRadius: BorderRadius.circular(8),
                color: dateRange != null
                    ? kBrandPurple.withValues(alpha: 0.05)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: dateRange != null ? kBrandPurple : kTextMuted,
                    size: 14, // ✅ ICONO PEQUEÑO
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateRange != null
                          ? '${_formatDate(dateRange!.start)} - ${_formatDate(dateRange!.end)}'
                          : 'Seleccionar rango',
                      style: TextStyle(
                        fontSize: 12, // ✅ TEXTO COMPACTO
                        color: dateRange != null ? kBrandPurple : kTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (dateRange != null)
                    InkWell(
                      onTap: () => onDateRangeChanged(null),
                      child: Icon(Icons.clear, size: 14, color: kTextMuted),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ PADDING COMPACTO
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings,
                  color: kWarningColor, size: 16), // ✅ ICONO PEQUEÑO
              const SizedBox(width: 6),
              const Text(
                'Opciones avanzadas',
                style: TextStyle(
                  fontSize: 14, // ✅ TÍTULO COMPACTO
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // ✅ ESPACIADO REDUCIDO
          _buildCompactSwitch(
            'Info personal completa',
            includePersonalInfo,
            onPersonalInfoChanged,
          ),
          _buildCompactSwitch(
            'Información de dirección',
            includeAddressInfo,
            onAddressInfoChanged,
          ),
          _buildCompactSwitch(
            'Métricas de rendimiento',
            includeMetrics,
            onMetricsChanged,
          ),
          _buildCompactSwitch(
            'BOM UTF-8 (Excel)',
            includeUtf8BOM,
            onUtf8BOMChanged,
          ),
          _buildCompactSwitch(
            'Filtros en nombre archivo',
            includeFilterSuffix,
            onFilterSuffixChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4), // ✅ PADDING ULTRA COMPACTO
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11, // ✅ TEXTO PEQUEÑO
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : color.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSwitch(
      String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // ✅ ESPACIADO MÍNIMO
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12, // ✅ TEXTO COMPACTO
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8, // ✅ SWITCH MÁS PEQUEÑO
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: kBrandPurple,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kBrandPurple,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked);
      HapticFeedback.lightImpact();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date); // ✅ FORMATO COMPACTO
  }
}
