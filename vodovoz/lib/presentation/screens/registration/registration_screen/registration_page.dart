import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/user/auth_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/presentation/widgets/show_error_widget.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  String btnName = 'Получить код';
  bool smsIsRequest = false;
  late String userId;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();
  final AuthRepository authRepo = getIt<AuthRepository>();
  final UserRepository userRepo = getIt<UserRepository>();

  String _countryCode = '+7';
  Timer? _timer;
  bool _showGoogleRegisterButton = false;

  Future<void> signUpUsingPhoneNumber() async {
    final phone = '$_countryCode${_phoneController.text}';
    if (!_isValidPhone(phone)) {
      showError(
          'Номер телефона должен начинаться с "+" и содержать максимум 15 цифр.',
          context);
      return;
    }

    try {
      userId = await authRepo.signUpUsingPhoneNumber(phone);
      if (userId == "login_error") {
        showError('Ошибка при регистрации. Попробуйте снова.', context);
        return;
      }

      setState(() {
        btnName = 'Подтвердить';
        smsIsRequest = true;
      },);

      // Запускаем таймер на 20 секунд
      _startTimer();
    } catch (e) {
      print("Error on create phone session in app: $e");
      showError('Ошибка при регистрации. Попробуйте снова.', context);
    }
  }

  bool _isValidPhone(String phone) {
    return phone.startsWith('+') && phone.length <= 15;
  }

  Future<void> _verifyOtpAndCompleteRegistration() async {
    try {
      final value = await authRepo.verifyPhoneWithOTP(
        userId: userId,
        otp: _smsController.text,
        phone: '$_countryCode${_phoneController.text}',
        context: context,
      );

      if (value) {
        try {
          await userRepo.getUserById(userId);
          LocalSavedData().saveUserid(userId);
        } catch (e) {
          LocalSavedData().saveUserid(userId);
          LocalSavedData()
              .saveUserPhone('$_countryCode${_phoneController.text}');
          UserModel user = UserModel(
            userId: userId,
            name: '',
            phoneNumber: '$_countryCode${_phoneController.text}',
            fileId: '',
            geolocationId: userId,
            isOnline: true,
            userType: 'user',
            ratingId: userId,
          );

          await userRepo.addUser(user);
          getIt<RatingRepository>().createRating(userId);
          getIt<GeolocationRepository>().createGeolocation(userId);
        }
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
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
if (smsIsRequest) {
        setState(() {
          _showGoogleRegisterButton = true;
        });
      }
      }
      
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  void _changeCountryCode() async {
    final newCountryCode = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController countryCodeController =
            TextEditingController(text: _countryCode);
        return AlertDialog(
          title: const Text('Введите новый код страны'),
          content: TextField(
            controller: countryCodeController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Код страны',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () {
                Navigator.of(context).pop(countryCodeController.text.isNotEmpty
                    ? countryCodeController.text
                    : null);
              },
            ),
          ],
        );
      },
    );

    if (newCountryCode != null && newCountryCode != _countryCode) {
      setState(() {
        _countryCode = newCountryCode;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    _cancelTimer();
    super.dispose();
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
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
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _changeCountryCode,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(20.sp),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14.0.sp),
                            child: Text(
                              _countryCode,
                              style: TextStyle(
                                fontSize: 24.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style:
                              TextStyle(fontSize: 24.sp, color: Colors.white),
                          decoration:
                              inptDec('Номер телефона без $_countryCode', true),
                        ),
                      ),
                    ],
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
                        await _verifyOtpAndCompleteRegistration();
                      } else {
                        await signUpUsingPhoneNumber();
                      }
                    },
                    style: btnStl,
                    child: Text(btnName,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              if (_showGoogleRegisterButton)
                SizedBox(
                  width: 300.w,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final googleUser =
                            await getIt<AuthRepository>().signInWithGoogle();
                        if (googleUser == null) {
                          showError('Вход через Google не удался', context);
                          return;
                        }

                        final userId = googleUser.$id;
                        final userName = googleUser.name;
                        final userEmail = googleUser.email;

                        try {
                          await userRepo.getUserById(userId);
                          LocalSavedData().saveUserid(userId);
                        } catch (e) {
                          LocalSavedData().saveUserid(userId);
                          LocalSavedData().saveUserName(userName);

                          UserModel user = UserModel(
                            userId: userId,
                            name: userName,
                            phoneNumber:
                                '', // если есть телефон, можно сохранить и его
                            fileId: '',
                            geolocationId: userId,
                            isOnline: true,
                            userType: 'user',
                            ratingId: userId,
                            email: userEmail,
                          );
                          await userRepo.addUser(user);
                          getIt<RatingRepository>().createRating(userId);
                          getIt<GeolocationRepository>()
                              .createGeolocation(userId);
                        }

                        SetPageWithoutBack(context, 'profile');
                      } catch (e) {
                        print(e);
                        showError('Ошибка входа через Google', context);
                      }
                    },
                    icon: const Icon(
                      Icons.login,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Войти через Google',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      textStyle: TextStyle(fontSize: 20.sp),
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
