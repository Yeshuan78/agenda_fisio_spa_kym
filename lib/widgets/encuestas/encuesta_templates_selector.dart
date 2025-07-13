// [Archivo: lib/widgets/encuestas/encuesta_templates_selector.dart]
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class EncuestaTemplatesSelector extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onTemplateSelected;

  const EncuestaTemplatesSelector({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  State<EncuestaTemplatesSelector> createState() =>
      _EncuestaTemplatesSelectorState();
}

class _EncuestaTemplatesSelectorState extends State<EncuestaTemplatesSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  bool _isExpanded = false;
  String? _selectedTemplate;

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'spa_wellness',
      'nombre': '🧘 Spa & Wellness',
      'descripcion': 'Perfecto para spas, centros de bienestar y relajación',
      'icon': Icons.spa,
      'color': kAccentGreen,
      'preguntas': [
        {
          "texto": "¿Cómo calificarías la atención del profesional?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿Qué tan relajante fue tu experiencia?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿Cómo valorarías la limpieza de nuestras instalaciones?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿Recomendarías nuestros servicios?",
          "tipo": "si_no",
          "requerida": true,
          "opciones": ["Sí", "No"]
        }
      ]
    },
    {
      'id': 'corporativo',
      'nombre': '🏢 Corporativo',
      'descripcion': 'Ideal para servicios corporativos y empresariales',
      'icon': Icons.business,
      'color': kBrandPurple,
      'preguntas': [
        {
          "texto": "¿Cómo calificarías la calidad del servicio recibido?",
          "tipo": "escala_1_10",
          "requerida": true,
          "opciones": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        },
        {
          "texto": "¿Qué tan profesional fue la atención?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿Se cumplieron tus expectativas?",
          "tipo": "multiple_choice",
          "requerida": true,
          "opciones": [
            "Superaron mis expectativas",
            "Cumplieron mis expectativas",
            "No cumplieron mis expectativas"
          ]
        },
        {
          "texto": "¿Cómo mejorarías nuestro servicio?",
          "tipo": "texto_libre",
          "requerida": false,
          "opciones": []
        }
      ]
    },
    {
      'id': 'salud_medico',
      'nombre': '🏥 Salud & Médico',
      'descripcion': 'Especializado para servicios médicos y de salud',
      'icon': Icons.local_hospital,
      'color': kAccentBlue,
      'preguntas': [
        {
          "texto": "¿Cómo calificarías la atención médica recibida?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿Te sentiste cómodo(a) durante el tratamiento?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿El profesional explicó claramente el procedimiento?",
          "tipo": "si_no",
          "requerida": true,
          "opciones": ["Sí", "No"]
        },
        {
          "texto": "¿Notaste mejoría después del tratamiento?",
          "tipo": "multiple_choice",
          "requerida": false,
          "opciones": [
            "Mucha mejoría",
            "Algo de mejoría",
            "Sin cambios",
            "Prefiero no responder"
          ]
        }
      ]
    },
    {
      'id': 'eventos',
      'nombre': '🎉 Eventos',
      'descripcion': 'Para eventos, talleres y actividades grupales',
      'icon': Icons.event,
      'color': Colors.orange.shade400,
      'preguntas': [
        {
          "texto": "¿Cómo calificarías la organización del evento?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        },
        {
          "texto": "¿El contenido cumplió con tus expectativas?",
          "tipo": "escala_1_10",
          "requerida": true,
          "opciones": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        },
        {
          "texto": "¿Participarías en futuros eventos similares?",
          "tipo": "si_no",
          "requerida": true,
          "opciones": ["Sí", "No"]
        },
        {
          "texto": "¿Qué te gustó más del evento?",
          "tipo": "texto_libre",
          "requerida": false,
          "opciones": []
        }
      ]
    },
    {
      'id': 'personalizado',
      'nombre': '⚙️ Personalizado',
      'descripcion': 'Comienza desde cero con una encuesta básica',
      'icon': Icons.tune,
      'color': Colors.grey.shade600,
      'preguntas': [
        {
          "texto": "¿Cómo calificarías tu experiencia general?",
          "tipo": "estrellas",
          "requerida": true,
          "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
        }
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectTemplate(Map<String, dynamic> template) {
    setState(() {
      _selectedTemplate = template['id'];
    });

    final preguntas = List<Map<String, dynamic>>.from(template['preguntas']);
    widget.onTemplateSelected(preguntas);

    // Contraer después de seleccionar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _toggleExpanded();
      }
    });

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('✨ Template "${template['nombre']}" aplicado exitosamente'),
        backgroundColor: template['color'] as Color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Templates Grid (expandible)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child:
                _isExpanded ? _buildTemplatesGrid() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kBrandPurple.withValues(alpha: 0.1),
              kAccentBlue.withValues(alpha: 0.1),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kBrandPurple, kAccentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: kBrandPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.dashboard_customize,
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
                    'Templates Profesionales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTemplate != null
                        ? 'Template "${_templates.firstWhere((t) => t['id'] == _selectedTemplate)['nombre']}" aplicado'
                        : 'Elige un template o personaliza tu encuesta',
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedTemplate != null
                          ? kAccentGreen
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.expand_more,
                color: kBrandPurple,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesGrid() {
    return FadeTransition(
      opacity: _slideAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona un template para comenzar:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  final isSelected = _selectedTemplate == template['id'];

                  return _buildTemplateCard(template, isSelected);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template, bool isSelected) {
    final color = template['color'] as Color;

    return GestureDetector(
      onTap: () => _selectTemplate(template),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : kBorderColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del template
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      template['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Nombre del template
              Text(
                template['nombre'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Descripción
              Text(
                template['descripcion'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Footer con número de preguntas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(template['preguntas'] as List).length} preguntas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
