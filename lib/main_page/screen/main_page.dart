import 'package:flutter/material.dart';
import 'package:Ezio/main_page/widget/bottom_nav_bar.dart';
import 'package:Ezio/theme/app_theme.dart';
import 'package:Ezio/user/calls/screen/calls.dart';
import 'package:Ezio/user/chat/screen/home_screen.dart';
import 'package:Ezio/user/feeds/screen/feeds_screen.dart';
import 'package:Ezio/user/group_chat/screen/group_chat_screen.dart';
import 'package:Ezio/user/settings/screen/profile_screen.dart';









class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final ScrollController scrollController = ScrollController();

  int selectedIndex = 0;

  final List<Widget> widgetOptions = <Widget>[
    const ChatScreen(),
    const GroupChatMessages(),
    const FeedScreen(),
    const CallScreen(),
    const ProfileScreen()
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