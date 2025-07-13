import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/services/firestore_agenda_service.dart';

class ProfessionalCalendarLoader extends StatelessWidget {
  final String profId;
  // Callback que se invoca cuando la data se ha cargado:
  // onLoaded recibe un Map<String, dynamic> (la data) y la foto (String).
  final void Function(Map<String, dynamic> data, String photo) onLoaded;

  const ProfessionalCalendarLoader({
    super.key,
    required this.profId,
    required this.onLoaded,
  });

  Future<Map<String, dynamic>> _loadCalendarData(String profId) async {
    final FirestoreAgendaService agendaService = FirestoreAgendaService();
    // Carga la data del calendario; en caso de null se asigna un mapa vacío.
    Map<String, dynamic>? calData =
        await agendaService.loadProfesionalCalendar(profId);
    calData ??= {};

    // Carga la foto del profesional; si retorna null se usa cadena vacía.
    final String photo =
        (await agendaService.loadProfesionalPhoto(profId)) ?? "";

    // Carga el documento del profesional (colección 'profesionales') para obtener el nombre.
    final DocumentSnapshot profDoc = await FirebaseFirestore.instance
        .collection('profesionales')
        .doc(profId)
        .get();

    if (profDoc.exists) {
      final Map<String, dynamic> profData =
          (profDoc.data() ?? {}) as Map<String, dynamic>;
      // Se extrae primero "fullName", si no se encuentra, se intenta "profesionalName".
      final String fullName =
          ((profData["fullName"] ?? profData["profesionalName"]) ?? "")
              .toString()
              .trim();
      calData["fullName"] = fullName;
    }

    // Se puede asignar la foto también en el map si se requiere.
    calData["photo"] = photo;

    return calData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadCalendarData(profId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.hasData) {
          // Se usa addPostFrameCallback para llamar al callback onLoaded una sola vez después del build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoaded(snapshot.data!, snapshot.data!["photo"]?.toString() ?? "");
          });
          return Container(); // Se retorna un Container() vacío.
        }
        return Container();
      },
    );
  }
}
