import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/repositories/user/auth_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/show_error_widget.dart';
import 'package:vodovoz/utils/constants.dart';

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
  Future<void> updatePhone(String userId, String phoneNumber) async {
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

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Инициализация OAuth с Google
      await account.createOAuth2Session(
        provider: OAuthProvider
            .google, // Используем строку 'google' вместо OAuthProvider.google
        scopes: [
          'email',
          'profile',
          'phone'
        ], // Указываем запрашиваемые доступы
      );

      // Получаем текущую сессию пользователя
      var session = await account.getSession(
          sessionId:
              'current'); // Используем 'current', чтобы получить текущую сессию
      print('Провайдер: ${session.provider}');
      print('UID провайдера: ${session.providerUid}');
      print('Токен доступа: ${session.providerAccessToken}');

      // Получение информации о текущем пользователе
      var user = await account.get();
      print(user);

      return user; // Возвращаем пользователя
    } on AppwriteException catch (e) {
      print('Ошибка при входе через Google: $e');
      return null; // В случае ошибки возвращаем null
    }
  }

  bool _isValidCode(String code) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(code);
  }

  @override
  Future<String> signUpUsingPhoneNumber(String phone) async {
    try {
      // Check if a user with this phone number already exists
      final userId = await checkPhoneNumber(phoneno: phone);

      // Handle the case where the user does not exist
      if (userId == "user_not_exist") {
        // Generate a unique ID for the new user
        final Token data = await account.createPhoneToken(
          userId: ID.unique(), // Use a unique ID for the new user
          phone: phone,
        );

        // Save the user's phone locally
        await LocalSavedData().saveUserPhone(phone);

        return data.userId; // Return the new user's ID
      } else {
        // Handle the case where the user already exists
        try {
          final Token data = await account.createPhoneToken(
            userId: userId, // Use the existing userId
            phone: phone,
          );

          return data.userId; // Return the existing user's ID
        } catch (e) {
          print("Error creating token for existing user: $e");
          return "token_creation_error";
        }
      }
    } catch (e) {
      print("Error on create phone session: $e");
      return "login_error"; // Return an error
    }
  }
}
