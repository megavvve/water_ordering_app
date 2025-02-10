import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/utils/enums/user_type.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final localSavedData = getIt<LocalSavedData>();

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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 100, 5, 5),
                child: Text(
                  'Доставка воды',
                  style: TextStyle(fontSize: 34.sp, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.sp),
                child: SizedBox(
                  width: 300.w,
                  child: Image.asset('assets/images/mark.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                child: SizedBox(
                  height: 60.h,
                  width: 300.w,
                  child: Builder(
                    builder: (context) {
                      return FilledButton(
                        onPressed: () async {
                          final sf = getIt<SharedPreferences>();
                         final route =  sf.getString("lastRoute");
                         if (route==null || route == '/'|| route.isEmpty){
                          String initialRoute = 'profile';
                          
                          try {
                            await getIt<AppWrite>().getAccount().get();

                            final userId = localSavedData.getUserId();
                            final user = await getIt<GetUserById>().call(
                              userId,
                            );

                            if (user != null) {
                              initialRoute = 'orderingRedirect';
                              if (user.userType == UserType.deliverer.name) {
                                final deliverer =
                                    await getIt<GetDelivererById>().call(
                                  localSavedData.getUserId(),
                                );

                                if (deliverer?.isAvailable == true &&
                                    deliverer!.waterType.isNotEmpty) {
                                  initialRoute = 'line';
                                } else {
                                  initialRoute = 'delivery';
                                }
                                localSavedData.saveIsUserIsDeliverer(true);
                              }
                            }
                          } catch (err) {
                            print(err);

                            initialRoute = 'signInSelection';
                          }
                         
                          SetPageWithoutBack(context, initialRoute);}
                          else{
                              SetPageWithoutBack(context, route);
                          }
                        },
                        style: btnStl,
                        child: const Text('Начать'),
                      );
                    },
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
