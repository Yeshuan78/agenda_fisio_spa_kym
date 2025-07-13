// [export_confirm_section.dart] - SECCIÓN DE CONFIRMACIÓN CON 3 COLUMNAS
// 📁 Ubicación: /lib/widgets/clients/export/export_confirm_section.dart
// 🎯 OBJETIVO: Widget compacto para confirmar y ejecutar exportación - LAYOUT 3 COLUMNAS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_service.dart';
import 'package:intl/intl.dart';

/// ✅ SECCIÓN DE CONFIRMACIÓN CON LAYOUT DE 3 COLUMNAS
class ExportConfirmSection extends StatefulWidget {
  final List<ClientModel> clients;
  final ExportFormat selectedFormat;
  final Set<String> selectedFields;
  final Set<ClientStatus> statusFilter;
  final Set<String> tagsFilter;
  final DateTimeRange? dateRange;
  final bool includePersonalInfo;
  final bool includeAddressInfo;
  final bool includeMetrics;
  final bool includeUtf8BOM;
  final bool includeFilterSuffix;
  final ClientExportService exportService;
  final bool isExporting;
  final ExportPreview? currentPreview;
  final Function(ExportPreview) onPreviewGenerated;
  final VoidCallback onExportStarted;
  final Function(ExportResult) onExportCompleted;
  final Function(String) onExportError;

  const ExportConfirmSection({
    super.key,
    required this.clients,
    required this.selectedFormat,
    required this.selectedFields,
    required this.statusFilter,
    required this.tagsFilter,
    required this.dateRange,
    required this.includePersonalInfo,
    required this.includeAddressInfo,
    required this.includeMetrics,
    required this.includeUtf8BOM,
    required this.includeFilterSuffix,
    required this.exportService,
    required this.isExporting,
    required this.currentPreview,
    required this.onPreviewGenerated,
    required this.onExportStarted,
    required this.onExportCompleted,
    required this.onExportError,
  });

  @override
  State<ExportConfirmSection> createState() => _ExportConfirmSectionState();
}

class _ExportConfirmSectionState extends State<ExportConfirmSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confirmar exportación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa la configuración antes de proceder',
            style: TextStyle(
              fontSize: 14,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: 16), // ✅ Reducido de 20 a 16
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ TARJETA CONSOLIDADA EN 3 COLUMNAS
                  _buildConsolidatedSummaryCard(),
                  if (_hasActiveFilters()) ...[
                    const SizedBox(height: 12), // ✅ Reducido de 16 a 12
                    _buildActiveFilters(),
                  ],
                  const SizedBox(height: 16), // ✅ Espacio para el botón
                ],
              ),
            ),
          ),
          _buildActionButtons(), // ✅ Sin SizedBox arriba
        ],
      ),
    );
  }

  /// ✅ TARJETA CONSOLIDADA EN 3 COLUMNAS - LAYOUT QUIRÚRGICO
  Widget _buildConsolidatedSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.08),
            kBrandPurple.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER PRINCIPAL
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kBrandPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.selectedFormat.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen de exportación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ✅ LAYOUT EN 3 COLUMNAS RESPONSIVAS
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcular si usar layout horizontal o vertical
              final useHorizontalLayout = constraints.maxWidth > 600;

              if (useHorizontalLayout) {
                return _buildHorizontalThreeColumns();
              } else {
                return _buildVerticalThreeColumns();
              }
            },
          ),
        ],
      ),
    );
  }

  /// 🔄 LAYOUT HORIZONTAL (PANTALLAS GRANDES)
  Widget _buildHorizontalThreeColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ COLUMNA 1: FORMATO + REGISTROS
        Expanded(
          flex: 1,
          child: _buildColumn1(),
        ),
        const SizedBox(width: 12),

        // ✅ COLUMNA 2: CAMPOS + TAMAÑO
        Expanded(
          flex: 1,
          child: _buildColumn2(),
        ),
        const SizedBox(width: 12),

        // ✅ COLUMNA 3: CAMPOS SELECCIONADOS + OPCIONES
        Expanded(
          flex: 1,
          child: _buildColumn3(),
        ),
      ],
    );
  }

  /// 📱 LAYOUT VERTICAL (PANTALLAS PEQUEÑAS)
  Widget _buildVerticalThreeColumns() {
    return Column(
      children: [
        _buildColumn1(),
        const SizedBox(height: 12),
        _buildColumn2(),
        const SizedBox(height: 12),
        _buildColumn3(),
      ],
    );
  }

  /// 📊 COLUMNA 1: FORMATO + REGISTROS
  Widget _buildColumn1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeader('Información básica', Icons.info_outline),
        const SizedBox(height: 8),
        _buildCompactSummaryItem(
          'Formato',
          widget.selectedFormat.displayName,
          Icons.file_present,
        ),
        const SizedBox(height: 6),
        _buildCompactSummaryItem(
          'Registros',
          '${_getFilteredClientsCount()} clientes',
          Icons.people,
        ),
      ],
    );
  }

  /// 📋 COLUMNA 2: CAMPOS + TAMAÑO
  Widget _buildColumn2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeader('Detalles técnicos', Icons.settings),
        const SizedBox(height: 8),
        _buildCompactSummaryItem(
          'Campos',
          '${widget.selectedFields.length} campos',
          Icons.view_column,
        ),
        const SizedBox(height: 6),
        _buildCompactSummaryItem(
          'Tamaño est.',
          _getEstimatedSize(),
          Icons.storage,
        ),
      ],
    );
  }

  /// 🏷️ COLUMNA 3: CAMPOS SELECCIONADOS + OPCIONES
  Widget _buildColumn3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildColumnHeader('Configuración', Icons.tune),
        const SizedBox(height: 8),

        // CAMPOS SELECCIONADOS COMPACTOS
        Text(
          'Campos seleccionados (${widget.selectedFields.length}):',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        _buildCompactFieldsList(),

        // OPCIONES AVANZADAS SI EXISTEN
        if (_hasAdvancedOptions()) ...[
          const SizedBox(height: 12),
          Text(
            'Opciones avanzadas:',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          _buildCompactAdvancedOptions(),
        ],
      ],
    );
  }

  /// 📋 HEADER DE COLUMNA REUTILIZABLE
  Widget _buildColumnHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kBrandPurple),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
      ],
    );
  }

  /// 📊 ITEM COMPACTO PARA COLUMNAS 1 Y 2
  Widget _buildCompactSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorderSoft.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: kTextSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🏷️ LISTA COMPACTA DE CAMPOS SELECCIONADOS
  Widget _buildCompactFieldsList() {
    // Mostrar solo los primeros 6 campos más importantes
    final displayFields = widget.selectedFields.take(6).toList();
    final hasMore = widget.selectedFields.length > 6;

    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: [
        ...displayFields.map((fieldKey) {
          final field =
              ExportField.getAllFields().firstWhere((f) => f.key == fieldKey);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: kAccentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kAccentBlue.withValues(alpha: 0.3)),
            ),
            child: Text(
              _getShortFieldName(field.displayName),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: kAccentBlue,
              ),
            ),
          );
        }).toList(),

        // Indicador de "más campos"
        if (hasMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: kTextSecondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+${widget.selectedFields.length - 6}',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
          ),
      ],
    );
  }

  /// ⚙️ OPCIONES AVANZADAS COMPACTAS
  Widget _buildCompactAdvancedOptions() {
    final activeOptions = _getAdvancedOptionsList();

    return Column(
      children: activeOptions.take(3).map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 10, color: kAccentGreen),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getShortOptionName(option),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderSoft),
        boxShadow: kSombraCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: kWarningColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Filtros aplicados (${_getActiveFiltersCount()})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Se aplicarán a ${widget.clients.length} clientes base',
            style: TextStyle(
              fontSize: 12,
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ BOTÓN DE EXPORTACIÓN COMPACTO
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // ✅ Reducido padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kBorderSoft)),
        boxShadow: [
          BoxShadow(
            color: kCardShadow.withValues(alpha: 0.1), // ✅ Sombra más sutil
            blurRadius: 4, // ✅ Reducido de 8 a 4
            offset: const Offset(0, -1), // ✅ Reducido de -2 a -1
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: widget.isExporting ? null : _startExport,
        icon: widget.isExporting
            ? const SizedBox(
                width: 14, // ✅ Reducido de 16 a 14
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.download, size: 18), // ✅ Reducido de 20 a 18
        label: Text(
          widget.isExporting
              ? 'Exportando...'
              : 'Exportar ${widget.selectedFormat.displayName}',
          style: const TextStyle(
            fontSize: 14, // ✅ Reducido de 16 a 14
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kBrandPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 24), // ✅ Reducido vertical de 16 a 12
          elevation: 2, // ✅ Reducido de 3 a 2
          minimumSize: const Size(double.infinity, 44), // ✅ Altura mínima fija
        ),
      ),
    );
  }

  // ====================================================================
  // 🔧 MÉTODOS HELPER PARA TEXTOS CORTOS
  // ====================================================================

  /// 📝 ACORTAR NOMBRES DE CAMPOS
  String _getShortFieldName(String fieldName) {
    final shortNames = {
      'Nombre Completo': 'Nombre',
      'Dirección': 'Dir.',
      'Teléfono': 'Tel.',
      'Total de Citas': 'Citas',
      'Ingresos Totales': 'Ingresos',
      'Fecha de Registro': 'Registro',
      'Satisfacción': 'Satisf.',
      'Etiquetas': 'Tags',
    };

    return shortNames[fieldName] ?? fieldName;
  }

  /// ⚙️ ACORTAR NOMBRES DE OPCIONES
  String _getShortOptionName(String optionName) {
    final shortNames = {
      'Información personal completa': 'Info personal',
      'Información de dirección': 'Dirección',
      'Métricas de rendimiento': 'Métricas',
      'BOM UTF-8': 'UTF-8',
      'Sufijo de filtros en nombre': 'Sufijo filtros',
    };

    return shortNames[optionName] ?? optionName;
  }

  List<String> _getAdvancedOptionsList() {
    final options = <String>[];
    if (widget.includePersonalInfo)
      options.add('Información personal completa');
    if (widget.includeAddressInfo) options.add('Información de dirección');
    if (widget.includeMetrics) options.add('Métricas de rendimiento');
    if (widget.includeUtf8BOM) options.add('BOM UTF-8');
    if (widget.includeFilterSuffix) options.add('Sufijo de filtros en nombre');
    return options;
  }

  // ====================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO (SIN CAMBIOS)
  // ====================================================================

  Future<void> _startExport() async {
    if (widget.selectedFields.isEmpty) {
      widget.onExportError('Selecciona al menos un campo para exportar');
      return;
    }

    try {
      final options = _buildExportOptions();
      ExportResult result;

      switch (widget.selectedFormat) {
        case ExportFormat.csv:
          result = await widget.exportService.exportToCSV(
            clients: widget.clients,
            options: options,
          );
          break;
        case ExportFormat.excel:
          result = await widget.exportService.exportToExcel(
            clients: widget.clients,
            options: options,
          );
          break;
        case ExportFormat.pdf:
          result = await widget.exportService.exportToPDF(
            clients: widget.clients,
            options: options,
          );
          break;
        case ExportFormat.json:
          result = await widget.exportService.exportToJSON(
            clients: widget.clients,
            options: options,
          );
          break;
      }

      if (result.isSuccess) {
        HapticFeedback.heavyImpact();
        widget.onExportCompleted(result);
      } else {
        widget.onExportError(
            result.errorMessage ?? 'Error desconocido en exportación');
      }
    } catch (e) {
      widget.onExportError('Error inesperado: $e');
    }
  }

  ExportOptions _buildExportOptions() {
    return ExportOptions(
      format: widget.selectedFormat,
      selectedFields: widget.selectedFields.toList(),
      statusFilter: widget.statusFilter.toList(),
      tagsFilter: widget.tagsFilter.toList(),
      dateRange: widget.dateRange,
      includePersonalInfo: widget.includePersonalInfo,
      includeAddressInfo: widget.includeAddressInfo,
      includeMetrics: widget.includeMetrics,
      includeUtf8BOM: widget.includeUtf8BOM,
      includeFilterSuffix: widget.includeFilterSuffix,
    );
  }

  int _getFilteredClientsCount() {
    try {
      final options = _buildExportOptions();

      var filtered = widget.clients.toList();

      if (options.statusFilter.isNotEmpty) {
        filtered = filtered
            .where((c) => options.statusFilter.contains(c.status))
            .toList();
      }

      if (options.tagsFilter.isNotEmpty) {
        filtered = filtered
            .where((c) =>
                c.tags.any((tag) => options.tagsFilter.contains(tag.label)))
            .toList();
      }

      if (options.dateRange != null) {
        filtered = filtered
            .where((c) =>
                c.createdAt.isAfter(options.dateRange!.start) &&
                c.createdAt.isBefore(options.dateRange!.end))
            .toList();
      }

      return filtered.length;
    } catch (e) {
      return widget.clients.length;
    }
  }

  String _getEstimatedSize() {
    final recordCount = _getFilteredClientsCount();
    final fieldsCount = widget.selectedFields.length;
    final avgFieldSize = widget.selectedFormat == ExportFormat.pdf ? 100 : 30;
    final totalBytes = recordCount * fieldsCount * avgFieldSize;

    if (totalBytes < 1024) return '${totalBytes}B';
    if (totalBytes < 1024 * 1024)
      return '${(totalBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool _hasActiveFilters() {
    return widget.statusFilter.isNotEmpty ||
        widget.tagsFilter.isNotEmpty ||
        widget.dateRange != null;
  }

  bool _hasAdvancedOptions() {
    return widget.includePersonalInfo ||
        widget.includeAddressInfo ||
        widget.includeMetrics ||
        widget.includeUtf8BOM ||
        widget.includeFilterSuffix;
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (widget.statusFilter.isNotEmpty) count++;
    if (widget.tagsFilter.isNotEmpty) count++;
    if (widget.dateRange != null) count++;
    return count;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }
}
