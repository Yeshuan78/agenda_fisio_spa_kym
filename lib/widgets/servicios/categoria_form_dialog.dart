import 'package:flutter/material.dart';
import 'dart:math';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/services/categoria_service.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/iconos_categoria_servicio.dart';

class CategoriaFormDialog extends StatefulWidget {
  const CategoriaFormDialog({super.key});

  @override
  State<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends State<CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoriaService = CategoriaService();

  String _nombre = '';
  Color _color = const Color(0xFF673AB7);
  String _icono = 'spa';

  final List<Color> _coloresDisponibles = const [
    Color(0xFF4FC3F7), // masajes
    Color(0xFFFFB74D), // faciales
    Color(0xFF81C784), // fisioterapia
    Color(0xFFBA68C8), // podología
    Color(0xFFEF5350), // cosmetología
    Color(0xFF3F51B5),
    Color(0xFF00BCD4),
    Color(0xFF009688),
    Color(0xFF9C27B0),
  ];

  void _seleccionarColorAleatorio() {
    final random = Random();
    final index = random.nextInt(_coloresDisponibles.length);
    setState(() {
      _color = _coloresDisponibles[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Nombre de categoría'),
                onSaved: (v) => _nombre = v ?? '',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              _buildColorSelector(),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _icono,
                onChanged: (v) => setState(() => _icono = v!),
                items: iconosCategoriaServicio.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        Icon(e.value),
                        const SizedBox(width: 8),
                        Text(e.key),
                      ],
                    ),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Ícono'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kBrandPurple),
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              final nueva = CategoriaModel(
                categoriaId: '',
                nombre: _nombre,
                colorHex:
                    '#${_color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                icono: _icono,
                orden: 0,
              );
              await _categoriaService.crearCategoria(nueva);
              if (!mounted) return;
              Navigator.pop(context, _nombre);
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Color'),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _coloresDisponibles.map((color) {
            final isSelected = color == _color;
            return GestureDetector(
              onTap: () => setState(() => _color = color),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _seleccionarColorAleatorio,
          icon: const Icon(Icons.casino),
          label: const Text('Color aleatorio'),
        ),
      ],
    );
  }
}
