import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/domain/usecases/update_user_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/widgets/get_cities_from_geo_list.dart';
import 'package:adminkigwater/presenation/widgets/navigation/drawer.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/edit_user_dialog.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/user_list_header.dart';
import 'package:adminkigwater/presenation/screens/user_page/widgets/user_list_widget.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:adminkigwater/presenation/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<StatefulWidget> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<UserModel> _allUsers = [];
  List<Geolocation> allGeolocations = [];
  List<UserModel> _filteredUsers = [];
  List<Geolocation?> _filteredGeolocations = [];
  String _searchQuery = "";
  String? _selectedCity;
  bool isCitySelected = false; // Новый флаг для отслеживания, выбран ли город
  final AuthRepository authRepository = getIt<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await getIt<GetUsers>().call();

      List<Geolocation> geolocations = await getIt<GeolocationRepository>()
          .getGeolocationsByIds(users.map((x) => x.userId).toList());

      setState(() {
        _allUsers = users;
        allGeolocations = geolocations;
        _filteredUsers = users;
        _filteredGeolocations = geolocations;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _onEditUser(UserModel user) async {
    final updatedUser = await showDialog<UserModel>(
      context: context,
      builder: (context) => UserEditDialog(user: user),
    );

    if (updatedUser != null) {
      await getIt<UpdateUser>().call(updatedUser);

      if (user.name != updatedUser.name) {
        await authRepository.updateAuthName(
            updatedUser.userId, updatedUser.name);
      }
      if (user.phoneNumber != updatedUser.phoneNumber) {
        await authRepository.updateAuthPhone(
            updatedUser.userId, updatedUser.phoneNumber);
      }
      await _fetchUsers();
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterUsers();
    });
  }

  void _onExport() {
    if (_selectedCity != null || _selectedCity != "Все города") {
      final filteredUsersByCity = _filteredUsers;
      getIt<ExcelService>().exportUsersReport(filteredUsersByCity);
    } else {
      getIt<ExcelService>().exportUsersReport(_allUsers);
    }
  }

  void _onCitySelected(String? city) {
    setState(() {
      _selectedCity = city;
      isCitySelected = true;
      _filterUsers();
    });
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        Geolocation? userGeolocation;
        try {
          userGeolocation = allGeolocations.firstWhere(
            (geo) => geo.geolocationId == user.userId,
          );
        } catch (e) {
          userGeolocation = null;
        }

        bool matchesSearchQuery =
            user.name.toLowerCase().contains(_searchQuery) ||
                user.phoneNumber.contains(_searchQuery);

        if (_selectedCity != null && _selectedCity != "Все города") {
          if (userGeolocation != null) {
            return matchesSearchQuery &&
                userGeolocation.address.contains(_selectedCity!);
          } else {
            return matchesSearchQuery && _selectedCity == "Город не указан";
          }
        }

        return matchesSearchQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> cities = getCitiesFromGeoList(allGeolocations);

  

  
    if (!isCitySelected) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Выберите город',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                DropdownButton<String>(
                  hint: const Text('Выберите город'),
                  value: _selectedCity,
                  onChanged: _onCitySelected,
                  items: cities
                      .map((city) => DropdownMenuItem<String>(
                            value: city == 'Все города' ? null : city,
                            child: Text(city ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // После выбора города возвращаем привычный интерфейс
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Пользователи'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15.h),
          DropdownButton<String>(
            hint: const Text('Выберите город'),
            value: _selectedCity,
            onChanged: _onCitySelected,
            items: cities
                .map((city) => DropdownMenuItem<String>(
                      value: city == 'Все города' ? null : city,
                      child: Text(city ),
                    ))
                .toList(),
          ),
          ExportButton(
            buttonText: _selectedCity == null
                ? 'Выгрузить статистику по всем пользователям'
                : 'Выгрузить статистику по городу: $_selectedCity',
            onExport: _onExport,
          ),
          SearchWidget(onSearch: _onSearch),
          Padding(
            padding: EdgeInsets.only(right: 295.w),
            child: const UserListHeader(),
          ),
          Expanded(
            child: _filteredUsers.isNotEmpty
                ? UserListWidget(
                    users: _filteredUsers,
                    geolocations: _filteredGeolocations,
                    onEditUser: _onEditUser,
                  )
                : (_allUsers.isNotEmpty
                    ? const Center(
                        child: Text('Пользователи не найдены'),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      )),
          ),
        ],
      ),
    );
  }
}
