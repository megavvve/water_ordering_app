import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CityDropdownSearch extends StatefulWidget {
  final List<String?> cities;
  final String? selectedCity;
  final ValueChanged<String?> onCitySelected;

  const CityDropdownSearch({
    super.key,
    required this.cities,
    this.selectedCity,
    required this.onCitySelected,
  });

  @override
  CityDropdownSearchState createState() => CityDropdownSearchState();
}

class CityDropdownSearchState extends State<CityDropdownSearch>
    with SingleTickerProviderStateMixin {
  String? _selectedCity;
  List<String?> _filteredCities = [];
  final TextEditingController _searchController =
      TextEditingController(text: '');
  bool _isDropdownExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _filteredCities = widget.cities;

    // Анимация для раскрытия списка
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Метод для фильтрации городов
  void _filterCities(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities
            .where((city) =>
                city != null &&
                city.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }

  // Метод для выбора города
  void _onCitySelected(String? city) {
    setState(() {
      _selectedCity = city;
      _isDropdownExpanded = false;
      _searchController.text = city ?? _searchController.text;
      if (city?.isNotEmpty??false) {
 _filterCities(city!);
      }
     
      _animationController.reverse(); // Закрываем список с анимацией
    });
    widget.onCitySelected(city);
  }

  @override
  Widget build(BuildContext context) {
    if (_filteredCities.isEmpty && _searchController.text.isEmpty) {
      setState(() {
        _filteredCities = widget.cities;
      });
    }
    return SizedBox(
      width: 600.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDropdownExpanded = !_isDropdownExpanded;
                if (_isDropdownExpanded) {
                  _animationController.forward(); // Открываем с анимацией
                } else {
                  _animationController.reverse(); // Закрываем с анимацией
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 16.sp),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0.sp),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCity ?? 'Выберите город',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: _selectedCity == null ? Colors.grey : Colors.black,
                    ),
                  ),
                  Icon(
                    _isDropdownExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                SizedBox(height: 10.h),
                // Поле для поиска
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0.sp),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCities,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Найдите ваш город...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                SizedBox(
                  height: (_filteredCities.isNotEmpty) ? 250.h : 0,
                  child: ListView.builder(
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      return GestureDetector(
                        onTap: () {
                          _onCitySelected(city);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.sp,
                            horizontal: 16.sp,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Text(
                            city ?? 'Неизвестный город',
                            style: TextStyle(
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
