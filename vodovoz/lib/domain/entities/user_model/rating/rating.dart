import 'dart:convert';

import 'package:flutter/foundation.dart';

class Rating {
  String id;
  String userId;
  double overallRating;
  double delivererRating;
  List<String> reviewsId;
  String lastUpdated;
  Rating({
    required this.id,
    required this.userId,
    required this.overallRating,
    required this.delivererRating,
    required this.reviewsId,
    required this.lastUpdated,
  });

  Rating copyWith({
    String? id,
    String? userId,
    double? overallRating,
    double? delivererRating,
    List<String>? reviewsId,
    String? lastUpdated,
  }) {
    return Rating(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      overallRating: overallRating ?? this.overallRating,
      delivererRating: delivererRating ?? this.delivererRating,
      reviewsId: reviewsId ?? this.reviewsId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'overallRating': overallRating,
      'delivererRating': delivererRating,
      'reviewsId': reviewsId,
      'lastUpdated': lastUpdated,
    };
  }

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      id: map['id'] as String,
      userId: map['userId'] as String,
      overallRating: (map['overallRating'] is int)
          ? (map['overallRating'] as int).toDouble()
          : map['overallRating'] as double,
      delivererRating: (map['delivererRating'] is int)
          ? (map['delivererRating'] as int).toDouble()
          : map['delivererRating'] as double,
      reviewsId: List<String>.from(
        (map['reviewsId'] as List<dynamic>).map((e) => e as String),
      ),
      lastUpdated: map['lastUpdated'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Rating.fromJson(String source) =>
      Rating.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Rating(id: $id, userId: $userId, overallRating: $overallRating, delivererRating: $delivererRating, reviewsId: $reviewsId, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(covariant Rating other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.overallRating == overallRating &&
        other.delivererRating == delivererRating &&
        listEquals(other.reviewsId, reviewsId) &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        overallRating.hashCode ^
        delivererRating.hashCode ^
        reviewsId.hashCode ^
        lastUpdated.hashCode;
  }
}
