import 'dart:io';

abstract class StorageRepository {
  Future<void> uploadAvatar(String userId, File file);
  Future<File?> getAvatar(String fileId, String userId);
  Future<void> uploadVodovozPhotos(String userId, Map<String, File?> photos);
  Future<File?> getVodovozPhoto(String userId, String photoType);
  Future<void> deletePhotoIfExists(String userId);
}
