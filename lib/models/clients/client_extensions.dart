// [client_extensions.dart] - EXTENSIONES Y HELPERS - ✅ CON SERVICEMODE
// 📁 Ubicación: /lib/models/clients/client_extensions.dart
// 🎯 OBJETIVO: Extensiones para listas de clientes con filtros y serviceModes

import 'client_model.dart';
import 'client_enums.dart';
import 'client_filter_model.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

/// 📊 EXTENSIONES PARA LISTAS DE CLIENTES - ✅ CON SERVICEMODE
extension ClientModelListExtensions on List<ClientModel> {
  List<ClientModel> get activeClients => where((c) => c.isActive).toList();

  List<ClientModel> get vipClients => where((c) => c.isVIP).toList();

  List<ClientModel> get corporateClients =>
      where((c) => c.isCorporate).toList();

  List<ClientModel> get newClients => where((c) => c.isNew).toList();

  // ✅ NUEVOS FILTROS POR SERVICEMODE
  List<ClientModel> get homeServiceClients =>
      where((c) => c.isHomeService).toList();

  List<ClientModel> get inSiteServiceClients =>
      where((c) => c.isInSiteService).toList();

  List<ClientModel> get hybridServiceClients =>
      where((c) => c.isHybridService).toList();

  List<ClientModel> filterByStatus(ClientStatus status) =>
      where((c) => c.status == status).toList();

  List<ClientModel> filterByTag(String tag) =>
      where((c) => c.hasTag(tag)).toList();

  List<ClientModel> filterByAlcaldia(String alcaldia) =>
      where((c) => c.addressInfo.alcaldia == alcaldia).toList();

  // ✅ NUEVO: FILTRAR POR SERVICEMODE
  List<ClientModel> filterByServiceMode(ClientServiceMode mode) =>
      where((c) => c.serviceMode == mode).toList();

  List<ClientModel> search(String query) =>
      where((c) => c.matchesSearchQuery(query)).toList();

  List<ClientModel> filterByCriteria(ClientFilterCriteria criteria) =>
      where((c) => c.matchesFilter(criteria)).toList();

  Map<ClientStatus, int> get countByStatus {
    final counts = <ClientStatus, int>{};
    for (final client in this) {
      counts[client.status] = (counts[client.status] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get countByTag {
    final counts = <String, int>{};
    for (final client in this) {
      for (final tag in client.tags) {
        counts[tag.label] = (counts[tag.label] ?? 0) + 1;
      }
    }
    return counts;
  }

  Map<String, int> get countByAlcaldia {
    final counts = <String, int>{};
    for (final client in this) {
      final alcaldia = client.addressInfo.alcaldia;
      if (alcaldia.isNotEmpty) {
        counts[alcaldia] = (counts[alcaldia] ?? 0) + 1;
      }
    }
    return counts;
  }

  // ✅ NUEVO: CONTEO POR SERVICEMODE
  Map<ClientServiceMode, int> get countByServiceMode {
    final counts = <ClientServiceMode, int>{};
    for (final client in this) {
      counts[client.serviceMode] = (counts[client.serviceMode] ?? 0) + 1;
    }
    return counts;
  }

  double get averageSatisfaction {
    if (isEmpty) return 0.0;
    final total = fold(0.0, (sum, c) => sum + c.metrics.satisfactionScore);
    return total / length;
  }

  double get totalRevenue {
    return fold(0.0, (sum, c) => sum + c.metrics.totalRevenue);
  }

  int get totalAppointments {
    return fold(0, (sum, c) => sum + c.metrics.appointmentsCount);
  }

  List<String> get allTags {
    final tags = <String>{};
    for (final client in this) {
      tags.addAll(client.tags.map((t) => t.label));
    }
    return tags.toList();
  }

  List<String> get allAlcaldias {
    final alcaldias = <String>{};
    for (final client in this) {
      if (client.addressInfo.alcaldia.isNotEmpty) {
        alcaldias.add(client.addressInfo.alcaldia);
      }
    }
    return alcaldias.toList();
  }

  // Ordenamiento
  List<ClientModel> sortByName() {
    final sorted = List<ClientModel>.from(this);
    sorted.sort((a, b) => a.fullName.compareTo(b.fullName));
    return sorted;
  }

  List<ClientModel> sortByCreatedDate() {
    final sorted = List<ClientModel>.from(this);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<ClientModel> sortByRevenue() {
    final sorted = List<ClientModel>.from(this);
    sorted.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return sorted;
  }

  List<ClientModel> sortByAppointments() {
    final sorted = List<ClientModel>.from(this);
    sorted.sort((a, b) => b.appointmentsCount.compareTo(a.appointmentsCount));
    return sorted;
  }

  List<ClientModel> sortBySatisfaction() {
    final sorted = List<ClientModel>.from(this);
    sorted.sort((a, b) => b.avgSatisfaction.compareTo(a.avgSatisfaction));
    return sorted;
  }
}
