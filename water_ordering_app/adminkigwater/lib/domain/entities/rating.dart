// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Rating {
  String id;
  String userId;
  String orderId;
  double rating;
  String comment;
  String date;
  Rating({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Rating copyWith({
    String? id,
    String? userId,
    String? orderId,
    double? rating,
    String? comment,
    String? date,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      userId: map['userId'] as String,
      orderId: map['orderId'] as String,
      rating: map['rating'] as double,
      comment: map['comment'] as String,
      date: map['date'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) =>
      Rating.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, orderId: $orderId, rating: $rating, comment: $comment, date: $date)';
  }

  @override
  bool operator ==(covariant Rating other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.orderId == orderId &&
        other.rating == rating &&
        other.comment == comment &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        orderId.hashCode ^
        rating.hashCode ^
        comment.hashCode ^
        date.hashCode;
  }
}
