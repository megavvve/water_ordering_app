import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/remote/geo_service.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/location_selection_widget/widgets/address_input_dialogue.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationSelectionWidget extends StatefulWidget {
  final Function(Point, String) onLocationSelected;
  final String? initialAddress;
  final String labelText;

  const LocationSelectionWidget({
    required this.onLocationSelected,
    this.initialAddress,
    super.key,
    required this.labelText,
  });

  @override
  _LocationSelectionWidgetState createState() =>
      _LocationSelectionWidgetState();
}

class _LocationSelectionWidgetState extends State<LocationSelectionWidget> {
  final TextEditingController _controller = TextEditingController();
  final GeoService geoService = getIt<GeoService>();
  bool isProfile = true;
  @override
  void initState() {
    if (widget.labelText.toLowerCase().trim().contains('доставк')) {
      isProfile = false;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(LocationSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAddress != oldWidget.initialAddress) {
      _controller.text = widget.initialAddress ?? '';
    }
  }

  void _openAddressInput() async {
    final selectedLocation = await showDialog<Point>(
      context: context,
      builder: (BuildContext context) {
        return AddressInputDialog(
            initialAddress: widget.initialAddress,
            onLocationSelected: (point, address) {
              _controller.text = address;
              widget.onLocationSelected(point, address);
            },
           );
      },
    );

    if (selectedLocation != null) {
      final address = await geoService.getAddressFromLatLng(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );
      _controller.text = address;
      widget.onLocationSelected(selectedLocation, address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openAddressInput,
      child: Padding(
        padding: EdgeInsets.all(5.sp),
        child: SizedBox(
          width: 300.w,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.none,
            readOnly: true,
            maxLines: null,
            showCursor: false,
            style: TextStyle(
                fontSize: 20.sp,
                color: isProfile ? Colors.white : Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: isProfile ? Colors.deepOrangeAccent : Colors.white,
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(20.sp),
              ),
              labelText: widget.labelText,
              labelStyle:
                  TextStyle(color: isProfile ? Colors.white : Colors.grey),
            ),
            onTap: _openAddressInput,
          ),
        ),
      ),
    );
  }
}
