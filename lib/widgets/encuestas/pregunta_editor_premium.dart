// [Archivo: lib/widgets/encuestas/pregunta_editor_premium.dart]
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class PreguntaEditorPremium extends StatefulWidget {
  final Map<String, dynamic> pregunta;
  final int index;
  final Function(Map<String, dynamic>) onPreguntaChanged;
  final VoidCallback onEliminar;
  final bool canDelete;

  const PreguntaEditorPremium({
    super.key,
    required this.pregunta,
    required this.index,
    required this.onPreguntaChanged,
    required this.onEliminar,
    required this.canDelete,
  });

  @override
  State<PreguntaEditorPremium> createState() => _PreguntaEditorPremiumState();
}

class _PreguntaEditorPremiumState extends State<PreguntaEditorPremium>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _updatePregunta(String key, dynamic value) {
    final updatedPregunta = Map<String, dynamic>.from(widget.pregunta);
    updatedPregunta[key] = value;
    widget.onPreguntaChanged(updatedPregunta);
  }

  String get _tipoPregunta => widget.pregunta['tipo'] ?? 'estrellas';
  bool get _esRequerida => widget.pregunta['requerida'] ?? false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? kBrandPurple.withValues(alpha: 0.3)
                      : kBorderColor.withValues(alpha: 0.2),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kBrandPurple.withValues(
                        alpha: _isHovered ? 0.15 : 0.08),
                    blurRadius: _elevationAnimation.value * 1.5,
                    spreadRadius: _elevationAnimation.value * 0.1,
                    offset: Offset(0, _elevationAnimation.value * 0.5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header de la pregunta
                  _buildPreguntaHeader(),

                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo de texto de la pregunta
                        _buildPreguntaTextField(),

                        const SizedBox(height: 16),

                        // Configuración de tipo y opciones
                        _buildTipoSelector(),

                        const SizedBox(height: 16),

                        // Editor de opciones (si aplica)
                        if (_tipoPregunta == 'multiple_choice' ||
                            _tipoPregunta == 'escala_personalizada')
                          _buildOpcionesEditor(),

                        // Preview de la pregunta
                        const SizedBox(height: 20),
                        _buildPreguntaPreview(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreguntaHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.01),
            kAccentBlue.withValues(alpha: 0.01),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Número de pregunta
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kBrandPurple, kAccentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Tipo de pregunta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTipoLabel(_tipoPregunta),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kBrandPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _esRequerida ? 'Pregunta obligatoria' : 'Pregunta opcional',
                  style: TextStyle(
                    fontSize: 12,
                    color: _esRequerida ? kAccentGreen : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Controles
          Row(
            children: [
              // Switch requerida
              Switch(
                value: _esRequerida,
                onChanged: (value) => _updatePregunta('requerida', value),
                activeColor: kBrandPurple,
              ),

              const SizedBox(width: 8),

              // Botón expandir/contraer
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: kBrandPurple,
                ),
              ),

              // Botón eliminar
              if (widget.canDelete)
                IconButton(
                  onPressed: widget.onEliminar,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreguntaTextField() {
    return TextField(
      controller: TextEditingController(text: widget.pregunta['texto'] ?? '')
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: (widget.pregunta['texto'] ?? '').length),
        ),
      decoration: InputDecoration(
        labelText: 'Pregunta',
        prefixIcon: Icon(Icons.help_outline, color: kBrandPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBorderColor.withValues(alpha: 0.03)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBrandPurple, width: 2),
        ),
        filled: true,
        fillColor: kBrandPurpleLight.withValues(alpha: 0.01),
      ),
      maxLines: 2,
      style: const TextStyle(fontSize: 16),
      onChanged: (value) => _updatePregunta('texto', value),
    );
  }

  Widget _buildTipoSelector() {
    final tipos = [
      {
        'value': 'estrellas',
        'label': '⭐ Calificación con estrellas',
        'icon': Icons.star
      },
      {
        'value': 'escala_1_10',
        'label': '📊 Escala del 1 al 10',
        'icon': Icons.linear_scale
      },
      {
        'value': 'multiple_choice',
        'label': '☑️ Opción múltiple',
        'icon': Icons.radio_button_checked
      },
      {
        'value': 'texto_libre',
        'label': '📝 Texto libre',
        'icon': Icons.text_fields
      },
      {'value': 'si_no', 'label': '✅ Sí / No', 'icon': Icons.check_circle},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de pregunta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kBrandPurple,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tipos.map((tipo) {
              final isSelected = _tipoPregunta == tipo['value'];
              return GestureDetector(
                onTap: () {
                  _updatePregunta('tipo', tipo['value']);
                  if (tipo['value'] == 'estrellas') {
                    _updatePregunta(
                        'opciones', ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]);
                  } else if (tipo['value'] == 'escala_1_10') {
                    _updatePregunta(
                        'opciones', List.generate(10, (i) => '${i + 1}'));
                  } else if (tipo['value'] == 'si_no') {
                    _updatePregunta('opciones', ['Sí', 'No']);
                  } else if (tipo['value'] == 'multiple_choice') {
                    _updatePregunta('opciones', ['Opción 1', 'Opción 2']);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? kBrandPurple : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? kBrandPurple
                          : kBorderColor.withValues(alpha: 0.03),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: kBrandPurple.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tipo['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : kBrandPurple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tipo['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : kBrandPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpcionesEditor() {
    final opciones = List<String>.from(widget.pregunta['opciones'] ?? []);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAccentBlue.withValues(alpha: 0.005),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentBlue.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, color: kAccentBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Opciones de respuesta',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kAccentBlue,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  final newOpciones = [...opciones, 'Nueva opción'];
                  _updatePregunta('opciones', newOpciones);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: kAccentBlue,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...opciones.asMap().entries.map((entry) {
            final index = entry.key;
            final opcion = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: kAccentBlue.withValues(alpha: 0.01),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kAccentBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: opcion)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: opcion.length),
                        ),
                      decoration: InputDecoration(
                        hintText: 'Texto de la opción',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: kBorderColor.withValues(alpha: 0.03)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: kAccentBlue),
                        ),
                      ),
                      onChanged: (value) {
                        final newOpciones = [...opciones];
                        newOpciones[index] = value;
                        _updatePregunta('opciones', newOpciones);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (opciones.length > 2)
                    IconButton(
                      onPressed: () {
                        final newOpciones = [...opciones];
                        newOpciones.removeAt(index);
                        _updatePregunta('opciones', newOpciones);
                      },
                      icon: const Icon(Icons.delete_outline),
                      iconSize: 20,
                      color: Colors.red.shade400,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPreguntaPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurpleLight.withValues(alpha: 0.03),
            kAccentBlue.withValues(alpha: 0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: kBrandPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vista previa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pregunta
          Text(
            widget.pregunta['texto']?.isNotEmpty == true
                ? widget.pregunta['texto']
                : 'Escribe tu pregunta aquí...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: widget.pregunta['texto']?.isNotEmpty == true
                  ? Colors.black87
                  : Colors.grey,
            ),
          ),

          if (_esRequerida)
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

          const SizedBox(height: 16),

          // Preview de opciones según el tipo
          _buildTipoPreview(),
        ],
      ),
    );
  }

  Widget _buildTipoPreview() {
    switch (_tipoPregunta) {
      case 'estrellas':
        return Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            );
          }),
        );

      case 'escala_1_10':
        return Wrap(
          spacing: 8,
          children: List.generate(10, (index) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: kBrandPurple.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    color: kBrandPurple,
                  ),
                ),
              ),
            );
          }),
        );

      case 'multiple_choice':
        final opciones = List<String>.from(widget.pregunta['opciones'] ?? []);
        return Column(
          children: opciones.map((opcion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    color: kBrandPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    opcion.isNotEmpty ? opcion : 'Opción vacía',
                    style: TextStyle(
                      fontSize: 14,
                      color: opcion.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'si_no':
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kAccentGreen.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sí',
                style:
                    TextStyle(color: kAccentGreen, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );

      case 'texto_libre':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderColor.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'El usuario podrá escribir su respuesta aquí...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        );

      default:
        return Container();
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'estrellas':
        return '⭐ Calificación con estrellas';
      case 'escala_1_10':
        return '📊 Escala del 1 al 10';
      case 'multiple_choice':
        return '☑️ Opción múltiple';
      case 'texto_libre':
        return '📝 Texto libre';
      case 'si_no':
        return '✅ Sí / No';
      default:
        return 'Tipo desconocido';
    }
  }
}
