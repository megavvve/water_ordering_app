import 'dart:io';
import 'dart:typed_data';

abstract class StorageRepository {
  Future<void> uploadAvatar(String userId, File file);
  Future<File?> getAvatar(String fileId, String userId);
  Future<void> uploadVodovozPhotos(String userId, Map<String, File?> photos);
  Future<Uint8List?> getVodovozPhoto(String userId, String photoType);
  Future<void> deletePhotoIfExists(String userId);
  Future<File?> loadImageFromStorage(String userId, String avatarId);
}
