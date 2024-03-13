import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gwengram/details_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData(useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,brightness: Brightness.dark,),textTheme: TextTheme(
    displayLarge: const TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.bold,), titleLarge: GoogleFonts.oswald(
        fontSize: 30,
        fontStyle: FontStyle.italic,
      ),
        bodyMedium: GoogleFonts.merriweather(),
        displaySmall: GoogleFonts.pacifico(),
      ),
    ),

     home:  const DetailsPage()

    );}
}




