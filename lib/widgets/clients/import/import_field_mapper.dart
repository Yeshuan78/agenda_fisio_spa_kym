// [import_field_mapper.dart] - FIX COMPLETO UI SINCRONIZADA
// 🚨 PROBLEMA: Dropdown no actualiza mappings y UI desincronizada
// ✅ SOLUCIÓN: Fix quirúrgico con forzado de rebuild y sincronización

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'import_models.dart';
import 'dart:math' as math;

/// 🗺️ MAPEADOR DE CAMPOS ENTERPRISE COMPACTO - ✅ FIX COMPLETO
class ImportFieldMapper extends StatefulWidget {
  final List<String> sourceColumns;
  final List<FieldMapping> currentMappings;
  final Function(List<FieldMapping>) onMappingsChanged;
  final Function(MappingConfiguration) onConfigurationChanged;
  final bool showAdvancedOptions;

  const ImportFieldMapper({
    super.key,
    required this.sourceColumns,
    required this.currentMappings,
    required this.onMappingsChanged,
    required this.onConfigurationChanged,
    this.showAdvancedOptions = false,
  });

  @override
  State<ImportFieldMapper> createState() => _ImportFieldMapperState();
}

class _ImportFieldMapperState extends State<ImportFieldMapper>
    with TickerProviderStateMixin {
  late AnimationController _autoMapController;
  late Animation<double> _autoMapAnimation;

  List<FieldMapping> _mappings = [];
  MappingConfiguration? _currentConfig;
  bool _isAutoMapping = false;
  bool _showSummary = true;

  // ✅ FIX: ESTADO DE SINCRONIZACIÓN UI
  int _rebuildCounter = 0;

  @override
  void initState() {
    super.initState();

    _autoMapController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _autoMapAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _autoMapController,
      curve: Curves.easeInOut,
    ));

    _mappings = List.from(widget.currentMappings);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateConfiguration();
    });

    // ✅ DEBUG: Log inicial
    debugPrint('🔧 FieldMapper inicializado con ${_mappings.length} mappings');
  }

  @override
  void dispose() {
    _autoMapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImportFieldMapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMappings != widget.currentMappings) {
      _mappings = List.from(widget.currentMappings);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateConfiguration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactHeader(),
          if (_showSummary) ...[
            const SizedBox(height: 8),
            _buildDiscreteSummary(),
          ],
          const SizedBox(height: 12),
          Expanded(child: _buildDenseMappingInterface()),
          if (widget.showAdvancedOptions) ...[
            const SizedBox(height: 8),
            _buildCompactAdvancedOptions(),
          ],
        ],
      ),
    );
  }

  // ========================================================================
  // 🎨 COMPONENTES COMPACTOS - EXACTAMENTE COMO TU ORIGINAL
  // ========================================================================

  Widget _buildCompactHeader() {
    return Container(
      height: 50,
      child: Row(
        children: [
          const Text(
            'Mapeo de Campos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: kFontFamily,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => setState(() => _showSummary = !_showSummary),
            icon: Icon(
              _showSummary
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 18,
              color: kTextSecondary,
            ),
            tooltip: _showSummary ? 'Ocultar resumen' : 'Mostrar resumen',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
          const Spacer(),
          _buildCompactButton(
            onPressed: _isAutoMapping ? null : _performAutoMapping,
            icon: _isAutoMapping ? Icons.sync : Icons.auto_fix_high,
            label: 'Auto',
            color: kAccentBlue,
            isLoading: _isAutoMapping,
          ),
          const SizedBox(width: 8),
          _buildCompactButton(
            onPressed: _clearAllMappings,
            icon: Icons.clear_all,
            label: 'Limpiar',
            color: kTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    return AnimatedBuilder(
      animation: _autoMapAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isLoading ? _autoMapAnimation.value : 1.0,
          child: SizedBox(
            height: 32,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(icon, size: 14),
              label: Text(
                label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(60, 32),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                elevation: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscreteSummary() {
    if (_currentConfig == null) return const SizedBox.shrink();

    final config = _currentConfig!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _showSummary ? null : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: config.isComplete
              ? kAccentGreen.withValues(alpha: 0.08)
              : kWarningColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: config.isComplete
                ? kAccentGreen.withValues(alpha: 0.2)
                : kWarningColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              config.isComplete
                  ? Icons.check_circle_outline
                  : Icons.warning_amber,
              color: config.isComplete ? kAccentGreen : kWarningColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Text(
                    '${config.mappedColumns}/${config.totalColumns}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: config.isComplete ? kAccentGreen : kWarningColor,
                      fontFamily: kFontFamily,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: config.completionPercentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        config.isComplete ? kAccentGreen : kWarningColor,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (config.autoMappedColumns > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: kAccentBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${config.autoMappedColumns} auto',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: kAccentBlue,
                    fontFamily: kFontFamily,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDenseMappingInterface() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildDenseTargetFields(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildCompactSourceColumns(),
        ),
      ],
    );
  }

  Widget _buildDenseTargetFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: kBrandPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: kBrandPurple, size: 14),
              const SizedBox(width: 6),
              const Text(
                'Campos Sistema',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                  fontFamily: kFontFamily,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              _buildDenseFieldSection(
                'Requeridos',
                TargetFields.requiredFields,
                true,
                kErrorColor,
              ),
              const SizedBox(height: 12),
              _buildDenseFieldSection(
                'Opcionales',
                TargetFields.optionalFields,
                false,
                kTextSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDenseFieldSection(
    String title,
    Map<String, String> fields,
    bool isRequired,
    Color titleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Icon(
                isRequired ? Icons.star : Icons.info_outline,
                color: titleColor,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  fontFamily: kFontFamily,
                ),
              ),
            ],
          ),
        ),
        ...fields.entries.map((entry) => _buildDenseFieldMapping(
              entry.key,
              entry.value,
              isRequired,
            )),
      ],
    );
  }

  /// ✅ FIX CRÍTICO: DROPDOWN CON KEY ÚNICA Y DEBUG COMPLETO
  Widget _buildDenseFieldMapping(
      String fieldKey, String fieldLabel, bool isRequired) {
    final currentMapping = _mappings.firstWhere(
      (m) => m.targetField == fieldKey,
      orElse: () => FieldMapping(
        sourceColumn: '',
        targetField: fieldKey,
        isRequired: isRequired,
      ),
    );

    final isMapped = currentMapping.sourceColumn.isNotEmpty;
    final isAutoMapped = currentMapping.isAutoMapped;

    // ✅ FIX CRÍTICO: DEBUG PARA APELLIDOS
    if (fieldKey == 'apellidos') {
      debugPrint(
          '🔍 UI STATE: Apellidos -> currentMapping.sourceColumn="${currentMapping.sourceColumn}"');
      debugPrint(
          '🔍 UI STATE: isMapped=$isMapped, rebuildCounter=$_rebuildCounter');
      debugPrint('🔍 UI STATE: Available columns=${widget.sourceColumns}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMapped
            ? (isRequired
                ? kAccentGreen.withValues(alpha: 0.08)
                : kAccentGreen.withValues(alpha: 0.05))
            : (isRequired && !isMapped
                ? kErrorColor.withValues(alpha: 0.08)
                : Colors.grey.shade50),
        border: Border.all(
          color: isMapped
              ? kAccentGreen
              : (isRequired && !isMapped ? kErrorColor : kBorderSoft),
          width: isMapped ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isRequired)
                const Icon(Icons.star, color: kErrorColor, size: 10),
              if (isRequired) const SizedBox(width: 3),
              if (isAutoMapped)
                const Icon(Icons.auto_fix_high, color: kAccentBlue, size: 10),
              if (isAutoMapped) const SizedBox(width: 3),
              Expanded(
                child: Text(
                  fieldLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isMapped
                        ? kAccentGreen
                        : (isRequired ? kErrorColor : Colors.black87),
                    fontFamily: kFontFamily,
                  ),
                ),
              ),
              Icon(
                isMapped ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isMapped ? kAccentGreen : kTextMuted,
                size: 12,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: DropdownButtonFormField<String>(
              // ✅ FIX CRÍTICO: KEY ÚNICA PARA FORZAR REBUILD
              key: ValueKey(
                  '${fieldKey}_${currentMapping.sourceColumn}_$_rebuildCounter'),
              value: currentMapping.sourceColumn.isNotEmpty
                  ? currentMapping.sourceColumn
                  : null,
              decoration: InputDecoration(
                hintText: 'Seleccionar...',
                hintStyle: const TextStyle(fontSize: 11, color: kTextMuted),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: kBorderSoft, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: isMapped ? kAccentGreen : kBorderSoft,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: kBrandPurple, width: 1.5),
                ),
              ),
              style: const TextStyle(fontSize: 11),
              dropdownColor: Colors.white,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    '(No mapear)',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                        color: kTextMuted),
                  ),
                ),
                ...widget.sourceColumns
                    .map((header) => DropdownMenuItem<String>(
                          value: header,
                          child: Tooltip(
                            message: header,
                            child: Text(
                              header.length > 30
                                  ? '${header.substring(0, 30)}...'
                                  : header,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )),
              ],
              onChanged: (value) {
                debugPrint('🔧 UI FIX: Dropdown changed for $fieldKey: $value');
                _updateFieldMapping(fieldKey, value, isRequired);
              },
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            ),
          ),
          if (isRequired && !isMapped) ...[
            const SizedBox(height: 3),
            const Text(
              'Campo obligatorio',
              style: TextStyle(
                fontSize: 10,
                color: kErrorColor,
                fontFamily: kFontFamily,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactSourceColumns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: kAccentBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(Icons.table_chart, color: kAccentBlue, size: 14),
              const SizedBox(width: 6),
              Text(
                'Columnas (${widget.sourceColumns.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kAccentBlue,
                  fontFamily: kFontFamily,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: widget.sourceColumns.length,
            itemBuilder: (context, index) {
              final column = widget.sourceColumns[index];
              final isMapped = _mappings.any((m) => m.sourceColumn == column);

              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isMapped
                      ? kAccentGreen.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  border: Border.all(
                    color: isMapped ? kAccentGreen : kBorderSoft,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMapped
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isMapped ? kAccentGreen : kTextMuted,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        column,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: isMapped ? kAccentGreen : Colors.black87,
                          fontFamily: kFontFamily,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorderSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings, color: kTextSecondary, size: 14),
          const SizedBox(width: 6),
          const Text(
            'Avanzado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kTextSecondary,
              fontFamily: kFontFamily,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 28,
            child: OutlinedButton.icon(
              onPressed: _exportMappingTemplate,
              icon: const Icon(Icons.download, size: 12),
              label: const Text('Export', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kAccentBlue,
                side: const BorderSide(color: kAccentBlue, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            height: 28,
            child: OutlinedButton.icon(
              onPressed: _importMappingTemplate,
              icon: const Icon(Icons.upload, size: 12),
              label: const Text('Import', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: kAccentGreen,
                side: const BorderSide(color: kAccentGreen, width: 1),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // ✅ FIX CRÍTICO: ACTUALIZACIÓN DE MAPPINGS CON SINCRONIZACIÓN UI
  // ========================================================================

  /// ✅ FIX CRÍTICO: ACTUALIZAR MAPPING DE CAMPO CON SINCRONIZACIÓN UI
  void _updateFieldMapping(
      String targetField, String? sourceColumn, bool isRequired) {
    debugPrint('🔧 FIX UI: Actualizando $targetField -> "$sourceColumn"');

    setState(() {
      final existingIndex =
          _mappings.indexWhere((m) => m.targetField == targetField);

      if (existingIndex != -1) {
        // ✅ ACTUALIZAR MAPPING EXISTENTE
        _mappings[existingIndex] = _mappings[existingIndex].copyWith(
          sourceColumn: sourceColumn ?? '',
          isAutoMapped: false,
        );
        debugPrint('✅ UI FIX: Mapping actualizado en índice $existingIndex');
      } else {
        // ✅ CREAR NUEVO MAPPING
        _mappings.add(FieldMapping(
          sourceColumn: sourceColumn ?? '',
          targetField: targetField,
          isRequired: isRequired,
          isAutoMapped: false,
          validators: TargetFields.getValidators(targetField),
          displayName: TargetFields.allFields[targetField],
        ));
        debugPrint('✅ UI FIX: Nuevo mapping creado');
      }

      // ✅ FIX CRÍTICO: INCREMENTAR CONTADOR PARA FORZAR REBUILD
      _rebuildCounter++;
    });

    // ✅ FIX CRÍTICO: DOBLE CALLBACK PARA SINCRONIZACIÓN
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          // Forzar segundo rebuild para sincronización completa
          _rebuildCounter++;
        });

        _updateConfiguration();
        widget.onMappingsChanged(_mappings);

        debugPrint('✅ UI FIX: UI rebuild forzado (counter: $_rebuildCounter)');
        debugPrint('🔧 UI FIX: Mappings después del cambio:');
        for (final mapping in _mappings) {
          debugPrint('  ${mapping.targetField} -> "${mapping.sourceColumn}"');
        }
      }
    });
  }

  // ========================================================================
  // 🔧 RESTO DE MÉTODOS SIN CAMBIOS
  // ========================================================================

  Future<void> _performAutoMapping() async {
    setState(() => _isAutoMapping = true);
    _autoMapController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 600));

    final newMappings = <FieldMapping>[];
    int autoMappedCount = 0;
    double totalScore = 0.0;
    const double minAutoMappingConfidence = 0.7;

    for (final entry in TargetFields.allFields.entries) {
      final targetField = entry.key;
      final isRequired = TargetFields.requiredFields.containsKey(targetField);

      String? bestMatch;
      double bestScore = 0.0;

      for (final header in widget.sourceColumns) {
        final score = _calculateMappingScore(header, targetField);
        if (score > bestScore && score >= minAutoMappingConfidence) {
          bestScore = score;
          bestMatch = header;
        }
      }

      if (bestMatch != null) {
        autoMappedCount++;
        totalScore += bestScore;
      }

      newMappings.add(FieldMapping(
        sourceColumn: bestMatch ?? '',
        targetField: targetField,
        isRequired: isRequired,
        isAutoMapped: bestMatch != null,
        validators: TargetFields.getValidators(targetField),
        displayName: entry.value,
      ));
    }

    setState(() {
      _mappings = newMappings;
      _isAutoMapping = false;
      _rebuildCounter++; // ✅ FIX: Forzar rebuild después de auto-mapping
    });

    _autoMapController.stop();
    _autoMapController.reset();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateConfiguration();
      widget.onMappingsChanged(_mappings);
    });

    final accuracy =
        autoMappedCount > 0 ? (totalScore / autoMappedCount) * 100 : 0.0;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.auto_fix_high, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$autoMappedCount campos detectados (${accuracy.toInt()}%)',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: kAccentBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  double _calculateMappingScore(String sourceColumn, String targetField) {
    final source = sourceColumn.toLowerCase().trim();
    final patterns = TargetFields.fieldPatterns[targetField] ?? [];

    double maxScore = 0.0;

    for (final pattern in patterns) {
      final patternLower = pattern.toLowerCase();

      if (source == patternLower) {
        maxScore = 1.0;
        break;
      }

      if (source.contains(patternLower)) {
        maxScore = math.max(maxScore, 0.8);
      }

      final sourceWords = source.split(RegExp(r'[_\s-]+'));
      final patternWords = patternLower.split(RegExp(r'[_\s-]+'));

      for (final sourceWord in sourceWords) {
        for (final patternWord in patternWords) {
          if (sourceWord == patternWord) {
            maxScore = math.max(maxScore, 0.7);
          }
        }
      }
    }

    return maxScore;
  }

  void _clearAllMappings() {
    setState(() {
      _mappings.clear();

      for (final entry in TargetFields.allFields.entries) {
        _mappings.add(FieldMapping(
          sourceColumn: '',
          targetField: entry.key,
          isRequired: TargetFields.requiredFields.containsKey(entry.key),
          validators: TargetFields.getValidators(entry.key),
          displayName: entry.value,
        ));
      }

      _rebuildCounter++; // ✅ FIX: Forzar rebuild después de limpiar
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateConfiguration();
      widget.onMappingsChanged(_mappings);
    });
  }

  void _updateConfiguration() {
    if (!mounted) return;

    final autoMappedColumns = _mappings.where((m) => m.isAutoMapped).length;
    final missingRequired = TargetFields.requiredFields.keys
        .where((field) => !_mappings
            .any((m) => m.targetField == field && m.sourceColumn.isNotEmpty))
        .toList();

    final unmappedColumns = widget.sourceColumns
        .where((col) => !_mappings.any((m) => m.sourceColumn == col))
        .toList();

    double autoMappingAccuracy = 0.0;
    if (autoMappedColumns > 0) {
      double totalScore = 0.0;
      int count = 0;

      for (final mapping in _mappings.where((m) => m.isAutoMapped)) {
        totalScore +=
            _calculateMappingScore(mapping.sourceColumn, mapping.targetField);
        count++;
      }

      autoMappingAccuracy = count > 0 ? (totalScore / count) * 100 : 0.0;
    }

    final newConfig = MappingConfiguration(
      mappings: _mappings.where((m) => m.sourceColumn.isNotEmpty).toList(),
      unmappedColumns: unmappedColumns,
      missingRequiredFields: missingRequired,
      totalColumns: widget.sourceColumns.length,
      autoMappingAccuracy: autoMappingAccuracy,
    );

    if (_currentConfig == null ||
        _currentConfig!.mappedColumns != newConfig.mappedColumns ||
        _currentConfig!.isComplete != newConfig.isComplete) {
      setState(() => _currentConfig = newConfig);
      widget.onConfigurationChanged(newConfig);
    }
  }

  void _exportMappingTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportar template en desarrollo'),
        backgroundColor: kWarningColor,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _importMappingTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Importar template en desarrollo'),
        backgroundColor: kWarningColor,
        duration: Duration(seconds: 1),
      ),
    );
  }
}
