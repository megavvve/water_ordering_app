class Deliverer {
  final String userId;
  String regCert;
  String license;
  String capacity;
  String waterType;
  bool? isAvailable;
  int pricePerPiece; 
  int pricePerLiter;
  int balance; // Баланс водовоза

  Deliverer({
    required this.userId,
    required this.regCert,
    required this.license,
    required this.capacity,
    required this.waterType,
    required this.isAvailable,
    required this.pricePerPiece,
    required this.pricePerLiter,
    required this.balance,
  });


  Deliverer copyWith({
    String? userId,
    String? regCert,
    String? license,
    String? capacity,
    String? waterType,
    bool? isAvailable,
    int? pricePerPiece,
    int? pricePerLiter,
    int? balance,
  }) {
    return Deliverer(
      userId: userId ?? this.userId,
      regCert: regCert ?? this.regCert,
      license: license ?? this.license,
      capacity: capacity ?? this.capacity,
      waterType: waterType ?? this.waterType,
      isAvailable: isAvailable ?? this.isAvailable,
      pricePerPiece: pricePerPiece ?? this.pricePerPiece,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'regCert': regCert,
      'license': license,
      'capacity': capacity,
      'waterType': waterType,
      'isAvailable': isAvailable,
      'pricePerPiece': pricePerPiece,
      'pricePerLiter': pricePerLiter,
      'balance': balance,
    };
  }

  factory Deliverer.fromJson(Map<String, dynamic> map) {
    return Deliverer(
      userId: map['userId'] as String,
      regCert: map['regCert'] as String,
      license: map['license'] as String,
      capacity: map['capacity'] as String,
      waterType: map['waterType'] as String,
      isAvailable: map['isAvailable'] != null ? map['isAvailable'] as bool : null,
      pricePerPiece: map['pricePerPiece'] ==null?0:  map['pricePerPiece']as int,
      pricePerLiter: map['pricePerLiter']==null?0:  map['pricePerLiter']as int,
      balance: map['balance']==null?0:  map['balance']as int,
    );
  }


  @override
  String toString() {
    return 'Deliverer(userId: $userId, regCert: $regCert, license: $license, capacity: $capacity, waterType: $waterType, isAvailable: $isAvailable, pricePerPiece: $pricePerPiece, pricePerLiter: $pricePerLiter, balance: $balance)';
  }

  @override
  bool operator ==(covariant Deliverer other) {
    if (identical(this, other)) return true;
  
    return 
      other.userId == userId &&
      other.regCert == regCert &&
      other.license == license &&
      other.capacity == capacity &&
      other.waterType == waterType &&
      other.isAvailable == isAvailable &&
      other.pricePerPiece == pricePerPiece &&
      other.pricePerLiter == pricePerLiter &&
      other.balance == balance;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      regCert.hashCode ^
      license.hashCode ^
      capacity.hashCode ^
      waterType.hashCode ^
      isAvailable.hashCode ^
      pricePerPiece.hashCode ^
      pricePerLiter.hashCode ^
      balance.hashCode;
  }
}
