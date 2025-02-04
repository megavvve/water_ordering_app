import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/domain/repositories/admin_repository.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/widgets/navigation/set_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KIG water'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: SizedBox(
                height: 50.h,
                width: 300.w,
                child: TextField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Логин',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: SizedBox(
                height: 50.h,
                width: 300.w,
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Пароль',
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
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: SizedBox(
                height: 50.h,
                width: 300.w,
                child: OutlinedButton(
                  onPressed: () async {
                    final error = await getIt<AuthRepository>()
                        .loginWithLoginAndPassword(
                            _loginController.text, _passwordController.text);

                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    } else {
                      final permissions =
                          await getIt<AdminRepository>().getPermissions();
                      LocalSavedData().saveAdminPermissions(permissions);
                      SetPageWithoutBack(context, 'admins');
                    }
                  },
                  child: const Text('Войти'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
