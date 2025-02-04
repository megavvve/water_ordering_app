import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:adminkigwater/domain/entities/admin.dart';
import 'package:adminkigwater/domain/usecases/get_admins_use_case.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/presenation/screens/admins_page/widgets/add_admin_dialog.dart';
import 'package:adminkigwater/presenation/screens/admins_page/widgets/admins_card.dart';
import 'package:adminkigwater/presenation/screens/admins_page/widgets/edit_admin_dialog.dart';
import 'package:adminkigwater/presenation/widgets/search_bar.dart';
import 'package:adminkigwater/presenation/widgets/navigation/drawer.dart';
import 'package:adminkigwater/presenation/widgets/export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminsPage extends StatefulWidget {
  const AdminsPage({super.key});

  @override
  State<StatefulWidget> createState() => _AdminsPageState();
}

class _AdminsPageState extends State<AdminsPage> {
  final TextEditingController searchController = TextEditingController();
  late Future<List<Admin>> _futureAdmins;
  List<Admin> _allAdmins = [];
  List<Admin> _filteredAdmins = [];

  @override
  void initState() {
    super.initState();
    _futureAdmins = _fetchAdmins();
  }

  Future<List<Admin>> _fetchAdmins() async {
    try {
      // Получаем список всех администраторов
      List<Admin> admins = await getIt<GetAdmins>().call();

      // Получаем ID залогиненного администратора из локального хранилища
      final loggedInAdminId = LocalSavedData().getUserId();

      // Удаляем залогиненного администратора из списка
      admins = admins.where((admin) => admin.id != loggedInAdminId).toList();

      _allAdmins = admins;
      _filteredAdmins = admins;
      return admins;
    } catch (e) {
      print('Ошибка при загрузке администраторов: $e');
      return [];
    }
  }

  void _searchAdmins(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredAdmins = _allAdmins
          .where((admin) => admin.name.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAdminDialog(onAdminAdded: () {
          Navigator.pop(context);
          setState(() {
            _futureAdmins = _fetchAdmins();
          });
        });
      },
    );
  }

  void _showEditAdminDialog(Admin admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAdminDialog(
          admin: admin,
          onAdminUpdated: () {
            Navigator.pop(context);
            setState(() {
              _futureAdmins = _fetchAdmins();
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Администраторы',
          style: TextStyle(fontSize: 30.sp),
        ),
        centerTitle: true,
      ),
      drawer: getDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            SizedBox(
              height: 15.h,
            ),
            ExportButton(
              buttonText: 'Выгрузить статистику по всем администраторам',
              onExport: () {
                getIt<ExcelService>().exportAdminsReport(_allAdmins);
              },
            ),
            SizedBox(
              height: 15.h,
            ),
            SearchWidget(
              onSearch: (query) {
                _searchAdmins(query);
              },
            ),
            Expanded(
              child: FutureBuilder<List<Admin>>(
                future: _futureAdmins,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Ошибка при загрузке данных'),
                    );
                  } else if (_filteredAdmins.isEmpty) {
                    return const Center(
                      child: Text('Нет администраторов'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: _filteredAdmins.length,
                      itemBuilder: (context, index) {
                        final admin = _filteredAdmins[index];
                        return AdminCard(
                          admin: admin,
                          onEdit: () => _showEditAdminDialog(admin),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAdminDialog,
        label: const Text('Добавить'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
