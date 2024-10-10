import 'package:admin/bloc/auth.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/side_menu.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Define a variable to keep track of the current screen
  Widget _currentScreen = DashboardScreen(); // Default screen



  // Function to change the screen
  void _changeScreen(Widget newScreen) {
    setState(() {
      _currentScreen = newScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Scaffold(
            key: context
                .read<MenuAppController>()
                .scaffoldKey,
            drawer: SideMenu(onMenuItemSelected: _changeScreen),
            // Pass the function to SideMenu
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show side menu only for large screens
                  if (Responsive.isDesktop(context))
                    Expanded(
                      // Takes 1/6 part of the screen
                      child: SideMenu(
                          onMenuItemSelected: _changeScreen), // Pass the function here as well
                    ),
                  Expanded(
                    // Takes 5/6 part of the screen
                    flex: 5,
                    child: _currentScreen, // Display the current screen
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
