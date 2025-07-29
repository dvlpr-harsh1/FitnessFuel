import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessfuel/model/client_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FetchedClients extends StatefulWidget {
  dynamic userCred;
  FetchedClients({required this.userCred, super.key});

  @override
  State<FetchedClients> createState() => _FetchedClientsState();
}

class _FetchedClientsState extends State<FetchedClients> {
  String formatDate(String date) {
    try {
      if (date.contains('-')) {
        final d = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(d);
      } else if (date.contains('/')) {
        final parts = date.split('/');
        if (parts.length == 3) {
          final d = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return DateFormat('dd MMM yyyy').format(d);
        }
      }
    } catch (_) {}
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final userCred = widget.userCred;
    if (userCred == null) {
      return const Center(child: Text("Not logged in"));
    }

    final joined = formatDate(userCred['startDate']);
    final end = formatDate(userCred['endDate']);
    final paymentDate = formatDate(userCred['paymentDate']);

    final mq = MediaQuery.of(context).size;
    final isWeb = mq.width > 1100;
    final isTablet = mq.width > 600 && mq.width <= 1100;
    final isMobile = mq.width <= 600;

    // Responsive paddings and max width
    final double cardPadding = isWeb ? 40.0 : (isTablet ? 28.0 : 12.0);
    final double maxContentWidth = isWeb
        ? 900
        : (isTablet ? 700 : double.infinity);

    final labelStyle = TextStyle(
      color: Colors.grey[700],
      fontWeight: FontWeight.w600,
      fontSize: isWeb ? 18 : (isTablet ? 16 : 15),
    );
    final valueStyle = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
      fontSize: isWeb ? 18 : (isTablet ? 16 : 15),
    );
    final headingStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: isWeb ? 28 : (isTablet ? 24 : 20),
      color: Colors.purple[800],
      letterSpacing: 1.1,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
              vertical: isWeb ? 48 : (isTablet ? 32 : 12),
              horizontal: isWeb ? 0 : (isTablet ? 0 : 0),
            ),
            child: Container(
              width: maxContentWidth,
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  isWeb ? 18 : (isTablet ? 0 : 0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.purple.withOpacity(0.08),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: isMobile
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: isWeb ? 32 : (isTablet ? 28 : 24),
                        backgroundColor: Colors.purple[100],
                        child: Icon(
                          Icons.person,
                          color: Colors.purple[700],
                          size: isWeb ? 36 : 28,
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Text(
                          userCred['name'] ?? '',
                          style: headingStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 32 : (isTablet ? 24 : 14)),
                  Divider(thickness: 1.2, color: Colors.grey[200]),
                  SizedBox(height: isWeb ? 24 : (isTablet ? 18 : 10)),
                  Wrap(
                    runSpacing: 10,
                    spacing: 24,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.purple[300],
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text("Contact: ", style: labelStyle),
                          Text(userCred['contact'] ?? '', style: valueStyle),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon(Icons.whatsapp, color: Colors.green[400], size: 22),
                          SizedBox(width: 10),
                          Text("WhatsApp: ", style: labelStyle),
                          Text(userCred['whatsapp'] ?? '', style: valueStyle),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.blue[300],
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text("Plan: ", style: labelStyle),
                          Text(userCred['planType'] ?? '', style: valueStyle),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    runSpacing: 10,
                    spacing: 24,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Colors.orange[300],
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text("Start: ", style: labelStyle),
                          Text(joined, style: valueStyle),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("End: ", style: labelStyle),
                          Text(end, style: valueStyle),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    runSpacing: 10,
                    spacing: 24,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.teal[400],
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text("Total: ", style: labelStyle),
                          Text(
                            userCred['totalAmount'] ?? '',
                            style: valueStyle,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Paid: ", style: labelStyle),
                          Text(userCred['paidAmount'] ?? '', style: valueStyle),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Remain: ", style: labelStyle),
                          Text(
                            userCred['remainingAmount'] ?? '',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    runSpacing: 10,
                    spacing: 24,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment,
                            color: Colors.deepPurple[300],
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text("Payment Date: ", style: labelStyle),
                          Text(paymentDate, style: valueStyle),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.blueGrey[400],
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text("Status: ", style: labelStyle),
                          Text(
                            userCred['paymentStatus'] ?? '',
                            style: valueStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: isWeb ? 32 : (isTablet ? 24 : 16)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isWeb ? 16 : 12,
                          horizontal: isWeb ? 32 : 20,
                        ),
                        textStyle: TextStyle(
                          fontSize: isWeb ? 18 : 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isWeb ? 12 : (isTablet ? 10 : 6),
                          ),
                        ),
                        elevation: 6,
                        shadowColor: Colors.purple.withOpacity(0.18),
                      ),
                      icon: Icon(Icons.arrow_back),
                      label: Text("Back"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
