// [Archivo: lib/widgets/navigation/sidebar_firestore_service.dart]
// 🔥 SERVICIO DE PERSISTENCIA PARA CONFIGURACION DEL SIDEBAR - SIN CARACTERES ILEGALES

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SidebarFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'sidebar_preferences';
  static const String _userId = 'default_user'; // TODO: Integrar con auth real

  /// 📋 Cargar todas las preferencias del usuario
  static Future<Map<String, dynamic>> cargarPreferencias() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'vista': data['vista'] ?? 'estandar',
          'favoritos': List<String>.from(data['favoritos'] ?? []),
          'ordenPersonalizado':
              List<String>.from(data['ordenPersonalizado'] ?? []),
          'estadoGrupos': Map<String, bool>.from(data['estadoGrupos'] ?? {}),
          'isCompactMode': data['isCompactMode'] ?? false,
          'theme': data['theme'] ?? 'light',
          'lastUpdated': data['lastUpdated'],
        };
      }

      // Valores por defecto si no existe documento
      return {
        'vista': 'estandar',
        'favoritos': <String>[],
        'ordenPersonalizado': <String>[],
        'estadoGrupos': <String, bool>{},
        'isCompactMode': false,
        'theme': 'light',
        'lastUpdated': null,
      };
    } catch (e) {
      debugPrint('Error cargando preferencias del sidebar: $e');
      return {
        'vista': 'estandar',
        'favoritos': <String>[],
        'ordenPersonalizado': <String>[],
        'estadoGrupos': <String, bool>{},
        'isCompactMode': false,
        'theme': 'light',
        'lastUpdated': null,
      };
    }
  }

  /// 🎯 Guardar vista actual (estandar, favoritos, personalizada)
  static Future<void> guardarVista(String vista) async {
    try {
      await _firestore.collection(_collection).doc(_userId).set({
        'vista': vista,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Vista guardada: $vista');
    } catch (e) {
      debugPrint('Error guardando vista: $e');
    }
  }

  /// ⭐ Guardar lista de favoritos
  static Future<void> guardarFavoritos(List<String> favoritos) async {
    try {
      await _firestore.collection(_collection).doc(_userId).set({
        'favoritos': favoritos,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Favoritos guardados: ${favoritos.length} items');
    } catch (e) {
      debugPrint('Error guardando favoritos: $e');
    }
  }

  /// 📂 Guardar estado de expansion de un grupo
  static Future<void> guardarEstadoGrupo(String grupo, bool estado) async {
    try {
      await _firestore.collection(_collection).doc(_userId).set({
        'estadoGrupos.$grupo': estado,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Estado grupo guardado: $grupo = $estado');
    } catch (e) {
      debugPrint('Error guardando estado grupo: $e');
    }
  }

  /// 🔄 Guardar orden personalizado de elementos
  static Future<void> guardarOrden(List<String> orden) async {
    try {
      await _firestore.collection(_collection).doc(_userId).set({
        'ordenPersonalizado': orden,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Orden personalizado guardado: ${orden.length} items');
    } catch (e) {
      debugPrint('Error guardando orden: $e');
    }
  }

  /// 📱 Guardar modo compacto
  static Future<void> guardarModoCompacto(bool isCompact) async {
    try {
      await _firestore.collection(_collection).doc(_userId).set({
        'isCompactMode': isCompact,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Modo compacto guardado: $isCompact');
    } catch (e) {
      debugPrint('Error guardando modo compacto: $e');
    }
  }

  /// 🎨 Guardar tema (light/dark)
  static Future<void> guardarTema(String theme) async {
    try {
      await _firestore.collection(_collection).doc(_userId).set({
        'theme': theme,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Tema guardado: $theme');
    } catch (e) {
      debugPrint('Error guardando tema: $e');
    }
  }

  /// 🧹 Limpiar todas las preferencias (reset)
  static Future<void> resetearPreferencias() async {
    try {
      await _firestore.collection(_collection).doc(_userId).delete();

      debugPrint('Preferencias reseteadas');
    } catch (e) {
      debugPrint('Error reseteando preferencias: $e');
    }
  }

  /// 📊 Obtener estadisticas de uso
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_userId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final favoritos = List<String>.from(data['favoritos'] ?? []);
        final ordenPersonalizado =
            List<String>.from(data['ordenPersonalizado'] ?? []);
        final estadoGrupos = Map<String, bool>.from(data['estadoGrupos'] ?? {});

        return {
          'totalFavoritos': favoritos.length,
          'tieneOrdenPersonalizado': ordenPersonalizado.isNotEmpty,
          'gruposExpandidos': estadoGrupos.values.where((v) => v).length,
          'gruposColapsados': estadoGrupos.values.where((v) => !v).length,
          'vista': data['vista'] ?? 'estandar',
          'modoCompacto': data['isCompactMode'] ?? false,
          'ultimaActualizacion': data['lastUpdated'],
        };
      }

      return {
        'totalFavoritos': 0,
        'tieneOrdenPersonalizado': false,
        'gruposExpandidos': 0,
        'gruposColapsados': 0,
        'vista': 'estandar',
        'modoCompacto': false,
        'ultimaActualizacion': null,
      };
    } catch (e) {
      debugPrint('Error obteniendo estadisticas: $e');
      return {};
    }
  }

  /// 🔄 Stream para escuchar cambios en tiempo real
  static Stream<Map<String, dynamic>> streamPreferencias() {
    return _firestore
        .collection(_collection)
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        return {
          'vista': data['vista'] ?? 'estandar',
          'favoritos': List<String>.from(data['favoritos'] ?? []),
          'ordenPersonalizado':
              List<String>.from(data['ordenPersonalizado'] ?? []),
          'estadoGrupos': Map<String, bool>.from(data['estadoGrupos'] ?? {}),
          'isCompactMode': data['isCompactMode'] ?? false,
          'theme': data['theme'] ?? 'light',
          'lastUpdated': data['lastUpdated'],
        };
      }

      return {
        'vista': 'estandar',
        'favoritos': <String>[],
        'ordenPersonalizado': <String>[],
        'estadoGrupos': <String, bool>{},
        'isCompactMode': false,
        'theme': 'light',
        'lastUpdated': null,
      };
    });
  }

  /// 🔍 Buscar historial de navegacion (para sugerencias)
  static Future<List<String>> obtenerRutasRecientes() async {
    try {
      final collection = _firestore
          .collection('navigation_history')
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .limit(10);

      final snapshot = await collection.get();

      return snapshot.docs.map((doc) => doc.data()['route'] as String).toList();
    } catch (e) {
      debugPrint('Error obteniendo rutas recientes: $e');
      return [];
    }
  }

  /// 📝 Registrar navegacion (para analytics)
  static Future<void> registrarNavegacion(String route) async {
    try {
      await _firestore.collection('navigation_history').add({
        'userId': _userId,
        'route': route,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': 'Flutter Web',
      });
    } catch (e) {
      debugPrint('Error registrando navegacion: $e');
    }
  }

  /// 📱 Guardar configuracion de accesibilidad
  static Future<void> guardarAccesibilidad({
    bool? altosContrastes,
    bool? animacionesReducidas,
    double? tamanoTexto,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (altosContrastes != null) {
        updates['accessibility.altosContrastes'] = altosContrastes;
      }
      if (animacionesReducidas != null) {
        updates['accessibility.animacionesReducidas'] = animacionesReducidas;
      }
      if (tamanoTexto != null) {
        updates['accessibility.tamanoTexto'] = tamanoTexto;
      }

      await _firestore
          .collection(_collection)
          .doc(_userId)
          .set(updates, SetOptions(merge: true));

      debugPrint('Configuracion de accesibilidad guardada');
    } catch (e) {
      debugPrint('Error guardando accesibilidad: $e');
    }
  }
}
