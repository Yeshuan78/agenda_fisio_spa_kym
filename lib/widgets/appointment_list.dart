// lib/widgets/appointment_list.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'appointment_card.dart';

class AppointmentList extends StatelessWidget {
  final String defaultEstado;
  const AppointmentList({Key? key, required this.defaultEstado})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No hay citas disponibles."));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return AppointmentCard(appointment: docs[index]);
          },
        );
      },
    );
  }
}
