import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/services/categoria_service.dart';
import 'package:agenda_fisio_spa_kym/services/servicio_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/categoria_form_dialog.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ServicioForm extends StatefulWidget {
  final ServicioModel? servicio;

  const ServicioForm({super.key, this.servicio});

  @override
  State<ServicioForm> createState() => _ServicioFormState();
}

class _ServicioFormState extends State<ServicioForm> {
  final _formKey = GlobalKey<FormState>();
  final CategoriaService _categoriaService = CategoriaService();
  final ServicioService _servicioService = ServicioService();

  List<CategoriaModel> _categorias = [];

  late String _nombre;
  late String _descripcion;
  late String _categoria;
  late int _duracion;
  late int _precio;
  late String _imagen;

  @override
  void initState() {
    super.initState();
    final s = widget.servicio;
    _nombre = s?.name ?? '';
    _descripcion = s?.description ?? '';
    _categoria = s?.category ?? '';
    _duracion = s?.duration ?? 0;
    _precio = s?.price ?? 0;
    _imagen = s?.image ?? '';
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final resultado = await _categoriaService.getCategorias();
    setState(() {
      _categorias = resultado;
    });
  }

  Future<void> _crearNuevaCategoria() async {
    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => const CategoriaFormDialog(),
    );
    if (nueva != null && nueva.isNotEmpty) {
      await _cargarCategorias();
      setState(() => _categoria = nueva.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.servicio == null ? 'Nuevo servicio' : 'Editar servicio'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInput('Nombre',
                    initialValue: _nombre, onSaved: (v) => _nombre = v),
                const SizedBox(height: 12),
                _buildInput('Descripción',
                    initialValue: _descripcion,
                    onSaved: (v) => _descripcion = v,
                    maxLines: 3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildCategoriaDropdown()),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _crearNuevaCategoria,
                      child: const Text('+ Nueva'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildInput('Duración (min)',
                            initialValue: _duracion.toString(),
                            onSaved: (v) => _duracion = int.tryParse(v) ?? 0,
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildInput('Precio',
                            initialValue: _precio.toString(),
                            onSaved: (v) => _precio = int.tryParse(v) ?? 0,
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInput('URL Imagen',
                    initialValue: _imagen, onSaved: (v) => _imagen = v),
              ],
            ),
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
              final nuevo = ServicioModel(
                serviceId: widget.servicio?.serviceId ?? '',
                name: _nombre,
                category: _categoria.trim(),
                description: _descripcion,
                duration: _duracion,
                price: _precio,
                tipo: widget.servicio?.tipo ?? 'domicilio',
                activo: widget.servicio?.activo ?? true,
                bufferMin: widget.servicio?.bufferMin ?? 0,
                nivelEnergia: widget.servicio?.nivelEnergia ?? 'media',
                capacidad: widget.servicio?.capacidad ?? 1,
                professionalIds: widget.servicio?.professionalIds ?? [],
                image: _imagen,
              );

              try {
                await _servicioService.crearServicio(nuevo);
                if (!mounted) return;
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Servicio guardado correctamente')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al guardar: \$e')),
                );
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildInput(String label,
      {required String initialValue,
      required void Function(String) onSaved,
      int maxLines = 1,
      TextInputType? keyboardType}) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: (val) => onSaved(val ?? ''),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<String>(
      value: _categoria.isNotEmpty ? _categoria : null,
      onChanged: (v) => setState(() => _categoria = v?.trim() ?? ''),
      items: _categorias.map((cat) {
        return DropdownMenuItem(
          value: cat.nombre.trim(),
          child: Text(cat.nombre.trim()),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
      ),
    );
  }
}
