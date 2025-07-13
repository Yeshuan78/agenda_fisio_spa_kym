// [Archivo: lib/widgets/encuestas/micrositio_preview_widget.dart]
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class MicrositioPreviewWidget extends StatefulWidget {
  final String titulo;
  final String descripcion;
  final List<Map<String, dynamic>> preguntas;

  const MicrositioPreviewWidget({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.preguntas,
  });

  @override
  State<MicrositioPreviewWidget> createState() =>
      _MicrositioPreviewWidgetState();
}

class _MicrositioPreviewWidgetState extends State<MicrositioPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isMobileView = false;
  Map<int, dynamic> _respuestas = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MicrositioPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preguntas.length != widget.preguntas.length ||
        oldWidget.titulo != widget.titulo ||
        oldWidget.descripcion != widget.descripcion) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Header del preview
          _buildPreviewHeader(),

          // Contenido del micrositio
          Expanded(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                    child: _buildMicrositioContent(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.1),
            kAccentBlue.withValues(alpha: 0.1)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(color: kBorderColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: kBrandPurple, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Preview en Tiempo Real',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // Toggle vista móvil/desktop
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: kBorderColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggle(Icons.computer, !_isMobileView, () {
                      setState(() => _isMobileView = false);
                    }),
                    _buildViewToggle(Icons.phone_android, _isMobileView, () {
                      setState(() => _isMobileView = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Así se verá tu encuesta en el micrositio',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? kBrandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMicrositioContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: _isMobileView ? 320 : 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorderColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del micrositio
              _buildMicrositioHeader(),

              // Formulario
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo número de empleado
                    _buildEmpleadoField(),

                    const SizedBox(height: 24),

                    // Preguntas
                    ...widget.preguntas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pregunta = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildPreguntaWidget(pregunta, index),
                      );
                    }),

                    // Campo comentario
                    _buildComentarioField(),

                    const SizedBox(height: 32),

                    // Botón enviar
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicrositioHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandPurple, kAccentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.spa,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            widget.titulo.isNotEmpty ? widget.titulo : 'Título de la encuesta',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            widget.descripcion.isNotEmpty
                ? widget.descripcion
                : 'Descripción de la encuesta',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpleadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número de empleado (obligatorio)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ej. 12456',
            prefixIcon: Icon(Icons.badge_outlined, color: kBrandPurple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: kBorderColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBrandPurple, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: TextInputType.number,
          enabled: false, // Solo preview
        ),
      ],
    );
  }

  Widget _buildPreguntaWidget(Map<String, dynamic> pregunta, int index) {
    final tipo = pregunta['tipo'] ?? 'estrellas';
    final texto = pregunta['texto'] ?? '';
    final esRequerida = pregunta['requerida'] ?? false;
    final opciones = List<String>.from(pregunta['opciones'] ?? []);

    if (texto.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(
              'Pregunta ${index + 1}: Escribe el texto de la pregunta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto de la pregunta
        Row(
          children: [
            Text(
              '${index + 1}. ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kBrandPurple,
              ),
            ),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),

        if (esRequerida)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '*Obligatoria',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Widget según el tipo
        _buildTipoWidget(tipo, opciones, index),
      ],
    );
  }

  Widget _buildTipoWidget(String tipo, List<String> opciones, int index) {
    switch (tipo) {
      case 'estrellas':
        return _buildEstrellasWidget(index);

      case 'escala_1_10':
        return _buildEscalaWidget(index);

      case 'multiple_choice':
        return _buildMultipleChoiceWidget(opciones, index);

      case 'si_no':
        return _buildSiNoWidget(index);

      case 'texto_libre':
        return _buildTextoLibreWidget(index);

      default:
        return Container();
    }
  }

  Widget _buildEstrellasWidget(int preguntaIndex) {
    final respuesta = _respuestas[preguntaIndex] as int?;

    return Row(
      children: List.generate(5, (index) {
        final isSelected = respuesta != null && index < respuesta;
        return GestureDetector(
          onTap: () {
            setState(() {
              _respuestas[preguntaIndex] = index + 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected ? Colors.amber : Colors.grey.shade400,
              size: _isMobileView ? 32 : 36,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEscalaWidget(int preguntaIndex) {
    final respuesta = _respuestas[preguntaIndex] as int?;

    return Wrap(
      spacing: _isMobileView ? 6 : 8,
      runSpacing: 8,
      children: List.generate(10, (index) {
        final valor = index + 1;
        final isSelected = respuesta == valor;

        return GestureDetector(
          onTap: () {
            setState(() {
              _respuestas[preguntaIndex] = valor;
            });
          },
          child: Container(
            width: _isMobileView ? 28 : 36,
            height: _isMobileView ? 28 : 36,
            decoration: BoxDecoration(
              color: isSelected ? kBrandPurple : Colors.white,
              border: Border.all(
                color: isSelected
                    ? kBrandPurple
                    : kBorderColor.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$valor',
                style: TextStyle(
                  fontSize: _isMobileView ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : kBrandPurple,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMultipleChoiceWidget(List<String> opciones, int preguntaIndex) {
    final respuesta = _respuestas[preguntaIndex] as String?;

    return Column(
      children: opciones.map((opcion) {
        final isSelected = respuesta == opcion;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _respuestas[preguntaIndex] = opcion;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? kBrandPurple.withValues(alpha: 0.1)
                    : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? kBrandPurple
                      : kBorderColor.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? kBrandPurple : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      opcion,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected ? kBrandPurple : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSiNoWidget(int preguntaIndex) {
    final respuesta = _respuestas[preguntaIndex] as String?;

    return Row(
      children: [
        // Opción Sí
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _respuestas[preguntaIndex] = 'Sí';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: respuesta == 'Sí' ? kAccentGreen : Colors.white,
                border: Border.all(
                  color: respuesta == 'Sí'
                      ? kAccentGreen
                      : kBorderColor.withValues(alpha: 0.3),
                  width: respuesta == 'Sí' ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: respuesta == 'Sí' ? Colors.white : kAccentGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sí',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: respuesta == 'Sí' ? Colors.white : kAccentGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Opción No
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _respuestas[preguntaIndex] = 'No';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: respuesta == 'No' ? Colors.red.shade400 : Colors.white,
                border: Border.all(
                  color: respuesta == 'No'
                      ? Colors.red.shade400
                      : kBorderColor.withValues(alpha: 0.3),
                  width: respuesta == 'No' ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    color:
                        respuesta == 'No' ? Colors.white : Colors.red.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: respuesta == 'No'
                          ? Colors.white
                          : Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextoLibreWidget(int preguntaIndex) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Escribe tu respuesta aquí...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kBorderColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kBrandPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
      enabled: false, // Solo preview
      onChanged: (value) {
        _respuestas[preguntaIndex] = value;
      },
    );
  }

  Widget _buildComentarioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentario adicional (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Comparte cualquier comentario adicional...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: kBorderColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: kBrandPurple, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
          enabled: false, // Solo preview
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandPurple, kAccentBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Solo preview - mostrar mensaje
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    '✨ Esto es solo un preview - la encuesta se ve increíble!'),
                backgroundColor: kBrandPurple,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: const Center(
            child: Text(
              'Enviar Encuesta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
