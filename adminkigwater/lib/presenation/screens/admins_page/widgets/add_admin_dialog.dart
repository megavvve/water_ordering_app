import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/repositories/admin_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddAdminDialog extends StatefulWidget {
  final VoidCallback onAdminAdded;

  const AddAdminDialog({
    Key? key,
    required this.onAdminAdded,
  }) : super(key: key);

  @override
  _AddAdminDialogState createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<AddAdminDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _canManageUsers = false;
  bool _canManageGeo = false;
  bool _canManageDrivers = false;
  bool _canManageStats = false;
  bool _canManageAdmins = false;
  bool _obscureText = true;
  String? _passwordError;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _addAdmin() async {
    if (passController.text.length < 8) {
      setState(() {
        _passwordError = 'Пароль должен быть не менее 8 символов';
      });
      return;
    }

    try {
      Admin admin = Admin(
        id: ID.unique(),
        name: nameController.text,
        login: loginController.text,
        password: passController.text,
        permissionForUsers: _canManageUsers,
        permissionForGeo: _canManageGeo,
        permissionForStats: _canManageStats,
        permissionForDrivers: _canManageDrivers,
        permissionForAdmins: _canManageAdmins,
      );
      await getIt<AdminRepository>().addAdmin(admin);
      widget.onAdminAdded();
    } catch (e) {
      // Handle error (e.g., show a dialog or other error UI)
      print('Ошибка при добавлении администратора: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить администратора'),
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
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Пароль',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              onChanged: (text) {
                setState(() {
                  if (text.length >= 8) {
                    _passwordError = null;
                  } else {
                    _passwordError = 'Пароль должен быть не менее 8 символов';
                  }
                });
              },
            ),
            SizedBox(height: 20.h),
            Text('Права доступа',
                style: Theme.of(context).textTheme.headlineMedium),
            _buildPermissionCheckbox('Пользователи', _canManageUsers, (value) {
              setState(() {
                _canManageUsers = value!;
              });
            }),
            _buildPermissionCheckbox('Гео-активность', _canManageGeo, (value) {
              setState(() {
                _canManageGeo = value!;
              });
            }),
            _buildPermissionCheckbox('Заявки водовозов', _canManageDrivers,
                (value) {
              setState(() {
                _canManageDrivers = value!;
              });
            }),
            _buildPermissionCheckbox('Статистика', _canManageStats, (value) {
              setState(() {
                _canManageStats = value!;
              });
            }),
            _buildPermissionCheckbox('Администраторы', _canManageAdmins,
                (value) {
              setState(() {
                _canManageAdmins = value!;
              });
            }),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _passwordError == null ? _addAdmin : null,
          child: const Text('Добавить'),
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
