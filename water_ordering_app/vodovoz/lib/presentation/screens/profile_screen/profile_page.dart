import 'dart:io' as f;

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/profile_screen/widgets/profile_widgets.dart';
import 'package:vodovoz/presentation/screens/profile_screen/widgets/reg_page_for_profile.dart';
import 'package:vodovoz/presentation/screens/profile_screen/widgets/show_success_widget.dart';
import 'package:vodovoz/presentation/widgets/location_selection_widget/location_selection_widget.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? cityCopy;
  String? nameCopy;
  f.File? imageCopy;
  bool isEmailUser = true;
  String phone = '';
  String phoneCopy = '';
  f.File? _image;
  double? longitudeCopy;
  double? latitudeCopy;
  double longitude = 0.0;
  double latitude = 0.0;
  UserModel? user;
  late final Account account;
  bool isChanged = false;
  final UserRepository userRepo = getIt<UserRepository>();
  final StorageRepository storageRepo = getIt<StorageRepository>();
  bool isLoadingAvatar = true;
  @override
  void initState() {
    super.initState();
    account = AppWrite().getAccount();
    _loadUserData();
    fullNameController.addListener(_checkForChanges);
    cityController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    fullNameController.removeListener(_checkForChanges);
    cityController.removeListener(_checkForChanges);
    phoneController.removeListener(_checkForChanges);
    fullNameController.dispose();
    cityController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = LocalSavedData().getUserId();
      final user = await userRepo.getUserById(userId);
      Geolocation? previousCity =
          await getIt<GeolocationRepository>().getGeolocation(userId);
      if (previousCity != null) {
        cityCopy = previousCity.address;
        longitudeCopy = double.tryParse(previousCity.longitude);
        latitudeCopy = double.tryParse(previousCity.latitude);
      }
      nameCopy = user?.name ?? '';
      phoneCopy = user?.phoneNumber ?? '';

      // Проверяем, что виджет всё ещё смонтирован
      if (!mounted) return;

      setState(() {
        if (user?.email == null || user!.email!.isEmpty) {
          isEmailUser = false;
        }
        fullNameController.text = user?.name ?? '';
        phoneController.text = user?.phoneNumber ?? '';
        cityController.text = previousCity?.address ?? '';
        phone = user?.phoneNumber ?? '';
      });

      String? fileId = user!.fileId;
      if (fileId != '') {
        f.File? imageFile = await storageRepo.getAvatar(fileId ?? '', userId);

      

        setState(() {
          _image = imageFile;
          imageCopy = _image;
          isLoadingAvatar = false;
        });
      }
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  Future<void> _saveProfileData() async {
    try {
      // Сравниваем текущее значение с его копией
      String? fullName = fullNameController.text.trim() == nameCopy
          ? null
          : fullNameController.text.trim();

      Geolocation? geolocation;
      if (cityController.text.trim() != cityCopy ||
          latitude != latitudeCopy ||
          longitude != longitudeCopy) {
        geolocation = Geolocation(
          geolocationId: LocalSavedData().getUserId(),
          address: cityController.text.trim(),
          latitude: latitude.toString(),
          longitude: longitude.toString(),
        );
      } else {
        geolocation = null;
      }

      f.File? image = _image == imageCopy ? null : _image;
      String? phoneNum =
          phoneController.text == phoneCopy ? null : phoneController.text;
      // Сохраняем данные профиля с использованием обновленных значений
      await userRepo.saveProfileData(
          fullName, geolocation, image, phoneNum, context);
      Future.delayed(
        const Duration(
          seconds: 3,
        ),
      );
      showSuccessDialog(context);
      // Обновляем копии значений, если сохранение прошло успешно
      setState(() {
        nameCopy = fullNameController.text.trim();
        cityCopy = cityController.text.trim();
        phoneCopy = phoneController.text.trim();
        imageCopy = _image;
        latitudeCopy = latitude;
        longitudeCopy = longitude;
      });
    } catch (e) {
      print('Failed to save profile data: $e');
    }
  }

  Future<void> _pickImage() async {
    ImagePicker  picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
            child: SizedBox(
              width: 120.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      size: 20.sp,
                    ),
                    title: Text(
                      'Выбрать из галереи',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.w400),
                    ),
                    onTap: () async {
                      XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _image = f.File(pickedFile.path);
                          _checkForChanges();
                        });
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  Divider(height: 1.h),
                  ListTile(
                    leading: Icon(
                      Icons.photo_camera,
                      size: 20.sp,
                    ),
                    title: Text(
                      'Сделать фото',
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.w400),
                    ),
                    onTap: () async {
                      XFile? pickedFile =
                          await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        setState(() {
                          _image = f.File(pickedFile.path);
                          _checkForChanges();
                        });
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _checkForChanges() {
    bool isChanged = cityCopy != cityController.text.trim() ||
        nameCopy != fullNameController.text.trim() ||
        imageCopy != _image;

    setState(() {
      isChanged = isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonVisible = cityCopy != cityController.text.trim() ||
        nameCopy != fullNameController.text.trim() ||
        imageCopy != _image ||
        phoneCopy != phoneController.text.trim();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.white, Colors.blueAccent],
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset:false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        endDrawer: drawer(context),
        backgroundColor: Colors.transparent,
        body: Center(
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: Text(
                      'Профиль',
                      style: TextStyle(fontSize: 34.sp, color: Colors.white),
                    ),
                  ),
                  ProfileAvatar(
                    image: _image,
                    onPressed: _pickImage,
                    isLoadingAvatar: isLoadingAvatar,
                  ),
                  SelectPhotoButton(onPressed: _pickImage),
                  ProfileTextField(
                    controller: fullNameController,
                    labelText: 'ФИО полностью',
                    enabled: true,
                  ),
                  LocationSelectionWidget(
                    initialAddress: cityController.text,
                    onLocationSelected: (point, address) {
                      setState(() {
                        cityController.text = address;
                        longitude = point.longitude;
                        latitude = point.latitude;
                        _checkForChanges();
                      });
                      Navigator.of(context).pop();
                    },
                    labelText: 'Выбор города/населённого пункта',
                  ),
                  (!isEmailUser)
                      ? EditButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>
                                    const RegPageForProfile(),
                              ),
                            );
                          },
                          phone: phone,
                        )
                      : PhoneTextField(
                          controller: phoneController,
                          labelText: 'Номер телефона'),
                  if (isButtonVisible)
                    SaveButton(
                      onPressed: _saveProfileData,
                    ),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
