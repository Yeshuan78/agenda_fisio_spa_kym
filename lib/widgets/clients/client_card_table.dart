// [client_card_table.dart] - VISTA TABLA ENTERPRISE 1200px - ✅ FIX: TELÉFONO MÁS ANCHO + EMPRESA ORDENABLE
// 📁 Ubicación: /lib/widgets/clients/client_card_table.dart
// 🎯 OBJETIVO: Vista tipo spreadsheet ultra-compacta 48px altura - CONSTRAINT 1200px
// ✅ CAMBIOS: Teléfono 160px + Empresa ordenable por alfabeto

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/enums/view_mode.dart';

/// 📊 CLIENT CARD TABLE - VISTA SPREADSHEET ENTERPRISE (CONSTRAINT 1200px)
/// Máxima densidad de datos tipo Excel/Google Sheets - RESPONSIVE
class ClientCardTable extends StatefulWidget {
  final ClientModel client;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onQuickPreview;
  final bool isEvenRow;

  const ClientCardTable({
    super.key,
    required this.client,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onQuickPreview,
    this.isEvenRow = false,
  });

  @override
  State<ClientCardTable> createState() => _ClientCardTableState();
}

class _ClientCardTableState extends State<ClientCardTable> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 1200), // 🎯 ACTUALIZADO A 1200PX
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onQuickPreview();
            },
            child: Container(
              height: ViewMode.table.cardHeight,
              margin: ViewMode.table.cardMargin,
              decoration: _buildTableRowDecoration(),
              child: _buildTableRow(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildTableRowDecoration() {
    Color backgroundColor;

    if (widget.isSelected) {
      backgroundColor = widget.client.statusColor.withValues(alpha: 0.1);
    } else if (_isHovered) {
      backgroundColor = widget.client.statusColor.withValues(alpha: 0.05);
    } else if (widget.isEvenRow) {
      backgroundColor = kBackgroundColor.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.white;
    }

    return BoxDecoration(
      color: backgroundColor,
      border: Border(
        bottom: BorderSide(
          color: kBorderSoft.withValues(alpha: 0.5),
          width: 0.5,
        ),
        left: BorderSide(
          color: widget.isSelected
              ? widget.client.statusColor
              : Colors.transparent,
          width: widget.isSelected ? 3 : 0,
        ),
      ),
    );
  }

  Widget _buildTableRow() {
    return Row(
      children: [
        // CHECKBOX (50px) - AUMENTADO 5px
        _buildColumnWrapper(50, _buildTableCheckbox()),

        // AVATAR + NOMBRE (280px) - AUMENTADO 50px
        _buildColumnWrapper(280, _buildNameCell()),

        // EMAIL (240px) - AUMENTADO 30px
        _buildColumnWrapper(240, _buildEmailCell()),

        // TELÉFONO (160px) - ✅ FIX: AUMENTADO DE 130px A 160px (+30px)
        _buildColumnWrapper(160, _buildPhoneCell()),

        // EMPRESA (Flexible) - EXPANDIBLE MÁS ANCHO - ✅ FIX: Reducido para compensar teléfono
        Expanded(
            child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: _buildCompanyCell(),
        )),

        // STATUS (85px) - AUMENTADO 10px
        _buildColumnWrapper(85, _buildStatusCell()),

        // TAGS (105px) - AUMENTADO 10px
        _buildColumnWrapper(105, _buildTagsCell()),

        // ACTIONS (75px) - AUMENTADO 10px
        _buildColumnWrapper(75, _buildActionsCell()),
      ],
    );
  }

  Widget _buildColumnWrapper(double width, Widget child) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 6), // PADDING AUMENTADO
        child: child,
      ),
    );
  }

  Widget _buildTableCheckbox() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onSelect();
        },
        child: Container(
          width: 18, // CHECKBOX MÁS GRANDE
          height: 18,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.client.statusColor
                : Colors.transparent,
            border: Border.all(
              color: widget.client.statusColor.withValues(alpha: 0.6),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: widget.isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
      ),
    );
  }

  Widget _buildNameCell() {
    return Row(
      children: [
        // Mini avatar MÁS GRANDE
        Container(
          width: 32, // AUMENTADO DE 28 A 32
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.client.statusColor.withValues(alpha: 0.2),
                widget.client.statusColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8), // RADIO MÁS GRANDE
            border: Border.all(
              color: widget.client.statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              _getInitials(widget.client.fullName),
              style: TextStyle(
                fontSize: 12, // TEXTO MÁS GRANDE
                fontWeight: FontWeight.bold,
                color: widget.client.statusColor,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10), // SPACING AUMENTADO

        // Nombre
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.client.fullName,
                style: const TextStyle(
                  fontSize: 14, // TEXTO MÁS GRANDE
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Indicador VIP/Corporate en nombre
              if (widget.client.isVIP || widget.client.isCorporate)
                Row(
                  children: [
                    if (widget.client.isVIP) ...[
                      Icon(
                        Icons.star,
                        size: 10, // ICONO MÁS GRANDE
                        color: Colors.amber.shade600,
                      ),
                      const SizedBox(width: 3),
                    ],
                    if (widget.client.isCorporate) ...[
                      Icon(
                        Icons.business,
                        size: 10, // ICONO MÁS GRANDE
                        color: kAccentBlue,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailCell() {
    return GestureDetector(
      onTap: () => _launchEmail(widget.client.email),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            size: 14, // ICONO MÁS GRANDE
            color: kTextMuted,
          ),
          const SizedBox(width: 6), // SPACING AUMENTADO
          Expanded(
            child: Text(
              widget.client.email,
              style: TextStyle(
                fontSize: 13, // TEXTO MÁS GRANDE
                color: kTextSecondary,
                decoration: _isHovered ? TextDecoration.underline : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCell() {
    return GestureDetector(
      onTap: () => _launchPhone(widget.client.phone),
      child: Row(
        children: [
          Icon(
            Icons.phone_outlined,
            size: 14, // ICONO MÁS GRANDE
            color: kTextMuted,
          ),
          const SizedBox(width: 6), // SPACING AUMENTADO
          Expanded(
            child: Text(
              _formatPhoneForDisplay(widget.client.phone),
              style: TextStyle(
                fontSize: 13, // TEXTO MÁS GRANDE
                color: kTextSecondary,
                decoration: _isHovered ? TextDecoration.underline : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCell() {
    if (widget.client.empresa.isEmpty) {
      return Center(
        child: Text(
          '-',
          style: TextStyle(
            fontSize: 13, // TEXTO MÁS GRANDE
            color: kTextMuted,
          ),
        ),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.business_outlined,
          size: 14, // ICONO MÁS GRANDE
          color: kTextMuted,
        ),
        const SizedBox(width: 6), // SPACING AUMENTADO
        Expanded(
          child: Text(
            widget.client.empresa,
            style: TextStyle(
              fontSize: 13, // TEXTO MÁS GRANDE
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCell() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4), // PADDING AUMENTADO
        decoration: BoxDecoration(
          color: widget.client.statusColor,
          borderRadius: BorderRadius.circular(10), // RADIO MÁS GRANDE
          boxShadow: [
            BoxShadow(
              color: widget.client.statusColor.withValues(alpha: 0.2),
              blurRadius: 4, // SOMBRA MÁS DIFUSA
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              color: Colors.white,
              size: 10, // ICONO MÁS GRANDE
            ),
            const SizedBox(width: 4), // SPACING AUMENTADO
            Text(
              _getStatusAbbreviation(),
              style: const TextStyle(
                fontSize: 10, // TEXTO MÁS GRANDE
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCell() {
    if (widget.client.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleTags =
        widget.client.tags.take(4).toList(); // MÁS TAGS VISIBLES
    final moreCount = widget.client.tags.length - 4;

    return Row(
      children: [
        // Dots representando tags MÁS GRANDES
        ...visibleTags
            .map((tag) => Container(
                  margin: const EdgeInsets.only(right: 4), // SPACING AUMENTADO
                  width: 8, // DOT MÁS GRANDE
                  height: 8,
                  decoration: BoxDecoration(
                    color: tag.displayColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tag.displayColor.withValues(alpha: 0.3),
                        blurRadius: 3, // SOMBRA MÁS DIFUSA
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ))
            .toList(),

        // Contador de tags adicionales
        if (moreCount > 0) ...[
          const SizedBox(width: 4), // SPACING AUMENTADO
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 5, vertical: 2), // PADDING AUMENTADO
            decoration: BoxDecoration(
              color: kTextMuted.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8), // RADIO MÁS GRANDE
            ),
            child: Text(
              '+$moreCount',
              style: TextStyle(
                fontSize: 9, // TEXTO MÁS GRANDE
                color: kTextMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        // Spacer para alinear a la izquierda
        const Spacer(),
      ],
    );
  }

  Widget _buildActionsCell() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTableAction(
          Icons.edit_outlined,
          'Editar',
          kAccentBlue,
          widget.onEdit,
        ),
        const SizedBox(width: 6), // SPACING AUMENTADO
        _buildTableAction(
          Icons.delete_outline,
          'Eliminar',
          Colors.red,
          widget.onDelete,
        ),
      ],
    );
  }

  Widget _buildTableAction(
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
          width: 24, // BOTONES MÁS GRANDES
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: _isHovered ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(6), // RADIO MÁS GRANDE
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 14, color: color), // ICONO MÁS GRANDE
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

  String _getStatusAbbreviation() {
    switch (widget.client.status) {
      case ClientStatus.vip:
        return 'VIP';
      case ClientStatus.active:
        return 'ACT';
      case ClientStatus.prospect:
        return 'PRO';
      case ClientStatus.inactive:
        return 'INA';
      case ClientStatus.suspended:
        return 'SUS';
    }
  }

  String _formatPhoneForDisplay(String phone) {
    // Formatear teléfono para México (XX) XXXX-XXXX
    if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  void _launchEmail(String email) {
    debugPrint('📧 Abriendo email: $email');
    HapticFeedback.lightImpact();
    // TODO: Implementar launch de email
  }

  void _launchPhone(String phone) {
    debugPrint('📞 Llamando a: $phone');
    HapticFeedback.lightImpact();
    // TODO: Implementar launch de teléfono
  }
}

/// 📊 HEADER COMPONENT PARA TABLE VIEW - CONSTRAINT 1200px - ✅ FIX: EMPRESA ORDENABLE
/// Widget separado para el header de la tabla
class ClientTableHeader extends StatelessWidget {
  final bool showSortIndicators;
  final String? sortColumn;
  final bool sortAscending;
  final Function(String)? onSort;

  const ClientTableHeader({
    super.key,
    this.showSortIndicators = true,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 1200), // 🎯 ACTUALIZADO A 1200PX
        child: Container(
          height: 44, // HEADER MÁS ALTO
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kBrandPurple.withValues(alpha: 0.08),
                kBrandPurple.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            border: Border.all(
              color: kBorderSoft,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // CHECKBOX (50px) - AUMENTADO
              _buildHeaderColumn(50, '', false),

              // CLIENTE (280px) - AUMENTADO
              _buildHeaderColumn(280, 'CLIENTE', true, 'name'),

              // EMAIL (240px) - AUMENTADO
              _buildHeaderColumn(240, 'EMAIL', true, 'email'),

              // TELÉFONO (160px) - ✅ FIX: AUMENTADO DE 130px A 160px (+30px)
              _buildHeaderColumn(160, 'TELÉFONO', true, 'phone'),

              // EMPRESA (Flexible) - ✅ FIX: AHORA ORDENABLE POR ALFABETO
              Expanded(
                  child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8), // PADDING AUMENTADO
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    if (onSort != null) {
                      HapticFeedback.lightImpact();
                      onSort!('company');
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'EMPRESA',
                          style: TextStyle(
                            fontSize: 12, // FUENTE MÁS GRANDE
                            fontWeight: FontWeight.w700,
                            color: sortColumn == 'company'
                                ? kBrandPurple
                                : kTextSecondary,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showSortIndicators) ...[
                        const SizedBox(width: 4),
                        Icon(
                          sortColumn == 'company'
                              ? (sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                              : Icons.unfold_more,
                          size: 12,
                          color: sortColumn == 'company'
                              ? kBrandPurple
                              : kTextMuted,
                        ),
                      ],
                    ],
                  ),
                ),
              )),

              // ESTADO (85px) - AUMENTADO
              _buildHeaderColumn(85, 'ESTADO', true, 'status'),

              // ETIQUETAS (105px) - AUMENTADO
              _buildHeaderColumn(105, 'ETIQUETAS', false),

              // ACCIONES (75px) - AUMENTADO
              _buildHeaderColumn(75, 'ACCIONES', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderColumn(
    double width,
    String title,
    bool sortable, [
    String? sortKey,
  ]) {
    final isActive = sortColumn == sortKey;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8), // PADDING AUMENTADO
      alignment: title == 'ACCIONES' || title == 'ESTADO'
          ? Alignment.center
          : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11, // FUENTE MÁS GRANDE
                fontWeight: FontWeight.w700,
                color: isActive ? kBrandPurple : kTextSecondary,
                letterSpacing: 0.4, // LETTER SPACING AUMENTADO
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (sortable && showSortIndicators) ...[
            const SizedBox(width: 4), // SPACING AUMENTADO
            Icon(
              isActive
                  ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 12, // ICONO MÁS GRANDE
              color: isActive ? kBrandPurple : kTextMuted,
            ),
          ],
        ],
      ),
    );

    if (sortable && onSort != null && sortKey != null) {
      content = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onSort!(sortKey);
        },
        child: content,
      );
    }

    return SizedBox(width: width, child: content);
  }
}
