// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Review {
  String id;
  String toWhomUserId;
  String fromWhomUserId;
  String orderId;
  double rating;
  bool isDeliverer;
  String comment;
  String date;
  bool? isReviewForCanceledOrder;
  Review({
    required this.id,
    required this.toWhomUserId,
    required this.fromWhomUserId,
    required this.orderId,
    required this.rating,
    required this.isDeliverer,
    required this.comment,
    required this.date,
    required this.isReviewForCanceledOrder,
  });

  Review copyWith({
    String? id,
    String? toWhomUserId,
    String? fromWhomUserId,
    String? orderId,
    double? rating,
    bool? isDeliverer,
    String? comment,
    String? date,
    bool? isReviewForCanceledOrder,
  }) {
    return Review(
      id: id ?? this.id,
      toWhomUserId: toWhomUserId ?? this.toWhomUserId,
      fromWhomUserId: fromWhomUserId ?? this.fromWhomUserId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      isDeliverer: isDeliverer ?? this.isDeliverer,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      isReviewForCanceledOrder: isReviewForCanceledOrder ?? this.isReviewForCanceledOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'toWhomUserId': toWhomUserId,
      'fromWhomUserId': fromWhomUserId,
      'orderId': orderId,
      'rating': rating,
      'isDeliverer': isDeliverer,
      'comment': comment,
      'date': date,
      'isReviewForCanceledOrder': isReviewForCanceledOrder,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
  return Review(
    id: map['id'] as String,
    toWhomUserId: map['toWhomUserId'] as String,
    fromWhomUserId: map['fromWhomUserId'] as String,
    orderId: map['orderId'] as String,
    rating: (map['rating'] is int) ? (map['rating'] as int).toDouble() : map['rating'] as double,
    isDeliverer: map['isDeliverer'] as bool,
    comment: map['comment'] as String,
    date: map['date'] as String,
    isReviewForCanceledOrder: map['isReviewForCanceledOrder'] != null ? map['isReviewForCanceledOrder'] as bool : null,
  );
}


  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Review(id: $id, toWhomUserId: $toWhomUserId, fromWhomUserId: $fromWhomUserId, orderId: $orderId, rating: $rating, isDeliverer: $isDeliverer, comment: $comment, date: $date, isReviewForCanceledOrder: $isReviewForCanceledOrder)';
  }

  @override
  bool operator ==(covariant Review other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.toWhomUserId == toWhomUserId &&
      other.fromWhomUserId == fromWhomUserId &&
      other.orderId == orderId &&
      other.rating == rating &&
      other.isDeliverer == isDeliverer &&
      other.comment == comment &&
      other.date == date &&
      other.isReviewForCanceledOrder == isReviewForCanceledOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      toWhomUserId.hashCode ^
      fromWhomUserId.hashCode ^
      orderId.hashCode ^
      rating.hashCode ^
      isDeliverer.hashCode ^
      comment.hashCode ^
      date.hashCode ^
      isReviewForCanceledOrder.hashCode;
  }
}
