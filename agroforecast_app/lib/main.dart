import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const AgroForecastApp());
}

class AgroForecastApp extends StatelessWidget {
  const AgroForecastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroForecast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Premium Green
          brightness: Brightness.light,
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFFF9A825), // Golden
          surface: const Color(0xFFF8F9FA),
        ),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Colors.black87),
          titleTextStyle: GoogleFonts.outfit(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
