import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/repositories/user/auth_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/presentation/widgets/show_error_widget.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class RegPageForProfile extends StatefulWidget {
  const RegPageForProfile({Key? key}) : super(key: key);

  @override
  _RegPageForProfileState createState() => _RegPageForProfileState();
}

class _RegPageForProfileState extends State<RegPageForProfile> {
  String btnName = 'Получить код';
  bool smsIsRequest = false;
  late String userId;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final account = AppWrite().getAccount();
  final AuthRepository authRepo = getIt<AuthRepository>();

  Future<String> signUpUsingPhoneNumber(String phone) async {
    if (!_isValidPhone(phone)) {
      showError(
          'Номер телефона должен начинаться с "+" и содержать максимум 15 цифр.',
          context);
      return '';
    }

    try {
      userId = await authRepo.checkPhoneNumber(phoneno: phone);
      if (userId == "user_not_exist") {
        userId = ID.unique();
      }
      final sessionToken =
          await account.createPhoneToken(userId: userId, phone: phone);
      setState(() {
        btnName = 'Подтвердить';
        smsIsRequest = true;
      });
      return sessionToken.userId;
    } catch (e) {
      print("error on create phone session :$e");
      return "login_error";
    }
  }

  bool _isValidPhone(String phone) {
    return phone.startsWith('+') && phone.length > 1;
  }

  Future<void> _updatePhone(String userId, String phoneNumber) async {
    try {
      await authRepo.updatePhone(userId, phoneNumber);
      print('Phone number updated successfully');
    } catch (e) {
      throw Exception('Failed to update phone number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.white, Colors.blueAccent],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20.sp),
                child: Text(
                  'Регистрация',
                  style: TextStyle(fontSize: 34.sp, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.sp),
                child: SizedBox(
                  height: 60.h,
                  width: 300.w,
                  child: TextField(
                    controller: _phoneController,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    decoration: inptDec('Номер телефона', true),
                  ),
                ),
              ),
              if (smsIsRequest)
                Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: SizedBox(
                    height: 60.h,
                    width: 300.w,
                    child: TextField(
                      controller: _smsController,
                      style: TextStyle(fontSize: 24.sp, color: Colors.white),
                      decoration: inptDec('Код из СМС', true),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(10.sp),
                child: SizedBox(
                  height: 60.h,
                  width: 300.w,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (smsIsRequest) {
                        try {
                          final value = await authRepo.verifyPhoneWithOTP(
                              userId: userId,
                              otp: _smsController.text,
                              context: context,
                              phone: _phoneController.text);
                          if (value) {
                            LocalSavedData().saveUserid(userId);
                            LocalSavedData()
                                .saveUserPhone(_phoneController.text);
                            await _updatePhone(userId, _phoneController.text);
                            SetPageWithoutBack(context, 'profile');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Login Failed",
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          showError('Ошибка подтверждения кода', context);
                        }
                      } else {
                        userId =
                            await signUpUsingPhoneNumber(_phoneController.text);
                        if (userId == '') {
                          showError('Ошибка при регистрации. Попробуйте снова.',
                              context);
                        }
                      }
                    },
                    style: btnStl,
                    child: Text(btnName),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
