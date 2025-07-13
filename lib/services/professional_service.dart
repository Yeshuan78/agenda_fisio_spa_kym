import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/professional_model.dart';

class ProfessionalService {
  final String _baseUrl = 'https://api.fisiospa.com';

  Future<List<ProfessionalModel>> getAllProfessionals() async {
    final response = await http.get(Uri.parse('$_baseUrl/professionals'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => ProfessionalModel.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener profesionales');
    }
  }

  Future<ProfessionalModel> getProfessionalById(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/professionals/$id'));
    if (response.statusCode == 200) {
      return ProfessionalModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al obtener profesional');
    }
  }

  Future<void> createProfessional(ProfessionalModel professional) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/professionals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(professional.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear profesional');
    }
  }

  Future<void> updateProfessional(ProfessionalModel professional) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/professionals/${professional.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(professional.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar profesional');
    }
  }

  /// ✅ FIX aplicado: ahora elimina en Firestore, no por API REST
  Future<void> deleteProfessional(String id) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('profesionales').doc(id).delete();
    await firestore.collection('calendarios').doc(id).delete();
  }
}
