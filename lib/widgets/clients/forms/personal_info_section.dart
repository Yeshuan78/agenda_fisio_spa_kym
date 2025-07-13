// [personal_info_section.dart] - SECCIÓN DE DATOS PERSONALES
// 📁 Ubicación: /lib/widgets/clients/forms/personal_info_section.dart
// 🎯 OBJETIVO: Formulario modular de información personal con glassmorphism

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/glassmorphism_form_card.dart';

/// 👤 SECCIÓN DE INFORMACIÓN PERSONAL
class PersonalInfoSection extends StatefulWidget {
  final ClientFormController controller;
  final bool isRequired;

  const PersonalInfoSection({
    super.key,
    required this.controller,
    this.isRequired = true,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  // ✅ CONTROLADORES DE TEXTO
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _empresaController;

  // ✅ FOCUS NODES PARA NAVEGACIÓN
  final FocusNode _focusNombre = FocusNode();
  final FocusNode _focusApellidos = FocusNode();
  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusTelefono = FocusNode();
  final FocusNode _focusEmpresa = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
  }

  void _initializeControllers() {
    final personalInfo = widget.controller.formData.personalInfo;
    
    _nombreController = TextEditingController(text: personalInfo.nombre);
    _apellidosController = TextEditingController(text: personalInfo.apellidos);
    _emailController = TextEditingController(text: personalInfo.email);
    _telefonoController = TextEditingController(text: personalInfo.telefono);
    _empresaController = TextEditingController(text: personalInfo.empresa ?? '');
  }

  void _setupListeners() {
    // Listeners para actualizar el controlador cuando cambian los campos
    _nombreController.addListener(() {
      widget.controller.updateNombre(_nombreController.text);
    });

    _apellidosController.addListener(() {
      widget.controller.updateApellidos(_apellidosController.text);
    });

    _emailController.addListener(() {
      widget.controller.updateEmail(_emailController.text);
    });

    _telefonoController.addListener(() {
      widget.controller.updateTelefono(_telefonoController.text);
    });

    _empresaController.addListener(() {
      widget.controller.updateEmpresa(_empresaController.text);
    });
  }

  @override
  void dispose() {
    // Limpiar controladores y focus nodes
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _empresaController.dispose();

    _focusNombre.dispose();
    _focusApellidos.dispose();
    _focusEmail.dispose();
    _focusTelefono.dispose();
    _focusEmpresa.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PersonalFormInfo>(
      valueListenable: widget.controller.personalInfoNotifier,
      builder: (context, personalInfo, child) {
        return ValueListenableBuilder(
          valueListenable: widget.controller.validationNotifier,
          builder: (context, validation, child) {
            return GlassmorphismFormCard(
              title: 'Información Personal',
              titleIcon: Icons.person_outline,
              subtitle: 'Datos básicos de identificación del cliente',
              primaryColor: kBrandPurple,
              isRequired: widget.isRequired,
              hasError: _hasPersonalInfoErrors(validation),
              errorMessage: _getPersonalInfoErrorMessage(validation),
              child: _buildFormFields(personalInfo, validation),
            );
          },
        );
      },
    );
  }

  Widget _buildFormFields(PersonalFormInfo personalInfo, ClientFormValidation validation) {
    return Column(
      children: [
        // Row para Nombre y Apellidos
        Row(
          children: [
            Expanded(
              child: GlassmorphismInputField(
                controller: _nombreController,
                label: 'Nombre',
                hintText: 'Ingrese el nombre',
                isRequired: true,
                errorText: validation.getFieldError('nombre'),
                focusNode: _focusNombre,
                nextFocusNode: _focusApellidos,
                prefixIcon: Icons.person,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                  LengthLimitingTextInputFormatter(50),
                ],
                enabled: widget.controller.currentState.canEdit,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassmorphismInputField(
                controller: _apellidosController,
                label: 'Apellidos',
                hintText: 'Ingrese los apellidos',
                isRequired: true,
                errorText: validation.getFieldError('apellidos'),
                focusNode: _focusApellidos,
                nextFocusNode: _focusEmail,
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                  LengthLimitingTextInputFormatter(50),
                ],
                enabled: widget.controller.currentState.canEdit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Email
        GlassmorphismInputField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hintText: 'ejemplo@correo.com',
          isRequired: true,
          errorText: validation.getFieldError('email'),
          focusNode: _focusEmail,
          nextFocusNode: _focusTelefono,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')), // No espacios
            LengthLimitingTextInputFormatter(100),
          ],
          enabled: widget.controller.currentState.canEdit,
          suffixWidget: _buildEmailValidationIndicator(validation),
        ),
        const SizedBox(height: 20),

        // Row para Teléfono y Empresa
        Row(
          children: [
            Expanded(
              flex: 3,
              child: GlassmorphismInputField(
                controller: _telefonoController,
                label: 'Teléfono',
                hintText: '55 1234 5678',
                isRequired: true,
                errorText: validation.getFieldError('telefono'),
                focusNode: _focusTelefono,
                nextFocusNode: _focusEmpresa,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                  _PhoneFormatter(), // Formatter personalizado
                ],
                enabled: widget.controller.currentState.canEdit,
                suffixWidget: _buildPhoneValidationIndicator(validation),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GlassmorphismInputField(
                controller: _empresaController,
                label: 'Empresa',
                hintText: 'Nombre de empresa (opcional)',
                isRequired: false,
                focusNode: _focusEmpresa,
                prefixIcon: Icons.business_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                enabled: widget.controller.currentState.canEdit,
              ),
            ),
          ],
        ),

        // Información adicional
        const SizedBox(height: 16),
        _buildInfoCard(personalInfo),
      ],
    );
  }

  Widget _buildEmailValidationIndicator(ClientFormValidation validation) {
    final hasEmailError = validation.hasFieldError('email');
    final isValidating = validation.isValidating;

    if (isValidating) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
          ),
        ),
      );
    }

    if (hasEmailError) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.error_outline,
          color: Colors.red.shade600,
          size: 20,
        ),
      );
    }

    if (_emailController.text.isNotEmpty && !hasEmailError) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green.shade600,
          size: 20,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPhoneValidationIndicator(ClientFormValidation validation) {
    final hasPhoneError = validation.hasFieldError('telefono');
    final phoneText = _telefonoController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (hasPhoneError) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.error_outline,
          color: Colors.red.shade600,
          size: 20,
        ),
      );
    }

    if (phoneText.length == 10) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green.shade600,
          size: 20,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoCard(PersonalFormInfo personalInfo) {
    if (personalInfo.nombre.isEmpty && personalInfo.apellidos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.05),
            kBrandPurple.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.2),
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
                  kBrandPurple.withValues(alpha: 0.2),
                  kBrandPurple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _getInitials(personalInfo.fullName),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personalInfo.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (personalInfo.empresa?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    personalInfo.empresa!,
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (personalInfo.isValid)
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
                    'VÁLIDO',
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

  bool _hasPersonalInfoErrors(ClientFormValidation validation) {
    return validation.hasFieldError('nombre') ||
           validation.hasFieldError('apellidos') ||
           validation.hasFieldError('email') ||
           validation.hasFieldError('telefono');
  }

  String? _getPersonalInfoErrorMessage(ClientFormValidation validation) {
    final errors = <String>[];
    
    if (validation.hasFieldError('nombre')) errors.add('nombre');
    if (validation.hasFieldError('apellidos')) errors.add('apellidos');
    if (validation.hasFieldError('email')) errors.add('email');
    if (validation.hasFieldError('telefono')) errors.add('teléfono');

    if (errors.isEmpty) return null;
    
    return 'Errores en: ${errors.join(', ')}';
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '?';
    
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }
}

/// 📱 FORMATTER PERSONALIZADO PARA TELÉFONOS MEXICANOS
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length <= 10) {
      String formatted = digitsOnly;
      
      if (digitsOnly.length > 2) {
        formatted = '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2)}';
      }
      if (digitsOnly.length > 6) {
        formatted = '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 6)} ${digitsOnly.substring(6)}';
      }
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    
    return oldValue;
  }
}