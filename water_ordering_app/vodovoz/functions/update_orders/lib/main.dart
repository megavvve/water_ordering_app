import 'package:dart_appwrite/dart_appwrite.dart';

Future main(final context) async {
  const String appwriteId = "6696b90100392dbab5c0";
  const String funAppwriteId = "671f5256000c2b670a19";
  final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject(appwriteId)
      .setKey(funAppwriteId);

  final databases = Databases(client);

  const String dbId = "6697f5b6002cb60641bd";
  const String ordersCollectionId = "6697f5c2001b7c65cf49";

  try {
    final response = await databases.listDocuments(
      databaseId: dbId,
      collectionId: ordersCollectionId,
      queries: [Query.limit(5000)],
    );

    for (final doc in response.documents) {
      final DateTime updatedAt = DateTime.parse(doc.$updatedAt);
      final Duration difference = DateTime.now().difference(updatedAt);
      final orderData = doc.data;

      // Проверка наличия geolocationId
      orderData['geolocationId'] ??= orderData['id']; 

      final status = orderData['status'] as String;
      final isFinish = orderData['isFinish'] as bool?;

      if (difference.inDays >= 1) {
            // Удаляем системные поля, чтобы избежать ошибок
      orderData.removeWhere((key, value) => key.startsWith(r'$'));
        if (['pending', 'awaitingConfirmation', 'accepted', 'inProgress'].contains(status)) {
          orderData['status'] = 'canceled';
          await databases.updateDocument(
            databaseId: dbId,
            collectionId: ordersCollectionId,
            documentId: orderData['id'],
            data: orderData,
          );
          context.log('Заказ с ID ${doc.$id} обновлен: статус -> отмененный');
        }
        
        if (isFinish != true) {
          orderData['isFinish'] = true;
          await databases.updateDocument(
            databaseId: dbId,
            collectionId: ordersCollectionId,
            documentId: orderData['id'] ,
            data: orderData,
          );
          context.log('Заказ с ID ${doc.$id} обновлен: статус -> завершен');
        }
      }
    }
    return context.res.text('Все заказы проверены и обновлены');
  } catch (e) {
    context.error('Ошибка при обновлении заказов: $e');
    return context.res.text('Ошибка при обновлении заказов');
  }
}
