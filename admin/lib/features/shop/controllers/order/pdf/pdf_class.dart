// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

// class PDF {
//   static Future<void> generatePDF() async {
//     final PdfDocument document = PdfDocument();
//     final PdfPage page = document.pages.add();
//     final PdfGraphics graphics = page.graphics;
//     final Size pageSize = page.getClientSize();
//     final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 14);

//     const String title = 'Invoice';
//     const String invoiceNumber = 'Invoice Number: 123456';
//     final String date = 'Date: ${DateTime.now().toString()}';

//     graphics.drawString(
//       title,
//       PdfStandardFont(PdfFontFamily.helvetica, 25, style: PdfFontStyle.bold),
//       brush: PdfSolidBrush(PdfColor(0, 0, 0)),
//       bounds: Rect.fromLTWH(0, 10, pageSize.width, pageSize.height),
//       format: PdfStringFormat(alignment: PdfTextAlignment.center),
//     );

//     graphics.drawString(
//       invoiceNumber,
//       font,
//       brush: PdfSolidBrush(PdfColor(0, 0, 0)),
//       bounds: Rect.fromLTWH(10, 70, pageSize.width / 2 - 20, pageSize.height),
//     );

//     graphics.drawString(
//       date,
//       font,
//       brush: PdfSolidBrush(PdfColor(0, 0, 0)),
//       bounds: Rect.fromLTWH(pageSize.width / 2 + 40, 70,
//           pageSize.width / 2 - 20, pageSize.height),
//     );

//     final PdfGrid grid = PdfGrid();
//     grid.columns.add(count: 3);
//     final PdfGridRow header = grid.headers.add(1)[0];
//     header.cells[0].value = 'Item';
//     header.cells[1].value = 'Quantity';
//     header.cells[2].value = 'Price';

//     final List<String> items = ['Item A', 'Item B', 'Item C'];
//     final List<int> quantities = [2, 3, 1];
//     final List<double> prices = [10.0, 20.0, 15.0];

//     for (int i = 0; i < items.length; i++) {
//       final PdfGridRow row = grid.rows.add();
//       row.cells[0].value = items[i];
//       row.cells[1].value = quantities[i];
//       row.cells[2].value = prices[i];
//       grid.draw(
//         bounds: Rect.fromLTWH(10, 100, pageSize.width - 20, pageSize.height),
//         graphics: graphics,
//         format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
//       );
//     }

//     final List<int> bytes = await document.save();
//     // final Directory? directory = await getExternalStorageDirectory();
//     // final String path = '${directory!.path}/example.pdf';
//     // final File file = File(path);

//     // await file.writeAsBytes(bytes);

//     // Open the PDF file
//     // await Share.shareFiles([path], text: 'Check out the PDF file!');
//   }
// }
