import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessfuel/model/client_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

// Only for Flutter Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PdfGeneration {
  /// Generates and sends a PDF receipt to WhatsApp
  Future<void> generateAndSendReceipt(
    ClientModel client, {
    void Function(String url)? onPdfUrlGenerated,
  }) async {
    final pdf = pw.Document();

    // 1️⃣ Create PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Fitness Fuel Gym - Receipt',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Client Name: ${client.name}'),
              pw.Text('Contact: ${client.contact}'),
              pw.Text('Plan: ${client.planType}'),
              pw.Text('Start Date: ${client.startDate}'),
              pw.Text('End Date: ${client.endDate}'),
              pw.Text('Total Amount: ₹${client.totalAmount}'),
              pw.Text('Paid: ₹${client.paidAmount}'),
              pw.Text('Remaining: ₹${client.remainingAmount}'),
              pw.Text('Payment Date: ${client.paymentDate}'),
              pw.Text('Payment Status: ${client.paymentStatus}'),
            ],
          );
        },
      ),
    );

    // 2️⃣ Save PDF to bytes
    final bytes = await pdf.save();
    final safeName = client.name.replaceAll(RegExp(r'[^\w\s]+'), '');
    final fileName = 'Receipt_${safeName}_${client.id}.pdf';

    // 3️⃣ Upload to Firebase Storage
    final ref = FirebaseStorage.instance.ref().child('clientPdf/$fileName');
    final uploadTask = await ref.putData(bytes);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Optional: pass back the PDF link
    if (onPdfUrlGenerated != null) {
      onPdfUrlGenerated(downloadUrl);
    }

    // 4️⃣ Compose Professional WhatsApp Message
    final message =
        '''
Dear ${client.name},

Thanks for subscribing to the '${client.planType}' plan.
Your total billing amount is ₹${client.totalAmount}.

You can download your receipt here:
$downloadUrl

Feel free to contact us in case of any queries.''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappNumber = client.whatsapp
        .replaceAll('+91', '')
        .replaceAll(RegExp(r'\s+'), '');
    final waUrl = Uri.parse(
      "https://wa.me/91$whatsappNumber?text=$encodedMessage",
    );

    // 5️⃣ Open WhatsApp based on platform
    if (kIsWeb) {
      html.window.open(waUrl.toString(), '_blank'); // Web: WhatsApp Web
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        print("⚠️ Could not launch WhatsApp.");
      }
    } else {
      print("❌ Unsupported platform for WhatsApp integration.");
    }
  }
}
