// [evento_basic_info_section.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/evento_basic_info_section.dart
// 🎯 OBJETIVO: Sección de información básica manteniendo lógica exacta del original

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/empresa_model.dart';

class EventoBasicInfoSection extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final EmpresaModel? empresaSeleccionada;
  final bool usarDireccionEmpresa;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> empresas;
  final Function(EmpresaModel?) onEmpresaChanged;
  final Function(bool?) onToggleDireccionEmpresa;

  const EventoBasicInfoSection({
    super.key,
    required this.nombreController,
    required this.direccionController,
    required this.empresaSeleccionada,
    required this.usarDireccionEmpresa,
    required this.empresas,
    required this.onEmpresaChanged,
    required this.onToggleDireccionEmpresa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de sección
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kBrandPurple, kAccentBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Básica',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Datos principales del evento',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Campo nombre del evento
          _buildPremiumTextField(
            label: 'Nombre del Evento',
            controller: nombreController,
            icon: Icons.event,
            color: kBrandPurple,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre del evento es requerido';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // ✅ MANTENER DropdownButtonFormField EXACTO del archivo original línea 170
          Container(
            decoration: BoxDecoration(
              color: kAccentBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kAccentBlue.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonFormField<String>(
              value: empresaSeleccionada?.empresaId,
              decoration: InputDecoration(
                labelText: 'Empresa',
                prefixIcon: Icon(Icons.domain, color: kAccentBlue, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                labelStyle: TextStyle(
                  color: kAccentBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              items: empresas
                  .map((emp) => DropdownMenuItem(
                        value: emp.id,
                        child: Text(
                          emp.data().containsKey('nombre')
                              ? emp['nombre']
                              : emp.id,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                // ✅ COPIAR EXACTO lógica líneas 180-190 del archivo original
                if (value != null) {
                  final empresa = empresas.firstWhere((e) => e.id == value);
                  final empresaModel = EmpresaModel.fromMap(empresa.data(), empresa.id);
                  onEmpresaChanged(empresaModel);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona una empresa';
                }
                return null;
              },
              dropdownColor: Colors.white,
              menuMaxHeight: 300,
            ),
          ),

          const SizedBox(height: 20),

          // ✅ MANTENER lógica de dirección con checkbox EXACTA líneas 200-230
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: usarDireccionEmpresa 
                        ? Colors.grey.shade100 
                        : kAccentGreen.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: usarDireccionEmpresa 
                          ? Colors.grey.shade300 
                          : kAccentGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextFormField(
                    controller: direccionController,
                    enabled: !usarDireccionEmpresa,
                    decoration: InputDecoration(
                      labelText: 'Dirección del evento',
                      prefixIcon: Icon(
                        Icons.location_on, 
                        color: usarDireccionEmpresa 
                            ? Colors.grey.shade400 
                            : kAccentGreen,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      labelStyle: TextStyle(
                        color: usarDireccionEmpresa 
                            ? Colors.grey.shade500 
                            : kAccentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: usarDireccionEmpresa 
                          ? Colors.grey.shade600 
                          : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderColor.withValues(alpha: 0.2)),
                  ),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Usar dirección de la empresa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: usarDireccionEmpresa,
                    onChanged: onToggleDireccionEmpresa,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: kAccentGreen,
                    checkColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        validator: validator,
      ),
    );
  }
}
  