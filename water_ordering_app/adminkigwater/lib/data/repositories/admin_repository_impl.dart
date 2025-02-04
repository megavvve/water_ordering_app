import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/repositories/admin_repository.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/constants.dart';
import 'package:appwrite/appwrite.dart';

class AdminRepositoryImpl extends AdminRepository {
  late Databases database;

  AdminRepositoryImpl() {
    final appwrite = getIt<AppWrite>();
    database = appwrite.getDataBase();
  }
  @override
  Future<void> addAdmin(Admin admin) async {
    try {
      // Создание нового администратора
      await database.createDocument(
        collectionId: adminsCollectionId,
        documentId: admin.id,
        data: admin.toMap(),
        databaseId: dbId,
      );
      final email = '${admin.login}@admin.ru';
      final authrepo = getIt<AuthRepository>();
      authrepo.createUser(admin.id, email, admin.password, admin.name);

      print('Admin added successfully');
    } catch (e) {
      print('Error adding admin: $e');
    }
  }

  @override
  Future<void> updateAdmin(Admin admin) async {
    try {
      // Обновление существующего администратора
      await database.updateDocument(
        collectionId: adminsCollectionId,
        documentId: admin.id,
        data: admin.toMap(),
        databaseId: dbId,
      );
      print('Admin updated successfully');
    } catch (e) {
      print('Error updating admin: $e');
    }
  }

  @override
  Future<List<Admin>> getAdmins() async {
    try {
      final response = await database.listDocuments(
        collectionId: adminsCollectionId,
        databaseId: dbId,
      );
      return response.documents.map((doc) {
        return Admin.fromMap(doc.data);
      }).toList();
    } catch (e) {
      print('Error fetching admins: $e');
      return [];
    }
  }

  @override
  Future<Admin?> getAdmin(String adminId) async {
    print(adminId);
    try {
      final response = await database.getDocument(
        collectionId: adminsCollectionId,
        databaseId: dbId,
        documentId: adminId,
      );

      return Admin.fromMap(response.data);
    } catch (e) {
      print('Error fetching admins: $e');
      return null;
    }
  }

  @override
  Future<List<bool>> getPermissions() async {
    // Fetch permissions using the getAdmin method
    final admin = await getAdmin(LocalSavedData().getUserId());

    List<bool> permissions = [];
    if (admin != null) {
      permissions = [
        admin.permissionForUsers,
        admin.permissionForGeo,
        admin.permissionForStats,
        admin.permissionForDrivers,
        admin.permissionForAdmins
      ];
    }

    // Return the fetched permissions
    return permissions;
  }
}
