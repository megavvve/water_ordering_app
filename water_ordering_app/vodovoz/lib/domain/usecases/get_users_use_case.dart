import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';

class GetUsers {
  final UserRepository userRepository;

  GetUsers({required this.userRepository});

  Future<List<UserModel>> call() async {
    return await userRepository.getUsers();
  }
}
