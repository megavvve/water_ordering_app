import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/domain/usecases/update_admin.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/widgets/navigation/set_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditAdminDialog extends StatefulWidget {
  final Admin admin;
  final VoidCallback onAdminUpdated;

  const EditAdminDialog({
    Key? key,
    required this.admin,
    required this.onAdminUpdated,
  }) : super(key: key);

  @override
  _EditAdminDialogState createState() => _EditAdminDialogState();
}

class _EditAdminDialogState extends State<EditAdminDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _canManageUsers = false;
  bool _canManageGeo = false;
  bool _canManageDrivers = false;
  bool _canManageStats = false;
  bool _canManageAdmins = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.admin.name;
    loginController.text = widget.admin.login;
    passController.text = widget.admin.password;

    _canManageUsers = widget.admin.permissionForUsers;
    _canManageGeo = widget.admin.permissionForGeo;
    _canManageDrivers = widget.admin.permissionForDrivers;
    _canManageStats = widget.admin.permissionForStats;
    _canManageAdmins = widget.admin.permissionForAdmins;
  }

  Future<void> _updateAdmin() async {
    // Валидация длины пароля
    if (passController.text.length < 8) {
      setState(() {
        _passwordError = 'Пароль должен содержать не менее 8 символов';
      });
      return;
    }

    final updatedAdmin = Admin(
      id: widget.admin.id,
      name: nameController.text,
      login: loginController.text,
      password: passController.text,
      permissionForUsers: _canManageUsers,
      permissionForGeo: _canManageGeo,
      permissionForDrivers: _canManageDrivers,
      permissionForStats: _canManageStats,
      permissionForAdmins: _canManageAdmins,
    );

    try {
      if (widget.admin.name != updatedAdmin.name) {
        await getIt<AuthRepository>()
            .updateAuthName(updatedAdmin.id, updatedAdmin.name);
      }

      if (widget.admin.login != updatedAdmin.login) {
        await getIt<AuthRepository>().updateAuthLogin(
            "${updatedAdmin.login}@admin.ru", widget.admin.password);
      }

      if (widget.admin.password != updatedAdmin.password) {
        await getIt<AuthRepository>()
            .updateAuthPassword(widget.admin.password, updatedAdmin.password);
      }
      await getIt<UpdateAdmin>().call(updatedAdmin);

      widget.onAdminUpdated();
      SetPageWithoutBack(context, 'admins');
    } catch (e) {
      print('Error updating admin: $e');
      // Handle error (e.g., show a snackbar or dialog)
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать администратора'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: loginController,
              decoration: const InputDecoration(labelText: 'Логин'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: passController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Пароль',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Права доступа',
                style: Theme.of(context).textTheme.headlineMedium),
            _buildPermissionCheckbox('Пользователи', _canManageUsers, (value) {
              setState(() {
                _canManageUsers = value ?? false;
              });
            }),
            _buildPermissionCheckbox('Гео-активность', _canManageGeo, (value) {
              setState(() {
                _canManageGeo = value ?? false;
              });
            }),
            _buildPermissionCheckbox('Заявки водовозов', _canManageDrivers,
                (value) {
              setState(() {
                _canManageDrivers = value ?? false;
              });
            }),
            _buildPermissionCheckbox('Статистика', _canManageStats, (value) {
              setState(() {
                _canManageStats = value ?? false;
              });
            }),
            _buildPermissionCheckbox('Администраторы', _canManageAdmins,
                (value) {
              setState(() {
                _canManageAdmins = value ?? false;
              });
            }),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _updateAdmin,
          child: const Text('Сохранить'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Отмена'),
        ),
      ],
    );
  }

  Widget _buildPermissionCheckbox(
      String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
