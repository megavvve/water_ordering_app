import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/usecases/get_user_by_id.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class ExcelService {
  Future<void> exportOrdersReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по заказам')]);
    sheet.appendRow([
      const TextCellValue('ID заказа'),
      const TextCellValue('ID клиента'),
      const TextCellValue('ID исполнителя'),
      const TextCellValue('Тип воды'),
      const TextCellValue('Количество'),
      const TextCellValue('Статус')
    ]);
    // Данные заказов
    for (var order in orders) {
      sheet.appendRow([
        TextCellValue(order.id),
        TextCellValue(order.customerId),
        TextCellValue(order.delivererId),
        TextCellValue(order.waterType),
        TextCellValue(order.quantity.toString()),
        TextCellValue(order.status),
      ]);
    }

    await _saveExcelFile(excel, 'Orders_Report.xlsx');
  }

  Future<void> exportUsersReport(List<UserModel> users) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по пользователям')]);
    sheet.appendRow([
      const TextCellValue('ID пользователя'),
      const TextCellValue('Имя'),
      const TextCellValue('Номер телефона'),
      const TextCellValue('ID файла'),
      const TextCellValue('Город'),
      const TextCellValue('Тип пользователя'),
      const TextCellValue('ID рейтинга'),
      const TextCellValue('Токен'),
      const TextCellValue('Онлайн статус'),
    ]);

    // Данные пользователей
    for (var user in users) {
      sheet.appendRow([
        TextCellValue(user.userId),
        TextCellValue(user.name),
        TextCellValue(user.phoneNumber),
        TextCellValue(user.fileId ?? 'N/A'),
        TextCellValue(user.city),
        TextCellValue(user.userType),
        TextCellValue(user.ratingId ?? 'N/A'),
        TextCellValue(user.token ?? 'N/A'),
        TextCellValue(
            user.isOnline != null && user.isOnline! ? 'Онлайн' : 'Оффлайн'),
      ]);
    }

    await _saveExcelFile(excel, 'Users_Report.xlsx');
  }

  Future<void> exportClientsReport(
      List<Map<String, dynamic>> clientsData) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Отчёт по клиентам'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по клиентам')]);
    sheet.appendRow([
      const TextCellValue('ID клиента'),
      const TextCellValue('Имя'),
      const TextCellValue('Телефон')
    ]);

    // Данные клиентов
    for (var client in clientsData) {
      sheet.appendRow([
        TextCellValue(client['id']),
        TextCellValue(client['name']),
        TextCellValue(client['phone']),
      ]);
    }

    await _saveExcelFile(excel, 'Clients_Report.xlsx');
  }

  Future<void> exportWaterTypesReport(
      List<Map<String, dynamic>> waterTypesData) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Отчёт по типам воды'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по типам воды')]);
    sheet.appendRow(
        [const TextCellValue('Тип воды'), const TextCellValue('Количество')]);

    // Данные типов воды
    for (var waterType in waterTypesData) {
      sheet.appendRow([
        TextCellValue(waterType['type']),
        TextCellValue(waterType['quantity']),
      ]);
    }

    await _saveExcelFile(excel, 'Water_Types_Report.xlsx');
  }

  Future<void> _saveExcelFile(Excel excel, String fileName) async {
    excel.save(fileName: fileName);
  }

  //statistics
  Future<void> exportOrdersByLocationReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Orders_By_Location'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по заказам (по локации)')]);
    sheet.appendRow([
      const TextCellValue('ID заказа'),
      const TextCellValue('ID клиента'),
      const TextCellValue('ID поставщика'),
      const TextCellValue('Тип воды'),
      const TextCellValue('Количество'),
      const TextCellValue('Адрес'),
      const TextCellValue('Метод оплаты'),
      const TextCellValue('Статус'),
      const TextCellValue('Дата создания'),
    ]);

    // Данные по заказам
    for (var order in orders) {
      sheet.appendRow([
        TextCellValue(order.id),
        TextCellValue(order.customerId),
        TextCellValue(order.delivererId),
        TextCellValue(order.waterType),
        TextCellValue(order.quantity.toString()),
        TextCellValue(order.address),
        TextCellValue(order.paymentMethod),
        TextCellValue(order.status),
        TextCellValue(order.createdAt.toString()),
      ]);
    }

    await _saveExcelFile(excel, 'Orders_By_Location_Report.xlsx');
  }

  Future<void> exportOrdersByClientsReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Orders_By_Clients'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по заказам (по клиентам)')]);
    sheet.appendRow([
      const TextCellValue('ID заказа'),
      const TextCellValue('ID клиента'),
      const TextCellValue('Количество заказов'),
      const TextCellValue('Общая сумма'),
    ]);

    // Группировка заказов по клиентам
    var ordersByClient = <String, List<Order>>{};
    for (var order in orders) {
      ordersByClient.putIfAbsent(order.customerId, () => []).add(order);
    }

    // Данные по клиентам
    ordersByClient.forEach((clientId, clientOrders) {
      sheet.appendRow([
        TextCellValue(clientId),
        TextCellValue(clientOrders.length.toString()),
        TextCellValue(clientOrders
            .fold(0, (sum, order) => sum + order.quantity)
            .toString()),
      ]);
    });

    await _saveExcelFile(excel, 'Orders_By_Clients_Report.xlsx');
  }

  Future<void> exportUsersByLocationReport(List<UserModel> users) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Users_By_Location'];

    // Заголовки
    sheet.appendRow(
        [const TextCellValue('Отчёт по пользователям (по локациям)')]);
    sheet.appendRow([
      const TextCellValue('ID пользователя'),
      const TextCellValue('Имя'),
      const TextCellValue('Номер телефона'),
      const TextCellValue('Город'),
    ]);

    // Группировка пользователей по локациям
    var usersByLocation = <String, List<UserModel>>{};
    for (var user in users) {
      usersByLocation.putIfAbsent(user.city, () => []).add(user);
    }

    // Данные по локациям
    usersByLocation.forEach((location, locationUsers) {
      for (var user in locationUsers) {
        sheet.appendRow([
          TextCellValue(user.userId),
          TextCellValue(user.name),
          TextCellValue(user.phoneNumber),
          TextCellValue(location),
        ]);
      }
    });

    await _saveExcelFile(excel, 'Users_By_Location_Report.xlsx');
  }

  Future<void> exportNewUsersReport(List<UserModel> users) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['New_Users'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по новым пользователям')]);
    sheet.appendRow([
      const TextCellValue('ID пользователя'),
      const TextCellValue('Имя'),
      const TextCellValue('Номер телефона'),
      const TextCellValue('Дата регистрации'),
    ]);

    // Данные по новым пользователям
    for (var user in users.sublist(0, users.length > 5 ? 5 : users.length)) {
      sheet.appendRow([
        TextCellValue(user.userId),
        TextCellValue(user.name),
        TextCellValue(user.phoneNumber),
        TextCellValue(user.city),
      ]);
    }

    await _saveExcelFile(excel, 'New_Users_Report.xlsx');
  }

  Future<void> exportDriverApplicationsReport(List<Deliverer> drivers) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Driver_Applications'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по заявкам водителей')]);
    sheet.appendRow([
      const TextCellValue('ID пользователя'),
      const TextCellValue('Имя'),
      const TextCellValue('Номер телефона'),
      const TextCellValue('Статус заявки'),
    ]);

    // Данные по заявкам водителей
    for (Deliverer driver in drivers) {
      final user = await getIt<GetUserById>().call(driver.userId);
      sheet.appendRow([
        TextCellValue(driver.userId),
        TextCellValue(user!.name),
        TextCellValue(user.phoneNumber),
        TextCellValue(driver.isAvailable.toString()),
      ]);
    }

    await _saveExcelFile(excel, 'Driver_Applications_Report.xlsx');
  }

  Future<void> exportActiveOrdersByRegionsReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Active_Orders_By_Regions'];

    // Заголовки
    sheet.appendRow(
        [const TextCellValue('Статистика по активным заказам и регионам')]);
    sheet.appendRow([
      const TextCellValue('Регион'),
      const TextCellValue('Количество активных заказов'),
    ]);

    // Группировка активных заказов по регионам
    var activeOrdersByRegion = <String, int>{};
    for (var order in orders.where((order) => order.status == 'active')) {
      activeOrdersByRegion.update(order.address, (count) => count + 1,
          ifAbsent: () => 1);
    }

    // Данные по активным заказам и регионам
    activeOrdersByRegion.forEach((region, count) {
      sheet.appendRow([
        TextCellValue(region),
        TextCellValue(count.toString()),
      ]);
    });

    await _saveExcelFile(excel, 'Active_Orders_By_Regions_Report.xlsx');
  }

  Future<void> exportOrdersBySuppliersReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Orders_By_Suppliers'];

    // Заголовки
    sheet.appendRow([const TextCellValue('Отчёт по заказам (по поставщикам)')]);
    sheet.appendRow([
      const TextCellValue('ID заказа'),
      const TextCellValue('ID поставщика'),
      const TextCellValue('Количество заказов'),
      const TextCellValue('Общая сумма'),
    ]);

    // Группировка заказов по поставщикам
    var ordersBySupplier = <String, List<Order>>{};
    for (var order in orders) {
      ordersBySupplier.putIfAbsent(order.delivererId, () => []).add(order);
    }

    // Данные по поставщикам
    ordersBySupplier.forEach((supplierId, supplierOrders) {
      sheet.appendRow([
        TextCellValue(supplierId),
        TextCellValue(supplierOrders.length.toString()),
        TextCellValue(supplierOrders
            .fold(0, (sum, order) => sum + order.quantity)
            .toString()),
      ]);
    });

    await _saveExcelFile(excel, 'Orders_By_Suppliers_Report.xlsx');
  }

  Future<void> loadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      Uint8List? bytes = result.files.single.bytes;
      var excel = Excel.decodeBytes(bytes!);

      for (var table in excel.tables.keys) {
        print(table); // Имя листа
        print(excel.tables[table]!.maxColumns);
        print(excel.tables[table]!.maxRows);

        for (var row in excel.tables[table]!.rows) {
          print('$row');
        }
      }
    }
  }
}
