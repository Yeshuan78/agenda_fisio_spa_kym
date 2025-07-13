// [client_info_step.dart] - ✨ MEJORADO: Campos optimizados + Apellidos + Selector Alcaldías
// 📁 Ubicación: /lib/widgets/booking/steps/client_info_step.dart
// 🎯 OBJETIVO: Reducir redundancias + Apellidos separados + Selector alcaldías CDMX
// ✅ MANTIENE: Toda la lógica existente sin romper conexiones CRM

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/enums/booking_types.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/booking_form_field.dart';

class ClientInfoStep extends StatefulWidget {
  final Color accentColor;
  final bool isExistingClient;
  final BookingType bookingType;
  final bool requiresAddress;
  final bool isSubmitting;
  final TextEditingController nombreController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;
  final TextEditingController empleadoController;

  // ✅ CONTROLADORES EXISTENTES PARA DIRECCIÓN
  final TextEditingController calleController;
  final TextEditingController numeroExteriorController;
  final TextEditingController numeroInteriorController;
  final TextEditingController coloniaController;
  final TextEditingController codigoPostalController;
  final TextEditingController alcaldiaController;

  final VoidCallback onSubmit;

  const ClientInfoStep({
    super.key,
    required this.accentColor,
    required this.isExistingClient,
    required this.bookingType,
    required this.requiresAddress,
    required this.isSubmitting,
    required this.nombreController,
    required this.telefonoController,
    required this.emailController,
    required this.empleadoController,
    required this.calleController,
    required this.numeroExteriorController,
    required this.numeroInteriorController,
    required this.coloniaController,
    required this.codigoPostalController,
    required this.alcaldiaController,
    required this.onSubmit,
  });

  @override
  State<ClientInfoStep> createState() => _ClientInfoStepState();
}

class _ClientInfoStepState extends State<ClientInfoStep>
    with SingleTickerProviderStateMixin {
  // ✅ ANIMACIONES EXISTENTES
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 🆕 NUEVO: Controlador para apellidos
  late TextEditingController _apellidosController;

  // 🆕 NUEVO: Alcaldía seleccionada
  String? _selectedAlcaldia;

  // 🆕 NUEVO: Lista de alcaldías CDMX
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
    _initializeAnimations();
    _loadExistingData();
  }

  void _initializeControllers() {
    // 🆕 NUEVO: Inicializar controlador de apellidos
    _apellidosController = TextEditingController();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  void _loadExistingData() {
    // 🆕 NUEVO: Cargar alcaldía existente si hay
    if (widget.alcaldiaController.text.isNotEmpty) {
      final alcaldiaText = widget.alcaldiaController.text;
      if (_alcaldiasCDMX.contains(alcaldiaText)) {
        _selectedAlcaldia = alcaldiaText;
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _apellidosController.dispose(); // 🆕 NUEVO: Dispose del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(_getContainerPadding(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_getBorderRadius(context)),
          boxShadow: kSombraCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ HEADER MEJORADO (menos redundante)
            _buildOptimizedHeader(),
            SizedBox(height: _getSectionSpacing(context)),

            // 📝 FORMULARIO SEGÚN TIPO DE CLIENTE
            _buildClientForm(),
            SizedBox(height: _getSectionSpacing(context)),

            // 🔘 BOTÓN DE ENVÍO
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// ✨ HEADER OPTIMIZADO - ELIMINANDO REDUNDANCIAS
  Widget _buildOptimizedHeader() {
    String title = widget.isExistingClient
        ? 'Confirma tu identidad'
        : 'Completa tus datos';

    String subtitle = widget.isExistingClient
        ? 'Solo necesitamos verificar quién eres'
        : 'Datos necesarios para tu reserva';

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
            fontWeight: FontWeight.w700,
            color: widget.accentColor,
            fontFamily: kFontFamily,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: _getTextSpacing(context)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: _getSubtitleFontSize(context),
            color: kTextSecondary,
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 📝 FORMULARIO SEGÚN TIPO DE CLIENTE
  Widget _buildClientForm() {
    return Container(
      height: _getFormHeight(context),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (widget.isExistingClient)
              _buildExistingClientForm()
            else
              _buildNewClientForm(),
          ],
        ),
      ),
    );
  }

  /// 👤 FORMULARIO PARA CLIENTE EXISTENTE
  Widget _buildExistingClientForm() {
    return Column(
      children: [
        if (widget.bookingType == BookingType.enterprise) ...[
          BookingFormField(
            controller: widget.empleadoController,
            label: 'Número de empleado',
            hint: '12345',
            icon: Icons.badge_outlined,
            accentColor: widget.accentColor,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El número de empleado es requerido';
              }
              return null;
            },
          ),
        ] else ...[
          BookingFormField(
            controller: widget.telefonoController,
            label: 'Teléfono registrado',
            hint: '55 1234 5678',
            icon: Icons.phone_outlined,
            accentColor: widget.accentColor,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El teléfono es requerido';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  /// 🆕 FORMULARIO PARA CLIENTE NUEVO - MEJORADO
  Widget _buildNewClientForm() {
    return Column(
      children: [
        // 👤 DATOS PERSONALES (OPTIMIZADO)
        _buildPersonalDataSection(),
        SizedBox(height: _getContentSpacing(context)),

        // 📞 CONTACTO (OPTIMIZADO)
        _buildContactSection(),

        // 🏠 DIRECCIÓN (SOLO PARA PARTICULARES QUE REQUIEREN)
        if (widget.bookingType == BookingType.particular &&
            widget.requiresAddress) ...[
          SizedBox(height: _getContentSpacing(context)),
          _buildAddressSection(),
        ],
      ],
    );
  }

  /// 👤 SECCIÓN DATOS PERSONALES - ✨ OPTIMIZADA + APELLIDOS
  Widget _buildPersonalDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ TÍTULO OPTIMIZADO (sin redundancia "Información")
        Text(
          'Datos Personales',
          style: TextStyle(
            fontSize: _getSectionTitleSize(context),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: kFontFamily,
          ),
        ),
        SizedBox(height: _getContentSpacing(context) * 0.7),

        // 🆕 ROW: NOMBRE + APELLIDOS (solo para no-enterprise)
        if (widget.bookingType != BookingType.enterprise) ...[
          Row(
            children: [
              // 👤 NOMBRE
              Expanded(
                flex: 2,
                child: BookingFormField(
                  controller: widget.nombreController,
                  label: 'Nombre',
                  hint: 'María',
                  icon: Icons.person_outlined,
                  accentColor: widget.accentColor,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: _getFieldSpacing(context)),

              // 🆕 APELLIDOS
              Expanded(
                flex: 2,
                child: BookingFormField(
                  controller: _apellidosController,
                  label: 'Apellidos',
                  hint: 'González',
                  icon: Icons.person_pin_outlined,
                  accentColor: widget.accentColor,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Los apellidos son requeridos';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ] else ...[
          // 👤 SOLO NOMBRE PARA ENTERPRISE
          BookingFormField(
            controller: widget.nombreController,
            label: 'Nombre (sin apellidos)',
            hint: 'María',
            icon: Icons.person_outlined,
            accentColor: widget.accentColor,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
        ],

        // 🏢 NÚMERO DE EMPLEADO (solo enterprise)
        if (widget.bookingType == BookingType.enterprise) ...[
          SizedBox(height: _getFieldSpacing(context)),
          BookingFormField(
            controller: widget.empleadoController,
            label: 'Número de empleado',
            hint: '12345',
            icon: Icons.badge_outlined,
            accentColor: widget.accentColor,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El número de empleado es requerido';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  /// 📞 SECCIÓN CONTACTO - ✨ OPTIMIZADA
  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ TÍTULO OPTIMIZADO
        Text(
          'Contacto',
          style: TextStyle(
            fontSize: _getSectionTitleSize(context),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: kFontFamily,
          ),
        ),
        SizedBox(height: _getContentSpacing(context) * 0.7),

        // 📱 TELÉFONO
        BookingFormField(
          controller: widget.telefonoController,
          label: 'Teléfono',
          hint: '55 1234 5678',
          icon: Icons.phone_outlined,
          accentColor: widget.accentColor,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El teléfono es requerido';
            }
            return null;
          },
        ),

        // 📧 EMAIL (no enterprise)
        if (widget.bookingType != BookingType.enterprise) ...[
          SizedBox(height: _getFieldSpacing(context)),
          BookingFormField(
            controller: widget.emailController,
            label: 'Email',
            hint: 'maria@email.com',
            icon: Icons.email_outlined,
            accentColor: widget.accentColor,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El email es requerido';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  /// 🏠 SECCIÓN DIRECCIÓN - ✨ OPTIMIZADA + SELECTOR ALCALDÍA
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ TÍTULO OPTIMIZADO
        Text(
          'Dirección (para servicios a domicilio)',
          style: TextStyle(
            fontSize: _getSectionTitleSize(context),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: kFontFamily,
          ),
        ),
        SizedBox(height: _getContentSpacing(context) * 0.7),

        // 🛣️ CALLE
        BookingFormField(
          controller: widget.calleController,
          label: 'Calle',
          hint: 'Av. Insurgentes',
          icon: Icons.streetview_outlined,
          accentColor: widget.accentColor,
          validator: (value) {
            if (widget.requiresAddress &&
                (value == null || value.trim().isEmpty)) {
              return 'La calle es requerida';
            }
            return null;
          },
        ),
        SizedBox(height: _getFieldSpacing(context)),

        // 🏠 NÚMEROS (EXTERIOR E INTERIOR)
        Row(
          children: [
            // NÚMERO EXTERIOR
            Expanded(
              flex: 2,
              child: BookingFormField(
                controller: widget.numeroExteriorController,
                label: 'Núm. Exterior',
                hint: '123',
                icon: Icons.home_outlined,
                accentColor: widget.accentColor,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (widget.requiresAddress &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Requerido';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: _getFieldSpacing(context)),

            // NÚMERO INTERIOR (OPCIONAL)
            Expanded(
              flex: 2,
              child: BookingFormField(
                controller: widget.numeroInteriorController,
                label: 'Núm. Interior',
                hint: 'A (opcional)',
                icon: Icons.door_front_door_outlined,
                accentColor: widget.accentColor,
                keyboardType: TextInputType.text,
              ),
            ),
          ],
        ),
        SizedBox(height: _getFieldSpacing(context)),

        // 🏘️ COLONIA
        BookingFormField(
          controller: widget.coloniaController,
          label: 'Colonia',
          hint: 'Roma Norte',
          icon: Icons.location_city_outlined,
          accentColor: widget.accentColor,
          validator: (value) {
            if (widget.requiresAddress &&
                (value == null || value.trim().isEmpty)) {
              return 'La colonia es requerida';
            }
            return null;
          },
        ),
        SizedBox(height: _getFieldSpacing(context)),

        // 📮 CÓDIGO POSTAL Y ALCALDÍA
        Row(
          children: [
            // CÓDIGO POSTAL
            Expanded(
              flex: 2,
              child: BookingFormField(
                controller: widget.codigoPostalController,
                label: 'Código Postal',
                hint: '06700',
                icon: Icons.local_post_office_outlined,
                accentColor: widget.accentColor,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (widget.requiresAddress &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Requerido';
                  }
                  if (widget.requiresAddress &&
                      value != null &&
                      value.length != 5) {
                    return 'Debe tener 5 dígitos';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: _getFieldSpacing(context)),

            // 🆕 SELECTOR DE ALCALDÍA
            Expanded(
              flex: 3,
              child: _buildAlcaldiaSelector(),
            ),
          ],
        ),
      ],
    );
  }

  /// 🆕 SELECTOR DE ALCALDÍA OPTIMIZADO
  Widget _buildAlcaldiaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alcaldía',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: kFontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: _getFieldHeight(context),
          decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderSoft),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAlcaldia,
              hint: Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    color: widget.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Seleccionar alcaldía',
                      style: TextStyle(
                        fontSize: 16,
                        color: kTextMuted,
                        fontFamily: kFontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: widget.accentColor,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: kFontFamily,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              menuMaxHeight: 300,
              items: _alcaldiasCDMX.map((String alcaldia) {
                return DropdownMenuItem<String>(
                  value: alcaldia,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: _selectedAlcaldia == alcaldia
                              ? widget.accentColor
                              : kTextSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            alcaldia,
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedAlcaldia == alcaldia
                                  ? widget.accentColor
                                  : Colors.black87,
                              fontWeight: _selectedAlcaldia == alcaldia
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontFamily: kFontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAlcaldia = newValue;
                  // ✅ ACTUALIZAR CONTROLADOR PARA MANTENER COMPATIBILIDAD
                  widget.alcaldiaController.text = newValue ?? '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 🔘 BOTÓN DE ENVÍO - ✅ LÓGICA EXTENDIDA PARA APELLIDOS
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: _getButtonHeight(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.accentColor,
            widget.accentColor.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius(context)),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius(context)),
          ),
        ),
        child: widget.isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _getLoadingIconSize(context),
                    height: _getLoadingIconSize(context),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: _getContentSpacing(context) * 0.6),
                  Text(
                    'Procesando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _getButtonFontSize(context),
                      fontWeight: FontWeight.w600,
                      fontFamily: kFontFamily,
                    ),
                  ),
                ],
              )
            : Text(
                'Confirmar Reserva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getButtonFontSize(context),
                  fontWeight: FontWeight.w600,
                  fontFamily: kFontFamily,
                ),
              ),
      ),
    );
  }

  /// 🆕 HANDLE SUBMIT - COMBINAR NOMBRE + APELLIDOS
  void _handleSubmit() {
    // ✅ COMBINAR NOMBRE + APELLIDOS EN EL CONTROLADOR PRINCIPAL
    if (widget.bookingType != BookingType.enterprise &&
        _apellidosController.text.isNotEmpty) {
      final nombreCompleto =
          '${widget.nombreController.text.trim()} ${_apellidosController.text.trim()}';
      widget.nombreController.text = nombreCompleto;
    }

    // ✅ EJECUTAR CALLBACK ORIGINAL
    widget.onSubmit();
  }

  // ============================================================================
  // 📐 SISTEMA RESPONSIVO INTELIGENTE (SIN CAMBIOS)
  // ============================================================================

  /// 📦 PADDING CONTENEDOR
  double _getContainerPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 375) return 20;
    if (width <= 768) return 24;
    return 32;
  }

  /// 📐 RADIO DE BORDES
  double _getBorderRadius(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 768) return 16;
    return 20;
  }

  /// 📏 ESPACIADO SECCIONES
  double _getSectionSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 24;
    if (width <= 768) return 28;
    return 32;
  }

  /// 📏 ESPACIADO CONTENIDO
  double _getContentSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 12;
    if (width <= 375) return 16;
    if (width <= 768) return 20;
    return 24;
  }

  /// 📏 ESPACIADO ENTRE CAMPOS
  double _getFieldSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 375) return 18;
    if (width <= 768) return 20;
    return 24;
  }

  /// 📝 FONT SIZE TÍTULO
  double _getTitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 20;
    if (width <= 375) return 22;
    if (width <= 768) return 24;
    return 28;
  }

  /// 📝 FONT SIZE SUBTITLE
  double _getSubtitleFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 13;
    if (width <= 375) return 14;
    if (width <= 768) return 15;
    return 16;
  }

  /// 📝 FONT SIZE SECTION TITLE
  double _getSectionTitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 15;
    if (width <= 768) return 16;
    return 18;
  }

  /// 📏 ESPACIADO TEXTO
  double _getTextSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 6;
    if (width <= 768) return 8;
    return 12;
  }

  /// 📊 ALTURA DEL FORMULARIO
  double _getFormHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 300;
    if (width <= 375) return 350;
    if (width <= 768) return 400;
    return 450;
  }

  /// 🔘 ALTURA DEL BOTÓN
  double _getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 48;
    if (width <= 375) return 52;
    if (width <= 768) return 56;
    return 60;
  }

  /// 📝 FONT SIZE BOTÓN
  double _getButtonFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 14;
    if (width <= 375) return 15;
    if (width <= 768) return 16;
    return 16;
  }

  /// ⏳ TAMAÑO ÍCONO LOADING
  double _getLoadingIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 16;
    if (width <= 375) return 18;
    if (width <= 768) return 20;
    return 20;
  }

  /// 🆕 ALTURA DE CAMPO
  double _getFieldHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 320) return 48;
    if (width <= 375) return 52;
    if (width <= 768) return 56;
    return 60;
  }
}
