import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pichat/main_page/widget/bottom_nav_bar.dart';
import 'package:pichat/theme/app_theme.dart';
import 'package:hidable/hidable.dart';
import 'package:pichat/user/chat/screen/chat_screen.dart';









class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final ScrollController scrollController = ScrollController();

  int selectedIndex = 0;

  final List<Widget> widgetOptions = <Widget>[
    ChatScreen(),
    Container(
      color: AppTheme().greenColor,
    ),
    Container(
      color: AppTheme().greenColor,
    ),
    Container(
      color: AppTheme().greenColor,
    )
  ];

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme().whiteColor,
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onItemTapped,      
      ),
    );
  }
}