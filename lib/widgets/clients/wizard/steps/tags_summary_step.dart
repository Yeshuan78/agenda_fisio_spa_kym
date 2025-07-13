// [tags_summary_step.dart] - PASO 3: COMPLETO CON LAYOUT 2 COLUMNAS VERTICALES - REDISTRIBUCIÓN SIMPLE
// 📁 Ubicación: /lib/widgets/clients/wizard/steps/tags_summary_step.dart
// 🎯 OBJETIVO: Layout 2 columnas + TODAS las funcionalidades originales + campos más abajo

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';

/// 🏷️ PASO 3: ETIQUETAS Y CONFIRMACIÓN - LAYOUT 2 COLUMNAS COMPLETO
class TagsSummaryStep extends StatefulWidget {
  final ClientFormController formController;
  final bool isEditMode;

  const TagsSummaryStep({
    super.key,
    required this.formController,
    this.isEditMode = false,
  });

  @override
  State<TagsSummaryStep> createState() => _TagsSummaryStepState();
}

class _TagsSummaryStepState extends State<TagsSummaryStep>
    with AutomaticKeepAliveClientMixin {
  // ✅ CONTROLADOR PARA NUEVAS ETIQUETAS
  final TextEditingController _newTagController = TextEditingController();
  final FocusNode _newTagFocus = FocusNode();

  // ✅ ETIQUETAS BASE COMPACTAS
  static const List<Map<String, dynamic>> _baseTags = [
    {'label': 'VIP', 'icon': Icons.star, 'color': Colors.purple},
    {'label': 'Corporativo', 'icon': Icons.business, 'color': Colors.blue},
    {'label': 'Nuevo', 'icon': Icons.fiber_new, 'color': Colors.green},
    {'label': 'Recurrente', 'icon': Icons.repeat, 'color': Colors.orange},
    {'label': 'Promoción', 'icon': Icons.local_offer, 'color': Colors.red},
    {'label': 'Consentido', 'icon': Icons.favorite, 'color': Colors.pink},
    {'label': 'Especial', 'icon': Icons.star_border, 'color': Colors.amber},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _newTagController.dispose();
    _newTagFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<TagsFormInfo>(
      valueListenable: widget.formController.tagsInfoNotifier,
      builder: (context, tagsInfo, child) {
        return ValueListenableBuilder<PersonalFormInfo>(
          valueListenable: widget.formController.personalInfoNotifier,
          builder: (context, personalInfo, child) {
            return ValueListenableBuilder<AddressFormInfo>(
              valueListenable: widget.formController.addressInfoNotifier,
              builder: (context, addressInfo, child) {
                return _buildTwoColumnLayout(
                    personalInfo, addressInfo, tagsInfo);
              },
            );
          },
        );
      },
    );
  }

  /// ✅ LAYOUT PRINCIPAL: 2 COLUMNAS VERTICALES - SOLO FIX OVERFLOW
  Widget _buildTwoColumnLayout(PersonalFormInfo personalInfo,
      AddressFormInfo addressInfo, TagsFormInfo tagsInfo) {
    return Column(
      children: [
        // ✅ FILA 1: ETIQUETAS COMPLETAS (ARRIBA) - SIN CAMBIOS
        SizedBox(
          height: 120, // ✅ ORIGINAL: Mantener como estaba
          child: _buildCompleteTagsSection(tagsInfo),
        ),

        const SizedBox(height: 20), // ✅ SEPARACIÓN COMO EN FLECHAS

        // ✅ FILA 2: 2 COLUMNAS VERTICALES - SOLO CRECER DIRECCIÓN +30px
        SizedBox(
          height: 230, // ✅ FIX OVERFLOW: 200 → 230px (+30px para dirección)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ COLUMNA 1: Personal + Dirección
              Expanded(
                flex: 1,
                child: _buildLeftColumn(personalInfo, addressInfo),
              ),

              const SizedBox(width: 20), // ✅ SEPARACIÓN COMO EN FLECHAS

              // ✅ COLUMNA 2: Contacto + Validación
              Expanded(
                flex: 1,
                child: _buildRightColumn(personalInfo, addressInfo),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16), // ✅ SEPARACIÓN COMO EN FLECHAS

        // ✅ VALIDACIÓN FINAL - FLEXIBLE
        Expanded(
          child: _buildFinalValidation(personalInfo, addressInfo),
        ),
      ],
    );
  }

  /// ✅ SECCIÓN DE ETIQUETAS COMPLETA
  Widget _buildCompleteTagsSection(TagsFormInfo tagsInfo) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ ORIGINAL: Como estaba
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(139, 191, 84, 0.06),
            Color.fromRGBO(139, 191, 84, 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(139, 191, 84, 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con validación
          Row(
            children: [
              const Icon(Icons.label_outline, color: kAccentGreen, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Etiquetas del Cliente',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kAccentGreen,
                ),
              ),
              const Spacer(),
              _buildTagCountChip(tagsInfo),
            ],
          ),

          const SizedBox(height: 10), // ✅ ORIGINAL: Como estaba

          // Tags base + personalizados + input en una fila
          Expanded(
            child: Row(
              children: [
                // Tags base
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Base',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _baseTags.map((tag) {
                            final isSelected =
                                tagsInfo.baseTags.contains(tag['label']);
                            return _buildCompactSelectableTag(
                              label: tag['label'],
                              color: tag['color'],
                              isSelected: isSelected,
                              onTap: () => _toggleBaseTag(tag['label']),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Tags personalizados
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personalizadas',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: tagsInfo.customTags.isEmpty
                            ? const Center(
                                // ✅ CENTRADO AL RESTO
                                child: Text(
                                  'Sin etiquetas personalizadas',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: kTextMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign:
                                      TextAlign.center, // ✅ TEXTO CENTRADO
                                ),
                              )
                            : SingleChildScrollView(
                                child: Wrap(
                                  spacing: 3,
                                  runSpacing: 3,
                                  children: tagsInfo.customTags.map((tag) {
                                    return _buildCompactCustomTag(
                                      tag,
                                      onRemove: () => _removeCustomTag(tag),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Input para nueva etiqueta - MÁS ANCHO
                SizedBox(
                  width: 120, // ✅ MÁS ANCHO: 90 → 120px
                  child: _buildCompactAddTagInput(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ COLUMNA IZQUIERDA: Personal + Dirección - ORIGINAL
  Widget _buildLeftColumn(
      PersonalFormInfo personalInfo, AddressFormInfo addressInfo) {
    return Column(
      children: [
        // Información Personal Completa - ORIGINAL
        _buildCompactInfoCard(
          'Información Personal',
          Icons.person_outline,
          [
            _buildCompactInfoRow('Nombre', personalInfo.fullName),
            if (personalInfo.empresa?.isNotEmpty == true)
              _buildCompactInfoRow('Empresa', personalInfo.empresa!),
          ],
        ),

        const SizedBox(height: 12), // ✅ ORIGINAL

        // Dirección Completa - ORIGINAL
        Expanded(
          child: _buildCompactInfoCard(
            'Dirección en CDMX',
            Icons.location_on_outlined,
            _hasAddressData(addressInfo)
                ? [
                    if (addressInfo.calle.isNotEmpty &&
                        addressInfo.numeroExterior.isNotEmpty)
                      _buildCompactInfoRow('Calle',
                          '${addressInfo.calle} ${addressInfo.numeroExterior}'),
                    if (addressInfo.colonia.isNotEmpty)
                      _buildCompactInfoRow('Colonia', addressInfo.colonia),
                    if (addressInfo.alcaldia.isNotEmpty)
                      _buildCompactInfoRow('Alcaldía', addressInfo.alcaldia),
                    if (addressInfo.codigoPostal.isNotEmpty)
                      _buildCompactInfoRow('CP', addressInfo.codigoPostal),
                  ]
                : [
                    Container(
                      padding: const EdgeInsets.all(12), // ✅ ORIGINAL
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: kTextMuted, size: 16), // ✅ ORIGINAL
                          SizedBox(width: 8), // ✅ ORIGINAL
                          Expanded(
                            child: Text(
                              'Sin dirección registrada',
                              style: TextStyle(
                                fontSize: 11, // ✅ ORIGINAL
                                color: kTextMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  /// ✅ COLUMNA DERECHA: Contacto + Validación - ORIGINAL
  Widget _buildRightColumn(
      PersonalFormInfo personalInfo, AddressFormInfo addressInfo) {
    return Column(
      children: [
        // Avatar + Información de Contacto - ORIGINAL
        _buildContactCard(personalInfo),

        const SizedBox(height: 12), // ✅ ORIGINAL

        // Card de Validación - ORIGINAL
        Expanded(
          child: _buildValidationCard(personalInfo, addressInfo),
        ),
      ],
    );
  }

  /// ✅ CARD DE CONTACTO CON AVATAR - ORIGINAL
  Widget _buildContactCard(PersonalFormInfo personalInfo) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ ORIGINAL
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentBlue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: kAccentBlue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar - ORIGINAL
          Container(
            width: 50, // ✅ ORIGINAL
            height: 50, // ✅ ORIGINAL
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(153, 32, 167, 0.2),
                  Color.fromRGBO(153, 32, 167, 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12), // ✅ ORIGINAL
              border: Border.all(
                  color: kBrandPurple.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                _getInitials(personalInfo.fullName),
                style: const TextStyle(
                  fontSize: 18, // ✅ ORIGINAL
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12), // ✅ ORIGINAL

          // Información de contacto - ORIGINAL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personalInfo.fullName.isNotEmpty
                      ? personalInfo.fullName
                      : 'Nombre del Cliente',
                  style: const TextStyle(
                    fontSize: 14, // ✅ ORIGINAL
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2, // ✅ ORIGINAL
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // ✅ ORIGINAL
                Text(
                  personalInfo.email,
                  style: const TextStyle(
                    fontSize: 11, // ✅ ORIGINAL
                    color: kTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // ✅ ORIGINAL
                Text(
                  _formatPhoneForDisplay(personalInfo.telefono),
                  style: const TextStyle(
                    fontSize: 11, // ✅ ORIGINAL
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 4), // ✅ ORIGINAL
                Text(
                  widget.isEditMode ? 'Editando cliente' : 'Nuevo cliente',
                  style: const TextStyle(
                    fontSize: 9, // ✅ ORIGINAL
                    color: kBrandPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ CARD DE VALIDACIÓN COMPACTA - SIN CAMBIOS EN FUNCIONALIDAD
  Widget _buildValidationCard(
      PersonalFormInfo personalInfo, AddressFormInfo addressInfo) {
    final isValid = _isPersonalInfoValid(personalInfo);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isValid
              ? [
                  Colors.green.withValues(alpha: 0.08),
                  Colors.green.withValues(alpha: 0.03),
                ]
              : [
                  Colors.orange.withValues(alpha: 0.08),
                  Colors.orange.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            color: isValid ? Colors.green.shade600 : Colors.orange.shade600,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            isValid ? 'VÁLIDO' : 'INCOMPLETO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isValid ? Colors.green.shade700 : Colors.orange.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isValid
                ? 'Cliente correctamente configurado'
                : 'Revise información requerida',
            style: TextStyle(
              fontSize: 9,
              color: isValid ? Colors.green.shade600 : Colors.orange.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          if (isValid) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Listo para ${widget.isEditMode ? "actualizar" : "crear"}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ VALIDACIÓN FINAL COMPACTA - FIX CHIP MÁS DELGADO
  Widget _buildFinalValidation(
      PersonalFormInfo personalInfo, AddressFormInfo addressInfo) {
    final isValid = _isPersonalInfoValid(personalInfo);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12), // ✅ MÁS DELGADO: all(8) → symmetric
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isValid
              ? [
                  Colors.green.withValues(alpha: 0.08),
                  Colors.green.withValues(alpha: 0.03),
                ]
              : [
                  Colors.orange.withValues(alpha: 0.08),
                  Colors.orange.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // ✅ CENTRADO
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            color: isValid ? Colors.green.shade600 : Colors.orange.shade600,
            size: 20, // ✅ TIPOGRAFÍA MÁS GRANDE: 16 → 20
          ),
          const SizedBox(width: 12), // ✅ AUMENTADO: 8 → 12
          Expanded(
            child: Text(
              isValid
                  ? '¡Perfecto! Toda la información está completa y válida'
                  : 'Por favor complete la información faltante antes de continuar',
              style: TextStyle(
                fontSize: 13, // ✅ TIPOGRAFÍA MÁS GRANDE: 10 → 13
                fontWeight: FontWeight.w600,
                color: isValid ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              textAlign: TextAlign.center, // ✅ TEXTO CENTRADO
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ CHIP CONTADOR DE ETIQUETAS - SIN CAMBIOS
  Widget _buildTagCountChip(TagsFormInfo tagsInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kAccentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${tagsInfo.totalTags} etiquetas',
        style: const TextStyle(
          fontSize: 10,
          color: kAccentGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// ✅ TARJETA DE INFORMACIÓN COMPACTA - SIN CAMBIOS
  Widget _buildCompactInfoCard(
      String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kBrandPurple, size: 14),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  /// ✅ FILA DE INFORMACIÓN COMPACTA - SIN CAMBIOS
  Widget _buildCompactInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ TAG SELECCIONABLE COMPACTO - SIN CAMBIOS
  Widget _buildCompactSelectableTag({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : color.withValues(alpha: 0.8),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 3),
              Icon(Icons.check_circle, size: 10, color: color),
            ],
          ],
        ),
      ),
    );
  }

  /// ✅ TAG PERSONALIZADO COMPACTO CON ELIMINACIÓN - SIN CAMBIOS
  Widget _buildCompactCustomTag(String tag, {required VoidCallback onRemove}) {
    final color = _getCustomTagColor(tag);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 10, color: color),
          ),
        ],
      ),
    );
  }

  /// ✅ INPUT COMPACTO PARA AGREGAR TAG - SIN CAMBIOS
  Widget _buildCompactAddTagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agregar',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 28,
          child: TextFormField(
            controller: _newTagController,
            focusNode: _newTagFocus,
            decoration: InputDecoration(
              hintText: 'Nueva etiqueta',
              hintStyle: TextStyle(color: kTextMuted, fontSize: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: kBorderSoft),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              suffixIcon: GestureDetector(
                onTap: _addCustomTag,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: kAccentGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.add, size: 10, color: Colors.white),
                ),
              ),
            ),
            style: const TextStyle(fontSize: 8),
            onFieldSubmitted: (_) => _addCustomTag(),
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO - SIN CAMBIOS
  // ========================================================================

  void _toggleBaseTag(String tag) {
    HapticFeedback.lightImpact();
    widget.formController.toggleBaseTag(tag);
  }

  void _addCustomTag() {
    final tagText = _newTagController.text.trim();
    if (tagText.isEmpty) return;

    HapticFeedback.lightImpact();
    widget.formController.addCustomTag(tagText);
    _newTagController.clear();
    _newTagFocus.unfocus();
  }

  void _removeCustomTag(String tag) {
    HapticFeedback.lightImpact();
    widget.formController.removeCustomTag(tag);
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER - SIN CAMBIOS
  // ========================================================================

  bool _isPersonalInfoValid(PersonalFormInfo personalInfo) {
    return personalInfo.nombre.trim().isNotEmpty &&
        personalInfo.apellidos.trim().isNotEmpty &&
        personalInfo.email.trim().isNotEmpty &&
        personalInfo.telefono.trim().isNotEmpty &&
        _isValidEmail(personalInfo.email) &&
        _isValidInternationalPhone(personalInfo.telefono);
  }

  bool _hasAddressData(AddressFormInfo addressInfo) {
    return addressInfo.calle.trim().isNotEmpty ||
        addressInfo.numeroExterior.trim().isNotEmpty ||
        addressInfo.colonia.trim().isNotEmpty ||
        addressInfo.codigoPostal.trim().isNotEmpty ||
        addressInfo.alcaldia.trim().isNotEmpty;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  bool _isValidInternationalPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty || cleaned.length < 7 || cleaned.length > 20)
      return false;

    if (cleaned.length == 10 && !cleaned.startsWith('+')) return true;
    if (cleaned.startsWith('+') && cleaned.length >= 10 && cleaned.length <= 15)
      return true;
    if (cleaned.length >= 7 && cleaned.length <= 15) return true;

    return false;
  }

  String _formatPhoneForDisplay(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 6)} ${cleaned.substring(6)}';
    }
    return cleaned;
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  Color _getCustomTagColor(String tag) {
    const colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[tag.hashCode.abs() % colors.length];
  }
}
