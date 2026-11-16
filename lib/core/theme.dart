import 'package:flutter/material.dart';

const forest = Color(0xFF19532B);
const cream = Color(0xFFFCF8F0);
const kiwi = Color(0xFFD0E08B);
ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: forest,
    primary: forest,
    surface: cream,
  ),
  scaffoldBackgroundColor: cream,
  appBarTheme: const AppBarTheme(
    backgroundColor: cream,
    foregroundColor: forest,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE1EDE4)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: kiwi,
  ),
);
