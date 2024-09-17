import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vodovoz/domain/repositories/user/notification_repository.dart';
import 'package:vodovoz/utils/constants.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl();

  @override
  Future<void> saveUserDeviceToken(String token, String userId) async {
    final uri = Uri.parse('$endpointId/saveDeviceToken');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKeyId',
    };

    final data = {
      'token': token,
      'userId': userId,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Device token saved successfully');
    } else {
      print('Failed to save device token: ${response.body}');
      throw Exception('Failed to save device token');
    }
  }

  @override
  Future<void> sendNotificationtoOtherUser({
    required String notificationTitle,
    required String notificationBody,
    required String deviceToken,
  }) async {
    try {
      print("Sending notification...");

      final Map<String, dynamic> body = {
        "deviceToken": deviceToken,
        "message": {"title": notificationTitle, "body": notificationBody},
      };

      final response = await http.post(
        Uri.parse("https://669b7f91c1886f9a2fde.appwrite.global/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Notification sent to other user");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      print("Notification cannot be sent: $e");
    }
  }
}
