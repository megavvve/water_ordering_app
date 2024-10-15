import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodovoz/injection_container.dart';

class LocalSavedData {
  final preferences = getIt<SharedPreferences>();

  // save the userId
  Future<void> saveUserid(String id) async {
    print("save user id to local");
    await preferences.setString("userId", id);
  }

  // read the userId
  String getUserId() {
    return preferences.getString("userId") ?? "";
  }

  // save the user name
  Future<void> saveUserName(String name) async {
    print("save user name to local: $name");

    await preferences.setString("name", name);
  }

  // read the user name
  String getUserName() {
    return preferences.getString("name") ?? "";
  }

  // save the user phone
  Future<void> saveUserPhone(String phone) async {
    print("save user phone number to local:$phone");

    await preferences.setString("phone", phone);
  }

  // read the user phone
  String getUserPhone() {
    return preferences.getString("phone") ?? "";
  }

  Future<void> saveDelivererWaterType(String waterType) async {
    print("save DelivererWaterType to local:$waterType");

    await preferences.setString("waterType", waterType);
  }

  // read the user phone
  String getDelivererWaterType() {
    return preferences.getString("waterType") ?? "";
  }

  Future<void> saveCurrentOrderId(String id) async {
    print("save current order id to local");
    await preferences.setString("currentOrderId", id);
  }

  // read the userId
  String getCurrentOrderId() {
    return preferences.getString("currentOrderId") ?? "";
  }

  Future<void> saveIsUserIsDeliverer(bool boolean) async {
    print("save saveIsUserIsDeliverer");
    await preferences.setBool("isUserIsDeliverer", boolean);
  }
    bool? getIsUserIsDeliverer() {
    return preferences.getBool("isUserIsDeliverer");
  }

  // clear all the saved data
  clearAllData() async {
    final bool data = await preferences.clear();
    print("cleared all data from local :$data");
  }
}
