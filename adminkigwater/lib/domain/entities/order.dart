// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Order {
  String id;
  String customerId;
  String delivererId;
  String waterType;
  int quantity;
  String? geolocationId;
  String paymentMethod;
  String
      status; // 'pending', 'accepted', 'in_progress', 'completed', 'canceled'
  String createdAt;
  String? updatedAt;
  String? comment;
  List<String> idsOfPossibleDeliverers;
  List<String> idsOfNotPossibleDeliverers;
  bool? isFinish;
  bool? isLitre;
  Order(
      {required this.id,
      required this.customerId,
      required this.delivererId,
      required this.waterType,
      required this.quantity,
      this.geolocationId,
      required this.paymentMethod,
      required this.status,
      required this.createdAt,
      this.updatedAt,
      this.comment,
      required this.idsOfPossibleDeliverers,
      required this.idsOfNotPossibleDeliverers,
      this.isFinish,
      this.isLitre});

  Order copyWith(
      {String? id,
      String? customerId,
      String? delivererId,
      String? waterType,
      int? quantity,
      String? geolocationId,
      String? paymentMethod,
      String? status,
      String? createdAt,
      String? updatedAt,
      String? comment,
      List<String>? idsOfPossibleDeliverers,
      List<String>? idsOfNotPossibleDeliverers,
      bool? isFinish,
      bool? isLitre}) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      delivererId: delivererId ?? this.delivererId,
      waterType: waterType ?? this.waterType,
      quantity: quantity ?? this.quantity,
      geolocationId: geolocationId ?? this.geolocationId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      comment: comment ?? this.comment,
      idsOfPossibleDeliverers:
          idsOfPossibleDeliverers ?? this.idsOfPossibleDeliverers,
      idsOfNotPossibleDeliverers:
          idsOfNotPossibleDeliverers ?? this.idsOfNotPossibleDeliverers,
      isFinish: isFinish ?? this.isFinish,
      isLitre: isLitre ?? this.isLitre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'customerId': customerId,
      'delivererId': delivererId,
      'waterType': waterType,
      'quantity': quantity,
      'geolocationId': geolocationId,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'comment': comment,
      'idsOfPossibleDeliverers': idsOfPossibleDeliverers,
      'idsOfNotPossibleDeliverers': idsOfNotPossibleDeliverers,
      'isFinish': isFinish,
      'isLitre': isLitre
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
        id: map['id'] as String,
        customerId: map['customerId'] as String,
        delivererId: map['delivererId'] as String,
        waterType: map['waterType'] as String,
        quantity: map['quantity'] as int,
        geolocationId: map['geolocationId'] != null
            ? map['geolocationId'] as String
            : null,
        paymentMethod: map['paymentMethod'] as String,
        status: map['status'] as String,
        createdAt: map['createdAt'] as String,
        updatedAt: map['updatedAt'] != null ? map['updatedAt'] as String : null,
        comment: map['comment'] != null ? map['comment'] as String : null,
        idsOfPossibleDeliverers: List<String>.from(
          (map['idsOfPossibleDeliverers'] as List<dynamic>)
              .map((e) => e as String),
        ),
        idsOfNotPossibleDeliverers: List<String>.from(
          (map['idsOfNotPossibleDeliverers'] as List<dynamic>)
              .map((e) => e as String),
        ),
        isFinish: map['isFinish'] as bool?,
        isLitre: map['isLitre'] as bool?);
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, delivererId: $delivererId, waterType: $waterType, quantity: $quantity, geolocationId: $geolocationId, paymentMethod: $paymentMethod, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, comment: $comment, idsOfPossibleDeliverers: $idsOfPossibleDeliverers, idsOfNotPossibleDeliverers: $idsOfNotPossibleDeliverers)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.customerId == customerId &&
        other.delivererId == delivererId &&
        other.waterType == waterType &&
        other.quantity == quantity &&
        other.geolocationId == geolocationId &&
        other.paymentMethod == paymentMethod &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.comment == comment &&
        listEquals(other.idsOfPossibleDeliverers, idsOfPossibleDeliverers) &&
        listEquals(
            other.idsOfNotPossibleDeliverers, idsOfNotPossibleDeliverers) &&
        other.isFinish == isFinish &&
        other.isLitre == isLitre;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        customerId.hashCode ^
        delivererId.hashCode ^
        waterType.hashCode ^
        quantity.hashCode ^
        geolocationId.hashCode ^
        paymentMethod.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        comment.hashCode ^
        idsOfPossibleDeliverers.hashCode ^
        idsOfNotPossibleDeliverers.hashCode;
  }
}
