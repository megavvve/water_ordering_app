import 'package:adminkigwater/data/datasources/local/local_saved_data.dart';
import 'package:flutter/material.dart';

Drawer getDrawer(context) {
  List<bool> permiss = LocalSavedData().getAdminPermissions();
  if (permiss.length != 5) {
    permiss = [true, true, true, true, true];
  }
  return Drawer(
    child: ListView(
      children: [
        DrawerHeader(
            child: SizedBox(
          height: 250,
          child: Image.asset('assets/images/Icon512.png'),
        )),
        ListTile(
          enabled: permiss[0],
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, 'users', (route) => false);
          },
          title: const Text('Пользователи'),
          leading: const Icon(Icons.account_circle_rounded),
        ),
        ListTile(
          enabled: permiss[1],
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(context, 'geo', (route) => false);
          },
          title: const Text('Гео-активность'),
          leading: const Icon(Icons.location_on_outlined),
        ),
        ListTile(
          enabled: permiss[2],
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, 'stats', (route) => false);
          },
          title: const Text('Статистика'),
          leading: const Icon(Icons.ssid_chart),
        ),
        ListTile(
          enabled: permiss[3],
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, 'drivers', (route) => false);
          },
          title: const Text('Водовозы'),
          leading: const Icon(Icons.fire_truck_outlined),
        ),
        ListTile(
          enabled: permiss[4],
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, 'admins', (route) => false);
          },
          title: const Text('Администраторы'),
          leading: const Icon(Icons.admin_panel_settings_outlined),
        ),
      ],
    ),
  );
}
