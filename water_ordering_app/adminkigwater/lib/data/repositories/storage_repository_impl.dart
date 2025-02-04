import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/domain/repositories/storage_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';

class StorageRepositoryImpl implements StorageRepository {
  late Storage storage;

  StorageRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    storage = appwrite.getStorage();
  }

  @override
  Future<void> uploadAvatar(String userId, File file) async {
    try {
      await storage.createFile(
        bucketId: storageBucketId,
        fileId: ID.unique(),
        file: InputFile(
          path: file.path,
          filename: 'avatar_$userId.png',
        ),
      );
      print('Avatar uploaded successfully');
    } catch (e) {
      print('Failed to upload avatar: $e');
      throw Exception('Failed to upload avatar');
    }
  }

  @override
  Future<File?> getAvatar(String fileId, String userId) async {
    try {
      final response = await storage.getFileView(
        bucketId: storageBucketId,
        fileId: fileId,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/avatar_$userId.png');
      await file.writeAsBytes(response);
      return file;
    } catch (e) {
      print('Failed to get avatar: $e');
      return null;
    }
  }

  @override
  Future<void> uploadVodovozPhotos(
      String userId, Map<String, File?> photos) async {
    try {
      for (var entry in photos.entries) {
        if (entry.value != null) {
          await storage.createFile(
            bucketId: storageBucketId,
            fileId: ID.unique(),
            file: InputFile(
              path: entry.value!.path,
              filename: '${entry.key}_$userId.png',
            ),
          );
        }
      }
      print('Photos uploaded successfully');
    } catch (e) {
      print('Failed to upload photos: $e');
      throw Exception('Failed to upload photos');
    }
  }

  @override
  Future<Uint8List?> getVodovozPhoto(String userId, String photoType) async {
    try {
      final listPhotos = await storage.listFiles(
        bucketId: '66994cf6003b4da561d2',
      );

      for (var file in listPhotos.files) {
        if (file.name.startsWith('$userId-$photoType')) {
          Uint8List? fileData = await storage.getFileDownload(
            fileId: file.$id,
            bucketId: '66994cf6003b4da561d2',
          );

          print('Successfully fetched $photoType for $userId');
          return fileData;
        }
      }
    } catch (e) {
      print('Error fetching vodovoz photo: $e');
      return null;
    }

    return null;
  }

  @override
  Future<void> deletePhotoIfExists(String userId) async {
    try {
      final response = await storage.listFiles(bucketId: storageBucketId);
      for (var file in response.files) {
        if (file.name.contains(userId)) {
          await storage.deleteFile(bucketId: storageBucketId, fileId: file.$id);
        }
      }
      print('Photos deleted successfully');
    } catch (e) {
      print('Failed to delete photos: $e');
      throw Exception('Failed to delete photos');
    }
  }

  @override
  Future<File?> loadImageFromStorage(String userId, String avatarId) async {
    return getAvatar(avatarId, userId);
  }
}
