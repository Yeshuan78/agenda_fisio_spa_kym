// [personal_info_step.dart] - PASO 1: INFORMACIÓN PERSONAL ULTRA COMPACTO - SIN SCROLL
// 📁 Ubicación: /lib/widgets/clients/wizard/steps/personal_info_step.dart
// 🎯 OBJETIVO: Layout ultra compacto con distribución vertical equilibrada - TODO EN UNA PANTALLA
// ✅ CÓDIGO COMPLETO SIN OMISIONES

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_controller.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/components/service_mode_toggle.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';
import 'package:agenda_fisio_spa_kym/services/company/company_settings_service.dart';
// ✅ NUEVO IMPORT PARA FECHA DE NACIMIENTO
import 'package:agenda_fisio_spa_kym/widgets/clients/birthday_date_picker.dart';

/// 👤 PASO 1: INFORMACIÓN PERSONAL ULTRA COMPACTO - ZERO SCROLL
/// Layout grid inteligente con distribución vertical equilibrada para 650px de altura
class PersonalInfoStep extends StatefulWidget {
  final ClientFormController formController;

  const PersonalInfoStep({
    super.key,
    required this.formController,
  });

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep>
    with AutomaticKeepAliveClientMixin {
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

  // ✅ VARIABLES PARA TOGGLE DE SERVICIO
  late WizardController _wizardController;
  bool _serviceConfigLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListeners();
    _initializeWizardController();
  }

  void _initializeControllers() {
    final personalInfo = widget.formController.formData.personalInfo;

    _nombreController = TextEditingController(text: personalInfo.nombre);
    _apellidosController = TextEditingController(text: personalInfo.apellidos);
    _emailController = TextEditingController(text: personalInfo.email);
    _telefonoController = TextEditingController(text: personalInfo.telefono);
    _empresaController =
        TextEditingController(text: personalInfo.empresa ?? '');
  }

  void _setupListeners() {
    _nombreController.addListener(() {
      widget.formController.updateNombre(_nombreController.text);
    });

    _apellidosController.addListener(() {
      widget.formController.updateApellidos(_apellidosController.text);
    });

    _emailController.addListener(() {
      widget.formController.updateEmail(_emailController.text);
    });

    _telefonoController.addListener(() {
      widget.formController.updateTelefono(_telefonoController.text);
    });

    _empresaController.addListener(() {
      widget.formController.updateEmpresa(_empresaController.text);
    });
  }

  void _initializeWizardController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final wizardController =
            Provider.of<WizardController>(context, listen: false);
        _wizardController = wizardController;

        wizardController.addListener(_onWizardControllerChanged);

        if (mounted) {
          setState(() {
            _serviceConfigLoaded = wizardController.serviceConfigLoaded;
          });
        }
      } catch (e) {
        debugPrint('⚠️ Error inicializando WizardController: $e');
        setState(() {
          _serviceConfigLoaded = false;
        });
      }
    });
  }

  void _onWizardControllerChanged() {
    if (mounted &&
        _wizardController.serviceConfigLoaded != _serviceConfigLoaded) {
      setState(() {
        _serviceConfigLoaded = _wizardController.serviceConfigLoaded;
      });
    }
  }

  @override
  void dispose() {
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

    if (_serviceConfigLoaded && mounted) {
      try {
        _wizardController.removeListener(_onWizardControllerChanged);
      } catch (e) {
        debugPrint('⚠️ Error removiendo listener: $e');
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ValueListenableBuilder<PersonalFormInfo>(
      valueListenable: widget.formController.personalInfoNotifier,
      builder: (context, personalInfo, child) {
        return ValueListenableBuilder(
          valueListenable: widget.formController.validationNotifier,
          builder: (context, validation, child) {
            return _buildUltraCompactLayout(personalInfo, validation);
          },
        );
      },
    );
  }

  /// ✅ LAYOUT DISTRIBUIDO VERTICALMENTE - USA TODO EL ESPACIO
  Widget _buildUltraCompactLayout(
      PersonalFormInfo personalInfo, ClientFormValidation validation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ HEADER COMPACTO
        _buildCompactStepIntro(),

        // ✅ ESPACIO FLEXIBLE PARA CENTRAR CONTENIDO
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ✅ FORMULARIO GRID INTELIGENTE
              _buildIntelligentFormGrid(personalInfo, validation),

              // ✅ TOGGLE DE SERVICIO ORIGINAL (si aplica)
              if (_serviceConfigLoaded && shouldShowServiceToggle)
                _buildServiceModeSection(),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ HEADER COMPACTO - 40% MENOS ESPACIO
  Widget _buildCompactStepIntro() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.04),
            kBrandPurple.withValues(alpha: 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kBrandPurple.withValues(alpha: 0.12),
                  kBrandPurple.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: kBrandPurple.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: kBrandPurple,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Datos básicos de identificación del cliente',
                  style: TextStyle(
                    fontSize: 11,
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

  /// ✅ GRID INTELIGENTE - APROVECHA TODO EL ESPACIO DISPONIBLE + FECHA DE NACIMIENTO
  Widget _buildIntelligentFormGrid(
      PersonalFormInfo personalInfo, ClientFormValidation validation) {
    return Column(
      children: [
        // ✅ ROW 1: Nombre + Apellidos (Full Width)
        Row(
          children: [
            Expanded(
              child: _buildCompactInputField(
                controller: _nombreController,
                label: 'Nombre',
                hintText: 'Juan Carlos',
                isRequired: true,
                errorText: validation.getFieldError('nombre'),
                focusNode: _focusNombre,
                nextFocusNode: _focusApellidos,
                prefixIcon: Icons.person,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactInputField(
                controller: _apellidosController,
                label: 'Apellidos',
                hintText: 'García López',
                isRequired: true,
                errorText: validation.getFieldError('apellidos'),
                focusNode: _focusApellidos,
                nextFocusNode: _focusEmail,
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // ✅ AUMENTADO: 12 → 16

        // ✅ ROW 2: Email + Teléfono (Full Width)
        Row(
          children: [
            Expanded(
              child: _buildCompactInputField(
                controller: _emailController,
                label: 'Correo Electrónico',
                hintText: 'juan.garcia@ejemplo.com',
                isRequired: true,
                errorText: validation.getFieldError('email'),
                focusNode: _focusEmail,
                nextFocusNode: _focusTelefono,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                suffixWidget: _buildEmailValidationIndicator(validation),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactInputField(
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
                  LengthLimitingTextInputFormatter(20),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-\(\)]')),
                ],
                suffixWidget: _buildPhoneValidationIndicator(validation),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16), // ✅ AUMENTADO: 12 → 16

        // ✅ ROW 3: Empresa + Fecha de Nacimiento (2 columnas)
        Row(
          children: [
            Expanded(
              child: _buildCompactInputField(
                controller: _empresaController,
                label: 'Empresa',
                hintText: 'Nombre de la empresa (opcional)',
                isRequired: false,
                focusNode: _focusEmpresa,
                prefixIcon: Icons.business_outlined,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactDateField(personalInfo),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ CAMPO DE FECHA COMPACTO - NUEVO MÉTODO
  Widget _buildCompactDateField(PersonalFormInfo personalInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de Nacimiento',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderSoft, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: personalInfo.fechaNacimiento != null
                  ? '${personalInfo.fechaNacimiento!.day.toString().padLeft(2, '0')}/${personalInfo.fechaNacimiento!.month.toString().padLeft(2, '0')}/${personalInfo.fechaNacimiento!.year}'
                  : '',
            ),
            decoration: const InputDecoration(
              hintText: 'dd/mm/aaaa',
              hintStyle: TextStyle(color: kTextMuted, fontSize: 11),
              prefixIcon: Icon(Icons.cake, color: kTextMuted, size: 16),
              suffixIcon:
                  Icon(Icons.calendar_today, color: kTextMuted, size: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            onTap: () => _selectDate(personalInfo),
          ),
        ),
      ],
    );
  }

  /// ✅ SELECTOR DE FECHA - NUEVO MÉTODO
  Future<void> _selectDate(PersonalFormInfo personalInfo) async {
    final now = DateTime.now();
    final initialDate = personalInfo.fechaNacimiento ??
        DateTime(now.year - 30, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now.subtract(const Duration(days: 1)),
      locale: const Locale('es', 'MX'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kBrandPurple,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      widget.formController.updateFechaNacimiento(pickedDate);
    }
  }

  /// ✅ TOGGLE DE SERVICIO ORIGINAL - SIN CAMBIOS
  Widget _buildServiceModeSection() {
    return Consumer<WizardController>(
      builder: (context, wizardController, child) {
        if (!wizardController.shouldShowServiceToggle) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceModeSectionHeader(),
            const SizedBox(height: 12),
            ServiceModeToggle(
              currentMode: wizardController.currentServiceMode,
              onModeChanged: wizardController.setServiceMode,
              enabled: true,
              description: _getServiceModeDescription(),
            ),
          ],
        );
      },
    );
  }

  /// ✅ HEADER DE LA SECCIÓN DE SERVICIO MÁS DELGADO
  Widget _buildServiceModeSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // ✅ REDUCIDO: vertical 12 → 6
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.04),
            kBrandPurple.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4), // ✅ REDUCIDO: 6 → 4
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.settings_suggest,
              color: kBrandPurple,
              size: 14, // ✅ REDUCIDO: 16 → 14
            ),
          ),
          const SizedBox(width: 8), // ✅ REDUCIDO: 10 → 8
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración de Servicio',
                  style: TextStyle(
                    fontSize: 11, // ✅ REDUCIDO: 12 → 11
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                  ),
                ),
                SizedBox(height: 1), // ✅ REDUCIDO: 2 → 1
                Text(
                  'Seleccione el tipo de servicio para este cliente',
                  style: TextStyle(
                    fontSize: 9, // ✅ REDUCIDO: 10 → 9
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

  /// ✅ INPUT FIELD ULTRA COMPACTO - ALTURA FIJA 40px
  Widget _buildCompactInputField({
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
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: hasError ? Colors.red.shade700 : kTextSecondary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 2),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? Colors.red.withValues(alpha: 0.4) : kBorderSoft,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
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
                fontSize: 11,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: kTextMuted, size: 16)
                  : null,
              suffixIcon: suffixWidget,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
            ),
            style: const TextStyle(
              fontSize: 12,
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
        if (hasError) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 10,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  errorText,
                  style: TextStyle(
                    fontSize: 9,
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

  Widget _buildEmailValidationIndicator(ClientFormValidation validation) {
    final hasError = validation.hasFieldError('email');
    final emailText = _emailController.text.trim();

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.error_outline,
          color: Colors.red.shade600,
          size: 14,
        ),
      );
    }

    if (emailText.isNotEmpty && _isValidEmail(emailText)) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 14,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPhoneValidationIndicator(ClientFormValidation validation) {
    final hasError = validation.hasFieldError('telefono');
    final phoneText = _telefonoController.text.trim();

    if (hasError) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.error_outline,
          color: Colors.red.shade600,
          size: 14,
        ),
      );
    }

    if (phoneText.isNotEmpty && _isValidInternationalPhone(phoneText)) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 14,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER PARA VALIDACIÓN
  // ========================================================================

  bool get shouldShowServiceToggle {
    return _serviceConfigLoaded && _wizardController.shouldShowServiceToggle;
  }

  String? _getServiceModeDescription() {
    try {
      final businessType = CompanySettingsService.businessType;

      switch (businessType) {
        case BusinessType.spa_tradicional:
          return null;
        case BusinessType.servicios_domicilio:
          return null;
        case BusinessType.hibrido:
          return 'Puede cambiar este ajuste más tarde en el perfil del cliente';
      }
    } catch (e) {
      debugPrint('⚠️ Error obteniendo descripción: $e');
      return 'Configuración de tipo de servicio';
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email.trim());
  }

  bool _isValidInternationalPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.isEmpty) return false;
    if (cleaned.length < 7) return false;
    if (cleaned.length > 20) return false;

    if (cleaned.length == 10 && !cleaned.startsWith('+')) {
      return true;
    }

    if (cleaned.startsWith('+') &&
        cleaned.length >= 10 &&
        cleaned.length <= 15) {
      return true;
    }

    if (cleaned.length >= 7 && cleaned.length <= 15) {
      return true;
    }

    return false;
  }
}
