// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Order {
  String id;
  String customerId;
  String delivererId;
  String waterType;
  int quantity;
  String address;
  String paymentMethod;
  String
      status; // 'pending', 'accepted', 'in_progress', 'completed', 'canceled'
  String createdAt;
  String? updatedAt;
  String? comment;
  List<String> idsOfPossibleDeliverers;
  List<String> idsOfNotPossibleDeliverers;

  Order({
    required this.id,
    required this.customerId,
    required this.delivererId,
    required this.waterType,
    required this.quantity,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.comment,
    required this.idsOfPossibleDeliverers,
    required this.idsOfNotPossibleDeliverers,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'delivererId': delivererId,
      'waterType': waterType,
      'quantity': quantity,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'comment': comment,
      'idsOfPossibleDeliverers': idsOfPossibleDeliverers,
      'idsOfNotPossibleDeliverers': idsOfNotPossibleDeliverers,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      delivererId: map['delivererId'] as String? ?? '',
      waterType: map['waterType'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      address: map['address'] as String? ?? '',
      paymentMethod: map['paymentMethod'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt: map['updatedAt'] as String?,
      comment: map['comment'] as String?,
      idsOfPossibleDeliverers: _parseStringList(map['idsOfPossibleDeliverers']),
      idsOfNotPossibleDeliverers:
          _parseStringList(map['idsOfNotPossibleDeliverers']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);
  Order copyWith({
    String? id,
    String? customerId,
    String? delivererId,
    String? waterType,
    int? quantity,
    String? address,
    String? paymentMethod,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? comment,
    List<String>? idsOfPossibleDeliverers,
    List<String>? idsOfNotPossibleDeliverers,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      delivererId: delivererId ?? this.delivererId,
      waterType: waterType ?? this.waterType,
      quantity: quantity ?? this.quantity,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comment: comment ?? this.comment,
      idsOfPossibleDeliverers:
          idsOfPossibleDeliverers ?? this.idsOfPossibleDeliverers,
      idsOfNotPossibleDeliverers:
          idsOfNotPossibleDeliverers ?? this.idsOfNotPossibleDeliverers,
    );
  }
}

List<String> _parseStringList(dynamic list) {
  if (list == null) {
    return [];
  }

  if (list is List<dynamic>) {
    return list.map((e) => e.toString()).toList();
  }

  return [];
}
