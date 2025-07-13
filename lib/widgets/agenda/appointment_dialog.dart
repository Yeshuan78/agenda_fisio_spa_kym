// [appointment_dialog_premium.dart] - VERSIÓN CORREGIDA CON ESTRUCTURA FIRESTORE REAL
// 📁 Ubicación: /lib/widgets/agenda/appointment_dialog_premium.dart
// 🔧 SOLUCIONADO: Servicios por profesional + estructura de colecciones real

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AppointmentDialogPremium extends StatefulWidget {
  final DateTime? fechaSeleccionada;
  final String? profesionalIdPreseleccionado;
  final String? servicioIdPreseleccionado;
  final List<DocumentSnapshot> listaClientes;
  final List<DocumentSnapshot> listaProfesionales;
  final List<DocumentSnapshot> listaServicios;

  const AppointmentDialogPremium({
    super.key,
    this.fechaSeleccionada,
    this.profesionalIdPreseleccionado,
    this.servicioIdPreseleccionado,
    required this.listaClientes,
    required this.listaProfesionales,
    required this.listaServicios,
  });

  @override
  State<AppointmentDialogPremium> createState() =>
      _AppointmentDialogPremiumState();
}

class _AppointmentDialogPremiumState extends State<AppointmentDialogPremium>
    with TickerProviderStateMixin {
  // ✅ CONTROLLERS DE ANIMACIÓN
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

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
  DateTime _fechaHora = DateTime.now();
  int _duracionMinutos = 60;
  bool _notificarCliente = true;
  bool _enviarRecordatorio = false;

  // ✅ ESTADO DE VALIDACIÓN
  bool _isLoading = false;
  bool _showClienteForm = false;
  bool _clienteEncontrado = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeForm();
    _setupValidationListeners();
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

    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeForm() {
    _fechaHora = widget.fechaSeleccionada ?? DateTime.now();
    _profesionalId = widget.profesionalIdPreseleccionado;
    _servicioId = widget.servicioIdPreseleccionado;

    // ✅ FILTRAR SERVICIOS SI HAY PROFESIONAL PRESELECCIONADO
    if (_profesionalId != null) {
      _filtrarServicios(_profesionalId!);
    }
  }

  void _setupValidationListeners() {
    _clienteCtrl.addListener(_onClienteChanged);
    _telefonoCtrl.addListener(_onTelefonoChanged);
    _buscarClienteCtrl.addListener(_onBusquedaClienteChanged);
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

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
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
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.85,
      constraints: const BoxConstraints(
        maxWidth: 800,
        maxHeight: 700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDialogHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
            kBrandPurple.withValues(alpha: 0.05),
            kAccentBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(
            color: kBorderColor.withValues(alpha: 0.1),
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
              gradient: const LinearGradient(
                colors: [kBrandPurple, kAccentBlue],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_task,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nueva Cita',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kBrandPurple,
                  ),
                ),
                Text(
                  'Programar nueva cita con validación automática',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.grey),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteSection() {
    return _buildSection(
      title: 'Información del Cliente',
      icon: Icons.person_outline,
      child: Column(
        children: [
          // ✅ BUSCADOR DE CLIENTE INTELIGENTE
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
                label: Text(_showClienteForm ? 'Buscar' : 'Nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _showClienteForm ? kAccentBlue : kAccentGreen,
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
                border: Border.all(color: kBorderColor.withValues(alpha: 0.3)),
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
                color: kBorderColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kBrandPurple.withValues(alpha: 0.1),
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
        color: kAccentGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Nuevo Cliente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kAccentGreen,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _abrirFormularioNuevoCliente(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Completo'),
                style: TextButton.styleFrom(
                  foregroundColor: kAccentGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _profesionalId,
                  decoration: const InputDecoration(
                    labelText: 'Profesional *',
                    prefixIcon: Icon(Icons.person_pin),
                  ),
                  isExpanded: true,
                  items: widget.listaProfesionales.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = data["nombre"] ?? "Sin nombre";
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                kBrandPurple.withValues(alpha: 0.1),
                            child: Text(
                              nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 10,
                                color: kBrandPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              nombre,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _profesionalId = value;
                      _servicioId = null; // ✅ RESETEAR SERVICIO
                    });
                    if (value != null) {
                      _filtrarServicios(value);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Selecciona un profesional' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _servicioId,
                  decoration: const InputDecoration(
                    labelText: 'Servicio *',
                    prefixIcon: Icon(Icons.spa),
                  ),
                  isExpanded: true,
                  items: _serviciosFiltrados.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = data["name"] ?? "Sin nombre";
                    final duracion = data["duration"] ?? 60;
                    final categoria = data["category"] ?? "";
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Tooltip(
                        message: '$nombre - $categoria ($duracion min)',
                        child: Text(
                          '$nombre ($duracion min)',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _servicioId = value);
                    if (value != null) {
                      _actualizarDuracionServicio(value);
                    }
                  },
                  validator: (value) =>
                      value == null ? 'Selecciona un servicio' : null,
                ),
              ),
            ],
          ),
          if (_serviciosFiltrados.isEmpty && _profesionalId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
          DropdownButtonFormField<String>(
            value: _estadoSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Estado de la cita',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            isExpanded: true,
            items: _estadosDisponibles.map((estado) {
              return DropdownMenuItem(
                value: estado,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getEstadoColor(estado),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _capitalizeFirst(estado),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _estadoSeleccionado = value!),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              CheckboxListTile(
                title: const Text('Notificar cliente'),
                subtitle: const Text('Enviar confirmación por email/SMS'),
                value: _notificarCliente,
                onChanged: (value) =>
                    setState(() => _notificarCliente = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Recordatorio'),
                subtitle: const Text('Programar recordatorio automático'),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.05),
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
            color: kBorderColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
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
              ],
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _guardarCita,
            style: ElevatedButton.styleFrom(
              backgroundColor: kBrandPurple,
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
                : const Icon(Icons.add),
            label: const Text('Crear Cita'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO - CORREGIDOS PARA ESTRUCTURA FIRESTORE REAL
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

  // ✅ CORREGIDO: Método para filtrar servicios según estructura real de Firestore
  void _filtrarServicios(String profesionalId) {
    try {
      final profesionalDoc = widget.listaProfesionales.firstWhere(
        (doc) => doc.id == profesionalId,
        orElse: () => throw Exception('Profesional no encontrado'),
      );

      final data = profesionalDoc.data() as Map<String, dynamic>;
      final serviciosDelProfesional = data['servicios'] as List<dynamic>? ?? [];

      debugPrint(
          '🔍 Servicios del profesional $profesionalId: $serviciosDelProfesional');

      // ✅ EXTRAER IDs DE SERVICIOS SEGÚN ESTRUCTURA REAL
      final serviciosIds = <String>{};

      for (final servicio in serviciosDelProfesional) {
        if (servicio is Map<String, dynamic>) {
          // Estructura: {"category": "Terapeutica", "name": "Servicio", "serviceId": "id"}
          final serviceId = servicio['serviceId'];
          if (serviceId != null && serviceId.toString().isNotEmpty) {
            serviciosIds.add(serviceId.toString());
          }
        } else if (servicio is String) {
          // Por si acaso hay strings directos
          serviciosIds.add(servicio);
        }
      }

      debugPrint('🎯 IDs de servicios extraídos: $serviciosIds');

      // ✅ FILTRAR SERVICIOS DISPONIBLES
      setState(() {
        _serviciosFiltrados = widget.listaServicios.where((serviceDoc) {
          final isAssigned = serviciosIds.contains(serviceDoc.id);
          if (isAssigned) {
            final serviceData = serviceDoc.data() as Map<String, dynamic>;
            debugPrint(
                '✅ Servicio encontrado: ${serviceData['name']} (${serviceDoc.id})');
          }
          return isAssigned;
        }).toList();
      });

      debugPrint('📋 Total servicios filtrados: ${_serviciosFiltrados.length}');
    } catch (e) {
      debugPrint('❌ Error filtrando servicios: $e');
      setState(() => _serviciosFiltrados = []);
    }
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
              content: Text('Cliente encontrado y datos autocompletados'),
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

    HapticFeedback.selectionClick();
  }

  void _actualizarDuracionServicio(String servicioId) {
    try {
      final servicioDoc =
          _serviciosFiltrados.firstWhere((doc) => doc.id == servicioId);
      final data = servicioDoc.data() as Map<String, dynamic>;
      final duracion =
          data['duration'] ?? 60; // ✅ USAR 'duration' según estructura real

      setState(() => _duracionMinutos = duracion);
    } catch (e) {
      debugPrint('Error actualizando duración: $e');
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime.now(),
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
    }
  }

  Future<void> _guardarCita() async {
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
      String? clienteIdFinal = _clienteId;

      // ✅ CREAR CLIENTE SI ES NUEVO
      if (!_clienteEncontrado && _showClienteForm) {
        clienteIdFinal = await _crearNuevoCliente();
      }

      // ✅ OBTENER DATOS ADICIONALES
      final profesionalData = await _getProfesionalData(_profesionalId!);
      final servicioData = await _getServicioData(_servicioId!);

      // ✅ CREAR NUEVA CITA CON ESTRUCTURA FIRESTORE REAL
      final appointmentData = {
        // ✅ ESTRUCTURA SEGÚN EJEMPLO REAL DE BOOKINGS
        'clienteId': clienteIdFinal,
        'clienteNombre':
            _clienteCtrl.text.trim(), // ✅ USAR 'clienteNombre' no 'clientName'
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
        'estado': _estadoSeleccionado, // ✅ USAR 'estado' no 'status'
        'comentarios': _comentariosCtrl.text.trim().isEmpty
            ? null
            : _comentariosCtrl.text.trim(),
        'duracion': _duracionMinutos,
        'notificarCliente': _notificarCliente,
        'enviarRecordatorio': _enviarRecordatorio,
        'creadoEn': FieldValue
            .serverTimestamp(), // ✅ USAR 'creadoEn' según estructura real
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .add(appointmentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita creada exitosamente'),
            backgroundColor: kAccentGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la cita: $e'),
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

  Future<String> _crearNuevoCliente() async {
    final clienteData = {
      'idUsuario': const Uuid().v4(),
      'nombre': _clienteCtrl.text.trim().split(' ').first,
      'apellidos': _clienteCtrl.text.trim().split(' ').skip(1).join(' '),
      'telefono': _telefonoCtrl.text.trim(),
      'correo': _emailCtrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef =
        await FirebaseFirestore.instance.collection('clients').add(clienteData);

    return docRef.id;
  }

  Future<void> _abrirFormularioNuevoCliente() async {
    await showFormularioClienteCompleto(
      context: context,
      onClienteCreado: (nuevoId, datosCliente) {
        setState(() {
          _clienteId = nuevoId;
          _clienteEncontrado = true;
          _clienteCtrl.text =
              '${datosCliente['nombre']} ${datosCliente['apellidos']}'.trim();
          _telefonoCtrl.text = datosCliente['telefono'] ?? '';
          _emailCtrl.text = datosCliente['correo'] ?? '';
          _showClienteForm = false;
        });
      },
    );
  }

  Future<Map<String, dynamic>> _getProfesionalData(String profesionalId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('profesionales')
          .doc(profesionalId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        // ✅ USAR SOLO 'nombre' SEGÚN ESTRUCTURA REAL
        return {
          'nombre': data['nombre'] ?? 'Profesional desconocido',
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
          'nombre': data['name'] ??
              'Sin nombre', // ✅ USAR 'name' según estructura real
          'duracion':
              data['duration'] ?? 60, // ✅ USAR 'duration' según estructura real
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

  Color _getEstadoColor(String estado) {
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

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// ========================================================================
// 🎯 FUNCIÓN AUXILIAR PARA CREAR CLIENTE COMPLETO
// ========================================================================

Future<void> showFormularioClienteCompleto({
  required BuildContext context,
  required Function(String id, Map<String, dynamic> datos) onClienteCreado,
}) async {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nombreCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final empresaCtrl = TextEditingController();

  bool isLoading = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.8,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kBrandPurple.withValues(alpha: 0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kAccentGreen.withValues(alpha: 0.1), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kAccentGreen, Colors.green],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuevo Cliente',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kAccentGreen,
                            ),
                          ),
                          Text(
                            'Registro completo en el sistema CRM',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Información Personal
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: nombreCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre *',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Requerido' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: apellidosCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Apellidos *',
                                  prefixIcon: Icon(Icons.family_restroom),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Requerido' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: telefonoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono *',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: correoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico *',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Requerido';
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            return emailRegex.hasMatch(v!)
                                ? null
                                : 'Email inválido';
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: empresaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Empresa (Opcional)',
                            prefixIcon: Icon(Icons.domain_outlined),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Acciones
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: kBorderColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '* Campos obligatorios',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              setDialogState(() => isLoading = true);

                              try {
                                final clienteData = {
                                  'idUsuario': const Uuid().v4(),
                                  'nombre': nombreCtrl.text.trim(),
                                  'apellidos': apellidosCtrl.text.trim(),
                                  'correo': correoCtrl.text.trim(),
                                  'telefono': telefonoCtrl.text.trim(),
                                  'empresa': empresaCtrl.text.trim(),
                                  'fechaRegistro': FieldValue.serverTimestamp(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'updatedAt': FieldValue.serverTimestamp(),
                                  'activo': true,
                                };

                                final docRef = await FirebaseFirestore.instance
                                    .collection('clients')
                                    .add(clienteData);

                                onClienteCreado(docRef.id, clienteData);

                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Cliente "${nombreCtrl.text.trim()}" creado exitosamente'),
                                      backgroundColor: kAccentGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error al crear cliente: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setDialogState(() => isLoading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(isLoading ? 'Guardando...' : 'Crear Cliente'),
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
