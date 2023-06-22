import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../main.dart';

pw.Page buildCert(Runner r, int place, String picLeft, String picRight,
    String runName, String runPlace) {
  final imageLeft = pw.MemoryImage(
    File(picLeft).readAsBytesSync(),
  );
  final imageRight = pw.MemoryImage(
    File(picRight).readAsBytesSync(),
  );

  var standardStyle = const pw.TextStyle(fontSize: 16);

  var textC =
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
    pw.Text('Urkunde',
        style: pw.TextStyle(
            fontSize: 46,
            fontWeight: pw.FontWeight.bold,
            fontStyle: pw.FontStyle.italic)),
    pw.SizedBox(height: 10),
    pw.Text(runName,
        style: pw.TextStyle(
            fontSize: 36,
            fontWeight: pw.FontWeight.bold,
            fontStyle: pw.FontStyle.italic)),
    pw.Text('${DateTime.now().year}',
        style: pw.TextStyle(
            fontSize: 36,
            fontWeight: pw.FontWeight.bold,
            fontStyle: pw.FontStyle.italic))
  ]);
  var firstRow = pw.Row(children: [
    pw.Image(imageLeft, height: 120),
    pw.SizedBox(width: 10),
    textC,
    pw.SizedBox(width: 10),
    pw.Image(imageRight, height: 120)
  ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween);

  var attributeNames = pw.Column(
      children: [
        pw.Text('Strecke: ', style: standardStyle),
        pw.SizedBox(height: 10),
        pw.Text('Altersklasse: ', style: standardStyle),
        pw.SizedBox(height: 10),
        pw.Text('Sportgruppe: ', style: standardStyle),
        pw.SizedBox(height: 10),
        pw.Text('Startnummer: ', style: standardStyle),
        pw.SizedBox(height: 10),
        pw.Text('Zeit: ', style: standardStyle)
      ],
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.end);
  var attributes = pw.Column(children: [
    pw.Text(r.runLength, style: standardStyle),
    pw.SizedBox(height: 10),
    pw.Text(r.ageGroup, style: standardStyle),
    pw.SizedBox(height: 10),
    pw.Text(r.group == '' ? 'keine' : r.group, style: standardStyle),
    pw.SizedBox(height: 10),
    pw.Text(r.startNumber, style: standardStyle),
    pw.SizedBox(height: 10),
    pw.Text(r.formattedTime!, style: standardStyle)
  ], crossAxisAlignment: pw.CrossAxisAlignment.start);
  var dateNow = DateTime.now();
  return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              firstRow,
              pw.SizedBox(height: 80),
              pw.Text('${r.givenName} ${r.familyName}',
                  style: const pw.TextStyle(fontSize: 30)),
              pw.SizedBox(height: 60),
              pw.Row(
                  children: [attributeNames, attributes],
                  mainAxisAlignment: pw.MainAxisAlignment.center),
              pw.SizedBox(height: 50),
              pw.Text('$place. Platz', style: const pw.TextStyle(fontSize: 80)),
              pw.SizedBox(height: 60),
              pw.Row(children: [
                pw.Text('Leiter der Veranstaltung'),
                pw.Text(
                    '$runPlace, ${dateNow.day.toString().padLeft(2, '0')}.${dateNow.month.toString().padLeft(2, '0')}.${dateNow.year}')
              ], mainAxisAlignment: pw.MainAxisAlignment.spaceBetween)
            ]);
      });
}
