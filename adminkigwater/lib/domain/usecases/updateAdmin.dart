import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/repositories/admin_repository.dart';

class UpdateAdmin {
  final AdminRepository adminRepository;

  UpdateAdmin({required this.adminRepository});

  Future<void> call(Admin admin) async {
    return await adminRepository.updateAdmin(admin);
  }
}
