import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessfuel/model/client_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// Only for Flutter Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if WhatsApp is enabled later

class PdfGeneration {
  final pdf = pw.Document();

  /// Generates PDF, uploads to Firebase Storage, and returns the downloadUrl
  Future<String> generateAndSendReceipt(ClientModel client) async {
    // 1️⃣ Generate PDF content
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 🔷 Gym Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Fitness Fuel Gym',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepOrange,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Nashik, Maharashtra, India',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Phone: 9307280042   |   Email: fitnessfuel@gmail.com',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              pw.Divider(thickness: 1.2),
              pw.SizedBox(height: 10),

              // 🔷 Receipt Title
              pw.Center(
                child: pw.Text(
                  'RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // 🔷 Client Info + Receipt Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Client Name: ${client.name}'),
                      pw.Text('Contact No.: ${client.contact}'),
                      pw.Text('Membership: ${client.planType}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Receipt Date: ${client.paymentDate}'),
                      pw.Text('Status: ${client.paymentStatus}'),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // 🔷 Membership Details Table
              pw.Table.fromTextArray(
                headers: [
                  'Start Date',
                  'End Date',
                  'Total (₹)',
                  'Paid (₹)',
                  'Balance (₹)',
                ],
                data: [
                  [
                    client.startDate,
                    client.endDate,
                    '${client.totalAmount}',
                    '${client.paidAmount}',
                    '${client.remainingAmount}',
                  ],
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey700),
                cellAlignment: pw.Alignment.center,
                cellPadding: const pw.EdgeInsets.all(6),
                border: pw.TableBorder.all(width: 0.5),
              ),

              pw.SizedBox(height: 20),

              // 🔷 Summary Block
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Amount: ₹${client.totalAmount}'),
                      pw.Text('Paid: ₹${client.paidAmount}'),
                      pw.Text('Balance: ₹${client.remainingAmount}'),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              // 🔷 Terms & Conditions
              pw.Text(
                'Terms & Conditions:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Bullet(
                text: 'Membership rates are subject to change by the gym.',
              ),
              pw.Bullet(text: 'Fees once paid are non-refundable.'),
              pw.SizedBox(height: 30),

              // 🔷 Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(''),
                  pw.Column(
                    children: [
                      pw.Text('_______________________'),
                      pw.Text('Authorized Signature'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // 2️⃣ Save PDF and upload to Firebase
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final safeName = client.name.replaceAll(RegExp(r'[^\w\s]+'), '');
    final fileName = 'Receipt_${safeName}_${client.id}.pdf';
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', '$safeName.pdf')
      ..click();
    Future.delayed(Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });

    final ref = FirebaseStorage.instance.ref().child('clientPdf/$fileName');
    final uploadTask = await ref.putData(bytes);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;

    // 🔒 Commented WhatsApp code (can be re-enabled later)
    /*
    final message = '''
    Dear ${client.name},

    Thanks for subscribing to the '${client.planType}' plan.
    Your total billing amount is ₹${client.totalAmount}.

    You can download your receipt here:
    $downloadUrl

    Feel free to contact us in case of any queries.''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappNumber = client.whatsapp.replaceAll('+91', '').replaceAll(RegExp(r'\s+'), '');
    final waUrl = Uri.parse("https://wa.me/91$whatsappNumber?text=$encodedMessage");

    if (kIsWeb) {
      html.window.open(waUrl.toString(), '_blank');
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        print("⚠️ Could not launch WhatsApp.");
      }
    } else {
      print("❌ Unsupported platform for WhatsApp integration.");
    }
    */
  }
}
