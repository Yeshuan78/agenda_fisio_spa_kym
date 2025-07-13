// [tags_management_section.dart] - SECCIÓN DE GESTIÓN DE ETIQUETAS
// 📁 Ubicación: /lib/widgets/clients/forms/tags_management_section.dart
// 🎯 OBJETIVO: Gestión avanzada de etiquetas con glassmorphism y animaciones

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/controllers/client_form_controller.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_form_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/forms/glassmorphism_form_card.dart';

/// 🏷️ SECCIÓN DE GESTIÓN DE ETIQUETAS
class TagsManagementSection extends StatefulWidget {
  final ClientFormController controller;
  final bool isRequired;

  const TagsManagementSection({
    super.key,
    required this.controller,
    this.isRequired = false,
  });

  @override
  State<TagsManagementSection> createState() => _TagsManagementSectionState();
}

class _TagsManagementSectionState extends State<TagsManagementSection>
    with TickerProviderStateMixin {
  
  // ✅ CONTROLADOR PARA NUEVA ETIQUETA
  late final TextEditingController _newTagController;
  final FocusNode _newTagFocus = FocusNode();

  // ✅ ETIQUETAS BASE DISPONIBLES
  static const List<String> _baseTags = [
    'VIP',
    'Corporativo',
    'Nuevo',
    'Recurrente',
    'Promoción',
    'Consentido',
    'Especial',
  ];

  // ✅ COLORES PARA ETIQUETAS BASE
  static const Map<String, Color> _baseTagColors = {
    'VIP': kBrandPurple,
    'Corporativo': kAccentBlue,
    'Nuevo': kAccentGreen,
    'Recurrente': Colors.amber,
    'Promoción': Colors.orange,
    'Consentido': Colors.pink,
    'Especial': Colors.red,
  };

  // ✅ ANIMACIONES
  late AnimationController _addTagAnimationController;
  late Animation<double> _addTagScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _newTagController = TextEditingController();
  }

  void _initializeAnimations() {
    _addTagAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _addTagScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _addTagAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _newTagController.dispose();
    _newTagFocus.dispose();
    _addTagAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TagsFormInfo>(
      valueListenable: widget.controller.tagsInfoNotifier,
      builder: (context, tagsInfo, child) {
        return GlassmorphismFormCard(
          title: 'Etiquetas y Clasificación',
          titleIcon: Icons.label_outline,
          subtitle: 'Categoriza al cliente con etiquetas personalizables',
          primaryColor: kAccentGreen,
          isRequired: widget.isRequired,
          child: _buildTagsContent(tagsInfo),
        );
      },
    );
  }

  Widget _buildTagsContent(TagsFormInfo tagsInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección de etiquetas base
        _buildBaseTagsSection(tagsInfo),
        const SizedBox(height: 24),

        // Sección para agregar etiquetas personalizadas
        _buildCustomTagsInput(),
        const SizedBox(height: 20),

        // Lista de etiquetas personalizadas
        if (tagsInfo.customTags.isNotEmpty) ...[
          _buildCustomTagsList(tagsInfo),
          const SizedBox(height: 20),
        ],

        // Resumen de etiquetas
        _buildTagsSummary(tagsInfo),
      ],
    );
  }

  Widget _buildBaseTagsSection(TagsFormInfo tagsInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_outline,
              color: kAccentGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Etiquetas Base',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kAccentGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona las categorías que aplican al cliente',
          style: TextStyle(
            fontSize: 14,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Chips de etiquetas base
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _baseTags.map((tag) {
            final isSelected = tagsInfo.baseTags.contains(tag);
            final color = _baseTagColors[tag] ?? kAccentGreen;
            
            return _buildGlassmorphismTagChip(
              label: tag,
              color: color,
              isSelected: isSelected,
              onTap: () => _toggleBaseTag(tag),
              icon: _getTagIcon(tag),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: kBrandPurple,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Etiquetas Personalizadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kBrandPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Crea etiquetas específicas para este cliente',
          style: TextStyle(
            fontSize: 14,
            color: kTextSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Input para nueva etiqueta
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: kBorderSoft,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _newTagController,
                  focusNode: _newTagFocus,
                  enabled: widget.controller.currentState.canEdit,
                  decoration: InputDecoration(
                    hintText: 'Nueva etiqueta personalizada...',
                    prefixIcon: Icon(
                      Icons.edit_outlined,
                      color: kBrandPurple,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    hintStyle: TextStyle(
                      color: kTextMuted,
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]')),
                  ],
                  onFieldSubmitted: (_) => _addCustomTag(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _addTagScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _addTagScaleAnimation.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kBrandPurple,
                          kBrandPurple.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandPurple.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.controller.currentState.canEdit ? _addCustomTag : null,
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomTagsList(TagsFormInfo tagsInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.style_outlined,
              color: kBrandPurple,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Etiquetas Creadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kBrandPurple,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: kBrandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: kBrandPurple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${tagsInfo.customTags.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tagsInfo.customTags.asMap().entries.map((entry) {
            final index = entry.key;
            final tag = entry.value;
            final color = _getCustomTagColor(index);
            
            return _buildCustomTagChip(
              label: tag,
              color: color,
              onRemove: () => _removeCustomTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSummary(TagsFormInfo tagsInfo) {
    final totalTags = tagsInfo.totalTags;
    
    if (totalTags == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kTextMuted.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: kTextMuted.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: kTextMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sin etiquetas asignadas. Las etiquetas ayudan a categorizar y filtrar clientes.',
                style: TextStyle(
                  fontSize: 14,
                  color: kTextMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAccentGreen.withValues(alpha: 0.05),
            kAccentGreen.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kAccentGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                color: kAccentGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen de Etiquetas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kAccentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildSummaryItem(
                'Total',
                totalTags.toString(),
                kAccentGreen,
                Icons.label,
              ),
              const SizedBox(width: 20),
              _buildSummaryItem(
                'Base',
                tagsInfo.baseTags.length.toString(),
                kAccentBlue,
                Icons.star,
              ),
              const SizedBox(width: 20),
              _buildSummaryItem(
                'Personalizadas',
                tagsInfo.customTags.length.toString(),
                kBrandPurple,
                Icons.edit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: kTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphismTagChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: widget.controller.currentState.canEdit ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected ? [
              color.withValues(alpha: 0.9),
              color.withValues(alpha: 0.7),
            ] : [
              Colors.white.withValues(alpha: 0.8),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: isSelected ? 0.8 : 0.3),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTagChip({
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.controller.currentState.canEdit ? onRemove : null,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 🔧 MÉTODOS DE LÓGICA
  // ========================================================================

  void _toggleBaseTag(String tag) {
    widget.controller.toggleBaseTag(tag);
    HapticFeedback.lightImpact();
  }

  void _addCustomTag() {
    final tagText = _newTagController.text.trim();
    if (tagText.isNotEmpty) {
      widget.controller.addCustomTag(tagText);
      _newTagController.clear();
      _addTagAnimationController.forward().then((_) {
        _addTagAnimationController.reverse();
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _removeCustomTag(String tag) {
    widget.controller.removeCustomTag(tag);
    HapticFeedback.lightImpact();
  }

  // ========================================================================
  // 🎨 MÉTODOS HELPER
  // ========================================================================

  IconData _getTagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'vip':
        return Icons.star;
      case 'corporativo':
        return Icons.business;
      case 'nuevo':
        return Icons.fiber_new;
      case 'recurrente':
        return Icons.repeat;
      case 'promoción':
        return Icons.local_offer;
      case 'consentido':
        return Icons.favorite;
      case 'especial':
        return Icons.diamond;
      default:
        return Icons.label;
    }
  }

  Color _getCustomTagColor(int index) {
    const colors = [
      Color(0xFF7c4dff), // Morado vibrante
      Color(0xFF009688), // Teal
      Color(0xFF795548), // Marrón
      Color(0xFF3f51b5), // Índigo
      Color(0xFF00bcd4), // Cyan
      Color(0xFFff5722), // Deep Orange
      Color(0xFFcddc39), // Lime
      Color(0xFF607d8b), // Blue Grey
      Color(0xFFe91e63), // Pink
      Color(0xFFffc107), // Amber
    ];
    
    return colors[index % colors.length];
  }
}