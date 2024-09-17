abstract class NotificationRepository {
  Future<void> saveUserDeviceToken(String token, String userId);
  Future<void> sendNotificationtoOtherUser({
    required String notificationTitle,
    required String notificationBody,
    required String deviceToken,
  });
}
