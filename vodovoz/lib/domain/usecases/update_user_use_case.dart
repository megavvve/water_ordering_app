import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';

class UpdateUser {
  final UserRepository userRepository;

  UpdateUser({required this.userRepository});

  Future<UserModel?> call(UserModel user) async {
    return await userRepository.updateUser(user);
  }
}
