import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_option.dart';
import 'package:agenda_fisio_spa_kym/widgets/navigation/sidebar_context_menu.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class SidebarItemTile extends StatefulWidget {
  final SidebarOption option;
  final bool isActive;
  final VoidCallback onTap;

  final bool esVistaEstandar;
  final bool esModoDrag;
  final List<String> favoritos;
  final Function(List<String>) onFavoritosChanged;

  const SidebarItemTile({
    super.key,
    required this.option,
    required this.isActive,
    required this.onTap,
    required this.esVistaEstandar,
    required this.favoritos,
    required this.onFavoritosChanged,
    this.esModoDrag = false,
  });

  @override
  State<SidebarItemTile> createState() => _SidebarItemTileState();
}

class _SidebarItemTileState extends State<SidebarItemTile>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 150),
    );
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorito() {
    final nuevo = [...widget.favoritos];
    if (nuevo.contains(widget.option.route)) {
      nuevo.remove(widget.option.route);
    } else {
      nuevo.add(widget.option.route);
    }
    widget.onFavoritosChanged(nuevo);
    _controller.reverse().then((_) => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = kBrandPurple;
    final hoverScale = _hovering ? 1.0 : 0.98;
    final esFavorito = widget.favoritos.contains(widget.option.route);

    return GestureDetector(
      onTap: widget.onTap,
      onSecondaryTapDown: (details) {
        showSidebarContextMenu(context, details.globalPosition, widget.option);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: hoverScale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                gradient: widget.isActive
                    ? LinearGradient(
                        colors: [
                          kBrandPurpleLight.withValues(alpha: 0.09),
                          Colors.white,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: widget.isActive
                    ? null
                    : _hovering
                        ? kBrandPurpleLight.withAlpha(50)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isActive
                      ? activeColor.withAlpha(160)
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.035),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(widget.option.icon,
                          color:
                              widget.isActive ? activeColor : Colors.grey[700]),
                      const SizedBox(width: 12),
                      Text(
                        widget.option.label,
                        style: TextStyle(
                          fontWeight: widget.isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: widget.isActive ? activeColor : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // ✅ ÍCONO DERECHO — Favorito o Drag
                  if (widget.esModoDrag)
                    const Icon(Icons.more_vert, size: 20, color: Colors.grey)
                  else if (widget.esVistaEstandar)
                    ScaleTransition(
                      scale: _controller,
                      child: GestureDetector(
                        onTap: _toggleFavorito,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            esFavorito ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: esFavorito
                                ? kBrandPurple
                                : Colors.grey.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
