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

class SignInSelectionPage extends StatelessWidget {
  const SignInSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = getIt<AuthRepository>();
    final userRepo = getIt<UserRepository>();

    Future<void> signInWithGoogle() async {
      try {
        // Выполняем вход через Google
        final googleUser = await authRepository.signInWithGoogle();
        if (googleUser == null) {
          showError('Вход через Google не удался', context);
          return;
        }

        final userId = googleUser.$id;
        final userName = googleUser.name;
        final userEmail = googleUser.email;

        // Проверяем, существует ли пользователь в базе данных
        try {
          await userRepo.getUserById(userId);
          LocalSavedData().saveUserid(userId);
        } catch (e) {
          // Если пользователь не существует, создаем его
          LocalSavedData().saveUserid(userId);
          LocalSavedData().saveUserName(userName);

          UserModel user = UserModel(
            userId: userId,
            name: userName,
            phoneNumber: '', // если есть телефон, можно сохранить и его
            fileId: '',
            geolocationId: userId,
            isOnline: true,
            userType: 'user',
            ratingId: userId,
            email: userEmail,
          );

          await userRepo.addUser(user);
          getIt<RatingRepository>().createRating(userId);
          getIt<GeolocationRepository>().createGeolocation(userId);
        }

        // После успешного входа и сохранения данных направляем пользователя на страницу профиля
        SetPageWithoutBack(context, 'profile');
      } catch (e) {
        showError('Ошибка при входе через Google: $e', context);
      }
    }

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
          centerTitle: true,
          title: const Text(
            'Выберите способ входа',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    SetPageWithBack(context, 'reg');
                  },
                  icon: Icon(
                    Icons.phone,
                    size: 30.sp,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Войти по номеру телефона',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      textStyle: TextStyle(fontSize: 18.sp),
                      backgroundColor: Colors.orange),
                ),
                SizedBox(height: 20.h),
                ElevatedButton.icon(
                  onPressed: () async {
                    signInWithGoogle();
                  },
                  icon: Image.asset(
                    'assets/images/google_icon.png',
                    width: 25.w,
                    height: 25.h,
                  ),
                  label: const Text('Войти через Google'),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      textStyle: TextStyle(fontSize: 16.sp),
                      backgroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
