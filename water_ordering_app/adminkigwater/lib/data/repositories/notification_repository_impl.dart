import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:adminkigwater/domain/repositories/notification_repository.dart';
import 'package:adminkigwater/utils/constants.dart';

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
    final uri = Uri.parse('$endpointId/sendNotification');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKeyId',
    };

    final data = {
      'title': notificationTitle,
      'body': notificationBody,
      'token': deviceToken,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
      throw Exception('Failed to send notification');
    }
  }
}
