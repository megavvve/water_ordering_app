import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: 'Поиск...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onSearch,
    );
  }
}
