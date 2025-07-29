import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessfuel/model/client_model.dart';
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

      // Parse and format dates to ISO8601 string (or keep as dd/MM/yyyy if you want)
      String formatDate(String date) {
        try {
          // Try parsing dd/MM/yyyy
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
        return date; // fallback to original if parsing fails
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

      await firestore
          .doc(uid)
          .collection('ClientCollection')
          .doc(id)
          .set(userCred.toMap())
          .then((value) {
            return result = 'Success';
          })
          .onError((error, stackTrace) {
            print('$error');
            return result = 'Error: $error';
          });
      print('Data Uploaded Successfully');
      // Return the client model for further use (e.g., PDF)
      return userCred;
    } catch (e) {
      print('$e');
      return '$e';
    }
  }
}
