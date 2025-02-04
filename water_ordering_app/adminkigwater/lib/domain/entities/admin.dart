// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Admin {
  final String id;
  String name;
  final String login;
  final String password;
  bool permissionForUsers;
  bool permissionForGeo;
  bool permissionForStats;
  bool permissionForDrivers;
  bool permissionForAdmins;
  Admin({
    required this.id,
    required this.name,
    required this.login,
    required this.password,
    required this.permissionForUsers,
    required this.permissionForGeo,
    required this.permissionForStats,
    required this.permissionForDrivers,
    required this.permissionForAdmins,
  });

  Admin copyWith({
    String? id,
    String? name,
    String? login,
    String? password,
    bool? permissionForUsers,
    bool? permissionForGeo,
    bool? permissionForStats,
    bool? permissionForDrivers,
    bool? permissionForAdmins,
  }) {
    return Admin(
      id: id ?? this.id,
      name: name ?? this.name,
      login: login ?? this.login,
      password: password ?? this.password,
      permissionForUsers: permissionForUsers ?? this.permissionForUsers,
      permissionForGeo: permissionForGeo ?? this.permissionForGeo,
      permissionForStats: permissionForStats ?? this.permissionForStats,
      permissionForDrivers: permissionForDrivers ?? this.permissionForDrivers,
      permissionForAdmins: permissionForAdmins ?? this.permissionForAdmins,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'login': login,
      'password': password,
      'permissionForUsers': permissionForUsers,
      'permissionForGeo': permissionForGeo,
      'permissionForStats': permissionForStats,
      'permissionForDrivers': permissionForDrivers,
      'permissionForAdmins': permissionForAdmins,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['id'] as String,
      name: map['name'] as String,
      login: map['login'] as String,
      password: map['password'] as String,
      permissionForUsers: map['permissionForUsers'] as bool,
      permissionForGeo: map['permissionForGeo'] as bool,
      permissionForStats: map['permissionForStats'] as bool,
      permissionForDrivers: map['permissionForDrivers'] as bool,
      permissionForAdmins: map['permissionForAdmins'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Admin.fromJson(String source) =>
      Admin.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Admin(id: $id, name: $name, login: $login, password: $password, permissionForUsers: $permissionForUsers, permissionForGeo: $permissionForGeo, permissionForStats: $permissionForStats, permissionForDrivers: $permissionForDrivers, permissionForAdmins: $permissionForAdmins)';
  }

  @override
  bool operator ==(covariant Admin other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.login == login &&
        other.password == password &&
        other.permissionForUsers == permissionForUsers &&
        other.permissionForGeo == permissionForGeo &&
        other.permissionForStats == permissionForStats &&
        other.permissionForDrivers == permissionForDrivers &&
        other.permissionForAdmins == permissionForAdmins;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        login.hashCode ^
        password.hashCode ^
        permissionForUsers.hashCode ^
        permissionForGeo.hashCode ^
        permissionForStats.hashCode ^
        permissionForDrivers.hashCode ^
        permissionForAdmins.hashCode;
  }
}
