import 'package:flutter/material.dart';

abstract class AuthRepository {
  Future<String> checkPhoneNumber({required String phoneno});
  Future<void> updateAuthPhone(String userId, String phoneNumber);
  Future<void> updateAuthName(String userId, String name);
  Future<bool> verifyPhoneWithOTP({
    required String userId,
    required String otp,
    required BuildContext context,
    required String phone,
  });
  Future<String> signUpUsingPhoneNumber(String phone);
  Future<String?> loginWithLoginAndPassword(String login, String password);
  Future<void> createUser(
    String userId,
    String? email,
    String? password,
    String? name,
  );
  Future<String?> updateAuthPassword(String oldPassword, String newPassword);
  Future<String?> updateAuthLogin(String newEmail, String password);
}
