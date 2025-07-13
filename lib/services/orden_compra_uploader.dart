import 'dart:typed_data';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/services/factura_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class OrdenCompraUploader {
  static Future<void> subirOrdenCompra({
    required Uint8List archivo,
    required String empresaId,
    required String ordenCompra,
  }) async {
    try {
      final String idFactura = const Uuid().v4();
      final String storagePath = 'ordenes_compra/$idFactura.pdf';
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = await ref.putData(archivo);
      final String pdfUrl = await uploadTask.ref.getDownloadURL();

      final factura = FacturaModel(
        id: idFactura,
        empresaId: empresaId,
        ordenCompra: ordenCompra,
        monto: 0.0,
        numeroFactura: '',
        fechaIngreso: DateTime.now(),
        condicionesPagoDias: 0,
        fechaPagoEstimado: DateTime.now(),
        fechaPagoReal: null,
        estadoPago: 'Pendiente',
        complementoEnviado: false,
        descripcionServicios: '',
        pdfUrl: pdfUrl,
        xmlUrl: '',
        uuid: null,
        usoCFDI: null,
        metodoPago: null,
        formaPago: null,
        rfcReceptor: null,
      );

      await FacturaService().crearFactura(factura);
      print('[OrdenCompraUploader] Orden subida y registrada: \$idFactura');
    } catch (e) {
      print('[OrdenCompraUploader] Error: \$e');
      rethrow;
    }
  }
}
