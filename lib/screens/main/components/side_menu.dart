import 'package:admin/screens/dashboard/chat_screen.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/dashboard/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final Function(Widget) onMenuItemSelected;

  SideMenu({required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              onMenuItemSelected(DashboardScreen()); // Change to DashboardScreen
              // Navigator.of(context).pop(); // Close the drawer
            },
          ),
          DrawerListTile(
            title: "AI Chat",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {
              onMenuItemSelected(GeminiChatBot()); // Change to DashboardScreen
              // Navigator.of(context).pop(); // Close the drawer
            },
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              onMenuItemSelected(UserProfileScreen()); // Change to DashboardScreen
              // Navigator.of(context).pop(); // Close the drawer
            },
          ),

        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
