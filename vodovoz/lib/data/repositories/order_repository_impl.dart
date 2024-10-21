import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';

import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';
import 'package:vodovoz/utils/constants.dart';

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
        queries: [Query.limit(5000)]);
    List<Order> ordersCollectionIdList = [];
    for (Document element in response.documents) {
      DateTime givenDateTime = DateTime.parse(element.$updatedAt);
      DateTime now = DateTime.now();
      Duration difference = now.difference(givenDateTime);
     
      final order = Order.fromMap(element.data);
      if (difference.inDays > 1) {
        if (order.status == OrderStatus.pending.name ||
            order.status == OrderStatus.awaitingConfirmation.name ||
            order.status == OrderStatus.accepted.name) {
          order.status = 'canceled';
          await updateOrder(order);
          print('Разница больше одного дня у заказа, поэтому он стал canceled');
        }
      }
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
        queries: [Query.equal('customerId', userId)],
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

  @override
  Future<Order?> getActiveOrder() async {
    final String userId = LocalSavedData().getUserId();

    try {
      // Query the database for orders with the given status and user ID
      final response = await database.listDocuments(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        queries: [
          Query.equal('customerId', userId),
          Query.or([
            Query.equal('status', OrderStatus.pending.name),
            Query.equal('status', OrderStatus.awaitingConfirmation.name),
            Query.equal('status', OrderStatus.inProgress.name),
            Query.equal('status', OrderStatus.accepted.name),
            Query.equal('status', OrderStatus.completed.name),
          ]),
        ],
      );

      if (response.documents.isNotEmpty) {
        // Assuming you only care about the first match
        List<Order> orders =
            response.documents.map((doc) => Order.fromMap(doc.data)).toList();
        orders.removeWhere((x) => x.isFinish == true);
        final activeOrder = orders.first;

        return activeOrder;
      } else {
        return null;
      }
    } on AppwriteException catch (e) {
      // Handle Appwrite-specific exceptions
      print('Error fetching order: ${e.message}');
      return null;
    } catch (e) {
      // Handle any other types of exceptions
      print('Unexpected error: $e');
      return null;
    }
  }

  @override
  Future<Order?> getOrderByOrderId(String orderId) async {
    try {
      // Fetch the order document by ID
      Document orderDoc = await database.getDocument(
        databaseId: dbId,
        collectionId: ordersCollectionId,
        documentId: orderId,
      );

      // Convert the document data to an Order object
      Order order = Order.fromMap(orderDoc.data);

      return order;
    } on AppwriteException catch (e) {
      // Handle exceptions, like document not found or permission issues
      print('Error fetching order: ${e.message}');
      return null;
    } catch (e) {
      // Handle any other type of exception
      print('Unexpected error: $e');
      return null;
    }
  }
}
