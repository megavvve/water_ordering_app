import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';

class GetUserById {
  final UserRepository userRepository;

  GetUserById({required this.userRepository});

  Future<UserModel?> call(String id) async {
    return await userRepository.getUserById(id);
  }
}
