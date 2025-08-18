import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  static const List<Widget> _pages = <Widget>[HomePage(), ProfilePage()];

  void _onItemTapped(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_page),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home_outlined,
              color: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedItemColor,
            ),
            label: 'Home',
            labelStyle: TextStyle(
              color: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedItemColor!,
              fontWeight: FontWeight.w600,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.person_outline,
              color: Theme.of(
                context,
              ).bottomNavigationBarTheme.selectedItemColor,
            ),
            label: 'Profile',
            labelStyle: TextStyle(
              color: Theme.of(
                context,
              ).bottomNavigationBarTheme.unselectedItemColor!,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor!,
        buttonBackgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
    );
  }
}
