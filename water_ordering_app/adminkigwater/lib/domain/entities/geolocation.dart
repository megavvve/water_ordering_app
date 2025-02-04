import 'dart:convert';

class Geolocation {
  final String geolocationId;
  final String address;
  final String latitude;
  final String longitude;
  Geolocation({
    required this.geolocationId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Geolocation copyWith({
    String? geolocationId,
    String? address,
    String? latitude,
    String? longitude,
  }) {
    return Geolocation(
      geolocationId: geolocationId ?? this.geolocationId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geolocationId': geolocationId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Geolocation.fromMap(Map<String, dynamic> map) {
    return Geolocation(
      geolocationId: map['geolocationId'] as String,
      address: map['address'] as String,
      latitude: map['latitude'] as String,
      longitude: map['longitude'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Geolocation.fromJson(String source) =>
      Geolocation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Geolocation(geolocationId: $geolocationId, address: $address, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(covariant Geolocation other) {
    if (identical(this, other)) return true;

    return other.geolocationId == geolocationId &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return geolocationId.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}
