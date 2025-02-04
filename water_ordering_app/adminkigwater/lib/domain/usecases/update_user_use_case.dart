import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/user_repository.dart';

class UpdateUser {
  final UserRepository userRepository;

  UpdateUser({required this.userRepository});

  Future<UserModel?> call(UserModel user) async {
    return await userRepository.updateUser(user);
  }
}
