// [schedule_block_dialog_premium.dart] - VERSIÓN FUNCIONAL COMPLETA
// 📁 Ubicación: /lib/widgets/agenda/schedule_block_dialog_premium.dart
// 🔧 FUNCIONAL: Selector de profesional conectado a Firestore real

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

Future<void> showScheduleBlockDialogPremium({
  required BuildContext context,
  required DateTime slotStart,
  required String profesionalId,
  required Function({
    required String profesionalId,
    required DateTime day,
    required int startHour,
    required int startMin,
    required int endHour,
    required int endMin,
    required String blockName,
  }) onSaveBlock,
  Function()? onAfterSave,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => _ScheduleBlockDialogPremium(
      slotStart: slotStart,
      profesionalId: profesionalId,
      onSaveBlock: onSaveBlock,
      onAfterSave: onAfterSave,
    ),
  );
}

class _ScheduleBlockDialogPremium extends StatefulWidget {
  final DateTime slotStart;
  final String profesionalId;
  final Function({
    required String profesionalId,
    required DateTime day,
    required int startHour,
    required int startMin,
    required int endHour,
    required int endMin,
    required String blockName,
  }) onSaveBlock;
  final Function()? onAfterSave;

  const _ScheduleBlockDialogPremium({
    required this.slotStart,
    required this.profesionalId,
    required this.onSaveBlock,
    this.onAfterSave,
  });

  @override
  State<_ScheduleBlockDialogPremium> createState() =>
      _ScheduleBlockDialogPremiumState();
}

class _ScheduleBlockDialogPremiumState
    extends State<_ScheduleBlockDialogPremium> with TickerProviderStateMixin {
  // ✅ ANIMATION CONTROLLERS
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  // ✅ ANIMATIONS
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  // ✅ FORM CONTROLLERS
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();

  // ✅ ESTADO DEL FORMULARIO
  DateTime _fechaSeleccionada = DateTime.now(); // ✅ NUEVA VARIABLE PARA FECHA
  TimeOfDay _horaInicio = TimeOfDay.now();
  TimeOfDay? _horaFin;
  String _tipoBloqueoSeleccionado = 'mantenimiento';
  String _prioridadSeleccionada = 'media';
  bool _notificarEquipo = true;
  bool _mostrarEnCalendario = true;
  bool _isLoading = false;

  // ✅ VARIABLES PARA PROFESIONALES - CONECTADAS A FIRESTORE
  String? _profesionalSeleccionado;
  List<DocumentSnapshot> _profesionales = [];
  bool _loadingProfesionales = true;

  // ✅ CONFIGURACIÓN
  final List<Map<String, dynamic>> _tiposBloqueo = [
    {
      'id': 'mantenimiento',
      'nombre': 'Mantenimiento',
      'icon': Icons.build_circle_outlined,
      'color': Colors.orange.shade600,
      'descripcion': 'Mantenimiento de equipos'
    },
    {
      'id': 'almuerzo',
      'nombre': 'Almuerzo',
      'icon': Icons.restaurant_outlined,
      'color': Colors.green.shade600,
      'descripcion': 'Horario de comida'
    },
    {
      'id': 'reunion',
      'nombre': 'Reunión',
      'icon': Icons.meeting_room_outlined,
      'color': kAccentBlue,
      'descripcion': 'Reunión de equipo'
    },
    {
      'id': 'capacitacion',
      'nombre': 'Capacitación',
      'icon': Icons.school_outlined,
      'color': kBrandPurple,
      'descripcion': 'Entrenamiento'
    },
    {
      'id': 'personal',
      'nombre': 'Personal',
      'icon': Icons.person_outline,
      'color': Colors.grey.shade600,
      'descripcion': 'Tiempo personal'
    },
    {
      'id': 'emergencia',
      'nombre': 'Emergencia',
      'icon': Icons.emergency_outlined,
      'color': Colors.red.shade600,
      'descripcion': 'Bloqueo de emergencia'
    },
  ];

  final List<Map<String, dynamic>> _prioridades = [
    {
      'id': 'baja',
      'nombre': 'Baja',
      'color': Colors.green.shade600,
      'descripcion': 'Puede ser modificado'
    },
    {
      'id': 'media',
      'nombre': 'Media',
      'color': Colors.orange.shade600,
      'descripcion': 'Requiere aprobación'
    },
    {
      'id': 'alta',
      'nombre': 'Alta',
      'color': Colors.red.shade600,
      'descripcion': 'No se puede modificar'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeForm();
    _loadProfesionales(); // ✅ CARGAR PROFESIONALES DESDE FIRESTORE
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat(reverse: true);
  }

  void _initializeForm() {
    _fechaSeleccionada = widget.slotStart; // ✅ INICIALIZAR CON FECHA DEL SLOT
    _horaInicio =
        TimeOfDay(hour: widget.slotStart.hour, minute: widget.slotStart.minute);
    _nombreCtrl.text =
        _getTipoBloqueoData(_tipoBloqueoSeleccionado)['descripcion'];
    _profesionalSeleccionado = widget.profesionalId; // ✅ PRESELECCIONAR
  }

  // ✅ MÉTODO FUNCIONAL: CARGAR PROFESIONALES DESDE FIRESTORE
  Future<void> _loadProfesionales() async {
    try {
      debugPrint('🔄 Cargando profesionales desde Firestore...');

      // ✅ SOLUCIÓN TEMPORAL: Quitar orderBy para evitar necesidad de índice
      final snapshot = await FirebaseFirestore.instance
          .collection('profesionales')
          .where('estado', isEqualTo: true)
          .get();

      // ✅ ORDENAR EN MEMORIA EN LUGAR DE FIRESTORE
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        final nombreA = dataA['nombre']?.toString() ?? '';
        final nombreB = dataB['nombre']?.toString() ?? '';
        return nombreA.compareTo(nombreB);
      });

      debugPrint('✅ Profesionales cargados y ordenados: ${docs.length}');

      if (mounted) {
        setState(() {
          _profesionales = docs; // ✅ USAR DOCS ORDENADOS
          _loadingProfesionales = false;
        });

        // ✅ VALIDAR SI EL PROFESIONAL PRESELECCIONADO EXISTE
        final profesionalExiste =
            _profesionales.any((doc) => doc.id == widget.profesionalId);
        if (!profesionalExiste && _profesionales.isNotEmpty) {
          // Si el profesional preseleccionado no existe, seleccionar el primero
          _profesionalSeleccionado = _profesionales.first.id;
          debugPrint(
              '⚠️ Profesional preseleccionado no encontrado, usando: ${_profesionales.first.id}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error cargando profesionales: $e');
      if (mounted) {
        setState(() => _loadingProfesionales = false);

        // ✅ MOSTRAR ERROR AL USUARIO
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error cargando profesionales: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Map<String, dynamic> _getTipoBloqueoData(String tipoId) {
    return _tiposBloqueo.firstWhere(
      (tipo) => tipo['id'] == tipoId,
      orElse: () => _tiposBloqueo.first,
    );
  }

  Map<String, dynamic> _getPrioridadData(String prioridadId) {
    return _prioridades.firstWhere(
      (prioridad) => prioridad['id'] == prioridadId,
      orElse: () => _prioridades.first,
    );
  }

  // ✅ MÉTODO HELPER: OBTENER NOMBRE COMPLETO DEL PROFESIONAL
  String _getNombreCompleto(Map<String, dynamic> data) {
    final nombre = data['nombre']?.toString() ?? '';
    final apellidos = data['apellidos']?.toString() ?? '';
    return '$nombre $apellidos'.trim();
  }

  // ✅ MÉTODO HELPER: OBTENER INICIAL DEL PROFESIONAL
  String _getInicialProfesional(String nombreCompleto) {
    if (nombreCompleto.isEmpty) return '?';
    return nombreCompleto[0].toUpperCase();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_slideAnimation, _fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildDialogContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 700, // ✅ REDUCIDO DE 750 A 700
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: kBrandPurple.withValues(alpha: 0.1),
              blurRadius: 50,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(),
            _buildDialogBody(),
            _buildDialogActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    final tipoData = _getTipoBloqueoData(_tipoBloqueoSeleccionado);

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (tipoData['color'] as Color).withValues(alpha: 0.08),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.3 + (_shimmerAnimation.value * 0.3), 1.0],
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
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                tipoData['color'] as Color,
                                (tipoData['color'] as Color)
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (tipoData['color'] as Color)
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            tipoData['icon'] as IconData,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bloquear Horario',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: tipoData['color'] as Color,
                            fontFamily: kFontFamily,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configurar bloqueo profesional',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: kFontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDateTimeInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateTimeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAccentBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kAccentBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kAccentBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today, // ✅ CAMBIAR ÍCONO DE RELOJ A CALENDARIO
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                // ✅ FECHA CLICKEABLE PARA CAMBIAR - SIN TEXTO ADICIONAL
                InkWell(
              onTap: _seleccionarFecha,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: kAccentBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: kAccentBlue,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'es_MX')
                          .format(_fechaSeleccionada),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kAccentBlue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit,
                      color: kAccentBlue,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogBody() {
    return Expanded(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ SECCIÓN FUNCIONAL: SELECTOR DE PROFESIONAL
              _buildProfesionalSection(),
              const SizedBox(height: 24),
              _buildTipoBloqueoSection(),
              const SizedBox(height: 24),
              _buildHorarioSection(),
              const SizedBox(height: 24),
              _buildDetallesSection(),
              const SizedBox(height: 24),
              _buildConfiguracionSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ SECCIÓN COMPLETAMENTE FUNCIONAL: SELECTOR DE PROFESIONAL
  Widget _buildProfesionalSection() {
    return _buildSection(
      title: 'Profesional',
      icon: Icons.person_pin_outlined,
      child: _loadingProfesionales
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Cargando profesionales...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _profesionales.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No hay profesionales activos disponibles',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: _profesionalSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Seleccionar profesional *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: kBrandPurple, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.02),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12, // ✅ PADDING VERTICAL REDUCIDO
                    ),
                  ),
                  isDense: true, // ✅ MODO DENSO PARA REDUCIR ALTURA
                  items: _profesionales.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombreCompleto = _getNombreCompleto(data);
                    final inicial = _getInicialProfesional(nombreCompleto);
                    final servicios =
                        (data['servicios'] as List<dynamic>?)?.length ?? 0;

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Row(
                        children: [
                          // ✅ AVATAR CON INICIAL
                          CircleAvatar(
                            radius: 16, // ✅ REDUCIDO DE 18 A 16
                            backgroundColor:
                                kBrandPurple.withValues(alpha: 0.1),
                            backgroundImage: data['fotoUrl'] != null &&
                                    data['fotoUrl'].toString().isNotEmpty
                                ? NetworkImage(data['fotoUrl'])
                                : null,
                            child: data['fotoUrl'] == null ||
                                    data['fotoUrl'].toString().isEmpty
                                ? Text(
                                    inicial,
                                    style: const TextStyle(
                                      fontSize: 12, // ✅ REDUCIDO DE 14 A 12
                                      color: kBrandPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10), // ✅ REDUCIDO DE 12 A 10

                          // ✅ INFORMACIÓN DEL PROFESIONAL - SIMPLIFICADA
                          Expanded(
                            child: Text(
                              nombreCompleto.isEmpty
                                  ? 'Sin nombre'
                                  : nombreCompleto,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1, // ✅ FORZAR UNA SOLA LÍNEA
                            ),
                          ),

                          // ✅ INDICADOR DE ESTADO - MÁS PEQUEÑO
                          Container(
                            width: 6, // ✅ REDUCIDO DE 8 A 6
                            height: 6, // ✅ REDUCIDO DE 8 A 6
                            decoration: BoxDecoration(
                              color: data['estado'] == true
                                  ? kAccentGreen
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _profesionalSeleccionado = value);
                    HapticFeedback.selectionClick();
                    debugPrint('✅ Profesional seleccionado: $value');
                  },
                  validator: (value) =>
                      value == null ? 'Selecciona un profesional' : null,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
    );
  }

  Widget _buildTipoBloqueoSection() {
    return _buildSection(
      title: 'Tipo de Bloqueo',
      icon: Icons.category_outlined,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _tiposBloqueo.length,
            itemBuilder: (context, index) {
              final tipo = _tiposBloqueo[index];
              final isSelected = _tipoBloqueoSeleccionado == tipo['id'];

              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _tipoBloqueoSeleccionado = tipo['id'] as String;
                      _nombreCtrl.text = tipo['descripcion'] as String;
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (tipo['color'] as Color).withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? tipo['color'] as Color
                            : Colors.grey.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tipo['icon'] as IconData,
                          color: isSelected
                              ? tipo['color'] as Color
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tipo['nombre'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? tipo['color'] as Color
                                  : Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorarioSection() {
    return _buildSection(
      title: 'Configuración de Horario',
      icon: Icons.schedule_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _seleccionarHora(true),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kAccentGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kAccentGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: kAccentGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Hora Inicio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kAccentGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _horaInicio.format(context),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kAccentGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () => _seleccionarHora(false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stop,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hora Fin',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _horaFin?.format(context) ?? 'Seleccionar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_horaFin != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBrandPurple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kBrandPurple.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: kBrandPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Duración: ${_calcularDuracion()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kBrandPurple,
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

  Widget _buildDetallesSection() {
    return _buildSection(
      title: 'Detalles del Bloqueo',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreCtrl,
            decoration: InputDecoration(
              labelText: 'Motivo del bloqueo *',
              hintText: 'Describe el motivo específico...',
              prefixIcon: const Icon(Icons.edit_note),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBrandPurple, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.02),
            ),
            maxLines: 2,
            validator: (value) =>
                value?.trim().isEmpty == true ? 'El motivo es requerido' : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: _prioridadSeleccionada,
              decoration: InputDecoration(
                labelText: 'Prioridad',
                prefixIcon: const Icon(Icons.priority_high),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBrandPurple, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.02),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12, // ✅ PADDING VERTICAL REDUCIDO
                ),
              ),
              isDense: true, // ✅ MODO DENSO PARA REDUCIR ALTURA
              items: _prioridades.map((prioridad) {
                return DropdownMenuItem<String>(
                  value: prioridad['id'] as String,
                  child: Row(
                    children: [
                      Container(
                        width: 10, // ✅ REDUCIDO DE 12 A 10
                        height: 10, // ✅ REDUCIDO DE 12 A 10
                        decoration: BoxDecoration(
                          color: prioridad['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10), // ✅ REDUCIDO DE 12 A 10
                      Expanded(
                        child: Text(
                          prioridad['nombre'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // ✅ FORZAR UNA SOLA LÍNEA
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _prioridadSeleccionada = value!),
              isExpanded: true,
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguracionSection() {
    return _buildSection(
      title: 'Configuración Adicional',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          _buildConfigOption(
            title: 'Notificar al equipo',
            subtitle: 'Enviar notificación sobre este bloqueo',
            value: _notificarEquipo,
            onChanged: (value) => setState(() => _notificarEquipo = value),
            icon: Icons.notifications_outlined,
            color: kAccentBlue,
          ),
          const SizedBox(height: 12),
          _buildConfigOption(
            title: 'Mostrar en calendario',
            subtitle: 'Visible para todos los usuarios',
            value: _mostrarEnCalendario,
            onChanged: (value) => setState(() => _mostrarEnCalendario = value),
            icon: Icons.calendar_view_day_outlined,
            color: kAccentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value
            ? color.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value ? color : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: value ? color : Colors.grey.shade700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withValues(alpha: 0.3),
          ),
        ],
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
        color: Colors.grey.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kBrandPurple.withValues(alpha: 0.03),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
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
    final tipoData = _getTipoBloqueoData(_tipoBloqueoSeleccionado);
    final prioridadData = _getPrioridadData(_prioridadSeleccionada);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ RESUMEN RÁPIDO
          if (_horaFin != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (tipoData['color'] as Color).withValues(alpha: 0.05),
                    (prioridadData['color'] as Color).withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (tipoData['color'] as Color).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tipoData['icon'] as IconData,
                    color: tipoData['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${tipoData['nombre']} • ${_calcularDuracion()}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tipoData['color'] as Color,
                          ),
                        ),
                        Text(
                          '${_horaInicio.format(context)} - ${_horaFin!.format(context)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: prioridadData['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prioridadData['nombre'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ✅ BOTONES DE ACCIÓN
          Row(
            children: [
              // ✅ INFORMACIÓN DE VALIDACIÓN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_horaFin != null) ...[
                      Text(
                        'Duración: ${_calcularDuracion()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Prioridad: ${prioridadData['nombre']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: prioridadData['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Selecciona la hora de fin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // ✅ BOTÓN CANCELAR
              TextButton.icon(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Cancelar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),

              const SizedBox(width: 12),

              // ✅ BOTÓN GUARDAR
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _guardarBloqueo,
                icon: _isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isLoading ? Colors.white70 : Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        tipoData['icon'] as IconData,
                        size: 18,
                      ),
                label: Text(_isLoading ? 'Guardando...' : 'Bloquear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tipoData['color'] as Color,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor:
                      (tipoData['color'] as Color).withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🎯 MÉTODOS DE LÓGICA DE NEGOCIO
  // ========================================================================

  // ✅ NUEVO MÉTODO: SELECTOR DE FECHA
  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now()
          .subtract(const Duration(days: 1)), // ✅ PERMITIR DESDE AYER
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // ✅ HASTA 1 AÑO ADELANTE
      locale: const Locale('es', 'MX'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kBrandPurple,
                  onSurface: Colors.black87,
                ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: kBrandPurple,
              headerForegroundColor: Colors.white,
              dayStyle: const TextStyle(fontSize: 14),
              yearStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
      HapticFeedback.selectionClick();
      debugPrint('📅 Fecha seleccionada: $_fechaSeleccionada');
    }
  }

  Future<void> _seleccionarHora(bool esHoraInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: esHoraInicio ? _horaInicio : (_horaFin ?? _horaInicio),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (esHoraInicio) {
          _horaInicio = picked;
          // Si la hora de fin ya está seleccionada y es anterior a la nueva hora de inicio,
          // ajustar la hora de fin
          if (_horaFin != null && _compareTimeOfDay(_horaFin!, picked) <= 0) {
            _horaFin = TimeOfDay(
              hour: (picked.hour + 1) % 24,
              minute: picked.minute,
            );
          }
        } else {
          // Validar que la hora de fin sea posterior a la hora de inicio
          if (_compareTimeOfDay(picked, _horaInicio) > 0) {
            _horaFin = picked;
          } else {
            // Mostrar error si la hora de fin es anterior o igual a la hora de inicio
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'La hora de fin debe ser posterior a la hora de inicio',
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            return;
          }
        }
      });

      HapticFeedback.selectionClick();
    }
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) {
      return a.hour.compareTo(b.hour);
    }
    return a.minute.compareTo(b.minute);
  }

  String _calcularDuracion() {
    if (_horaFin == null) return '';

    final inicioMinutos = _horaInicio.hour * 60 + _horaInicio.minute;
    final finMinutos = _horaFin!.hour * 60 + _horaFin!.minute;
    final duracionMinutos = finMinutos - inicioMinutos;

    if (duracionMinutos <= 0) return '';

    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;

    if (horas == 0) {
      return '${minutos}min';
    } else if (minutos == 0) {
      return '${horas}h';
    } else {
      return '${horas}h ${minutos}min';
    }
  }

  Future<void> _guardarBloqueo() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (_horaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona la hora de fin del bloqueo'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (_profesionalSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un profesional'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ USAR EL PROFESIONAL SELECCIONADO Y FECHA SELECCIONADA
      debugPrint(
          '💾 Guardando bloqueo para profesional: $_profesionalSeleccionado');
      debugPrint('📅 Fecha seleccionada: $_fechaSeleccionada');

      await widget.onSaveBlock(
        profesionalId: _profesionalSeleccionado!,
        day:
            _fechaSeleccionada, // ✅ USAR FECHA SELECCIONADA EN LUGAR DE widget.slotStart
        startHour: _horaInicio.hour,
        startMin: _horaInicio.minute,
        endHour: _horaFin!.hour,
        endMin: _horaFin!.minute,
        blockName: _nombreCtrl.text.trim(),
      );

      debugPrint('✅ Bloqueo guardado exitosamente');

      // ✅ EFECTOS DE ÉXITO
      HapticFeedback.heavyImpact();

      if (widget.onAfterSave != null) {
        widget.onAfterSave!();
      }

      if (mounted) {
        final tipoData = _getTipoBloqueoData(_tipoBloqueoSeleccionado);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  tipoData['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bloqueo creado exitosamente',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${tipoData['nombre']} • ${_calcularDuracion()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: tipoData['color'] as Color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Error guardando bloqueo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el bloqueo: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
