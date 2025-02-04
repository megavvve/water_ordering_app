import 'package:appwrite/models.dart';
import 'dart:io' as f;

import 'package:flutter/material.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserById(String userId);
  Future<Document?> addUser(UserModel user);
  Future<UserModel?> updateUser(UserModel user);
  Future<void> saveProfileData(String? fullName, Geolocation? geolocation,
      f.File? image, String? phone, BuildContext context);
  Future<List<UserModel>> getUsers();
}
