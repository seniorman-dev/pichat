import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pichat/theme/app_theme.dart';






class BottomNavBar extends StatefulWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;
  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppTheme().whiteColor,
      selectedItemColor: AppTheme().mainColor,
      unselectedItemColor: AppTheme().darkGreyColor,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 13.sp
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 13.sp
      ),
      items: _navBarsItems(),
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.selectedIndex,
      iconSize: 24.r,
      onTap: widget.onItemTapped,
      elevation: 0, //5,
    );
  }
}

List<BottomNavigationBarItem> _navBarsItems() {
  return <BottomNavigationBarItem>[
    const BottomNavigationBarItem(
      activeIcon: Icon(CupertinoIcons.hexagon_fill),
      icon: Icon(CupertinoIcons.hexagon),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill),
      icon: Icon(CupertinoIcons.chat_bubble_text),
      label: 'Groups',
    ),
    const BottomNavigationBarItem(
      activeIcon: Icon(CupertinoIcons.chart_pie_fill),
      icon: Icon(CupertinoIcons.chart_pie),
      label: 'Feeds',
    ),
    const BottomNavigationBarItem(
      activeIcon: Icon(CupertinoIcons.phone_fill),
      icon:  Icon(CupertinoIcons.phone),
      label: 'Calls',
    ),
    const BottomNavigationBarItem(
      activeIcon:  Icon(CupertinoIcons.gear_alt_fill),
      icon: Icon(CupertinoIcons.gear_alt),
      label: 'Account',
    ),
  ];
}
