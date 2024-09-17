import 'package:adminkigwater/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // save the user profile picture
  Future<void> saveUserProfile(String profile) async {
    print("save user profile to local");
    await preferences.setString("profile", profile);
  }

  // read the user profile picture
  String getUserProfile() {
    return preferences.getString("profile") ?? "";
  }

  // Save admin permissions
  Future<void> saveAdminPermissions(List<bool> permissions) async {
    print("Saving admin permissions to local storage");

    List<String> stringPermissions =
        permissions.map((p) => p.toString()).toList();
    await preferences.setStringList("admin_permissions", stringPermissions);
  }

  // Get admin permissions
  List<bool> getAdminPermissions() {
    print("Retrieving admin permissions from local storage");
    List<String>? stringPermissions =
        preferences.getStringList("admin_permissions");
    if (stringPermissions != null) {
      final list = stringPermissions.map((p) => p == 'true').toList();

      return list;
    }

    return [];
  }

  // clear all the saved data
  clearAllData() async {
    final bool data = await preferences.clear();
    print("cleared all data from local :$data");
  }
}
