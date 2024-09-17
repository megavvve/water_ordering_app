class Deliverer {
  final String userId;
  String regCert;
  String license;
  String capacity;
  String waterType;
  bool? isAvailable;

  Deliverer({
    required this.userId,
    required this.regCert,
    required this.license,
    required this.capacity,
    required this.waterType,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'regCert': regCert,
        'license': license,
        'capacity': capacity,
        'waterType': waterType,
        'isAvailable': isAvailable,
      };

  static Deliverer fromJson(Map<String, dynamic> json) {
    return Deliverer(
      userId: json['userId'],
      regCert: json['regCert'],
      license: json['license'],
      capacity: json['capacity'],
      waterType: json['waterType'],
      isAvailable: json['isAvailable'],
    );
  }
}
