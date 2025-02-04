import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/repositories/admin_repository.dart';

class GetAdmins {
  final AdminRepository adminRepository;

  GetAdmins({required this.adminRepository});

  Future<List<Admin>> call() async {
    return await adminRepository.getAdmins();
  }
}
