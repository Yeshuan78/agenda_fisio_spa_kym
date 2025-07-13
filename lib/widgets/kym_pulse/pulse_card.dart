// IMPORTANTE: Este archivo debe REEMPLAZAR completamente el pulse_card.dart original
// Ubicación: /lib/widgets/kym_pulse/pulse_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/evento_model.dart';
import '../../../models/servicio_realizado_model.dart';
import '../../../theme/theme.dart';
import '../../../services/evento_service.dart';
import 'pulse_card_header.dart';
import 'pulse_card_profesionales.dart';
import 'pulse_card_encuestas.dart';
import 'pulse_card_acciones.dart';
import 'pulse_card_estado_selector.dart';

class PulseCard extends StatefulWidget {
  final EventoModel evento;

  const PulseCard({super.key, required this.evento});

  @override
  State<PulseCard> createState() => _PulseCardState();
}

class _PulseCardState extends State<PulseCard> with TickerProviderStateMixin {
  // ✅ LÓGICA ORIGINAL MANTENIDA
  Map<String, String> _servicios = {};
  Map<String, String> _profesionales = {};

  // ✅ ANIMACIONES MEJORADAS
  late AnimationController _liveController;
  late AnimationController _stateController;
  late AnimationController _refreshController;

  late Animation<double> _liveAnimation;
  late Animation<double> _stateAnimation;
  late Animation<double> _refreshAnimation;

  bool _showStateSelector = false;
  bool _isRefreshing = false;

  // ✅ SISTEMA DE ESTADOS IDÉNTICO A EVENTO CARD
  Map<String, Map<String, dynamic>> get _estadosConfig => {
        'activo': {
          'color': const Color(0xFF4CAF50), // Verde
          'icon': Icons.play_circle_filled,
          'label': 'Activo',
          'description': 'Evento en curso',
        },
        'completado': {
          'color': kBrandPurple, // Morado
          'icon': Icons.check_circle,
          'label': 'Completado',
          'description': 'Evento finalizado',
        },
        'programado': {
          'color': const Color(0xFF2196F3), // Azul
          'icon': Icons.schedule,
          'label': 'Programado',
          'description': 'Evento planificado',
        },
        'cancelado': {
          'color': const Color(0xFFF44336), // Rojo
          'icon': Icons.cancel,
          'label': 'Cancelado',
          'description': 'Evento cancelado',
        },
        'reagendado': {
          'color': const Color(0xFFFF9800), // Naranja
          'icon': Icons.update,
          'label': 'Reagendado',
          'description': 'Evento reprogramado',
        },
        'pausado': {
          'color': const Color(0xFFFFEB3B), // Amarillo
          'icon': Icons.pause_circle,
          'label': 'Pausado',
          'description': 'Evento suspendido',
        },
      };

  Color _getStatusColor() =>
      _estadosConfig[widget.evento.estado]?['color'] ?? Colors.grey;

  @override
  void initState() {
    super.initState();
    _cargarNombres();
    _initializeAnimations();
  }

  Future<void> _cargarNombres() async {
    final serviciosIds = widget.evento.serviciosAsignados
        .map((e) => e['servicioId'] ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final profesionalesIds = widget.evento.serviciosAsignados
        .map((e) => e['profesionalId'] ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (serviciosIds.isNotEmpty) {
      final snapServicios = await FirebaseFirestore.instance
          .collection('services')
          .where(FieldPath.documentId, whereIn: serviciosIds)
          .get();

      if (mounted) {
        setState(() {
          _servicios = {
            for (var doc in snapServicios.docs)
              doc.id: doc.data()['name']?.toString() ?? doc.id
          };
        });
      }
    }

    if (profesionalesIds.isNotEmpty) {
      final snapProfesionales = await FirebaseFirestore.instance
          .collection('profesionales')
          .where(FieldPath.documentId, whereIn: profesionalesIds)
          .get();

      if (mounted) {
        setState(() {
          _profesionales = {
            for (var doc in snapProfesionales.docs)
              doc.id: doc.data()['nombre']?.toString() ?? doc.id
          };
        });
      }
    }
  }

  void _initializeAnimations() {
    _liveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _stateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _liveAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _liveController, curve: Curves.easeInOut),
    );

    _stateAnimation = CurvedAnimation(
      parent: _stateController,
      curve: Curves.easeOutCubic,
    );

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeOutCubic),
    );

    // Solo anima si el evento está activo
    if (widget.evento.estado.toLowerCase() == 'activo') {
      _liveController.repeat(reverse: true);
    }
  }

  // ✅ CAMBIO DE ESTADO PROFESIONAL
  Future<void> _cambiarEstado(String nuevoEstado) async {
    try {
      final eventoActualizado = EventoModel(
        id: widget.evento.id,
        eventoId: widget.evento.eventoId,
        nombre: widget.evento.nombre,
        empresa: widget.evento.empresa,
        empresaId: widget.evento.empresaId,
        ubicacion: widget.evento.ubicacion,
        fecha: widget.evento.fecha,
        estado: nuevoEstado,
        observaciones: widget.evento.observaciones,
        serviciosAsignados: widget.evento.serviciosAsignados,
        fechaCreacion: widget.evento.fechaCreacion,
      );

      await EventoService().updateEvento(eventoActualizado);

      setState(() {
        _showStateSelector = false;
      });
      _stateController.reverse();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Estado cambiado a: ${_estadosConfig[nuevoEstado]?['label']}'),
            backgroundColor: _estadosConfig[nuevoEstado]?['color'],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error actualizando estado: $e'),
            backgroundColor: const Color(0xFFF44336),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ ACTUALIZACIÓN MANUAL PROFESIONAL
  Future<void> _manualRefresh() async {
    setState(() => _isRefreshing = true);
    _refreshController.forward();

    // Simular carga y recargar nombres
    await Future.delayed(const Duration(milliseconds: 500));
    await _cargarNombres();

    setState(() => _isRefreshing = false);
    _refreshController.reverse();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('✅ Datos actualizados',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _liveController.dispose();
    _stateController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrosRef = FirebaseFirestore.instance
        .collection('eventos')
        .doc(widget.evento.id)
        .collection('registros');

    return StreamBuilder<QuerySnapshot>(
      stream: registrosRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final registros = snapshot.data!.docs
            .map((doc) => ServicioRealizadoModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        // ✅ CÁLCULOS MEJORADOS MANTENIDOS
        final Map<String, int> serviciosCount = {};
        final List<String> comentariosPlanos = [];
        final Map<String, List<double>> preguntas = {
          'preg0': [],
          'preg1': [],
          'preg2': [],
          'preg3': [],
          'preg4': [],
        };

        for (var r in registros) {
          serviciosCount[r.servicioId] =
              (serviciosCount[r.servicioId] ?? 0) + 1;

          if (r.encuesta != null) {
            for (var key in r.encuesta!.keys) {
              if (key.startsWith('preg') && key != 'comentario') {
                final valor = r.encuesta![key];
                if (valor != null) {
                  double nota = 0.0;
                  if (valor is String) {
                    nota = _parseEstrellas(valor);
                  } else if (valor is int) {
                    nota = valor.toDouble();
                  } else if (valor is double) {
                    nota = valor;
                  }

                  if (nota > 0) {
                    if (!preguntas.containsKey(key)) {
                      preguntas[key] = [];
                    }
                    preguntas[key]!.add(nota);
                  }
                }
              }
            }

            final comentario = r.encuesta?['comentario'];
            if (comentario != null && comentario.toString().trim().isNotEmpty) {
              comentariosPlanos.add(comentario.toString().trim());
            }
          }
        }

        final totalRegistros = registros.length;
        int totalEncuestas = 0;
        double promedioGlobal = 0.0;

        for (var entry in preguntas.entries) {
          if (entry.value.isNotEmpty) {
            totalEncuestas = entry.value.length;
            break;
          }
        }

        if (totalEncuestas > 0) {
          double sumaPromedios = 0.0;
          int preguntasConRespuestas = 0;

          for (var entry in preguntas.entries) {
            if (entry.value.isNotEmpty) {
              final promedioPregunta =
                  entry.value.reduce((a, b) => a + b) / entry.value.length;
              sumaPromedios += promedioPregunta;
              preguntasConRespuestas++;
            }
          }

          if (preguntasConRespuestas > 0) {
            promedioGlobal = sumaPromedios / preguntasConRespuestas;
          }
        }

        final mostrarComentarios = comentariosPlanos.take(5).toList();
        final restantes = comentariosPlanos.length - mostrarComentarios.length;
        final evento = widget.evento;
        final isEventoActivo =
            evento.estado.toLowerCase() == 'activo' && totalRegistros > 0;

        // ✅ CARD PREMIUM CON GLASSMORPHISM ELEGANTE
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Stack(
              children: [
                Container(
                  margin:
                      const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    // ✅ GLASSMORPHISM ELEGANTE - DIFERENTE A EVENTO CARD
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.8),
                        _getStatusColor().withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor().withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      // ✅ SOMBRA PRINCIPAL ELEGANTE
                      BoxShadow(
                        color: _getStatusColor().withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      // ✅ SOMBRA INTERNA GLASSMORPHISM
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: -5,
                        offset: const Offset(0, -5),
                      ),
                      // ✅ SOMBRA DE PROFUNDIDAD
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // ✅ HEADER COMPONENT
                        PulseCardHeader(
                          evento: evento,
                          totalRegistros: totalRegistros,
                          isEventoActivo: isEventoActivo,
                          liveAnimation: _liveAnimation,
                          estadosConfig: _estadosConfig,
                          onEstadoTap: () {
                            setState(() {
                              _showStateSelector = !_showStateSelector;
                            });
                            if (_showStateSelector) {
                              _stateController.forward();
                            } else {
                              _stateController.reverse();
                            }
                          },
                        ),

                        // ✅ MAIN CONTENT CON WIDGETS EXTERNOS
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ COLUMNA 1: Profesionales COMPONENT - FLEX IGUAL
                              Expanded(
                                flex: 1, // ✅ CAMBIO: flex igual para todas
                                child: PulseCardProfesionales(
                                  evento: evento,
                                  registros: registros,
                                  servicios: _servicios,
                                  profesionales: _profesionales,
                                ),
                              ),

                              const SizedBox(
                                  width: 16), // ✅ CAMBIO: menor separación

                              // ✅ COLUMNA 2: Encuestas COMPONENT - FLEX IGUAL
                              Expanded(
                                flex: 1, // ✅ CAMBIO: flex igual para todas
                                child: PulseCardEncuestas(
                                  totalEncuestas: totalEncuestas,
                                  promedioGlobal: promedioGlobal,
                                  mostrarComentarios: mostrarComentarios,
                                  restantes: restantes,
                                  comentariosPlanos: comentariosPlanos,
                                  totalRegistros: totalRegistros,
                                ),
                              ),

                              const SizedBox(
                                  width: 16), // ✅ CAMBIO: menor separación

                              // ✅ COLUMNA 3: Acciones COMPONENT - FLEX IGUAL
                              Expanded(
                                flex: 1, // ✅ CAMBIO: flex igual para todas
                                child: PulseCardAcciones(
                                  evento: evento,
                                  serviciosCount: serviciosCount,
                                  servicios: _servicios,
                                  isRefreshing: _isRefreshing,
                                  refreshAnimation: _refreshAnimation,
                                  onRefresh: _manualRefresh,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ SELECTOR DE ESTADOS FLOTANTE COMPONENT
                if (_showStateSelector)
                  AnimatedBuilder(
                    animation: _stateAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 20,
                        right: 20,
                        child: Transform.scale(
                          scale: _stateAnimation.value,
                          child: Opacity(
                            opacity: _stateAnimation.value,
                            child: PulseCardEstadoSelector(
                              evento: evento,
                              estadosConfig: _estadosConfig,
                              onEstadoChanged: _cambiarEstado,
                              onClose: () {
                                setState(() {
                                  _showStateSelector = false;
                                });
                                _stateController.reverse();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ FUNCIÓN PARA PARSING DE ESTRELLAS
  double _parseEstrellas(String estrella) {
    final trimmed = estrella.trim();

    switch (trimmed) {
      case '⭐':
      case '1':
        return 1.0;
      case '⭐⭐':
      case '2':
        return 2.0;
      case '⭐⭐⭐':
      case '3':
        return 3.0;
      case '⭐⭐⭐⭐':
      case '4':
        return 4.0;
      case '⭐⭐⭐⭐⭐':
      case '5':
        return 5.0;
      default:
        final numero = double.tryParse(trimmed);
        if (numero != null && numero >= 1 && numero <= 5) {
          return numero;
        }
        return 0.0;
    }
  }
}
