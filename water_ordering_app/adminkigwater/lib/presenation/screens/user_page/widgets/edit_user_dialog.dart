
import 'package:flutter/material.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';

class UserEditDialog extends StatefulWidget {
  final UserModel user;

  const UserEditDialog({super.key, required this.user});

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Имя'),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Телефон'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Обновление пользователя с геолокацией или без неё
            UserModel updatedUser = UserModel(
              userId: widget.user.userId,
              name: _nameController.text,
              phoneNumber: _phoneController.text,
              fileId: widget.user.fileId,
              userType: widget.user.userType,
              ratingId: widget.user.ratingId,
              token: widget.user.token,
              isOnline: widget.user.isOnline,
              // Если geolocationId отсутствует, присваиваем userId
              geolocationId: widget.user.geolocationId ?? widget.user.userId,
            );

            Navigator.of(context).pop(updatedUser);
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
