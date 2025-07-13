// [client_card_compact.dart] - VISTA COMPACTA ENTERPRISE DE CLIENTE
// 📁 Ubicación: /lib/widgets/clients/client_card_compact.dart
// 🎯 OBJETIVO: Máxima densidad de información en 80px altura con glassmorphism optimizado

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';

/// 📦 CLIENT CARD COMPACT - DENSIDAD MÁXIMA ENTERPRISE
/// Diseñado para mostrar 6-8 clientes por pantalla con información esencial
class ClientCardCompact extends StatefulWidget {
  final ClientModel client;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQuickPreview;
  final bool showHoverEffects;

  const ClientCardCompact({
    super.key,
    required this.client,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onQuickPreview,
    this.showHoverEffects = true,
  });

  @override
  State<ClientCardCompact> createState() => _ClientCardCompactState();
}

class _ClientCardCompactState extends State<ClientCardCompact>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late Animation<double> _hoverScale;
  late Animation<double> _hoverOpacity;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _hoverScale = Tween<double>(
      begin: 1.0,
      end: 1.01, // Sutil para vista compacta
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
    
    _hoverOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          height: ViewMode.compact.cardHeight,
          margin: ViewMode.compact.cardMargin,
          child: _buildCardWrapper(),
        ),
      ),
    );
  }

  Widget _buildCardWrapper() {
    if (!widget.showHoverEffects) {
      return _buildCard();
    }

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onQuickPreview,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.99 : _hoverScale.value,
              child: _buildCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: _buildCompactDecoration(),
      child: ClipRRect(
        borderRadius: ViewMode.compact.cardBorderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildCompactContent(),
        ),
      ),
    );
  }

  BoxDecoration _buildCompactDecoration() {
    final isActiveOrHovered = widget.isSelected || _isHovered;
    final intensity = isActiveOrHovered ? 1.3 : 1.0;

    return BoxDecoration(
      // Glassmorphism optimizado para compact
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.75),
          widget.client.statusColor.withValues(alpha: 0.04),
          widget.client.statusColor.withValues(alpha: 0.02),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ),
      
      borderRadius: ViewMode.compact.cardBorderRadius,
      
      border: Border.all(
        color: isActiveOrHovered
            ? widget.client.statusColor.withValues(alpha: 0.3)
            : widget.client.statusColor.withValues(alpha: 0.15),
        width: isActiveOrHovered ? 1.5 : 1.0,
      ),
      
      boxShadow: [
        BoxShadow(
          color: widget.client.statusColor.withValues(alpha: 0.12 * intensity),
          blurRadius: 12 * intensity,
          spreadRadius: 1 * intensity,
          offset: Offset(0, 4 * intensity),
        ),
        if (isActiveOrHovered)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
      ],
    );
  }

  Widget _buildCompactContent() {
    return Row(
      children: [
        _buildSelectionArea(),
        const SizedBox(width: 12),
        _buildCompactAvatar(),
        const SizedBox(width: 14),
        Expanded(child: _buildMainInfo()),
        _buildStatusArea(),
        const SizedBox(width: 12),
        _buildActionsArea(),
      ],
    );
  }

  Widget _buildSelectionArea() {
    return SizedBox(
      width: 20,
      child: _buildSelectionCheckbox(),
    );
  }

  Widget _buildSelectionCheckbox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      child: Transform.scale(
        scale: _isHovered || widget.isSelected ? 1.0 : 0.9,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onSelect();
          },
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.client.statusColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: widget.client.statusColor,
                width: 1.5,
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
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAvatar() {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.client.statusColor.withValues(alpha: 0.2),
              widget.client.statusColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.client.statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.client.statusColor.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getInitials(widget.client.fullName),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.client.statusColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTopRow(),
        const SizedBox(height: 6),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        // Nombre (flex 3)
        Expanded(
          flex: 3,
          child: Text(
            widget.client.fullName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Email (flex 4)
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 12,
                color: kTextMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.client.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Teléfono + Empresa (flex 3)
        Expanded(
          flex: 3,
          child: _buildContactInfo(),
        ),
        
        const SizedBox(width: 8),
        
        // Tags compactos (flex 4)
        Expanded(
          flex: 4,
          child: _buildCompactTags(),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Row(
      children: [
        Icon(
          Icons.phone_outlined,
          size: 12,
          color: kTextMuted,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.client.phone,
            style: TextStyle(
              fontSize: 11,
              color: kTextMuted,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.client.empresa.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.business_outlined,
            size: 10,
            color: kTextMuted,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactTags() {
    final visibleTags = widget.client.tags.take(2).toList();
    final moreCount = widget.client.tags.length - 2;
    
    if (visibleTags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        ...visibleTags.map((tag) => _buildMiniTag(tag)),
        if (moreCount > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: kTextMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+$moreCount',
              style: TextStyle(
                fontSize: 9,
                color: kTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMiniTag(ClientTag tag) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.7),
            tag.displayColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: tag.displayColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTagIcon(tag.label),
            size: 8,
            color: tag.displayColor,
          ),
          const SizedBox(width: 2),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: tag.displayColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusArea() {
    return SizedBox(
      width: 60,
      child: _buildStatusBadge(),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.client.statusColor,
            widget.client.statusColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.client.statusColor.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(),
            color: Colors.white,
            size: 10,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              widget.client.statusDisplayName.length > 3 
                  ? widget.client.statusDisplayName.substring(0, 3).toUpperCase()
                  : widget.client.statusDisplayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsArea() {
    return SizedBox(
      width: 60,
      child: _buildQuickActions(),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          Icons.edit_outlined,
          'Editar',
          kAccentBlue,
          widget.onEdit,
        ),
        const SizedBox(width: 6),
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
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
      ),
    );
  }

  void _handleHover(bool isHovered) {
    if (!widget.showHoverEffects) return;
    
    setState(() => _isHovered = isHovered);
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  // ====================================================================
  // 🎯 MÉTODOS HELPER REUTILIZADOS
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
}