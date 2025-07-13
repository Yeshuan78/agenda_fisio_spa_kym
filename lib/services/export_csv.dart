// services/export_csv.dart
import 'dart:convert';
import 'dart:html' as html;

class ExportCSV {
  static void generarArchivo(List<Map<String, dynamic>> datos,
      {required String nombreArchivo}) {
    if (datos.isEmpty) return;

    final headers = datos.first.keys.toList();
    final rows = datos.map((d) => headers.map((h) => d[h]).toList()).toList();

    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (var row in rows) {
      csv.writeln(row.map((e) => '"${e ?? ''}"').join(','));
    }

    final bytes = utf8.encode(csv.toString());
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "$nombreArchivo.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
