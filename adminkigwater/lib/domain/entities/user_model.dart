// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  String userId;
  String name;
  String phoneNumber;
  String? fileId;
  String city;
  String userType; // 'user', 'deliverer', 'advertiser', 'admin'
  String? ratingId;
  String? token;
  bool? isOnline;
  UserModel({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.fileId,
    required this.city,
    required this.userType,
    required this.ratingId,
    this.token,
    this.isOnline,
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? phoneNumber,
    String? fileId,
    String? city,
    String? userType,
    String? ratingId,
    String? token,
    bool? isOnline,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fileId: fileId ?? this.fileId,
      city: city ?? this.city,
      userType: userType ?? this.userType,
      ratingId: ratingId ?? this.ratingId,
      token: token ?? this.token,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'fileId': fileId,
      'city': city,
      'userType': userType,
      'ratingId': ratingId,
      'token': token,
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] as String,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      fileId: map['fileId'] != null ? map['fileId'] as String : null,
      city: map['city'] as String,
      userType: map['userType'] as String,
      ratingId: map['ratingId'] != null ? map['ratingId'] as String : null,
      token: map['token'] != null ? map['token'] as String : null,
      isOnline: map['isOnline'] != null ? map['isOnline'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, phoneNumber: $phoneNumber, fileId: $fileId, city: $city, userType: $userType, ratingId: $ratingId, token: $token, isOnline: $isOnline)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.fileId == fileId &&
        other.city == city &&
        other.userType == userType &&
        other.ratingId == ratingId &&
        other.token == token &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        fileId.hashCode ^
        city.hashCode ^
        userType.hashCode ^
        ratingId.hashCode ^
        token.hashCode ^
        isOnline.hashCode;
  }
}
