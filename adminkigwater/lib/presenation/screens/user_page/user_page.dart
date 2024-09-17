import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/domain/usecases/update_user_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/edit_user_dialog.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/user_list_header.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/user_list_widget.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/user_search_bar.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<StatefulWidget> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  Future<List<UserModel>>? _usersFuture;
  List<UserModel> _allUsers = [];
  String _searchQuery = "";
  final AuthRepository authRepository = getIt<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await getIt<GetUsers>().call();
    setState(() {
      _allUsers = users;
      _usersFuture = Future.value(_allUsers);
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      List<UserModel> filteredUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(_searchQuery) ||
            user.phoneNumber.contains(_searchQuery) ||
            user.city.toLowerCase().contains(_searchQuery);
      }).toList();
      _usersFuture = Future.value(filteredUsers);
    });
  }

  void _onEditUser(UserModel user) async {
    final updatedUser = await showDialog<UserModel>(
      context: context,
      builder: (context) => UserEditDialog(user: user),
    );

    if (updatedUser != null) {
      await getIt<UpdateUser>().call(updatedUser);

      if (user.name != updatedUser.name) {
        await authRepository.updateAuthName(
            updatedUser.userId, updatedUser.name);
      }
      if (user.phoneNumber != updatedUser.phoneNumber) {
        await authRepository.updateAuthPhone(
            updatedUser.userId, updatedUser.phoneNumber);
      }
      await _fetchUsers(); // Refresh the user list after update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Пользователи'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 15.h,
            ),
            ExportButton(
              buttonText: 'Выгрузить статистику по всем пользователям',
              onExport: () {
                getIt<ExcelService>().exportUsersReport(_allUsers);
              },
            ),
            Padding(
              padding: EdgeInsets.all(15.sp),
              child: SizedBox(
                height: 50.h,
                child: SearchWidget(onSearch: _onSearch),
              ),
            ),
            const UserListHeader(),
            Expanded(
              child: UserListWidget(
                usersFuture: _usersFuture,
                onEditUser: _onEditUser,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
