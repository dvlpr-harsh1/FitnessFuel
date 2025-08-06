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
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool showSearchPanel = false;
  dynamic selectedClient;
  late AnimationController _controller;
  late Animation<double> _panelAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _panelAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleSearchPanel() {
    setState(() {
      showSearchPanel = !showSearchPanel;
      if (showSearchPanel) {
        _controller.forward();
      } else {
        _controller.reverse();
        selectedClient = null;
      }
    });
  }

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

  int getRemainingDays(String startDate, String endDate) {
    try {
      DateTime start, end;
      if (startDate.contains('-')) {
        start = DateTime.parse(startDate);
      } else if (startDate.contains('/')) {
        final parts = startDate.split('/');
        start = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return 0;
      }
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
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);

      // Smooth animation: use AnimatedSwitcher for the Remain days text in the UI (not here in logic)
      if (today.isBefore(startDay)) {
        final totalDays = endDay.difference(startDay).inDays + 1;
        return totalDays >= 0 ? totalDays : 0;
      } else if (today.isAfter(endDay)) {
        return 0;
      } else {
        final remain = endDay.difference(today).inDays + 1;
        return remain >= 0 ? remain : 0;
      }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: mq.width > webScreenSize
            ? mq.height * .12
            : mq.height * .08,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Home()),
            );
          },
          child: Image.asset('assets/images/logo.jpg', height: 100),
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
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: () => AuthController().signOut(context),
              ),
            ),
          ),
          if (mq.width > webScreenSize)
            Container(
              alignment: Alignment.center,
              padding: mq.width > webScreenSize
                  ? EdgeInsets.symmetric(horizontal: mq.width * .02)
                  : EdgeInsets.only(
                      left: mq.width * .05,
                      right: mq.width * .05,
                    ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  hoverColor: Colors.transparent,
                  onPressed: toggleSearchPanel,
                  icon: Icon(
                    showSearchPanel ? Icons.close : CupertinoIcons.search,
                    // size: mq.width > webScreenSize ? 30 : 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (mq.width <= webScreenSize)
            Container(
              alignment: Alignment.center,
              padding: mq.width > webScreenSize
                  ? EdgeInsets.symmetric(horizontal: mq.width * .02)
                  : EdgeInsets.only(
                      left: mq.width * .05,
                      right: mq.width * .05,
                    ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  hoverColor: Colors.transparent,
                  onPressed: () {
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
          child: Container(color: Theme.of(context).dividerColor, height: 2.0),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FitnessFuel',
                      style: GoogleFonts.poppins(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(.6),
                        fontSize: mq.width > webScreenSize ? 60 : 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _GymClientFormFields(),
                    SizedBox(height: 30),
                    footer,
                  ],
                ),
              ),
            ),
          ),

          // ✅ For web/tablet split panel view
          if (kIsWeb && mq.width > 800)
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  width: showSearchPanel ? 500 : 0,
                  child: showSearchPanel
                      ? Material(
                          color: Colors.transparent,
                          child: Container(
                            color: Colors.transparent,
                            child: WebSearchClientPanel(
                              onClose: toggleSearchPanel,
                              onClientTap: (client) {
                                setState(() {
                                  selectedClient = client;
                                });
                              },
                              selectedClient: selectedClient,
                            ),
                          ),
                        )
                      : null,
                ),

                // ✅ Right pane (client detail)
                if (showSearchPanel && selectedClient != null)
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          left: BorderSide(color: Colors.grey, width: 1.5),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: _FetchedClientDetailCard(
                          client: selectedClient,
                          onBack: () {
                            setState(() {
                              selectedClient = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
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
  bool isLoading = false;

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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            context: context,
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
                color: Colors.white70,
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
                context: context,
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
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            context: context,
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
                color: Colors.white70,
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
            context: context,
          ),
          SizedBox(height: fieldSpacing),
          // Plan Type
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Plan Type",
              style: TextStyle(
                color: Colors.white70,
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
                                color: Colors.white70,
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
                                context: context,
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
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          AbsorbPointer(
                            child: customTextfield.customTextfield(
                              context: context,
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
                          color: Colors.white70,
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
                          context: context,
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
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    AbsorbPointer(
                      child: customTextfield.customTextfield(
                        context: context,
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
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 6),
          customTextfield.customTextfield(
            context: context,
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
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          customTextfield.customTextfield(
                            context: context,
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
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          customTextfield.customTextfield(
                            context: context,
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
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: fieldSpacing),
                    customTextfield.customTextfield(
                      context: context,
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
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    customTextfield.customTextfield(
                      context: context,
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
                color: Colors.white70,
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
                context: context,
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
                color: Colors.white70,
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
            context: context, // context is now required and first
            labelWidget: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Text(
                    'Submit',
                    style: TextStyle(color: MyColor.background, fontSize: 18),
                  ),
            onTap: () async {
              setState(() {
                isLoading = true;
              });
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
              setState(() {
                isLoading = false;
              });
            },
          ),
        ],
      ),
    );
  }
}

// class _SearchClientDialog extends StatefulWidget {
//   @override
//   State<_SearchClientDialog> createState() => _SearchClientDialogState();
// }

// class _SearchClientDialogState extends State<_SearchClientDialog> {
//   final searchController = TextEditingController();
//   dynamic selectedClient;

//   String formatDateForList(String date) {
//     try {
//       if (date.contains('-')) {
//         final d = DateTime.parse(date);
//         return DateFormat('dd MMM yyyy').format(d);
//       } else if (date.contains('/')) {
//         final parts = date.split('/');
//         if (parts.length == 3) {
//           final d = DateTime(
//             int.parse(parts[2]),
//             int.parse(parts[1]),
//             int.parse(parts[0]),
//           );
//           return DateFormat('dd MMM yyyy').format(d);
//         }
//       }
//     } catch (_) {}
//     return date;
//   }

//   int getRemainingDays(String startDate, String endDate) {
//     try {
//       DateTime start, end;
//       if (startDate.contains('-')) {
//         start = DateTime.parse(startDate);
//       } else if (startDate.contains('/')) {
//         final parts = startDate.split('/');
//         start = DateTime(
//           int.parse(parts[2]),
//           int.parse(parts[1]),
//           int.parse(parts[0]),
//         );
//       } else {
//         return 0;
//       }
//       if (endDate.contains('-')) {
//         end = DateTime.parse(endDate);
//       } else if (endDate.contains('/')) {
//         final parts = endDate.split('/');
//         end = DateTime(
//           int.parse(parts[2]),
//           int.parse(parts[1]),
//           int.parse(parts[0]),
//         );
//       } else {
//         return 0;
//       }

//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);
//       final startDay = DateTime(start.year, start.month, start.day);
//       final endDay = DateTime(end.year, end.month, end.day);

//       if (today.isBefore(startDay)) {
//         final totalDays = endDay.difference(startDay).inDays;
//         return totalDays >= 0 ? totalDays : 0;
//       } else {
//         final remain = endDay.difference(today).inDays;
//         return remain >= 0 ? remain : 0;
//       }
//     } catch (_) {
//       return 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context).size;
//     final auth = FirebaseAuth.instance;
//     final firebaseFirestore = FirebaseFirestore.instance.collection('Admin');

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       child: Container(
//         width: 500,
//         height: mq.height * 0.8,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//         child: selectedClient == null
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           "Search Client",
//                           style: TextStyle(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.onSurface.withOpacity(.7),
//                             fontWeight: FontWeight.w700,
//                             fontSize: 20,
//                             letterSpacing: 0.2,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Material(
//                     elevation: 1,
//                     borderRadius: BorderRadius.circular(12),
//                     color: Theme.of(context).cardColor,
//                     child: TextField(
//                       controller: searchController,
//                       keyboardType: TextInputType.text,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: Theme.of(
//                             context,
//                           ).iconTheme.color?.withOpacity(0.7),
//                         ),
//                         hintText: "Type client name or number...",
//                         hintStyle: TextStyle(
//                           color: Theme.of(context).hintColor,
//                           fontSize: 14,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Theme.of(context).cardColor,
//                         contentPadding: EdgeInsets.symmetric(
//                           vertical: 0,
//                           horizontal: 0,
//                         ),
//                       ),
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                       onChanged: (_) => setState(() {}),
//                     ),
//                   ),
//                   SizedBox(height: 26),
//                   Text(
//                     "Clients List",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withOpacity(.7),
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Expanded(
//                     child: StreamBuilder(
//                       stream: firebaseFirestore
//                           .doc(auth.currentUser!.uid)
//                           .collection('ClientCollection')
//                           .snapshots(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(child: CircularProgressIndicator());
//                         } else if (snapshot == null || !snapshot.hasData) {
//                           return Center(child: Text('No Data Found'));
//                         } else if (snapshot.hasError) {
//                           return Center(
//                             child: Text('❌ Error: ${snapshot.error}'),
//                           );
//                         }

//                         var clients = snapshot.data!.docs;
//                         final query = searchController.text
//                             .trim()
//                             .toLowerCase();

//                         final filtered = query.isEmpty
//                             ? clients
//                             : clients.where((c) {
//                                 final name = (c['name'] ?? '')
//                                     .toString()
//                                     .toLowerCase();
//                                 final contact = (c['contact'] ?? '')
//                                     .toString()
//                                     .toLowerCase();
//                                 final whatsapp = (c['whatsapp'] ?? '')
//                                     .toString()
//                                     .toLowerCase();

//                                 return name.contains(query) ||
//                                     contact.contains(query) ||
//                                     whatsapp.contains(query);
//                               }).toList();

//                         if (filtered.isEmpty) {
//                           return Center(child: Text('No clients found.'));
//                         }

//                         return ListView.builder(
//                           itemCount: filtered.length,
//                           itemBuilder: (context, index) {
//                             var client = filtered[index];
//                             final joined = formatDateForList(
//                               client['startDate'],
//                             );
//                             final end = formatDateForList(client['endDate']);
//                             final remain = getRemainingDays(
//                               client['startDate'],
//                               client['endDate'],
//                             );

//                             return Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).cardColor,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Theme.of(context).dividerColor,
//                                 ),
//                               ),
//                               child: ListTile(
//                                 leading: CircleAvatar(
//                                   backgroundColor: Colors.red.shade100,
//                                   child: Icon(
//                                     Icons.person,
//                                     color: Colors.red.shade700,
//                                   ),
//                                 ),
//                                 title: Text(
//                                   client['name'],
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 15,
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onSurface,
//                                   ),
//                                 ),
//                                 subtitle: Padding(
//                                   padding: const EdgeInsets.only(top: 2.0),
//                                   child: Text(
//                                     'Remain: $remain days\nJoined: $joined | End: $end',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Theme.of(
//                                         context,
//                                       ).colorScheme.onSurface.withOpacity(0.7),
//                                       height: 1.3,
//                                     ),
//                                   ),
//                                 ),
//                                 trailing: Icon(
//                                   Icons.chevron_right,
//                                   color: Theme.of(
//                                     context,
//                                   ).iconTheme.color?.withOpacity(0.5),
//                                 ),
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 6,
//                                 ),
//                                 onTap: () {
//                                   setState(() {
//                                     selectedClient = client;
//                                   });
//                                 },
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             : Stack(
//                 children: [
//                   SingleChildScrollView(
//                     child: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.only(top: 8, bottom: 16),
//                       child: _FetchedClientDetailCard(
//                         client: selectedClient,
//                         onBack: () => setState(() => selectedClient = null),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 0,
//                     right: 0,
//                     child: IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }

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

  int getRemainingDays(String startDate, String endDate) {
    try {
      DateTime start, end;
      if (startDate.contains('-')) {
        start = DateTime.parse(startDate);
      } else if (startDate.contains('/')) {
        final parts = startDate.split('/');
        start = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return 0;
      }
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
      final startDay = DateTime(start.year, start.month, start.day);
      final endDay = DateTime(end.year, end.month, end.day);

      if (today.isBefore(startDay)) {
        final totalDays = endDay.difference(startDay).inDays;
        return totalDays >= 0 ? totalDays : 0;
      } else {
        final remain = endDay.difference(today).inDays;
        return remain >= 0 ? remain : 0;
      }
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                        fillColor: Theme.of(context).cardColor,
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
                    "Clientss",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(.7),
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

                        // Filter based on search
                        final filtered = query.isEmpty
                            ? clients
                            : clients.where((c) {
                                final name = (c['name'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final contact = (c['contact'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                final whatsapp = (c['whatsapp'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return name.contains(query) ||
                                    contact.contains(query) ||
                                    whatsapp.contains(query);
                              }).toList();

                        if (filtered.isEmpty) {
                          return Center(child: Text('No clients found.'));
                        }

                        // Calculate clients added this month count
                        final now = DateTime.now();
                        final monthlyAddedClients = clients.where((c) {
                          dynamic startDate = c['startDate'];
                          DateTime? dt;
                          if (startDate is Timestamp) {
                            dt = startDate.toDate();
                          } else if (startDate is DateTime) {
                            dt = startDate;
                          } else if (startDate is String) {
                            try {
                              dt = DateTime.parse(startDate);
                            } catch (_) {
                              dt = null;
                            }
                          }
                          if (dt == null) return false;
                          return dt.year == now.year && dt.month == now.month;
                        }).toList();

                        return Column(
                          children: [
                            // Your requested Row showing counts
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 70,
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Clients (This Month)"),
                                        Text(
                                          "${monthlyAddedClients.length}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 70,
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Total Clients"),
                                        Text(
                                          "${filtered.length}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(
                              color: Theme.of(context).dividerColor,
                              thickness: 1.2,
                            ),
                            // Client list
                            Expanded(
                              child: ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  var client = filtered[index];
                                  final joined = formatDateForList(
                                    client['startDate'],
                                  );
                                  final end = formatDateForList(
                                    client['endDate'],
                                  );
                                  final remain = getRemainingDays(
                                    client['startDate'],
                                    client['endDate'],
                                  );
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      title: Text(
                                        client['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 2.0,
                                        ),
                                        child: Text(
                                          'Remain: $remain days\nJoined: $joined | End: $end',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
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
                              ),
                            ),
                          ],
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

  String formatDate(dynamic date) {
    try {
      if (date is DateTime) {
        return DateFormat('dd MMM yyyy').format(date);
      } else if (date is String) {
        if (date.contains('-')) {
          return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
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
      }
    } catch (_) {}
    return date.toString(); // fallback
  }

  @override
  Widget build(BuildContext context) {
    final joined = formatDate(client['startDate']);
    final end = formatDate(client['endDate']);
    final paymentDate = formatDate(client['paymentDate']);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red[100],
                  child: Icon(Icons.person, color: Colors.red[700], size: 32),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Text(
                    client['name'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white70,
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
            SizedBox(height: 18),

            /// Contact Info
            _infoRow(
              icon: Icons.phone,
              label: "Contact",
              value: client['contact'],
              iconColor: Colors.red[300],
            ),
            _infoRowImage(
              asset: 'assets/images/whatsapp.png',
              label: "WhatsApp",
              value: client['whatsapp'],
            ),
            _infoRow(
              icon: Icons.calendar_today,
              label: "Plan",
              value: client['planType'],
              iconColor: Colors.blue[300],
            ),
            _dualLabelRow(
              icon: Icons.date_range,
              firstLabel: "Start",
              firstValue: joined,
              secondLabel: "End",
              secondValue: end,
              iconColor: Colors.orange[300],
            ),
            _infoRow(
              icon: Icons.attach_money,
              label: "Total",
              value: client['totalAmount'],
              iconColor: Colors.teal[400],
            ),
            _infoRow(
              icon: Icons.attach_money,
              label: "Paid",
              value: client['paidAmount'],
              iconColor: Colors.teal[400],
            ),
            _infoRow(
              icon: Icons.attach_money,
              label: "Remain",
              value: client['remainingAmount'],
              iconColor: Colors.teal[400],
            ),
            _infoRow(
              icon: Icons.payment,
              label: "Payment Date",
              value: paymentDate,
              iconColor: Colors.red[300],
            ),
            _infoRow(
              icon: Icons.verified,
              label: "Status",
              value: client['paymentStatus'],
              iconColor: Colors.blueGrey[400],
            ),

            SizedBox(height: 30),

            /// Back Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
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
                  shadowColor: Colors.red.withOpacity(0.18),
                ),
                icon: Icon(Icons.close, color: Colors.redAccent),
                label: Text("Close", style: TextStyle(color: Colors.redAccent)),
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generic info row with Icon + Label + Value
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String? value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey),
          SizedBox(width: 12),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Info row with custom image instead of icon (for WhatsApp)
  Widget _infoRowImage({
    required String asset,
    required String label,
    required String? value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Image.asset(asset, height: 22, width: 22),
          SizedBox(width: 12),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Dual value row (for Start and End dates)
  Widget _dualLabelRow({
    required IconData icon,
    required String firstLabel,
    required String? firstValue,
    required String secondLabel,
    required String? secondValue,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(
                        text: "$firstLabel: ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: firstValue ?? '',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(
                        text: "$secondLabel: ",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: secondValue ?? '',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WebSearchClientPanel extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(dynamic)? onClientTap;
  final dynamic selectedClient;
  const WebSearchClientPanel({
    this.onClose,
    this.onClientTap,
    this.selectedClient,
  });

  @override
  State<WebSearchClientPanel> createState() => _WebSearchClientPanelState();
}

class _WebSearchClientPanelState extends State<WebSearchClientPanel> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final auth = FirebaseAuth.instance;
    final firebaseFirestore = FirebaseFirestore.instance.collection('Admin');

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // Search bar and close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Search Client",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
              child: TextField(
                controller: searchController,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                  ),
                  hintText: "Type client name or number...",
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              "Clients",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List of clients
          Expanded(
            child: StreamBuilder(
              stream: firebaseFirestore
                  .doc(auth.currentUser!.uid)
                  .collection('ClientCollection')
                  .snapshots(),
              builder: (context, snapshot) {
                String formatDate(dynamic date) {
                  try {
                    if (date is DateTime) {
                      return DateFormat('dd MMM yyyy').format(date);
                    } else if (date is String) {
                      if (date.contains('-')) {
                        return DateFormat(
                          'dd MMM yyyy',
                        ).format(DateTime.parse(date));
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
                    }
                  } catch (_) {}
                  return date.toString(); // fallback
                }

                int calculateRemainingDays(dynamic endDate) {
                  try {
                    DateTime end;
                    if (endDate is DateTime) {
                      end = endDate;
                    } else {
                      end = DateTime.parse(endDate.toString());
                    }
                    final now = DateTime.now();
                    return end.difference(now).inDays;
                  } catch (_) {
                    return 0;
                  }
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot == null || !snapshot.hasData) {
                  return Center(
                    child: Text(
                      'No Data Found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '❌ Error: ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }

                var clients = snapshot.hasData ? snapshot.data!.docs : [];
                final query = searchController.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? clients
                    : clients.where((c) {
                        final name = (c['name'] ?? '').toString().toLowerCase();
                        final contact = (c['contact'] ?? '')
                            .toString()
                            .toLowerCase();
                        final whatsapp = (c['whatsapp'] ?? '')
                            .toString()
                            .toLowerCase();
                        // Search by name, contact, or whatsapp number
                        return name.contains(query) || contact.contains(query);
                      }).toList();

                // Get the current date (for current month/year comparison)
                final now = DateTime.now();
                final currentYear = now.year;
                final currentMonth = now.month;

                // Calculate how many clients were added in the current month
                final monthlyAddedClients = filtered.where((client) {
                  try {
                    final startDate = client['startDate'];

                    // Ensure startDate is in DateTime format
                    DateTime startDateObj;

                    // Handle both String and DateTime formats for 'startDate'
                    if (startDate is String) {
                      // Try parsing as String (e.g., 'dd/MM/yyyy' format)
                      final parts = startDate.split('/');
                      if (parts.length == 3) {
                        startDateObj = DateTime(
                          int.parse(parts[2]), // Year
                          int.parse(parts[1]), // Month
                          int.parse(parts[0]), // Day
                        );
                      } else {
                        // Try parsing it as a standard ISO string (e.g., "2022-01-01")
                        startDateObj = DateTime.parse(startDate);
                      }
                    } else if (startDate is DateTime) {
                      startDateObj = startDate;
                    } else {
                      return false; // Invalid date
                    }

                    // Check if the startDate is in the current month and year
                    return startDateObj.year == currentYear &&
                        startDateObj.month == currentMonth;
                  } catch (_) {
                    return false;
                  }
                }).toList();

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: 70,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Clients (This Month)"),
                                  Text(
                                    "${monthlyAddedClients.length}",
                                  ), // Show count of clients added this month
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: 70,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Total Clients"),
                                  Text(
                                    "${filtered.length}",
                                  ), // Show total clients in list
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 1.2,
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered
                              .length, // Show all filtered clients in list
                          itemBuilder: (context, index) {
                            var client = filtered[index];
                            final joined = formatDate(client['startDate']);
                            final end = formatDate(client['endDate']);
                            final remaining = calculateRemainingDays(
                              client['endDate'],
                            );

                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: 12,
                                left: 8,
                                right: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                title: Text(
                                  client['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    "Remaining: ${remaining >= 0 ? '$remaining days' : 'Expired'} \nJoined: $joined | End: $end\n",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Theme.of(
                                    context,
                                  ).iconTheme.color?.withOpacity(0.5),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                onTap: () {
                                  if (widget.onClientTap != null) {
                                    widget.onClientTap!(client);
                                  }
                                },
                                selected:
                                    widget.selectedClient != null &&
                                    widget.selectedClient['id'] == client['id'],
                                selectedTileColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.08),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
