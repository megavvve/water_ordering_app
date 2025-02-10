// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';
import 'package:appwrite/models.dart' as m;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/order_water/push_order_page/widgets/show_alert_dialogue.dart';
import 'package:vodovoz/utils/enums/user_type.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/capacity_text_field.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/licence_text_filed.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/photo_section_widget.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/save_button_section.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/reg_cert_text_filed.dart';
import 'package:vodovoz/utils/constants.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<StatefulWidget> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  bool isVodovoz = false;
  bool isUnderReview = false;
  final account = AppWrite().getAccount();

  final TextEditingController regCertController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  File? carPhoto;
  File? sorPhoto;
  File? licensePhoto;
  bool isLoading = true;
  late m.Preferences preferences;
  File? carPhotoCopy;
  File? sorPhotoCopy;
  File? licensePhotoCopy;
  bool? isAvalible;
  final StorageRepository storageRepo = getIt<StorageRepository>();
  final DelivererRepository delivererRepository = getIt<DelivererRepository>();
  final UserRepository userRepository = getIt<UserRepository>();
  final ChangeNotifier _profileNotifier = ChangeNotifier(); // Separate notifier

  @override
  void initState() {
    super.initState();
    initializeFields();
  }

  @override
  void dispose() {
    regCertController.dispose();
    licenseController.dispose();
    capacityController.dispose();
    carPhoto = null;
    sorPhoto = null;
    licensePhoto = null;
    _profileNotifier.dispose(); // Dispose the notifier
    super.dispose();
  }

  Future<void> initializeFields() async {
    try {
      preferences = await account.getPrefs();
      Deliverer? deliverer =
          await delivererRepository.getDeliverer(LocalSavedData().getUserId());

      if (deliverer != null) {
        regCertController.text = deliverer.regCert;
        licenseController.text = deliverer.license;
        capacityController.text = deliverer.capacity;

        carPhoto =
            await storageRepo.getVodovozPhoto(deliverer.userId, 'carPhoto');
        sorPhoto =
            await storageRepo.getVodovozPhoto(deliverer.userId, 'sorPhoto');
        licensePhoto =
            await storageRepo.getVodovozPhoto(deliverer.userId, 'licensePhoto');
        licensePhotoCopy = licensePhoto;
        carPhotoCopy = carPhoto;
        sorPhotoCopy = sorPhoto;
        isAvalible = deliverer.isAvailable;
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> setRole() async {
    final userById =
        await userRepository.getUserById(LocalSavedData().getUserId());
    userRepository.updateUser(
        userById!.copyWith(userType: UserType.deliverer.name, isOnline: true));
    isVodovoz = true;
  }

  Future<void> _showImageSourceDialog(String type) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Сделать фото'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera, type);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery, type);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source, String type) async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          if (type == 'car') {
            carPhoto = File(pickedFile.path);
          } else if (type == 'sor') {
            sorPhoto = File(pickedFile.path);
          } else if (type == 'license') {
            licensePhoto = File(pickedFile.path);
          }
          _profileNotifier.notifyListeners();
        });
      }
    }
  }

  bool isFormFilled() {
    return regCertController.text.isNotEmpty &&
        licenseController.text.isNotEmpty &&
        capacityController.text.isNotEmpty &&
        carPhoto != null &&
        sorPhoto != null &&
        licensePhoto != null;
  }

  Future<void> saveChanges() async {
    final userById =
        await getIt<GetUserById>().call(LocalSavedData().getUserId());
    if (userById?.phoneNumber == null || userById!.phoneNumber.isEmpty) {
      showPhoneAlert(context);
      return;
    }
    setState(() => isLoading = !isLoading);
    final updatedRegCert = regCertController.text;
    final updatedLicense = licenseController.text;
    final updatedCapacity = capacityController.text;
    if (isAvalible == null && isAllowPermissionForAutomaticPassageToBeVodovoz) {
      isAvalible = false;
    }
    Deliverer deliverer = Deliverer(
      userId: LocalSavedData().getUserId(),
      regCert: updatedRegCert,
      license: updatedLicense,
      capacity: updatedCapacity,
      waterType: '',
      isAvailable: isAvalible,
      balance: 0,
      pricePerLiter: 0,
      pricePerPiece: 0,
    );

    if (carPhoto != carPhotoCopy ||
        licensePhoto != licensePhotoCopy ||
        sorPhoto != sorPhotoCopy) {
      await storageRepo.uploadVodovozPhotos(LocalSavedData().getUserId(), {
        'carPhoto': carPhoto,
        'sorPhoto': sorPhoto,
        'licensePhoto': licensePhoto,
      });
    }

    await delivererRepository.saveDeliverer(deliverer);
    await setRole();
    setState(() => isLoading = !isLoading);
    if (isAvalible != null) {
      SetPageWithBack(context, 'delivery');
    } else {
      setState(() => isUnderReview = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context);
    return ListenableBuilder(
      listenable: _profileNotifier,
      builder: (context2, state) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueAccent, Colors.blueGrey],
            ),
          ),
          child: PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (bool didPop, _) async {
              if (!didPop) {
                final bool? confirmExit = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Выход из приложения'),
                    content: const Text('Вы точно хотите выйти?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Выйти'),
                      ),
                    ],
                  ),
                );

                if (confirmExit ?? false) {
                  if (mounted) SystemNavigator.pop();
                }
              }
            },
            child: Scaffold(
              endDrawer: drawer(context),
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Text(
                  'Профиль водовоза',
                  style: TextStyle(fontSize: 28.sp, color: Colors.white),
                ),
              ),
              body: isLoading
                  ? Center(
                      child: SizedBox(
                        height: 50.h,
                        width: 50.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : isUnderReview
                      ? Center(
                          child: Text(
                            'Ваша заявка на рассмотрении администрации приложения',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                SizedBox(height: 30.h),
                                PhotoSectionWidget(
                                  title: 'Фото автомобиля',
                                  photo: carPhoto,
                                  onPickImage: () =>
                                      _showImageSourceDialog('car'),
                                ),
                                SizedBox(height: 30.h),
                                RegCertTextField(
                                  regCertController: regCertController,
                                  onChanged: (value) =>
                                      _profileNotifier.notifyListeners(),
                                ),
                                SizedBox(height: 30.h),
                                PhotoSectionWidget(
                                  title: 'Фото свидетельства о регистрации',
                                  photo: sorPhoto,
                                  onPickImage: () =>
                                      _showImageSourceDialog('sor'),
                                ),
                                SizedBox(height: 30.h),
                                LicenseTextField(
                                  licenseController: licenseController,
                                  onChanged: (value) =>
                                      _profileNotifier.notifyListeners(),
                                ),
                                SizedBox(height: 30.h),
                                PhotoSectionWidget(
                                  title: 'Фото водительского удостоверения',
                                  photo: licensePhoto,
                                  onPickImage: () =>
                                      _showImageSourceDialog('license'),
                                ),
                                SizedBox(height: 30.h),
                                CapacityTextField(
                                  capacityController: capacityController,
                                  onChanged: (value) =>
                                      _profileNotifier.notifyListeners(),
                                ),
                                SizedBox(height: 30.h),
                                if (isFormFilled())
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    child: SaveButtonSection(
                                      isFormFilled: isFormFilled(),
                                      onSave: saveChanges,
                                    ),
                                  ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        );
      },
    );
  }
}
