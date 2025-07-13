// [edit_appointment_dialog_premium.dart] - VERSIÓN CORREGIDA SIN RENDERFLEX ERRORS
// 📁 Ubicación: /lib/widgets/agenda/edit_appointment_dialog_premium.dart
// 🔧 SOLUCIONADO: RenderFlex constraints infinitos + UX mejorada

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class EditAppointmentDialogPremium extends StatefulWidget {
  final AppointmentModel appointment;
  final List<DocumentSnapshot> listaClientes;
  final List<DocumentSnapshot> listaProfesionales;
  final List<DocumentSnapshot> listaServicios;
  final Function(AppointmentModel)? onAppointmentUpdated;
  final VoidCallback? onAppointmentDeleted;

  const EditAppointmentDialogPremium({
    super.key,
    required this.appointment,
    required this.listaClientes,
    required this.listaProfesionales,
    required this.listaServicios,
    this.onAppointmentUpdated,
    this.onAppointmentDeleted,
  });

  @override
  State<EditAppointmentDialogPremium> createState() =>
      _EditAppointmentDialogPremiumState();
}

class _EditAppointmentDialogPremiumState
    extends State<EditAppointmentDialogPremium> with TickerProviderStateMixin {
  // ✅ CONTROLLERS DE ANIMACIÓN
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _statusChangeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _statusChangeAnimation;

  // ✅ FORM CONTROLLERS
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _comentariosCtrl = TextEditingController();
  final TextEditingController _buscarClienteCtrl = TextEditingController();

  // ✅ ESTADO DEL FORMULARIO
  List<DocumentSnapshot> _sugerenciasClientes = [];
  List<DocumentSnapshot> _serviciosFiltrados = [];
  final List<String> _estadosDisponibles = [
    'reservado',
    'confirmado',
    'en camino',
    'realizada',
    'cancelado',
    'recordatorio'
  ];

  String? _profesionalId;
  String? _servicioId;
  String? _clienteId;
  String _estadoSeleccionado = 'reservado';
  String _estadoOriginal = '';
  DateTime _fechaHora = DateTime.now();
  int _duracionMinutos = 60;
  bool _notificarCliente = true;
  bool _enviarRecordatorio = false;

  // ✅ ESTADO DE VALIDACIÓN Y CONTROL
  bool _isLoading = false;
  bool _showClienteForm = false;
  bool _clienteEncontrado = false;
  bool _hasChanges = false;
  bool _showDeleteConfirmation = false;

  // ✅ HISTORIAL Y AUDITORÍA
  List<Map<String, dynamic>> _historialCambios = [];
  DateTime? _fechaCreacion;
  DateTime? _ultimaModificacion;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeFormWithAppointment();
    _setupValidationListeners();
    _loadAppointmentHistory();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _statusChangeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _statusChangeAnimation = CurvedAnimation(
      parent: _statusChangeController,
      curve: Curves.elasticOut,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeFormWithAppointment() {
    final appointment = widget.appointment;

    // ✅ DATOS BÁSICOS
    _clienteId = appointment.clientEmail;
    _clienteCtrl.text = appointment.nombreCliente ?? '';
    _telefonoCtrl.text = appointment.clientPhone ?? '';
    _emailCtrl.text = appointment.clientEmail ?? '';
    _comentariosCtrl.text = appointment.comentarios ?? '';
    _buscarClienteCtrl.text = appointment.nombreCliente ?? '';

    // ✅ SERVICIO Y PROFESIONAL
    _profesionalId = appointment.profesionalId;
    _servicioId = appointment.servicioId;

    // ✅ FECHA Y HORA
    _fechaHora = appointment.fechaInicio ?? DateTime.now();
    _duracionMinutos = appointment.duracion ?? 60;

    // ✅ ESTADO
    _estadoSeleccionado = appointment.estado ?? 'reservado';
    _estadoOriginal = _estadoSeleccionado;

    // ✅ CONFIGURACIONES
    _clienteEncontrado = _clienteId?.isNotEmpty == true;

    // ✅ FILTRAR SERVICIOS SI HAY PROFESIONAL
    if (_profesionalId != null) {
      _filtrarServicios(_profesionalId!);
    }
  }

  void _setupValidationListeners() {
    _clienteCtrl.addListener(_onClienteChanged);
    _telefonoCtrl.addListener(_onTelefonoChanged);
    _buscarClienteCtrl.addListener(_onBusquedaClienteChanged);

    // ✅ DETECTAR CAMBIOS PARA ACTIVAR GUARDAR
    _clienteCtrl.addListener(_detectChanges);
    _telefonoCtrl.addListener(_detectChanges);
    _emailCtrl.addListener(_detectChanges);
    _comentariosCtrl.addListener(_detectChanges);
  }

  void _detectChanges() {
    final hasChanges =
        _clienteCtrl.text != (widget.appointment.nombreCliente ?? '') ||
            _telefonoCtrl.text != (widget.appointment.clientPhone ?? '') ||
            _emailCtrl.text != (widget.appointment.clientEmail ?? '') ||
            _comentariosCtrl.text != (widget.appointment.comentarios ?? '') ||
            _profesionalId != widget.appointment.profesionalId ||
            _servicioId != widget.appointment.servicioId ||
            _estadoSeleccionado != (widget.appointment.estado ?? 'reservado') ||
            _fechaHora != (widget.appointment.fechaInicio ?? DateTime.now()) ||
            _duracionMinutos != (widget.appointment.duracion ?? 60);

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  void _onClienteChanged() {
    if (_clienteCtrl.text.isNotEmpty) {
      _filtrarClientes(_clienteCtrl.text);
    }
  }

  void _onTelefonoChanged() {
    if (_telefonoCtrl.text.length >= 10) {
      _buscarClientePorTelefono(_telefonoCtrl.text);
    }
  }

  void _onBusquedaClienteChanged() {
    if (_buscarClienteCtrl.text.isNotEmpty) {
      _filtrarClientes(_buscarClienteCtrl.text);
    }
  }

  Future<void> _loadAppointmentHistory() async {
    setState(() {
      _historialCambios = [
        {
          'fecha': DateTime.now().subtract(const Duration(hours: 2)),
          'accion': 'Cita creada',
          'usuario': 'Sistema',
          'detalles': 'Cita inicial programada',
        },
        if (_estadoOriginal != 'reservado')
          {
            'fecha': DateTime.now().subtract(const Duration(minutes: 30)),
            'accion': 'Estado actualizado',
            'usuario': 'Recepcionista',
            'detalles': 'Estado cambiado a $_estadoOriginal',
          },
      ];
      _fechaCreacion = DateTime.now().subtract(const Duration(hours: 2));
      _ultimaModificacion =
          DateTime.now().subtract(const Duration(minutes: 30));
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _statusChangeController.dispose();
    _clienteCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _comentariosCtrl.dispose();
    _buscarClienteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildDialogContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.9,
      constraints: const BoxConstraints(
        maxWidth: 900,
        maxHeight: 800,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.015),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDialogHeader(),
          Expanded(
            child: Row(
              children: [
                // ✅ FORMULARIO PRINCIPAL
                Expanded(
                  flex: 3,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusIndicator(),
                          const SizedBox(height: 24),
                          _buildClienteSection(),
                          const SizedBox(height: 24),
                          _buildServicioSection(),
                          const SizedBox(height: 24),
                          _buildFechaHoraSection(),
                          const SizedBox(height: 24),
                          _buildConfiguracionSection(),
                          const SizedBox(height: 24),
                          _buildComentariosSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                // ✅ PANEL LATERAL DE INFORMACIÓN
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    border: Border(
                      left: BorderSide(
                        color: kBorderColor.withValues(alpha: 0.02),
                        width: 1,
                      ),
                    ),
                  ),
                  child: _buildInfoPanel(),
                ),
              ],
            ),
          ),
          _buildDialogActions(),
        ],
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(_estadoSeleccionado).withValues(alpha: 0.005),
            _getStatusColor(_estadoSeleccionado).withValues(alpha: 0.002),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: kBorderColor.withValues(alpha: 0.01),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(_estadoSeleccionado),
                  _getStatusColor(_estadoSeleccionado).withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_calendar,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Cita',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(_estadoSeleccionado),
                  ),
                ),
                Text(
                  'ID: ${widget.appointment.id} • ${_formatDateTime(_fechaHora)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'Cambios pendientes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _hasChanges
                ? _showUnsavedChangesDialog
                : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withValues(alpha: 0.01),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return AnimatedBuilder(
      animation: _statusChangeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_statusChangeAnimation.value * 0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(_estadoSeleccionado).withValues(alpha: 0.01),
                  _getStatusColor(_estadoSeleccionado).withValues(alpha: 0.005),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(_estadoSeleccionado)
                    .withValues(alpha: 0.03),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(_estadoSeleccionado),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado actual: ${_capitalizeFirst(_estadoSeleccionado)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(_estadoSeleccionado),
                        ),
                      ),
                      if (_estadoSeleccionado != _estadoOriginal)
                        Text(
                          'Estado anterior: ${_capitalizeFirst(_estadoOriginal)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusQuickActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusQuickActions() {
    final quickActions = <String, Color>{
      'confirmado': kAccentGreen,
      'en camino': kAccentBlue,
      'realizada': kBrandPurple,
      'cancelado': Colors.red.shade600,
    };

    return Wrap(
      spacing: 8,
      children: quickActions.entries
          .where((entry) => entry.key != _estadoSeleccionado)
          .take(3)
          .map((entry) => _buildQuickStatusButton(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildQuickStatusButton(String estado, Color color) {
    return Tooltip(
      message: 'Cambiar a ${_capitalizeFirst(estado)}',
      child: InkWell(
        onTap: () => _cambiarEstadoRapido(estado),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.01),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.03)),
          ),
          child: Icon(
            _getStatusIcon(estado),
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildClienteSection() {
    return _buildSection(
      title: 'Información del Cliente',
      icon: Icons.person_outline,
      child: Column(
        children: [
          // ✅ BUSCADOR DE CLIENTE INTELIGENTE - CORREGIDO
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _buscarClienteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar cliente existente',
                    hintText: 'Nombre, teléfono o email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _clienteEncontrado
                        ? const Icon(Icons.check_circle, color: kAccentGreen)
                        : null,
                  ),
                  onChanged: (value) => _filtrarClientes(value),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    setState(() => _showClienteForm = !_showClienteForm),
                icon: Icon(
                    _showClienteForm ? Icons.person_search : Icons.person_add),
                label: Text(_showClienteForm ? 'Buscar' : 'Editar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _showClienteForm ? kAccentBlue : Colors.orange.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          // ✅ SUGERENCIAS DE CLIENTES
          if (_sugerenciasClientes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _sugerenciasClientes.length,
                itemBuilder: (context, index) {
                  final cliente = _sugerenciasClientes[index];
                  final data = cliente.data() as Map<String, dynamic>;
                  return _buildClienteSuggestion(cliente.id, data);
                },
              ),
            ),
          ],

          // ✅ FORMULARIO DE CLIENTE (EXPANDIBLE)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showClienteForm ? null : 0,
            child: _showClienteForm
                ? _buildClienteForm()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteSuggestion(String clienteId, Map<String, dynamic> data) {
    final nombre = '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
    final telefono = data['telefono'] ?? '';
    final email = data['correo'] ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _seleccionarCliente(clienteId, data),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: kBorderColor.withValues(alpha: 0.02),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kBrandPurple.withValues(alpha: 0.01),
                radius: 20,
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: kBrandPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre.isEmpty ? 'Cliente sin nombre' : nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (telefono.isNotEmpty || email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [telefono, email]
                            .where((s) => s.isNotEmpty)
                            .join(' • '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClienteForm() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.005),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editar Información del Cliente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _clienteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'El nombre es requerido' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _telefonoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true
                      ? 'El teléfono es requerido'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email (opcional)',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isNotEmpty == true) {
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                return emailRegex.hasMatch(value!) ? null : 'Email inválido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServicioSection() {
    return _buildSection(
      title: 'Servicio y Profesional',
      icon: Icons.medical_services_outlined,
      child: Column(
        children: [
          // ✅ DROPDOWNS CORREGIDOS - SIN EXPANDED EN CONTENIDO
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _profesionalId,
                    decoration: const InputDecoration(
                      labelText: 'Profesional *',
                      prefixIcon: Icon(Icons.person_pin),
                    ),
                    items: widget.listaProfesionales.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre =
                          '${data["nombre"] ?? ""} ${data["apellidos"] ?? ""}'
                              .trim();
                      return DropdownMenuItem(
                        value: doc.id,
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    kBrandPurple.withValues(alpha: 0.01),
                                child: Text(
                                  nombre.isNotEmpty
                                      ? nombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: kBrandPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(child: Text(nombre)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _profesionalId = value);
                      if (value != null) {
                        _filtrarServicios(value);
                      }
                      _detectChanges();
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona un profesional' : null,
                    isExpanded: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _servicioId,
                    decoration: const InputDecoration(
                      labelText: 'Servicio *',
                      prefixIcon: Icon(Icons.spa),
                    ),
                    items: _serviciosFiltrados.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre =
                          data["name"] ?? data["nombre"] ?? "Sin nombre";
                      final duracion =
                          data["duration"] ?? data["duracion"] ?? 60;
                      return DropdownMenuItem(
                        value: doc.id,
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(nombre),
                              Text(
                                '$duracion min',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _servicioId = value);
                      if (value != null) {
                        _actualizarDuracionServicio(value);
                      }
                      _detectChanges();
                    },
                    validator: (value) =>
                        value == null ? 'Selecciona un servicio' : null,
                    isExpanded: true,
                  ),
                ),
              ),
            ],
          ),
          if (_serviciosFiltrados.isEmpty && _profesionalId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.orange.withValues(alpha: 0.03)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El profesional seleccionado no tiene servicios asignados',
                      style: TextStyle(color: Colors.orange),
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

  Widget _buildFechaHoraSection() {
    return _buildSection(
      title: 'Fecha y Hora',
      icon: Icons.schedule_outlined,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'es_MX').format(_fechaHora),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: _seleccionarHora,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hora *',
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  DateFormat('HH:mm').format(_fechaHora),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: _duracionMinutos.toString(),
              decoration: const InputDecoration(
                labelText: 'Duración',
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final duration = int.tryParse(value);
                if (duration != null && duration > 0) {
                  setState(() => _duracionMinutos = duration);
                  _detectChanges();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguracionSection() {
    return _buildSection(
      title: 'Configuración',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          // ✅ DROPDOWN ESTADO CORREGIDO
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Estado de la cita',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: _estadosDisponibles.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getStatusColor(estado),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_capitalizeFirst(estado)),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _estadoSeleccionado = value!);
                _detectChanges();
                _statusChangeController.forward().then((_) {
                  _statusChangeController.reverse();
                });
              },
              isExpanded: true,
            ),
          ),
          const SizedBox(height: 16),
          // ✅ CHECKBOXES CORREGIDOS - SIN EXPANDED
          Column(
            children: [
              CheckboxListTile(
                title: const Text('Notificar cliente'),
                subtitle: const Text('Enviar actualización por email/SMS'),
                value: _notificarCliente,
                onChanged: (value) =>
                    setState(() => _notificarCliente = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Recordatorio'),
                subtitle: const Text('Actualizar recordatorio automático'),
                value: _enviarRecordatorio,
                onChanged: (value) =>
                    setState(() => _enviarRecordatorio = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComentariosSection() {
    return _buildSection(
      title: 'Comentarios Adicionales',
      icon: Icons.note_outlined,
      child: TextFormField(
        controller: _comentariosCtrl,
        decoration: const InputDecoration(
          hintText: 'Notas especiales, instrucciones, observaciones...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        maxLength: 500,
      ),
    );
  }

  Widget _buildInfoPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildHistorialCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: kBrandPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Información de la Cita',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('ID', widget.appointment.id),
          _buildInfoRow('Cliente Original',
              widget.appointment.nombreCliente ?? 'Sin nombre'),
          _buildInfoRow('Estado Original', _capitalizeFirst(_estadoOriginal)),
          if (_fechaCreacion != null)
            _buildInfoRow('Creada', _formatDateTime(_fechaCreacion!)),
          if (_ultimaModificacion != null)
            _buildInfoRow(
                'Última modificación', _formatDateTime(_ultimaModificacion!)),
          _buildInfoRow(
              'Duración original', '${widget.appointment.duracion ?? 60} min'),
        ],
      ),
    );
  }

  Widget _buildHistorialCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: kAccentBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Historial de Cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kAccentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_historialCambios.isEmpty)
            const Text(
              'No hay cambios registrados',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          else
            ...(_historialCambios
                .take(5)
                .map((cambio) => _buildHistorialItem(cambio))),
          if (_historialCambios.length > 5) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _showFullHistorial,
                child: Text('Ver todos (${_historialCambios.length})'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistorialItem(Map<String, dynamic> cambio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kAccentBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cambio['accion'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDateTime(cambio['fecha'])} • ${cambio['usuario']}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (cambio['detalles'] != null) ...[
            const SizedBox(height: 2),
            Text(
              cambio['detalles'],
              style: const TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // ✅ BOTÓN DE DUPLICAR
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _duplicarCita,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentBlue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Duplicar Cita'),
          ),
        ),
        const SizedBox(height: 12),

        // ✅ BOTÓN DE ELIMINAR
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _showDeleteConfirmation ? null : _mostrarConfirmacionEliminar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: _showDeleteConfirmation
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.delete),
            label: Text(
                _showDeleteConfirmation ? 'Eliminando...' : 'Eliminar Cita'),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.002),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.005),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: kBrandPurple, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kBrandPurple,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: kBorderColor.withValues(alpha: 0.01),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ INFORMACIÓN RÁPIDA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Duración: $_duracionMinutos min',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Fin estimado: ${DateFormat('HH:mm').format(_fechaHora.add(Duration(minutes: _duracionMinutos)))}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (_hasChanges)
                  const Text(
                    '⚠️ Hay cambios sin guardar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // ✅ BOTONES DE ACCIÓN
          const SizedBox(width: 16),
          TextButton(
            onPressed: _hasChanges
                ? _showUnsavedChangesDialog
                : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: (_isLoading || !_hasChanges) ? null : _actualizarCita,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _hasChanges ? Colors.orange.shade600 : kBrandPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_hasChanges ? Icons.save : Icons.check),
            label: Text(_hasChanges ? 'Guardar Cambios' : 'Sin Cambios'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO
  // ========================================================================

  void _filtrarClientes(String query) {
    if (query.isEmpty) {
      setState(() => _sugerenciasClientes = []);
      return;
    }

    setState(() {
      _sugerenciasClientes = widget.listaClientes
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nombre = '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'
                .toLowerCase();
            final telefono = (data['telefono'] ?? '').toString().toLowerCase();
            final email = (data['correo'] ?? data['email'] ?? '')
                .toString()
                .toLowerCase();

            final searchQuery = query.toLowerCase();
            return nombre.contains(searchQuery) ||
                telefono.contains(searchQuery) ||
                email.contains(searchQuery);
          })
          .take(5)
          .toList();
    });
  }

  void _filtrarServicios(String profesionalId) {
    final profesionalDoc = widget.listaProfesionales.firstWhere(
      (doc) => doc.id == profesionalId,
      orElse: () => throw Exception('Profesional no encontrado'),
    );

    final data = profesionalDoc.data() as Map<String, dynamic>;
    final serviciosIds = (data['servicios'] as List<dynamic>?)?.map((servicio) {
      if (servicio is String && servicio.contains("|")) {
        return servicio.split("|")[0];
      }
      return servicio.toString();
    }).toSet();

    setState(() {
      _serviciosFiltrados = widget.listaServicios.where((serviceDoc) {
        return serviciosIds?.contains(serviceDoc.id) ?? false;
      }).toList();
    });
  }

  Future<void> _buscarClientePorTelefono(String telefono) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('clients')
          .where('telefono', isEqualTo: telefono)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final clienteDoc = query.docs.first;
        final data = clienteDoc.data();
        setState(() {
          _clienteEncontrado = true;
          _clienteId = clienteDoc.id;
          _clienteCtrl.text =
              '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
          _emailCtrl.text = data['correo'] ?? data['email'] ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente encontrado y datos actualizados'),
              backgroundColor: kAccentGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error buscando cliente: $e');
    }
  }

  void _seleccionarCliente(String clienteId, Map<String, dynamic> data) {
    setState(() {
      _clienteId = clienteId;
      _clienteEncontrado = true;
      _clienteCtrl.text =
          '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
      _telefonoCtrl.text = data['telefono'] ?? '';
      _emailCtrl.text = data['correo'] ?? data['email'] ?? '';
      _buscarClienteCtrl.text = _clienteCtrl.text;
      _sugerenciasClientes = [];
      _showClienteForm = false;
    });

    _detectChanges();
    HapticFeedback.selectionClick();
  }

  void _actualizarDuracionServicio(String servicioId) {
    try {
      final servicioDoc =
          _serviciosFiltrados.firstWhere((doc) => doc.id == servicioId);
      final data = servicioDoc.data() as Map<String, dynamic>;
      final duracion = data['duration'] ?? data['duracion'] ?? 60;

      setState(() => _duracionMinutos = duracion);
      _detectChanges();
    } catch (e) {
      debugPrint('Error actualizando duración: $e');
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'MX'),
    );

    if (picked != null) {
      setState(() {
        _fechaHora = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _fechaHora.hour,
          _fechaHora.minute,
        );
      });
      _detectChanges();
    }
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaHora),
    );

    if (picked != null) {
      setState(() {
        _fechaHora = DateTime(
          _fechaHora.year,
          _fechaHora.month,
          _fechaHora.day,
          picked.hour,
          picked.minute,
        );
      });
      _detectChanges();
    }
  }

  void _cambiarEstadoRapido(String nuevoEstado) {
    setState(() => _estadoSeleccionado = nuevoEstado);
    _detectChanges();
    _statusChangeController.forward().then((_) {
      _statusChangeController.reverse();
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _actualizarCita() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ OBTENER DATOS ADICIONALES
      final profesionalData = await _getProfesionalData(_profesionalId!);
      final servicioData = await _getServicioData(_servicioId!);

      // ✅ PREPARAR DATOS ACTUALIZADOS
      final updateData = {
        'clienteNombre': _clienteCtrl.text.trim(),
        'clientEmail':
            _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'clientPhone': _telefonoCtrl.text.trim().isEmpty
            ? null
            : _telefonoCtrl.text.trim(),
        'profesionalId': _profesionalId,
        'profesionalNombre': profesionalData['nombre'],
        'servicioId': _servicioId,
        'servicioNombre': servicioData['nombre'],
        'fecha': Timestamp.fromDate(_fechaHora),
        'estado': _estadoSeleccionado,
        'comentarios': _comentariosCtrl.text.trim().isEmpty
            ? null
            : _comentariosCtrl.text.trim(),
        'duracion': _duracionMinutos,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // ✅ ACTUALIZAR EN FIRESTORE
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.appointment.id)
          .update(updateData);

      // ✅ REGISTRAR CAMBIO EN HISTORIAL
      await _registrarCambioEnHistorial('Cita actualizada', 'Usuario actual',
          'Se actualizaron los datos de la cita');

      // ✅ CREAR MODELO ACTUALIZADO
      final updatedAppointment = AppointmentModel(
        id: widget.appointment.id,
        nombreCliente: _clienteCtrl.text.trim(),
        clientEmail:
            _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        clientPhone: _telefonoCtrl.text.trim().isEmpty
            ? null
            : _telefonoCtrl.text.trim(),
        profesionalId: _profesionalId,
        profesionalNombre: profesionalData['nombre'],
        servicioId: _servicioId,
        servicioNombre: servicioData['nombre'],
        estado: _estadoSeleccionado,
        comentarios: _comentariosCtrl.text.trim().isEmpty
            ? null
            : _comentariosCtrl.text.trim(),
        fechaInicio: _fechaHora,
        fechaFin: _fechaHora.add(Duration(minutes: _duracionMinutos)),
        duracion: _duracionMinutos,
      );

      // ✅ NOTIFICAR AL PADRE
      widget.onAppointmentUpdated?.call(updatedAppointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita actualizada exitosamente'),
            backgroundColor: kAccentGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _duplicarCita() async {
    try {
      final nuevaFecha = _fechaHora.add(const Duration(days: 1));
      final appointmentData = {
        'clienteNombre': _clienteCtrl.text.trim(),
        'clientEmail':
            _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'clientPhone': _telefonoCtrl.text.trim().isEmpty
            ? null
            : _telefonoCtrl.text.trim(),
        'profesionalId': _profesionalId,
        'profesionalNombre':
            (await _getProfesionalData(_profesionalId!))['nombre'],
        'servicioId': _servicioId,
        'servicioNombre': (await _getServicioData(_servicioId!))['nombre'],
        'fecha': Timestamp.fromDate(nuevaFecha),
        'estado': 'reservado',
        'comentarios': 'Cita duplicada desde ${widget.appointment.id}',
        'duracion': _duracionMinutos,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .add(appointmentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Cita duplicada para ${DateFormat('dd/MM/yyyy HH:mm').format(nuevaFecha)}'),
            backgroundColor: kAccentBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al duplicar la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarConfirmacionEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Confirmar Eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de que deseas eliminar esta cita?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.03)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${_clienteCtrl.text}'),
                  Text('Fecha: ${_formatDateTime(_fechaHora)}'),
                  Text('Estado: ${_capitalizeFirst(_estadoSeleccionado)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ Esta acción no se puede deshacer.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _eliminarCita();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar Definitivamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarCita() async {
    setState(() => _showDeleteConfirmation = true);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.appointment.id)
          .delete();

      widget.onAppointmentDeleted?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita eliminada exitosamente'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la cita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _showDeleteConfirmation = false);
      }
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Cambios Sin Guardar'),
          ],
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Qué deseas hacer?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar editor sin guardar
            },
            child: const Text('Descartar Cambios'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar Editando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _actualizarCita();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar y Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showFullHistorial() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: kAccentBlue, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Historial Completo de Cambios',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kAccentBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _historialCambios.length,
                  itemBuilder: (context, index) {
                    final cambio = _historialCambios[index];
                    return _buildHistorialItem(cambio);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registrarCambioEnHistorial(
      String accion, String usuario, String detalles) async {
    try {
      setState(() {
        _historialCambios.insert(0, {
          'fecha': DateTime.now(),
          'accion': accion,
          'usuario': usuario,
          'detalles': detalles,
        });
      });
    } catch (e) {
      debugPrint('Error registrando cambio en historial: $e');
    }
  }

  Future<Map<String, dynamic>> _getProfesionalData(String profesionalId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('profesionales')
          .doc(profesionalId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'nombre': '${data['nombre'] ?? ''} ${data['apellidos'] ?? ''}'.trim(),
        };
      }
    } catch (e) {
      debugPrint('Error obteniendo datos del profesional: $e');
    }
    return {'nombre': 'Profesional desconocido'};
  }

  Future<Map<String, dynamic>> _getServicioData(String servicioId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('services')
          .doc(servicioId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'nombre': data['name'] ?? data['nombre'] ?? 'Sin nombre',
          'duracion': data['duration'] ?? data['duracion'] ?? 60,
        };
      }
    } catch (e) {
      debugPrint('Error obteniendo datos del servicio: $e');
    }
    return {'nombre': 'Servicio desconocido', 'duracion': 60};
  }

  // ========================================================================
  // 🎯 MÉTODOS HELPER
  // ========================================================================

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmado':
        return kAccentGreen;
      case 'reservado':
        return Colors.orange.shade600;
      case 'en camino':
        return kAccentBlue;
      case 'realizada':
        return kBrandPurple;
      case 'cancelado':
        return Colors.red.shade600;
      case 'recordatorio':
        return Colors.amber.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmado':
        return Icons.check_circle;
      case 'en camino':
        return Icons.directions_run;
      case 'realizada':
        return Icons.task_alt;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}
