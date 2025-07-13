// [import_validation_section.dart] - FIX CRÍTICO: HEADERS CORRECTOS AL VALIDADOR
// 🚨 PROBLEMA: El validador recibe datos en lugar de headers
// ✅ SOLUCIÓN: Extraer headers del parseResult, no de sampleData

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'import_models.dart';
import 'data_validator_service.dart';

/// 📝 ENTRADA DE LOG SIMPLE
class LogEntry {
  final String message;
  final DateTime timestamp;
  final ImportStatus level;

  LogEntry({
    required this.message,
    required this.timestamp,
    required this.level,
  });
}

/// ✅ SECCIÓN DE VALIDACIÓN EN TIEMPO REAL COMPACTA - ✅ CON FIX DE HEADERS
class ImportValidationSection extends StatefulWidget {
  final List<List<String>> sampleData;
  final List<String> headers; // ✅ NUEVO: Headers reales del parser
  final List<FieldMapping> mappings;
  final Function(ValidationResult)? onValidationChanged;
  final bool isValidating;

  const ImportValidationSection({
    super.key,
    required this.sampleData,
    required this.headers, // ✅ NUEVO: Parámetro obligatorio
    required this.mappings,
    this.onValidationChanged,
    this.isValidating = false,
  });

  @override
  State<ImportValidationSection> createState() =>
      _ImportValidationSectionState();
}

class _ImportValidationSectionState extends State<ImportValidationSection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final DataValidatorService _validator = DataValidatorService();
  ValidationResult? _currentValidation;
  bool _isValidating = false;
  bool _showDetails = true;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Validar inmediatamente si hay datos
    if (widget.sampleData.isNotEmpty && widget.mappings.isNotEmpty) {
      _performValidation();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImportValidationSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-validar si cambió el mapeo o los headers
    if (oldWidget.mappings != widget.mappings ||
        oldWidget.headers != widget.headers) {
      _performValidation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactHeader(),
          const SizedBox(height: 12),
          if (_isValidating)
            _buildCompactValidatingIndicator()
          else if (_currentValidation != null)
            Expanded(child: _buildCompactValidationResults())
          else
            _buildCompactNoValidationState(),
        ],
      ),
    );
  }

  // ========================================================================
  // ✅ FIX CRÍTICO: VALIDACIÓN CON HEADERS CORRECTOS
  // ========================================================================

  /// ✅ REALIZAR VALIDACIÓN CON HEADERS Y DATOS NORMALIZADOS
  Future<void> _performValidation() async {
    debugPrint(
        '🔍 VALIDATION INPUT: headers=${widget.headers.take(5)}, sampleData=${widget.sampleData.take(2)}');

    if (widget.sampleData.isEmpty || widget.mappings.isEmpty) {
      setState(() {
        _currentValidation = null;
      });
      return;
    }

    final activeMappings =
        widget.mappings.where((m) => m.sourceColumn.isNotEmpty).toList();

    if (activeMappings.isEmpty) {
      setState(() {
        _currentValidation = null;
      });
      return;
    }

    setState(() {
      _isValidating = true;
    });

    _pulseController.repeat(reverse: true);

    try {
      // ✅ FIX CRÍTICO: NORMALIZAR SAMPLE DATA CON HEADERS
      final normalizedSampleData = <List<String>>[];

      for (final row in widget.sampleData) {
        final normalizedRow = <String>[];

        // Asegurar que cada fila tenga la misma longitud que headers
        for (int i = 0; i < widget.headers.length; i++) {
          if (i < row.length) {
            normalizedRow.add(row[i]);
          } else {
            normalizedRow.add(''); // Rellenar con vacío si faltan columnas
          }
        }

        normalizedSampleData.add(normalizedRow);
      }

      debugPrint('🔧 FIX: Headers length: ${widget.headers.length}');
      debugPrint(
          '🔧 FIX: Original first row length: ${widget.sampleData.isNotEmpty ? widget.sampleData.first.length : 0}');
      debugPrint(
          '🔧 FIX: Normalized first row length: ${normalizedSampleData.isNotEmpty ? normalizedSampleData.first.length : 0}');
      debugPrint('🔧 FIX: Usando headers del parser: ${widget.headers}');
      debugPrint(
          '🔧 FIX: Mappings activos: ${activeMappings.map((m) => '${m.targetField} -> "${m.sourceColumn}"').join(', ')}');

      // ✅ USAR DATOS NORMALIZADOS
      final result = await _validator.validateData(
        normalizedSampleData, // ✅ DATOS NORMALIZADOS
        activeMappings,
        headers: widget.headers, // ✅ HEADERS COMPLETOS
      );

      if (mounted) {
        setState(() {
          _currentValidation = result;
          _isValidating = false;
        });

        _pulseController.stop();
        _pulseController.reset();

        widget.onValidationChanged?.call(result);

        debugPrint('✅ FIX: Validación completada con datos normalizados');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });

        _pulseController.stop();
        _pulseController.reset();

        debugPrint('❌ Error en validación: $e');
      }
    }
  }

  // ========================================================================
  // 🎨 COMPONENTES COMPACTOS (SIN CAMBIOS)
  // ========================================================================

  Widget _buildCompactHeader() {
    return Container(
      height: 44,
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: _getHeaderColor(),
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Validación en Tiempo Real',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getHeaderColor(),
                fontFamily: kFontFamily,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showDetails = !_showDetails),
            icon: Icon(
              _showDetails
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 16,
              color: kTextSecondary,
            ),
            tooltip: _showDetails ? 'Ocultar detalles' : 'Mostrar detalles',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          if (_currentValidation != null) _buildCompactValidationBadge(),
        ],
      ),
    );
  }

  Widget _buildCompactValidationBadge() {
    final validation = _currentValidation!;
    Color badgeColor;
    String badgeText;

    if (!validation.hasErrors && !validation.hasWarnings) {
      badgeColor = kAccentGreen;
      badgeText = '✓';
    } else if (validation.hasErrors) {
      badgeColor = kErrorColor;
      badgeText = '${validation.errors.length}';
    } else {
      badgeColor = kWarningColor;
      badgeText = '${validation.warnings.length}';
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Center(
        child: Text(
          badgeText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: badgeColor,
            fontFamily: kFontFamily,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactValidatingIndicator() {
    return Container(
      height: 80,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kBrandPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kBrandPurple),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Validando...',
              style: TextStyle(
                fontSize: 12,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactNoValidationState() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              color: kTextMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Mapea campos para\nver validación',
              style: TextStyle(
                fontSize: 12,
                color: kTextMuted,
                fontFamily: kFontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactValidationResults() {
    final validation = _currentValidation!;

    return Column(
      children: [
        _buildUltraCompactSummary(validation),
        const SizedBox(height: 12),
        if (_showDetails)
          Expanded(child: _buildCompactValidationDetails(validation))
        else
          _buildCollapsedSummary(validation),
      ],
    );
  }

  Widget _buildUltraCompactSummary(ValidationResult validation) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _getValidationSummaryColor().withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: _getValidationSummaryColor().withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildMiniSummaryCard(
                      'Válidas',
                      '${validation.validRows}',
                      kAccentGreen,
                      Icons.check_circle)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildMiniSummaryCard('Errores',
                      '${validation.errorRows}', kErrorColor, Icons.error)),
              const SizedBox(width: 6),
              Expanded(
                  child: _buildMiniSummaryCard(
                      'Avisos',
                      '${validation.warningRows}',
                      kWarningColor,
                      Icons.warning)),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Éxito',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kTextSecondary,
                      fontFamily: kFontFamily,
                    ),
                  ),
                  Text(
                    '${validation.successRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getSuccessRateColor(validation.successRate),
                      fontFamily: kFontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: validation.successRate / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                    _getSuccessRateColor(validation.successRate)),
                minHeight: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: kFontFamily,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontFamily: kFontFamily,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSummary(ValidationResult validation) {
    if (validation.hasErrors || validation.hasWarnings) {
      final issueCount = validation.errors.length + validation.warnings.length;
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (validation.hasErrors ? kErrorColor : kWarningColor)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: (validation.hasErrors ? kErrorColor : kWarningColor)
                  .withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              validation.hasErrors ? Icons.error : Icons.warning,
              color: validation.hasErrors ? kErrorColor : kWarningColor,
              size: 14,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$issueCount ${validation.hasErrors ? "errores" : "advertencias"} encontrados',
                style: TextStyle(
                  fontSize: 11,
                  color: validation.hasErrors ? kErrorColor : kWarningColor,
                  fontFamily: kFontFamily,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kAccentGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kAccentGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kAccentGreen, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Todos los datos son válidos',
              style: TextStyle(
                fontSize: 11,
                color: kAccentGreen,
                fontFamily: kFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactValidationDetails(ValidationResult validation) {
    final allIssues = [
      ...validation.errors,
      ...validation.warnings,
      ...validation.infos
    ];

    if (allIssues.isEmpty) {
      return _buildCompactNoIssuesFound();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalles (${allIssues.length})',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
            fontFamily: kFontFamily,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            itemCount: allIssues.length,
            itemBuilder: (context, index) {
              final issue = allIssues[index];
              return _buildCompactValidationIssueCard(issue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNoIssuesFound() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kAccentGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.verified, color: kAccentGreen, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              'Excelente!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kAccentGreen,
                fontFamily: kFontFamily,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Datos válidos',
              style: TextStyle(
                fontSize: 12,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactValidationIssueCard(ValidationError issue) {
    Color cardColor;
    IconData cardIcon;

    switch (issue.level) {
      case ValidationLevel.error:
        cardColor = kErrorColor;
        cardIcon = Icons.error;
        break;
      case ValidationLevel.warning:
        cardColor = kWarningColor;
        cardIcon = Icons.warning;
        break;
      case ValidationLevel.info:
        cardColor = kAccentBlue;
        cardIcon = Icons.info;
        break;
    }

    Widget? phonePreview;
    if (issue.columnName.toLowerCase().contains('telefono') ||
        issue.columnName.toLowerCase().contains('phone')) {
      phonePreview = _buildPhonePreview(issue.originalValue);
    }

    // ✅ FIX CRÍTICO: DISPLAY CORRECTO DE UBICACIÓN
    String locationDisplay;
    if (issue.rowIndex >= 0) {
      // Mostrar fila + campo en lugar de solo "F1"
      locationDisplay = 'Fila ${issue.displayRowNumber}';
    } else {
      locationDisplay = 'General';
    }

    // ✅ FIX: NOMBRE DEL CAMPO MÁS CLARO
    String fieldDisplay = issue.columnName;

    // Mapear nombres técnicos a nombres amigables
    switch (issue.columnName.toLowerCase()) {
      case 'apellidos':
        fieldDisplay = 'Apellidos';
        break;
      case 'nombre':
        fieldDisplay = 'Nombre';
        break;
      case 'email':
        fieldDisplay = 'Email';
        break;
      case 'telefono':
        fieldDisplay = 'Teléfono';
        break;
      case 'empresa':
        fieldDisplay = 'Empresa';
        break;
      case 'direccion':
        fieldDisplay = 'Dirección';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cardColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cardIcon, color: cardColor, size: 12),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  locationDisplay,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: cardColor,
                    fontFamily: kFontFamily,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  fieldDisplay, // ✅ FIX: Usar nombre amigable
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: cardColor,
                    fontFamily: kFontFamily,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            issue.message,
            style: TextStyle(
              fontSize: 11,
              color: cardColor,
              fontFamily: kFontFamily,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // ✅ FIX CRÍTICO: MOSTRAR VALOR ACTUAL Y CONTEXTO
          if (issue.originalValue.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Valor: "${issue.originalValue.length > 20 ? "${issue.originalValue.substring(0, 20)}..." : issue.originalValue}"',
              style: TextStyle(
                fontSize: 9,
                color: cardColor.withValues(alpha: 0.7),
                fontFamily: kFontFamily,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (issue.level == ValidationLevel.warning &&
              fieldDisplay == 'Apellidos') ...[
            // ✅ CASO ESPECIAL: Apellidos vacíos
            const SizedBox(height: 2),
            Text(
              'Valor: (vacío)',
              style: TextStyle(
                fontSize: 9,
                color: cardColor.withValues(alpha: 0.7),
                fontFamily: kFontFamily,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: kAccentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: kAccentBlue, size: 8),
                  SizedBox(width: 3),
                  Text(
                    'Se importará sin apellidos',
                    style: TextStyle(
                      fontSize: 8,
                      color: kAccentBlue,
                      fontFamily: kFontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (phonePreview != null) ...[
            const SizedBox(height: 4),
            phonePreview,
          ],
          if (issue.suggestedFix != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: cardColor, size: 10),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      issue.suggestedFix!,
                      style: TextStyle(
                        fontSize: 9,
                        color: cardColor,
                        fontFamily: kFontFamily,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhonePreview(String originalPhone) {
    if (originalPhone.trim().isEmpty) return const SizedBox.shrink();

    try {
      final normalized =
          InternationalPhoneValidator.normalizeForStorage(originalPhone);
      final formatted =
          InternationalPhoneValidator.formatForDisplay(originalPhone);
      final country = InternationalPhoneValidator.detectCountry(originalPhone);

      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: kAccentBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: kAccentBlue.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_android, color: kAccentBlue, size: 10),
                const SizedBox(width: 4),
                Text(
                  'Se procesará como:',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: kAccentBlue,
                    fontFamily: kFontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Storage: $normalized',
              style: TextStyle(
                fontSize: 8,
                color: kAccentBlue,
                fontFamily: kFontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Display: $formatted',
              style: TextStyle(
                fontSize: 8,
                color: kAccentBlue,
                fontFamily: kFontFamily,
              ),
            ),
            if (country != null)
              Text(
                'País: $country',
                style: TextStyle(
                  fontSize: 8,
                  color: kAccentBlue,
                  fontFamily: kFontFamily,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kWarningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Error procesando teléfono',
          style: TextStyle(
            fontSize: 8,
            color: kWarningColor,
            fontFamily: kFontFamily,
          ),
        ),
      );
    }
  }

  // ========================================================================
  // 🎨 HELPERS DE COLORES (SIN CAMBIOS)
  // ========================================================================

  Color _getHeaderColor() {
    if (_currentValidation == null) return kTextSecondary;
    if (_currentValidation!.hasErrors) return kErrorColor;
    if (_currentValidation!.hasWarnings) return kWarningColor;
    return kAccentGreen;
  }

  Color _getValidationSummaryColor() {
    if (_currentValidation == null) return kTextSecondary;
    if (_currentValidation!.hasErrors) return kErrorColor;
    if (_currentValidation!.hasWarnings) return kWarningColor;
    return kAccentGreen;
  }

  Color _getSuccessRateColor(double successRate) {
    if (successRate >= 90) return kAccentGreen;
    if (successRate >= 70) return kWarningColor;
    return kErrorColor;
  }
}
