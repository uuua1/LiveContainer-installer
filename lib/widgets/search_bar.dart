import 'package:flutter/cupertino.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoSearchTextField(placeholder: "Search");
  }
}
