import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitnessfuel/main.dart';
import 'package:fitnessfuel/provider/auth_provider.dart';
import 'package:fitnessfuel/provider/home_provider.dart';
import 'package:fitnessfuel/responsive/screen_dimention.dart';
import 'package:fitnessfuel/services/pdf_generation.dart';
import 'package:fitnessfuel/utils/my_color.dart';
import 'package:fitnessfuel/view/footer/footer.dart';
import 'package:fitnessfuel/view/pages/fetched_clients.dart';
import 'package:fitnessfuel/widgets/anim_image.dart';
import 'package:fitnessfuel/widgets/custom_button.dart';
import 'package:fitnessfuel/widgets/custom_dropdown.dart';
import 'package:fitnessfuel/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  String formatDateForList(String date) {
    try {
      if (date.contains('-')) {
        // ISO8601
        final d = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(d);
      } else if (date.contains('/')) {
        // dd/MM/yyyy
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

  int getRemainingDays(String endDate) {
    try {
      DateTime end;
      if (endDate.contains('-')) {
        end = DateTime.parse(endDate);
      } else if (endDate.contains('/')) {
        final parts = endDate.split('/');
        end = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return 0;
      }
      final now = DateTime.now();
      // Only date part, ignore time
      final today = DateTime(now.year, now.month, now.day);
      final endDay = DateTime(end.year, end.month, end.day);
      final diff = endDay.difference(today).inDays;
      return diff >= 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _homeProvider = Provider.of<HomeProvider>(context);
    Footer footer = Footer();
    AnimImage animImage = AnimImage();

    final searchController = TextEditingController();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passController = TextEditingController();
    final CustomTextfield customTextfield = CustomTextfield();
    final auth = FirebaseAuth.instance;
    final firebaseFirestore = FirebaseFirestore.instance.collection('Admin');

    // Responsive horizontal padding
    final double horizontalPadding = mq.width > webScreenSize
        ? 120
        : (mq.width > 900 ? 80 : (mq.width > 600 ? 36 : 12));

    return Scaffold(
      ///Appbar
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: mq.width > webScreenSize
            ? mq.height * .085
            : mq.height * .08,
        centerTitle: true,
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            child: Text(
              'FitnessFuel',
              style: mq.width > webScreenSize
                  ? TextStyle(fontSize: 36)
                  : TextStyle(fontSize: 26),
            ),
          ),
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            padding: mq.width > webScreenSize
                ? EdgeInsets.symmetric(horizontal: mq.width * .02)
                : EdgeInsets.only(left: mq.width * .05, right: mq.width * .05),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                hoverColor: Colors.transparent,
                onPressed: () {
                  AuthController().signOut(context);
                },
                icon: Icon(
                  Icons.logout,
                  size: mq.width > webScreenSize ? 30 : 28,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: mq.width > webScreenSize
                ? EdgeInsets.symmetric(horizontal: mq.width * .02)
                : EdgeInsets.only(left: mq.width * .05, right: mq.width * .05),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                hoverColor: Colors.transparent,
                onPressed: () {
                  if (mq.width > 900) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _SearchClientDialog();
                      },
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      builder: (context) {
                        return _SearchClientBottomSheet();
                      },
                    );
                  }
                },
                icon: Icon(
                  CupertinoIcons.search,
                  size: mq.width > webScreenSize ? 30 : 28,
                ),
              ),
            ),
          ),
        ],

        /// Add bottom border
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(color: MyColor.borderColor, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ///Image
                    Text(
                      'FitnessFuel',
                      style: GoogleFonts.poppins(
                        color: MyColor.black.withOpacity(.6),
                        fontSize: mq.width > webScreenSize ? 60 : 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    ///Textfields & all content.
                    _GymClientFormFields(),

                    SizedBox(height: 30),

                    ///Footer
                    footer,
                  ],
                ),
              ),

              // Remove the side panel for web/tablet
              // if (_homeProvider.searchBox && mq.width > 900)
              //   Expanded(
              //     flex: 1,
              //     child: ...,
              //   ),
              // For mobile/tablet, show nothing here (handled by modal)
            ],
          ),
        ),
      ),
    );
  }
}

class _GymClientFormFields extends StatefulWidget {
  @override
  State<_GymClientFormFields> createState() => _GymClientFormFieldsState();
}

class _GymClientFormFieldsState extends State<_GymClientFormFields> {
  CustomButton customButton = CustomButton();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final whatsappController = TextEditingController();
  final birthDateController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final paidAmountController = TextEditingController();
  final remainingAmountController = TextEditingController();
  final totalAmountController = TextEditingController();
  final paymentDateController = TextEditingController();

  String selectedPaymentStatus = 'Paid';
  final List<String> paymentStatusOptions = ['Paid', 'Unpaid'];
  String selectedPlan = 'Monthly';
  final List<String> planTypes = [
    'Monthly',
    'Quarterly',
    'Half-Yearly',
    'Yearly',
  ];

  final CustomTextfield customTextfield = CustomTextfield();
  final CustomDropdownfield customDropdownfield = CustomDropdownfield();

  @override
  void initState() {
    super.initState();
    totalAmountController.addListener(_updateRemainingAmount);
    paidAmountController.addListener(_updateRemainingAmount);
  }

  void _updateRemainingAmount() {
    final total = double.tryParse(totalAmountController.text) ?? 0.0;
    final paid = double.tryParse(paidAmountController.text) ?? 0.0;
    double remaining = total - paid;
    if (remaining < 0) remaining = 0;
    remainingAmountController.text = remaining
        .toStringAsFixed(2)
        .replaceAll(RegExp(r"\.00$"), "");
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    whatsappController.dispose();
    birthDateController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    paidAmountController.dispose();
    remainingAmountController.dispose();
    totalAmountController.dispose();
    paymentDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) => child!,
    );
    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  void _adjustEndDate() {
    final startText = startDateController.text;
    if (startText.isEmpty) {
      endDateController.text = '';
      return;
    }
    try {
      final parts = startText.split('/');
      if (parts.length != 3) return;
      final start = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      DateTime end;
      switch (selectedPlan) {
        case 'Monthly':
          end = DateTime(start.year, start.month + 1, start.day);
          break;
        case 'Quarterly':
          end = DateTime(start.year, start.month + 3, start.day);
          break;
        case 'Half-Yearly':
          end = DateTime(start.year, start.month + 6, start.day);
          break;
        case 'Yearly':
          end = DateTime(start.year + 1, start.month, start.day);
          break;
        default:
          end = start;
      }
      endDateController.text =
          "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}";
    } catch (_) {
      endDateController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = mq.width > webScreenSize;
    final bool isTablet = mq.width > 600 && mq.width <= webScreenSize;
    final double headingFontSize = isWeb ? 38 : (isTablet ? 32 : 24);
    final double subHeadingFontSize = isWeb ? 20 : (isTablet ? 18 : 15);
    final double fieldSpacing = isWeb ? 32 : (isTablet ? 22 : 14);
    final double buttonFontSize = isWeb ? 20 : (isTablet ? 18 : 16);
    final double buttonPadding = isWeb ? 22 : (isTablet ? 18 : 14);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Fill in the details to add a new gym member.",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w400,
              fontSize: subHeadingFontSize,
            ),
          ),
          SizedBox(height: isWeb ? 38 : (isTablet ? 28 : 18)),

          // Client Name
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Client Name",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            controller: nameController,
            title: "",
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: fieldSpacing),

          // Birth Date
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Birth Date",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap: () => _selectDate(birthDateController),
            child: AbsorbPointer(
              child: customTextfield.customTextfield(
                controller: birthDateController,
                title: "",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
                hintText: 'Select Birth Date',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
          SizedBox(height: fieldSpacing),

          // Contact Number
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Contact Number",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            controller: contactController,
            title: "",
            keyboardType: TextInputType.phone,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: fieldSpacing),

          // WhatsApp Number
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "WhatsApp Number",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            controller: whatsappController,
            title: "",
            keyboardType: TextInputType.phone,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: fieldSpacing),
          // Plan Type
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Plan Type",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customDropdownfield.dropdownField(
            title: "",
            value: selectedPlan,
            items: planTypes,
            onChanged: (val) {
              setState(() {
                selectedPlan = val;
                _adjustEndDate();
              });
            },
            context: context,
          ),
          SizedBox(height: fieldSpacing),

          // Start Date & End Date
          (isTablet || isWeb)
              ? Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Start Date",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              await _selectDate(startDateController);
                              _adjustEndDate();
                            },
                            child: AbsorbPointer(
                              child: customTextfield.customTextfield(
                                controller: startDateController,
                                title: "",
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Required'
                                    : null,
                                hintText: 'Select Start Date',
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "End Date",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          AbsorbPointer(
                            child: customTextfield.customTextfield(
                              controller: endDateController,
                              title: "",
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                              hintText: 'Auto-calculated End Date',
                              suffixIcon: const Icon(Icons.calendar_today),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Start Date",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        await _selectDate(startDateController);
                        _adjustEndDate();
                      },
                      child: AbsorbPointer(
                        child: customTextfield.customTextfield(
                          controller: startDateController,
                          title: "",
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Required' : null,
                          hintText: 'Select Start Date',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    SizedBox(height: fieldSpacing),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "End Date",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    AbsorbPointer(
                      child: customTextfield.customTextfield(
                        controller: endDateController,
                        title: "",
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                        hintText: 'Auto-calculated End Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
          SizedBox(height: fieldSpacing),

          // Total Amount (always show before Paid/Remaining)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Total Amount",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            controller: totalAmountController,
            title: "",
            keyboardType: TextInputType.number,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          SizedBox(height: fieldSpacing),

          // Paid & Remaining Amount
          (isTablet || isWeb)
              ? Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Paid Amount",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          customTextfield.customTextfield(
                            controller: paidAmountController,
                            title: "",
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Remaining Amount",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          customTextfield.customTextfield(
                            controller: remainingAmountController,
                            title: "",
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                            readOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Paid Amount",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: fieldSpacing),
                    customTextfield.customTextfield(
                      controller: paidAmountController,
                      title: "",
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: fieldSpacing),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Remaining Amount",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    customTextfield.customTextfield(
                      controller: remainingAmountController,
                      title: "",
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                      readOnly: true,
                    ),
                  ],
                ),

          SizedBox(height: fieldSpacing),

          // Payment Date
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Date",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap: () => _selectDate(paymentDateController),
            child: AbsorbPointer(
              child: customTextfield.customTextfield(
                controller: paymentDateController,
                title: "",
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
                hintText: 'Select Payment Date',
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
          ),
          SizedBox(height: fieldSpacing),

          // Payment Status
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Payment Status",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customDropdownfield.dropdownField(
            title: "",
            value: selectedPaymentStatus,
            items: paymentStatusOptions,
            onChanged: (val) => setState(() => selectedPaymentStatus = val),
            context: context,
          ),
          SizedBox(height: isWeb ? 48 : (isTablet ? 36 : 24)),

          customButton.custButton(
            labelWidget: Text(
              'Create Account',
              style: TextStyle(color: MyColor.background, fontSize: 18),
            ),
            onTap: () async {
              if (_formKey.currentState!.validate()) {
                final homeProvider = Provider.of<HomeProvider>(
                  context,
                  listen: false,
                );
                final result = await homeProvider.addClient(
                  name: nameController.text,
                  birthDate: birthDateController.text,
                  contactNumber: contactController.text,
                  whatsAppNumber: whatsappController.text,
                  startDate: startDateController.text,
                  endDate: endDateController.text,
                  planType: selectedPlan,
                  paidAmount: paidAmountController.text,
                  totalAmount: totalAmountController.text,
                  paymentDate: paymentDateController.text,
                  paymentStatus: selectedPaymentStatus,
                );
                if (result is String) {
                  // Error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $result"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  // Success, result is ClientModel
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Client data saved!"),
                      backgroundColor: Color(0xFFBB86FC),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Remove this line to avoid double PDF download:
                  // await PdfGeneration().generateAndSendReceipt(result);
                  // Optionally clear fields here
                  nameController.clear();
                  birthDateController.clear();
                  contactController.clear();
                  whatsappController.clear();
                  startDateController.clear();
                  endDateController.clear();
                  paidAmountController.clear();
                  totalAmountController.clear();
                  remainingAmountController.clear();
                  paymentDateController.clear();
                  setState(() {
                    selectedPlan = 'Monthly';
                    selectedPaymentStatus = 'Paid';
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SearchClientDialog extends StatefulWidget {
  @override
  State<_SearchClientDialog> createState() => _SearchClientDialogState();
}

class _SearchClientDialogState extends State<_SearchClientDialog> {
  final searchController = TextEditingController();
  dynamic selectedClient;

  String formatDateForList(String date) {
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

  int getRemainingDays(String endDate) {
    try {
      DateTime end;
      if (endDate.contains('-')) {
        end = DateTime.parse(endDate);
      } else if (endDate.contains('/')) {
        final parts = endDate.split('/');
        end = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return 0;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endDay = DateTime(end.year, end.month, end.day);
      final diff = endDay.difference(today).inDays;
      return diff >= 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final auth = FirebaseAuth.instance;
    final firebaseFirestore = FirebaseFirestore.instance.collection('Admin');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        width: 500,
        height: mq.height * 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: selectedClient == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Search Client",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        hintText: "Type client name or number...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 0,
                        ),
                      ),
                      style: TextStyle(fontSize: 15),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(height: 26),
                  Text(
                    "Clients",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black.withOpacity(.7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder(
                      stream: firebaseFirestore
                          .doc(auth.currentUser!.uid)
                          .collection('ClientCollection')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot == null || !snapshot.hasData) {
                          return Center(child: Text('No Data Found'));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('❌ Error: ${snapshot.error}'),
                          );
                        }
                        var clients = snapshot.data!.docs;
                        final query = searchController.text
                            .trim()
                            .toLowerCase();
                        final filtered = query.isEmpty
                            ? clients
                            : clients.where((c) {
                                final name = (c['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final contact = (c['contact'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return name.contains(query) ||
                                    contact.contains(query);
                              }).toList();
                        if (filtered.isEmpty) {
                          return Center(child: Text('No clients found.'));
                        }
                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            var client = filtered[index];
                            final joined = formatDateForList(
                              client['startDate'],
                            );
                            final end = formatDateForList(client['endDate']);
                            final remain = getRemainingDays(client['endDate']);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                title: Text(
                                  client['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Remain: $remain days\nJoined: $joined | End: $end',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedClient = client;
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _FetchedClientDetailCard(
                        client: selectedClient,
                        onBack: () => setState(() => selectedClient = null),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SearchClientBottomSheet extends StatefulWidget {
  @override
  State<_SearchClientBottomSheet> createState() =>
      _SearchClientBottomSheetState();
}

class _SearchClientBottomSheetState extends State<_SearchClientBottomSheet> {
  final searchController = TextEditingController();
  dynamic selectedClient;

  String formatDateForList(String date) {
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

  int getRemainingDays(String endDate) {
    try {
      DateTime end;
      if (endDate.contains('-')) {
        end = DateTime.parse(endDate);
      } else if (endDate.contains('/')) {
        final parts = endDate.split('/');
        end = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return 0;
      }
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endDay = DateTime(end.year, end.month, end.day);
      final diff = endDay.difference(today).inDays;
      return diff >= 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final auth = FirebaseAuth.instance;
    final firebaseFirestore = FirebaseFirestore.instance.collection('Admin');

    return SafeArea(
      child: Container(
        height: mq.height * 0.85,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: selectedClient == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Search Client",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        hintText: "Type client name or number...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 0,
                        ),
                      ),
                      style: TextStyle(fontSize: 15),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(height: 26),
                  Text(
                    "Clients",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black.withOpacity(.7),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder(
                      stream: firebaseFirestore
                          .doc(auth.currentUser!.uid)
                          .collection('ClientCollection')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot == null || !snapshot.hasData) {
                          return Center(child: Text('No Data Found'));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('❌ Error: ${snapshot.error}'),
                          );
                        }
                        var clients = snapshot.data!.docs;
                        final query = searchController.text
                            .trim()
                            .toLowerCase();
                        final filtered = query.isEmpty
                            ? clients
                            : clients.where((c) {
                                final name = (c['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final contact = (c['contact'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return name.contains(query) ||
                                    contact.contains(query);
                              }).toList();
                        if (filtered.isEmpty) {
                          return Center(child: Text('No clients found.'));
                        }
                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            var client = filtered[index];
                            final joined = formatDateForList(
                              client['startDate'],
                            );
                            final end = formatDateForList(client['endDate']);
                            final remain = getRemainingDays(client['endDate']);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                title: Text(
                                  client['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    'Remain: $remain days\nJoined: $joined | End: $end',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedClient = client;
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: _FetchedClientDetailCard(
                        client: selectedClient,
                        onBack: () => setState(() => selectedClient = null),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FetchedClientDetailCard extends StatelessWidget {
  final dynamic client;
  final VoidCallback onBack;
  const _FetchedClientDetailCard({required this.client, required this.onBack});

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
    final joined = formatDate(client['startDate']);
    final end = formatDate(client['endDate']);
    final paymentDate = formatDate(client['paymentDate']);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.purple[100],
                  child: Icon(
                    Icons.person,
                    color: Colors.purple[700],
                    size: 32,
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    client['name'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.purple[800],
                      letterSpacing: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Divider(thickness: 1.2, color: Colors.grey[200]),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.purple[300], size: 20),
                SizedBox(width: 10),
                Text(
                  "Contact: ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    client['contact'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                // Icon(Icons.whatsapp, color: Colors.green[400], size: 20),
                SizedBox(width: 10),
                Text(
                  "WhatsApp: ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    client['whatsapp'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[300], size: 18),
                SizedBox(width: 10),
                Text("Plan: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: Text(
                    client['planType'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.date_range, color: Colors.orange[300], size: 18),
                SizedBox(width: 10),
                Text("Start: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Text(joined, style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(width: 16),
                Text("End: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Text(end, style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.teal[400], size: 20),
                SizedBox(width: 10),
                Text("Total: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  client['totalAmount'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 12),
                Text("Paid: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  client['paidAmount'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 12),
                Text("Remain: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  client['remainingAmount'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.payment, color: Colors.deepPurple[300], size: 20),
                SizedBox(width: 10),
                Text(
                  "Payment Date: ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  paymentDate,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.verified, color: Colors.blueGrey[400], size: 20),
                SizedBox(width: 10),
                Text("Status: ", style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  client['paymentStatus'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: Colors.purple.withOpacity(0.18),
                ),
                icon: Icon(Icons.arrow_back),
                label: Text("Back"),
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
