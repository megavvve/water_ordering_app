import 'package:adminkigwater/presenation/navigation/drawer.dart';
import 'package:flutter/material.dart';

class GeoAddPage extends StatefulWidget {
  const GeoAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _GeoAddPageState();
}

class _GeoAddPageState extends State<GeoAddPage> {
  List<String> citysList = [];
  Widget pageContent = const Center(
    child: Text(
      'Функция гео-активности находится в разработке',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );

  @override
  void initState() {
    super.initState();
    // Дальнейшая логика работы с базой данных пока закомментирована
    // и может быть реализована позже.

    // citysRef.onChildAdded.listen((event) {
    //   citysList.add(event.snapshot.value.toString());
    //   ReloadCityList(citysList);
    // });
    // citysRef.onChildRemoved.listen((event) {
    //   citysList.remove(event.snapshot.value.toString());
    //   ReloadCityList(citysList);
    // });
    // GetCitys().then((value) {
    //   citysList = value;
    //   ReloadCityList(citysList);
    // });
  }

  void ReloadCityList(List<String> citys) {
    setState(() {
      pageContent = ListView.builder(
        itemCount: citys.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: Card(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(citys[index]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        // Логика удаления города из базы данных
                      },
                      child: const Text('Удалить'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(context),
      appBar: AppBar(
        title: const Text('Редактирование гео-активности'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                height: 50,
                child: SearchBar(
                  leading: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(child: pageContent),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              TextEditingController tc = TextEditingController();

              return AlertDialog(
                content: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextField(
                        controller: tc,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Логика добавления города в базу данных
                          Navigator.pop(context);
                        },
                        child: const Text('Добавить'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        label: const Text('Добавить'),
        icon: const Icon(Icons.add_circle_outline),
      ),
    );
  }
}
