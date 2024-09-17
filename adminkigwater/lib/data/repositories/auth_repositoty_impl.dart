import 'dart:convert';

import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/widgets/show_error_widget.dart';
import 'package:adminkigwater/utils/constants.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class AuthRepositotyImpl extends AuthRepository {
  late Databases database;
  late Account account;

  AuthRepositotyImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
    account = appwrite.getAccount();
  }
  @override
  Future<String> checkPhoneNumber({required String phoneno}) async {
    try {
      final DocumentList matchUser = await database.listDocuments(
          databaseId: dbId,
          collectionId: usersCollectionId,
          queries: [Query.equal("phoneNumber", phoneno)]);

      if (matchUser.total > 0) {
        final Document user = matchUser.documents[0];

        if (user.data["phoneNumber"] != null || user.data["phone_no"] != "") {
          return user.data["userId"];
        } else {
          print("no user exist on db");
          return "user_not_exist";
        }
      } else {
        print("no user exist on db");
        return "user_not_exist";
      }
    } on AppwriteException catch (e) {
      print("error on reading database $e");
      return "user_not_exist";
    }
  }

  @override
  Future<void> updateAuthPhone(String userId, String phoneNumber) async {
    final uri = Uri.parse('$endpointId/users/$userId/phone');
    final headers = {
      'Content-Type': 'application/json',
      'X-Appwrite-Project': appwriteId,
      'X-Appwrite-Key': apiKeyId,
    };

    final Map<String, dynamic> data = {
      'number': phoneNumber,
    };

    final response = await http.patch(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Phone number updated successfully');
    } else {
      throw Exception('Failed to update phone');
    }
  }

  @override
  Future<void> updateAuthName(String userId, String name) async {
    final uri = Uri.parse('$endpointId/users/$userId/name');
    final headers = {
      'Content-Type': 'application/json',
      'X-Appwrite-Project': appwriteId,
      'X-Appwrite-Key': apiKeyId,
    };

    final Map<String, dynamic> data = {
      'name': name,
    };

    final response = await http.patch(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Name updated successfully');
    } else {
      throw Exception('Failed to update name: ${response.body}');
    }
  }

  @override
  Future<bool> verifyPhoneWithOTP({
    required String userId,
    required String otp,
    required BuildContext context,
    required String phone,
  }) async {
    if (!_isValidCode(otp)) {
      showError('Код должен содержать 6 цифр', context);
      return Future.error('Invalid OTP format');
    }
    try {
      await account.updatePhoneSession(userId: userId, secret: otp);

      return true;
    } catch (e) {
      print("error on login with otp :$e");
      return false;
    }
  }

  bool _isValidCode(String code) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(code);
  }

  @override
  Future<String> signUpUsingPhoneNumber(String phone) async {
    if (!_isValidPhone(phone)) {
      return '';
    }

    String userId = await checkPhoneNumber(phoneno: phone);
    if (userId == "user_not_exist") {
      userId = ID.unique();
    }

    final sessionToken =
        await account.createPhoneToken(userId: userId, phone: phone);
    return sessionToken.userId;
  }

  bool _isValidPhone(String phone) {
    return phone.startsWith('+') && phone.length <= 15;
  }

  @override
  Future<String?> loginWithLoginAndPassword(
      String login, String password) async {
    login = "$login@admin.ru";

    try {
      print(login);
      print(password);
      final session = await account.createEmailPasswordSession(
        email: login,
        password: password,
      );

      LocalSavedData().saveUserid(session.userId);
      return null; // Возвращаем null, если всё прошло успешно
    } catch (e) {
      // Возвращаем сообщение об ошибке
      return 'Error: $e';
    }
  }

  @override
  Future<void> createUser(
    String userId,
    String? email,
    String? password,
    String? name,
  ) async {
    final Uri url = Uri.parse('$endpointId/users');
    final Map<String, dynamic> body = {
      'userId': userId,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (name != null) 'name': name,
    };

    final http.Response response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Appwrite-Project': appwriteId,
        'X-Appwrite-Key': apiKeyId,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      print('User created successfully');
    } else {
      print('Failed to create user: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<String?> updateAuthLogin(String newEmail, String password) async {
    try {
      await account.updateEmail(email: newEmail, password: password);

      return null; // Возвращаем null, если всё прошло успешно
    } catch (e) {
      print("Error: $e");
      return 'Error: $e'; // Возвращаем ошибку, если что-то пошло не так
    }
  }

  @override
  Future<String?> updateAuthPassword(
      String oldPassword, String newPassword) async {
    try {
      // Обновляем пароль
      await account.updatePassword(
        oldPassword: oldPassword,
        password: newPassword,
      );

      return null; // Возвращаем null, если всё прошло успешно
    } catch (e) {
      print("Error: $e");
      return 'Error: $e'; // Возвращаем ошибку, если что-то пошло не так
    }
  }
}
