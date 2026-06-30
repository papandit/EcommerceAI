// ignore_for_file: deprecated_member_use

import 'package:EcommerceApp/model/ordermodel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generates a tax invoice PDF from a real order and triggers the browser's
/// save/print dialog (download) — no dummy data, no bundled-asset dependency.
class OrderInvoiceApi {
  static double _n(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;

  static Future<void> downloadInvoice(FirebaseOrderModel order) async {
    final pdf = pw.Document();
    final df = DateFormat('dd MMM yyyy');

    const accent = PdfColor.fromInt(0xFFC04A66);
    const ink = PdfColor.fromInt(0xFF2A1E26);
    const grey = PdfColor.fromInt(0xFF8B8089);
    const line = PdfColor.fromInt(0xFFEFE3E8);

    final items = order.items ?? [];
    final tableData = items.map((it) {
      final price = _n(it.price);
      final qty = (it.quantity ?? 1);
      return [
        (it.title ?? '').toString(),
        (it.size ?? '-').toString(),
        '$qty',
        'Rs ${price.toStringAsFixed(0)}',
        'Rs ${(price * qty).toStringAsFixed(0)}',
      ];
    }).toList();

    final subtotal = _n(order.subtotal);
    final shipping = _n(order.shippingCost);
    final tax = _n(order.taxCost);
    final total = _n(order.totalAmount);

    pw.Widget totalRow(String label, double value,
        {bool bold = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    color: bold ? ink : grey,
                    fontSize: bold ? 12 : 10.5,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            pw.Text('Rs ${value.toStringAsFixed(0)}',
                style: pw.TextStyle(
                    color: bold ? accent : ink,
                    fontSize: bold ? 12 : 10.5,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Click & Collect',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: accent)),
                  pw.Text('Tax Invoice',
                      style: const pw.TextStyle(fontSize: 12, color: grey)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Order #${order.Orderid ?? ''}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, color: ink)),
                  pw.Text(
                      order.orderDate != null ? df.format(order.orderDate!) : '',
                      style: const pw.TextStyle(color: grey, fontSize: 10.5)),
                  pw.Text('Payment: ${order.paymentMethod ?? ''}',
                      style: const pw.TextStyle(color: grey, fontSize: 10.5)),
                  pw.Text(
                      'Status: ${(order.status ?? '').replaceAll('OrderStatus.', '')}',
                      style: const pw.TextStyle(color: grey, fontSize: 10.5)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(color: line),
          pw.SizedBox(height: 6),
          if ((order.email ?? '').isNotEmpty)
            pw.Text('Billed to: ${order.email}',
                style: const pw.TextStyle(color: ink, fontSize: 11)),
          pw.SizedBox(height: 14),
          pw.Table.fromTextArray(
            headers: ['Item', 'Size', 'Qty', 'Price', 'Total'],
            data: tableData,
            border: null,
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10.5),
            headerDecoration: const pw.BoxDecoration(color: accent),
            cellHeight: 26,
            cellStyle: const pw.TextStyle(color: ink, fontSize: 10),
            rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: line))),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 230,
              child: pw.Column(
                children: [
                  totalRow('Subtotal', subtotal),
                  totalRow('Shipping', shipping),
                  totalRow('GST / Tax', tax),
                  pw.Divider(color: line),
                  totalRow('Total Paid', total, bold: true),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 28),
          pw.Text('Thank you for shopping with us!',
              style: pw.TextStyle(color: accent, fontWeight: pw.FontWeight.bold)),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text('Click & Collect — Fashion for every her',
              style: const pw.TextStyle(color: grey, fontSize: 9)),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Invoice_${order.Orderid ?? 'order'}.pdf',
    );
  }
}
