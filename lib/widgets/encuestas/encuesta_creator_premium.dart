// [Archivo: lib/widgets/encuestas/encuesta_creator_premium.dart]
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/theme.dart';
import 'pregunta_editor_premium.dart';
import 'micrositio_preview_widget.dart';
import 'encuesta_templates_selector.dart';

class EncuestaCreatorPremium extends StatefulWidget {
  const EncuestaCreatorPremium({super.key});

  @override
  State<EncuestaCreatorPremium> createState() => _EncuestaCreatorPremiumState();
}

class _EncuestaCreatorPremiumState extends State<EncuestaCreatorPremium>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _preguntas = [];
  String? _docId;
  bool _isLoading = true;
  bool _isSaving = false;
  String _encuestaTitulo = "Encuesta de Satisfacción";
  String _encuestaDescripcion = "Ayúdanos a mejorar nuestros servicios";

  // Controllers para animaciones
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _fabController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _cargarPreguntas();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOutCubic,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fabController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _cargarPreguntas() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('encuestas')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _docId = doc.id;
        final data = doc.data();

        if (data.containsKey('preguntas')) {
          setState(() {
            _preguntas = List<Map<String, dynamic>>.from(data['preguntas']);
            _encuestaTitulo = data['titulo'] ?? _encuestaTitulo;
            _encuestaDescripcion = data['descripcion'] ?? _encuestaDescripcion;
          });
        } else {
          _preguntas = _crearPreguntasPorDefecto();
          await _guardar();
        }
      } else {
        final newDoc =
            await FirebaseFirestore.instance.collection('encuestas').add({
          'titulo': _encuestaTitulo,
          'descripcion': _encuestaDescripcion,
          'preguntas': _crearPreguntasPorDefecto(),
          'fechaCreacion': FieldValue.serverTimestamp(),
          'activa': true,
        });
        _docId = newDoc.id;
        _preguntas = _crearPreguntasPorDefecto();
      }
    } catch (e) {
      _showSnackBar('❌ Error cargando encuesta: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _crearPreguntasPorDefecto() {
    return [
      {
        "texto": "¿Cómo calificarías la atención del profesional?",
        "tipo": "estrellas",
        "requerida": true,
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Qué tan cómodo(a) te sentiste durante el servicio?",
        "tipo": "estrellas",
        "requerida": true,
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Qué opinas de la puntualidad en tu cita?",
        "tipo": "estrellas",
        "requerida": true,
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Qué tan útil consideras este servicio para tu bienestar?",
        "tipo": "estrellas",
        "requerida": true,
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Cómo calificarías la experiencia general del servicio?",
        "tipo": "estrellas",
        "requerida": true,
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      }
    ];
  }

  Future<void> _guardar() async {
    if (_docId == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('encuestas').doc(_docId).set({
        'titulo': _encuestaTitulo,
        'descripcion': _encuestaDescripcion,
        'preguntas': _preguntas,
        'fechaActualizacion': FieldValue.serverTimestamp(),
        'activa': true,
      });

      _showSnackBar('✅ Encuesta guardada correctamente');
    } catch (e) {
      _showSnackBar('❌ Error guardando: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : kBrandPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _agregarPregunta() {
    setState(() {
      _preguntas.add({
        'texto': '',
        'tipo': 'estrellas',
        'requerida': false,
        'opciones': ['⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐']
      });
    });

    // Animar el scroll hacia abajo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _eliminarPregunta(int index) {
    setState(() {
      _preguntas.removeAt(index);
    });
  }

  void _aplicarTemplate(List<Map<String, dynamic>> templatePreguntas) {
    setState(() {
      _preguntas = templatePreguntas;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: kBrandPurple),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Panel Principal - Editor
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // Header Premium con Gradiente
                _buildPremiumHeader(),

                // Contenido Principal
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Templates Selector
                          AnimatedBuilder(
                            animation: _cardsAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset:
                                    Offset(0, 50 * (1 - _cardsAnimation.value)),
                                child: Opacity(
                                  opacity: _cardsAnimation.value,
                                  child: EncuestaTemplatesSelector(
                                    onTemplateSelected: _aplicarTemplate,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Configuración de Encuesta
                          _buildEncuestaConfig(),

                          const SizedBox(height: 32),

                          // Lista de Preguntas
                          ...List.generate(_preguntas.length, (index) {
                            return AnimatedBuilder(
                              animation: _cardsAnimation,
                              builder: (context, child) {
                                final delay = index * 0.1;
                                final animationValue = Curves.easeOutCubic
                                    .transform((((_cardsAnimation.value - delay)
                                                .clamp(0.0, 1.0)) /
                                            (1.0 - delay))
                                        .clamp(0.0, 1.0));

                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - animationValue)),
                                  child: Opacity(
                                    opacity: animationValue,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: PreguntaEditorPremium(
                                        pregunta: _preguntas[index],
                                        index: index,
                                        onPreguntaChanged: (updatedPregunta) {
                                          setState(() {
                                            _preguntas[index] = updatedPregunta;
                                          });
                                        },
                                        onEliminar: () =>
                                            _eliminarPregunta(index),
                                        canDelete: _preguntas.length > 1,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel Lateral - Preview
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  left: BorderSide(color: kBorderColor.withValues(alpha: 0.03)),
                ),
              ),
              child: MicrositioPreviewWidget(
                titulo: _encuestaTitulo,
                descripcion: _encuestaDescripcion,
                preguntas: _preguntas,
              ),
            ),
          ),
        ],
      ),

      // FAB Premium
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Transform.rotate(
              angle: (1 - _fabAnimation.value) * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [kBrandPurple, kAccentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kBrandPurple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isSaving ? null : _guardar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSaving)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            const Icon(
                              Icons.save_rounded,
                              color: Colors.white,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            _isSaving ? 'Guardando...' : 'Guardar Encuesta',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

      // Segundo FAB - Agregar Pregunta
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 80, bottom: 16),
              child: FloatingActionButton(
                heroTag: "add_question",
                onPressed: _agregarPregunta,
                backgroundColor: kAccentGreen,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kBrandPurple,
                    kAccentBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: kSombraSuperior,
              ),
              child: Stack(
                children: [
                  // Patrón decorativo
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.01),
                      ),
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Icono principal
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.quiz_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Títulos
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Creator Studio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Diseña encuestas profesionales con preview en tiempo real',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.09),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Estadísticas rápidas
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.015),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_preguntas.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Preguntas',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEncuestaConfig() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.005),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined, color: kBrandPurple),
              const SizedBox(width: 12),
              const Text(
                'Configuración de Encuesta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: TextEditingController(text: _encuestaTitulo)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: _encuestaTitulo.length),
              ),
            decoration: const InputDecoration(
              labelText: 'Título de la encuesta',
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (value) {
              setState(() {
                _encuestaTitulo = value;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _encuestaDescripcion)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: _encuestaDescripcion.length),
              ),
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                _encuestaDescripcion = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
