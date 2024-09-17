import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/utils/constants.dart';

class StorageRepositoryImpl implements StorageRepository {
  late Storage storage;

  StorageRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    storage = appwrite.getStorage();
  }

  @override
  Future<void> uploadAvatar(String fileId, File file) async {
    try {
      // Попробуем удалить предыдущий файл, если он существует
      try {
        await storage.deleteFile(
          bucketId: avatarsBucketId,
          fileId: fileId,
        );
      } catch (e) {
        print('Previous avatar file not found or failed to delete: $e');
      }

      // Загружаем новый файл
      await storage.createFile(
        bucketId: avatarsBucketId,
        fileId: fileId,
        file:
            InputFile.fromPath(path: file.path, filename: '$fileId-avatar.jpg'),
      );
    } catch (e) {
      print('Error uploading avatar: $e');
    }
  }

  @override
  Future<File?> getAvatar(String fileId, String userid) async {
    try {
      final response = await storage.getFileView(
        bucketId: avatarsBucketId,
        fileId: fileId,
      );

      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/$userid-avatar.jpg');

      // Если файл уже существует, удаляем его
      if (await file.exists()) {
        await file.delete();
      }

      // Записываем новый файл
      await file.writeAsBytes(response);
      return file;
    } catch (e) {
      print('Error retrieving avatar: $e');
      return null;
    }
  }

  @override
  Future<void> uploadVodovozPhotos(
      String userId, Map<String, File?> photos) async {
    await deletePhotoIfExists(userId);
    final storage = AppWrite().getStorage();
    for (var entry in photos.entries) {
      if (entry.value != null) {
        final String photoType = entry.key;
        final File photoFile = entry.value!;
        final String fileName = '$userId-$photoType';
        String fileId = ID.unique();

        final tempPath = (await getTemporaryDirectory()).path;
        final tempFile = File('$tempPath/$photoType');
        await tempFile.writeAsBytes(await photoFile.readAsBytes());

        await storage.createFile(
          bucketId: '66994cf6003b4da561d2',
          fileId: fileId,
          file: InputFile.fromPath(path: tempFile.path, filename: fileName),
        );
        // if (await tempFile.exists()) {
        //   await tempFile.delete();
        // }
      }
    }
  }

  @override
  Future<File?> getVodovozPhoto(String userId, String photoType) async {
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

          final tempDir = await getTemporaryDirectory();
          final tempFilePath = '${tempDir.path}/$userId-$photoType';
          final tempFile = File(tempFilePath);

          // Удаляем старый файл, если он существует
          if (await tempFile.exists()) {
            await tempFile.delete();
            print('Old file $tempFilePath deleted.');
          }

          // Сохраняем новый файл
          await tempFile.writeAsBytes(fileData);

          print('Successfully fetched $photoType for $userId');
          return tempFile;
        }
      }
    } catch (e) {
      print('Error fetching vodovoz photo : $e');
      return null;
    }
    return null;
  }

  @override
  Future<void> deletePhotoIfExists(String userId) async {
    try {
      // List all files in the bucket
      final listPhotos = await storage.listFiles(
        bucketId: '66994cf6003b4da561d2',
      );

      for (var file in listPhotos.files) {
        if (file.name.startsWith(userId)) {
          await storage.deleteFile(
              fileId: file.$id, bucketId: '66994cf6003b4da561d2');
        }
      }
    } catch (e) {
      print('Error deleting photo for $userId: $e');
    }
  }
}
