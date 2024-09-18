import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/geo_service.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/location_selection_widget/widgets/location_map.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class AddressInputDialog extends StatefulWidget {
  final Function(Point, String) onLocationSelected;
  final String? initialAddress;

  final bool isProfile;

  const AddressInputDialog({
    required this.onLocationSelected,
    this.initialAddress,
    Key? key,
    required this.isProfile,
  }) : super(key: key);

  @override
  _AddressInputDialogState createState() => _AddressInputDialogState();
}

class _AddressInputDialogState extends State<AddressInputDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _suggestions = [];
  final GeoService geoService = getIt<GeoService>();
  Geolocation? currentGeolocation;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _searchController.text = widget.initialAddress!;
    }

    _searchController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onAddressChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onAddressChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
      });
      return;
    }
    if (!widget.isProfile && currentGeolocation == null) {
      currentGeolocation = await getIt<GeolocationRepository>()
          .getGeolocation(LocalSavedData().getUserId());
    }

    final List<String>? suggestions = (widget.isProfile)
        ? await geoService.searchCities(query)
        : await geoService.searchAddresses(query, currentGeolocation);
     if (mounted) {
    setState(() {
      _suggestions.clear();
      if (suggestions != null) {
        _suggestions.addAll(suggestions);
      }
    });
  }
  }

  void _selectAddress(String address) async {
    final point = await geoService.getLatLngFromAddress(address);
    if (point != null) {
      widget.onLocationSelected(point, address);
    }
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: LocationMap(
              initialAddress: widget.initialAddress,
              onLocationSelected: (point, address) {
                widget.onLocationSelected(point, address);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: 20.h, top: 30.h, left: 10.w, right: 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextField(
                        maxLines: null,
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              _onAddressChanged();
                            },
                          ),
                          labelText: 'Введите адрес',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final parts = _suggestions[index].split(', ');
                        final country = parts.first;
                        final place = parts.sublist(1);

                        // Проверяем, содержат ли слова после страны ключевые слова
                        final keywords = [
                          'область',
                          'регион',
                          'край',
                          'республика'
                        ];
                        final countryParts = [country];
                        for (var word in place) {
                          if (keywords.any((keyword) =>
                              word.toLowerCase().contains(keyword))) {
                            countryParts.add(word);
                          } else {
                            break;
                          }
                        }

                        // Объединяем слова в страну и место
                        final newCountry = countryParts.join(', ');
                        final newPlace =
                            place.sublist(countryParts.length - 1).join(', ');

                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(
                            newPlace,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(newCountry),
                          onTap: () => _selectAddress(_suggestions[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 3.h,
                ),
                TextButton(
                  onPressed: _showAddressDialog,
                  child: Text(
                    'Карта',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            )
          ],
        ),
      ),
    );
  }
}
