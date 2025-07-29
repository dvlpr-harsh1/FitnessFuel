// import 'package:fitnessfuel/main.dart';
// import 'package:fitnessfuel/widgets/custom_dropdown.dart';
// import 'package:fitnessfuel/widgets/custom_textfield.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fitnessfuel/model/client_model.dart';

// class GymClientForm extends StatefulWidget {
//   const GymClientForm({super.key});

//   @override
//   State<GymClientForm> createState() => _GymClientFormState();
// }

// class _GymClientFormState extends State<GymClientForm> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final contactController = TextEditingController();
//   final whatsappController = TextEditingController();
//   final birthDateController = TextEditingController();
//   final startDateController = TextEditingController();
//   final endDateController = TextEditingController();
//   final paidAmountController = TextEditingController();
//   final remainingAmountController = TextEditingController();
//   final totalAmountController = TextEditingController();
//   final paymentDateController = TextEditingController();
//   String selectedPaymentStatus = 'Paid';
//   final List<String> paymentStatusOptions = ['Paid', 'Unpaid'];
//   @override
//   void dispose() {
//     nameController.dispose();
//     contactController.dispose();
//     whatsappController.dispose();
//     birthDateController.dispose();
//     startDateController.dispose();
//     endDateController.dispose();
//     paidAmountController.dispose();
//     remainingAmountController.dispose();
//     totalAmountController.dispose();
//     paymentDateController.dispose();
//     super.dispose();
//   }

//   final CustomTextfield customTextfield = CustomTextfield();
//   final CustomDropdownfield customDropdownfield = CustomDropdownfield();

//   String selectedPlan = 'Monthly';
//   final List<String> planTypes = [
//     'Monthly',
//     'Quarterly',
//     'Half-Yearly',
//     'Yearly',
//   ];

//   Future<void> _selectDate(TextEditingController controller) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1950),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.dark(
//               primary: Color(0xFFBB86FC),
//               onPrimary: Colors.white,
//               surface: Color(0xFF232526),
//               onSurface: Colors.white,
//               background: Color(0xFF232526),
//             ),
//             dialogBackgroundColor: const Color(0xFF232526),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: Color(0xFFBB86FC)),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       controller.text = DateFormat('dd/MM/yyyy').format(picked);
//     }
//   }

//   Future<void> _saveClient() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     final docRef = FirebaseFirestore.instance
//         .collection('Admin')
//         .doc(user.uid)
//         .collection('clients')
//         .doc();
//     final client = ClientModel(
//       id: docRef.id,
//       name: nameController.text.trim(),
//       contact: contactController.text.trim(),
//       whatsapp: whatsappController.text.trim(),
//       birthDate: birthDateController.text.trim(),
//       startDate: startDateController.text.trim(),
//       endDate: endDateController.text.trim(),
//       planType: selectedPlan,
//       paidAmount: paidAmountController.text.trim(),
//       remainingAmount: remainingAmountController.text.trim(),
//       totalAmount: totalAmountController.text.trim(),
//       paymentDate: paymentDateController.text.trim(),
//       paymentStatus: selectedPaymentStatus,
//     );
//     await docRef.set(client.toMap());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = mq.width >= 600;
//     final double horizontalPadding = isTablet ? mq.width * 0.06 : 18;
//     final double formWidth = isTablet ? 700 : double.infinity;
//     final double cardRadius = isTablet ? 40 : 24;
//     final double cardPadding = isTablet ? 48 : 24;
//     final double headingFontSize = isTablet ? 38 : 28;
//     final double subHeadingFontSize = isTablet ? 20 : 15;
//     final double fieldSpacing = isTablet ? 32 : 20;
//     final double buttonFontSize = isTablet ? 20 : 16;
//     final double buttonPadding = isTablet ? 22 : 16;

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF232526),
//               Color(0xFF485563),
//               Color(0xFF232526),
//               Color(0xFFBB86FC),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             stops: [0.0, 0.5, 0.8, 1.0],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: isTablet ? mq.height * 0.08 : mq.height * 0.04,
//               ),
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     vertical: cardPadding,
//                     horizontal: cardPadding,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.10),
//                     borderRadius: BorderRadius.circular(cardRadius),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.18),
//                         blurRadius: 32,
//                         offset: const Offset(0, 16),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.13),
//                       width: 1.2,
//                     ),
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Text(
//                           "Register New Client",
//                           style: Theme.of(context).textTheme.displaySmall
//                               ?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: headingFontSize,
//                                 letterSpacing: 1.2,
//                               ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: isTablet ? 12 : 8),
//                         Text(
//                           "Fill in the details to add a new gym member.",
//                           style: Theme.of(context).textTheme.bodyLarge
//                               ?.copyWith(
//                                 color: Colors.white70,
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: subHeadingFontSize,
//                               ),
//                           textAlign: TextAlign.center,
//                         ),
//                         SizedBox(height: isTablet ? 44 : 28),
//                         customTextfield.customTextfield(
//                           controller: nameController,
//                           title: "Client Name",
//                           validator: (val) =>
//                               val == null || val.isEmpty ? 'Required' : null,
//                         ),
//                         SizedBox(height: fieldSpacing),
//                         GestureDetector(
//                           onTap: () => _selectDate(birthDateController),
//                           child: AbsorbPointer(
//                             child: customTextfield.customTextfield(
//                               controller: birthDateController,
//                               title: "Birth Date",
//                               validator: (val) => val == null || val.isEmpty
//                                   ? 'Required'
//                                   : null,
//                               hintText: 'Select Birth Date',
//                               suffixIcon: const Icon(Icons.calendar_today),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: fieldSpacing),
//                         customTextfield.customTextfield(
//                           controller: contactController,
//                           title: "Contact Number",
//                           keyboardType: TextInputType.phone,
//                           validator: (val) =>
//                               val == null || val.isEmpty ? 'Required' : null,
//                         ),
//                         SizedBox(height: fieldSpacing),
//                         customTextfield.customTextfield(
//                           controller: whatsappController,
//                           title: "WhatsApp Number",
//                           keyboardType: TextInputType.phone,
//                           validator: (val) =>
//                               val == null || val.isEmpty ? 'Required' : null,
//                         ),

//                         SizedBox(height: fieldSpacing),
//                         isTablet
//                             ? Row(
//                                 children: [
//                                   Flexible(
//                                     child: GestureDetector(
//                                       onTap: () =>
//                                           _selectDate(startDateController),
//                                       child: AbsorbPointer(
//                                         child: customTextfield.customTextfield(
//                                           controller: startDateController,
//                                           title: "Start Date",
//                                           validator: (val) =>
//                                               val == null || val.isEmpty
//                                               ? 'Required'
//                                               : null,
//                                           hintText: 'Select Start Date',
//                                           suffixIcon: const Icon(
//                                             Icons.calendar_today,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 28),
//                                   Flexible(
//                                     child: GestureDetector(
//                                       onTap: () =>
//                                           _selectDate(endDateController),
//                                       child: AbsorbPointer(
//                                         child: customTextfield.customTextfield(
//                                           controller: endDateController,
//                                           title: "End Date",
//                                           validator: (val) =>
//                                               val == null || val.isEmpty
//                                               ? 'Required'
//                                               : null,
//                                           hintText: 'Select End Date',
//                                           suffixIcon: const Icon(
//                                             Icons.calendar_today,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Column(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () =>
//                                         _selectDate(startDateController),
//                                     child: AbsorbPointer(
//                                       child: customTextfield.customTextfield(
//                                         controller: startDateController,
//                                         title: "Start Date",
//                                         validator: (val) =>
//                                             val == null || val.isEmpty
//                                             ? 'Required'
//                                             : null,
//                                         hintText: 'Select Start Date',
//                                         suffixIcon: const Icon(
//                                           Icons.calendar_today,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(height: fieldSpacing),
//                                   GestureDetector(
//                                     onTap: () => _selectDate(endDateController),
//                                     child: AbsorbPointer(
//                                       child: customTextfield.customTextfield(
//                                         controller: endDateController,
//                                         title: "End Date",
//                                         validator: (val) =>
//                                             val == null || val.isEmpty
//                                             ? 'Required'
//                                             : null,
//                                         hintText: 'Select End Date',
//                                         suffixIcon: const Icon(
//                                           Icons.calendar_today,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                         SizedBox(height: fieldSpacing),
//                         customDropdownfield.dropdownField(
//                           title: "Plan Type",
//                           value: selectedPlan,
//                           items: planTypes,
//                           onChanged: (val) =>
//                               setState(() => selectedPlan = val),
//                           context: context,
//                         ),
//                         SizedBox(height: fieldSpacing),
//                         isTablet
//                             ? Row(
//                                 children: [
//                                   Flexible(
//                                     child: customTextfield.customTextfield(
//                                       controller: paidAmountController,
//                                       title: "Paid Amount",
//                                       keyboardType: TextInputType.number,
//                                       validator: (val) =>
//                                           val == null || val.isEmpty
//                                           ? 'Required'
//                                           : null,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 28),
//                                   Flexible(
//                                     child: customTextfield.customTextfield(
//                                       controller: remainingAmountController,
//                                       title: "Remaining Amount",
//                                       keyboardType: TextInputType.number,
//                                       validator: (val) =>
//                                           val == null || val.isEmpty
//                                           ? 'Required'
//                                           : null,
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Column(
//                                 children: [
//                                   customTextfield.customTextfield(
//                                     controller: paidAmountController,
//                                     title: "Paid Amount",
//                                     keyboardType: TextInputType.number,
//                                     validator: (val) =>
//                                         val == null || val.isEmpty
//                                         ? 'Required'
//                                         : null,
//                                   ),
//                                   SizedBox(height: fieldSpacing),
//                                   customTextfield.customTextfield(
//                                     controller: remainingAmountController,
//                                     title: "Remaining Amount",
//                                     keyboardType: TextInputType.number,
//                                     validator: (val) =>
//                                         val == null || val.isEmpty
//                                         ? 'Required'
//                                         : null,
//                                   ),
//                                 ],
//                               ),
//                         SizedBox(height: fieldSpacing),
//                         customTextfield.customTextfield(
//                           controller: totalAmountController,
//                           title: "Total Amount",
//                           keyboardType: TextInputType.number,
//                           validator: (val) =>
//                               val == null || val.isEmpty ? 'Required' : null,
//                         ),
//                         SizedBox(height: fieldSpacing),
//                         GestureDetector(
//                           onTap: () => _selectDate(paymentDateController),
//                           child: AbsorbPointer(
//                             child: customTextfield.customTextfield(
//                               controller: paymentDateController,
//                               title: "Payment Date",
//                               validator: (val) => val == null || val.isEmpty
//                                   ? 'Required'
//                                   : null,
//                               hintText: 'Select Payment Date',
//                               suffixIcon: const Icon(Icons.calendar_today),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: fieldSpacing),
//                         customDropdownfield.dropdownField(
//                           title: "Payment Status",
//                           value: selectedPaymentStatus,
//                           items: paymentStatusOptions,
//                           onChanged: (val) =>
//                               setState(() => selectedPaymentStatus = val),
//                           context: context,
//                         ),
//                         SizedBox(height: isTablet ? 48 : 32),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFBB86FC),
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               vertical: buttonPadding,
//                             ),
//                             textStyle: TextStyle(
//                               fontSize: buttonFontSize,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.1,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(
//                                 isTablet ? 22 : 16,
//                               ),
//                             ),
//                             elevation: 8,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                           ),
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               await _saveClient();
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text("Client data saved!"),
//                                   backgroundColor: Color(0xFFBB86FC),
//                                   behavior: SnackBarBehavior.floating,
//                                 ),
//                               );
//                             }
//                           },
//                           child: const Text("Submit"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
