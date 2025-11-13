class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final bool isPrimary;
  final bool smsEnabled;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.isPrimary = false,
    this.smsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
      'isPrimary': isPrimary,
      'smsEnabled': smsEnabled,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relation: map['relation'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
      smsEnabled: map['smsEnabled'] ?? true,
    );
  }
}
