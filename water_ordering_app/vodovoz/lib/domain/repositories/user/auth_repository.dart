import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

abstract class AuthRepository {
  Future<String> checkPhoneNumber({required String phoneno});
  Future<void> updatePhone(String userId, String phoneNumber);
  Future<bool> verifyPhoneWithOTP({
    required String userId,
    required String otp,
    required BuildContext context,
    required String phone,
  });
  Future<String> signUpUsingPhoneNumber(String phone);
  Future<User?> signInWithGoogle();
}
