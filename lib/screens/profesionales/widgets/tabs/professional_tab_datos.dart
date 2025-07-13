import 'dart:io';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalTabDatos extends StatefulWidget {
  final String nombre;
  final String apellidos;
  final String sexo;
  final String cedulaProfesional;
  final String email;
  final String telefono;
  final String fotoUrl;
  final String notas;
  final List<String> especialidades;
  final bool estado;
  final DateTime fechaAlta;
  final void Function({
    String? nombre,
    String? apellidos,
    String? sexo,
    String? cedulaProfesional,
    String? email,
    String? telefono,
    String? fotoUrl,
    String? notas,
    List<String>? especialidades,
  }) onChanged;

  const ProfessionalTabDatos({
    super.key,
    required this.nombre,
    required this.apellidos,
    required this.sexo,
    required this.cedulaProfesional,
    required this.email,
    required this.telefono,
    required this.fotoUrl,
    required this.notas,
    required this.especialidades,
    required this.estado,
    required this.fechaAlta,
    required this.onChanged,
  });

  @override
  State<ProfessionalTabDatos> createState() => _ProfessionalTabDatosState();
}

class _ProfessionalTabDatosState extends State<ProfessionalTabDatos> {
  File? _imagen;
  List<String> especialidadesDisponibles = [];
  Map<String, String> mapaEspecialidadCategoria = {}; // nombre → categoría

  Color _colorEspecialidad(String nombreEspecialidad) {
    final categoria = mapaEspecialidadCategoria[nombreEspecialidad] ?? '';
    final base = categoria.toLowerCase().trim();
    final colores = {
      'masajes': const Color(0xFFE1F5FE),
      'faciales': const Color(0xFFFFF3E0),
      'fisioterapia': const Color(0xFFE8F5E9),
      'podología': const Color(0xFFF3E5F5),
      'cosmetología': const Color(0xFFFFEBEE),
    };
    return colores[base] ?? Colors.grey.shade200;
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagen = File(picked.path));
      widget.onChanged(fotoUrl: picked.path);
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarEspecialidades();
  }

  Future<void> _cargarEspecialidades() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('especialidades').get();

    final nombres = <String>[];
    final mapa = <String, String>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final nombre = data['nombre']?.toString() ?? '';
      final categoria = data['categoria']?.toString() ?? '';
      if (nombre.isNotEmpty) {
        nombres.add(nombre);
        mapa[nombre] = categoria;
      }
    }

    setState(() {
      especialidadesDisponibles = nombres;
      mapaEspecialidadCategoria = mapa;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: _seleccionarImagen,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: _imagen != null
                  ? FileImage(_imagen!)
                  : (widget.fotoUrl.isNotEmpty
                      ? NetworkImage(widget.fotoUrl)
                      : null) as ImageProvider<Object>?,
              child: _imagen == null && widget.fotoUrl.isEmpty
                  ? const Icon(Icons.camera_alt, size: 32)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.nombre,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      onChanged: (v) => widget.onChanged(nombre: v),
                    ),
                    SizedBox(height: spacing),
                    TextFormField(
                      initialValue: widget.cedulaProfesional,
                      decoration: const InputDecoration(
                          labelText: 'Cédula Profesional'),
                      onChanged: (v) => widget.onChanged(cedulaProfesional: v),
                    ),
                    SizedBox(height: spacing),
                    TextFormField(
                      initialValue: widget.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) => widget.onChanged(email: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.apellidos,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                      onChanged: (v) => widget.onChanged(apellidos: v),
                    ),
                    SizedBox(height: spacing),
                    DropdownButtonFormField<String>(
                      value: widget.sexo.isNotEmpty ? widget.sexo : null,
                      decoration: const InputDecoration(
                        labelText: 'Sexo',
                        hintText: 'Seleccione sexo',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'masculino', child: Text('Masculino')),
                        DropdownMenuItem(
                            value: 'femenino', child: Text('Femenino')),
                      ],
                      onChanged: (v) => widget.onChanged(sexo: v),
                    ),
                    SizedBox(height: spacing),
                    TextFormField(
                      initialValue: widget.telefono,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      maxLength: 14,
                      onChanged: (v) => widget.onChanged(telefono: v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Especialidades',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: especialidadesDisponibles.map((e) {
              final seleccionada = widget.especialidades.contains(e);
              return FilterChip(
                label: Text(e),
                selected: seleccionada,
                backgroundColor: _colorEspecialidad(e),
                selectedColor: kBrandPurple.withValues(alpha: 0.02),
                onSelected: (selected) {
                  final nuevas = List<String>.from(widget.especialidades);
                  if (selected) {
                    nuevas.add(e);
                  } else {
                    nuevas.remove(e);
                  }
                  widget.onChanged(especialidades: nuevas);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: widget.notas,
            decoration: const InputDecoration(labelText: 'Notas'),
            maxLines: 2,
            onChanged: (v) => widget.onChanged(notas: v),
          ),
        ],
      ),
    );
  }
}
