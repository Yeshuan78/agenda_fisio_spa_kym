import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/servicio_group.dart';

class CategoriaGroupWidget extends StatefulWidget {
  final CategoriaModel categoria;
  final List<ServicioModel> servicios;
  final void Function(ServicioModel) onEdit;
  final void Function(ServicioModel) onDelete;

  const CategoriaGroupWidget({
    super.key,
    required this.categoria,
    required this.servicios,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<CategoriaGroupWidget> createState() => _CategoriaGroupWidgetState();
}

class _CategoriaGroupWidgetState extends State<CategoriaGroupWidget> {
  bool _expandido = false;
  bool hoverCategoria = false; // ✅ CAMBIO: estado hover institucional

  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      return Color(int.parse("0x$hexColor"));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromHex(widget.categoria.colorHex);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: MouseRegion(
            onEnter: (_) => setState(() => hoverCategoria = true),
            onExit: (_) => setState(() => hoverCategoria = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: hoverCategoria
                    ? _getColorFromHex(widget.categoria.colorHex).withAlpha(30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.folder,
                        color: _getColorFromHex(widget.categoria.colorHex)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.categoria.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                    ),
                  ],
                ),
              ),
            ),
          ),
          onExpansionChanged: (value) {
            setState(() => _expandido = value);
          },
          children: [
            ServicioGroup(
              categoria: widget.categoria,
              servicios: widget.servicios,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
