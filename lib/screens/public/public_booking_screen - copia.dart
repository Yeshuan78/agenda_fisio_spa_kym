// 📱 ARCHIVO: /lib/screens/public/public_booking_screen.dart
// 🎯 PANTALLA PÚBLICA DE AGENDAMIENTO CON FIX MOUNTED

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/theme.dart';

class PublicBookingScreen extends StatefulWidget {
  final String? companyId;
  final bool isParticular;
  final Map<String, String>? queryParams;

  const PublicBookingScreen({
    super.key,
    this.companyId,
    this.isParticular = false,
    this.queryParams,
  });

  @override
  State<PublicBookingScreen> createState() => _PublicBookingScreenState();
}

class _PublicBookingScreenState extends State<PublicBookingScreen> {
  // 🎯 ESTADO DEL FORMULARIO
  String? _selectedEventId;
  String? _selectedServiceId;
  String? _selectedProfessionalId;
  DateTime? _selectedDate;
  String? _selectedTime;

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  List<DocumentSnapshot> _eventos = [];
  List<Map<String, dynamic>> _serviciosDisponibles = [];
  List<DocumentSnapshot> _professionals = [];
  Map<String, dynamic>? _companyData;
  Map<String, dynamic>? _selectedEventData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// 🔧 CARGA INICIAL DE DATOS CON FIX MOUNTED
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (widget.companyId != null) {
        // Cargar datos de empresa
        await _loadCompanyData();
        // Cargar eventos activos de la empresa
        await _loadCompanyEvents();
      } else {
        // Para particulares, cargar servicios directamente
        await _loadServicesForParticulares();
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  /// 🏢 CARGAR DATOS DE LA EMPRESA
  Future<void> _loadCompanyData() async {
    final companyDoc = await FirebaseFirestore.instance
        .collection('empresas')
        .doc(widget.companyId)
        .get();

    if (companyDoc.exists) {
      _companyData = companyDoc.data();
    } else {
      throw Exception('Empresa no encontrada');
    }
  }

  /// 📅 CARGAR EVENTOS ACTIVOS DE LA EMPRESA CON FIX MOUNTED
  Future<void> _loadCompanyEvents() async {
    final now = DateTime.now();

    // Buscar eventos usando el nombre de la empresa
    final companyName = _companyData?['nombre'] ?? '';

    Query query = FirebaseFirestore.instance
        .collection('eventos')
        .where('estado', isEqualTo: 'activo');

    // Filtrar por empresa (usar el campo que coincida con tu estructura)
    if (companyName.isNotEmpty) {
      try {
        final snapshot =
            await query.where('empresa', isEqualTo: companyName).get();

        if (snapshot.docs.isEmpty) {
          // Si no encuentra con 'empresa', intentar con 'empresaId'
          final snapshotById = await FirebaseFirestore.instance
              .collection('eventos')
              .where('estado', isEqualTo: 'activo')
              .where('empresaId', isEqualTo: widget.companyId)
              .get();

          if (!mounted) return;
          setState(() => _eventos = snapshotById.docs);
        } else {
          if (!mounted) return;
          setState(() => _eventos = snapshot.docs);
        }
      } catch (e) {
        debugPrint('Error cargando eventos: $e');
        // Cargar todos los eventos como fallback
        final allEvents = await FirebaseFirestore.instance
            .collection('eventos')
            .where('estado', isEqualTo: 'activo')
            .get();

        if (!mounted) return;
        setState(() => _eventos = allEvents.docs);
      }
    }
  }

  /// 🛍️ CARGAR SERVICIOS PARA PARTICULARES CON FIX MOUNTED
  Future<void> _loadServicesForParticulares() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('activo', isEqualTo: true)
        .get();

    if (!mounted) return;
    setState(() {
      _serviciosDisponibles = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'duration': data['duration'] ?? 60,
          'price': data['price'] ?? 0,
          'category': data['category'] ?? '',
        };
      }).toList();
    });

    // Cargar profesionales
    await _loadProfessionals();
  }

  /// 📋 CARGAR SERVICIOS DE UN EVENTO ESPECÍFICO CON FIX MOUNTED
  Future<void> _loadServicesFromEvent(String eventId) async {
    final eventDoc = await FirebaseFirestore.instance
        .collection('eventos')
        .doc(eventId)
        .get();

    if (!eventDoc.exists) return;

    final eventData = eventDoc.data()!;
    _selectedEventData = eventData;

    // Obtener servicios asignados al evento (estructura de objetos)
    final serviciosAsignados =
        List<Map<String, dynamic>>.from(eventData['serviciosAsignados'] ?? []);

    if (serviciosAsignados.isEmpty) {
      if (!mounted) return;
      setState(() => _serviciosDisponibles = []);
      return;
    }

    // Cargar datos completos de los servicios
    final servicios = <Map<String, dynamic>>[];

    for (Map<String, dynamic> servicioAsignado in serviciosAsignados) {
      final serviceId = servicioAsignado['servicioId'];
      if (serviceId == null) continue;

      try {
        final serviceDoc = await FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .get();

        if (serviceDoc.exists) {
          final data = serviceDoc.data()!;
          servicios.add({
            'id': serviceDoc.id,
            'name': data['name'] ?? servicioAsignado['servicioNombre'] ?? '',
            'duration': data['duration'] ?? 60,
            'price': data['price'] ?? 0,
            'category': data['category'] ?? '',
            // Información adicional del evento
            'profesionalAsignado': servicioAsignado['profesionalId'],
            'profesionalNombre': servicioAsignado['profesionalNombre'],
            'fechaAsignada': servicioAsignado['fechaAsignada'],
            'ubicacion': servicioAsignado['ubicacion'],
          });
        }
      } catch (e) {
        debugPrint('Error cargando servicio $serviceId: $e');
      }
    }

    if (!mounted) return;
    setState(() => _serviciosDisponibles = servicios);
  }

  /// 👨‍⚕️ CARGAR PROFESIONALES CON FIX MOUNTED
  Future<void> _loadProfessionals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('profesionales')
        .where('estado', isEqualTo: true)
        .get();

    if (!mounted) return;
    setState(() => _professionals = snapshot.docs);
  }

  /// 💾 ENVIAR BOOKING A FIREBASE
  Future<void> _submitBooking() async {
    if (!_validateForm()) return;

    try {
      // Crear booking data
      final bookingData = await _buildBookingData();

      final docRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(bookingData);

      // Navegar a confirmación
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bookingId: docRef.id,
              bookingData: bookingData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creando cita: $e')),
        );
      }
    }
  }

  /// ✅ VALIDAR FORMULARIO
  bool _validateForm() {
    if (widget.companyId != null && _selectedEventId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un evento')),
        );
      }
      return false;
    }

    if (_selectedServiceId == null ||
        _selectedProfessionalId == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _nombreController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _emailController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
      }
      return false;
    }

    return true;
  }

  /// 🏗️ CONSTRUIR DATOS DEL BOOKING
  Future<Map<String, dynamic>> _buildBookingData() async {
    // Obtener datos del servicio
    final servicioData =
        _serviciosDisponibles.firstWhere((s) => s['id'] == _selectedServiceId);

    // Obtener datos del profesional
    final professionalDoc =
        _professionals.firstWhere((p) => p.id == _selectedProfessionalId);
    final professionalData = professionalDoc.data() as Map<String, dynamic>;

    // Crear fecha y hora completa
    final timeParts = _selectedTime!.split(':');
    final finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    return {
      'clienteNombre': _nombreController.text.trim(),
      'clienteTelefono': _telefonoController.text.trim(),
      'clienteEmail': _emailController.text.trim(),
      'servicioId': _selectedServiceId,
      'servicioNombre': servicioData['name'],
      'profesionalId': _selectedProfessionalId,
      'profesionalNombre':
          '${professionalData['nombre']} ${professionalData['apellidos'] ?? ''}'
              .trim(),
      'fecha': Timestamp.fromDate(finalDateTime),
      'duracion': servicioData['duration'],
      'precio': servicioData['price'],
      'estado': 'reservado',
      'tipoBooking': widget.companyId != null ? 'B2B' : 'B2C',
      'empresaId': widget.companyId,
      'empresaNombre': _companyData?['nombre'],
      'eventoId': _selectedEventId,
      'eventoNombre': _selectedEventData?['nombre'],
      'promocion': widget.queryParams?['promo'],
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: kBrandPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: kBrandPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            // Mostrar selector de eventos para empresas
            if (widget.companyId != null) ...[
              _buildEventSelector(),
              const SizedBox(height: 24),
            ],

            // Mostrar servicios solo después de seleccionar evento (empresas) o directamente (particulares)
            if ((widget.companyId != null && _selectedEventId != null) ||
                (widget.companyId == null &&
                    _serviciosDisponibles.isNotEmpty)) ...[
              _buildServiceSelector(),
              const SizedBox(height: 24),
            ],

            if (_selectedServiceId != null) ...[
              _buildProfessionalSelector(),
              const SizedBox(height: 24),
            ],

            if (_selectedProfessionalId != null) ...[
              _buildDateTimeSelector(),
              const SizedBox(height: 24),
            ],

            if (_selectedDate != null && _selectedTime != null) ...[
              _buildClientForm(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// 📝 TÍTULO DE LA PÁGINA
  String _getPageTitle() {
    if (widget.companyId != null) {
      return 'Agendar Cita - ${_companyData?['nombre'] ?? 'Empresa'}';
    }
    return 'Agendar Cita - Fisio Spa KYM';
  }

  /// 🎨 HEADER CORPORATIVO O GENERAL
  Widget _buildHeader() {
    if (widget.companyId != null && _companyData != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kBrandPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, size: 30, color: kBrandPurple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido colaborador',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _companyData!['nombre'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kHeaderGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fisio Spa KYM',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu momento de relajación te espera',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          if (widget.queryParams?['promo'] != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '🎉 Promoción: ${widget.queryParams!['promo']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 📅 SELECTOR DE EVENTOS (SOLO EMPRESAS)
  Widget _buildEventSelector() {
    if (_eventos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No hay eventos disponibles para tu empresa en este momento.',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona el evento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
        const SizedBox(height: 12),
        ...(_eventos.map((event) {
          final data = event.data() as Map<String, dynamic>;
          final isSelected = _selectedEventId == event.id;
          final fecha =
              (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now();

          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              setState(() {
                _selectedEventId = event.id;
                _selectedServiceId = null;
                _serviciosDisponibles = [];
              });
              _loadServicesFromEvent(event.id);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? kBrandPurple : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kBrandPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    color: isSelected ? kBrandPurple : Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nombre'] ?? 'Evento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? kBrandPurple : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${fecha.day}/${fecha.month}/${fecha.year}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: kBrandPurple),
                ],
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  /// 🛍️ SELECTOR DE SERVICIOS
  Widget _buildServiceSelector() {
    if (_serviciosDisponibles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No hay servicios disponibles.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tu servicio',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
        const SizedBox(height: 12),
        ...(_serviciosDisponibles.map((service) {
          final isSelected = _selectedServiceId == service['id'];

          return GestureDetector(
            onTap: () {
              if (!mounted) return;
              setState(() {
                _selectedServiceId = service['id'];
                _selectedProfessionalId = null;
              });
              _loadProfessionals();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? kBrandPurple : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kBrandPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.spa,
                    color: isSelected ? kBrandPurple : Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] ?? 'Servicio',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? kBrandPurple : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service['duration'] ?? 60} min',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.companyId == null)
                    Text(
                      '\$${service['price']?.toStringAsFixed(0) ?? '0'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kBrandPurple,
                        fontSize: 16,
                      ),
                    ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: kBrandPurple),
                ],
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  /// 👨‍⚕️ SELECTOR DE PROFESIONAL
  Widget _buildProfessionalSelector() {
    if (_professionals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: kBrandPurple),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona tu profesional',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedProfessionalId,
            decoration: const InputDecoration(
              hintText: 'Elige un profesional',
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _professionals.map((professional) {
              final data = professional.data() as Map<String, dynamic>;
              return DropdownMenuItem(
                value: professional.id,
                child:
                    Text('${data['nombre']} ${data['apellidos'] ?? ''}'.trim()),
              );
            }).toList(),
            onChanged: (value) {
              if (!mounted) return;
              setState(() => _selectedProfessionalId = value);
            },
          ),
        ),
      ],
    );
  }

  /// 📅 SELECTOR DE FECHA Y HORA
  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha y hora',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: kBrandPurple,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null && mounted) {
                    setState(() {
                      _selectedDate = date;
                      _selectedTime = null;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Seleccionar fecha',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedTime,
                  decoration: const InputDecoration(
                    hintText: 'Hora',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  items: _generateTimeSlots().map((time) {
                    return DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: _selectedDate != null
                      ? (value) {
                          if (mounted) {
                            setState(() => _selectedTime = value);
                          }
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ⏰ GENERAR SLOTS DE TIEMPO
  List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (int hour = 9; hour < 18; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  /// 📝 FORMULARIO DE DATOS DEL CLIENTE
  Widget _buildClientForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tus datos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _nombreController,
          label: 'Nombre completo',
          hint: 'Tu nombre y apellidos',
          icon: Icons.person,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _telefonoController,
          label: 'Teléfono',
          hint: '55 1234 5678',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'tu@email.com',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  /// 📝 CAMPO DE TEXTO PERSONALIZADO
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: kBrandPurple),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// 🚀 BOTÓN DE ENVÍO
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: kButtonGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: kBrandPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _submitBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Confirmar Cita',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎉 PANTALLA DE CONFIRMACIÓN
class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('¡Cita Confirmada!'),
        backgroundColor: kAccentGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: kAccentGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kAccentGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Perfecto!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu cita ha sido confirmada exitosamente',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'ID de tu cita: ${bookingId.substring(0, 8)}...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kBrandPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Servicio:', bookingData['servicioNombre']),
                    _buildDetailRow(
                        'Profesional:', bookingData['profesionalNombre']),
                    _buildDetailRow('Cliente:', bookingData['clienteNombre']),
                    if (bookingData['empresaNombre'] != null)
                      _buildDetailRow('Empresa:', bookingData['empresaNombre']),
                    if (bookingData['eventoNombre'] != null)
                      _buildDetailRow('Evento:', bookingData['eventoNombre']),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Recibirás confirmación por WhatsApp y email',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/agenda/premium',
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
