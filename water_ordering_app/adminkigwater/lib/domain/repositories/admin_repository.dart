import 'package:adminkigwater/domain/entities/admin.dart';

abstract class AdminRepository {
  Future<void> addAdmin(Admin admin);
  Future<void> updateAdmin(Admin admin);
  Future<List<Admin>> getAdmins();
  Future<List<bool>> getPermissions();
  Future<Admin?> getAdmin(String adminId);
}
