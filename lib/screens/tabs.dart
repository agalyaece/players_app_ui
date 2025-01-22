import 'package:flutter/material.dart';
import 'package:players_app/screens/home/home.dart';
import 'package:players_app/widgets/fantasy/fantasy.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectedPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomeScreen();
    const activePageTitle = "Home";

    if (_selectedPageIndex == 1) {
      activePage = const Fantasy();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
        actions: [],
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Fantasy"),
        ],
        onTap: _selectedPage,
        currentIndex: _selectedPageIndex,
      ),
    );
  }
}
