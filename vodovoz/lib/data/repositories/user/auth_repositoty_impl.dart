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
      // Создание сессии через Google OAuth
      await account.createOAuth2Session(
        provider: OAuthProvider.google,
        scopes: ['email', 'profile', 'phone'],
      );

      // Задержка для завершения входа (можно удалить, если не требуется)
      await Future.delayed(const Duration(milliseconds: 500));

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

  // @override
  // Future<String> signUpUsingPhoneNumber(String phone) async {
  //   String userId = await checkPhoneNumber(phoneno: phone);
  //   if (userId == "user_not_exist") {
  //     userId = ID.unique();
  //   }

  //   const int maxRetries = 5;
  //   int attempt = 0;
  //   while (attempt < maxRetries) {
  //     try {
  //       final sessionToken =
  //           await account.createPhoneToken(userId: userId, phone: phone);

  //       if (sessionToken.secret.isNotEmpty) {
  //         print(sessionToken.expire);
  //         print(sessionToken.phrase);
  //         print(sessionToken.secret);
  //         print(sessionToken.userId);
  //         print(sessionToken.$id);
  //         return sessionToken.userId;
  //       }
  //     } on AppwriteException catch (e) {
  //       if (e.code == 429) {
  //         // Rate limit exceeded
  //         print(
  //           "Rate limit exceeded, waiting before retry...",
  //         );
  //         print(e);
  //         await Future.delayed(
  //             const Duration(seconds: 10)); // Wait 10 seconds before retrying
  //       } else {
  //         print("Ошибка отправки: ${e.message}");
  //         return ''; // Return immediately if the error is not related to rate limiting
  //       }
  //     }
  //     attempt++;
  //   }

  //   return '';
  // }
  @override
  Future<String> signUpUsingPhoneNumber(String phone) async {
    try {
      final userId = await checkPhoneNumber(phoneno: phone);
      if (userId == "user_not_exist") {
        // creating a new account
        final Token data =
            await account.createPhoneToken(userId: ID.unique(), phone: phone);

        // save the new user to user collection
        LocalSavedData().saveUserPhone(phone);

        return data.userId;
      } else {
        // create phone token for existing user
        final Token data =
            await account.createPhoneToken(userId: userId, phone: phone);

        return data.userId;
      }
    } catch (e) {
      print("error on create phone session :$e");
      return "login_error";
    }
  }
}
