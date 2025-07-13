// [export_fields_selector.dart] - SELECTOR DE CAMPOS ULTRA COMPACTO
// 📁 Ubicación: /lib/widgets/clients/export/export_fields_selector.dart
// 🎯 OBJETIVO: Campos compactos en 2 columnas para aprovechar espacio

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/export/export_models.dart';

/// 📋 SELECTOR DE CAMPOS ULTRA COMPACTO
class ExportFieldsSelector extends StatelessWidget {
  final Set<String> selectedFields;
  final Function(Set<String>) onFieldsChanged;

  const ExportFieldsSelector({
    super.key,
    required this.selectedFields,
    required this.onFieldsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allFields = ExportField.getAllFields();
    final requiredFields = allFields.where((f) => f.isRequired).toList();
    final optionalFields = allFields.where((f) => !f.isRequired).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20), // ✅ REDUCIDO DE 24 A 20
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildQuickSelectionButtons(), // ✅ MOVIDO ARRIBA
                  const SizedBox(height: 20),
                  _buildRequiredFieldsSection(requiredFields),
                  const SizedBox(height: 24), // ✅ REDUCIDO DE 32 A 24
                  _buildOptionalFieldsSection(optionalFields),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona los campos a exportar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige qué información incluir en tu exportación',
          style: TextStyle(
            fontSize: 14,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 12), // ✅ REDUCIDO DE 16 A 12
        Container(
          padding: const EdgeInsets.all(10), // ✅ REDUCIDO DE 12 A 10
          decoration: BoxDecoration(
            color: kInfoColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kInfoColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: kInfoColor, size: 16), // ✅ REDUCIDO DE 18 A 16
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Los campos marcados como requeridos siempre se incluyen',
                  style: TextStyle(
                    fontSize: 11, // ✅ REDUCIDO DE 12 A 11
                    color: kInfoColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredFieldsSection(List<ExportField> requiredFields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star,
                color: kWarningColor, size: 18), // ✅ REDUCIDO DE 20 A 18
            const SizedBox(width: 8),
            const Text(
              'Campos requeridos',
              style: TextStyle(
                fontSize: 15, // ✅ REDUCIDO DE 16 A 15
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // ✅ REDUCIDO DE 12 A 10

        // ✅ GRID COMPACTO PARA CAMPOS REQUERIDOS
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // ✅ 3 COLUMNAS
            crossAxisSpacing: 8,
            mainAxisSpacing: 6, // ✅ ESPACIADO MÍNIMO
            childAspectRatio: 5.5, // ✅ MÁS BAJO (era 4.0)
          ),
          itemCount: requiredFields.length,
          itemBuilder: (context, index) {
            return _buildCompactFieldTile(requiredFields[index], true);
          },
        ),
      ],
    );
  }

  Widget _buildOptionalFieldsSection(List<ExportField> optionalFields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune,
                color: kAccentBlue, size: 18), // ✅ REDUCIDO DE 20 A 18
            const SizedBox(width: 8),
            Text(
              'Campos opcionales (${selectedFields.where((f) => !_isRequired(f)).length}/${optionalFields.length})',
              style: const TextStyle(
                fontSize: 15, // ✅ REDUCIDO DE 16 A 15
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // ✅ REDUCIDO DE 12 A 10

        // ✅ GRID COMPACTO PARA CAMPOS OPCIONALES
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // ✅ 3 COLUMNAS
            crossAxisSpacing: 8,
            mainAxisSpacing: 6, // ✅ ESPACIADO MÍNIMO
            childAspectRatio: 5.5, // ✅ MÁS BAJO (era 4.0)
          ),
          itemCount: optionalFields.length,
          itemBuilder: (context, index) {
            return _buildCompactFieldTile(optionalFields[index], false);
          },
        ),
      ],
    );
  }

  Widget _buildCompactFieldTile(ExportField field, bool isRequired) {
    final isSelected = selectedFields.contains(field.key);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? kBrandPurple.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(8), // ✅ REDUCIDO DE 12 A 8
        border: Border.all(
          color: isSelected ? kBrandPurple.withValues(alpha: 0.3) : kBorderSoft,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRequired ? null : () => _toggleField(field.key, !isSelected),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3), // ✅ PADDING VERTICAL REDUCIDO
            child: Row(
              children: [
                // ✅ CHECKBOX O ICONO COMPACTO
                SizedBox(
                  width: 20, // ✅ ANCHO FIJO PARA ALINEACIÓN
                  height: 20,
                  child: isRequired
                      ? Icon(Icons.lock_outline, color: kTextMuted, size: 14)
                      : Checkbox(
                          value: isSelected,
                          onChanged: (value) =>
                              _toggleField(field.key, value ?? false),
                          activeColor: kBrandPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact, // ✅ COMPACTO
                        ),
                ),
                const SizedBox(width: 8),

                // ✅ ICONO DEL CAMPO
                Icon(
                  _getFieldIcon(field.key),
                  color: isRequired ? kTextMuted : kBrandPurple,
                  size: 14, // ✅ ICONO PEQUEÑO
                ),
                const SizedBox(width: 6),

                // ✅ TEXTO COMPACTO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        field.displayName,
                        style: TextStyle(
                          fontSize: 12, // ✅ REDUCIDO DE 14 A 12
                          fontWeight: FontWeight.w600,
                          color: isRequired ? kTextMuted : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        field.description,
                        style: TextStyle(
                          fontSize: 9, // ✅ ULTRA PEQUEÑO PARA DESCRIPCIÓN
                          color: isRequired ? kTextMuted : kTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectionButtons() {
    return Row(
      children: [
        Icon(Icons.flash_on, color: kBrandPurple, size: 14),
        const SizedBox(width: 6),
        const Text(
          'Selección rápida:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12), // ✅ ESPACIADO ENTRE TÍTULO Y BOTONES
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildQuickButton('Básico', () => _selectBasicFields()),
              _buildQuickButton('Completo', () => _selectAllFields()),
              _buildQuickButton('Contacto', () => _selectContactFields()),
              _buildQuickButton('Métricas', () => _selectMetricsFields()),
              _buildQuickButton('Limpiar', () => _clearOptionalFields()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: kBrandPurple, width: 1),
        foregroundColor: kBrandPurple,
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4), // ✅ PADDING ULTRA COMPACTO
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(0, 24), // ✅ ALTURA ULTRA COMPACTA
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10, // ✅ TEXTO ULTRA PEQUEÑO
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS DE LÓGICA (SIN CAMBIOS)
  // ====================================================================

  void _toggleField(String fieldKey, bool isSelected) {
    final newSelection = Set<String>.from(selectedFields);

    if (isSelected) {
      newSelection.add(fieldKey);
    } else {
      newSelection.remove(fieldKey);
    }

    onFieldsChanged(newSelection);
    HapticFeedback.lightImpact();
  }

  void _selectBasicFields() {
    final basicFields = {'fullName', 'email', 'phone', 'status'};
    final requiredFields = ExportField.getAllFields()
        .where((f) => f.isRequired)
        .map((f) => f.key)
        .toSet();

    onFieldsChanged({...requiredFields, ...basicFields});
    HapticFeedback.mediumImpact();
  }

  void _selectAllFields() {
    final allFields = ExportField.getAllFields().map((f) => f.key).toSet();
    onFieldsChanged(allFields);
    HapticFeedback.mediumImpact();
  }

  void _selectContactFields() {
    final contactFields = {'fullName', 'email', 'phone', 'company', 'address'};
    final requiredFields = ExportField.getAllFields()
        .where((f) => f.isRequired)
        .map((f) => f.key)
        .toSet();

    onFieldsChanged({...requiredFields, ...contactFields});
    HapticFeedback.mediumImpact();
  }

  void _selectMetricsFields() {
    final metricsFields = {
      'appointmentsCount',
      'totalRevenue',
      'satisfactionScore'
    };
    final requiredFields = ExportField.getAllFields()
        .where((f) => f.isRequired)
        .map((f) => f.key)
        .toSet();

    onFieldsChanged({...requiredFields, ...metricsFields});
    HapticFeedback.mediumImpact();
  }

  void _clearOptionalFields() {
    final requiredFields = ExportField.getAllFields()
        .where((f) => f.isRequired)
        .map((f) => f.key)
        .toSet();

    onFieldsChanged(requiredFields);
    HapticFeedback.lightImpact();
  }

  bool _isRequired(String fieldKey) {
    return ExportField.getAllFields()
        .firstWhere((f) => f.key == fieldKey)
        .isRequired;
  }

  IconData _getFieldIcon(String fieldKey) {
    switch (fieldKey) {
      case 'fullName':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'company':
        return Icons.business;
      case 'status':
        return Icons.flag;
      case 'tags':
        return Icons.label;
      case 'address':
        return Icons.location_on;
      case 'createdAt':
        return Icons.calendar_today;
      case 'appointmentsCount':
        return Icons.event;
      case 'totalRevenue':
        return Icons.attach_money;
      case 'satisfactionScore':
        return Icons.star;
      default:
        return Icons.data_object;
    }
  }
}
