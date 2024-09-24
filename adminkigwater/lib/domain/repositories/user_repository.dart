import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:appwrite/models.dart';
import 'dart:io' as f;

import 'package:flutter/material.dart';

abstract class UserRepository {
  Future<UserModel?> getUserById(String userId);
  Future<Document?> addUser(UserModel user);
  Future<UserModel?> updateUser(UserModel user);
  Future<void> saveProfileData(String? fullName, Geolocation? geolocation,
      f.File? image, String? phone, BuildContext context);
  Future<List<UserModel>> getUsers();
}
