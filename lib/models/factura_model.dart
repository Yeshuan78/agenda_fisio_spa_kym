import 'package:cloud_firestore/cloud_firestore.dart';

class FacturaModel {
  final String? uuid;
  final String? usoCFDI;
  final String? metodoPago;
  final String? formaPago;
  final String? rfcReceptor;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? complementoUrl; // ✅ Complemento pago
  final String? ocUrl; // ✅ Orden de compra PDF

  final String id;
  final String empresaId;
  final String ordenCompra;
  final double monto;
  final String numeroFactura;
  final DateTime fechaIngreso;
  final int condicionesPagoDias;
  final DateTime fechaPagoEstimado;
  final DateTime? fechaPagoReal;
  final String estadoPago;
  final bool complementoEnviado;
  final String descripcionServicios;

  FacturaModel({
    required this.id,
    required this.empresaId,
    required this.ordenCompra,
    required this.monto,
    required this.numeroFactura,
    required this.fechaIngreso,
    required this.condicionesPagoDias,
    required this.fechaPagoEstimado,
    this.fechaPagoReal,
    required this.estadoPago,
    required this.complementoEnviado,
    required this.descripcionServicios,
    this.uuid,
    this.usoCFDI,
    this.metodoPago,
    this.formaPago,
    this.rfcReceptor,
    this.pdfUrl,
    this.xmlUrl,
    this.complementoUrl,
    this.ocUrl,
  });

  factory FacturaModel.fromMap(Map<String, dynamic> map, String id) {
    return FacturaModel(
      id: id,
      empresaId: map['empresaId'],
      ordenCompra: map['ordenCompra'],
      monto: (map['monto'] as num).toDouble(),
      numeroFactura: map['numeroFactura'],
      fechaIngreso: (map['fechaIngreso'] as Timestamp).toDate(),
      condicionesPagoDias: map['condicionesPagoDias'],
      fechaPagoEstimado: (map['fechaPagoEstimado'] as Timestamp).toDate(),
      fechaPagoReal: map['fechaPagoReal'] != null
          ? (map['fechaPagoReal'] as Timestamp).toDate()
          : null,
      estadoPago: map['estadoPago'],
      complementoEnviado: map['complementoEnviado'],
      descripcionServicios: map['descripcionServicios'],
      uuid: map['uuid'],
      usoCFDI: map['usoCFDI'],
      metodoPago: map['metodoPago'],
      formaPago: map['formaPago'],
      rfcReceptor: map['rfcReceptor'],
      pdfUrl: map['pdfUrl'],
      xmlUrl: map['xmlUrl'],
      complementoUrl: map['complementoUrl'],
      ocUrl: map['ocUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'usoCFDI': usoCFDI,
      'metodoPago': metodoPago,
      'formaPago': formaPago,
      'rfcReceptor': rfcReceptor,
      'pdfUrl': pdfUrl,
      'xmlUrl': xmlUrl,
      'complementoUrl': complementoUrl,
      'ocUrl': ocUrl,
      'empresaId': empresaId,
      'ordenCompra': ordenCompra,
      'monto': monto,
      'numeroFactura': numeroFactura,
      'fechaIngreso': Timestamp.fromDate(fechaIngreso),
      'condicionesPagoDias': condicionesPagoDias,
      'fechaPagoEstimado': Timestamp.fromDate(fechaPagoEstimado),
      'fechaPagoReal':
          fechaPagoReal != null ? Timestamp.fromDate(fechaPagoReal!) : null,
      'estadoPago': estadoPago,
      'complementoEnviado': complementoEnviado,
      'descripcionServicios': descripcionServicios,
    };
  }
}
