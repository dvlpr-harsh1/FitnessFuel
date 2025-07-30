import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessfuel/model/client_model.dart';
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
// Only for Flutter Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PdfGeneration {
  /// Generates PDF, uploads to Firebase Storage, returns downloadUrl, and triggers download (web)
  Future<String> generateAndSendReceipt(ClientModel client) async {
    final pdf = pw.Document();

    // Format date and time professionally
    String formatDateTime(String isoOrSlashDate) {
      try {
        DateTime dt;
        if (isoOrSlashDate.contains('-')) {
          dt = DateTime.parse(isoOrSlashDate);
        } else if (isoOrSlashDate.contains('/')) {
          final parts = isoOrSlashDate.split('/');
          if (parts.length == 3) {
            dt = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          } else {
            return isoOrSlashDate;
          }
        } else {
          return isoOrSlashDate;
        }
        // Example: 12 Mar 2024, 10:15 AM
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {
        return isoOrSlashDate;
      }
    }

    // Use Unicode for Rupee symbol (works with built-in fonts)
    String rupee(String value) => '\u20B9$value';

    final logoData = await rootBundle.load('assets/images/logo.jpg');
    final logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Stack(
            children: [
              // 🔴 Watermark (diagonal)
              pw.Positioned.fill(
                child: pw.Transform.rotate(
                  angle: 0.7, // Diagonal
                  child: pw.Opacity(
                    opacity: 0.07,
                    child: pw.Center(
                      child: pw.Text(
                        '  FITNESSFUEL',
                        style: pw.TextStyle(
                          fontSize: 70,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔲 Main Content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 🖼️ Logo
                  pw.Center(child: pw.Image(logoImage, height: 80)),
                  pw.SizedBox(height: 8),

                  // 🏢 Centered Gym Info
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'FITNESSFUEL GYM',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          'Datta Shree Apartment, Near ABB Circle, Mahatma Nagar, Nashik',
                          style: pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'Phone: +91 9130601261   |   Email: fitnessfuel@gmail.com',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 16),

                  // 📄 Receipt Title
                  pw.Center(
                    child: pw.Text(
                      'RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // 👤 Client Info
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Client:  ${client.name}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            'Contact: ${client.contact}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            'Plan:    ${client.planType}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Date: ${formatDateTime(client.paymentDate)}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            'Status: ${client.paymentStatus}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 18),

                  // 📊 Membership Table (no vertical borders)
                  pw.Table(
                    border: pw.TableBorder(
                      top: pw.BorderSide(width: 0.5),
                      bottom: pw.BorderSide(width: 0.5),
                      horizontalInside: pw.BorderSide(width: 0.2),
                    ),
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          for (var h in [
                            'Start Date',
                            'End Date',
                            'Total\nAmount',
                            'Paid\nAmount',
                            'Unpaid\nAmount',
                          ])
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(
                                h,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              formatDateTime(client.startDate),
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              formatDateTime(client.endDate),
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              client.totalAmount,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              client.paidAmount,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              client.remainingAmount,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 18),

                  // 💵 Summary Box
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total Amount:  ${client.totalAmount}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Paid Amount:   ${client.paidAmount}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Unpaid Amount: ${client.remainingAmount}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 24),

                  // 📌 Terms
                  pw.Text(
                    'Terms & Conditions:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                    text: 'Membership rates may be revised at any time.',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Bullet(
                    text: 'Fees once paid are non-refundable.',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Bullet(
                    text: 'Fees once paid are non-refundable.',
                    style: pw.TextStyle(fontSize: 10),
                  ),

                  pw.SizedBox(height: 30),

                  // 🖋️ Signature
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Column(
                      children: [
                        pw.Text('_________________________'),
                        pw.Text(
                          'Authorized Signature',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
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

    // 3️⃣ Upload to Firebase Storage and get downloadUrl
    final safeName = client.name.replaceAll(RegExp(r'[^\w\s]+'), '');
    final fileName = 'Receipt_${safeName}_${client.id}.pdf';
    final ref = FirebaseStorage.instance.ref().child('clientPdf/$fileName');
    final uploadTask = await ref.putData(bytes);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // 4️⃣ Download PDF for user (Web only)
    if (kIsWeb) {
      try {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        Future.delayed(Duration(seconds: 1), () {
          html.Url.revokeObjectUrl(url);
        });
      } catch (e) {
        print('PDF download failed: $e');
      }
    }

    return downloadUrl;
  }
}
//     $downloadUrl

//     Feel free to contact us in case of any queries.''';

//     final encodedMessage = Uri.encodeComponent(message);
//     final whatsappNumber = client.whatsapp.replaceAll('+91', '').replaceAll(RegExp(r'\s+'), '');
//     final waUrl = Uri.parse("https://wa.me/91$whatsappNumber?text=$encodedMessage");

//     if (kIsWeb) {
//       html.window.open(waUrl.toString(), '_blank');
//     } else if (Platform.isAndroid || Platform.isIOS) {
//       if (await canLaunchUrl(waUrl)) {
//         await launchUrl(waUrl, mode: LaunchMode.externalApplication);
//       } else {
//         print("⚠️ Could not launch WhatsApp.");
//       }
//     } else {
//       print("❌ Unsupported platform for WhatsApp integration.");
//     }
//     */
//   }
// }
