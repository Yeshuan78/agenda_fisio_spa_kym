// [address_info_step.dart] - PASO 2: DIRECCIÓN GRID COMPACTO CON VALIDACIÓN CONDICIONAL
// 📁 Ubicación: /lib/widgets/clients/wizard/steps/address_info_step.dart
// 🎯 OBJETIVO: Layout grid compacto + campos altura fija + validación según modo de servicio

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_controller.dart';

/// 🏠 PASO 2: INFORMACIÓN DE DIRECCIÓN GRID COMPACTO
/// Layout grid optimizado + lógica condicional basada en modo de servicio
class AddressInfoStep extends StatefulWidget {
  final ClientFormController formController;

  const AddressInfoStep({
    super.key,
    required this.formController,
  });

  @override
  State<AddressInfoStep> createState() => _AddressInfoStepState();
}

class _AddressInfoStepState extends State<AddressInfoStep>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    final addressInfo = widget.formController.formData.addressInfo;

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
      widget.formController.updateCalle(_calleController.text);
    });

    _numeroExteriorController.addListener(() {
      widget.formController
          .updateNumeroExterior(_numeroExteriorController.text);
    });

    _numeroInteriorController.addListener(() {
      widget.formController
          .updateNumeroInterior(_numeroInteriorController.text);
    });

    _coloniaController.addListener(() {
      widget.formController.updateColonia(_coloniaController.text);
    });

    _codigoPostalController.addListener(() {
      widget.formController.updateCodigoPostal(_codigoPostalController.text);
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
    super.build(context);

    return Consumer<WizardController>(
      builder: (context, wizardController, child) {
        final serviceMode = wizardController.currentServiceMode;

        return ValueListenableBuilder<AddressFormInfo>(
          valueListenable: widget.formController.addressInfoNotifier,
          builder: (context, addressInfo, child) {
            return ValueListenableBuilder(
              valueListenable: widget.formController.validationNotifier,
              builder: (context, validation, child) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactStepIntro(serviceMode),
                      const SizedBox(height: 16),
                      _buildCompactServiceModeInfo(serviceMode),
                      const SizedBox(height: 16),
                      _buildCompactGridFormFields(
                          addressInfo, validation, serviceMode),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// ✅ INTRO COMPACTA
  Widget _buildCompactStepIntro(ClientServiceMode serviceMode) {
    final isSucursalMode = serviceMode == ClientServiceMode.sucursal;
    final isDomicilioMode = serviceMode == ClientServiceMode.domicilio;
    final isAmbosMode = serviceMode == ClientServiceMode.ambos;

    final icon = isSucursalMode
        ? Icons.business_outlined
        : (isAmbosMode ? Icons.swap_horiz : Icons.home_outlined);

    final title = isSucursalMode
        ? 'Dirección (Opcional)'
        : (isAmbosMode
            ? 'Dirección (Recomendada)'
            : 'Dirección para Servicios');

    final subtitle = isSucursalMode
        ? 'Información adicional del cliente'
        : (isAmbosMode
            ? 'Útil para servicios a domicilio'
            : 'Requerida para servicios a domicilio');

    final color = isSucursalMode
        ? kAccentBlue
        : (isAmbosMode ? kBrandPurple : kAccentGreen);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.06),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ INFO MODO SERVICIO COMPACTA
  Widget _buildCompactServiceModeInfo(ClientServiceMode serviceMode) {
    final isSucursalMode = serviceMode == ClientServiceMode.sucursal;
    final isDomicilioMode = serviceMode == ClientServiceMode.domicilio;
    final isAmbosMode = serviceMode == ClientServiceMode.ambos;

    String emoji, titulo, descripcion;
    Color bgColor, textColor;

    if (isSucursalMode) {
      emoji = '🏢';
      titulo = 'Servicio en Sucursal';
      descripcion = 'La dirección es opcional. El cliente acudirá a su spa.';
      bgColor = Colors.blue.withValues(alpha: 0.04);
      textColor = Colors.blue.shade600;
    } else if (isAmbosMode) {
      emoji = '🔄';
      titulo = 'Cliente Híbrido';
      descripcion =
          'Usa ambos servicios. Dirección recomendada para domicilio.';
      bgColor = Colors.purple.withValues(alpha: 0.04);
      textColor = Colors.purple.shade600;
    } else {
      emoji = '🏠';
      titulo = 'Servicio a Domicilio';
      descripcion = 'Se requiere dirección básica para coordinar el servicio.';
      bgColor = Colors.green.withValues(alpha: 0.04);
      textColor = Colors.green.shade600;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ GRID COMPACTO REORDENADO - NUEVO ORDEN: Calle / Núm.Ext + Núm.Int + CP / Colonia + Alcaldía
  Widget _buildCompactGridFormFields(AddressFormInfo addressInfo,
      ClientFormValidation validation, ClientServiceMode serviceMode) {
    final isSucursalMode = serviceMode == ClientServiceMode.sucursal;
    final isAmbosMode = serviceMode == ClientServiceMode.ambos;
    final isDomicilioMode = serviceMode == ClientServiceMode.domicilio;

    return Column(
      children: [
        // ✅ ROW 1: Calle (ancho completo)
        _buildWizardInputField(
          controller: _calleController,
          label: 'Calle',
          hintText: isSucursalMode
              ? 'Av. Insurgentes Sur (opcional)'
              : (isAmbosMode
                  ? 'Av. Insurgentes Sur (recomendada)'
                  : 'Av. Insurgentes Sur'),
          isRequired: isDomicilioMode,
          errorText: validation.getFieldError('calle'),
          focusNode: _focusCalle,
          nextFocusNode: _focusNumExt,
          prefixIcon: Icons.add_road,
          keyboardType: TextInputType.streetAddress,
          inputFormatters: [
            LengthLimitingTextInputFormatter(80),
          ],
        ),
        const SizedBox(height: 16),

        // ✅ ROW 2: Núm.Ext + Núm.Int + CP
        Row(
          children: [
            Expanded(
              child: _buildWizardInputField(
                controller: _numeroExteriorController,
                label: 'Núm. Exterior',
                hintText: isSucursalMode
                    ? '457 (opcional)'
                    : (isAmbosMode ? '457 (recomendado)' : '457'),
                isRequired: isDomicilioMode,
                errorText: validation.getFieldError('numeroExterior'),
                focusNode: _focusNumExt,
                nextFocusNode: _focusNumInt,
                prefixIcon: Icons.home_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWizardInputField(
                controller: _numeroInteriorController,
                label: 'Núm. Interior',
                hintText: 'A, 101 (opcional)',
                isRequired: false,
                focusNode: _focusNumInt,
                nextFocusNode: _focusCP,
                prefixIcon: Icons.door_back_door_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildWizardInputField(
                controller: _codigoPostalController,
                label: 'Código Postal',
                hintText: isSucursalMode
                    ? '03610 (opcional)'
                    : (isAmbosMode ? '03610 (recomendado)' : '03610'),
                isRequired: false, // CP siempre opcional
                errorText: validation.getFieldError('codigoPostal'),
                focusNode: _focusCP,
                nextFocusNode: _focusColonia,
                prefixIcon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                suffixWidget: _buildCPValidationIndicator(validation),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ✅ ROW 3: Colonia + Alcaldía
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildWizardInputField(
                controller: _coloniaController,
                label: 'Colonia',
                hintText: isSucursalMode
                    ? 'Del Valle (opcional)'
                    : (isAmbosMode ? 'Del Valle (recomendada)' : 'Del Valle'),
                isRequired: isDomicilioMode,
                errorText: validation.getFieldError('colonia'),
                focusNode: _focusColonia,
                prefixIcon: Icons.location_city_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(40),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildAlcaldiaDropdown(validation, serviceMode),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ CAMPO INPUT COMPACTO CON ALTURA FIJA (NOMBRE PRESERVADO)
  Widget _buildWizardInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool isRequired = false,
    String? errorText,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixWidget,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ LABEL COMPACTO
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasError ? Colors.red.shade700 : kTextSecondary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // ✅ INPUT FIELD COMPACTO CON ALTURA FIJA
        Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError ? Colors.red.withValues(alpha: 0.4) : kBorderSoft,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: kTextMuted,
                fontSize: 13,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: kTextMuted, size: 18)
                  : null,
              suffixIcon: suffixWidget,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            onFieldSubmitted: (_) {
              if (nextFocusNode != null) {
                FocusScope.of(context).requestFocus(nextFocusNode);
              }
            },
          ),
        ),

        // ✅ ERROR MESSAGE COMPACTO
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: TextStyle(
                    fontSize: 11,
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

  /// ✅ DROPDOWN ALCALDÍA COMPACTO (NOMBRE PRESERVADO) - AHORA INLINE SIN SEPARACIÓN
  Widget _buildAlcaldiaDropdown(
      ClientFormValidation validation, ClientServiceMode serviceMode) {
    final hasError = validation.hasFieldError('alcaldia');
    final borderColor =
        hasError ? Colors.red.withValues(alpha: 0.4) : kBorderSoft;
    final isSucursalMode = serviceMode == ClientServiceMode.sucursal;
    final isAmbosMode = serviceMode == ClientServiceMode.ambos;
    final isRequired = serviceMode == ClientServiceMode.domicilio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ LABEL COMPACTO
        Row(
          children: [
            Text(
              isSucursalMode
                  ? 'Alcaldía (opcional)'
                  : (isAmbosMode ? 'Alcaldía (recomendada)' : 'Alcaldía'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasError ? Colors.red.shade700 : kTextSecondary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // ✅ DROPDOWN COMPACTO CON ALTURA FIJA
        Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _alcaldiaSeleccionada,
            hint: Text(
              isSucursalMode
                  ? 'Seleccione una alcaldía (opcional)'
                  : (isAmbosMode
                      ? 'Seleccione una alcaldía (recomendada)'
                      : 'Seleccione una alcaldía'),
              style: TextStyle(
                color: kTextMuted,
                fontSize: 13,
              ),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: kTextMuted, size: 18),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.account_balance_outlined,
                color: kTextMuted,
                size: 18,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            dropdownColor: Colors.white,
            items: _alcaldiasCDMX.map((alcaldia) {
              return DropdownMenuItem<String>(
                value: alcaldia,
                child: Text(
                  alcaldia,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _alcaldiaSeleccionada = value;
              });
              if (value != null) {
                widget.formController.updateAlcaldia(value);
              }
            },
          ),
        ),

        // ✅ ERROR DE ALCALDÍA COMPACTO
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  validation.getFieldError('alcaldia')!,
                  style: TextStyle(
                    fontSize: 11,
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
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 18,
        ),
      );
    }

    if (cpText.length == 5) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 18,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
