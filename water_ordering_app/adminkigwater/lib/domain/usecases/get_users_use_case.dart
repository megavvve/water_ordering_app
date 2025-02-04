import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/user_repository.dart';

class GetUsers {
  final UserRepository userRepository;

  GetUsers({required this.userRepository});

  Future<List<UserModel>> call() async {
    return await userRepository.getUsers();
  }
}
