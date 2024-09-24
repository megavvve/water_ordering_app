import 'dart:async';

import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';
import 'package:appwrite/appwrite.dart';


class GeolocationRepositoryImpl implements GeolocationRepository {
  late Databases database;

  GeolocationRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
  }
  @override
  Future<void> createGeolocation(String geolocationId) async {
    try {
      await database.createDocument(
        databaseId: dbId,
        collectionId: geolocationsCollectionId,
        documentId: geolocationId,
        data: Geolocation(
                geolocationId: geolocationId,
                address: '',
                latitude: '',
                longitude: '')
            .toMap(),
      );
      print('Geolocation created successfully');
    } catch (e) {
      print('Error creating geolocation: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGeolocation(Geolocation geolocation) async {
    try {
      await database.updateDocument(
        databaseId: dbId,
        collectionId: geolocationsCollectionId,
        documentId: geolocation.geolocationId,
        data: geolocation.toMap(),
      );
      print('Geolocation updated successfully');
    } catch (e) {
      database.createDocument(
          databaseId: dbId,
          collectionId: geolocationsCollectionId,
          documentId: geolocation.geolocationId,
          data: geolocation.toMap());
      print('Error updating geolocation: $e');
  
    }
  }

  @override
  Future<Geolocation?> getGeolocation(String geolocationId) async {
    try {
      final document = await database.getDocument(
        databaseId: dbId,
        collectionId: geolocationsCollectionId,
        documentId: geolocationId,
      );

      Geolocation geolocation = Geolocation.fromMap(document.data);
      print('Geolocation retrieved successfully');
      return geolocation;
    } catch (e) {
      print('Error retrieving geolocation: $e');
      return null;
    }
  }
@override
  Future<List<Geolocation>> getGeolocationsByIds(
      List<String> ids) async {
    try {
      // Выполнение запроса для получения списка документов
      final documents = await database.listDocuments(
        databaseId: dbId,
        collectionId: geolocationsCollectionId,
        queries: [
          Query.equal('geolocationId', ids),
        ],
      );

      
      List<Geolocation> geolocations = documents.documents.map((doc) {
        return Geolocation.fromMap(doc.data);
      }).toList();

      print('Geolocations retrieved successfully');
      return geolocations;
    } catch (e) {
      print('Error retrieving geolocations: $e');
      return [];
    }
  }
  @override
  Future<List<Geolocation>> getGeolocationsByDelivererIds(
      List<String> delivererIds) async {
    try {
      // Выполнение запроса для получения списка документов
      final documents = await database.listDocuments(
        databaseId: dbId,
        collectionId: geolocationsCollectionId,
        queries: [
          Query.equal('customerId', delivererIds),
        ],
      );

      // Преобразование каждого документа в объект Geolocation
      List<Geolocation> geolocations = documents.documents.map((doc) {
        return Geolocation.fromMap(doc.data);
      }).toList();

      print('Geolocations retrieved successfully');
      return geolocations;
    } catch (e) {
      print('Error retrieving geolocations: $e');
      return [];
    }
  }
}
