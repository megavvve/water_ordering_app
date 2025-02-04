import 'dart:io' as f;

import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/domain/repositories/storage_repository.dart';
import 'package:adminkigwater/domain/repositories/user_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';


class UserRepositoryImpl implements UserRepository {
  late Databases database;
  late Account account;

  UserRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
    account = appwrite.getAccount();
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    Document user = await database.getDocument(
      collectionId: usersCollectionId,
      documentId: userId,
      databaseId: dbId,
    );
    return UserModel.fromMap(user.data);
  }

  @override
  Future<Document?> addUser(UserModel user) async {
    try {
      Document userDocument = await database.createDocument(
        collectionId: usersCollectionId,
        documentId: user.userId,
        data: user.toMap(),
        databaseId: dbId,
      );
      return userDocument;
    } on AppwriteException catch (e) {
      print('Failed to add user: ${e.message}');
      return null;
    }
  }

  @override
  Future<UserModel?> updateUser(UserModel user) async {
    try {
      Document updatedUserDocument = await database.updateDocument(
        collectionId: usersCollectionId,
        documentId: user.userId,
        data: user.toMap(),
        databaseId: dbId,
      );
      return UserModel.fromMap(updatedUserDocument.data);
    } on AppwriteException catch (e) {
      print('Failed to update user: ${e.message}');
      return null;
    }
  }

  @override
  Future<void> saveProfileData(String? fullName, Geolocation? geolocation,
      f.File? image, String? phone, BuildContext context) async {
    try {
      String? fileId;

      // Обновление аватара
      if (image != null) {
        fileId = LocalSavedData().getUserId();
        await getIt<StorageRepository>().uploadAvatar(fileId, image);
      }

      // Обновление геолокации
      if (geolocation?.address != null) {
        await getIt<GeolocationRepository>().updateGeolocation(geolocation!);
      }

      // Получаем данные аккаунта
      Account account = AppWrite().getAccount();

      // Если есть изменения, обновляем профиль пользователя
      if (fullName != null || fileId != null || phone != null) {
        UserModel? user = await getUserById(LocalSavedData().getUserId());

        // Обновление пользователя в локальной модели
        user = user!.copyWith(
          name: fullName ?? user.name,
          fileId: fileId ?? user.fileId,
          phoneNumber: phone ?? user.phoneNumber,
        );
        updateUser(user);
        //final authRepo = getIt<AuthRepository>();
        // Обновление данных в аккаунте Appwrite
        if (fullName != null) {
          await account.updateName(name: fullName);
        }
        // if (phone != null) {
        //   authRepo.updatePhone(user.userId, phone);
        // }
      }
    } catch (e) {
      print('Ошибка при сохранении профиля: $e');
    }
  }

 @override
Future<List<UserModel>> getUsers() async {
 try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: usersCollectionId,
          queries: [
          Query.limit(5000),
        ]
      );

      return response.documents
          .map((doc) => UserModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
}

}
