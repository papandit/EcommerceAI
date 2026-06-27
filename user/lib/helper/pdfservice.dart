import 'dart:convert';
import 'dart:ui';
import 'package:EcommerceApp/model/ordermodel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:universal_html/html.dart';

class PdfService {
  Future<void> printCustomersPdf(FirebaseOrderModel data) async {
    //Create a new PDF document
    PdfDocument document = PdfDocument();
    PdfGrid grid = PdfGrid();

    //Define number of columns in table
    grid.columns.add(count: 5);
    //Add header to the grid
    grid.headers.add(1);
    //Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = "formattedDeliveryDate";
    header.cells[1].value = "deliveryDate";
    header.cells[2].value = "email";
    header.cells[3].value = "orderDate";
    header.cells[4].value = "totalAmount";
    //Add header style
    header.style = PdfGridCellStyle(
      backgroundBrush: PdfBrushes.lightGray,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 12),
    );

    PdfGridRow row = grid.rows.add();
    row.cells[0].value = data.createdate;
    row.cells[1].value = data.deliveryDate;
    row.cells[2].value = data.email;
    row.cells[3].value = data.orderDate;
    row.cells[4].value = data.totalAmount;

    // Add rows to grid
    // for (final customer in data ) {
    //   PdfGridRow row = grid.rows.add();
    //   row.cells[0].value = customer.formattedDeliveryDate;
    //   row.cells[1].value = customer.deliveryDate;
    //   row.cells[2].value = customer.email;
    //   row.cells[3].value = customer.orderDate;
    //   row.cells[4].value = customer.totalAmount;
    // }
    //Add rows style
    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 10, right: 3, top: 4, bottom: 5),
      backgroundBrush: PdfBrushes.white,
      textBrush: PdfBrushes.black,
      font: PdfStandardFont(PdfFontFamily.timesRoman, 8),
    );

    //Draw the grid
    grid.draw(
        page: document.pages.add(), bounds: const Rect.fromLTWH(0, 0, 0, 0));
    List<int> bytes = await document.save();

    //Download document
    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "invoice.pdf")
      ..click();

    //Dispose the document
    document.dispose();
  }
}
