import 'dart:io' as f;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';

import 'package:adminkigwater/domain/repositories/user_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';

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
  Future<void> saveProfileData(String fullName, String city, f.File? image,
      BuildContext context, UserModel? user) async {
    try {
      Storage storage = AppWrite().getStorage();
      String? fileId;

      final userId = LocalSavedData().getUserId();
      if (image != null) {
        final result = await storage.createFile(
          bucketId: '6697bf930027e7399200',
          fileId: ID.unique(),
          file: InputFile.fromPath(
              path: image.path, filename: '$userId-avatar.jpg'),
        );
        fileId = result.$id;
      }
      Account account = AppWrite().getAccount();
      if (user != null) {
        updateUser(
          user.copyWith(
            name: fullName,
            city: city,
            fileId: fileId,
          ),
        );
      }

      await account.updateName(name: fullName);

      // Optionally, update local state or navigate to another page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пррофиль успешно обновлен')),
      );
    } catch (e) {
      print('Failed to save profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не получилось обновить профиль')),
      );
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await database.listDocuments(
        collectionId: usersCollectionId,
        databaseId: dbId,
      );
      return response.documents.map((doc) {
        return UserModel.fromMap(doc.data);
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}
