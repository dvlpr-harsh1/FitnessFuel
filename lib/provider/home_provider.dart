import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessfuel/model/client_model.dart';
import 'package:fitnessfuel/services/pdf_generation.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  final firestore = FirebaseFirestore.instance.collection('Admin');
  final auth = FirebaseAuth.instance;
  bool isDrawerOpen = false;
  void toggleDrawer() {
    isDrawerOpen = !isDrawerOpen;
    notifyListeners();
  }

  bool searchBox = false;
  void toggleSearchDrawer() {
    searchBox = !searchBox;
    notifyListeners();
  }

  // Method to update client's paid amount
  Future<String> updateClientPaidAmount({
    required String clientId,
    required String newPaidAmount,
    required String totalAmount,
  }) async {
    try {
      // Validate inputs
      if (clientId.isEmpty) {
        return 'Invalid client ID';
      }

      // Validate and parse amounts
      final double? totalParsed = double.tryParse(totalAmount);
      final double? paidParsed = double.tryParse(newPaidAmount);

      if (totalParsed == null) {
        return 'Invalid total amount format';
      }

      if (paidParsed == null) {
        return 'Invalid paid amount format';
      }

      final user = auth.currentUser;
      if (user == null) {
        return 'User not found';
      }
      final uid = user.uid;

      // Calculate new remaining amount
      double remaining = totalParsed - paidParsed;
      if (remaining < 0) remaining = 0;
      final remainingAmount = remaining
          .toStringAsFixed(2)
          .replaceAll(RegExp(r"\.00$"), "");

      // Update payment status based on remaining amount
      final paymentStatus = remaining <= 0 ? 'Paid' : 'Unpaid';

      // Update the client document
      await firestore
          .doc(uid)
          .collection('ClientCollection')
          .doc(clientId)
          .update({
            'paidAmount': newPaidAmount,
            'remainingAmount': remainingAmount,
            'paymentStatus': paymentStatus,
            'paymentDate': DateTime.now().toIso8601String(),
          });

      // Add a small delay to ensure Firestore has time to update
      await Future.delayed(Duration(milliseconds: 300));

      // Fetch the updated client data to pass to PDF generation
      final updatedClientDoc = await firestore
          .doc(uid)
          .collection('ClientCollection')
          .doc(clientId)
          .get();

      if (updatedClientDoc.exists) {
        final updatedClientData = updatedClientDoc.data();
        final ClientModel clientModel = ClientModel(
          id: updatedClientData?['id'] ?? '',
          name: updatedClientData?['name'] ?? '',
          contact: updatedClientData?['contact'] ?? '',
          whatsapp: updatedClientData?['whatsapp'] ?? '',
          birthDate: updatedClientData?['birthDate'] ?? '',
          startDate: updatedClientData?['startDate'] ?? '',
          endDate: updatedClientData?['endDate'] ?? '',
          planType: updatedClientData?['planType'] ?? '',
          paidAmount: updatedClientData?['paidAmount'] ?? '',
          remainingAmount: updatedClientData?['remainingAmount'] ?? '',
          totalAmount: updatedClientData?['totalAmount'] ?? '',
          paymentDate: updatedClientData?['paymentDate'] ?? '',
          paymentStatus: updatedClientData?['paymentStatus'] ?? '',
          pdfUrl: updatedClientData?['pdfUrl'],
        );

        // Generate and send receipt PDF
        final pdfGenerator = PdfGeneration();
        await pdfGenerator.generateAndSendReceipt(clientModel);
        print('PDF generated automatically after update.');
      } else {
        print('Updated client document not found for PDF generation.');
      }

      notifyListeners();
      return 'Success';
    } catch (e) {
      print('Error updating paid amount: $e');
      return 'Error: $e';
    }
  }

  Future<dynamic> addClient({
    required String name,
    required String birthDate,
    required String contactNumber,
    required String whatsAppNumber,
    required String startDate,
    required String endDate,
    required String planType,
    required String paidAmount,
    required String totalAmount,
    required String paymentDate,
    required String paymentStatus,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String result = 'Got some error';
    try {
      final user = auth.currentUser;
      if (user == null) {
        return 'User not found';
      }
      final uid = user.uid;

      String formatDate(String date) {
        try {
          final parts = date.split('/');
          if (parts.length == 3) {
            final d = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            return d.toIso8601String();
          }
        } catch (_) {}
        return date;
      }

      ClientModel userCred = ClientModel(
        id: id,
        name: name.trim(),
        contact: contactNumber.trim(),
        whatsapp: whatsAppNumber.trim(),
        birthDate: formatDate(birthDate.trim()),
        startDate: formatDate(startDate.trim()),
        endDate: formatDate(endDate.trim()),
        planType: planType.trim(),
        paidAmount: paidAmount.trim(),
        remainingAmount:
            (double.tryParse(totalAmount) != null &&
                double.tryParse(paidAmount) != null)
            ? (double.parse(totalAmount) - double.parse(paidAmount)).toString()
            : '0',
        totalAmount: totalAmount.trim(),
        paymentDate: formatDate(paymentDate.trim()),
        paymentStatus: paymentStatus.trim(),
      );

      // Generate PDF and get downloadUrl
      final downloadUrl = await PdfGeneration().generateAndSendReceipt(
        userCred,
      );

      // Update client with downloadUrl
      final clientWithPdf = userCred..pdfUrl = downloadUrl;

      await firestore
          .doc(uid)
          .collection('ClientCollection')
          .doc(id)
          .set(clientWithPdf.toMap())
          .then((value) {
            return result = 'Success';
          })
          .onError((error, stackTrace) {
            print('$error');
            return result = 'Error: $error';
          });
      print('Data Uploaded Successfully');
      return clientWithPdf;
    } catch (e) {
      print('$e');
      return '$e';
    }
  }

  /// Update multiple fields and auto-download PDF
  Future<String> updateClientMultipleFields({
    required String clientId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) return 'User not logged in';
      final uid = user.uid;

      await firestore
          .doc(uid)
          .collection('ClientCollection')
          .doc(clientId)
          .update(updates);

      // Fetch updated client data
      final updatedClientDoc = await firestore
          .doc(uid)
          .collection('ClientCollection')
          .doc(clientId)
          .get();

      if (updatedClientDoc.exists) {
        final updatedClientData = updatedClientDoc.data();
        final ClientModel clientModel = ClientModel(
          id: updatedClientData?['id'] ?? '',
          name: updatedClientData?['name'] ?? '',
          contact: updatedClientData?['contact'] ?? '',
          whatsapp: updatedClientData?['whatsapp'] ?? '',
          birthDate: updatedClientData?['birthDate'] ?? '',
          startDate: updatedClientData?['startDate'] ?? '',
          endDate: updatedClientData?['endDate'] ?? '',
          planType: updatedClientData?['planType'] ?? '',
          paidAmount: updatedClientData?['paidAmount'] ?? '',
          remainingAmount: updatedClientData?['remainingAmount'] ?? '',
          totalAmount: updatedClientData?['totalAmount'] ?? '',
          paymentDate: updatedClientData?['paymentDate'] ?? '',
          paymentStatus: updatedClientData?['paymentStatus'] ?? '',
          pdfUrl: updatedClientData?['pdfUrl'],
        );
        final pdfGenerator = PdfGeneration();
        await pdfGenerator.generateAndSendReceipt(clientModel);
      }
      notifyListeners();
      return 'Success';
    } catch (e) {
      return e.toString();
    }
  }
}
