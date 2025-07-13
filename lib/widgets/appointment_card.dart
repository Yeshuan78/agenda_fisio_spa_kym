// lib/widgets/appointment_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class AppointmentCard extends StatefulWidget {
  final QueryDocumentSnapshot appointment;
  const AppointmentCard({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  // Lista de 11 estados predefinidos para la cita
  final List<String> estadosCita = [
    "Reservando",
    "Cita creada",
    "Pago pendiente",
    "Cita confirmada",
    "Cita realizada",
    "Cancelada",
    "Reagendando cita",
    "No llego cliente",
    "Rechazada",
    "Profesional en camino",
    "Profesional en sitio",
  ];

  @override
  Widget build(BuildContext context) {
    // Extraemos la información de la cita
    final data = widget.appointment.data() as Map<String, dynamic>;
    final clientName = data['clientName'] ?? "Cliente sin nombre";
    final professionalName = data['professionalName'] ?? "Profesional";
    final currentStatus = data['status'] ?? "Desconocido";
    final serviceName = data['serviceName'] ?? "Sin servicio";
    final date = data['date'] ?? "";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kBrandPurple.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        title: Text("$clientName - $professionalName"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Servicio: $serviceName"),
            Text("Fecha: $date"),
            Text("Estado: $currentStatus"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: kBrandPurple),
          tooltip: "Editar Estado",
          onPressed: () => _editStatusDialog(currentStatus),
        ),
      ),
    );
  }

  void _editStatusDialog(String currentStatus) {
    // Valor seleccionado (preseleccionado con el estado actual)
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Editar Estado de la Cita"),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: "Seleccione un nuevo estado",
              border: OutlineInputBorder(),
            ),
            value: selectedStatus,
            items: estadosCita.map((String estado) {
              return DropdownMenuItem<String>(
                value: estado,
                child: Text(estado),
              );
            }).toList(),
            onChanged: (valor) {
              if (valor != null) {
                selectedStatus = valor;
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Actualizamos el estado en Firestore
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(widget.appointment.id)
                    .update({'status': selectedStatus});
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Estado actualizado")),
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
