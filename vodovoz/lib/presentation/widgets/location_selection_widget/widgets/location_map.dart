import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vodovoz/data/datasources/remote/geo_service.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/order_water/push_order_page/widgets/show_confirmation_dialogue.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationMap extends StatefulWidget {
  final Function(Point, String) onLocationSelected;
  final String? initialAddress;

  const LocationMap({
    required this.onLocationSelected,
    this.initialAddress,
    Key? key,
  }) : super(key: key);

  @override
  _LocationMapState createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final _mapControllerCompleter = Completer<YandexMapController>();
  PlacemarkMapObject? _placemark;
  final GeoService geoService = getIt<GeoService>();
  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndInit();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Выбор местоположения',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: YandexMap(
        onMapCreated: (controller) {
          _mapControllerCompleter.complete(controller);
          _checkInitialAddress();
        },
        onMapTap: (point) async {
          setState(() {
            _updatePlacemark(point);
          });

          final address = await geoService.getAddressFromLatLng(
              point.latitude, point.longitude);

          // Запрос подтверждения у пользователя
          final bool? confirmed =
              await showConfirmationDialog(context, address);

          if (confirmed == true) {
            widget.onLocationSelected(point, address);
          }
        },
        mapObjects: _placemark != null ? [_placemark!] : [],
      ),
    );
  }

  Future<void> _checkInitialAddress() async {
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      final point =
          await geoService.getLatLngFromAddress(widget.initialAddress!);
      if (point != null) {
        await _moveToCurrentLocation(point);
        _updatePlacemark(point);
      }
    }
  }

  Future<void> _updatePlacemark(Point point) async {
    // final address =
    //     await _getAddressFromLatLng(point.latitude, point.longitude);
    final placemark = PlacemarkMapObject(
      mapId: const MapObjectId('selected_location'),
      point: point,
      opacity: 1,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('assets/images/place.png'),
          scale: 0.3.sp,
          anchor: Offset(
            0.5.w,
            1.0.h,
          ), // Нижняя центральная точка
        ),
      ),
    );

    setState(() {
      _placemark = placemark;
    });
  }

  Future<void> _checkLocationPermissionAndInit() async {
    final permissionStatus = await Permission.location.status;

    if (permissionStatus.isGranted) {
      await _initLocationLayer();
    } else if (permissionStatus.isDenied) {
      final result = await Permission.location.request();
      if (result.isGranted) {
        await _initLocationLayer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Нет доступа к местоположению пользователя',
            ),
          ),
        );
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _initLocationLayer() async {
    final mapController = await _mapControllerCompleter.future;
    await mapController.toggleUserLayer(
      visible: true,
      headingEnabled: true,
      autoZoomEnabled: true,
    );

    final userPosition = await mapController.getUserCameraPosition();
    if (userPosition != null) {
      await _moveToCurrentLocation(userPosition.target);
      _updatePlacemark(userPosition.target);
    }
  }

  Future<void> _moveToCurrentLocation(Point point) async {
    final mapController = await _mapControllerCompleter.future;
    mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: 16, // Зум карты
        ),
      ),
      animation: const MapAnimation(
        type: MapAnimationType.linear,
        duration: 2,
      ),
    );
  }
}
