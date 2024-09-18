import 'package:flutter/material.dart';

const List<DropdownMenuEntry> waterTypes = [
  DropdownMenuEntry<int>(value: 1, label: 'бутилированная'),
  DropdownMenuEntry<int>(value: 2, label: 'речная'),
  DropdownMenuEntry<int>(value: 3, label: 'озерная'),
  DropdownMenuEntry<int>(value: 4, label: 'очищенная'),
];

const List<DropdownMenuEntry> payType = [
  DropdownMenuEntry<int>(value: 1, label: 'Картой при получении'),
  DropdownMenuEntry<int>(value: 2, label: 'Переводом при получении'),
  DropdownMenuEntry<int>(value: 3, label: 'Наличными'),
];
const bool isAllowPermissionForAutomaticPassageToBeVodovoz = true;
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final dateTimeCorrectForm = DateTime.now().toString().substring(0, 10);
const String appwriteId = "6696b90100392dbab5c0";
const String deliverersCollectionId = "66993bc8002cd81e98b6";
const String ordersCollectionId = "6697f5c2001b7c65cf49";
const String geolocationsCollectionId = "66bded280023f8912d58";
const String storageBucketId = "662faabe001a20bb87c6";
const String avatarsBucketId = '6697bf930027e7399200';
const String delivererPhotosBucketId = '66994cf6003b4da561d2';
const String dbId = "6697f5b6002cb60641bd";
const String usersCollectionId = "669b7bb3001dcf0e79b6";
const apiKeyId =
    'e480aa480658de9ca03d449fc7be411ca4ec3d371add6453a9f672546b18ff51d1fc1cd9959b1e9430caab121a50ba97711f9b8c13b4ce1c799f87e3f91c187762d47fdef9e11e0a67db3d54e05b2d028dd5639632494b328d0b8ba5d47cbe7af24d7c52ba8550466e32ed9d205ec88bc7aa9389c5be22d9f63b3abefc97c029';
const String endpointId = 'https://cloud.appwrite.io/v1';
const String ratingsCollectionId = "669fdcbd000e9a2484f6";
const String reviewsCollectionId = "66c34601002a97c33d0a";
//const String apiKeyForYandexMaps = 'da924512-acde-4a48-8b66-0a5b1f07a18c';
const String apiKeyForYandexMaps = '106e9257-04f5-403b-a516-90224792f022';
const String yandexGeosuggestAPIKey = '9a3ef726-3885-4b6e-a42d-24accf724cf2';

const String textForNotificationTitleFromDeliverer = 'Доставщик готов выполнить ваш заказ';
