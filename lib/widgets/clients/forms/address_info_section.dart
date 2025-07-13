// [address_info_section.dart] - SECCIÓN DE DIRECCIÓN
// 📁 Ubicación: /lib/widgets/clients/forms/address_info_section.dart
// 🎯 OBJETIVO: Formulario modular de dirección con glassmorphism y validaciones

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/glassmorphism_form_card.dart';

/// 🏠 SECCIÓN DE INFORMACIÓN DE DIRECCIÓN
class AddressInfoSection extends StatefulWidget {
  final ClientFormController controller;
  final bool isRequired;

  const AddressInfoSection({
    super.key,
    required this.controller,
    this.isRequired = true,
  });

  @override
  State<AddressInfoSection> createState() => _AddressInfoSectionState();
}

class _AddressInfoSectionState extends State<AddressInfoSection> {
  // ✅ CONTROLADORES DE TEXTO
  late final TextEditingController _calleController;
  late final TextEditingController _numeroExteriorController;
  late final TextEditingController _numeroInteriorController;
  late final TextEditingController _coloniaController;
  late final TextEditingController _codigoPostalController;

  // ✅ FOCUS NODES PARA NAVEGACIÓN
  final FocusNode _focusCalle = FocusNode();
  final FocusNode _focusNumExt = FocusNode();
  final FocusNode _focusNumInt = FocusNode();
  final FocusNode _focusColonia = FocusNode();
  final FocusNode _focusCP = FocusNode();

  // ✅ ALCALDÍA SELECCIONADA
  String? _alcaldiaSeleccionada;

  // ✅ ALCALDÍAS DE CDMX
  static const List<String> _alcaldiasCDMX = [
    'Álvaro Obregón',
    'Azcapotzalco',
    'Benito Juárez',
    'Coyoacán',
    'Cuajimalpa de Morelos',
    'Cuauhtémoc',
    'Gustavo A. Madero',
    'Iztacalco',
    'Iztapalapa',
    'La Magdalena Contreras',
    'Miguel Hidalgo',
    'Milpa Alta',
    'Tláhuac',
    'Tlalpan',
    'Venustiano Carranza',
    'Xochimilco',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    final addressInfo = widget.controller.formData.addressInfo;

    _calleController = TextEditingController(text: addressInfo.calle);
    _numeroExteriorController =
        TextEditingController(text: addressInfo.numeroExterior);
    _numeroInteriorController =
        TextEditingController(text: addressInfo.numeroInterior ?? '');
    _coloniaController = TextEditingController(text: addressInfo.colonia);
    _codigoPostalController =
        TextEditingController(text: addressInfo.codigoPostal);
    _alcaldiaSeleccionada =
        addressInfo.alcaldia.isNotEmpty ? addressInfo.alcaldia : null;
  }

  void _setupListeners() {
    _calleController.addListener(() {
      widget.controller.updateCalle(_calleController.text);
    });

    _numeroExteriorController.addListener(() {
      widget.controller.updateNumeroExterior(_numeroExteriorController.text);
    });

    _numeroInteriorController.addListener(() {
      widget.controller.updateNumeroInterior(_numeroInteriorController.text);
    });

    _coloniaController.addListener(() {
      widget.controller.updateColonia(_coloniaController.text);
    });

    _codigoPostalController.addListener(() {
      widget.controller.updateCodigoPostal(_codigoPostalController.text);
    });
  }

  @override
  void dispose() {
    _calleController.dispose();
    _numeroExteriorController.dispose();
    _numeroInteriorController.dispose();
    _coloniaController.dispose();
    _codigoPostalController.dispose();

    _focusCalle.dispose();
    _focusNumExt.dispose();
    _focusNumInt.dispose();
    _focusColonia.dispose();
    _focusCP.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AddressFormInfo>(
      valueListenable: widget.controller.addressInfoNotifier,
      builder: (context, addressInfo, child) {
        return ValueListenableBuilder(
          valueListenable: widget.controller.validationNotifier,
          builder: (context, validation, child) {
            return GlassmorphismFormCard(
              title: 'Información de Dirección',
              titleIcon: Icons.location_on_outlined,
              subtitle: 'Dirección completa del cliente en CDMX',
              primaryColor: kAccentBlue,
              isRequired: widget.isRequired,
              hasError: _hasAddressErrors(validation),
              errorMessage: _getAddressErrorMessage(validation),
              child: _buildFormFields(addressInfo, validation),
            );
          },
        );
      },
    );
  }

  Widget _buildFormFields(
      AddressFormInfo addressInfo, ClientFormValidation validation) {
    return Column(
      children: [
        // Calle (campo completo)
        GlassmorphismInputField(
          controller: _calleController,
          label: 'Calle',
          hintText: 'Nombre de la calle o avenida',
          isRequired: true,
          errorText: validation.getFieldError('calle'),
          focusNode: _focusCalle,
          nextFocusNode: _focusNumExt,
          prefixIcon:
              Icons.add_road, // ✅ CORREGIDO: Icons.road_outlined no existe
          keyboardType: TextInputType.streetAddress,
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          enabled: widget.controller.currentState.canEdit,
        ),
        const SizedBox(height: 20),

        // Row para Números Exterior e Interior
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GlassmorphismInputField(
                controller: _numeroExteriorController,
                label: 'Núm. Exterior',
                hintText: '123',
                isRequired: true,
                errorText: validation.getFieldError('numeroExterior'),
                focusNode: _focusNumExt,
                nextFocusNode: _focusNumInt,
                prefixIcon: Icons.home_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                enabled: widget.controller.currentState.canEdit,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GlassmorphismInputField(
                controller: _numeroInteriorController,
                label: 'Núm. Interior',
                hintText: 'A, 101 (opcional)',
                isRequired: false,
                focusNode: _focusNumInt,
                nextFocusNode: _focusColonia,
                prefixIcon: Icons.door_back_door_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
                enabled: widget.controller.currentState.canEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Row para Colonia y Código Postal
        Row(
          children: [
            Expanded(
              flex: 3,
              child: GlassmorphismInputField(
                controller: _coloniaController,
                label: 'Colonia',
                hintText: 'Nombre de la colonia',
                isRequired: true,
                errorText: validation.getFieldError('colonia'),
                focusNode: _focusColonia,
                nextFocusNode: _focusCP,
                prefixIcon: Icons.location_city_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                enabled: widget.controller.currentState.canEdit,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GlassmorphismInputField(
                controller: _codigoPostalController,
                label: 'Código Postal',
                hintText: '12345',
                isRequired: true,
                errorText: validation.getFieldError('codigoPostal'),
                focusNode: _focusCP,
                prefixIcon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                enabled: widget.controller.currentState.canEdit,
                suffixWidget: _buildCPValidationIndicator(validation),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Dropdown Alcaldía con estilo glassmorphism
        _buildAlcaldiaDropdown(validation),

        // Vista previa de dirección
        const SizedBox(height: 20),
        _buildAddressPreview(addressInfo),
      ],
    );
  }

  Widget _buildAlcaldiaDropdown(ClientFormValidation validation) {
    final hasError = validation.hasFieldError('alcaldia');
    final borderColor =
        hasError ? Colors.red.withValues(alpha: 0.4) : kBorderSoft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              'Alcaldía',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasError ? Colors.red.shade700 : kTextSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dropdown con estilo glassmorphism
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _alcaldiaSeleccionada,
            hint: const Text('Seleccione una alcaldía'),
            icon: Icon(Icons.keyboard_arrow_down, color: kTextMuted),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.account_balance_outlined,
                color: kTextMuted,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            dropdownColor: Colors.white,
            items: _alcaldiasCDMX.map((alcaldia) {
              return DropdownMenuItem<String>(
                value: alcaldia,
                child: Text(
                  alcaldia,
                  style: const TextStyle(fontSize: 15),
                ),
              );
            }).toList(),
            onChanged: widget.controller.currentState.canEdit
                ? (String? value) {
                    setState(() {
                      _alcaldiaSeleccionada = value;
                    });
                    if (value != null) {
                      widget.controller.updateAlcaldia(value);
                    }
                  }
                : null,
          ),
        ),

        // Error de alcaldía
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  validation.getFieldError('alcaldia')!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCPValidationIndicator(ClientFormValidation validation) {
    final hasCPError = validation.hasFieldError('codigoPostal');
    final cpText =
        _codigoPostalController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (hasCPError) {
      return const Padding(
        // ✅ CORREGIDO: const agregado
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 20,
        ),
      );
    }

    if (cpText.length == 5) {
      return const Padding(
        // ✅ CORREGIDO: const agregado
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 20,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAddressPreview(AddressFormInfo addressInfo) {
    if (!addressInfo.isValid) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAccentBlue.withValues(alpha: 0.05),
            kAccentBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kAccentBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.preview_outlined,
                color: kAccentBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Vista Previa de Dirección',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kAccentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: kAccentBlue.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: kAccentBlue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    addressInfo.fullAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 14,
                ),
                const SizedBox(width: 4),
                const Text(
                  'DIRECCIÓN COMPLETA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER
  // ========================================================================

  bool _hasAddressErrors(ClientFormValidation validation) {
    return validation.hasFieldError('calle') ||
        validation.hasFieldError('numeroExterior') ||
        validation.hasFieldError('colonia') ||
        validation.hasFieldError('codigoPostal') ||
        validation.hasFieldError('alcaldia');
  }

  String? _getAddressErrorMessage(ClientFormValidation validation) {
    final errors = <String>[];

    if (validation.hasFieldError('calle')) {
      errors.add('calle');
    }
    if (validation.hasFieldError('numeroExterior')) {
      errors.add('número exterior');
    }
    if (validation.hasFieldError('colonia')) {
      errors.add('colonia');
    }
    if (validation.hasFieldError('codigoPostal')) {
      errors.add('código postal');
    }
    if (validation.hasFieldError('alcaldia')) {
      errors.add('alcaldía');
    }

    if (errors.isEmpty) {
      return null; // ✅ CORREGIDO: if con llaves
    }

    return 'Errores en: ${errors.join(', ')}';
  }
}
