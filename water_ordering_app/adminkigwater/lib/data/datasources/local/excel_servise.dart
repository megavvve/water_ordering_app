import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
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
    sheet.appendRow([TextCellValue('Отчёт по заказам')]);
    sheet.appendRow([
      TextCellValue('ID заказа'),
      TextCellValue('ID клиента'),
      TextCellValue('ID исполнителя'),
      TextCellValue('Тип воды'),
      TextCellValue('Количество'),
      TextCellValue('Статус')
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

    // Заголовки таблицы
    sheet.appendRow([TextCellValue('Отчёт по пользователям')]);
    sheet.appendRow([
      TextCellValue('ID пользователя'),
      TextCellValue('Имя'),
      TextCellValue('Номер телефона'),
      TextCellValue('ID файла'),
      TextCellValue('Город'),
      TextCellValue('Тип пользователя'),
      TextCellValue('ID рейтинга'),
      TextCellValue('Токен'),
      // TextCellValue('Онлайн статус'),
    ]);

    // Данные пользователей
    for (UserModel user in users) {
      // Получение геолокации пользователя
      Geolocation? userGeo =
          await getIt<GeolocationRepository>().getGeolocation(user.userId);

      // Заполнение строки с учетом пустых полей
      sheet.appendRow([
        TextCellValue(user.userId),
        TextCellValue(user.name.isNotEmpty ? user.name : 'не указано'),
        TextCellValue(
            user.phoneNumber.isNotEmpty ? user.phoneNumber : 'не указано'),
        TextCellValue(user.fileId ?? 'не указано'),
        TextCellValue(userGeo?.address ?? 'не указано'),
        TextCellValue(user.userType.isNotEmpty ? user.userType : 'не указано'),
        TextCellValue(user.ratingId ?? 'не указано'),
        TextCellValue(user.token ?? 'не указано'),
          // TextCellValue(
          //     user.isOnline != null && user.isOnline! ? 'Онлайн' : 'Оффлайн'),
      ]);
    }

    // Сохранение Excel файла
    await _saveExcelFile(excel, 'Users_Report.xlsx');
  }

  Future<void> exportAdminsReport(List<Admin> admins) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки таблицы
    sheet.appendRow([TextCellValue('Отчёт по администраторам')]);
    sheet.appendRow([
      TextCellValue('ID администратора'),
      TextCellValue('Имя'),
      TextCellValue('Логин'),
      TextCellValue('Пароль'),
      TextCellValue('Права на пользователей'),
      TextCellValue('Права на гео'),
      TextCellValue('Права на статистику'),
      TextCellValue('Права на водителей'),
      TextCellValue('Права на администраторов'),
    ]);

    // Данные администраторов
    for (Admin admin in admins) {
      sheet.appendRow([
        TextCellValue(admin.id),
        TextCellValue(admin.name.isNotEmpty ? admin.name : 'не указано'),
        TextCellValue(admin.login),
        TextCellValue(admin.password),
        TextCellValue(admin.permissionForUsers ? 'Да' : 'Нет'),
        TextCellValue(admin.permissionForGeo ? 'Да' : 'Нет'),
        TextCellValue(admin.permissionForStats ? 'Да' : 'Нет'),
        TextCellValue(admin.permissionForDrivers ? 'Да' : 'Нет'),
        TextCellValue(admin.permissionForAdmins ? 'Да' : 'Нет'),
      ]);
    }

    // Сохранение Excel файла
    await _saveExcelFile(excel, 'Admins_Report.xlsx');
  }

  Future<void> exportClientsReport(
      List<Map<String, dynamic>> clientsData) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по клиентам')]);
    sheet.appendRow([
      TextCellValue('ID клиента'),
      TextCellValue('Имя'),
      TextCellValue('Телефон')
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
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по типам воды')]);
    sheet.appendRow([TextCellValue('Тип воды'), TextCellValue('Количество')]);

    // Данные типов воды
    for (var waterType in waterTypesData) {
      sheet.appendRow([
        TextCellValue(waterType['type']),
        TextCellValue(waterType['quantity']),
      ]);
    }

    await _saveExcelFile(excel, 'Water_Types_Report.xlsx');
  }

  Future<void> exportGeolocationStatistics(
      Map<String, Map<String, Map<String, int>>> stats) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки таблицы
    sheet.appendRow([TextCellValue('Отчёт по геоактивности')]);
    sheet.appendRow([
      TextCellValue('Страна'),
      TextCellValue('Регион'),
      TextCellValue('Город'),
      TextCellValue('Количество заказов')
    ]);

    // Заполнение данными
    for (var countryEntry in stats.entries) {
      String country = countryEntry.key;
      Map<String, Map<String, int>> regions = countryEntry.value;

      for (var regionEntry in regions.entries) {
        String region = regionEntry.key;
        Map<String, int> localities = regionEntry.value;

        for (var localityEntry in localities.entries) {
          String locality = localityEntry.key;
          int orderCount = localityEntry.value;

          sheet.appendRow([
            TextCellValue(country),
            TextCellValue(region),
            TextCellValue(locality),
            TextCellValue(orderCount.toString())
          ]);
        }
      }
    }

    // Сохранение Excel файла
    await _saveExcelFile(excel, 'Geolocation_Statistics_Report.xlsx');
  }

  Future<void> _saveExcelFile(Excel excel, String fileName) async {
    excel.save(fileName: fileName);
  }

  //statistics
  Future<void> exportOrdersByLocationReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по заказам (по локации)')]);
    sheet.appendRow([
      TextCellValue('ID заказа'),
      TextCellValue('ID клиента'),
      TextCellValue('ID поставщика'),
      TextCellValue('Тип воды'),
      TextCellValue('Количество'),
      TextCellValue('Адрес'),
      TextCellValue('Метод оплаты'),
      TextCellValue('Статус'),
      TextCellValue('Дата создания'),
    ]);

    // Данные по заказам
    for (var order in orders) {
      Geolocation? orderGeo =
          await getIt<GeolocationRepository>().getGeolocation(order.id);
      sheet.appendRow([
        TextCellValue(order.id),
        TextCellValue(order.customerId),
        TextCellValue(order.delivererId),
        TextCellValue(order.waterType),
        TextCellValue(order.quantity.toString()),
        TextCellValue(orderGeo?.address ?? 'N/A'),
        TextCellValue(order.paymentMethod),
        TextCellValue(order.status),
        TextCellValue(order.createdAt.toString()),
      ]);
    }

    await _saveExcelFile(excel, 'Orders_By_Location_Report.xlsx');
  }

  Future<void> exportOrdersByClientsReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по заказам (по клиентам)')]);
    sheet.appendRow([
      TextCellValue('ID заказа'),
      TextCellValue('ID клиента'),
      TextCellValue('Количество заказов'),
      TextCellValue('Общая сумма'),
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
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по пользователям (по локациям)')]);
    sheet.appendRow([
      TextCellValue('ID пользователя'),
      TextCellValue('Имя'),
      TextCellValue('Номер телефона'),
      TextCellValue('Город'),
    ]);

    // Группировка пользователей по локациям
    var usersByLocation = <String, List<UserModel>>{};
    for (var user in users) {
      Geolocation? userGeo =
          await getIt<GeolocationRepository>().getGeolocation(user.userId);
      usersByLocation
          .putIfAbsent(userGeo?.address ?? 'N/A', () => [])
          .add(user);
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
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по новым пользователям')]);
    sheet.appendRow([
      TextCellValue('ID пользователя'),
      TextCellValue('Имя'),
      TextCellValue('Номер телефона'),
      TextCellValue('Дата регистрации'),
    ]);

    // Данные по новым пользователям
    for (var user in users.sublist(0, users.length > 5 ? 5 : users.length)) {
      Geolocation? userGeo =
          await getIt<GeolocationRepository>().getGeolocation(user.userId);
      sheet.appendRow([
        TextCellValue(user.userId),
        TextCellValue(user.name),
        TextCellValue(user.phoneNumber),
        TextCellValue(userGeo?.address ?? 'N/A'),
      ]);
    }

    await _saveExcelFile(excel, 'New_Users_Report.xlsx');
  }

  Future<void> exportDriverApplicationsReport(List<Deliverer> drivers) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки таблицы
    sheet.appendRow([TextCellValue('Отчёт по заявкам водовозов')]);
    sheet.appendRow([
      TextCellValue('ID водовоза'),
      TextCellValue('Регистрационный сертификат'),
      TextCellValue('Лицензия'),
      TextCellValue('Вместимость (л)'),
      TextCellValue('Тип воды'),
      TextCellValue('Статус доступности'),
    ]);

    // Данные по водовозам
    for (Deliverer driver in drivers) {
      // Заполнение строки с учетом пустых полей
      sheet.appendRow([
        TextCellValue(driver.userId),
        TextCellValue(
            driver.regCert.isNotEmpty ? driver.regCert : 'не указано'),
        TextCellValue(
            driver.license.isNotEmpty ? driver.license : 'не указано'),
        TextCellValue(
            driver.capacity.isNotEmpty ? driver.capacity : 'не указано'),
        TextCellValue(
            driver.waterType.isNotEmpty ? driver.waterType : 'не указано'),
        TextCellValue(driver.isAvailable != null && driver.isAvailable!
            ? 'Доступен'
            : 'Недоступен'),
      ]);
    }

    // Сохранение Excel файла
    await _saveExcelFile(excel, 'Driver_Applications_Report.xlsx');
  }

  Future<void> exportActiveOrdersByRegionsReport(List<Order> orders) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow(
        [TextCellValue('Статистика по активным заказам и регионам')]);
    sheet.appendRow([
      TextCellValue('Регион'),
      TextCellValue('Количество активных заказов'),
    ]);

    // Группировка активных заказов по регионам
    var activeOrdersByRegion = <String, int>{};
    for (var order in orders.where((order) => order.status == 'active')) {
      Geolocation? orderGeo =
          await getIt<GeolocationRepository>().getGeolocation(order.id);
      activeOrdersByRegion.update(
          orderGeo?.address ?? 'N/A', (count) => count + 1,
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
    Sheet sheet = excel['Sheet1'];

    // Заголовки
    sheet.appendRow([TextCellValue('Отчёт по заказам (по поставщикам)')]);
    sheet.appendRow([
      TextCellValue('ID заказа'),
      TextCellValue('ID поставщика'),
      TextCellValue('Количество заказов'),
      TextCellValue('Общая сумма'),
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
