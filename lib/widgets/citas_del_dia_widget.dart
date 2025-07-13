import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CitasDelDiaWidget extends StatelessWidget {
  final DateTime selectedDay;

  const CitasDelDiaWidget({Key? key, required this.selectedDay})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Se define el inicio y el fin del día seleccionado.
    final startOfDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where("date", isGreaterThanOrEqualTo: startOfDay)
          .where("date", isLessThan: endOfDay)
          .orderBy("date", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No hay citas para este día."));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final clientName = data["clientName"] ?? "Sin Cliente";
            final professionalName =
                data["professionalName"] ?? "Sin Profesional";
            final status = data["status"] ?? "Desconocido";
            // Se asume que el campo "date" se guarda como Timestamp
            final Timestamp? timestamp = data["date"];
            final timeLabel = timestamp != null
                ? DateFormat("HH:mm").format(timestamp.toDate())
                : "";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text("$clientName - $professionalName"),
                subtitle: Text("Estado: $status \nHora: $timeLabel"),
              ),
            );
          },
        );
      },
    );
  }
}
