import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/user_repository.dart';

class GetUserById {
  final UserRepository userRepository;

  GetUserById({required this.userRepository});

  Future<UserModel?> call(String id) async {
    return await userRepository.getUserById(id);
  }
}
