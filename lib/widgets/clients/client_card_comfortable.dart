// [client_card_premium.dart] - REDISEÑO CON GLASSMORPHISM DIRECTO
// 📁 Ubicación: /lib/widgets/clients/client_card_premium.dart
// 🎯 OBJETIVO: MISMO WIDGET, SOLO APLICAR ESTILO GLASSMORPHISM SIN IMPORTS INVENTADOS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 💎 CARD PREMIUM PARA CLIENTES - REDISEÑADO CON GLASSMORPHISM DIRECTO
class ClientCardComfortable extends StatefulWidget {
  final ClientModel client;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQuickPreview;

  const ClientCardComfortable({
    super.key,
    required this.client,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onQuickPreview,
  });

  @override
  State<ClientCardComfortable> createState() => _ClientCardComfortableState();
}

class _ClientCardComfortableState extends State<ClientCardComfortable>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = _getSecondaryColor();
    final isActiveOrHovered = widget.isSelected || _isHovered;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // 🎯 MAX 800PX
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onQuickPreview,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isPressed ? 0.98 : _scaleAnimation.value,
                    child: Container(
                      decoration: _buildGlassmorphismDecoration(
                          secondaryColor, isActiveOrHovered),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: _buildCardContent(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎨 DECORACIÓN GLASSMORPHISM DIRECTA
  BoxDecoration _buildGlassmorphismDecoration(
      Color secondaryColor, bool isActiveOrHovered) {
    final intensity = isActiveOrHovered ? 1.5 : 1.0;

    return BoxDecoration(
      // ✅ GRADIENTE GLASSMORPHISM BASE
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.7),
          widget.client.statusColor.withValues(alpha: 0.05),
          secondaryColor.withValues(alpha: 0.025),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),

      borderRadius: BorderRadius.circular(16),

      // ✅ BORDE GLASSMORPHISM
      border: Border.all(
        color: isActiveOrHovered
            ? widget.client.statusColor.withValues(alpha: 0.3)
            : widget.client.statusColor.withValues(alpha: 0.15),
        width: isActiveOrHovered ? 2.0 : 1.0,
      ),

      // ✅ SOMBRAS MULTICAPA GLASSMORPHISM
      boxShadow: [
        // SOMBRA PRINCIPAL COLOREADA
        BoxShadow(
          color: widget.client.statusColor.withValues(alpha: 0.15 * intensity),
          blurRadius: 20 * intensity,
          spreadRadius: 2 * intensity,
          offset: Offset(0, 8 * intensity),
        ),
        // SOMBRA INTERNA GLASSMORPHISM
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 15 * intensity,
          spreadRadius: -5 * intensity,
          offset: Offset(0, -5 * intensity),
        ),
        // SOMBRA DE PROFUNDIDAD
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05 * intensity),
          blurRadius: 30 * intensity,
          spreadRadius: 0,
          offset: Offset(0, 15 * intensity),
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildClientInfo(),
        const SizedBox(height: 16),
        _buildTags(),
        const SizedBox(height: 16),
        _buildMetricsAndActions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildSelectionCheckbox(),
        const SizedBox(width: 12),
        _buildClientAvatar(),
        const SizedBox(width: 16),
        Expanded(child: _buildClientName()),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildSelectionCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Transform.scale(
        scale: _isHovered || widget.isSelected ? 1.0 : 0.8,
        child: GestureDetector(
          onTap: widget.onSelect,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.client.statusColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: widget.client.statusColor,
                width: 2,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.client.statusColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: widget.isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildClientAvatar() {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.client.statusColor.withValues(alpha: 0.2),
              widget.client.statusColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.client.statusColor.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.client.statusColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getInitials(widget.client.fullName),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.client.statusColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.client.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (widget.client.empresa.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.business_outlined,
                size: 14,
                color: kTextSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.client.empresa,
                  style: TextStyle(
                    fontSize: 13,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.client.statusColor.withValues(alpha: 0.9),
            widget.client.statusColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.client.statusColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
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
          Icon(_getStatusIcon(), color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            widget.client.statusDisplayName.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.email_outlined,
          widget.client.email,
          isClickable: true,
          onTap: () => _launchEmail(widget.client.email),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          Icons.phone_outlined,
          widget.client.phone,
          isClickable: true,
          onTap: () => _launchPhone(widget.client.phone),
        ),
        if (widget.client.direccionCompleta.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_on_outlined,
            widget.client.direccionCompleta,
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    bool isClickable = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isClickable ? kBrandPurple : kTextSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isClickable ? kBrandPurple : kTextSecondary,
              fontWeight: isClickable ? FontWeight.w500 : FontWeight.w400,
              decoration: isClickable ? TextDecoration.underline : null,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (isClickable && onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildTags() {
    if (widget.client.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: widget.client.tags
          .take(5)
          .map((tag) => _buildGlassmorphismChip(tag))
          .toList(),
    );
  }

  Widget _buildGlassmorphismChip(ClientTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.6),
            tag.displayColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tag.displayColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tag.displayColor.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTagIcon(tag.label), size: 14, color: tag.displayColor),
          const SizedBox(width: 6),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tag.displayColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsAndActions() {
    return Row(
      children: [
        Expanded(child: _buildMetrics()),
        _buildActions(),
      ],
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        _buildMetricItem(
          Icons.event_available,
          widget.client.appointmentsCount.toString(),
          'Citas',
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildMetricItem(
          Icons.star_outline,
          widget.client.avgSatisfaction.toStringAsFixed(1),
          'Satisfacción',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: kTextMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          Icons.edit_outlined,
          'Editar',
          kAccentBlue,
          widget.onEdit,
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          Icons.delete_outline,
          'Eliminar',
          Colors.red,
          widget.onDelete,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // ====================================================================
  // 🎯 MÉTODOS HELPER
  // ====================================================================

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'N/A';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  Color _getSecondaryColor() {
    switch (widget.client.status) {
      case ClientStatus.vip:
        return Colors.amber;
      case ClientStatus.active:
        return kAccentBlue;
      case ClientStatus.prospect:
        return kAccentGreen;
      default:
        return kBrandPurple;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.client.status) {
      case ClientStatus.vip:
        return Icons.star;
      case ClientStatus.active:
        return Icons.check_circle;
      case ClientStatus.prospect:
        return Icons.person_add;
      case ClientStatus.inactive:
        return Icons.pause_circle;
      case ClientStatus.suspended:
        return Icons.block;
    }
  }

  IconData _getTagIcon(String tagLabel) {
    switch (tagLabel.toLowerCase()) {
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
      case 'especial':
        return Icons.favorite;
      default:
        return Icons.label;
    }
  }

  void _launchEmail(String email) {
    debugPrint('📧 Abriendo email: $email');
    HapticFeedback.lightImpact();
  }

  void _launchPhone(String phone) {
    debugPrint('📞 Llamando a: $phone');
    HapticFeedback.lightImpact();
  }
}
