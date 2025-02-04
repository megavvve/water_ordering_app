import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';

import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';

class OrderRepositoryImpl implements OrderRepository {
  late Databases database;
  late Realtime realtime;

  OrderRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
    realtime = appwrite.getRealtime();
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    try {
      final response = await database.getDocument(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        documentId: orderId,
      );
      return Order.fromMap(response.data);
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  @override
  Future<List<Order>> getOrders() async {
    final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        queries: [
          Query.limit(5000),
        ]);
    List<Order> ordersCollectionIdList = [];
    for (Document element in response.documents) {
      final order = Order.fromMap(element.data);

      ordersCollectionIdList.add(order);
    }
    return ordersCollectionIdList;
  }

  @override
  Future<void> updateOrder(Order order) async {
    try {
      order = order.copyWith(updatedAt: dateTimeCorrectForm);
      final response = await database.updateDocument(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        documentId: order.id,
        data: order.toMap(),
      );
      print('Order updated successfully: ${response.$id}');
    } catch (e) {
      print('Failed to update order: $e');
      throw Exception('Failed to update order');
    }
  }

  @override
  Future<void> addDelivererToOrder(String orderId, String delivererId) async {
    final orderDoc = await database.getDocument(
      databaseId: dbId,
      collectionId: ordersCollectionId,
      documentId: orderId,
    );

    final order = Order.fromMap(orderDoc.data);
    order.idsOfPossibleDeliverers.add(delivererId);

    await database.updateDocument(
      databaseId: dbId,
      collectionId: ordersCollectionId,
      documentId: orderId,
      data: order.toMap(),
    );
  }

  @override
  Future<void> deleteDelivererFromOrder(
      String orderId, String delivererId) async {
    final orderDoc = await database.getDocument(
      databaseId: dbId,
      collectionId: ordersCollectionId,
      documentId: orderId,
    );

    final order = Order.fromMap(orderDoc.data);
    order.idsOfPossibleDeliverers.remove(delivererId);

    await database.updateDocument(
      databaseId: dbId,
      collectionId: ordersCollectionId,
      documentId: orderId,
      data: order.toMap(),
    );
  }

  @override
  Future<List<Order>> getOrdersByWaterType(String waterType) async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        queries: [Query.equal('waterType', waterType)],
      );

      return response.documents.map((doc) => Order.fromMap(doc.data)).toList();
    } catch (e) {
      print('Error fetching orders by water type: $e');
      return [];
    }
  }

  @override
  Future<Order?> getOrderByUserId(String userId) async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        queries: [Query.equal('userId', userId)],
      );

      if (response.documents.isNotEmpty) {
        return Order.fromMap(response.documents.first.data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching order by user id: $e');
      return null;
    }
  }

  @override
  Future<List<Order>> getOrdersForHistory() async {
    try {
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: ordersCollectionId,
      );

      return response.documents
          .where((doc) {
            final order = Order.fromMap(doc.data);

            return ['pending', 'canceled', 'accepted'].contains(order.status);
          })
          .map((doc) => Order.fromMap(doc.data))
          .toList();
    } on AppwriteException catch (e) {
      print('Ошибка при получении истории заказов: ${e.message}');
      return [];
    }
  }

  @override
  Future<void> addOrder(Order order) async {
    try {
      final response = await database.createDocument(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        documentId: order.id,
        data: order.toMap(),
      );
      print('Order added: ${response.$id}');
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }
}
