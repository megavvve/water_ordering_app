import 'dart:async';
import 'dart:io' as f;

import 'package:appwrite/appwrite.dart';

class AppWrite {
  Client appWriteClient = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('6696b90100392dbab5c0')
      .setSelfSigned(status: true);

  Databases getDataBase() {
    Databases databases = Databases(appWriteClient);
    return databases;
  }

  Messaging getMessaging() {
    Messaging messaging = Messaging(appWriteClient);
    return messaging;
  }

  Realtime getRealtime() {
    Realtime realtime = Realtime(appWriteClient);
    return realtime;
  }

  Storage getStorage() {
    Storage storage = Storage(appWriteClient);
    return storage;
  }

  Account getAccount() {
    Account account = Account(appWriteClient);
    return account;
  }

  Future<void> uploadAvatar(String userId, f.File file) async {
    try {
      await getStorage().createFile(
        bucketId: '6697bf930027e7399200',
        fileId: userId,
        file: InputFile.fromPath(path: file.path),
      );
    } catch (e) {
      print('Error uploading avatar: $e');
    }
  }
}
