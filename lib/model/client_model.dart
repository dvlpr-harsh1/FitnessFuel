class ClientModel {
  String id;
  String name;
  String contact;
  String whatsapp;
  String birthDate;
  String startDate;
  String endDate;
  String planType;
  String paidAmount;
  String remainingAmount;
  String totalAmount;
  String paymentDate;
  String paymentStatus;
  String? pdfUrl;

  ClientModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.whatsapp,
    required this.birthDate,
    required this.startDate,
    required this.endDate,
    required this.planType,
    required this.paidAmount,
    required this.remainingAmount,
    required this.totalAmount,
    required this.paymentDate,
    required this.paymentStatus,
    this.pdfUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'whatsapp': whatsapp,
      'birthDate': birthDate,
      'startDate': startDate,
      'endDate': endDate,
      'planType': planType,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'totalAmount': totalAmount,
      'paymentDate': paymentDate,
      'paymentStatus': paymentStatus,
      if (pdfUrl != null) 'pdfUrl': pdfUrl,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      birthDate: map['birthDate'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      planType: map['planType'] ?? '',
      paidAmount: map['paidAmount'] ?? '',
      remainingAmount: map['remainingAmount'] ?? '',
      totalAmount: map['totalAmount'] ?? '',
      paymentDate: map['paymentDate'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      pdfUrl: map['pdfUrl'],
    );
  }
}
