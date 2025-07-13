// [client_crud_screen.dart] - ORQUESTADOR PRINCIPAL REFACTORIZADO
// 📁 Ubicación: /lib/screens/clients/client_crud_screen.dart
// 🎯 OBJETIVO: Screen principal con arquitectura modular y glassmorphism enterprise

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// ✅ IMPORTS DE ARQUITECTURA MODULAR
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_validation_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/services/clients/client_form_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/address_info_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/glassmorphism_form_card.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/personal_info_section.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/tags_management_section.dart';

/// 🏗️ SCREEN PRINCIPAL DE CRUD CLIENTE - REFACTORIZADO ENTERPRISE
/// Orquestador que coordina controladores, validaciones y widgets modulares
class ClientCrudScreen extends StatefulWidget {
  final DocumentSnapshot? cliente;
  final String? initialClientId;
  final ClientModel? clientModel;

  const ClientCrudScreen({
    super.key,
    this.cliente,
    this.initialClientId,
    this.clientModel,
  });

  @override
  State<ClientCrudScreen> createState() => _ClientCrudScreenState();
}

class _ClientCrudScreenState extends State<ClientCrudScreen>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES ESPECIALIZADOS
  late ClientFormController _formController;
  late ClientValidationController _validationController;
  late ClientFormService _formService;

  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _pageAnimationController;
  late AnimationController _saveAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _saveButtonAnimation;

  // ✅ CONFIGURACIÓN
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // ✅ ESTADO DE UI
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeServices() {
    _formService = ClientFormService();
    _validationController = ClientValidationController();

    // ✅ CREAR CONTROLLER VACÍO SIEMPRE - Los datos se cargan en _loadInitialData()
    _formController = ClientFormController(formService: _formService);
  }

  void _initializeAnimations() {
    // Animación de entrada de página
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Animación de botón guardar
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _saveButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadInitialData() async {
    try {
      if (widget.cliente != null) {
        final clientModel = ClientModel.fromDoc(widget.cliente!);
        debugPrint(
            '🔄 Cargando desde DocumentSnapshot: ${clientModel.fullName}');
        _formController.loadExistingClient(clientModel);
      } else if (widget.clientModel != null) {
        debugPrint(
            '🔄 Cargando desde ClientModel: ${widget.clientModel!.fullName}');
        _formController.loadExistingClient(widget.clientModel!);
      } else if (widget.initialClientId != null) {
        debugPrint('🔄 Cargando por ID: ${widget.initialClientId}');
        await _formController.loadClientById(widget.initialClientId!);
      } else {
        debugPrint('🔄 Inicializando cliente nuevo');
        _formController.initializeNewClient();
      }

      setState(() {
        _isInitialized = true;
      });

      _pageAnimationController.forward();
    } catch (e) {
      debugPrint('❌ Error cargando datos iniciales: $e');
      _showErrorDialog(
        'Error de Carga',
        'No se pudieron cargar los datos del cliente. Por favor, intente nuevamente.',
      );
    }
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _saveAnimationController.dispose();
    _scrollController.dispose();
    _formController.dispose();
    _validationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _formController),
        ChangeNotifierProvider.value(value: _validationController),
      ],
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  /// 📱 APP BAR CON GLASSMORPHISM
  PreferredSizeWidget _buildAppBar() {
    final isEditMode = widget.cliente != null || widget.clientModel != null;

    return AppBar(
      title: Text(
        isEditMode ? 'Editar Cliente' : 'Nuevo Cliente', // ✅ CORREGIDO
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: kFontFamily,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: kHeaderGradient,
          boxShadow: kSombraHeader,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        // Indicador de validación
        Consumer<ClientValidationController>(
          builder: (context, validation, child) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  if (validation.isValidating) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Validando...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ] else if (validation.hasErrors) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${validation.validationResults.values.where((r) => !r.isValid).length}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (validation.isFormValid) ...[
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.lightGreen,
                      size: 20,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// 🏗️ CUERPO PRINCIPAL CON CONSTRAINT
  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 24),
                          _buildFormSections(),
                          const SizedBox(height: 32),
                          _buildFormActions(),
                          const SizedBox(height: 100), // Espacio para FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📋 HEADER DE PÁGINA
  Widget _buildPageHeader() {
    return Consumer<ClientFormController>(
      builder: (context, controller, child) {
        // ✅ DETECTAR MODO EDICIÓN CORRECTAMENTE
        final isEditMode = widget.cliente != null ||
            widget.clientModel != null ||
            controller.isEditMode;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.7),
                kBrandPurple.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kBrandPurple.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: kSombraCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kBrandPurple.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isEditMode ? Icons.edit : Icons.person_add, // ✅ CORREGIDO
                      color: kBrandPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode // ✅ CORREGIDO
                              ? 'Editando Cliente'
                              : 'Registrar Nuevo Cliente',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBrandPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditMode // ✅ CORREGIDO
                              ? 'Modifique los datos del cliente existente'
                              : 'Complete la información del nuevo cliente',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  /// 📊 INDICADOR DE PROGRESO
  Widget _buildProgressIndicator() {
    return Consumer<ClientValidationController>(
      builder: (context, validation, child) {
        final summary = validation.getValidationSummary();
        final progress = summary.validationProgress;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: kBrandPurple.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      summary.fieldsWithErrors > 0
                          ? Colors.orange
                          : kAccentGreen,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: summary.fieldsWithErrors > 0
                        ? Colors.orange
                        : kAccentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip(
                  Icons.check_circle,
                  '${summary.validFields}',
                  'Válidos',
                  kAccentGreen,
                ),
                const SizedBox(width: 8),
                if (summary.fieldsWithErrors > 0) ...[
                  _buildStatChip(
                    Icons.error,
                    '${summary.fieldsWithErrors}',
                    'Errores',
                    Colors.red,
                  ),
                  const SizedBox(width: 8),
                ],
                if (summary.fieldsWithWarnings > 0) ...[
                  _buildStatChip(
                    Icons.warning,
                    '${summary.fieldsWithWarnings}',
                    'Advertencias',
                    Colors.orange,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatChip(
      IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 SECCIONES DEL FORMULARIO
  Widget _buildFormSections() {
    return Column(
      children: [
        // Sección: Datos Personales
        GlassmorphismFormCard(
          title: 'Información Personal',
          titleIcon: Icons.person_outline,
          subtitle: 'Datos básicos del cliente',
          primaryColor: kBrandPurple,
          isRequired: true,
          child: _buildPersonalInfoSection(),
        ),

        const SizedBox(height: 20),

        // Sección: Dirección
        AddressInfoSection(
          controller: _formController,
          isRequired: true,
        ),

        const SizedBox(height: 20),

        // Sección: Etiquetas
        GlassmorphismFormCard(
          title: 'Etiquetas y Categorización',
          titleIcon: Icons.label_outline,
          subtitle: 'Clasifica y organiza tus clientes',
          primaryColor: kAccentGreen,
          child: _buildTagsSection(),
        ),
      ],
    );
  }

  /// 👤 SECCIÓN PERSONAL INFO REAL
  Widget _buildPersonalInfoSection() {
    return PersonalInfoSection(
      controller: _formController,
      isRequired: true,
    );
  }

  /// 🏷️ SECCIÓN TAGS REAL
  Widget _buildTagsSection() {
    return TagsManagementSection(
      controller: _formController,
      isRequired: false,
    );
  }

  /// 🎬 ACCIONES DEL FORMULARIO
  Widget _buildFormActions() {
    return Consumer2<ClientFormController, ClientValidationController>(
      builder: (context, formController, validationController, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _handleCancel,
              style: TextButton.styleFrom(
                foregroundColor: kBrandPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: formController.canSave == true ? _handleSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.cliente != null ? 'Actualizar' : 'Guardar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 💾 FLOATING ACTION BUTTON
  Widget _buildFloatingActionButton() {
    return Consumer2<ClientFormController, ClientValidationController>(
      builder: (context, formController, validationController, child) {
        final canSave =
            (formController.canSave == true) && !formController.isProcessing;

        return AnimatedBuilder(
          animation: _saveButtonAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _saveButtonAnimation.value,
              child: FloatingActionButton.extended(
                onPressed: canSave ? _handleSave : null,
                backgroundColor: canSave ? kBrandPurple : Colors.grey,
                foregroundColor: Colors.white,
                elevation: canSave ? 8 : 4,
                icon: Icon(widget.cliente != null ? Icons.save : Icons.add),
                label: Text(
                  (widget.cliente != null || widget.clientModel != null)
                      ? 'Actualizar'
                      : 'Crear Cliente', // ✅ CORREGIDO
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🔄 PANTALLA DE CARGA
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Cargando...'),
        backgroundColor: kBrandPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Cargando información del cliente...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // 🎯 MANEJADORES DE EVENTOS
  // ========================================================================

  Future<void> _handleSave() async {
    try {
      // Feedback háptico
      HapticFeedback.mediumImpact();

      // Animación del botón
      _saveAnimationController.forward().then((_) {
        _saveAnimationController.reverse();
      });

      // Validar formulario
      if (!_formKey.currentState!.validate()) {
        _showValidationErrorDialog();
        return;
      }

      // Validar con controlador
      await _formController.validateForm();
      if (!_formController.canSave) {
        _showValidationErrorDialog();
        return;
      }

      // Guardar cliente
      final success = await _formController.saveClient();
      if (success == true) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(
          'Error al Guardar',
          'No se pudo guardar el cliente. Por favor, intente nuevamente.',
        );
      }
    } catch (e) {
      debugPrint('❌ Error guardando cliente: $e');
      _showErrorDialog(
        'Error al Guardar',
        'No se pudo guardar el cliente. Por favor, verifique su conexión e intente nuevamente.',
      );
    }
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  void _exitScreen([dynamic result]) {
    Navigator.of(context).pop(result);
  }

  // ========================================================================
  // 🎭 DIÁLOGOS Y FEEDBACK
  // ========================================================================

  void _showValidationErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text('Errores de Validación'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por favor corrija los errores en el formulario antes de continuar.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: kAccentGreen),
            SizedBox(width: 12),
            Text('¡Éxito!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.cliente != null
                  ? 'Cliente actualizado correctamente'
                  : 'Cliente creado correctamente',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kAccentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kAccentGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _formController.formData.personalInfo.fullName.isNotEmpty
                        ? _formController.formData.personalInfo.fullName
                        : 'Cliente Sin Nombre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formController.formData.personalInfo.email.isNotEmpty
                        ? _formController.formData.personalInfo.email
                        : 'sin-email@cliente.com',
                    style: const TextStyle(
                      fontSize: 14,
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              _exitScreen(true); // Salir con resultado exitoso
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
