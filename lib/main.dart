import 'package:admin/bloc/auth.dart';
import 'package:admin/bloc/profile.dart';
import 'package:admin/network/api_service.dart';
import 'package:admin/network/token.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/screens/main/main_screen.dart';

// Import your auth related files
import 'screens/auth/Login.dart';
import 'screens/auth/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenManager = await TokenManager.create();
  final apiService = ApiService(tokenManager);

  runApp(MyApp(tokenManager: tokenManager, apiService: apiService));
}

class MyApp extends StatelessWidget {
  final TokenManager tokenManager;
  final ApiService apiService;

  const MyApp({
    Key? key,
    required this.tokenManager,
    required this.apiService
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(apiService, tokenManager)),
        BlocProvider(create: (context) => ProfileBloc(apiService)),
        ChangeNotifierProvider(create: (context) => MenuAppController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Edventure Admin',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: kPrimaryColor,
                shape: const StadiumBorder(),
                maximumSize: const Size(double.infinity, 56),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              iconColor: kPrimaryColor,
              prefixIconColor: kPrimaryColor,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
            )),


        home: tokenManager.hasTokens ?
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => MenuAppController(),
            ),
          ],
          child: MainScreen(),
        ) : LoginScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/dashboard': (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => MenuAppController(),
              ),
            ],
            child: MainScreen(),
          ),
        },
      ),
    );
  }
}