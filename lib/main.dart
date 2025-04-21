import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MorningSortApp());
}

class MorningSortApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Morning Sort',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          primaryColor: Color(0xFF87CEEB), // Sky blue
          colorScheme: ColorScheme.light(
            primary: Color(0xFF87CEEB),
            secondary: Color(0xFFFFB74D), // Soft orange (sunrise)
            surface: Colors.white,
            background: Color(0xFFE3F2FD), // Very light blue
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF212121), // Dark header
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          scaffoldBackgroundColor: Color(0xFFE3F2FD), // Light blue background
          fontFamily: 'Montserrat',
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFFFFB74D), // Sunrise orange
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFB74D), // Sunrise orange
            ),
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          primaryColor: Color(0xFF1A237E), // Dark blue
          colorScheme: ColorScheme.dark(
            primary: Color(0xFF1A237E),
            secondary: Color(0xFFFF9800), // Brighter orange for dark mode
            surface: Color(0xFF212121),
            background: Color(0xFF121212),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          scaffoldBackgroundColor: Color(0xFF121212),
          fontFamily: 'Montserrat',
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xFFFF9800),
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9800),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: HomeScreen(),
      );
}